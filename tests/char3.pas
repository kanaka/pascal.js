program Sample;
var
  A,B, C : Char;
begin
  A := 'A';
  B := 'B';
  C := Char(Ord(B) + 1);
  WriteLn('A: ', A);
  WriteLn('B: ', B);
  WriteLn('C: ', C);
end.
