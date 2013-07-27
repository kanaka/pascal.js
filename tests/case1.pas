program TestCase;

  procedure switch(sel : Integer);
  begin
    case sel of
      0: WriteLn('hello 0');
      1: WriteLn('hello 1');
      2: WriteLn('hello 2');
      3,4: WriteLn('hello 3 or 4');
      5..10: WriteLn('hello 5 through 10');
      otherwise begin
        WriteLn('unrecognize selector:');
        WriteLn(sel);
      end;
    end;
  end;

begin
  switch(0);
  switch(1);
  switch(2);
  switch(3);
  switch(4);
  switch(5);
  switch(10);
  switch(11);
end.
