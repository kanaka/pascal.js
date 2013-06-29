Program Get_It;



Uses
     Crt;



Const
      {
      ManChar      =Chr(1);
      BallChar     =Chr(9);
      ChaserChar   =Chr(2);
      EraseChar    =Chr(0);
      }
      ManChar      =Chr(64);
      BallChar     =Chr(79);
      ChaserChar   =Chr(88);
      EraseChar    =Chr(32);
      XMax         =70;
      YMax         =25;
      BallSpeed    =30;
      Chaser1Speed =100;
      Chaser2Speed =150;
      Chaser3Speed =200;
      Chaser4Speed =400;
      Esc          =^[;

Var
    I,
    Score,
    RndBall,
    ManX,ManY,
    BallX,BallY,
    Chaser1X,Chaser1Y,
    Chaser2X,Chaser2Y,
    Chaser3X,Chaser3Y,
    Chaser4X,Chaser4Y,
    BallCounter,
    Chaser1Counter,
    Chaser2Counter,
    Chaser3Counter,
    Chaser4Counter       :Integer;

    Rsp                  :Char;



Procedure SetUp;
Begin
  ManX           :=40;
  ManY           :=12;
  BallX          :=60;
  BallY          :=12;
  Chaser1X       :=1;
  Chaser1Y       :=1;
  Chaser2X       :=70;
  Chaser2Y       :=1;
  Chaser3X       :=1;
  Chaser3Y       :=25;
  Chaser4X       :=70;
  Chaser4Y       :=25;
  BallCounter    :=1;
  Chaser1Counter :=1;
  Chaser2Counter :=1;
  Chaser3Counter :=1;
  Chaser4Counter :=1;
  Rsp            :=' ';

  ClrScr;
  GotoXY(ManX,ManY);Write(ManChar);
  GotoXY(BallX,BallY);Write(BallChar);
  GotoXY(Chaser1X,Chaser1Y);Write(ChaserChar);
  GotoXY(Chaser2X,Chaser2Y);Write(ChaserChar);
  GotoXY(Chaser3X,Chaser3Y);Write(ChaserChar);
  GotoXY(Chaser4X,Chaser4Y);Write(ChaserChar);
End; {of Procedure SetUp}



Procedure Pause(ms : Integer);
Begin
  Delay(ms);
End;



Procedure Beep;
Begin
  For I :=1000 to 1400 do
  Begin
    {Sound(I);}
    Pause(2);
  End;
  For I :=1400 downto 1000 do
  Begin
    {Sound(I);}
    Pause(2);
  End;
  {NoSound;}
End; {of Procedure Beep}


Procedure MoveMan;
Begin

  If (Rsp=#72) and (ManY >1) then
  Begin
    GotoXY(ManX,ManY);Write(EraseChar);
    ManY :=ManY-1;
    GotoXY(ManX,ManY);Write(ManChar);
  End;

  If (Rsp=#75) and (ManX >1) then
  Begin
    GotoXY(ManX,ManY);Write(EraseChar);
    ManX :=ManX-1;
    GotoXY(ManX,ManY);Write(ManChar);
  End;

  If (Rsp=#80) and (ManY <YMax) then
  Begin
    GotoXY(ManX,ManY);Write(EraseChar);
    ManY :=ManY+1;
    GotoXY(ManX,ManY);Write(ManChar);
  End;

  If (Rsp=#77) and (ManX <XMax) then
  Begin
    GotoXY(ManX,ManY);Write(EraseChar);
    ManX :=ManX+1;
    GotoXY(ManX,ManY);Write(ManChar);
  End;

End; {of Procedure MoveMan}



Procedure MoveChaser(Var ChaserX,ChaserY :Integer);
Begin

  If ManX >ChaserX then
  Begin
    GotoXY(ChaserX,ChaserY);Write(EraseChar);
    ChaserX :=ChaserX+1;
    GotoXY(ChaserX,ChaserY);Write(ChaserChar);
  End;

  If ManX <ChaserX then
  Begin
    GotoXY(ChaserX,ChaserY);Write(EraseChar);
    ChaserX :=ChaserX-1;
    GotoXY(ChaserX,ChaserY);Write(ChaserChar);
  End;

  If ManY >ChaserY then
  Begin
    GotoXY(ChaserX,ChaserY);Write(EraseChar);
    ChaserY :=ChaserY+1;
    GotoXY(ChaserX,ChaserY);Write(ChaserChar);
  End;

  If ManY <ChaserY then
  Begin
    GotoXY(ChaserX,ChaserY);Write(EraseChar);
    ChaserY :=ChaserY-1;
    GotoXY(ChaserX,ChaserY);Write(ChaserChar);
  End;

End;



Procedure MoveBall;
Begin

  RndBall :=Random(4);

  If (RndBall =0) and (BallX>1) then
  Begin
    GotoXY(BallX,BallY);Write(EraseChar);
    BallX :=BallX-1;
    GotoXY(BallX,BallY);Write(BallChar);
  End;

  If (RndBall =1) and (BallY<Ymax) then
  Begin
    GotoXY(BallX,BallY);Write(EraseChar);
     BallY :=BallY+1;
    GotoXY(BallX,BallY);Write(BallChar);
  End;

  If (RndBall =2) and (BallX<XMax) then
  Begin
    GotoXY(BallX,BallY);Write(EraseChar);
    BallX :=BallX+1;
    GotoXY(BallX,BallY);Write(BallChar);
  End;

  If (RndBall =3) and (BallY>1) then
  Begin
    GotoXY(BallX,BallY);Write(EraseChar);
    BallY :=BallY-1;
    GotoXY(BallX,BallY);Write(BallChar);
  End;

End; {of Procedure MoveBall}



Procedure WriteScore;
Begin

  Gotoxy(71,1);Write('Score ',Score);

End; {of WriteScore}



Procedure CheckCounters;
Begin

  If Chaser1Counter =Chaser1Speed then
  Begin
    MoveChaser(Chaser1X,Chaser1Y);
    Chaser1Counter :=1;
  End
  Else
    Chaser1Counter :=Chaser1Counter+1;


  If Chaser2Counter =Chaser2Speed then
  Begin
    MoveChaser(Chaser2X,Chaser2Y);
    Chaser2Counter :=1;
  End
  Else
    Chaser2Counter :=Chaser2Counter+1;


  If Chaser3Counter =Chaser3Speed then
  Begin
    MoveChaser(Chaser3X,Chaser3Y);
    Chaser3Counter :=1;
  End
  Else
    Chaser3Counter :=Chaser3Counter+1;


  If Chaser4Counter =Chaser4Speed then
  Begin
    MoveChaser(Chaser4X,Chaser4Y);
    Chaser4Counter :=1;
  End
  Else
    Chaser4Counter :=Chaser4Counter+1;


  If BallCounter =BallSpeed then
  Begin
    MoveBall;
    BallCounter :=1;
  End
  Else
    BallCounter :=BallCounter+1;

End; {of Procedure CheckCounter}



Procedure CheckCollision(var CorX,CorY          :Integer;
                             ScoreNum           :Integer;
                             Message            :String);
Begin
  If (ManX =CorX) and (ManY =CorY) then
  Begin
    Beep;
    Score :=Score+ScoreNum;
    While KeyPressed do
      Rsp :=ReadKey;
    GotoXY(1,YMAX);Write(Message);
    Write('Press <Return> to continue');
    repeat
        Rsp := ReadKey;
    until (Rsp = #10) or (Rsp = #13);
    SetUp;
  End;
End; {of Procedure CheckCollision}

Begin

  SetUp;

  Score :=0;

  Repeat

    If KeyPressed then
    Begin
      Rsp :=ReadKey;
      If Rsp=#0 then Rsp :=ReadKey;
      MoveMan;
    End;

    WriteScore;

    If Score =-5 then
    Begin
      For I :=1 to 1000 do
      Begin
        Sound(I);Pause(3);
        Sound(I+813);Pause(2);
        Sound(I+1576);Pause(5);
      End;

      NoSound;
      Gotoxy(1,YMax);
      Write('HA HA HA HA!!!!!!!!!   YYYOOOUUU LLLOOOSSSEEE!!!');
      Pause(10000);
      Halt(1);
    End;

    If Score=6 then
    Begin
      Sound(1000);Pause(5000);
      NoSound;
      Gotoxy(1,YMax-4);
      Writeln('IiITtT cCcAaNT  BbBEeE!!!!!!!!!');
      Writeln('YoUvE w, W, wOn');
      Writeln('iT MuSt BE an ErROr IN My ProGRAMinG');
      Write('BUT Ill GET YOU NEEEEEEEEEEXT TIIIIME!!!!!!!!!');
      Pause(7000);
      Score :=0;
      ClrScr;
      Write('Press <ESC> to quit or any other key to play again');
      Rsp :=ReadKey;
      Clrscr;
    End;

    CheckCounters;

    CheckCollision(BallX,BallY,1,'YOU GOT IT!!, AAAAAAAHH!!');

    CheckCollision(Chaser1X,Chaser1Y,-1,'I GOT YOU, HA,HA,HA,HAAAA!!!!');

    CheckCollision(Chaser2X,Chaser2Y,-1,'I GOT YOU, HA,HA,HA,HAAAA!!!!');

    CheckCollision(Chaser3X,Chaser3Y,-1,'I GOT YOU, HA,HA,HA,HAAAA!!!!');

    CheckCollision(Chaser4X,Chaser4Y,-1,'I GOT YOU, HA,HA,HA,HAAAA!!!!');

    Pause(16);

  Until (Rsp = Esc) or (Rsp = #113);

End. {of Main Program}
