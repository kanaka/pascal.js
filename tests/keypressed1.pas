program Sample;

uses crt;

var ch : char;

begin
  WriteLn('Waiting for key press');
  while not KeyPressed() do
  begin
    Delay(1);
  end;
  ch := ReadKey;
  WriteLn('Got character: ', ch);
end.
