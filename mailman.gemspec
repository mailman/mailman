# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

# this gemspec was mostly stolen from bundler

require 'mailman/version'

Gem::Specification.new do |s|
  s.name        = 'mailman'
  s.version     = Mailman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jonathan Rudenberg']
  s.email       = ['jonathan@titanous.com']
  s.homepage    = 'http://mailmanrb.com'
  s.summary     = 'A incoming email processing microframework'
  s.description = 'Mailman makes it easy to process incoming emails with a simple routing DSL'

  s.rubyforge_project = 'mailman'

  s.add_dependency 'mail', '>= 2.0.3'
  s.add_dependency 'activesupport', '>= 2.3.4'
  s.add_dependency 'fssm', '>= 0.1.4'
  s.add_dependency 'maildir', '>= 0.5.0'
  s.add_dependency 'i18n', '>= 0.4.1' # fix for mail/activesupport-3 dependency issue

  s.add_development_dependency 'rspec', '~> 2.6.0'

  s.files        = Dir.glob('{bin,lib,examples}/**/*') + %w(LICENSE README.md USER_GUIDE.md)
  s.require_path = 'lib'
end
