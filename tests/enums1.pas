program TestEnums;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var day : Days;

begin
  WriteLn('Ord(Mon): ', Ord(Mon));
  day := Tue;
  WriteLn('Ord(day): ', Ord(day));
end.
