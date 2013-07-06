program Sample;

var
  a : string;
  i : Integer;

begin
  a := 'Hello World';
  i := 2;
  a[i-1] := 'M';
  WriteLn('a: ''', a, '''');
end.
