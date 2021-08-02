class CreateSellingItemBarterItems < ActiveRecord::Migration[6.1]
  def change
    create_table :selling_item_barter_items do |t|
      t.belongs_to :selling_item, null: false, index: true
      t.integer :item_id, null: false, index: true

      t.timestamps
    end
  end
end
