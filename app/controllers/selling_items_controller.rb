class SellingItemsController < ApplicationController
  def index
    @form = SellingItems::SearchForm.new(search_form_params)
  end

  private def search_form_params
    params.fetch(:selling_items_search_form, {}).permit(
      :search_keyword,
      :purchasable_only,
      :order
    ).merge(current_user: current_user)
  end
end
