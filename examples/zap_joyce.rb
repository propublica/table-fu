spreadsheet = TableFu.new(FasterCSV.parse(csv)) do |s|
  s.delete_rows! [1]
end