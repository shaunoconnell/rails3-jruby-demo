# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jruby-jars}
  s.version = "1.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Charles Oliver Nutter}]
  s.date = %q{2011-10-25}
  s.description = %q{This gem includes the core JRuby code and the JRuby 1.8 stdlib as jar files.
It provides a way to have other gems depend on JRuby without including (and
freezing to) a specific jruby-complete jar version.}
  s.email = [%q{headius@headius.com}]
  s.extra_rdoc_files = [%q{History.txt}, %q{Manifest.txt}, %q{README.txt}]
  s.files = [%q{History.txt}, %q{Manifest.txt}, %q{README.txt}]
  s.homepage = %q{http://github.com/jruby/jruby/tree/master/gem/}
  s.rdoc_options = [%q{--main}, %q{README.txt}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.8.9}
  s.summary = %q{This gem includes the core JRuby code and the JRuby 1.8 stdlib as jar files}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
    else
      s.add_dependency(%q<hoe>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<hoe>, ["~> 2.12"])
  end
end
