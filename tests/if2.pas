program Sample;

var a : BOOLEAN;
    b : BOOLEAN;
    
begin
  a := true;
  b := false;
  if a and b then begin
    WriteLn('and is yep')
  end else if a or b then begin
    WriteLn('and is nope but or is yep')
  end else
    WriteLn('and and or is nope')
end.


