class AddGuestAndAiToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :guest, :boolean, default: false
    add_column :players, :ai, :boolean, default: false
  end
end
