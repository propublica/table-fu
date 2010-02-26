require 'rubygems'
require 'fastercsv'

# Adds spreadsheet functionality to an Array
class TableFu
  
  attr_reader :deleted_rows, :table, :totals, :column_headers
  attr_accessor :faceted_on, :col_opts
  
  # Should be initialized with a matrix array or a string containing a csv, and expects the first
  # array in the matrix to be column headers.
  def initialize(table, column_opts = {})
    # Assume if we're past a string or filehandle we need to parse a csv
    if table.is_a?(String) || table.is_a?(File)
      table = FasterCSV.parse(table)
    end
    @column_headers = table.slice!(0)
    @totals = {}
    @table = table
    @col_opts = column_opts
    yield self if block_given?
  end


  
  # Pass it an array and it will delete it from the table, but save the data in
  # @deleted_rows@ for later perusal.
  # 
  # Returns: 
  # nothing
  def delete_rows!(arr)
    @deleted_rows ||= []
    arr.map do |a|
      @deleted_rows << @table[a] #account for header and 0 index
      @table[a] = nil
    end
    @table.compact!
  end
  
  
  # Inverse slice: Only keep the rows in the range after sorting
  def only!(range)
    rows_to_exclude = rows.map do |row|
      range.include?(row.row_num) ? nil : row.row_num
    end
    delete_rows!(rows_to_exclude.compact)
  end

  # Returns a Row object for the row at a certain index
  def row_at(row_num)
    TableFu::Row.new(@table[row_num], row_num, self)
  end
  
  # Returns all the Row objects for this object as a collection
  def rows
    all_rows = []
    @table.each_with_index do |r, i|
      all_rows << TableFu::Row.new(r, i, self)
    end    
    all_rows.sort
  end
  
  # Return the headers defined in column headers or cherry picked from @col_opts
  def columns
    @col_opts[:columns] || column_headers
  end
  
  # Return the headers of the array 
  def headers
    all_columns = []
    columns.each do |h|
      all_columns << TableFu::Header.new(h, h, nil, self)
    end
    all_columns
  end
  
  # Sum the values of a particular column
  def sum_totals_for(column)
    @totals[column.to_s] = rows.inject(0) { |sum, r| to_numeric(r.datum_for(column).value) + sum }
  end
  
  # Sum the values of a particular column and return a Datum
  def total_for(column)
    sum_totals_for(column)
    Datum.new(@totals[column.to_s], column, nil, self)
  end
  
  # Return an array of TableFu instances grouped by a column.
  def faceted_by(column, opts = {})
    faceted_spreadsheets = {}
    rows.each do |r|
      unless r.column_for(column).value.nil?
        faceted_spreadsheets[r.column_for(column).value] ||= []
        faceted_spreadsheets[r.column_for(column).value] << r
      end
    end
    
    # Create new table_fu instances for each facet
    tables = []
    faceted_spreadsheets.each do |k,v|
      new_table = [@column_headers] + v
      t = TableFu.new(new_table)
      t.faceted_on = k
      t.col_opts = @col_opts #formatting should be carried through
      tables << t
    end
    
    tables.sort! do |a,b|
      a.faceted_on <=> b.faceted_on
    end
    
    if opts[:total]
      opts[:total].each do |c|
        tables.each do |f|
          f.sum_totals_for(c)
        end
      end
    end
      
    tables
  end
  
  # Return a numeric instance for a string number, or if it's a string we
  # return 1, this way if we total up a series of strings it's a count
  def to_numeric(num)
    if num.nil?
      0
    elsif num.kind_of? Integer
      num
    else
      1 # We count each instance of a string this way
    end
  end
  
  # Return true if this table is faceted
  def faceted?
    not faceted_on.nil?
  end
  
  # Return the sorted_by column
  def sorted_by
    @col_opts[:sorted_by]
  end
  
  # Set the sorted_by column
  def sorted_by=(h)
    @col_opts[:sorted_by] = h
  end
  
  # Return the formatting hash
  def formatting
    @col_opts[:formatting]
  end
  
  # Set the formatting hash
  def formatting=(h)
    @col_opts[:formatting] = h
  end
  
  # Set up the cherry picked columns
  def columns=(a)
    @col_opts[:columns] = a
  end
  

  
end

