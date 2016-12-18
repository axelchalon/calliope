class Player < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
          :registerable,
         :recoverable,
         :rememberable,
         :trackable,
          :validatable,
          :authentication_keys => [:username]

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def games
    Game.where(player1_id: id).or(Game.where(player2_id: id))
  end

end