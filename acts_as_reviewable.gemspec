# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "acts_as_reviewable"
  s.summary = "Reviews for any AR model with multi-dimensional ratings and review commentary."
  s.description = "Reviews for any AR model with multi-dimensional ratings and review commentary."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.version = "0.0.1"
end