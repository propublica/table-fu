spreadsheet = TableFu.new(csv) do |s|
  s.delete_rows! [1]
end