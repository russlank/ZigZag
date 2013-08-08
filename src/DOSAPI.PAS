unit DOSAPI;

interface

uses Crt;

function InputString(AX, AY, MaxLen: Integer; var AStr: string; ADisplay: Boolean): Boolean;
function InputInteger(AX, AY, MinVal, MaxVal: Integer; var AValue: Integer): Boolean;

implementation

function InputString(AX, AY, MaxLen: Integer; var AStr: string; ADisplay: Boolean): Boolean;
var Str: string;
    Pos: Integer;
    WindowWidth: Integer;
    LastTextAttr: Byte;

    procedure Draw;
    var I: Integer;
    begin
         GotoXY(AX, AY);
         TextAttr := 15;
         for I := 1 to WindowWidth
         do Write(' ');
         GotoXY(AX + 1, AY);
         Write(Str);
    end;

    procedure Display;
    var I: Integer;
    begin
         GotoXY(AX, AY);
         TextAttr := 15;
         for I := 1 to WindowWidth
         do Write(' ');
         if ADisplay
         then begin
              TextAttr := 15;
              GotoXY(AX + 1, AY);
              Write(Str);
              GotoXY(AX + Pos, AY)
              end
         else begin
              TextAttr := 15;
              GotoXY(AX + 1, AY);
              for I := 1 to Length(Str)
              do Write('*');
              GotoXY(AX + Pos, AY);
              end;
    end;

    function Edit: Boolean;
    var Key: Char;
        Update: Boolean;
    begin
         Key := ReadKey;
         Update := False;
         while ((Key <> #13) and (Key <> #27))
         do begin
            if Key in [#32..#127]
            then begin
                 if Pos <= MaxLen
                 then begin
                      Str[Pos] := Key;
                      if Pos > Length(Str)
                      then begin
                           Str[0] := Char(Pos);
                           end;
                      Pos := Pos + 1;
                      Update := True;
                      end;
                 end
            else begin
                 if (Key = #0)
                 then begin
                      Key := ReadKey;
                      end;
                 case Key
                 of #8: begin
                        if (Pos > 1)
                        then begin
                             Pos := Pos - 1;
                             Delete(Str,Pos,1);
                             Update := True;
                             end;
                        end;
                     #83: begin
                          if (Pos <= Length(Str))
                          then begin
                               Delete(Str,Pos,1);
                               Update := True;
                               end;
                          end;
                     #75: begin
                          if (Pos > 1)
                          then begin
                               Pos := Pos - 1;
                               Update := True;
                               end;
                          end;
                     #77: begin
                          if (Pos <= Length(Str))
                          then begin
                               Pos := Pos + 1;
                               Update := True;
                               end;
                          end;
                     end;
                 end;
            if Update
            then Display;
            Key := ReadKey;
            end;
         if Key = #13
         then begin
              Edit := True;
              AStr := Str;
              end
         else begin
              Edit := False;
              end;
    end;
begin
     {HideMouse;}
     LastTextAttr := TextAttr;
     WindowWidth := (MaxLen + 2);
     if (Length(AStr) <= MaxLen)
     then Str := AStr
     else Str := Copy(AStr,1,MaxLen);
     Pos := Length(Str) + 1;
     Draw;
     Display;
     TextAttr := LastTextAttr;
     InputString := Edit;
     {ShowMouse;}
end;

function InputInteger(AX, AY, MinVal, MaxVal: Integer; var AValue: Integer): Boolean;
var S: string;
    Accept: Boolean;
    Value: Integer;
    Code: Integer;
label
     Input;
begin
     Str(AValue, S);
Input:
     Accept := InputString(AX, AY, 4, S, True);
     if Accept
     then begin
          Val(S, Value, Code);
          if ((Code <> 0) or (Value < MinVal) or (Value > MaxVal))
          then goto Input;
          AValue := Value;
          end;
     InputInteger := Accept;
end;

end.