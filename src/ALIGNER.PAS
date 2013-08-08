unit Aligner;

interface

uses WinTypes, WinProcs, OWindows, WIN31, Strings, Generics;

type
    TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient);

    PAligner = ^TAligner;
    TAligner = object(TGeneric)
       Align : TAlign;
       constructor Create(AAlign: TAlign);
       destructor Destroy; virtual;
       function GetAlignStyle: TAlign; virtual;
       function GetDim: Integer; virtual;
       procedure AlignItem(ARect: TRect); virtual;
       end;

    PWinndowAligner = ^TWinndowAligner;
    TWinndowAligner = object(TAligner)
       Window: HWND;
       Dim: Integer;
       constructor Create(AAlign: TAlign; AWindow: HWND; ADim: Integer);
       function GetDim: Integer; virtual;
       procedure AlignItem(ARect: TRect); virtual;
       end;

    PAlignHandler = ^TAlignHandler;
    TAlignHandler = object(TGeneric)
       Window: HWND;
       Items: TContainerCollection;
       FrameWidth: Integer;
       constructor Create(AWindow: HWND; AFrameWidth: Integer);
       destructor Destroy; virtual;
       procedure SetWindow(AWindow: HWND);
       procedure AlignItems;
       procedure InsertItem( AItem: PAligner);
       end;

implementation

constructor TAligner.Create(AAlign: TAlign);
begin
     inherited Create;
     Align := AAlign;
end;

destructor TAligner.Destroy;
begin
     inherited Destroy;
end;

function TAligner.GetAlignStyle: TAlign;
begin
     GetAlignStyle := Align;
end;

function TAligner.GetDim: Integer;
begin
     GetDim := 0;
end;

procedure TAligner.AlignItem(ARect: TRect);
begin
end;


constructor TWinndowAligner.Create(AAlign: TAlign; AWindow: HWND; ADim: Integer);
begin
     inherited Create(AAlign);
     Dim := ADim;
     Window := AWindow;
end;

function TWinndowAligner.GetDim: Integer;
begin
     GetDim := Dim;
end;

procedure TWinndowAligner.AlignItem(ARect: TRect);
begin
     if (Window <> 0)
     then MoveWindow(Window, ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top, True);
end;


constructor TAlignHandler.Create(AWindow: HWND; AFrameWidth: Integer);
begin
	 inherited Create;
     Window := AWindow;
     FrameWidth := AFrameWidth;
     Items.Create;
end;

destructor TAlignHandler.Destroy;
begin
     Items.Destroy;
     inherited Destroy;
end; 	

procedure TAlignHandler.SetWindow(AWindow: HWND);
begin
     Window := AWindow;
end;

procedure TAlignHandler.AlignItems;
var RemainRect: TRect;
    AlignRect: TRect;
    Item: PAligner;
    Dim: Integer;
begin
     if (Window <> 0)
     then begin
          GetClientRect(Window, RemainRect);
          RemainRect.Top := RemainRect.Top + FrameWidth;
          RemainRect.Left := RemainRect.Left + FrameWidth;
          RemainRect.Bottom := RemainRect.Bottom - FrameWidth;
          RemainRect.Right := RemainRect.Right - FrameWidth;

          Item := PAligner(Items.GetFirst);
		  while (Item <> nil)
		  do begin
             Dim := Item^.GetDim;
             if (Dim <> -1)
             then begin
                  case Item^.GetAlignStyle
                  of alTop: begin
                            AlignRect.Top := RemainRect.Top;
                            AlignRect.Bottom := RemainRect.Top + Dim;
                            AlignRect.Left := RemainRect.Left;
                            AlignRect.Right := RemainRect.Right;
                            RemainRect.Top := RemainRect.Top + Dim + FrameWidth;
                            Item^.AlignItem(AlignRect);
                            end;
                     alBottom: begin
                               AlignRect.Top := RemainRect.Bottom - Dim;
                               AlignRect.Bottom := RemainRect.Bottom;
                               AlignRect.Left := RemainRect.Left;
                               AlignRect.Right := RemainRect.Right;
                               RemainRect.Bottom := RemainRect.Bottom - Dim - FrameWidth;
                               Item^.AlignItem(AlignRect);
                               end;
                     alLeft: begin
                             AlignRect.Top := RemainRect.Top;
                             AlignRect.Bottom := RemainRect.Bottom;
                             AlignRect.Left := RemainRect.Left;
                             AlignRect.Right := RemainRect.Left + Dim;
                             RemainRect.Left := RemainRect.Left + Dim + FrameWidth;
                             Item^.AlignItem(AlignRect);
                             end;
                     alRight: begin
                              AlignRect.Top := RemainRect.Top;
                              AlignRect.Bottom := RemainRect.Bottom;
                              AlignRect.Left := RemainRect.Right - Dim;
                              AlignRect.Right := RemainRect.Right + Dim;
                              RemainRect.Right := RemainRect.Right - Dim - FrameWidth;
                              Item^.AlignItem(AlignRect);
                              end;
                     alClient: begin
                               Item^.AlignItem(RemainRect);
                               end;
                     alNone: begin
                             end;
                     end;
                  end;
             Item := PAligner(Items.GetNext);
             end;
          end;
end;

procedure TAlignHandler.InsertItem( AItem: PAligner);
begin
     if (AItem <> nil)
     then Items.PushLast( AItem);
end;

end.


end.
