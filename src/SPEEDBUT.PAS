unit SpeedButtons;

interface

uses WinTypes, WinProcs, OWindows, WIN31, Strings, Generics, Aligner;

const STATESCONT         = 3;
      WM_SPEEDBUTTON     = wm_User + $0001;

type

  PSpeedButton = ^TSpeedButton;
  TSpeedButton = object(TGeneric)
     private
     Bitmap: HBitmap;
     Origin: TPoint;
     Size: TPoint;
     Command: Word;
     Switch: Boolean;
     StatusText: PChar;
     Enabled: Boolean;
     Group: Integer;
     public
     constructor Create(AX, AY: Integer; ACommand: Word; AGroup: Integer; BitmapRes: PChar; AStatusText: PChar);
     destructor Destroy; virtual;
     procedure Draw(DC: HDC; State: Integer); virtual;
     function ContainsPoint(APoint: TPoint): Boolean;
     function GetStatusText: PChar; virtual;
     function GetCommand: Word; virtual;
     procedure GetSize(var ASize: TPoint); virtual;
     procedure GetPos(var APos: Tpoint); virtual;
     procedure Enable(AEnable: Boolean); virtual;
     procedure EnableGroup(AGroup: Integer; AEnable: Boolean); virtual;
     procedure EnableCommand(ACommand: Word; AEnable: Boolean); virtual;
     end;

  PSpeedBottonAligner = ^TSpeedBottonAligner;
  TSpeedBottonAligner = object(TAligner)
     Button: PSpeedButton;
     constructor Create(AAlign: TAlign; AButton: PSpeedButton);
     function GetDim: Integer; virtual;
     procedure AlignItem(ARect: TRect); virtual;
     end;

  PSpeedButtonsHandler = ^TSpeedButtonsHandler;
  TSpeedButtonsHandler = object(TGeneric)
     Buttons: TContainerCollection{PSpeedButton};
     ActiveButton: PSpeedButton;
     Window: HWND;
     TempDC: HDC;
     ActiveButtonState: Integer;

     constructor Create(AWindow: HWND);
     destructor Destroy; virtual;
     procedure Draw(DC: HDC); virtual;
     procedure Invalidate; virtual;
     procedure InsertButton(AButton: PSpeedButton); virtual;
     procedure EnableGroup(AGroup: Integer; AEnable: Boolean); virtual;
     procedure EnableCommand(ACommand: Word; AEnable: Boolean); virtual;
     procedure WMLButtonDown(var Msg:TMessage); virtual;
     procedure WMLButtonUp(var Msg:TMessage); virtual;
     procedure WMMouseMove(var Msg:TMessage); virtual;
     end;

  procedure DrawBitmap(ADC: HDC; AX, AY, AWidth, AHeight: Integer; ABitmap: HBitmap);

implementation


  procedure DrawBitmap(ADC: HDC; AX, AY, AWidth, AHeight: Integer; ABitmap: HBitmap);
  var OldBitmap: HBitmap;
      MemDC: HDC;
  begin
     if (ABitmap <> 0)
     then begin
          MemDC := CreateCompatibleDC(ADC);
          OldBitmap := SelectObject(MemDC, ABitmap);
          BitBlt(ADC ,AX, AY, AWidth, AHeight, MemDC, 0,0,SRCCOPY);
          SelectObject(MemDC, OldBitmap);
          DeleteDC(MemDC);
          end;
end;


constructor TSpeedButton.Create(AX, AY: Integer; ACommand: Word; AGroup: Integer; BitmapRes: PChar; AStatusText: PChar);
var BM: TBITMAP;
begin
     inherited Create;
     if (BitmapRes <> nil)
     then Bitmap := LoadBitmap(HInstance, BitmapRes)
     else Bitmap := 0;
     if (Bitmap <> 0)
     then begin
          GetObject(Bitmap, SizeOf(BM), @BM);
          Size.X := BM.bmWidth div STATESCONT;
          Size.Y := BM.bmHeight;
          end
     else begin
          Size.X := 0;
          Size.Y := 0;
          end;
     {Size.X := LOWORD(L) div STATESCONT;
     Size.Y := HIWORD(L);}
     Origin.X := AX;
     Origin.Y := AY;
     Command := ACommand;
     Group := AGroup;
     Enabled := True;
     Switch := False;
     if (AStatusText <> nil)
     then StatusText := StrNew(AStatusText)
     else StatusText := nil;
end;

destructor TSpeedButton.Destroy;
begin
     DeleteObject(Bitmap);
     if (StatusText <> nil)
     then StrDispose(StatusText);
     inherited Destroy;
end;

procedure TSpeedButton.Draw(DC: HDC; State: Integer);
var OldBitmap: HBitmap;
    MemDC: HDC;
begin
     if (Bitmap <> 0)
     then begin
          MemDC := CreateCompatibleDC(DC);
          OldBitmap := SelectObject(MemDC, Bitmap);
          if Enabled
          then BitBlt(DC ,Origin.X,Origin.Y,Size.X,Size.Y,MemDC,Size.X * State,0,SRCCOPY)
          else BitBlt(DC ,Origin.X,Origin.Y,Size.X,Size.Y,MemDC,Size.X * 2,0,SRCCOPY);
          SelectObject(MemDC, OldBitmap);
          DeleteDC(MemDC);
          end;
end;

function TSpeedButton.ContainsPoint(APoint: TPoint): Boolean;
begin
     ContainsPoint := Enabled and ((APoint.X >= Origin.X)
                      and (APoint.Y >= Origin.Y)
                      and (APoint.X < (Origin.X + Size.X))
                      and (APoint.Y < (Origin.Y + Size.Y)));
end;

function TSpeedButton.GetCommand: Word;
begin
     GetCommand := Command;
