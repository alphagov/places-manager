class UpdateIncorrectBusinessSizeSlugs < Mongoid::Migration
  def self.up
    BusinessSupportScheme.all.each do |bss|
      if bss[:business_sizes].include? 'between-501-and-100'
        bss.pull(:business_sizes, 'between-501-and-100')
        bss.push(:business_sizes, 'between-501-and-1000')
      end
    end
  end

  def self.down
  end
end