program TestOrd;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var
    day: Days;
    weekday: Mon..Fri;

begin
  day := Mon;
  weekday := Mon;
  WriteLn('Ord(day): ', Ord(day));
  WriteLn('day: ', day);
  WriteLn('Ord(weekday): ', Ord(weekday));
  WriteLn('weekday: ', weekday);
end.
