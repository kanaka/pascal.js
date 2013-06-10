program Sample;
type
    MyInt1 = Integer;
    MyInt2 = MyInt1;
var
    A,B,C : MyInt2;
begin
    A := 1;
    B := 2;
    C := A + B;
    WriteLn(C) 
end.
