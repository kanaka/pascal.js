program Sample;
var
  H, W, HW       : String;
begin
  H := 'Hello';
  W := 'World';
  HW := Concat(H, ' ', W);
  WriteLn(HW);
end.
