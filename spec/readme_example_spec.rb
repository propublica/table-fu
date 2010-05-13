require 'spec'
require 'spec/spec_helper'
require 'fastercsv'


describe TableFu do

  before :all do
    @csv = <<-CSV
Project,Cost,Date,URL
Build Supercollider,500_000_000.50,09/15/2009,http://project.com
Harness Power of Fusion,25_000_000,09/16/2009,http://project2.com
Motorized Bar Stool,45.00,09/17/2009,http://project3.com
CSV

    @spreadsheet = TableFu.new(@csv) do |s|
      s.formatting = {'Cost' => 'currency'}
      s.sorted_by = {'Project' => {'order' => 'descending'}}
      s.columns = ['Date', 'Project', 'Cost']
    end 
    
  end

  it "should just work" do
    @spreadsheet.rows[0].column_for('Cost').to_s.should == '$45.00'
    @spreadsheet.rows[0].columns[1].to_s.should == 'Motorized Bar Stool'
  end
  
  it 'should open a file if passed one' do
    @spreadsheet = TableFu.new(File.open('spec/assets/test.csv')).rows[0].column_for('State').to_s.should eql "Alabama"
  end
  
  it "should populate headers if we don't tell it which headers to use" do
    TableFu.new(@csv).headers.should_not be_nil
  end

end
