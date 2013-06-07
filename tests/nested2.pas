program Sample;
  procedure Output(A,B : Integer);
    var C,D : Integer;
    procedure Incs();
      procedure IncD();
      begin
        D := D + 1
      end;
    begin
      C := C + 1;
      IncD()
    end;
  begin
    C := 10;
    D := 100;
    Incs();
    WriteLn(A, ', ', B, ', ', C, ', ', D) 
  end;
begin
  Output(1, 2)
end.
