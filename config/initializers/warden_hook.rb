# app/config/initializers/warden_hooks.rb
Warden::Manager.after_set_user do |user,auth,opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = user.id
end

Warden::Manager.before_logout do |user,auth,opts|
  scope = opts[:scope]
  auth.cookies.delete "#{scope}.id"
end
