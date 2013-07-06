program Sample;

var
  a : array [0 .. 9] of Integer;
  i : Integer;

begin
  i := 1;
  a[i-1] := 7;
  WriteLn('a[0] = ', a[0]);
end.
