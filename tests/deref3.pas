program Sample;

type
    RType = record
      A : Integer;
      B : Integer;
      C : Array [1..2] of Boolean;
      S : String;
    end;

var
  a : array [1..5] of array[1..10] of array[1..15] of RType;

begin
  a[2][5][3].A := 13;
  a[2][5][3].B := 17;
  a[2][5][3].C[1] := FALSE;
  a[2][5][3].C[2] := TRUE;
  a[2][5][3].S := 'a string';
  WriteLn('a[2][5][3].A = ', a[2][5][3].A);
  WriteLn('a[2][5][3].B = ', a[2][5][3].B);
  WriteLn('a[2][5][3].C[1] = ', a[2][5][3].C[1]);
  WriteLn('a[2][5][3].C[2] = ', a[2][5][3].C[2]);
  WriteLn('a[2][5][3].S = ''', a[2][5][3].S, '''');
end.
