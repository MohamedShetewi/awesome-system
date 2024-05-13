class AddIndexToChatsTable < ActiveRecord::Migration[7.1]
  def change
    add_index :chats, [:appID, :chatID], unique: true
  end
end
