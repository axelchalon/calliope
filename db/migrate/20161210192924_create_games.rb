class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|

      t.references :player1, foreign_key:{to_table: :player}
      t.integer :player1_score

      t.references :player2, foreign_key:{to_table: :player}
      t.integer :player2_score

      t.timestamps
    end
  end
end
