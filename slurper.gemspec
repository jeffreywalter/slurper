# -*- encoding: utf-8 -*-

require 'bundler'

Gem::Specification.new do |gem|
  gem.name = %q{eslurper}
  gem.version = "1.0.0"

  gem.required_rubygems_version = ">= 1.3.6"
  gem.authors = ["Wes Gibbs", "Adam Lowe", "Stephen Caudill", "Tim Pope", "Jeffrey Walter"]
  gem.date = Date.today.to_s
  gem.default_executable = %q{eslurp}
  gem.description = %q{
      Slurps stories from the given file (stories.slurper by default) and creates Pivotal Tracker stories from them. Useful during story carding sessions when you want to capture a number of stories quickly without clicking your way through the Tracker UI.
    }
  gem.email = %q{jeffrey.walter@ericsson.com}
  gem.executables = ["eslurp"]
  gem.extra_rdoc_files = [
    "README.rdoc"
  ]
  gem.files = [
    "bin/eslurp",
    "lib/slurper.rb",
    "lib/story.rb",
    "lib/cacert.pem"
  ]
  gem.homepage = %q{http://github.com/jeffreywalter/slurper}
  gem.rdoc_options = ["--charset=UTF-8"]
  gem.require_paths = ["lib"]
  gem.summary = %q{takes a formatted story file and puts it on Pivotal Tracker}
  gem.test_files = [
    "spec/slurper_spec.rb",
    "spec/story_spec.rb"
  ]

  gem.add_dependency("activeresource", ["~> 3.1.2"])
  gem.add_development_dependency("rspec", ["~> 1.3.0"])
  gem.add_development_dependency("ruby-debug19", ["~> 0.11.6"])
  gem.add_development_dependency("configuration", ["~> 1.2.0"])

end
