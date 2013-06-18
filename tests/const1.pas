program Sample;
const
  A = Chr(65);
  B = #66;
  CR = ^M;
  LF = ^J;

begin
  Write('A = ', A);
  Write(CR, LF);
  WriteLn('B = ', B);
end.
