Program Catch222;
{From Turbo Pascal Reference (Feb84) pg. 138}

Var
    X: Integer;
function Up(Var I: Integer): Integer; forward;
function Down(Var I: Integer): Integer;
begin
  I := I div 2; Writeln(I);
  if I <> 1 then I := Up(I);
end;
function Up(Var I: Integer): Integer;
begin
  while I mod 2 <> 0 do
  begin
    I := I*3+1; Writeln(I);
  end;
  I := Down(I);
end;

begin
  Write('Enter any integer: ');
  Readln(X);
  X := Up(X);
  Writeln('Ok. Program stopped again.');
end.
