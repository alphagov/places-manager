class DataSet
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :service
  embeds_many :places
  embeds_many :actions
  
  field :version, :type => Integer, :default => 1
  
  def activate!
    service.active_data_set_version = self.version
    service.save
  end
  
  def new_action(user,type,comment)
    action = Action.new(:requester_id=>user.id,:request_type=>type,:comment=>comment)
    self.actions << action
    action
  end
  
  def places_near(lat, lng, opts = {})
    ordered_places = places.select { |p| p.location }.sort_by { |p| p.distance_from(lat, lng) }
    if opts[:limit]
      ordered_places.slice(0, opts[:limit].to_i)
    elsif opts[:max_distance]
      ordered_places.select { |p| p.distance <= opts[:max_distance].to_f }
    end
  end
end
