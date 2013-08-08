uses WinCrt, Strings;

const TheText : PChar = ' ’„Ì„ «· ÃÂÌ“« '#10
                          + '«·„Â‰œ” Œ«·œ ’»«€'#10
                          + 'Õ·» - ”Ê—Ì« - Â« › (021) 232979'#10#10
                          + '»—„Ã…'#10
                          + '«·„Â‰œ” —”·«‰ ﬂ›—Ì'#10
                          + 'Õ„«Â - ”Ê—Ì« - Â« › (033) 237297';

const Key: array[1..10] of Byte = (10,200,1,15,33,44,255,100,2,26);

procedure Decode(AKey: Pointer; ABlock: Pointer; AKeySize: Word; ABlockSize: Word);
var K,
    B: Word;
    KeyPtr: Pointer;
    BlockPtr: Pointer;
begin
     KeyPtr := AKey;
     BlockPtr := ABlock;
     K := 1;
     B := 1;
     while B <= ABlockSize
     do begin
        Byte(BlockPtr^) := Byte(BlockPtr^) xor Byte(KeyPtr^);
        B := B + 1;
        K := K + 1;
        KeyPtr := PChar(KeyPtr) + 1;
        BlockPtr := PChar(BlockPtr) + 1;
        if K > AKeySize
        then begin
             K := 1;
             KeyPtr := AKey;
             end;
        end;
end;


var F: Text;
    L: Integer;
    J: Word;
    BlockLen: Word;
    P: Pointer;
    I: Word;
begin

     Assign(F,'ENCODED.PAS');
     ReWrite(F);

     L := 1;
     WriteLn(F,'The key:');
     for J := 1 to SizeOf(Key)
     do begin
        Write(F, '#',Key[J]);
        L := L + 1;
        if L = 10
        then begin
             WriteLn(F);
             L := 1;
             end;
        end;


     BlockLen := StrLen(TheText);
     Decode(@Key, TheText, SizeOf(Key), BlockLen);
     WriteLn(F);
     WriteLn(F,'The text:');
     L := 1;
     P := TheText;
     I := 1;
     J := 1;

     while (I <= BlockLen)
     do begin
        Write(F, '#',Byte(P^));
        P := PChar(P) + 1;
        I := I + 1;
        L := L + 1;
        if L = 10
        then begin
             WriteLn(F);
             L := 1;
             end;
        end;

     Close(F);
end.