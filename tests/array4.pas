program Sample;

type
    Array10 = array [1..10] of Integer;

var
  a : Array10;

procedure update(var b : Array10);
  begin
    b[2] := 7;
  end;

begin
  a[1] := 1;
  a[2] := 2;
  a[3] := 3;
  update(a);
  WriteLn('a[1] = ', a[1], ', a[2] = ', a[2], ', a[3] = ', a[3])
end.
