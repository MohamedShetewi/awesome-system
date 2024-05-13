class AddIndexToMessagesTable < ActiveRecord::Migration[7.1]
  def change
    add_index :messages, [:appID, :chatID, :messageID], unique: true
    add_index :messages, [:appID, :chatID]
  end
end
