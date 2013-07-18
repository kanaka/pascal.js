program TestEnums;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

procedure proc1();
  type
    WeekDays = (Mon, Tue, Wed, Thu, Fri);
  begin
    WriteLn('2 Wed: ', Wed);
    WriteLn('2 Ord(Wed): ', Ord(Wed));
  end;

begin
  WriteLn('1 Wed: ', Wed);
  WriteLn('1 Ord(Wed): ', Ord(Wed));
  proc1();
end.
