# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jdbc-sqlite3}
  s.version = "3.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Nick Sieger, Ola Bini and JRuby contributors}]
  s.date = %q{2011-06-17}
  s.description = %q{Install this gem and require 'sqlite3' within JRuby to load the driver.}
  s.email = %q{nick@nicksieger.com, ola.bini@gmail.com}
  s.extra_rdoc_files = [%q{Manifest.txt}, %q{README.txt}, %q{LICENSE.txt}]
  s.files = [%q{Manifest.txt}, %q{README.txt}, %q{LICENSE.txt}]
  s.homepage = %q{http://jruby-extras.rubyforge.org/ActiveRecord-JDBC}
  s.rdoc_options = [%q{--main}, %q{README.txt}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{SQLite3 JDBC driver for Java and SQLite3/ActiveRecord-JDBC.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
