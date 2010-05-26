spreadsheet = TableFu.new(csv) do |s|
  s.columns = ["Best Book", "Author"]
end

spreadsheet.rows[0]['Style'].to_s