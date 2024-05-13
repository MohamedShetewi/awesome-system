class Message < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.string :appID
      t.string :chatID
      t.string :messageID
      t.text :message


      t.timestamps
    end
  end
end
