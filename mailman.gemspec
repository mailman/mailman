# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

# this gemspec was mostly stolen from bundler

require 'mailman/version'

Gem::Specification.new do |s|
  s.name        = 'mailman'
  s.version     = Mailman::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jonathan Rudenberg']
  s.email       = ['jonathan@titanous.com']
  s.homepage    = 'https://github.com/mailman/mailman'
  s.summary     = 'A incoming email processing microframework'
  s.description = 'Mailman makes it easy to process incoming emails with a simple routing DSL'

  s.rubyforge_project = 'mailman'

  s.add_dependency 'mail', '~>2.0', '>= 2.0.3'
  s.add_dependency 'activesupport', '>= 2.3.4'
  s.add_dependency 'listen', '>= 2.2', '<4'
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
    s.add_dependency 'maildir', '>= 0.5.0', '< 2.1.0'
  else
    s.add_dependency 'maildir', '>= 0.5.0'
  end
  s.add_dependency 'i18n', '>= 0.4.1' # fix for mail/activesupport-3 dependency issue

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rack', '~> 1.6'

  s.files        = Dir.glob('{bin,lib,examples}/**/*') + %w(LICENSE README.md USER_GUIDE.md CHANGELOG.md)
  s.require_path = 'lib'
  s.executables  = ['mailman']
end
