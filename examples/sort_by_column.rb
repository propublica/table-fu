csv =<<-CSV
Author,Best Book,Number of Pages,Style
Samuel Beckett,Malone Muert,120,Modernism
James Joyce,Ulysses,644,Modernism
Nicholson Baker,Mezannine,150,Minimalism
Vladimir Sorokin,The Queue,263,Satire
CSV

spreadsheet = TableFu.new(csv) do |s|
  s.sorted_by = {'Best Book' => {'order' => 'ascending'}}
end
