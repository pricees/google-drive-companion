# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_drive_companion/version'

Gem::Specification.new do |gem|
  gem.name          = "google_drive_companion"
  gem.version       = GoogleDriveCompanion::VERSION
  gem.authors       = ["Edward Price"]
  gem.email         = ["ted.price+github@gmail.com"]
  gem.description   = %q{Interface with google drive from tha matrix}
  gem.summary       = %q{Interface with google drive from tha matrix}
  gem.homepage      = "https://github.com/pricees/google-drive-companion"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("google_drive")
  gem.add_development_dependency("minitest")
  gem.add_development_dependency("mocha")
end
