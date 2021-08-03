class SellingItem < ApplicationRecord
  belongs_to :user
  has_many :selling_item_barter_items, dependent: :destroy
  has_one :purchased_item

  enum status: [
    :on_sale,
    :canceled,
    :paying,
    :paid
  ]

  include CoinCalculator
  include EnumTransactionType
  include InventoryIndex

  attribute :loaded_item_by_inventory_index, :boolean, default: false

  validates :user, presence: true
  validates :item_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :stack, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :prefix_id, presence: true
  validates :inventory_index, presence: true

  validate :item_exists
  validate :within_max_stack
  validate :within_maximum_selling_item_count
  validate :check_coin
  validate :check_item_same

  with_options unless: :loaded_item_by_inventory_index? do
    validates :coin_count, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :coin_transaction_type?
  end

  before_create :remove_item_from_ts_character_inventory

  def item
    @item ||= Item.new(id: self.item_id, stack: self.stack, prefix_id: self.prefix_id)
  end

  def load_item_by_inventory_index
    @item = self.user.ts_character.items[inventory_index]
    self.item_id = @item.id
    self.stack = @item.stack
    self.prefix_id = @item.prefix_id
    self.loaded_item_by_inventory_index = true
  end

  def item_name_with_metadata
    if self.item.prefix.present?
      "#{self.item.name} (#{self.item.prefix})"
    elsif self.stack > 1
      "#{self.item.name} (#{self.stack})}" # stackだけはselfを参照すること
    else
      self.item.name
    end
  end

  def cancel
    ActiveRecord::Base.transaction do
      self.inventory_index =  self.user.ts_character.add_item(
        item_id: self.item_id,
        stack: self.stack,
        prefix_id: self.prefix_id,
        inventory_index: self.inventory_index
      )
      self.canceled_at = Time.current
      self.canceled!
    end
  end

  private

  def item_exists
    self.errors.add(:base, "アイテムが存在しません") if self.item.nil?
  end

  def within_max_stack
    self.errors.add(:base, "出品数が所持数を超えています") if self.item.stack < self.stack
  end

  def within_maximum_selling_item_count
    self.errors.add(:base, "同時に出品可能なのは#{TsCharacter::BANK_SLOT_COUNT}個までです") if self.user.selling_items.count == TsCharacter::BANK_SLOT_COUNT
  end

  def check_coin
    self.errors.add(:base, "コインは出品できません") if self.item.coin?
  end

  def check_item_same
    self.errors.add(:base, "選択していたスロットのアイテムが変更されました。ゲームをログアウトしてから操作してください") if self.item_id != self.item.id || self.prefix_id != self.item.prefix_id
  end

  def remove_item_from_ts_character_inventory
    self.user.ts_character.remove_item(
      inventory_index: self.inventory_index,
      stack: self.stack
    )
  end
end
