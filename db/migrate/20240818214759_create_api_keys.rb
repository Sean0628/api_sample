class CreateApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_keys do |t|
      t.string :key, null: false, unique: true
      t.datetime :expired_at, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :api_keys, :key, unique: true
  end
end
