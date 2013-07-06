program Sample;
var
  A,B : Char;
  S   : String;
begin
  S := 'Hello World';
  A := #66;
  S[1] := A;
  B := S[7];
  WriteLn('A = ', A);
  WriteLn('S = ', S);
  WriteLn('B = ', B);
end.
