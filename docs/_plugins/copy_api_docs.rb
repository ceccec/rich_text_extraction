# frozen_string_literal: true

# Jekyll plugin to copy YARD-generated API documentation into the site
Jekyll::Hooks.register :site, :pre_render do |site|
  api_source = File.join(site.source, 'api')
  api_dest = File.join(site.dest, 'api')

  if Dir.exist?(api_source)
    # Create destination directory if it doesn't exist
    FileUtils.mkdir_p(api_dest) unless Dir.exist?(api_dest)

    # Copy all files from api source to api destination
    FileUtils.cp_r(Dir.glob(File.join(api_source, '*')), api_dest)

    Jekyll.logger.info "Copied API documentation from #{api_source} to #{api_dest}"
  else
    Jekyll.logger.warn "API documentation source not found at #{api_source}"
  end
end
