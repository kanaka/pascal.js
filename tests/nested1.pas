program Sample;
  procedure Output(A,B : Integer);
    VAR C : Integer;
    procedure IncC();
    begin
      C := C + 1
    end;
  begin
    C := 1;
    IncC();
    WriteLn(A, ', ', B, ', ', C) 
  end;
begin
  Output(7, 8)
end.
