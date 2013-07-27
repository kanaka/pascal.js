program TestOrd;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var
    weekday: Mon..Fri;

begin
  weekday := Mon;
  WriteLn('weekday: ', weekday);
  WriteLn('Ord(weekday): ', Ord(weekday));
end.
