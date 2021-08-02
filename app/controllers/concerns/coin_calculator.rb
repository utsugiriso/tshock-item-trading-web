module CoinCalculator
  extend ActiveSupport::Concern

  def coin_count
    if super.nil?
      return 0
    else
      super
    end
  end

  def copper_coin_count
    (self.coin_count / Item::COPPER_COIN_WORTH) % 100
  end

  def copper_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * Item::COPPER_COIN_WORTH
  end

  def silver_coin_count
    (self.coin_count / Item::SILVER_COIN_WORTH) % 100
  end

  def silver_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * Item::SILVER_COIN_WORTH
  end

  def gold_coin_count
    (self.coin_count / Item::GOLD_COIN_WORTH) % 100
  end

  def gold_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * Item::GOLD_COIN_WORTH
  end

  def platinum_coin_count
    (self.coin_count / Item::PLATINUM_COIN_WORTH) % 100
  end

  def platinum_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * Item::PLATINUM_COIN_WORTH
  end

end