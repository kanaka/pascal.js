program Sample;
var
    A,B,C,D     : Boolean;
begin
    A := TRUE;
    B := FALSE;
    C := A or B;
    D := A and B;
    WriteLn('A = ',A);
    WriteLn('B = ',B);
    WriteLn('C = ',C);
    WriteLn('D = ',D)
end.
