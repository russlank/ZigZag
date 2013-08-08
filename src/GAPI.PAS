unit GAPI;

interface

uses Crt, Graph;

const
     Solid : FillPatternType = ($FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF);
     Gray50 : FillPatternType = ($AA, $55, $AA, $55, $AA, $55, $AA, $55);
     Squares : FillPatternType = ($F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F);
     Hatch : FillPatternType = ($11,$22,$44,$88,$11,$22,$44,$88);

procedure OutTextXY3D(AX,AY: Integer; ATextColor, AShadowColor: Word; Text: string);
procedure OutTextXYFramed(AX, AY: Integer; ATextColor, AFrameColor: Word; Text: string);
function InputString(AX, AY, MaxLen: Integer; var AStr: string; ADisplay: Boolean): Boolean;
function GetOption( AXPos, AYPos: Integer; AAllign: Integer;
                    ATextColor, ABackColor: Integer; AOptions: string; ADefault: Integer): Integer;
function FileExists(AFName: string): Boolean;
procedure ErrorBeep;
procedure OkBeep;
procedure WarningBeep;

implementation


procedure OutTextXY3D(AX,AY: Integer; ATextColor, AShadowColor: Word; Text: string);
begin
     SetColor(AShadowColor);
     OutTextXY(AX,AY + 1,Text);
     SetColor(ATextColor);
     OutTextXY(AX + 1,AY,Text);
end;


procedure OutTextXYFramed(AX, AY: Integer; ATextColor, AFrameColor: Word; Text: string);
begin
     SetColor(AFrameColor);
     OutTextXY(AX + 1,AY + 1,Text);
     OutTextXY(AX - 1,AY - 1,Text);
     OutTextXY(AX,AY + 1,Text);
     OutTextXY(AX,AY - 1,Text);
     OutTextXY(AX + 1,AY,Text);
     OutTextXY(AX - 1,AY,Text);
     OutTextXY(AX + 1,AY - 1,Text);
     OutTextXY(AX - 1,AY + 1,Text);

     SetColor(ATextColor);
     OutTextXY(AX,AY,Text);
end;

function InputString(AX, AY, MaxLen: Integer; var AStr: string; ADisplay: Boolean): Boolean;
var Str: string;
    Pos: Integer;
    WindowWidth: Integer;
    WindowHeight: Integer;
    Buffer: Pointer;
    BufferSize: Word;
    OldSettings: ViewPortType;
    OldColor: Integer;

    procedure Draw;
    begin
         Bar(AX, AY, AX + WindowWidth, AY + WindowHeight);
         SetColor(15);
         Rectangle(AX, AY, AX + WindowWidth, AY + WindowHeight);
         OutTextXY(AX + 3, AY + 3, Str);
    end;

    procedure Display;
    var StrLen: Integer;
        S1,S2: String;
        I: Integer;
    begin
         Bar(AX + 1, AY + 1, AX + WindowWidth - 1, AY + WindowHeight - 1);
         if ADisplay
         then begin
              S1 := Copy(Str,1,Pos - 1);
              S2 := Copy(Str,Pos,Length(Str));
              SetColor(15);
              MoveTo(AX + 3, AY + 3);
              OutText(S1);
              SetColor(12);
              OutText('_');
              SetColor(15);
              OutText(S2);
              end
         else begin
              MoveTo(AX + 3, AY + 3);
              SetColor(15);
              for I := 1 to Pos - 1
              do OutText('*');
              SetColor(12);
              OutText('_');
              for I := Pos to Length(Str)
              do OutText('*');

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
     SetWriteMode(NormalPut);
     SetFillPattern(Solid, 0);
     WindowWidth := (MaxLen + 1) * TextWidth('W') + 4;
     WindowHeight := TextWidth('W') + 4;
     OldColor := GetColor;
     GetViewSettings(OldSettings);
     SetViewPort(0, 0, GetMaxX, GetMaxY, True);

     BufferSize := ImageSize(AX, AY, AX + WindowWidth, AY + WindowHeight);
     GetMem(Buffer,BufferSize);
     GetImage(AX, AY, AX + WindowWidth, AY + WindowHeight, Buffer^);
     if (Length(AStr) <= MaxLen)
     then Str := AStr
     else Str := Copy(AStr,1,MaxLen);
     Pos := Length(Str) + 1;
     Draw;
     Display;
     InputString := Edit;
     PutImage(AX,AY, Buffer^,NormalPut);
     FreeMem(Buffer,BufferSize);
     SetViewPort(OldSettings.X1, OldSettings.Y1, OldSettings.X2, OldSettings.Y2, OldSettings.Clip);
     SetColor(OldColor);

     {ShowMouse;}
