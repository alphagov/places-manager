require 'csv'

class BusinessSupportDataImporter

  attr_reader :bsf_schemes, :imported, :failed
  
  DATA_FILENAMES = ["bsf_schemes", "bsf_locations", "bsf_sectors",
    "bsf_stages", "bsf_business_types", "bsf_schemes_business_types", 
    "bsf_types", "bsf_schemes_locations", "bsf_schemes_sectors", 
    "bsf_schemes_stages", "bsf_schemes_types"]
  
  def initialize(data_dir)
    @imported = []
    @failed = []
    DATA_FILENAMES.each do |name|
      instance_variable_set("@#{name}", csv_data(data_dir, name))
    end
  end
  
  def self.run(data_dir)
      importer = BusinessSupportDataImporter.new(data_dir)
      importer.bsf_schemes.each do |row|
        importer.import(row)
      end
    ensure
      puts importer.formatted_result
  end
    
  def import row
    title = to_utf8(row['title'])
    scheme = BusinessSupportScheme.create(title: title, business_support_identifier: slug_for(title))
    
    if scheme
      puts "Created scheme '#{scheme.title}'."
      make_associations(scheme, row, "business_type")
      make_associations(scheme, row, "location")
      make_associations(scheme, row, "sector")
      make_associations(scheme, row, "stage")
      make_associations(scheme, row, "type")
    else
      @failed << "Failed to create scheme '#{title}', slug: '#{slug}'."
    end
    
    @imported << "#{scheme.business_support_identifier}" if scheme.save
  end
 
  def make_associations(scheme, row, key)
    scheme_collection = scheme.send("business_support_#{key}s")
    associate_class = Kernel.const_get("BusinessSupport#{key.camelize}")
    associate_collection = instance_variable_get("@bsf_#{key}s")
    join_collection = instance_variable_get("@bsf_schemes_#{key}s")
    associations = join_collection.find_all { |join_row| row['id'] == join_row['bsf_scheme_id'] }
    associations.each do |association|
      associated = associate_collection.find { |assoc| assoc['id'] == association["bsf_#{key}_id"] } 
      unless associated.nil?
        scheme_collection << associate_class.find_or_create_by(name: to_utf8(associated['name']), slug: slug_for(associated['name']))
        puts "Associated #{key} #{associated['name']} with scheme '#{scheme.title}'."
      end
    end
  end
  
  def slug_for(title)
    title.parameterize.gsub("-amp-", "-and-")
  end
  
  def to_utf8(str)
    (str.nil? ? nil : str.force_encoding("UTF-8"))
  end
  
  def formatted_result
    puts "--------------------------------------------------------------------------"
    puts "#{imported.size} BusinessSupportSchemes imported:"
    imported.sort.each { |i| puts i }
    puts "--------------------------------------------------------------------------"
    puts "#{failed.size} failed imports:"
    failed.sort.each { |f| puts f }
    puts "--------------------------------------------------------------------------"
  end
  
  def csv_data(data_dir, name)
    CSV.read(File.join(Rails.root, data_dir, "#{name}.csv"), headers: true)
  end

end
