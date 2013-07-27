program Sample;

type
    ShortBuf = array[1..10] of Byte;

var
    buffer: ShortBuf;
    a, idx: Byte;

begin
    a := 7;
    idx := 3;
    buffer[idx] := a;
    WriteLn('buffer[3]: ', buffer[3]);
end.
