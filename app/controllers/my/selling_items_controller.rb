class My::SellingItemsController < ApplicationController
  def index
    if params[:status].blank?
      @form = SalableItems::SearchForm.new(search_form_params)
    else
      @status = params[:status].to_i
      @selling_items = current_user.selling_items.where(status: @status).order(id: :desc).limit(TsCharacter::BANK_SLOT_COUNT)
    end
  end

  def new
    @selling_item = current_user.selling_items.build(selling_item_params.merge(stack: 1))
    @selling_item.load_item_by_slot_index
    unless @selling_item.valid?
      redirect_to_root_path_with_untradable_message
    end
  end

  def create
    @selling_item = current_user.selling_items.build(selling_item_params)
    begin
      if @selling_item.save
        flash[:success] = "#{@selling_item.item_name_with_metadata}の出品を開始しました"
        redirect_to my_selling_items_path(status: SellingItem.statuses[:on_sale])
      else
        @selling_item.load_item_by_slot_index
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
      flash[:success] = "#{@selling_item.item_name_with_metadata}の出品をキャンセルしました"
      redirect_to my_selling_items_path(status: SellingItem.statuses[:canceled])
    rescue Exception => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.join("\n")}")
      flash[:danger] = e.message
      redirect_to my_selling_items_path(status: SellingItem.statuses[:on_sale])
    end
  end

  private

  def selling_item_params
    params.require(:selling_item).permit(
      :item_id,
      :stack,
      :prefix_id,
      :slot_index,
      :transaction_type,
      :copper_coin_count,
      :silver_coin_count,
      :gold_coin_count,
      :platinum_coin_count
    )
  end

  def redirect_to_root_path_with_untradable_message
    flash[:danger] = "出品しようとしたアイテムがないか、出品できません"
    redirect_to root_path
  end

  def search_form_params
    params.fetch(:salable_items_search_form, {}).permit(
      :search_keyword
    ).merge(current_user: current_user)
  end
end
