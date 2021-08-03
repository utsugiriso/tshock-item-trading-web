module InventoryIndex
  extend ActiveSupport::Concern

  def storage_item_id
    TsCharacter.storage_item_id_by_inventory_index(self.inventory_index)
  end
end