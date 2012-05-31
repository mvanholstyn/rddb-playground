require 'net/http'
require 'rexml/document'
require 'couchdb/net_ext'


module Couch

  #
  # Wrapper for working with CouchDb's table data
  # 
  # Couch tables are stored queries of Couch's document space.
  # A table definition contains a selection filter and one or more columns.
  # The first column is a Key column and can be used to limit the query
  # This object represents the result of connecting to a defined
  # Couch table and asking for its contents.
  # 
  #
  class Table
    include Enumerable
    include CouchUtils
   
   
    def initialize(name, input)
      @name = name
      if input == nil
        @array = []
      elsif input.kind_of? REXML::Document
        @array = parse_table(input)
      elsif input.kind_of? Array
        @array = input
      else
        raise TypeError.new(input.class.name)
      end
    end
    
    def to_s
      @array.to_s
    end
    
    # Return the number of Couch::Row's in the table
    def size
      @array.size
    end
    
    # Fetch a specific Couch::Row by index
    def [](ndx)
      @array[ndx]
    end
 
    def each(&block)
      @array.each block
    end
    
    private
    
    def parse_tr(rowxml)
      row = Couch::Row.new
      row.id = rowxml.attribute(:id).to_s
      rowxml.elements.each(){|td|
        id = td.attribute(:id).to_s
        val = parse_val(td)
        row[id] = val
      }
      row
    end
    
    def parse_table(doc)
      array = []
      @id = doc.root.attribute(:id).to_s
      doc.elements.each("#{Str_Table}/#{Str_Tr}"){|tr|
        val = parse_tr(tr)
        #puts "Setting #{field_name} to '#{val}' (type of #{val.class.name})" 
        array << val
      }
      array
    end
  
  end

end

