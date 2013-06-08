program Sample;

var
  a1, a2 : array [1 .. 10] of Integer;

begin
  a2[9] := 9;
  a2[10] := 10;
  a1[9] := 2;
  a1[10] := 3;
  a2 := a1;
  a2[9] := 9;
  WriteLn('a1[9] = ', a1[9], ', a1[10] = ', a1[10], ', a2[9] = ', a2[9], ', a2[10] = ', a2[10]);
end.
