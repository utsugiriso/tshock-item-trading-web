class CreatePurchaseRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :purchase_requests do |t|
      t.belongs_to :user, null: false, index: true

      t.integer :item_id, null: false
      t.integer :stack, null: false
      t.integer :coin_count
      t.integer :transaction_type, null: false

      t.timestamps
    end
  end
end
