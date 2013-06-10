program Sample;

type
    RType = record
      A : Integer;
      B : Integer;
      C : record
        D : Integer;
        E : Integer;
      end;
    end;
var
    X : RType;

begin
    X.A := 1;
    X.B := 2;
    X.C.D := 3;
    X.C.E := 4;
    WriteLn('X.A = ', X.A, ', X.B = ', X.B);
    WriteLn('X.C.D = ', X.C.D, ', X.C.E = ', X.C.E);
end.
