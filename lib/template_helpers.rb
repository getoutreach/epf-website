require 'json'

module TemplateHelpers

  def release_path
    package = JSON.parse(IO.read('node_modules/epf/package.json'))
    version = package['version']
    "/releases/epf-#{version}.zip"
  end

end