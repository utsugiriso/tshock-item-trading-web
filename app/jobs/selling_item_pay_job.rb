class SellingItemPayJob < ApplicationJob
  queue_as :default

  def perform(selling_item_id)
    selling_item = SellingItem.find(selling_item_id)
    if selling_item.user.playing?
      selling_item.paying!
      SellingItemPayJob.set(wait: 10.minutes).perform_later(selling_item_id)
    else
      selling_item.paid!
      selling_item.user.ts_character.add_coin(selling_item.coin_count)
    end
  end
end
