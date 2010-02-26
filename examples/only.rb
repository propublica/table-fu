spreadsheet = TableFu.new(csv) do |s|
  s.sorted_by = {'Style' => {"order" => 'ascending'}}
end

spreadsheet.only!(2..4)
spreadsheet.rows