program Sample;
const
    max  = 10000;
var
    i    : Integer;
    rand : Integer;

begin
  for i := 1 to 20 do
  begin
    rand := Random(max);
    WriteLn('rand = ', rand);
  end;
end.