end;

function GetOption( AXPos, AYPos: Integer; AAllign: Integer;
                    ATextColor, ABackColor: Integer; AOptions: string; ADefault: Integer): Integer;
{const MENUFRAMECOLOR = 15;
      MENUBACKCOLOR  = 9;
      MENUITEMCOLOR  = 15;
      MENUACTIVECOLOR= 12;}
const MENUFRAMECOLOR   = 15;
      MENUBACKCOLOR    = 12;
      MENUITEMCOLOR    = 14;
      MENUACTIVECOLOR  = 15;
      MENUSHADOWNCOLOR = 0;

var I: Integer;
    StrLength: Integer;
    MaxLength: Integer;
    CurrentLength: Integer;
    OldSettings: ViewPortType;
    OldColor: Integer;

    XPos: Integer;
    YPos: Integer;
    ShadowOffset: Integer;
    MenuWidth,
    MenuHeight,
    FrameWidth: Integer;
    ItemWidth: Integer;
    ItemHeight: Integer;
    ItemsOriginX: Integer;
    ItemsOriginY: Integer;
    ItemsCount: Integer;
    ItemsHole: Integer;

    BufferSize: Word;
    Buffer: Pointer;

    procedure DisplayOptions;
    var I1, I2, I3: Integer;
        S: string;
        CrrentOriginY: Integer;
    begin
         SetColor( MENUFRAMECOLOR);
         SetFillPattern( Solid, MENUSHADOWNCOLOR);
         Bar( XPos + ShadowOffset, YPos + ShadowOffset, XPos + MenuWidth + ShadowOffset, YPos + MenuHeight + ShadowOffset);
         {SetFillPattern( Solid, MENUBACKCOLOR);}
         SetFillPattern( Solid, ABackColor);
         Bar( XPos, YPos, XPos + MenuWidth, YPos + MenuHeight);
         Rectangle( XPos, YPos, XPos + MenuWidth, YPos + MenuHeight);
         Rectangle( XPos + 1, YPos + 1, XPos + MenuWidth - 1, YPos + MenuHeight - 1);
         Rectangle( XPos + 3, YPos + 3, XPos + MenuWidth - 3, YPos + MenuHeight - 3);
         {SetColor( MENUITEMCOLOR);}
         SetColor(ATextColor);
         I1 := 1;
         I3 := 0;
         S := '';
         CrrentOriginY := ItemsOriginY;
         repeat
            if (( AOptions[I1] <> #0) and (I1 < StrLength))
            then S := S + AOptions[I1]
            else begin
                 OutTextXY( ItemsOriginX , CrrentOriginY , S);
                 CrrentOriginY := CrrentOriginY + ItemHeight + ItemsHole;
                 I3 := I3 + 1;
                 S := '';
                 end;
            I1 := I1 + 1;
         until ( I1 > StrLength);
         I2 := I1;
    end;

    procedure DrawActiveFrame( AItemIndex: Integer; AActive: Boolean);
    begin
         if AActive
         then SetColor(MENUACTIVECOLOR)
         else SetColor(ABackColor);

         Rectangle( ItemsOriginX - 3,
                    ItemsOriginY + (AItemIndex  - 1) * (ItemHeight + ItemsHole) - 3,
                    ItemsOriginX + ItemWidth + 2,
                    ItemsOriginY + (AItemIndex  - 1) * (ItemHeight + ItemsHole) + ItemHeight + 2);
         Rectangle( ItemsOriginX - 5,
                    ItemsOriginY + (AItemIndex  - 1) * (ItemHeight + ItemsHole) - 5,
                    ItemsOriginX + ItemWidth + 4,
                    ItemsOriginY + (AItemIndex  - 1) * (ItemHeight + ItemsHole) + ItemHeight + 4);
    end;

    function Select: Integer;
    var CurrentItem: Integer;
        Key: Char;
    begin
         if ((ADefault > 0) and (ADefault <= ItemsCount))
         then CurrentItem := ADefault
         else CurrentItem := 1;
         DrawActiveFrame(CurrentItem, True);
         while True
         do begin
            Key := ReadKey;
            case Key
            of #0: begin
                   Key := ReadKey;
                   case Key
                   of #80: if (CurrentItem < ItemsCount)
                           then begin
                                DrawActiveFrame(CurrentItem, False);
                                CurrentItem := CurrentItem + 1;
                                DrawActiveFrame(CurrentItem, True);
                                end;
                      #72: if (CurrentItem > 1)
                           then begin
                                DrawActiveFrame(CurrentItem, False);
                                CurrentItem := CurrentItem - 1;
                                DrawActiveFrame(CurrentItem, True);
                                end;
                      end;
                   end;

               #13: Break;
               #27: begin
                    CurrentItem := 0;
                    Break;
                    end;
               end;
            end;
         Select := CurrentItem;
    end;
begin
     StrLength := Length(AOptions);
     if (StrLength > 0)
     then begin
          MaxLength := 0;
          CurrentLength := 0;
          I := 0;
          ItemsCount := 0;
          while (StrLength > I)
          do begin
             I := I + 1;
             if ((AOptions[I] = #0) or (I = StrLength))
             then begin
                  if (MaxLength < CurrentLength)
                  then MaxLength := CurrentLength;
                  CurrentLength := 0;
                  ItemsCount := ItemsCount + 1;
                  end
             else CurrentLength := CurrentLength + 1;
             end;

          ShadowOffset := 4;
          FrameWidth := 20;
          ItemsHole := 8;
          ItemWidth := TextWidth('W') * MaxLength;
          ItemHeight := TextHeight('W');
          MenuWidth := ItemWidth + FrameWidth * 2;
          MenuHeight := (ItemHeight + ItemsHole) * ItemsCount - ItemsHole + FrameWidth * 2;
          case AAllign
          of 2: begin
                XPos := AXPos - MenuWidth;
                YPos := AYPos;
                end;
             3: begin
                XPos := AXPos - MenuWidth;
                YPos := AYPos - MenuHeight;
                end;
             4: begin
                XPos := AXPos;
                YPos := AYPos - MenuHeight;
                end
          else
              XPos := AXPos;
              YPos := AYPos;
              end;

          ItemsOriginX := XPos + FrameWidth;
          ItemsOriginY := YPos + FrameWidth;

          BufferSize := ImageSize( XPos, YPos, XPos + MenuWidth + ShadowOffset, YPos + MenuHeight + ShadowOffset);
          OldColor := GetColor;
          GetViewSettings(OldSettings);
          SetViewPort(0, 0, GetMaxX, GetMaxY, True);
          GetMem(Buffer,BufferSize);
          GetImage( XPos, YPos, XPos + MenuWidth + ShadowOffset, YPos + MenuHeight + ShadowOffset, Buffer^);
          DisplayOptions;

          GetOption := Select;
          PutImage( XPos, YPos, Buffer^, NormalPut);
          FreeMem(Buffer, BufferSize);
          SetViewPort(OldSettings.X1, OldSettings.Y1, OldSettings.X2, OldSettings.Y2, OldSettings.Clip);
          SetColor(OldColor);
          end
     else GetOption := 0;
end;

function FileExists(AFName: string): Boolean;
var F: File;
begin
     Assign(F, AFName);
{$I-}
     Reset(F,1);
     if IOResult = 0
     then begin
          Close(F);
          FileExists := True;
          end
     else FileExists := False;
end;

procedure WarningBeep;
begin
     Sound(200);
     Delay(200);
     NoSound;
end;

procedure ErrorBeep;
begin
     Sound(500);
     Delay(200);
     NoSound;
end;

procedure OkBeep;
begin
     Sound(2000);
     Delay(30);
     NoSound;
end;

end.