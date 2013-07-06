program Sample;

function Func(i :Integer) :Integer;
  begin
    WriteLn(i);
    Func := 'abc';
  end;

var res : Integer;

begin
  res := Func(1);
  WriteLn('res: ', res);
end.
