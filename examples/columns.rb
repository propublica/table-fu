spreadsheet = TableFu.new(csv) do |s|
  s.columns = ["Best Book", "Author"]
end

spreadsheet.columns.map do |column|
  spreadsheet.rows[0].column_for(column).to_s
end
