# Override this class to add more formatting methods
# 
# Methods expect one or more arguments, which could be nil, and should return the appropriate
# formatting and style.
class TableFu::Formatting

  class << self
    
    # Returns a currency formatted number
    def currency(num)
      begin
        parts = num.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
        "$#{parts.join('.')}"
      rescue
        num
      end
    end
    
    # Returns the last name of a name 
    # => last_name("Jeff Larson")
    # >> Larson
    def last_name(name)
      name.strip!
      if name.match(/\s(\w+)$/)
        $1
      else
        name
      end
    end
    # Returns that last name first of a name
    # => last_name_first_name("Jeff Larson")
    # >> Larson, Jeff
    def last_name_first_name(name)
      last = last_name(name)
      first = name.gsub(last, '').strip    
      "#{last}, #{first}"
    end
    
    # Returns an html link constructed from link, linkname
    def link(linkname, href)
      "<a href='#{href}' title='#{linkname}'>#{linkname}</a>"
    end
    
    # Returns an error message if the given formatter isn't available
    def method_missing(method)
      "#{method.to_s} not a valid formatter!"
    end
    
  end
  
end