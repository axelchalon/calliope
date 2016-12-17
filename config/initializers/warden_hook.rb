# app/config/initializers/warden_hooks.rb
Warden::Manager.after_set_user do |user,auth,opts|
  puts "WARDEN HOOK IS CALLED"
  puts "WARDEN HOOK IS CALLED"
  puts "WARDEN HOOK IS CALLED"
  puts "WARDEN HOOK IS CALLED"
  puts "WARDEN HOOK IS CALLED"
  scope = opts[:scope]
  puts "WARDEN HOOK IS CALLED + #{scope}.id"
  auth.cookies.signed["#{scope}.id"] = user.id
end
