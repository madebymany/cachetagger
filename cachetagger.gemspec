lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "cachetagger/version"

Gem::Specification.new do |s|
  s.name        = "cachetagger"
  s.version     = Cachetagger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stuart Eccles"]
  s.email       = ["stuart@madebymany.co.uk"]
  s.homepage    = "http://github.com/madebymany/cachetagger"
  s.summary     = "Invalidate that cache using tags"
  s.description = "Allows storing of a number of tags against a cache key. Multiple cache entries can then be invalidated by the tag"
  s.add_dependency "dalli"
  s.files        = Dir["{lib}/**/*"] + %w[README.md]
  s.require_path = 'lib'
end
