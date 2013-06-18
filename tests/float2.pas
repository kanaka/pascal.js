program Float1;
var
    A,B,C   : Real;
    D       : Integer;
begin
    A := 1.1;
    B := 21; {coerce integer literal to real}
    D := 31;
    C := D; {coerce integer variable to real}
    WriteLn('A = ', A, ', B = ', B, ', C = ', C);
end.
