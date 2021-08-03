class SellingItems::SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :current_user
  attribute :search_keyword, :string
  attribute :purchasable_only, :boolean, default: false
  attribute :order, :integer

  ORDER_BY_COIN_COUNT_ASK = 1
  ORDER_BY_COIN_COUNT_DESK = 2

  validates :current_user, presence: true

  def selling_items
    if @selling_items.nil?
      @selling_items = SellingItem.where.not(user_id: current_user.id).on_sale
      @selling_items = @selling_items.where(coin_count: 0..current_user.ts_character.coin_count) if self.purchasable_only
      if self.search_keyword.present?
        item_ids = []
        self.search_keyword.split(/[[:blank:]]/).reject(&:blank?).each do |keyword|
          Settings.items.each do |item_id, names|
            # Settings yamlなのでmapが使えない
            item_ids << item_id.to_s.to_i if names[:name].downcase.include?(keyword.downcase) || names[:internal_name].downcase.include?(keyword.downcase)
          end
        end
        @selling_items = @selling_items.where(item_id: item_ids)
      end
      case self.order
      when ORDER_BY_COIN_COUNT_ASK
        @selling_items = @selling_items.order(coin_count: :asc)
      when ORDER_BY_COIN_COUNT_DESK
        @selling_items = @selling_items.order(coin_count: :desc)
      else
        @selling_items = @selling_items.order(id: :desc)
      end
    end

    @selling_items
  end
end
