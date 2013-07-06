program Sample;
var
  H       : String;

procedure CopyPrint1(G: String);
  var F : String;
  begin
    F := G;
    F[1] := 'M';
    WriteLn('F: ', F);
    WriteLn('G: ', G);
  end;

procedure CopyPrint2(var G: String);
  var F : String;
  begin
    F := G;
    G[1] := 'M';
    WriteLn('F: ', F);
    WriteLn('G: ', G);
  end;

begin
  H := 'Hello World';
  CopyPrint1(H);
  WriteLn('1 H: ', H);
  CopyPrint2(H);
  WriteLn('2 H: ', H);
end.
