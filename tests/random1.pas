program Sample;
var
    i    : Integer;
    rand : Real;

begin
  for i := 1 to 20 do
  begin
    rand := Random;
    WriteLn('rand = ', rand);
  end;
end.
