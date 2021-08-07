class PurchaseRequest < ApplicationRecord
  belongs_to :user

  include CoinCalculator
  include EnumTransactionType
  include ItemNameWithMetadata

  validates :user, presence: true
  validates :item_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :stack, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :coin_count, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :coin_transaction_type?

  validate :within_maximum_request_count

  def item
    @item ||= Item.new(id: self.item_id, stack: 0)
  end

  def within_maximum_request_count
    self.errors.add(:base, "ほしい物リクエストできるのは#{TsCharacter::STORAGE_SLOT_COUNT}個までです") if self.user.purchase_requests.count >= TsCharacter::STORAGE_SLOT_COUNT
  end
end
