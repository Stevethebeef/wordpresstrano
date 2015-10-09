Gem::Specification.new do |s|
  s.name = 'wordpresstrano'
  s.version = '0.2.4'
  s.date = '2015-08-09'
  s.authors = ['Nialto Services']
  s.email = 'support@nialtoservices.co.uk'
  s.summary = 'Deploy WordPress sites to web servers using Capistrano'
  s.description = 'Deploy your WordPress sites to web servers like cPanel using the Capistrano deployment tool'
  s.homepage = 'http://rubygems.org/gems/wordpresstrano'
  s.files = `git ls-files`.split($/)
  s.require_paths = ['lib']
  s.license = 'MIT'
  
  s.required_ruby_version = '>= 2.0.0'
  s.add_dependency 'capistrano', '~> 3.0', '>= 3.4.0'
end
