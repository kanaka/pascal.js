program Sample;

function Func(i :Integer) :Integer;
  begin
    WriteLn(i);
    Func := i + 1;
  end;

var res : String;

begin
  res := Func(1);
  WriteLn('res: ', res);
end.
