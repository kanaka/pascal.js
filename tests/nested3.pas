program Sample;
  var A, B : Integer;
  procedure L1(var C : Integer);
    procedure L2();
      procedure L3();
      begin
        C := C + 100;
        B := B + 7
      end;
    begin
      C := C + 10;
      L3()
    end;
  begin
    C := C + 1;
    L2()
  end;
begin
  A := 0;
  B := 1000;
  L1(A);
  WriteLn('A = ', A, ', B = ', B) 
end.
