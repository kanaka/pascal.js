program Sample;
  VAR C : Integer;
  procedure Output(A,B : Integer);
  VAR C : Integer;
  begin
    C := 2;
    WriteLn(A, ', ', B, ', ', C) 
  end;
begin
  C := 1;
  Output(7, 8);
  WriteLn('C = ', C)
end.
