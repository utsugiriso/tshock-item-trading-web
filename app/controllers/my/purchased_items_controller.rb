class My::PurchasedItemsController < ApplicationController
  before_action :set_selling_item, except: :index

  def index; end

  def new

  end

  def create
    purchased_item = current_user.purchased_items.build(selling_item: @selling_item)
    begin
      if purchased_item.save
        flash[:success] = "#{purchased_item.selling_item.item_name_with_metadata}を購入しました"
        redirect_to my_selling_items_path
      else
        flash.now[:danger] = purchased_item.errors.full_messages
        redirect_to selling_items_path
      end
    rescue Exception => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      flash[:danger] = e.message
      redirect_to selling_items_path
    end
  end

  private def set_selling_item
    @selling_item = SellingItem.on_sale.find(params[:selling_item_id])
  end
end
