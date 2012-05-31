require 'net/http'


module Net

  class HTTPResponse
  
    def error?
      not self.kind_of?(HTTPSuccess)
    end
  
  end

end


