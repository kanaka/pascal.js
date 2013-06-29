program Sample;

uses crt;

var ch : char;

begin
  WriteLn('Press to show keys, q to exit');
  ch := #0;
  while ch <> #113 do
  begin
    ch := ReadKey;
    if ch = #0 then begin
      ch := ReadKey;
      WriteLn('Got escape character: ', Integer(ch));
    end else begin
      WriteLn('Got regular character: ', Integer(ch));
    end;
  end;
end.
