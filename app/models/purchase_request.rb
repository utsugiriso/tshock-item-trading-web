class PurchaseRequest < ApplicationRecord
  belongs_to :user

  include CoinCalculator
  include EnumTransactionType

  validates :user, presence: true
  validates :item_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :stack, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :coin_count, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :coin_transaction_type?
end
