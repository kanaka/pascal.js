program Sample;

var
  a : array [1..10] of array[1..5] of Integer;

begin
  a[2][5] := 2;
  WriteLn('a[2][5] = ', a[2][5]);
end.
