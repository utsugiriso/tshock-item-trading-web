class TsCharacter < ApplicationRecord
  self.table_name = 'tsCharacter'
  establish_connection :tshock

  belongs_to :user, foreign_key: 'Account'

  include CoinCalculator

  INVENTORY_SLOT_COUNT = 50
  COIN_SLOT_COUNT = 4
  AMMO_SLOT_COUNT = 4
  CURSOR_SLOT_COUNT = 1
  ARMOR_SLOT_COUNT = 20
  MISC_EQUIP_SLOT_COUNT = 5
  DYE_SLOT_COUNT = 10
  MISC_DYE_SLOT_COUNT = MISC_EQUIP_SLOT_COUNT
  TRASH_SLOT_COUNT = 1
  BANK_SLOT_COUNT = 40

  INVENTORY_SLOT_RANGE = (0...INVENTORY_SLOT_COUNT)
  COIN_SLOT_RANGE = (INVENTORY_SLOT_RANGE.last...INVENTORY_SLOT_RANGE.last + COIN_SLOT_COUNT)
  AMMO_SLOT_RANGE = (COIN_SLOT_RANGE.last...COIN_SLOT_RANGE.last + AMMO_SLOT_COUNT)
  CURSOR_SLOT_RANGE = (AMMO_SLOT_RANGE.last...AMMO_SLOT_RANGE.last + CURSOR_SLOT_COUNT)
  ARMOR_SLOT_RANGE = (CURSOR_SLOT_RANGE.last...(CURSOR_SLOT_RANGE.last + ARMOR_SLOT_COUNT))
  DYE_RANGE = (ARMOR_SLOT_RANGE.last...(ARMOR_SLOT_RANGE.last + DYE_SLOT_COUNT))
  MISC_EQUIP_RANGE = (DYE_RANGE.last...(DYE_RANGE.last + MISC_EQUIP_SLOT_COUNT))
  MISC_DYE_RANGE = (MISC_EQUIP_RANGE.last...(MISC_EQUIP_RANGE.last + MISC_DYE_SLOT_COUNT))
  PIGGY_RANGE = (MISC_DYE_RANGE.last...(MISC_DYE_RANGE.last + BANK_SLOT_COUNT))
  SAFE_RANGE = (PIGGY_RANGE.last...(PIGGY_RANGE.last + BANK_SLOT_COUNT))
  TRASH_RANGE = (SAFE_RANGE.last...(SAFE_RANGE.last + TRASH_SLOT_COUNT))
  FORGE_RANGE = (TRASH_RANGE.last...(TRASH_RANGE.last + BANK_SLOT_COUNT))
  VOID_RANGE = (FORGE_RANGE.last...(FORGE_RANGE.last + BANK_SLOT_COUNT))

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

  after_initialize :items

  def items(storage_item_id = nil)
    @items ||= self['Inventory'].split(ITEMS_DELIMITER).
      map { |item_string| item_string.split(ITEM_METADATA_DELIMITER) }.
      map.with_index do |item_array, index|
      item = Item.new(id: item_array[0], stack: item_array[1], prefix_id: item_array[2], slot_index: index)
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

  def self.salable_items(items)
    items.select { |item| item.tradable? }
  end

  def salable_items(storage_item_id = nil)
    @salable_items = {} if @salable_items.nil?
    @salable_items[storage_item_id] ||= TsCharacter.salable_items(self.items(storage_item_id))
  end

  def has_item_ids?(item_ids)
    return false if item_ids.blank?
    self.items.any? { |item| item_ids.include?(item.id) }
  end

  def update_inventory
    self.update_column(:Inventory, self.items.map(&:to_inventory_string).join(ITEMS_DELIMITER))
  end

  def raise_if_playing
    raise StandardError.new("ゲーム中はアイテムを取引できません。ログアウトしてから再度お試しください") if self.user.playing?
  end

  def self.slot_range_by_slot_index(slot_index)
    INVENTORY_RANGES.values.find { |inventory_range| inventory_range.include?(slot_index) }
  end

  def self.storage_item_id_by_slot_index(slot_index)
    INVENTORY_RANGES.find { |_, inventory_range| inventory_range.include?(slot_index) }[0]
  end

  def addable_slot?(item)
    item.empty? && (item.storage_item_ids&.include?(Item::CHARACTER_INVENTORY_ID) || self.has_item_ids?(item.storage_item_ids))
  end

  # アイテムごとにスタック上限があり、その定義を持っていないため、アイテム追加時は空欄に埋めるようにする
  def add_item(item_id:, stack:, prefix_id:, slot_index: nil)
    empty_item_slot = nil
    raise_if_playing

    empty_item_slot = self.items[slot_index] if !slot_index.nil? && addable_slot?(self.items[slot_index])
    empty_item_slot = self.items[TsCharacter.slot_range_by_slot_index(slot_index)].find { |item| addable_slot?(item) } if empty_item_slot.nil? && !slot_index.nil?
    empty_item_slot = self.items.find { |item| addable_slot?(item) } if empty_item_slot.nil?

    if empty_item_slot.nil?
      raise StandardError.new("アイテムを追加するスペースがインベントリにありません")
    else
      empty_item_slot.id = item_id
      empty_item_slot.stack = stack
      empty_item_slot.prefix_id = prefix_id

      self.update_inventory
    end
    empty_item_slot.slot_index
  end

  def remove_item(slot_index:, stack:)
    raise_if_playing

    item = self.items[slot_index]
    item.stack -= stack
    item.destroy if item.stack <= 0

    self.update_inventory
  end

  def set_coin(coin_item_id, coin_count)
    coin_slot = self.items[COIN_SLOT_RANGE].find(&:empty?)

    raise StandardError.new("アイテムが入っているスロットにコインをセットしようとしました") if coin_slot.valid?
    raise StandardError.new("プラチナコイン999枚以上には対応していません") if coin_item_id == Item::PLATINUM_COIN_ID && coin_slot.stack > 999

    coin_slot.destroy
    coin_slot.id = coin_item_id
    coin_slot.stack = coin_count
  end

  def reset_coin
    raise_if_playing

    # 先にインベントリー内のコインを全削除すること
    self.items.each do |item|
      item.destroy if item.coin?
    end

    self.set_coin(Item::PLATINUM_COIN_ID,  self.platinum_coin_count)
    self.set_coin(Item::GOLD_COIN_ID,  self.gold_coin_count)
    self.set_coin(Item::SILVER_COIN_ID,  self.silver_coin_count)
    self.set_coin(Item::COPPER_COIN_ID,  self.copper_coin_count)

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
