Gem::Specification.new do |s|
  s.name = 'rack-informant'
  s.authors = ['Rapportive Inc']
  s.email = 'supportive@rapportive.com'
  s.version = '1.0.0'
  s.summary = %q{Reporting middleware.}
  s.description = "Middleware that reports all requests to an interested party (e.g. for analytics)."
  s.homepage = "https://github.com/rapportive-oss/rack-informant"
  s.date = Date.today.to_s
  s.files = `git ls-files`.split("\n")
  s.require_paths = %w(lib)
end