class TableFu
  class Row < Array
    
    attr_reader :row_num
    
    def initialize(row, row_num, spreadsheet)
      self.replace row
      @row_num = row_num
      @spreadsheet = spreadsheet
    end
    
    def columns
      all_cols = []
      @spreadsheet.columns.each do |c|
        all_cols << datum_for(c)    
      end         
      all_cols
    end
    
    # This returns a Datum object for a header name. Will return a nil Datum object
    # for nonexistant column names
    # 
    # Parameters:
    # header name
    # 
    # Returns:
    # Datum object
    # 
    def datum_for(col_name)
      if col_num = @spreadsheet.column_headers.index(col_name)
        TableFu::Datum.new(self[col_num], col_name, @row_num, @spreadsheet)
      else # Return a nil Datum object for non existant column names
        TableFu::Datum.new(nil, col_name, @row_num, @spreadsheet)
      end
    end
    alias_method :column_for, :datum_for
    
    # Comparator for sorting a spreadsheet row.
    #
    def <=>(b)
      if @spreadsheet.sorted_by
        column = @spreadsheet.sorted_by.keys.first
        order = @spreadsheet.sorted_by[@spreadsheet.sorted_by.keys.first]["order"]
        format = @spreadsheet.sorted_by[@spreadsheet.sorted_by.keys.first]["format"]
        a = column_for(column).value || ''
        b = b.column_for(column).value || ''
        if format 
          a = TableFu::Formatting.send(format, a) || ''
          b = TableFu::Formatting.send(format, b) || ''
        end
        result = a <=> b
        result = -1 if result.nil?
        result = result * -1 if order == 'descending'
        result
      else
        -1
      end
    end
    
  end
  
  class Datum

    attr_reader :options, :column_name
    
    # Each piece of datum should know where it is by column and row number, along
    # with the spreadsheet it's apart of. There's probably a better way to go
    # about doing this. Subclass?
    def initialize(datum, col_name, row_num, spreadsheet)
      @datum = datum
      @column_name = col_name
      @row_num = row_num
      @spreadsheet = spreadsheet
    end
    
    # Our standard formatter for the datum
    #
    # Returns:
    # the formatted value, macro value, or a empty string
    #
    # First we test to see if this Datum has a macro attached to it. If so
    # we let the macro method do it's magic
    # 
    # Then we test for a simple formatter method.
    #
    # And finally we return a empty string object or the value.
    #
    def to_s
      if macro_value
        macro_value
      elsif @spreadsheet.formatting && format_method = @spreadsheet.formatting[column_name]
        TableFu::Formatting.send(format_method, @datum) || ''
      else
        @datum || ''
      end
    end
    
    # Returns the macro'd format if there is one 
    #
    # Returns:
    # The macro value if it exists, otherwise nil
    def macro_value
      # Grab the macro method first
      # Then get a array of the values in the columns listed as arguments
      # Splat the arguments to the macro method.
      # Example:
      #   @spreadsheet.col_opts[:formatting] = 
      #    {'Total Appropriation' => :currency,
      #     'AppendedColumn' => {'method' => 'append', 'arguments' => ['Projects','State']}}
      # 
      # in the above case we handle the AppendedColumn in this method
      if @row_num && @spreadsheet.formatting && @spreadsheet.formatting[@column_name].is_a?(Hash)
        method = @spreadsheet.formatting[@column_name]['method']
        arguments =  @spreadsheet.formatting[@column_name]['arguments'].inject([]){|arr,arg| arr << @spreadsheet.rows[@row_num].column_for(arg); arr}
        TableFu::Formatting.send(method, *arguments)
      end
    end
    
    # Returns the raw value of a datum 
    #
    # Returns:
    # raw value of the datum, could be nil  
    def value
      if @datum =~ /[0-9]+/
        @datum.to_i
      else
        @datum
      end
    end

    # This method missing looks for 4 matches
    #
    # First Option
    # We have a column option by that method name and it applies to this column
    # Example - 
    #   >> @data.column_name
    #   => 'Total'
    #   >> @datum.style
    # Finds col_opt[:style] = {'Total' => 'text-align:left;'}
    #   => 'text-align:left;'
    # 
    # Second Option
    # We have a column option by that method name, but no attribute
    #   >> @data.column_name
    #   => 'Total'
    #   >> @datum.style 
    #   Finds col_opt[:style] = {'State' => 'text-align:left;'}
    #   => ''
    # 
    # Third Option
    # The boolean
    #   >> @data.invisible?
    # And we've set it col_opts[:invisible] = ['Total']
    #   => true
    #
    # Fourth Option
    # The boolean that's false
    #   >> @data.invisible?
    # And it's not in the list col_opts[:invisible] = ['State']
    #   => false
    #
    def method_missing(method)
      opts = indifferent_access @spreadsheet.col_opts
      if val = opts[method] && opts[method][column_name]
        val
      elsif val = opts[method] && !opts[method][column_name]
        ''
      elsif method.to_s =~ /\?$/ && col_opts = opts[method.to_s.chop.to_sym]
        col_opts.index(column_name) || false
      elsif method.to_s =~ /\?$/ && !opts[method.to_s.chop.to_sym]
        nil
      else
        super
      end
    end
    
    private

    # Enable string or symbol key access to col_opts
    # from sinatra
    def indifferent_access(params)
      params = indifferent_hash.merge(params)
      params.each do |key, value|
        next unless value.is_a?(Hash)
        params[key] = indifferent_access(value)
      end
    end

    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end
  end
  
  class Header < Datum
    
    # A header object needs to be a special kind of Datum, and
    # we may want to extend this further, but currently we just
    # need to ensure that when to_s is called on a @Header@ object
    # that we don't run it through a macro, or a formatter.
    #
    def to_s
      @datum
    end
    
  end
  
end

$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'table_fu/formatting'