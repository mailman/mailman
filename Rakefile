# coding:utf-8
$:.unshift File.expand_path("../lib", __FILE__)

require 'rubygems'
require 'rubygems/specification'
require 'spec/rake/spectask'
require 'rake/gempackagetask'

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../mailman.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'gems,spec']
end

Rake::GemPackageTask.new(gemspec) do |pkg|
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
