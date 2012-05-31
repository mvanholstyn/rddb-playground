require File.join(File.dirname(__FILE__), %w[.. config environment])

server = Couch::Server.new('localhost', '8888')
Couch::Db.create(server, 'mydb')
db = Couch::Db.new(server, 'mydb')


doc = Couch::Doc.new('my_doc_id')
doc.category = 'Person'
doc.name = 'Pete'
doc.dogs = ['TC', 'Ginger', 'Cori']
db.put(doc)


doc = db.get('my_doc_id')
doc.language = 'Ruby!'
doc.favorite_number = 33
db.put(doc)


doc = Couch::Doc.new('design_queries')
doc.table_people = "SELECT category == 'Person';Column Email; Column FullName"
db.put(doc)


table = db.table("design_queries:people")
table.each{|row| puts "Document #{row.id} has email #{row['Email']}"}


table = db.table("design_queries:people", {:key => 'pete@somedomain.foo'})
table.each{|row| puts "Document #{row.id} has email #{row['Email']}"}


table = db.table("design_queries:people", {:startkey => 'a', :endkey => 'zzzzzzz'})
table.each{|row| puts "Document #{row.id} has email #{row['Email']}"}