end;

function TSpeedButton.GetStatusText: PChar;
begin
     GetStatusText := StatusText;
end;

procedure TSpeedButton.GetSize(var ASize: TPoint);
begin
     ASize := Size;
end;

procedure TSpeedButton.GetPos(var APos: Tpoint);
begin
     APos := Origin;
end;

procedure TSpeedButton.Enable(AEnable: Boolean);
begin
     Enabled := AEnable;
end;

procedure TSpeedButton.EnableGroup(AGroup: Integer; AEnable: Boolean);
begin
     if (Group = AGroup)
     then Enabled := AEnable;
end;

procedure TSpeedButton.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (Command = ACommand)
     then Enabled := AEnable;
end;


constructor TSpeedBottonAligner.Create(AAlign: TAlign; AButton: PSpeedButton);
begin
     inherited Create(AAlign);
     Button := AButton;
end;

function TSpeedBottonAligner.GetDim: Integer;
begin
     if (Button <> nil)
     then begin
          case Align
          of alTop,
             alBottom: GetDim := Button^.Size.Y;
             alLeft,
             alRight: GetDim := Button^.Size.X;
             else
             GetDim := 0;
             end;
          end
     else GetDim := -1;
end;

procedure TSpeedBottonAligner.AlignItem(ARect: TRect);
begin
     if (Button <> nil)
     then begin
          Button^.Origin.X := ARect.Left;
          Button^.Origin.Y := ARect.Top;
          end;
end;


constructor TSpeedButtonsHandler.Create(AWindow: HWND);
begin
     inherited Create;
     Buttons.Create;
     ActiveButton := nil;
     Window := AWindow;
     TempDC := 0;
end;

destructor TSpeedButtonsHandler.Destroy;
begin
     Buttons.Destroy;
     inherited Destroy;
end;

procedure TSpeedButtonsHandler.Draw(DC: HDC);
var TempButton: PSpeedButton;
begin
     TempButton := PSpeedButton(Buttons.GetFirst);
     while (TempButton <> nil)
     do begin
        TempButton^.Draw(DC,0);
        TempButton := PSpeedButton(Buttons.GetNext);
        end;
end;

procedure TSpeedButtonsHandler.Invalidate;
begin
     if (Window <> 0)
     then InvalidateRect(Window, nil, False);
end;

procedure TSpeedButtonsHandler.InsertButton(AButton: PSpeedButton);
begin
     if (AButton <> nil)
     then begin
          Buttons.PushLast(AButton);
          Invalidate;
          end;
end;

procedure TSpeedButtonsHandler.EnableGroup(AGroup: Integer; AEnable: Boolean);
var TempButton: PSpeedButton;
begin
     TempButton := PSpeedButton(Buttons.GetFirst);
     while (TempButton <> nil)
     do begin
        TempButton^.EnableGroup(AGroup, AEnable);
        TempButton := PSpeedButton(Buttons.GetNext);
        end;
     Invalidate;
end;

procedure TSpeedButtonsHandler.EnableCommand(ACommand: Word; AEnable: Boolean);
var TempButton: PSpeedButton;
begin
     TempButton := PSpeedButton(Buttons.GetFirst);
     while (TempButton <> nil)
     do begin
        TempButton^.EnableCommand(ACommand, AEnable);
        TempButton := PSpeedButton(Buttons.GetNext);
        end;
     Invalidate;
end;

procedure TSpeedButtonsHandler.WMLButtonDown(var Msg:TMessage);
var Pos: TPoint;
    TempButton: PSpeedButton;
    Found: Boolean;
begin
     TempButton := PSpeedButton(Buttons.GetLast);
     if (TempButton <> nil)
     then begin
          Pos.X := LOWORD(Msg.LParam);
          Pos.Y := HIWORD(Msg.LParam);
          Found := False;
          repeat
                if TempButton^.ContainsPoint(Pos)
                then begin
                     Found := True;
                     Break;
                     end
                else TempButton := PSpeedButton(Buttons.GetPrev);
          until (TempButton = nil);
          if Found
          then begin
               ActiveButton := TempButton;
               TempDC := GetDC(Window);
               ActiveButton^.Draw(TempDC, 1);
               ActiveButtonState := 1;
               SetCapture(Window);
               end;
          end;
end;

procedure TSpeedButtonsHandler.WMLButtonUp(var Msg:TMessage);
var Pos: TPoint;
    Command: Word;
begin
     if (ActiveButton <> nil)
     then begin
          Pos.X := LOWORD(Msg.LParam);
          Pos.Y := HIWORD(Msg.LParam);
          ReleaseCapture;
          ActiveButton^.Draw(TempDC, 0);
          ActiveButtonState := 0;
          ReleaseDC(Window, TempDC);
          if ActiveButton^.ContainsPoint(Pos)
          then begin
               Command := ActiveButton^.GetCommand;
               SendMessage(Window, WM_SPEEDBUTTON, Command, 0);
               end;
          ActiveButton := nil;
          end;
end;

procedure TSpeedButtonsHandler.WMMouseMove(var Msg:TMessage);
var Pos: TPoint;
begin
     if (ActiveButton <> nil)
     then begin
          Pos.X := LOWORD(Msg.LParam);
          Pos.Y := HIWORD(Msg.LParam);
          if ActiveButton^.ContainsPoint(Pos)
          then begin
               if (ActiveButtonState <> 1)
               then begin
                    ActiveButton^.Draw(TempDC, 1);
                    ActiveButtonState := 1;
                    end;
               end
          else begin
               if (ActiveButtonState <> 0)
               then begin
                    ActiveButton^.Draw(TempDC, 0);
                    ActiveButtonState := 0;
                    end;
               end;
          end;
end;

end.