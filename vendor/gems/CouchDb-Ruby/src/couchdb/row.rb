require 'net/http'
require 'rexml/document'
require 'couchdb/net_ext'

module Couch
  
  #
  # This class represents a row of data returned by a Table query
  #
  # The Row is a Hash of column values selected from a CouchDb document.  The values
  # generally are a subset of those of the complete Couch::Doc.
  # A Row will only have values from a single Couch::Doc
  #
  class Row < Hash
    
    #
    # The Couch::Doc ID represented by this Row
    #
    def id
      @id
    end
    
    def id=(v)
      @id = v
    end
  
  
    def to_s
      v = "#{@id}:\n"
      each_pair {|key, value| v << "   #{key} = #{value}\n" }
      v
    end
  
  end
  
end
