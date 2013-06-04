program Sample;
  var
      C : Integer;

  procedure Output(A,B : Integer);
  begin
    WriteLn(A, ', ', B) 
  end;
begin
  C := 9;
  Output(7,C)
end.
