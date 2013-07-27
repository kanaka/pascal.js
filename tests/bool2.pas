program Sample;

procedure A (test:Boolean);
begin
  if test then
    WriteLn('yep')
  else
    WriteLn ('nope')
end;

function B:Boolean;
begin
  B := False
end;

begin
 A( not(B) )
end.
