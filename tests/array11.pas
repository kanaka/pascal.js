program FuncArray;

const
 size = 5;

type
 a = array [1..size] of integer;

var
 balance:  a;
 average: real;  

  function avg( var arr: a) : real;
  var
    i :1..size;
    sum: integer;
  begin
    writeln('here2');
    sum := 0;
    for i := 1 to size do
       sum := sum + arr[i];
    writeln('here3');
    avg := sum / size;
    writeln('here4');
  end;

begin  
  writeln('here0');
  balance[1] := 1000;
  balance[2] := 2;
  balance[3] := 3;
  balance[4] := 17;
  balance[5] := 50;
  writeln('here1');
  average := avg( balance ) ;
  writeln('here5');
  writeln('Average: ', average);
  writeln('here6');
end.
