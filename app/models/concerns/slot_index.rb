module SlotIndex
  extend ActiveSupport::Concern

  def storage_item_id
    TsCharacter.storage_item_id_by_slot_index(self.slot_index)
  end
end