Rails.application.configure do
  config.action_cable.url = "ws://swarm.ovh:3000/cable"
end
