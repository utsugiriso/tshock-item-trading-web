class Items::SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_keyword, :string

  def item_ids
    @item_ids ||= Item.search_item_ids(self.search_keyword) if search_keyword.present?
  end
end
