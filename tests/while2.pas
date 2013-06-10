program Sample;

procedure countdown1();
  var i : Integer;
  begin
  i := 5;
  while i > 0 do
  begin
    writeln(i);
    i := i - 1;
  end;
  writeln('last i = ', i)
  end;

procedure countdown2(i : Integer);
  begin
  while i > 0 do
  begin
    writeln(i);
    i := i - 1;
  end;
  writeln('last i = ', i)
  end;

procedure countdown3(var i : Integer);
  begin
  while i > 0 do
  begin
    writeln(i);
    i := i - 1;
  end;
  writeln('last i = ', i)
  end;

var x : Integer;

begin
  countdown1();

  x := 6;
  countdown2(x);
  writeln('x after countdown2: ', x);

  x := 7;
  countdown3(x);
  writeln('x after countdown3: ', x);
end.
