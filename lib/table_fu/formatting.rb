class TableFu::Formatting

# Override this class to add more formatting methods
# 
# Methods expect one or more arguments, which could be nil, and should return the appropriate
# formatting and style.
# a method that

  class<<self
    
    def currency(num)
      "$#{num.to_s}"
    end
    
    def last_name(name)
      name.strip!
      if name.match(/\s(\w+)$/)
        $1
      else
        name
      end
    end
    
    def link(linkname, link)
      "<a href='#{link}', title='#{linkname}'>#{linkname}</a>"
    end
    
    def method_missing(method)
      "#{method.to_s} not a valid formatter!"
    end
    
  end
  
end