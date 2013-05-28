namespace :migrate do
  task :add_facet_values => :environment do
    pre_startup =  BusinessSupport::Stage.find_or_initialize_by(:name => 'Pre-startup', :slug => 'pre-startup')
    pre_startup.name = "Pre-start"
    pre_startup.slug = "pre-start"
    puts "Renamed 'Pre-startup' to 'Pre-start' (slug is now 'pre-start')" if pre_startup.save
   
    BusinessSupportScheme.where.in(stages:['pre-startup']).each do |bs| 
      bs.stages.map!{ |s| s.gsub('pre-startup','pre-start') }
      puts "Updated '#{bs.title}' with pre-start stage slug" if bs.save
    end 

    exiting_a_business = BusinessSupport::Stage.find_or_initialize_by(:name => 'Exiting a business', :slug => 'exiting-a-business')
    puts "Added 'Exiting a business'" if exiting_a_business.save
  end
end
