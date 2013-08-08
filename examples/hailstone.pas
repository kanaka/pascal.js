Program Hailstone;

function Hail(N :Integer) :Integer;
  var cnt: Integer;
  var start: Boolean;
begin
  cnt := 0;
  start := true;
  while N <> 1 do
  begin
    if Odd(N) then
      N := (3 * N) + 1
    else
      N := N div 2;
    if start then
      start := false
    else
      Write(', ');
    Write(N);
  end;
end;

Var
    I, X, Y: Integer;

begin
  Write('Enter any integer: ');
  Readln(X);
  for I := X downto 1 do
  begin
    Write(I, ': ');
    Y := Hail(I);
    WriteLn();
  end;
end.
