program Sample;

type
    RType = record
      A : Integer;
      B : Integer;
    end;
var
    X : RType;

begin
    X.A := 1;
    X.B := 2;
    WriteLn('X.A = ', X.A, ', X.B = ', X.B);
end.
