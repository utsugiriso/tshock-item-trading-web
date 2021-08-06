class PurchaseRequestsController < ApplicationController
  def index; end

  def my_index; end

  def search_items
    @form = Items::SearchForm.new(search_form_params)
  end

  def new
    @purchase_request = current_user.purchase_requests.build(purchase_request_params.merge(stack: 1))
  end

  def create
    @purchase_request = current_user.purchase_requests.build(purchase_request_params)
    if @purchase_request.save
      flash[:success] = "#{@purchase_request.item_name_with_metadata}をほしい物リクエストしました"
      redirect_to my_index_purchase_requests_path
    else
      flash.now[:danger] = @purchase_request.errors.full_messages
      render :new
    end
  end

  def destroy
    @purchase_request = current_user.purchase_requests.find(params[:id])
    @purchase_request.destroy
    flash[:success] = "#{@purchase_request.item_name_with_metadata}のほしい物リクエストを削除しました"
    redirect_to my_index_purchase_requests_path
  end

  private

  def search_form_params
    params.fetch(:items_search_form, {}).permit(
      :search_keyword
    )
  end

  def purchase_request_params
    params.require(:purchase_request).permit(
      :item_id,
      :stack,
      :transaction_type,
      :copper_coin_count,
      :silver_coin_count,
      :gold_coin_count,
      :platinum_coin_count
    )
  end
end
