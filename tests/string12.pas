program Sample;
var
  S              : Char;
  H, W, HW       : String;
begin
  S := ' ';
  H := 'Hello';
  W := 'World';
  HW := H + S + W;
  WriteLn(HW);
end.
