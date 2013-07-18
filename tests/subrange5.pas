program TestOrd;

const
    first = 'A';
    last = 'B';

type
    Alpha = first..last;

var
    a: Alpha;

begin
  a := 'B';
  WriteLn('a: ', a);
end.
