class Item
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :stack, :integer
  attribute :prefix_id, :integer
  attribute :slot_index, :integer

  COPPER_COIN_ID = 71
  SILVER_COIN_ID = 72
  GOLD_COIN_ID = 73
  PLATINUM_COIN_ID = 74
  COIN_IDS = [COPPER_COIN_ID, SILVER_COIN_ID, GOLD_COIN_ID, PLATINUM_COIN_ID].freeze

  CHARACTER_INVENTORY_ID = 0
  CHARACTER_INVENTORY_IMAGE_ID = 267
  PIGGY_BANK_ID = 87
  MONEY_THROUGH = 3213
  SAFE_ID = 346
  DEFENDERS_FORGE_ID = 3813
  VOID_VAULT_ID = 4076
  VOID_BAG_ID = 4131

  SEARCH_ICON_ITEM_ID = 1299

  def item_definition
    Settings.items[self.id]
  end

  def name
    item_definition&.name
  end

  def prefix
    if self.prefix_id.present? && self.prefix_id != 0
      Settings.item_prefixes[self.prefix_id]
    else
      nil
    end
  end

  def image_url
    Item.image_url(self.id)
  end

  def self.image_url(id)
    File.join(Settings.item_images_directory_url, "item_#{id}.png")
  end

  STORAGE_ITEM_IMAGE_IDS = {
    Item::CHARACTER_INVENTORY_ID => Item::CHARACTER_INVENTORY_IMAGE_ID,
    Item::PIGGY_BANK_ID => Item::PIGGY_BANK_ID,
    Item::MONEY_THROUGH => Item::PIGGY_BANK_ID,
    Item::SAFE_ID => Item::SAFE_ID,
    Item::DEFENDERS_FORGE_ID => Item::DEFENDERS_FORGE_ID,
    Item::VOID_VAULT_ID => Item::VOID_BAG_ID,
    Item::VOID_BAG_ID => Item::VOID_BAG_ID
  }.freeze

  def self.storage_item_image_url(id)
    image_url(STORAGE_ITEM_IMAGE_IDS[id])
  end

  def invalid?
    self.id.blank? || self.id == 0
  end

  alias empty? invalid?

  def valid?
    !invalid?
  end

  def self.coin?(item_id)
    COIN_IDS.include?(item_id)
  end

  def coin?
    Item.coin?(self.id)
  end

  def piggy_bank?
    self.id == PIGGY_BANK_ID || self.id == MONEY_THROUGH
  end

  def safe?
    self.id == SAFE_ID
  end

  def defenders_forge?
    self.id == DEFENDERS_FORGE_ID
  end

  def void_bag?
    self.id == VOID_BAG_ID || self.id == VOID_VAULT_ID
  end

  def copper_coin?
    self.id == COPPER_COIN_ID
  end

  def silver_coin?
    self.id == SILVER_COIN_ID
  end

  def gold_coin?
    self.id == GOLD_COIN_ID
  end

  def platinum_coin?
    self.id == PLATINUM_COIN_ID
  end

  def tradable?
    !(self.invalid? || self.coin?)
  end

  def to_inventory_string
    [self.id, self.stack, self.prefix_id].join(TsCharacter::ITEM_METADATA_DELIMITER)
  end

  def destroy
    self.id = 0
    self.stack = 0
    self.prefix_id = 0
  end

  def storage_item_ids
    raise StandardError.new("slot_indexが指定されていない場合はstorage_item_idsを取得できません") if self.slot_index.nil?

    if TsCharacter::INVENTORY_SLOT_RANGE.include?(self.slot_index)
      [CHARACTER_INVENTORY_ID]
    elsif TsCharacter::PIGGY_RANGE.include?(self.slot_index)
      [PIGGY_BANK_ID, MONEY_THROUGH]
    elsif TsCharacter::SAFE_RANGE.include?(self.slot_index)
      [SAFE_ID]
    elsif TsCharacter::FORGE_RANGE.include?(self.slot_index)
      [DEFENDERS_FORGE_ID]
    elsif TsCharacter::VOID_RANGE.include?(self.slot_index)
      [VOID_BAG_ID, VOID_VAULT_ID]
    else
      nil
    end
  end

  def self.search_item_ids(search_keyword)
    item_ids = []

    search_keyword.split(/[[:blank:]]/).reject(&:blank?).each do |keyword|
      Settings.items.each do |item_id, names|
        # Settings yamlなのでmapが使えない
        item_id = item_id.to_s.to_i
        item_ids << item_id if !Item.coin?(item_id) && (names[:name].downcase.include?(keyword.downcase) || names[:internal_name].downcase.include?(keyword.downcase))
      end
    end

    item_ids
  end
end
