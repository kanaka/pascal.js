program Sample;
var
  A,B : Char;
begin
  A := 'A';
  B := 'B';
  WriteLn('A = B: ', A = B);
  WriteLn('A = A: ', A = A);
  WriteLn('A = ''A'': ', A = 'A');
  WriteLn('A = #65: ', A = #65);
  WriteLn('A = Chr(65): ', A = Chr(65));
end.
