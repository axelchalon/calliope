require 'rails_helper'

RSpec.describe PlayersController, type: :controller do
  describe "#show" do
    it "shows username of given user" do
      player1 = Player.create!(username: "piou", password:"aaaaaaaa")
      get :show, params: {id: player1.id}
      expect(response).to have_http_status(:success)
      expect(response.body).to include(player1.username)
    end
  end
end
