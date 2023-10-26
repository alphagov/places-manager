class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, type: Array
end
