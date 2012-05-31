require File.join(File.dirname(__FILE__), %w[.. config environment])

data = YAML.load(File.new(File.join(ROOT, %w[data rddb_demo.yml])))

db = Rddb::Database.new
data.each { |o| db << o }

db.create_view('all users') do |document, args|
  if document.doctype == "user"
    {
      :name => "#{document.first_name} #{document.last_name}",
      :email => document.email
    }
  end
end

db.create_view('all users with email addresses from domain') do |document, domain|
  if document.doctype == "user" && document.email =~ /\@#{domain}$/
    {
      :name => "#{document.first_name} #{document.last_name}",
      :email => document.email
    }
  end
end

db.create_view('user count') do |document, args|
  if document.doctype == 'user'
    document
  end
end.reduce_with do |results|
  results.length
end

db.create_view('all documents count') do |document, args|
  document
end.reduce_with do |results|
  results.length
end

db.create_view('names sorted by last name') do |document, args|
  document if document.doctype == "user"
end.reduce_with do |results|
  results.sort { |a,b| a.last_name <=> b.last_name }.collect { |document| "#{document.first_name} #{document.last_name}" }
end

db.create_view('names sorted by last name descending') do |document, args|
  document if document.doctype == "user"
end.reduce_with do |results|
  results.sort { |a,b| a.last_name <=> b.last_name }.collect { |document| "#{document.first_name} #{document.last_name}" }.reverse
end

db.create_view('user by name') do |document, name|
  document if document.name = name
end

[
  'all users', 
  'names sorted by last name',
  'names sorted by last name descending',
  'user count', 
  'all documents count'
].each do |name|
  puts "#{name}:"
  pp db.query(name)
  puts
end

puts 'all users with foobar.com email addresses: '
pp db.query('all users with email addresses from domain', 'foobar.com')
pp db.query('all users with email addresses from domain', 'gmail.com')
puts
