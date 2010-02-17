require 'spec'
require 'spec/spec_helper'
require 'fastercsv'


describe TableFu do

  before :all do
    csv =<<-CSV
Project,Cost,Date,URL
Build Supercollider,500_000_000.50,09/15/2009,http://project.com
Harness Power of Fusion,25_000_000,09/16/2009,http://project2.com
Motorized Bar Stool,45.00,09/17/2009,http://project3.com
CSV
    
    matrix = FasterCSV.parse(csv)
    @spreadsheet = TableFu.new(matrix) do |s|
      s.formatting = {'Cost' => 'currency',
                      'Link' => {'method'=> 'link', 'arguments' => ['Project', 'URL']}}
      s.sorted_by = {'Project' => {'order' => 'descending'}}
      s.columns = ['Date', 'Project', 'Cost', 'Link']
    end 
    
  end

  it "should just work" do
    @spreadsheet.rows[0].column_for('Cost').to_s.should == '$45.00'
    @spreadsheet.rows[0].columns[1].to_s.should == 'Motorized Bar Stool'
    @spreadsheet.rows[0].column_for('Link').to_s.should == "<a href='http://project.com', title='Build Supercollider'>Build Supercollider</a>"
  end



end
