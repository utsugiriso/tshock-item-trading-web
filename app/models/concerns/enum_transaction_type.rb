module EnumTransactionType
  extend ActiveSupport::Concern

  included do
    enum transaction_type: [:coin, :barter], _suffix: true
  end
end