program Sample;
var
  H, G       : String;

procedure hello(s : String);
  var hstr : String;
  begin
    hstr := 'Hello';
    WriteLn(hstr, ' ', s);
  end;

begin
  H := 'World';
  G := H;
  hello(G);
end.
