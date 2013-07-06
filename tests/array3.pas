program Sample;

var
  a : array [1 .. 10] of Boolean;

begin
  a[1] := TRUE;
  a[2] := FALSE;
  a[3] := a[1] and a[2];
  WriteLn('a[1] = ', a[1], ', a[2] = ', a[2], ', a[3] = ', a[3])
end.
