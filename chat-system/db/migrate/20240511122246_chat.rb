class Chat < ActiveRecord::Migration[7.1]
  def change # This method is called when we run the migration
    create_table :chats do |t| # Create a table called 'chats'
      t.string :appID # A column for the application ID
      t.string :chatID # A column for chat ID
      t.integer :messagesCount # A column for the message count

      t.timestamps # Automatically add columns for created_at and updated_at
    end
  end
end
