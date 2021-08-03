class PurchasedItem < ApplicationRecord
  belongs_to :user
  belongs_to :selling_item

  include InventoryIndex

  validates :user, presence: true
  validates :selling_item, presence: true

  validate :selling_item_canceled_if_new_record
  validate :selling_item_purchased_if_new_record
  validate :has_required_coin

  before_create :pay
  before_create :add_item_to_ts_character_inventory

  private

  def selling_item_on_sale_if_new_record
    errors.add(:base, "#{selling_item.item_name_with_metadata}は出品が取り消されました") if self.new_record? && self.selling_item.canceled?
  end

  def selling_item_purchased_if_new_record
    errors.add(:base, "#{selling_item.item_name_with_metadata}は売り切れました") if self.new_record? && self.selling_item.purchased_item.present?
  end

  def has_required_coin
    errors.add(:base, "お金が足りません") if self.user.coin_count < self.selling_item.coin_count
  end

  def pay
    self.user.ts_character.remove_coin(self.selling_item.coin_count)
    self.selling_item.paying!
    SellingItemPayJob.perform_now(selling_item.id)
  end

  def add_item_to_ts_character_inventory
    self.inventory_index = self.user.ts_character.add_item(
      item_id: self.item_id,
      stack: self.stack,
      prefix_id: self.prefix_id
    )
  end
end
