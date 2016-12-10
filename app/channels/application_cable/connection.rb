module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      puts "CONNECTION."
      self.uuid = SecureRandom.uuid
      @toasterette = "Toasterette"
    end
  end
end
