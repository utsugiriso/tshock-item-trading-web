class CreateSellingItems < ActiveRecord::Migration[6.1]
  def change
    create_table :selling_items do |t|
      t.belongs_to :user, null: false, index: true

      t.integer :item_id, null: false
      t.integer :stack, null: false
      t.integer :prefix_id, null: false
      t.integer :slot_index, null: false

      t.integer :transaction_type, null: false
      t.integer :coin_count

      t.integer :status, null: false, default: 0

      t.datetime :canceled_at

      t.timestamps
    end
  end
end
