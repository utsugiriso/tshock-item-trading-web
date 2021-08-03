class TsCharacter < ApplicationRecord
  self.table_name = 'tsCharacter'
  establish_connection :tshock

  belongs_to :user, foreign_key: 'Account'

  include CoinCalculator

  INVENTORY_SLOT_COUNT = 59
  ARMOR_SLOT_COUNT = 20
  MISC_EQUIP_SLOT_COUNT = 5
  DYE_SLOT_COUNT = 10
  MISC_DYE_SLOT_COUNT = MISC_EQUIP_SLOT_COUNT
  TRASH_SLOT_COUNT = 1
  BANK_SLOT_COUNT = 40

  INVENTORY_SLOT_RANGE = (0...INVENTORY_SLOT_COUNT)
  ARMOR_SLOT_RANGE = (INVENTORY_SLOT_RANGE.last...(INVENTORY_SLOT_RANGE.last + ARMOR_SLOT_COUNT))
  DYE_RANGE = (ARMOR_SLOT_RANGE.last...(ARMOR_SLOT_RANGE.last + DYE_SLOT_COUNT))
  MISC_EQUIP_RANGE = (DYE_RANGE.last...(DYE_RANGE.last + MISC_EQUIP_SLOT_COUNT))
  MISC_DYE_RANGE = (MISC_EQUIP_RANGE.last...(MISC_EQUIP_RANGE.last + MISC_DYE_SLOT_COUNT))
  PIGGY_RANGE = (MISC_DYE_RANGE.last...(MISC_DYE_RANGE.last + BANK_SLOT_COUNT))
  SAFE_RANGE = (PIGGY_RANGE.last...(PIGGY_RANGE.last + BANK_SLOT_COUNT))
  TRASH_RANGE = (SAFE_RANGE.last...(SAFE_RANGE.last + TRASH_SLOT_COUNT))
  FORGE_RANGE = (TRASH_RANGE.last...(TRASH_RANGE.last + BANK_SLOT_COUNT))
  VOID_RANGE = (FORGE_RANGE.last...(FORGE_RANGE.last + BANK_SLOT_COUNT))

  PLATINUM_COIN_INVENTORY_INDEX = 54
  GOLD_COIN_INVENTORY_INDEX = 55
  SILVER_COIN_INVENTORY_INDEX = 56
  COPPER_COIN_INVENTORY_INDEX = 57

  ITEMS_DELIMITER = '~'.freeze
  ITEM_METADATA_DELIMITER = ','.freeze

  INVENTORY_RANGES = {
    Item::CHARACTER_INVENTORY_ID => INVENTORY_SLOT_RANGE,
    Item::PIGGY_BANK_ID => PIGGY_RANGE,
    Item::MONEY_THROUGH => PIGGY_RANGE,
    Item::SAFE_ID => SAFE_RANGE,
    Item::DEFENDERS_FORGE_ID => FORGE_RANGE,
    Item::VOID_VAULT_ID => VOID_RANGE,
    Item::VOID_BAG_ID => VOID_RANGE
  }.freeze

  attribute :coin_count, :integer, default: 0
  attribute :has_piggy_bank, :boolean, default: false
  attribute :has_safe, :boolean, default: false
  attribute :has_defenders_forge, :boolean, default: false
  attribute :has_void_bag, :boolean, default: false

  def items(storage_item_id = nil)
    @items ||= self['Inventory'].split(ITEMS_DELIMITER).
      map { |item_string| item_string.split(ITEM_METADATA_DELIMITER) }.
      map.with_index do |item_array, index|
      item = Item.new(id: item_array[0], stack: item_array[1], prefix_id: item_array[2], inventory_index: index)
      self.has_piggy_bank = true if item.piggy_bank?
      self.has_safe = true if item.safe?
      self.has_defenders_forge = true if item.defenders_forge?
      self.has_void_bag = true if item.void_bag?
      self.copper_coin_count += item.stack if item.copper_coin?
      self.silver_coin_count += item.stack if item.silver_coin?
      self.gold_coin_count += item.stack if item.gold_coin?
      self.platinum_coin_count += item.stack if item.platinum_coin?
      item
    end

    if storage_item_id.nil?
      @items
    else
      @items[INVENTORY_RANGES[storage_item_id]]
    end
  end

  def self.tradable_items(items)
    items.select { |item| item.tradable? }
  end

  def tradable_items(storage_item_id = nil)
    @tradable_items = {} if @tradable_items.nil?
    @tradable_items[storage_item_id] ||= TsCharacter.tradable_items(self.items(storage_item_id))
  end

  def has_item_ids?(item_ids)
    self.items.any? { |item| item_ids.include?(item.id) }
  end

  def update_inventory
    self.update_column(:Inventory, self.items.map(&:to_inventory_string).join(ITEMS_DELIMITER))
  end

  def raise_if_playing
    raise StandardError.new("ゲーム中はアイテムを取引できません。ログアウトしてから再度お試しください") if self.user.playing?
  end

  def self.slot_range_by_inventory_index(inventory_index)
    INVENTORY_RANGES.values.find { |inventory_range| inventory_range.include?(inventory_index) }
  end

  def self.storage_item_id_by_inventory_index(inventory_index)
    INVENTORY_RANGES.find { |_, inventory_range| inventory_range.include?(inventory_index) }[0]
  end

  def addable_slot?(item)
    item.empty? && (item.storage_item_ids.nil? || self.has_item_ids?(item.storage_item_ids))
  end

  # アイテムごとにスタック上限があり、その定義を持っていないため、アイテム通過時は空欄に埋めるようにする
  def add_item(item_id:, stack:, prefix_id:, inventory_index: nil)
    empty_item_slot = nil
    raise_if_playing

    empty_item_slot = self.items[inventory_index] if !inventory_index.nil? && addable_slot?(self.items[inventory_index])
    empty_item_slot = self.items[TsCharacter.slot_range_by_inventory_index(inventory_index)].find { |item| addable_slot?(item) } if empty_item_slot.nil?
    empty_item_slot = self.items.find { |item| addable_slot?(item) } if empty_item_slot.nil?

    if empty_item_slot.nil?
      raise StandardError.new("アイテムを追加するスペースがインベントリにありません")
    else
      empty_item_slot.id = item_id
      empty_item_slot.stack = stack
      empty_item_slot.prefix_id = prefix_id

      self.update_inventory
    end
    empty_item_slot.inventory_index
  end

  def remove_item(inventory_index:, stack:)
    raise_if_playing

    item = self.items[inventory_index]
    item.stack -= stack
    item.destroy if item.stack <= 0

    self.update_inventory
  end

  def reset_coin
    raise_if_playing
    self.items[PLATINUM_COIN_INVENTORY_INDEX] = self.platinum_coin_count
    self.items[GOLD_COIN_INVENTORY_INDEX] = self.gold_coin_count
    self.items[SILVER_COIN_INVENTORY_INDEX] = self.silver_coin_count
    self.items[COPPER_COIN_INVENTORY_INDEX] = self.copper_coin_count

    self.items.each do |item|
      item.destroy if item.coin?
    end

    self.update_inventory
  end

  def add_coin(coin_count)
    self.coin_count += coin_count
    self.reset_coin
  end

  def remove_coin(coin_count)
    self.coin_count -= coin_count
    self.reset_coin
  end
end
