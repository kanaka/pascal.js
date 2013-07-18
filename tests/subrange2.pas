program TestOrd;

type
    Low = 1..10;
    High = 11..20;

var
    l: Low;
    h: High;

begin
  l := 9;
  h := 12;
  WriteLn('l: ', l);
  WriteLn('h: ', h);
end.
