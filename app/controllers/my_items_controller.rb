class MyItemsController < ApplicationController
  def index
    @items = current_user.ts_character.tradable_items(params[:innventory_item_id].to_i)
  end
end
