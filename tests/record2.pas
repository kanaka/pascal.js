program Sample;

type
    R1 = record
           A : Integer;
           B : Integer;
           C : Array [1..10] of Integer;
         end;
var
    X : R1;
    Y : Array [1..3] of R1;

begin
    X.A := 1;
    X.B := 2;
    X.C[1] := 3;
    Y[1].A := 4;
    Y[1].B := 5;
    Y[2].C[3] := 6;
    WriteLn('X.B = ', X.B);
    WriteLn('Y[2].C[3] = ', Y[2].C[3]);
end.
