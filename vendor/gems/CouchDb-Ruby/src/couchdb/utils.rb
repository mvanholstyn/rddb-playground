

module CouchUtils

  def parse_val(field)
    vala = []
    field.each_element {|val|
      if (val.name == Couch::Str_Text)
        vala << val.text
      elsif (val.name == Couch::Str_Number)
        vala << val.text.to_f
      end
    }
    
    if (vala.size > 1)
      return vala
    else
      return vala[0]
    end
  end
  
end  