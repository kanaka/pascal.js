program findArea;

type
   squareType = record
      width : Integer;
      height : Integer;
   end;
var
   square : squareType;
begin
   WriteLn('Enter the height:');
   ReadLn(square.height);
   WriteLn('Enter the width:');
   ReadLn(square.width);
   WriteLn('Area: ', square.width * square.height);
end.
