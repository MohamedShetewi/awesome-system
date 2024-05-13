class AddIndexToApplicationTable < ActiveRecord::Migration[7.1]
  def change
    add_index :applications, :appID, unique: true
  end
end
