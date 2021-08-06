module CoinCalculator
  extend ActiveSupport::Concern

  COPPER_COIN_WORTH = 100**0
  SILVER_COIN_WORTH = 100**1
  GOLD_COIN_WORTH = 100**2
  PLATINUM_COIN_WORTH = 100**3

  def coin_count
    if super.nil?
      return 0
    else
      super
    end
  end

  def copper_coin_count
    (self.coin_count / COPPER_COIN_WORTH) % 100
  end

  def copper_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * COPPER_COIN_WORTH
  end

  def silver_coin_count
    (self.coin_count / SILVER_COIN_WORTH) % 100
  end

  def silver_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * SILVER_COIN_WORTH
  end

  def gold_coin_count
    (self.coin_count / GOLD_COIN_WORTH) % 100
  end

  def gold_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * GOLD_COIN_WORTH
  end

  def platinum_coin_count
    self.coin_count / PLATINUM_COIN_WORTH
  end

  def platinum_coin_count=(value)
    self.coin_count += Kernel.Integer(value) * PLATINUM_COIN_WORTH
  end

end