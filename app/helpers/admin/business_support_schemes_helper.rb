module Admin::BusinessSupportSchemesHelper
  
  PRIORITIES = { 0 => "Low", 1 => "Normal", 2 => "High" }

  def priority_options
    options = []
    PRIORITIES.each { |k,v| options << [v, k] }
    options
  end

  def priority_label(val)
    PRIORITIES[val] 
  end
end
