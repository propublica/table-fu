csv = <<-EOF
Website,URL
Propublica,http://www.propublica.org/
EOF

spreadsheet = TableFu.new(FasterCSV.parse(csv)) do |s|
  s.formatting = {"Link" => {'method' => 'link', 'arguments' => ['Website','URL']}}
end

spreadsheet.rows[0].column_for('Link').to_s