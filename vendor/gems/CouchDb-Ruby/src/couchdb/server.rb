require 'net/http'

module Couch
  
  #
  # The Server class contains the information to connect
  # to a CouchDb server and provide methods for the raw 
  # HTTP server interactions.
  # 
  # To connect to a CouchDb server on localhost port 8888 you can initialize
  # a server object like:
  # 
  #   server = CouchDb::Server.new("localhost", "8888")
  #
  # Rather than calling the server get, put, delete and post methods 
  # directly you should work with Db class instead.  
  # 
  #
  class Server
    def initialize(host, port, options = nil)
      @host = host;
      @port = port;
      @options = options;
    end
    
    # low-level HTTP Delete.
    # Returns HTTP::Response
    def delete(uri)
      request(Net::HTTP::Delete.new(uri))    
    end
    
    # low-level HTTP Get.
    # Returns HTTP::Response
    def get(uri)
      request(Net::HTTP::Get.new(uri))    
    end
    
    # low-level HTTP Put.
    # Returns HTTP::Response
    def put(uri, xml)
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/xml"
      req.body = xml
      request(req)
    end
    
    # low-level HTTP Post.
    # Returns HTTP::Response
    def post(uri, xml)
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/xml"
      req.body = xml
      request(req)
    end
    
    private
    
    def request(req)
      res = Net::HTTP.start(@host, @port) {|http|
        http.request(req)
      }
      if (res.error?)
        handle_error(req, res)
      end
      res
    end
    
    private
    
    def handle_error(req, res)
      e = RequestFailure.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
      e.code = res.code
      e.msg = res.message
      e.method = req.method
      e.path = req.path
      e.body = res.body
      raise e
    end
  end
  
  
end