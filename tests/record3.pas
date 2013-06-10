program Sample;

type
    RType = record
      A : Integer;
      B : record
        C : Integer;
        D : record
          E : Integer;
        end;
      end;
    end;
var
    X : RType;

begin
    X.A := 1;
    X.B.C := 2;
    X.B.D.E := 3;
    WriteLn('X.A = ', X.A);
    WriteLn('X.B.C = ', X.B.C);
    WriteLn('X.B.D.E = ', X.B.D.E);
end.
