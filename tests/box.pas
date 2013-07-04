program Box;

Uses Crt;

Var I: Integer;

procedure DrawBox(X1 ,Y1, X2, Y2: Integer);
  Var I: Integer;
  begin
      GotoXY(X1 ,Y1);
      for I := X1 to X2 do write('-');
      GotoXY(X1 ,Y1+1);
      for I := Y1 + 1 to Y2 do
      begin
          GotoXY(X1,I); Write('!');
          GotoXY(X2,I); Write('!');
      end;
      GotoXY(X1 ,Y2);
      for I := X1 to X2 do Write('-');
  end; { of procedure DrawBox }

begin
    ClrScr;
    for I := 1 to 5 do DrawBox(I*4,I*2,10*I,4*I);
    DrawBox(1,1,80,23);
end.

