require 'spec'
require 'spec/spec_helper'
require 'fastercsv'


describe TableFu do

  before :all do
    csv = FasterCSV.parse(File.open('spec/assets/test.csv'))
    @spreadsheet = TableFu.new(csv, :style => {'URL' => 'text-align: left;'})
  end

  it 'should give me back a Row object' do
    @spreadsheet.rows.each do |r|
      r.class.should eql TableFu::Row
    end
  end

  it 'should give me back a column by it\'s header name' do
    @spreadsheet.rows[0].column_for("State").to_s.should == "Alabama"
  end
  
  it 'should sort rows' do
    @spreadsheet.sorted_by = {'State' => {"order" => 'descending'}}
    @spreadsheet.rows[0].column_for("State").to_s.should eql "Wyoming"
    @spreadsheet.sorted_by = {'Party' => {"order" => 'descending'}}
    @spreadsheet.rows[0].column_for("Party").to_s.should eql "Republican"
    @spreadsheet.sorted_by = {'Representative' => {"order" => 'ascending', "format" => 'last_name'}}
    @spreadsheet.rows[2].column_for("Representative").to_s.should eql "Jo Bonner"
    @spreadsheet.col_opts[:columns] = {'State', 'Party', 'Total Appropriations', 'URL'}
    @spreadsheet.rows.each do |row|
      row.columns.each do |column|
        if column.column_name == 'URL'
          column.style.should eql 'text-align: left;'
          column.to_s.should eql ''
          column.value.should be_nil
        end
        column.style.should_not be_nil
      end
    end
  end

end

describe TableFu, 'with a complicated setup' do

  before :all do
    csv = FasterCSV.parse(File.open('spec/assets/test.csv'))
    @spreadsheet = TableFu.new(csv)
    @spreadsheet.col_opts[:formatting] = {'Total Appropriation' => :currency}
    @spreadsheet.col_opts[:style] = {'Leadership' => "text-align: left;", 'URL' => 'text-align: right;'}
    @spreadsheet.col_opts[:foo] = ['Leadership', 'URL']
    @spreadsheet.delete_rows! [8]
    @spreadsheet.sorted_by = {'State' => {"order" => 'descending'}}
    @spreadsheet.col_opts[:columns] = ['State', 'Leadership', 'Total Appropriation', 'Party', 'URL']
  end

  it 'Leadership column should be marked invisible' do
    @spreadsheet.rows[0].column_for('URL').foo?.should be_true
    @spreadsheet.rows[0].column_for('State').foo?.should be_false
  end

  it 'should give me back a Row object' do
    @spreadsheet.rows.each do |r|
      r.class.should eql TableFu::Row
    end
  end

  it 'should give me back a 7 rows because it ignored row 476 and header' do
    @spreadsheet.rows.size.should eql 7
  end

  it 'should give me back a column by it\'s header name' do
    @spreadsheet.rows[3].column_for('State').to_s.should eql "Georgia"
    @spreadsheet.rows[2].column_for('State').to_s.should eql "New Jersey"
    @spreadsheet.rows[0].column_for('State').to_s.should eql "Wyoming"
  end

  it 'should format a column' do
    @spreadsheet.rows[0].column_for("Total Appropriation").to_s.should eql "$138526141"
    @spreadsheet.rows[0].column_for("Total Appropriation").value.should eql "138526141"
  end
  
  it 'should format a header' do
    @spreadsheet.headers[1].style.should eql 'text-align: left;'
    @spreadsheet.headers[4].style.should eql 'text-align: right;'
  end

end


describe TableFu, "with faceting" do

  before :all do
    csv = FasterCSV.parse(File.open('spec/assets/test.csv'))
    @spreadsheet = TableFu.new(csv)
    @spreadsheet.col_opts[:style] = {'Projects' => 'text-align:left;'}
    @spreadsheet.col_opts[:formatting] = {'Total Appropriation' => :currency}
    @spreadsheet.delete_rows! [8]
    @spreadsheet.sorted_by = {'State' => {:order => 'ascending'}}
    @faceted_spreadsheets = @spreadsheet.faceted_by("Party", :total => ['Projects', 'Total Appropriation'])
  end

  it "should have 2 facets" do
    @faceted_spreadsheets.size.should == 2
  end

  it "should total up the projects and expenses" do
    @faceted_spreadsheets[1].total_for("Projects").value.should eql 63
    @faceted_spreadsheets[0].total_for("Projects").value.should eql 32
    @faceted_spreadsheets[1].total_for("State").value.should be_nil
    @faceted_spreadsheets[1].total_for("Total Appropriation").value.should eql 175142465
  end

  it "should keep formatting on totals" do
    @faceted_spreadsheets[1].total_for("Total Appropriation").to_s.should eql "$175142465"
  end

  it "should remember what facet it belongs to" do
    @faceted_spreadsheets[1].faceted?.should be_true
    @faceted_spreadsheets[0].faceted_on.should == 'Democrat'
  end

  it "should keep the formatting" do
    @faceted_spreadsheets[1].rows[1].column_for('Total Appropriation').to_s.should eql "$25320127"
    @faceted_spreadsheets[1].rows[1].column_for('Projects').style.should eql "text-align:left;"
  end


end

describe TableFu, 'with macro columns' do

  class TableFu::Formatting
   
    class<<self

      def append(first, second)
        "#{first}#{second}"
      end
      
    end
    
  end


  before :all do
    csv = FasterCSV.parse(File.open('spec/assets/test_macro.csv').read)
    @spreadsheet = TableFu.new(csv)
    @spreadsheet.col_opts[:style] = {'Projects' => 'text-align:left;'}
    @spreadsheet.col_opts[:formatting] = {'Total Appropriation' => :currency,
                                          'MacroColumn' => {'method' => 'append', 'arguments' => ['Projects','State']}}
    @spreadsheet.sorted_by = {'State' => {:order => 'ascending'}}
    @spreadsheet.col_opts[:columns] = ['State', 'Total Appropriation', 'MacroColumn']
  end


  it "should let us specify a macro for a column" do
    @spreadsheet.rows[0].column_for('MacroColumn').to_s.should eql '10Alabama'
  end

end

describe TableFu, 'with reordered columns' do

  before :all do
    csv = FasterCSV.parse(File.open('spec/assets/test.csv'))
    @spreadsheet = TableFu.new(csv)
    @spreadsheet.col_opts[:style] = {'Projects' => 'text-align:left;'}
    @spreadsheet.col_opts[:formatting] = {'Total Appropriation' => :currency}
    @spreadsheet.col_opts[:sorted_by] = {'State' => {:order => 'ascending'}}
  end


  it "should display columns in the correct order" do
    @spreadsheet.col_opts[:columns] = ['State', 'Blah', 'Projects']
    @spreadsheet.column_headers.size.should eql 7
    @spreadsheet.columns.size.should eql 3
    facets  = @spreadsheet.faceted_by('State')
    @spreadsheet.rows[0].column_for('Blah').to_s.should eql ''
    @spreadsheet.rows[0].column_for('Projects').to_s.should eql '10'
  end

end
