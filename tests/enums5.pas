program TestEnums;

type
    Days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var day : Days;

begin
  WriteLn('Mon < Fri: ', Mon < Fri);
  day := Tue;
  WriteLn('Fri < day: ', Fri < day);
end.
