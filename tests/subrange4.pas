program TestOrd;

const
    first1 = 1;
    last1 = 10;
    first2 = 11;
    last2 = 20;

type
    Low = first1..last1;
    High = first2..last2;

var
    l: Low;
    h: High;

begin
  l := 9;
  h := 12;
  WriteLn('l: ', l);
  WriteLn('h: ', h);
end.
