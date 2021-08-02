class SellingItemsController < ApplicationController
  def index
    @status = params[:status].to_i
    @selling_items = SellingItem.where(status: @status).order(id: :desc)
  end

  def new
    @selling_item = SellingItem.new(selling_item_params.merge(stack: 1))
    @selling_item.load_item_by_inventory_index
    unless @selling_item.valid?
      redirect_to_root_path_with_untradable_message
    end
  end

  def create
    @selling_item = SellingItem.new(selling_item_params)
    begin
      if @selling_item.save
        flash[:success] = "#{@selling_item.item_name_with_metadata}の販売を開始しました"
        redirect_to selling_items_path
      else
        @selling_item.load_item_by_inventory_index
        if @selling_item.item.tradable?
          flash.now[:danger] = @selling_item.errors.full_messages
          render :new
        else
          redirect_to_root_path_with_untradable_message
        end
      end
    rescue Exception => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      flash.now[:danger] = e.message
      render :new
    end
  end

  def destroy
    @selling_item = current_user.selling_items.find(params[:id])
    begin
      @selling_item.cancel
      flash[:success] = "#{@selling_item.item_name_with_metadata}の販売をキャンセルしました"
      redirect_to selling_items_path(status: SellingItem.statuses[:canceled])
    rescue Exception => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      flash[:danger] = e.message
      redirect_to selling_items_path
    end
  end

  private

  def selling_item_params
    params.require(:selling_item).permit(
      :item_id,
      :stack,
      :prefix_id,
      :inventory_index,
      :transaction_type,
      :copper_coin_count,
      :silver_coin_count,
      :gold_coin_count,
      :platinum_coin_count
    ).merge(user: current_user)
  end

  def redirect_to_root_path_with_untradable_message
    flash[:danger] = "販売しようとしたアイテムがないか、販売できません"
    redirect_to root_path
  end
end
