class PurchasedItem < ApplicationRecord
  belongs_to :user
  belongs_to :selling_item

  include SlotIndex

  validates :user, presence: true
  validates :selling_item, presence: true

  validate :selling_item_canceled_if_new_record
  validate :selling_item_purchased_if_new_record
  validate :has_required_coin

  before_create :settle
  after_create :update_selling_item_status

  def item
    selling_item.item
  end

  private

  def selling_item_canceled_if_new_record
    errors.add(:base, "#{selling_item.item_name_with_metadata}は出品が取り消されました") if self.new_record? && self.selling_item.canceled?
  end

  def selling_item_purchased_if_new_record
    errors.add(:base, "#{selling_item.item_name_with_metadata}は売り切れました") if self.new_record? && self.selling_item.sold?
  end

  def has_required_coin
    errors.add(:base, "お金が足りません") if self.user.ts_character.coin_count < self.selling_item.coin_count
  end

  def settle
    # 購入者側処理
    TsCharacter.transaction do
      self.slot_index = self.user.ts_character.add_item(
        item_id: self.selling_item.item_id,
        stack: self.selling_item.stack,
        prefix_id: self.selling_item.prefix_id
      )
      self.user.ts_character.remove_coin(self.selling_item.coin_count) # 引き去りはアイテム追加よりあとにすること。インベントリの空きチェックを追加時にしているため

    end

    # 出品者側処理
    SellingItemPayJob.perform_later(self.selling_item.id)
  end

  def update_selling_item_status
    self.selling_item.paying! if !self.selling_item.paid?
  end
end
