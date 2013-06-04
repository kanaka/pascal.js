PROGRAM Sample;
    VAR a,b : INTEGER;
    VAR x   : BOOLEAN;
BEGIN
  a := 1 * (2 + 3 DIV - 4);
  b := 5 DIV (6 - 7);
  x := a < b;
  WriteLn('a = ', a, ', b = ', b, ', x (a < b) = ', x)
END.


