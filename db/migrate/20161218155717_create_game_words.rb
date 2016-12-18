class CreateGameWords < ActiveRecord::Migration[5.0]
  def change
    create_table :game_words do |t|
      t.references :game, foreign_key: true
      t.references :player, foreign_key: true
      t.string :previous_letter
      t.string :word

      t.timestamps
    end
  end
end
