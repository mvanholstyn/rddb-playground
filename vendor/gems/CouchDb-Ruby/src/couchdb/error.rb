
module Couch

  class RequestFailure < RuntimeError
  
  
    attr_accessor :method, :path, :msg, :code, :body
    
    
  end
  
end