require 'dav4rack/file_resource'

module DAV4Rack
  
  class BuildResource < FileResource

    # TODO: This is a workaround of Rack bug
    # Fix is in master which is incompatible with current Rails (facepalm)
    # https://github.com/rack/rack/commit/7c36a88f73339bebe8b91b27e47ac958a7965f4f
    #
    # The whole method should be removed as soon as new Rack is released
    def get(request, response)
      return super unless stat.directory?

      response.body = ""

      rack_directory = Rack::Directory.new(root).call(request.env)[2]

      rack_directory.files.map do |x|
        x[0].gsub! /^#{Regexp.escape('%2Fbuilds')}/, '/builds'
        x
      end

      rack_directory.each do |line|
        response.body << line
      end
      response['Content-Length'] = response.body.bytesize.to_s
      OK
    end

    def put(*args)
      raise HTTPStatus::Forbidden
    end

    def delete(*args)
      raise HTTPStatus::Forbidden
    end

    def copy(*args)
      raise HTTPStatus::Forbidden
    end

    def move(*args)
      raise HTTPStatus::Forbidden
    end

    def make_collection
      raise HTTPStatus::Forbidden
    end

  protected

    def prop_hash
      {}
    end

  end

end