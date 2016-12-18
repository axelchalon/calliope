class Player < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
          :registerable,
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

  def won_games
    p1games = Game.where(player1: self).where('player1_score > player2_score')
    p2games = Game.where(player2: self).where('player2_score > player1_score')
    (p1games + p2games)
  end

  def lost_games
    p1games = Game.where(player1: self).where('player1_score < player2_score')
    p2games = Game.where(player2: self).where('player2_score < player1_score')
    (p1games + p2games)
  end

  # bit of meta programming :o
  ["won_games", "lost_games"].each do |method|
    define_method "#{method}_size" do
      eval(method).size
    end
  end

  def two_weeks_average_score
    two_weeks_ago = Game.where("created_at > ?",2.weeks.ago)

    p1_games_scores = two_weeks_ago.where(player1: self).pluck(:player1_score)
    p2_games_scores = two_weeks_ago.where(player2: self).pluck(:player2_score)

    scores = p1_games_scores.concat(p2_games_scores)

    return 0 if scores.size < 1

    scores.inject{ |sum, el| sum + el }.to_f / scores.size
  end

end
