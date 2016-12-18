class PlayersController < ApplicationController
  #before_actions :require_login

  def show
    @player = Player.find(params[:id])
    render html: "Current player name : #{@player.username}", status: 200
  end

  private

    def require_login
      unless player_signed_in?
        flash[:error] = "Please sign in"
        redirect_to :root
      end
    end
end
