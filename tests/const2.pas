program Sample;
const
  A = Chr(65);
  B = #66;
  CR = ^M;
  LF = ^J;
var
  C : Char;

begin
  Write('A = ', A);
  Write(CR, LF);
  WriteLn('B = ', B);
  C := #67;
  WriteLn('C = ', C);
end.
