class SalableItems::SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :current_user
  attribute :search_keyword, :string

  validates :current_user, presence: true

  def items
    if @items.nil?
      @items = current_user.ts_character.salable_items
      if self.search_keyword.present? && self.search_keyword
        item_ids = Item.search_item_ids(self.search_keyword)
        @items = @items.select { |item| item_ids.include?(item.id) }
      end
    end

    @items
  end
end
