program QuickSort;

type
  NumberArray = Array [0..9] of Integer;

procedure QSort(var numbers : NumberArray; left : Integer; right : Integer);
  var pivot, l_ptr, r_ptr : Integer;
begin
  l_ptr := left;
  r_ptr := right;
  pivot := numbers[left];
  while (left < right) do
  begin
    while ((numbers[right] >= pivot) and (left < right)) do
      right := right - 1;
    If (left <> right) then
    begin
      numbers[left] := numbers[right];
      left := left + 1;
    end;
    while ((numbers[left] <= pivot) and (left < right)) do
      left := left + 1;
    If (left <> right) then
    begin
      numbers[right] := numbers[left];
      right := right - 1;
    end;
  end;
  numbers[left] := pivot;
  pivot := left;
  left := l_ptr;
  right := r_ptr;
  If (left < pivot) then
    QSort(numbers, left, pivot-1);
  If (right > pivot) then
    QSort(numbers, pivot+1, right);
end;

var
  numbers : NumberArray;
  i : Integer;

begin
  numbers[0] := 123;
  numbers[1] := 1;
  numbers[2] := 98;
  numbers[3] := 5;
  numbers[5] := 13;
  numbers[4] := 20;
  numbers[6] := 25;
  numbers[7] := 22;
  numbers[8] := 21;
  numbers[9] := 5;
  QSort(numbers, 0, 9);
  for i := 0 to 9 do
    WriteLn(i, ': ', numbers[i]);
end.
