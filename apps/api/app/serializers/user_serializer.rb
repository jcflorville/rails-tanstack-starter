class UserSerializer < Blueprinter::Base
  identifier :id
  fields :email_address, :created_at
end
