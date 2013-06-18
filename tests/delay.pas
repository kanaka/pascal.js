program Sample;

Uses crt;

begin
  WriteLn('before delay(500)');
  Delay(500);
  WriteLn('after delay(500)');
  WriteLn('before delay(100)');
  Delay(100);
  WriteLn('after delay(100)');
end.
