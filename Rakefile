require 'rake/rdoctask'
require 'rake/testtask'

PKG_NAME           = 'acts_as_versioned_association'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the acts_as_versioned_association plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test/fixtures'  
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the acts_as_versioned_association plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "#{PKG_NAME} -- association versioning with active record models"
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
