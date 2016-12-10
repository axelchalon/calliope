class RemoveEmailFromPlayer < ActiveRecord::Migration[5.0]
  def change
    remove_column(:players, :email)
  end
end
