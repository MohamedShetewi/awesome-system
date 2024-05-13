class CreateApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :applications do |t|
      t.string :appID
      t.string :username
      t.integer :chatsCount

      t.timestamps
    end
  end
end
