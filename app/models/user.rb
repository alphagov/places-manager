class User
  include Mongoid::Document
  include GDS::SSO::User

  field :uid, type: String
  field :email, type: String
  field :version, type: Integer
  field :name, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false
  field :organisation_slug, type: String
  field :organisation_content_id, type: String
  field :disabled, type: Boolean, default: false

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
