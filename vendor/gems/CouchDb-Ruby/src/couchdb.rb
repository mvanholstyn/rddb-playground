#
# = CouchDb-Ruby: A Ruby front end for CouchDb
# This package contains code for accessing and working with {CouchDb}[http://www.couchdbwiki.com/index.php?title=Main_Page];
# an open source, schemaless document database.
# 
# == Overview
# The basic operations you need to know to work
# with CouchDb are as follows
# 
# ====1. Connect to a CouchDb server
#   server = Couch::Server.new('localhost', '8888')
#   
# ====2. Create a database
#   Couch::Db.create(server, 'mydb');
#   
# ====3. Open a database
#   db = Couch::Db.new(server, 'mydb')
#   
# ====4. Create a document
#   doc = Couch::Doc.new('my_doc_id')
#   doc.category = 'Person'
#   doc.name = 'Pete'
#   doc.dogs = ['TC', 'Ginger', 'Cori']
#   db.put(doc)
#   
# ====5. Read and update a document
#   doc = db.get('my_doc_id')
#   doc.language = 'Ruby!'
#   doc.favorite_number = 33
#   db.put(doc)
#   
# ====6. Create a Table for querying documents
#   doc = Couch::Doc.new('design_queries') 
#   doc.table_people = 'SELECT category == "Person';Column Category; Column Name")
#   db.put(doc)
#   
# ====7. Fetch a Table
#   table = db.table("design_queries:people")
#   table.each{|row| puts "Document #{row.id} has name #{row['Name']}"}  
#
# == Credit
# This code is a product of the {CouchDB-Ruby}[http://rubyforge.org/projects/couchdb/] project from Rubyforge.
#

require 'couchdb/error'
require 'couchdb/const'
require 'couchdb/utils'
require 'couchdb/server'
require 'couchdb/doc'
require 'couchdb/db'
require 'couchdb/row'
require 'couchdb/table'




