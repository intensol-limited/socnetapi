class Socnetapi::Error
  class NotConnected < StandardError; end
  class SourceNotReady < StandardError; end
  class BadResponse < StandardError; end
  class MissingId < StandardError; end
end