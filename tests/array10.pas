program Sample;

const
    size = 5;

type
    ARR = array[1..size] of Integer;

var
    a: ARR;

procedure print_array1 ( x :ARR; idx: Integer);
  begin
    WriteLn('x[idx]: ', x[idx]);
  end;

procedure print_array2 ( var y :ARR; idx: Integer);
  begin
    WriteLn('y[idx]: ', y[idx]);
  end;

begin
  a[1] := 7;
  WriteLn('a[1]: ', a[1]);
  print_array1(a, 1);
  print_array2(a, 1);
end.
