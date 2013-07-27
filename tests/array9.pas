program Sample;

type
    letters = 'A'..'M';
    days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

var
  a : array [letters,Mon..Fri] of Integer;
  b : array [letters,days] of Integer;

begin
  a['B',Tue] := 2;
  b['C',Tue] := 3;
  WriteLn('a[''B'',Tue] = ', a['B',Tue]);
  WriteLn('b[''C'',Tue] = ', b['C',Tue]);
end.
