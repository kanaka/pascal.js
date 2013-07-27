program Sample;

var
    a,b: Byte;

begin
    a := 1;
    b := 3;
    if a > b then
      WriteLn('a > b')
    else
      WriteLn('a < b');
    if b > 2 then
      WriteLn('b > 2')
    else
      WriteLn('b < 2');
end.
