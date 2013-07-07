require 'middleman-gh-pages'
require 'rubygems'
require 'json'

desc 'update release files from npm'
task :update_release do
  `npm update epf`
  `cd node_modules/epf; npm install; ./build-browser`

  package = JSON.parse(IO.read('node_modules/epf/package.json'))

  version = package['version']

  directory = 'node_modules/epf/dist'
  zipfile_name = "source/releases/epf-#{version}.zip"

  `zip -rj #{zipfile_name} #{directory}`
end