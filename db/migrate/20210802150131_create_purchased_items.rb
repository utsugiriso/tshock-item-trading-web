class CreatePurchasedItems < ActiveRecord::Migration[6.1]
  def change
    create_table :purchased_items do |t|
      t.belongs_to :user, null: false, index: true
      t.belongs_to :selling_item, null: false, index: true

      t.integer :slot_index, null: false

      t.timestamps
    end
  end
end
