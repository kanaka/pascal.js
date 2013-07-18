program TestEnums;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var day : Days;

begin
  WriteLn('Mon: ', Mon);
  day := Tue;
  WriteLn('day: ', day);
end.
