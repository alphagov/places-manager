# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'iconv'
require 'rake/tasklib'
require 'open-uri'
if Rails.env.development? || Rails.env.test?
  require 'ci/reporter/rake/minitest'
end

class CachedUrlTask < Rake::TaskLib
  attr_accessor :url, :cache_file, :opts

  def initialize(*args)
    yield(self)
    cache_dir = File.dirname(cache_file)
    directory cache_dir
    file cache_file => cache_dir do
      $stderr.puts "Fetching #{url} and caching it in #{cache_file}"
      open_uri_args = [url]
      open_uri_args << opts if opts
      data = open(*open_uri_args).read.force_encoding('UTF-8')
      File.open(cache_file, 'w:UTF-8') { |f| f.write Iconv.conv('ASCII//IGNORE', 'UTF-8', data) }
    end
  end
end

Imminence::Application.load_tasks
