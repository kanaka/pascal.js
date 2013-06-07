program fibo;     
var
 i, result : integer;

procedure fib(var return : integer; n : integer) ;
  var r1, r2 : integer;
  begin
    if n <= 2 then return := 1
    else begin
        fib(r1,n-2);
        fib(r2,n-1);
        return := r1 + r2
    end
  end;

begin
  for i := 1 to 20 do
  begin
    fib(result, i);
    writeln(i, ' : ', result)
  end
end.
