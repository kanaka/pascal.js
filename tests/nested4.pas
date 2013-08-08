program NestedScope;
  var A : Integer;

  procedure L1(var C : Integer);
    var B : Integer;

    procedure L2();

      procedure L3();
      begin
        A := A + 10;
        WriteLn('L3 A = ', A); {L3 A = 2211}
        B := B + 10;
        WriteLn('L3 A = ', A, ', B = ', B); {L3 A = 2211, B = 1110}
        C := C + 10;
        WriteLn('L3 A = ', A, ', B = ', B, ', C = ', C); {L3 A = 2221, B = 1110, C = 2221}
        C := A + B + C + 1;
        WriteLn('L3 A = ', A, ', B = ', B, ', C = ', C); {L3 A = 5553, B = 1110, C = 5553}
      end;

    begin
      A := A + 100;
      WriteLn('L2 A = ', A); {L2 A = 2101}
      B := B + 100;
      WriteLn('L2 A = ', A, ', B = ', B); {L2 A = 2101, B = 1100}
      C := C + 100;
      WriteLn('L2 A = ', A, ', B = ', B, ', C = ', C); {L2 A = 2101, B = 1100, C = 2201}
      L3();
      WriteLn('L2 A = ', A, ', B = ', B, ', C = ', C); {L2 A = 5553, B = 1110, C = 5553}
    end;

  begin
    A := A + 1000;
    WriteLn('L1 A = ', A); {L1 A = 1001}
    B := 1000;
    WriteLn('L1 A = ', A, ', B = ', B); {L1 A = 1001, B = 1000}
    C := C + 1000;
    WriteLn('L1 A = ', A, ', B = ', B, ', C = ', C); {L1 A = 2001, B = 1000, C = 2001}
    L2();
    WriteLn('L1 A = ', A, ', B = ', B, ', C = ', C); {L1 A = 5553, B = 1110, C = 5553}
  end;

begin
  A := 1;
  WriteLn('A = ', A); {A = 1}
  L1(A);
  WriteLn('A = ', A); {A = 5553}
end.
