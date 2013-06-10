program Sample;
type
    MyInt = Integer;
var
    A : array [1..10] of MyInt;

begin
    A[1] := 1;
    A[10] := 10;
    WriteLn('A[1] = ', A[1], ', A[10] = ', A[10]); 
end.
