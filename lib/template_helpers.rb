require 'json'

module TemplateHelpers

  def release_version
    package = JSON.parse(IO.read('node_modules/epf/package.json'))
    version = package['version']
  end

  def release_path
    "/releases/epf-#{release_version}.zip"
  end

end