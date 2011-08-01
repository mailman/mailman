# coding:utf-8
$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'rubygems/specification'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../mailman.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--color", "--backtrace", "-f documentation", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rspec_opts = ["--color", "--backtrace", "-f documentation", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov_opts =  %q[--exclude "gems, spec"]
end

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end
task :gem => :gemspec

desc 'install the gem locally'
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc 'validate the gemspec'
task :gemspec do
  gemspec.validate
end

task :package => :gemspec
task :default => :spec
