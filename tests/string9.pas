program Sample;
var
  H       : String;

function hello(): String;
  var hstr : String;
  begin
    hstr := 'Hello';
    hello := hstr;
  end;

begin
  WriteLn(hello(), ' World');
end.
