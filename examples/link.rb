csv = <<-EOF
Website,URL
Propublica,http://www.propublica.org/
EOF

spreadsheet = TableFu.new(csv) do |s|
  s.formatting = {"Link" => {'method' => 'link', 'arguments' => ['Website','URL']}}
  s.columns = ["Link"]
end

spreadsheet.rows[0].column_for('Link').to_s