require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "table_fu"
    gem.summary = %Q{TableFu makes arrays act like spreadsheets}
    gem.description = %Q{A library for manipulating tables as arrays}
    gem.email = "jeff.larson@gmail.com"
    gem.homepage = "http://propublica.github.com/table-fu/"
    gem.authors = ["Mark Percival", "Jeff Larson"]
    gem.add_dependency 'fastercsv'
    gem.add_development_dependency "spec"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "TableFu #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "render documentation for gh-pages"
task :gh do 
  require 'erb'
  File.open("index.html", "w") do |f|
    f.write ERB.new(File.open("documentation/index.html.erb").read).result
  end
end