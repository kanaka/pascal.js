program Sample;
var
  H, G       : String;
begin
  H := 'Hello World';
  G := H;
  H[1] := 'M';
  WriteLn('G: ', G);
  WriteLn('H: ', H);
end.
