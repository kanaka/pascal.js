program Sample;

var
  a : array ['A'..'M',1..5] of Integer;

begin
  a['B',5] := 2;
  WriteLn('a[''B'',5] = ', a['B',5]);
end.
