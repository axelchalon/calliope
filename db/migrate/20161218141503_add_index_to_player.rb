class AddIndexToPlayer < ActiveRecord::Migration[5.0]
  def change
    change_table :players do |t|
      t.index :username, unique: true
    end
  end
end
