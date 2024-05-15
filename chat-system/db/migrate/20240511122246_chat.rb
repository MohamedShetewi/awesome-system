class Chat < ActiveRecord::Migration[7.1]
  def change # This method is called when we run the migration
    create_table :chats do |t| # Create a table called 'chats'
      t.string :appID, null: false
      t.integer :chatID, null: false
      t.integer :messagesCount

      t.timestamps # Automatically add columns for created_at and updated_at
    end
  end
end
