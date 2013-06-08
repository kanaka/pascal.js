program Sample;

var
  a : array [1 .. 10] of Integer;

begin
  a[1] := 2;
  a[2] := 3;
  a[3] := a[1] + a[2];
  WriteLn('a[1] = ', a[1], ', a[2] = ', a[2], ', a[3] = ', a[3])
end.
