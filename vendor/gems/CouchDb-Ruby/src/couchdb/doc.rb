require 'net/http'
require 'rexml/document'

#include REXML

module Couch
  
  #
  # The Doc class represent a document in the Couch database.
  # 
  # A Doc may be read from or written to the database or created in memory and written
  # to the database.  The Doc class supports dynamic attributes. You may add 
  # attributes on the fly as your applications requires. Attributes added
  # will be stored in CouchDb fields of the same name.  For example the following code
  # will create an in memory schemaless document with the id 'SomeId'
  # and then add three fields to called: name, project and junk.
  # Finally the doc is written to the database.
  # 
  #   doc = Couch::Doc.create('SomeId')
  #   doc.name = 'pete'
  #   doc.project = 'couchdb-ruby'
  #   doc.junk = 'this is just junk'
  #   db.put(doc)
  # 
  #
  class Doc
    include Enumerable
    include CouchUtils
   
    def Doc.create(id, hash = nil)
      doc = Doc.new(hash)
      doc.id = id
      return doc
    end
    
    def initialize(input = nil)
      if input == nil
        @hash = {}
      elsif input.kind_of? REXML::Document
        @hash = parse_doc(input)
      elsif input.kind_of? Hash
        @hash = input
      else
        raise TypeError.new(input.class.name)
      end
    end
    
    # Get the revision number of this document. 
    def revision
      @revision
    end
    
    # Set the revision number of this document. Most
    # application would have no reason to set this and 
    # infact will probably cause problems if they do.
    def revision=(v)
      @revision = v
    end
    
    #
    # Get the document id
    #
    def id
      @id
    end
    
    #
    # Set the document id
    #
    def id=(v)
      @id = v
    end
    
    #
    # Get an array of fields currently in this document
    #
    def fields
      @hash.keys
    end
    
    def to_s
      hash2docxml().to_s
    end
    
    def each(&block)
      @hash.each block
    end
    
    
    private
    
    def val2xml(val)
      if val.kind_of? Array
        throw "Not supported"
      elsif val.kind_of? String
        e = REXML::Element.new(Str_Text)  
        e.text = val;
        e
      elsif val.kind_of? Float or val.kind_of? Integer
        e = REXML::Element.new(Str_Number)  
        e.text = val.to_s;   
        e
      end
    end
    
    def hash2docxml()
      doc = REXML::Element.new(Str_Doc)
      doc.add_attribute(Str_Previous_Rev, @revision)
      doc.add_attribute(Str_Id, @id)
      
      @hash.each_pair {|key, val| 
        field = REXML::Element.new(Str_Field)
        field.add_attribute(Str_Id, key)
        doc << field
        if val.kind_of? Array
          val.each() {|v|
            field << val2xml(v)
          }  
        elsif val.kind_of? String or val.kind_of? Float or val.kind_of? Integer
          field << val2xml(val)
        else
          raise TypeError.new(val.class.name)
        end
      }
      doc
    end
    
    def method_missing(sym, *args)
      meth = sym.id2name
      meth = meth.gsub(/^table_/, '$table_')  
      if /=$/ =~ meth
        sym = meth[0...-1].to_sym
        @hash[sym] = (args.length < 2 ? args[0] : args)
      else
        sym = meth.to_sym
        val = @hash[sym]
        return val
      end
    end
    

    
    def parse_doc(doc)
      hash = {}
      @id = doc.root.attribute(:id).to_s
      @revision = doc.root.attribute(:rev).to_s
      doc.elements.each("#{Str_Doc}/#{Str_Field}"){|field|
        field_name = field.attribute(:id).to_s
        val = parse_val(field)
        #puts "Setting #{field_name} to '#{val}' (type of #{val.class.name})" 
        hash[field_name.to_sym] = val
      }
      hash
    end
      
  end
  
end