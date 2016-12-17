module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      puts "CONNECTION."
      # ici get le user_id de la request ou sinon en générer un ? ou est-ce que c'est plus bas niveau ?
      # service pour request en tant que guest login + hash?
      # self.uuid = SecureRandom.uuid
      # self.current_user = find_verified_user
      self.uuid = find_verified_player.id
    end

    protected
      def find_verified_player
        if current_player = Player.find_by(id: cookies.signed['player.id'])
          puts "Curent player REGISTERED"
          current_player
        else
          puts "Curent player GUEST"
          player = Player.create!(username: "Guest", password: rand(100000..999999)) # @TODO add flag guest
          player.username = "Guest #" + player.id.to_s
          player.save!
          player
          # reject_unauthorized_connection
        end
      end

  end
end
