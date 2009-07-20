require 'net/http'
require 'fastercsv'

class String
  def numeric?
    self == self.to_i.to_s
  end
end

class YavinController < ApplicationController

  caches_page :view

  def view
    table = load_table
    if table
  
##REQUIRED PARAMETERS
  
      #init the easy stuff, sortable is true by default, disabled by options
      @title  = table['title']
      @deck   = table['deck']
      @footer = table['footer']
      @sortable = true

      
      #fetch the data
      url = table['url']
      csv_data = Net::HTTP.get_response(URI.parse(url)).body
      @data = FasterCSV.parse(csv_data)
      @headers = @data.slice!(0)
      
##OPTIONAL PARAMETERS

      #set up column styles
      @column_styles = table['column_styles']
      
      #set up formats
      @column_number_styles = table['column_number_styles'] ? Hash[*table['column_number_styles'].flatten] : {}
      
      #clean out dead rows and cols
      #there is probably a more ruby-rific way to do this
      dead_columns = table['dead_columns']
      if dead_columns
        for row in @data
          dead_count = 0
          for col in dead_columns
            row.slice!(col - dead_count)
            dead_count += 1
          end
        end
        dead_count = 0
        for col in dead_columns
          @headers.slice!(col - dead_count)
          dead_count += 1
        end
      end
      dead_rows = table['dead_rows']
      if dead_rows
        dead_count = 0
        for row in dead_rows
          @data.slice!(row - dead_count)
          dead_count += 1
        end
      end
      
      #set up sorting
      sort_by = table['sort_by']
      if sort_by
        @sort_by_index = @headers.index(sort_by)
      end
      sort_order = table['sort_order']
      if sort_order
        @sort_order_bit = sort_order == 'ascending' ? 0 : 1
      end
      
      #set up paging
      #will disable sorting, and doesnt work w/ faceting
      @per_page = table['per_page']
      if @per_page
        @sortable = false
        @data = @data.paginate(:page => params[:page], :per_page => @per_page)
      end
      
      #set up faceting
      #will disable sorting, and doesn't work w/ paging'
      facet_column = table['facet_column']
      if facet_column
        @facet_subtotal_columns = table['facet_subtotal_columns'] || []
        @sortable = false
        @facets = {}
        @facet_totals = {}
        
        facet_index = @headers.index(facet_column)
        @headers.slice!(facet_index)
        for row in @data
            facet = row[facet_index]
            if facet
              row.slice!(facet_index)
              if @facets[facet]
                @facets[facet] << row
              else
                @facets[facet] = [row]
              end
              for i in 0..row.length - 1
                if !@facet_totals[facet]
                  @facet_totals[facet] = []
                end
                if !@facet_totals[facet][i]
                  @facet_totals[facet][i] = 0
                end
                if row[i]
                  @facet_totals[facet][i] += row[i].numeric? ? row[i].to_i : 1
                end
              end
            end
        end
        @facets = @facets.sort
      end
      
      #set up a fixed last row (like a total)
      @fix_last_row = table['fix_last_row']
      
    end
  end
  
  def expire
    table = load_table
    if table
      slug = table['slug']
      cache_dir = ActionController::Base.page_cache_directory
      FileUtils.rm_r(Dir.glob(cache_dir + "/#{slug}.html")) rescue Errno::ENOENT
      FileUtils.rm_r(Dir.glob(cache_dir + "/#{slug}")) rescue Errno::ENOENT
    end
    redirect_to :action => 'view'
  end
  
  def load_table
    slug = params[:slug]
    begin
      config = YAML.load_file("config/tables/#{slug}.yaml")
      table = config['table']
      table['slug'] = slug
    rescue ArgumentError
      RAILS_DEFAULT_LOGGER.error("Error parsing configuration file.")
      render "#{RAILS_ROOT}/public/500.html", :status => 500 and return  
    rescue Errno::ENOENT
      render "#{RAILS_ROOT}/public/404.html", :status => 404 and return
    end
    table
  end
  
end
