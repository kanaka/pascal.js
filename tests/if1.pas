program Sample;

var a : BOOLEAN;
    b : BOOLEAN;
    
begin
  a := true;
  b := false;
  if a or b then
    WriteLn('or is yep')
  else
    WriteLn('or is nope');

  if a and b then begin
    WriteLn('and is yep')
  end else begin
    WriteLn('and is nope')
  end
end.


