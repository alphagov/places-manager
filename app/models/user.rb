class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array

  def record_action(data_set, type, comment = nil)
    data_set.new_action(self, type, comment)
    # NoisyWorkflow.make_noise(edition.container,action).deliver
  end

  def self.find_by_uid(uid)
    find_by(uid: uid)
  end

  def activate_data_set(data_set)
    data_set.activate
    record_action(data_set, "activated")
  end

  def to_s
    name
  end
end
