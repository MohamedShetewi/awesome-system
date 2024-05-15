class Message < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :appID, null: false
      t.integer :chatID, null: false
      t.integer :messageID, null: false
      t.text :message, null: false
      t.string :elasticsearchID, null: false


      t.timestamps
    end
  end
end
