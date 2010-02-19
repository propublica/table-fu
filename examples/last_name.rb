spreadsheet = TableFu.new(FasterCSV.parse(csv)) do |s|
  s.formatting = {"Author" => 'last_name'}
end
spreadsheet.rows[0].column_for('Author').to_s