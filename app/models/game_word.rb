class GameWord < ApplicationRecord
  belongs_to :game
  belongs_to :player

  before_create :set_empty_string_to_nil

  private

  def set_empty_string_to_nil
    self.word = nil if self.word === ""
  end

end
