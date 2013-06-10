program Sample;

type
    Array5 = array [1..5] of integer;

var
   a : Array5;

function sum(arr: Array5) : integer;
  var
     i : integer;
     ret : integer;
  begin
    ret := 0;
    for i := 1 to 5 do
      ret := ret + arr[i];
    sum := ret;
  end;

begin  
  a[1] := 1;
  a[2] := 2;
  a[3] := 3;
  a[4] := 4;
  a[5] := 5;
  WriteLn('Sum is: ', sum(a));
end.
