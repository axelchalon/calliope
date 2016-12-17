module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      puts "CONNECTION."
      # ici get le user_id de la request ou sinon en générer un ? ou est-ce que c'est plus bas niveau ?
      # service pour request en tant que guest login + hash?
      # self.uuid = SecureRandom.uuid
      # self.current_user = find_verified_user
      self.uuid = find_verified_user.id
    end

    protected
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          puts "Curent user OK"
          current_user
        else
          puts "Curent user REJECTED"
          reject_unauthorized_connection
        end
      end

  end
end
