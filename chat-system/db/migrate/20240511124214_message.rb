class Message < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :appID, null: false
      t.string :chatID, null: false
      t.string :messageID, null: false
      t.text :message, null: false


      t.timestamps
    end
  end
end
