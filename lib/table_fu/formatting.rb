class TableFu::Formatting

# Override this class to add more formatting methods
# 
# Methods expect one or more arguments, which could be nil, and should return the appropriate
# formatting and style.
# a method that

  class<<self
    # Returns a currency formatted number
    def currency(num)
      "$#{num.to_s}"
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
    
    # Returns an html link constructed from link, linkname
    def link(linkname, link)
      "<a href='#{link}' title='#{linkname}'>#{linkname}</a>"
    end
    
    # Returns an error message if the given formatter isn't available
    def method_missing(method)
      "#{method.to_s} not a valid formatter!"
    end
    
  end
  
end