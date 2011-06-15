class Socnetapi::Error
  class NotConnected < StandardError; end
  class SourceNotReady < StandardError; end
  class BadResponse < StandardError
    attr_accessor :code, :http_code
    def initialize msg=nil, code=nil, http_code=nil
      super msg
      @code = code
      @http_code = http_code
    end
  end
  class MissingId < StandardError; end
end