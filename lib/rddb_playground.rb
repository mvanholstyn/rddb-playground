require File.join(File.dirname(__FILE__), %w[.. config environment])

module ActiveRddb
  class Base
    @@database = Rddb::Database.new
    
    def initialize(attributes = {})
      @document = Rddb::Document.new attributes.merge(:clazz => self.class.name)
    end
    
    def inspect
      "#{self.class.name}: #{@document.instance_variable_get('@data').inspect}"
    end
    
    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ /=$/
        @document[method_name.to_s.gsub(/=$/, '')] = args.first
      else
        @document.send(method_name, *args, &block)
      end
    end
    
    def save
      @@database << @document
    end
    
    def update_attributes(attributes)
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
      save
    end
    
    def self.create(attributes = {})
      record = new(attributes)
      record.save
      record
    end
    
    def self.from_document(document)
      record = new
      record.instance_variable_set("@document", document)
      record
    end
        
    def self.view(name, &block) 
      @@database.create_view(name, &block)
    end
        
    def self.find(how_many, options = {})
      query_name = build_query_name(options)
      build_query(query_name, options)
      @@database.query(query_name).map do |document|
        from_document(document)
      end
    end
    
    def self.build_query_name(options = {})
      query_name = "#{name}"
      if options.any?
        query_name << ": {"
        query_name << options.map do |key, value|
          ":#{key} => #{value.inspect}"
        end.join(", ")
        query_name << "}"
      end
      query_name
    end
      
    def self.build_query(query_name, options = {})
      if view = @@database.views[query_name]
        return view
      end

      puts "Building... #{query_name}"

      view = view(query_name) do |record, args|
        conditions = options[:conditions] ||= {}
        conditions[:clazz] = name

        result = record
        conditions.each do |attribute, value|
          if value.is_a?(String)
            if record.send(attribute) != value
              result = nil
              break
            end
          elsif value.is_a?(Regexp)
            if record.send(attribute) !~ value
              result = nil
              break
            end
          elsif value.is_a?(Range) or value.is_a?(Array)
            if not value.include?(record.send(attribute))
              result = nil
              break
            end
          end
        end
        result
      end

      if order = options[:order]
        view.reduce_with do |records|
          records.sort_by do |record|
            order.to_s.split(/\s*,\s*/).map do |attribute|
              record.send(attribute)
            end
          end
        end
      end

      view
    end
  end
end

class User < ActiveRddb::Base
end

class Group < ActiveRddb::Base
end

liz = User.create :first_name => "liz", :last_name => "van", :age => 22
mark = User.create :first_name => "mark", :last_name => "van", :age => 23
mark.update_attributes :spouse => liz
liz.update_attributes :first_name => "Lizzy"#:spouse => mark
# User.create :first_name => "joanne", :last_name => "van", :age => 47
# User.create :first_name => "john", :last_name => "hwang", :age => 28
# User.create :first_name => "craig", :last_name => "demyan", :age => 35
# User.create :first_name => "zach", :last_name => "dennis", :age => 25

pp User.find(:all)
pp User.find(:all, :order => :last_name)
pp User.find(:all, :order => "last_name, first_name")
pp User.find(:all, :conditions => { :last_name => "van" })
pp User.find(:all, :conditions => { :last_name => /^van/ })
pp User.find(:all, :conditions => { :last_name => /an/ })
pp User.find(:all, :conditions => { :age => (20..30) })
pp User.find(:all, :conditions => { :age => [22, 23] })
pp Group.find(:all)
