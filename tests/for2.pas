program Sample;
var i : Integer;
begin
  i := 3;
  for i := 6 to 5 do
    writeln(i);
  writeln('i1: ', i);

  for i := 5 downto 6 do
    writeln(i);
  writeln('i2: ', i);

  for i := 8 to 8 do
    writeln(i);
  writeln('i3: ', i);

  for i := 13 downto 13 do
    writeln(i);
  writeln('i4: ', i)

end.
