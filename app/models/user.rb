class User
  include Mongoid::Document
  include GDS::SSO::User

  cache

  field  :uid, :type => String
  field  :email, :type => String
  field  :version, :type => Integer
  field  :name, :type => String

  def record_action(data_set, type, comment=nil)
    action = data_set.new_action(self, type, comment)
    # NoisyWorkflow.make_noise(edition.container,action).deliver
  end

  def self.find_by_uid(uid)
    first(conditions: {uid: uid})
  end

  def activate_data_set(data_set)
    data_set.activate!
    record_action(data_set, 'activated')
  end
end
