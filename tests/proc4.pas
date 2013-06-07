program Sample;
  procedure Change(A : Integer; var B : Integer);
  begin
    A := 13;
    B := B + 1 
  end;
  var A,B : Integer;
begin
    A := 3;
    B := 4;
    Change(A,B);
    WriteLn('A = ',A,' B = ',B)
end.
