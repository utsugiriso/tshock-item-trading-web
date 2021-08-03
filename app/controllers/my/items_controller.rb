class My::ItemsController < ApplicationController
  def index
    @items = current_user.ts_character.tradable_items(params[:storage_item_id].to_i)
  end
end
