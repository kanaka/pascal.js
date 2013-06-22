program Sample;
var i : Integer;
begin
  i := 6;
  repeat
    writeln(i);
    i := i - 1;
  until i <= 0;
  writeln('last i = ', i)
end.
