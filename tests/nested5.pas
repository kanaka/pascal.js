program Sample;
  procedure top();
    var A, cnt : Integer;
    procedure recur(A : Integer);
    begin
      cnt := cnt + 1;
      if (A > 0) then recur(A-1);
    end;
  begin
    A := 4;
    recur(10);
    WriteLn('A: ', A, ', cnt: ', cnt);
  end;
begin
  top();
end.
