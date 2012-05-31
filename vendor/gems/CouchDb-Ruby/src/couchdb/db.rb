require 'net/http'
require 'rexml/document'
require 'couchdb/net_ext'

module Couch

  #
  # The Db class represents a database on a CouchDb server
  # 
  # Use an instance of Db class to read and write Couch::Doc objects or to
  # fetch a Couch::Table collection of document summary data from a particular
  # database.
  # 
  # Use the class methods of Db to create and delete databases.
  #
  #
  class Db
    
    public
    
    #
    # List all the databases on the server
    #
    def Db.list_all(server)
      res =  server.get("/#{Str_All_Dbs}")
      xmldoc = REXML::Document.new(res.body)
      list = []
      xmldoc.elements.each("#{Str_Dbs}/#{Str_Db}"){|db|
        list << db.text
      }  
      list
    end
    
    #
    # Create a database on the server
    #
    def Db.create(server, name)
      server.put(fix_name(name), "")
      
      db = Db.new(server, name)
      doc = Couch::Doc.create("meta_tables")
      doc.table_designs = 'SELECT $docid > "design_" && $docid < "design_zzzzz"'
      db.put(doc)
    end
    
    #
    # Delete a database from the server
    #
    def Db.delete(server, name)
      server.delete(fix_name(name))
    end
    
    private
    
    def Db.fix_name(name)
      if ( not /^\/.*/ =~ name)
        name = '/' << name
      end
      
      if (not /.*\/$/ =~ name)
        name = name << '/'
      end
      
      name
    end
    
    def initialize(server, db, options = nil)
      @db = db
      @server = server
    end     
    
    public   
         
    #
    # Get the name of the database   
    #    
    def name
      @db.dup
    end
    
    #
    # Get a table of documents that follow the design_
    # prefix convention
    #
    def designs
      req = "/#{@db}/meta_tables:designs"
      res = @server.get(req)
      xmldoc = REXML::Document.new(res.body) 
      Table.new("meta_tables:designs", xmldoc)
    end
    
    #
    # Store the document in the database
    #
    def put(doc)
      res = @server.put("/#{@db}/#{doc.id}", doc.to_s)
      xmldoc = REXML::Document.new(res.body)
      
      xmldoc.elements.each("#{Str_Success}/#{Str_Update_Info}"){|info|
        doc.revision = info.attribute(:revid).to_s
      }  
      nil
    end
    
    #
    # Get a document with the specific ID
    #
    def get(id)
      res = @server.get("/#{@db}/#{id}")
      xmldoc = REXML::Document.new(res.body)      
      Doc.new(xmldoc);
    end
    
    #
    # Delete the document
    #
    def delete(id)
      @server.delete("/#{@db}/#{id}")
      nil
    end
    
    #
    # Get an entire table.  Name must be in the format "design_doc_id:table_name"
    #
    # options is a hash with any of the following values
    # 
    # key: one or more keys to return
    # startkey: the start key to return
    # endkey: the end key to return
    # count: the max number of rows
    #
    def table(name, options = nil)
    
      req = "/#{@db}/#{name}"
      opt = format_table_options(options)
      if opt.size > 0
        req << "?#{opt}"
      end
      res = @server.get(req)
      xmldoc = REXML::Document.new(res.body) 
      Table.new(name, xmldoc)
    end
    
    private 
    
  
    def format_table_options(options)
    
      ret = ""
      if options == nil
        return ret
      end
      
      options.each_pair {|key, val| 
        if key != nil and val != nil
          if ret.size > 0
            ret << '&'
          end
          if val.kind_of? Array
            v = ""
            val.each{|v2|
              if v.size > 0
                v << '&'
              end
              v << "#{key.to_s}=#{v2.to_s}"
            }
          else
            v = "#{key.to_s}=#{val.to_s}"
          end
          ret << v
        end
      }
      ret
    end
        
  end
end