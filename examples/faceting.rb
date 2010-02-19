spreadsheet = TableFu.new(FasterCSV.parse(csv))
spreadsheet.faceted_by "Style"