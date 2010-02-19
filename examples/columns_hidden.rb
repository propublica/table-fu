spreadsheet = TableFu.new(FasterCSV.parse(csv)) do |s|
  s.columns = ["Best Book", "Author"]
end

spreadsheet.rows[0].column_for('Style').to_s