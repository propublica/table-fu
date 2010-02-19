spreadsheet = TableFu.new(FasterCSV.parse(csv))
spreadsheet.sum_totals_for('Number of Pages')