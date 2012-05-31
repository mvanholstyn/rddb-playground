require "couchdb"
require 'test/unit'

$testdb = 'testdoc'

class CouchTest < Test::Unit::TestCase
  
  def setup
    @server = Couch::Server.new('localhost', '8888')
    begin
      Couch::Db.delete(@server, $testdb)      
    rescue
    end
  end

  def test_db_lifecycle

    begin  
      puts "testing db lifecycle"
      list = Couch::Db.list_all(@server)     
      begin
        Couch::Db.create(@server, $testdb)      
        Couch::Db.create(@server, $testdb)
        assert(false, "This line should never be reached")
      rescue => e
        assert(e.code == "409", "Expected 409")
      end
      
      list2 = Couch::Db.list_all(@server)
      assert(list2.size == list.size + 1, "Db creation not accounted for: #{list2.size} != #{list.size + 1}")
      Couch::Db.delete(@server, $testdb)
      list2 = Couch::Db.list_all(@server)
      assert(list2.size == list.size, "Db deletion not accounted for")
    rescue => details
      puts details.to_s
      puts details.backtrace
      assert(false, 'Unexpected exception.')
    end
  end
  
  def test_doc_lifecycle

    begin  
      puts "testing doc lifecycle"
      Couch::Db.create(@server, $testdb)
      couch = Couch::Db.new(@server, $testdb)     
      
      h1 = {:A => 'AAA', :B => 'BBB', :C => 'CCC'}
      doc = Couch::Doc.create("ID_001", h1)
      couch.put(doc)
      doc = couch.get("ID_001")
      val = doc.A
      assert(doc.A == "AAA", "missing attribute A")
      assert(doc.B == "BBB", "missing attribute B")
      assert(doc.C == "CCC", "missing attribute C")
      
      h1 = {:AAA => ["AAA", "BBB", "CCC"], :XXX => 10000.01, :YYY => 1234567890, :ZZZ => ["ZZZ", -1, -222, "THE END OF THE LIST"] }
      doc = Couch::Doc.create("ID_002", h1)      
 
      couch.put(doc)
      doc = couch.get("ID_002")
      
      val = doc.AAA
      
      assert(val.class.name == "Array", "Expected AAA to contain an array")
      assert(val.size == 3, "Expected AAA to have three elements")
      assert(val[0] == "AAA" && val[1] == 'BBB' && val[2] == "CCC", "Expected different data in AAA")
      
      val = doc.XXX
      
      assert(val.class.name == "Float", "Expected XXX to be a Float instead of #{val.class.name}")
      
      val = doc.fields
      
      assert(val.class.name == "Array", "Expected array")
      assert(val.size == 4, "Expected 4 fields not #{val.size}")
      assert(val.include?(:AAA), "Should include AAA")
      assert(val.include?(:XXX), "Should include XXX")
      assert(val.include?(:YYY), "Should include YYY")
      assert(val.include?(:ZZZ), "Should include ZZZ")
      
      Couch::Db.delete(@server, $testdb)
    rescue => details
      puts details.to_s
      puts details.backtrace
      assert(false, 'Unexpected exception.')
    end
  end
  
  def test_doc_embedded_xml

    begin  
      puts "testing doc embedded xml"
      Couch::Db.create(@server, $testdb)
      couch = Couch::Db.new(@server, $testdb)     
      
      h1 = {:A => '<text>AAA</text>', :B => '<foo><text>BBB</text></foo>'}
      doc = Couch::Doc.create("XML_001", h1)
      couch.put(doc)
      doc = couch.get("XML_001")
      val = doc.A
      assert(doc.A == '<text>AAA</text>', "wrong attribute A #{doc.A}")
      assert(doc.B == '<foo><text>BBB</text></foo>', "wrong attribute B #{doc.B}")
      
      h1 = {:A => '<foo>AAA</foo></text>'}
      doc = Couch::Doc.create("XML_002", h1)
      couch.put(doc)
      #puts doc
      doc = couch.get("XML_002")
      #puts doc
      val = doc.A
      assert(doc.A == '<foo>AAA</foo></text>', "wrong attribute A #{doc.A}")
      
      
      Couch::Db.delete(@server, $testdb)
      
    rescue => details
      puts details.to_s
      puts details.backtrace
      assert(false, 'Unexpected exception.')
    end
  end
  
  
  def test_select

    begin  
      puts "testing select"
      Couch::Db.create(@server, $testdb)
      couch = Couch::Db.new(@server, $testdb) 
      

      #
      # Create 5 documents - 2 designs and 3 test documents
      #
      doc = Couch::Doc.create("design_all")
      doc.table_select = 'SELECT true;Column Name'
      couch.put(doc)
      
      doc = Couch::Doc.create("design_foo")
      doc.table_select = 'SELECT Type=="BOOK";Column Subject;Column Name'
      couch.put(doc)
      
      doc = Couch::Doc.create("t1")
      doc.type = "BOOK"
      doc.subject = "Football"
      doc.name = "Why we play"
      couch.put(doc)
      
      doc = Couch::Doc.create("t2")
      doc.type = "BOOK"
      doc.subject = "Baseball"
      doc.name = "Go Redsox"
      couch.put(doc)
      
      doc = Couch::Doc.create("t3")
      doc.type = "MOVIE"
      doc.subject = "War"
      doc.name = "Uncivil War"
      couch.put(doc)
      
      #
      # Test the CouchDb-Ruby built in table
      #
      tbl = couch.designs
      assert(tbl.size == 2, "There should be 2 designs")
      
      tbl = couch.table("design_all:select")
      assert(tbl.size == 6, "There should be 6 not #{tbl.size}")
      
      tbl = couch.table("design_foo:select")
      assert(tbl.size == 2, "There are should be two foo documents")
      #t2 = tbl["t2"]
      
      tbl = couch.table("design_foo:select", {:key => 'Football'})
      assert(tbl.size == 1, "There are should be one football document not #{tbl.size}")
      
      tbl = couch.table("design_foo:select", {:startkey => 'A', :endkey => 'E'})
      assert(tbl.size == 1, "There are should be 1 docs in this range not #{tbl.size}")
      
      tbl = couch.table("design_foo:select", {:startkey => 'A', :endkey => 'Z'})
      assert(tbl.size == 2, "There are should be 2 docs in this range not #{tbl.size}")

      tbl = couch.table("design_foo:select", {:startkey => 'A', :endkey => 'FZ'})
      assert(tbl.size == 2, "There are should be 2 docs in this range not #{tbl.size}")
      
      
      Couch::Db.delete(@server, $testdb)
      
    rescue => details
      puts details.to_s
      puts details.backtrace
      assert(false, 'Unexpected exception.')
    end
  end
end

#begin
#
#  tags = ["A", "B", "C"]
#  h = {:Name => "Pete Lyons", :Age => 44, :Address => "22 Wallace Rd", :City => "Groton", :Tags => tags}
#  
#  server = Couch::Server.new('localhost', '8888')
#  couch = Couch::Db.new(server, 'foo')
#  
#  puts Couch::Db.list_all(server)
#  
#  begin
#    meta = couch.get_meta
#  rescue => details
#    puts details.to_s
#  end
#  
#  
#  doc = couch.get("some_tables")
#  puts doc.to_s
#  doc.table_all = "SELECT true; Column Subject; Column Revision"
#  couch.put(doc)
#  puts couch.get_raw("some_tables:all")
#  
#rescue Exception => e
#  puts e
#  puts e.backtrace.join("\n")
#end
#

#couch.put("some_tables3", h)
#puts couch.get_raw("$all_docs")


