program Sample;
var
  H       : String;

procedure PRINTIT(F : String);
  begin
    WriteLn('F: ', F);
  end;

begin
  H := 'Hello World';
  WriteLn('H: ', H);
  PRINTIT(H);
end.
