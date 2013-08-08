program JSCallback;

uses js;

  procedure periodic();
  begin
    WriteLn('In periodic') 
  end;

begin
  SetInterval(^periodic, 1000);
end.
