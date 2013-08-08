program ZIGZAG;

uses WinTypes, WinProcs, OWindows, WIN31,
     Canvas1, Canvas2, Aligner, WinCrt,
     Streams, Strings, OStdDlgs, DlgBoxes;

const STATUSLINEWIDTH = 40;


type

    TFileName = array[0..100] of Char;
{$R ZIGZAG.RES}

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

    {PMyFileDialog = ^TMyFileDialog;
    TMyFileDialog = object(TFileDialog)
       constructor Init(AParent: PWindowsObject;  AResName, AMask: PChar);
       end;

    constructor TMyFileDialog.Init(AParent: PWindowsObject; AResName, AMask: PChar);
    begin
         inherited Init(AParent, AResName, AMask);

    end;}


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

type

    TThisApplication = object(TApplication)
      procedure InitMainWindow;virtual;
    end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

    PApplicationWindow = ^TApplicationWindow;
    TApplicationWindow = object(TWindow)
       Canvas: PCanvasWindow;
       CanvasStatus: PCanvasStatusWindow;
       CanvasTools: PCanvasToolsWindow;
       Aligner: PAlignHandler;
       DrawnFilename: TFileName;
       ControlFilename: TFileName;
       DrawnFileNameDetermined: Boolean;

       constructor Init;
       procedure SetupWindow; virtual;
       destructor Done; virtual;
       function GetClassName: PChar; virtual;
       procedure GetWindowClass(var WndClass: TWndClass); virtual;
       procedure WMRButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_RButtonDown;
       procedure WMLButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_LButtonDown;
       procedure WMLButtonUp(var Msg:TMessage);
                 virtual wm_First + wm_LButtonUp;
       procedure WMMouseMove(var Msg:TMessage);
                 virtual wm_First + wm_MouseMove;
       procedure WMChar(var Msg: TMessage);
                 virtual wm_First + WM_CHAR;
       procedure WMPaint(var Msg: TMessage);
                 virtual wm_First + wm_Paint;
       procedure WMSize(var Msg:TMessage);
                 virtual wm_First + wm_Size;
       procedure Open(var Msg:TMessage);
                 virtual cm_First + 101;
       procedure OpenAsSymbol(var Msg:TMessage);
                 virtual cm_First + 107;
       procedure NewDrawn(var Msg:TMessage);
                 virtual cm_First + 102;
       procedure Save(var Msg:TMessage);
                 virtual cm_First + 103;
       procedure SaveAs(var Msg:TMessage);
                 virtual cm_First + 104;
       procedure GenerateOutput(var Msg:TMessage);
                 virtual cm_First + 105;
       procedure ExitApp(var Msg:TMessage);
                 virtual cm_First + 106;
       procedure About(var Msg:TMessage);
                 virtual cm_First + 200;
       function CanClose: Boolean; virtual;

       procedure UpdateWindowTitle;
       end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

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

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

    procedure TThisApplication.InitMainWindow;
    begin
         MainWindow := New(PApplicationWindow,Init);
    end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}


    constructor TApplicationWindow.Init;
    begin
         inherited Init(nil,'ZIGZAG');

         Attr.ExStyle := Attr.ExStyle or $00004000;

         Canvas := New(PCanvasWindow, Init(@Self));
         CanvasStatus := New(PCanvasStatusWindow, Init(@Self, Canvas));
         CanvasTools := New(PCanvasToolsWindow, Init(@Self, Canvas));
         StrCopy(@DrawnFilename, 'NONAME.ZIG');
         StrCopy(@ControlFilename, 'NONAME.ZCD');
         DrawnFileNameDetermined := False;
    end;

    function TApplicationWindow.GetClassName: PChar;
    begin
         GetClassName := 'ZigZagWindow';
    end;

    procedure TApplicationWindow.GetWindowClass(var WndClass: TWndClass);
    begin
         inherited GetWindowClass(WndClass);
         WndClass.lpszMenuName := 'MAINMENU';
         WndClass.hIcon := LoadIcon(hInstance, 'APPICON');
         WndClass.hbrBackGround := CreateSolidBrush(RGB(0,0,0));
    end;

    procedure TApplicationWindow.SetupWindow;
    begin
         inherited SetupWindow;
         Aligner := New(PAlignHandler, Create(HWindow, 1));
         Aligner^.InsertItem(New(PWinndowAligner, Create(alBottom, CanvasStatus^.HWindow,40)));
         Aligner^.InsertItem(New(PWinndowAligner, Create(alTop, CanvasTools^.HWindow,32)));
         Aligner^.InsertItem(New(PWinndowAligner, Create(alClient, Canvas^.HWindow, 0)));
         Aligner^.AlignItems;
         UpdateWindowTitle;
    end;

    destructor TApplicationWindow.Done;
    begin
         Aligner^.Free;
         inherited Done;
    end;

    procedure TApplicationWindow.WMRButtonDown(var Msg:TMessage);
    begin
    end;

    procedure TApplicationWindow.WMLButtonDown(var Msg: TMessage);
    begin
    end;

    procedure TApplicationWindow.WMLButtonUp(var Msg: TMessage);
    begin
    end;

    procedure TApplicationWindow.WMMouseMove(var Msg: TMessage);
    begin
    end;

    procedure TApplicationWindow.WMChar(var Msg: TMessage);
    begin
    end;

    procedure TApplicationWindow.WMPaint(var Msg: TMessage);
    var DC: HDC;
        PaintStruct: TPaintStruct;
    begin
         DC := BeginPaint(HWindow, PaintStruct);
         EndPaint(HWindow, PaintStruct);
    end;

    procedure TApplicationWindow.WMSize(var Msg:TMessage);
    begin
         Aligner^.AlignItems;
    end;

    procedure TApplicationWindow.Open(var Msg:TMessage);
    var Stream: PFileStream;
        TempFileName: TFileName;
    begin
         if (Canvas = nil)
         then Exit
         else if Canvas^.CanvasDrag = nil
              then Exit;

         if Canvas^.CanvasDrag^.Modifyed
         then begin
              case MessageBox( HWindow, 'Â·  Êœ Õ›Ÿ «· €ÌÌ—«  ›Ì „·›ø', 'ZIGZAG', MB_YESNOCANCEL or mb_ICONQUESTION
                                                                                  or $0400 or $0800)
              of IDCANCEL: begin
                           Exit;
                           end;
                 IDYES: begin
                        SaveAs(Msg);
                        if Canvas^.CanvasDrag^.Modifyed = True
                        then Exit;
                        end;
                 IDNO: begin
                       end;
                 else
                     exit;
                 end;
              end;

         StrCopy(@TempFileName, '*.ZIG');
         if (Application^.ExecDialog( New(PFileDialog,
            Init(@Self, PChar(sd_FileOpen), @TempFileName))) = id_Ok)
         then begin
              if FileExists(StrPas(@TempFileName))
              then begin
                   Canvas^.CanvasDrag^.Clear;
                   Stream := New(PFileStream, Create(StrPas(@TempFileName)));
                   Canvas^.CanvasDrag^.LoadFromStream(Stream);
                   Stream^.Free;
                   Canvas^.CanvasDrag^.RefreshFromChilds(True);
                   DrawnFilename := TempFileName;
                   DrawnFileNameDetermined := True;
                   UpdateWindowTitle;
                   end
              else MessageBox(HWindow, '·„ Ì „ «·⁄ÀÊ— ⁄·Ï «·„·›','ZIGZAG',mb_Ok or mb_IconHand or $0400 or $0800);
              end;
    end;

    procedure TApplicationWindow.OpenAsSymbol(var Msg:TMessage);
    var Stream: PFileStream;
        TempFileName: TFileName;
    begin
         if (Canvas = nil)
         then Exit;

         StrCopy(@TempFileName, '*.ZIG');
         if (Application^.ExecDialog( New(PFileDialog,
            Init(@Self, PChar(sd_FileOpen), @TempFileName))) = id_Ok)
         then begin
              if FileExists(StrPas(@TempFileName))
              then begin
                   Stream := New(PFileStream, Create(StrPas(@TempFileName)));
                   Canvas^.CanvasDrag^.LoadFromStreamAsSymbol(Stream);
                   Stream^.Free;
                   Canvas^.CanvasDrag^.RefreshFromChilds(True);
                   UpdateWindowTitle;
                   end
              else MessageBox(HWindow, '·„ Ì „ «·⁄ÀÊ— ⁄·Ï «·„·›','ZIGZAG',mb_Ok or mb_IconHand or $0400 or $0800);
              end;
    end;

    procedure TApplicationWindow.NewDrawn(var Msg:TMessage);
    begin
         if Canvas^.CanvasDrag^.Modifyed
         then begin
              case MessageBox( HWindow, 'Â·  Êœ Õ›Ÿ «· €ÌÌ—«  ›Ì „·›ø', 'ZIGZAG', MB_YESNOCANCEL or mb_ICONQUESTION
                                                                                  or $0400 or $0800)
              of IDCANCEL: begin
                           Exit;
                           end;
                 IDYES: begin
                        SaveAs(Msg);
                        if Canvas^.CanvasDrag^.Modifyed = True
                        then Exit;
                        end;
                 IDNO: begin
                       end;
                 else
                     exit;
                 end;
              end;

         StrCopy(@DrawnFilename, 'NONAME.ZIG');
         DrawnFileNameDetermined := False;
         if (Canvas <> nil)
         then begin
              Canvas^.CanvasDrag^.Clear;
              Canvas^.CanvasDrag^.RefreshFromChilds(True);
              end;
         UpdateWindowTitle;
    end;

    procedure TApplicationWindow.Save(var Msg:TMessage);
    var Stream: PFileStream;

    begin
         if (Canvas <> nil)
         then begin
              if DrawnFileNameDetermined
              then begin
                   Stream := New(PFileStream, Create(DrawnFilename));
                   Stream^.Reset;
                   Canvas^.CanvasDrag^.WriteToStream(Stream);
                   Stream^.Free;
                   end
              else SaveAs(Msg);
              end;
    end;

    procedure TApplicationWindow.SaveAs(var Msg:TMessage);
    var Stream: PFileStream;
        TempFileName: TFileName;
    begin
         if (Canvas = nil)
         then Exit;
         TempFileName := DrawnFilename;
         if (Application^.ExecDialog( New(PFileDialog,
            Init(@Self, PChar(sd_FileSave), @TempFileName))) = id_Ok)
         then begin
              if FileExists(StrPas(@TempFileName))
              then if (MessageBox(HWindow, 'Â·  Êœ «” »œ«· «·„·› «·”«»ﬁø','ZIGZAG', MB_YESNO or MB_ICONQUESTION
                                                                                    or $0400 or $0800) = IDNO)
                   then exit;
              Stream := New(PFileStream, Create(StrPas(@TempFileName)));
              Stream^.Reset;
              Canvas^.CanvasDrag^.WriteToStream(Stream);
              Stream^.Free;
              DrawnFilename := TempFileName;
              DrawnFileNameDetermined := True;
              UpdateWindowTitle;
              end;
    end;

    procedure TApplicationWindow.GenerateOutput(var Msg:TMessage);
    var Stream: PFileStream;
        TempFileName: TFileName;
    begin
         if (Canvas = nil)
         then Exit;
         TempFileName := ControlFilename;
         if (Application^.ExecDialog( New(PFileDialog,
            Init(@Self, PChar(sd_FileSave), @TempFileName))) = id_Ok)
         then begin
              Stream := New(PFileStream, Create(StrPas(@TempFileName)));
              Stream^.Reset;
              Canvas^.CanvasDrag^.GenerateOtputToStream(Stream);
              Stream^.Free;
              ControlFilename := TempFileName;
              end;
    end;


    function TApplicationWindow.CanClose: Boolean;
    var Msg: TMessage;
    begin
         CanClose := True;

         if (Canvas = nil)
         then Exit
         else if Canvas^.CanvasDrag = nil
              then Exit;

         if Canvas^.CanvasDrag^.Modifyed
         then begin
              case MessageBox( HWindow, 'Â·  Êœ Õ›Ÿ «· €ÌÌ—«  ›Ì „·›ø', 'ZIGZAG', MB_YESNOCANCEL or mb_ICONQUESTION
                                                                                  or $0400 or $0800)
              of IDCANCEL: CanClose := False;
                 IDYES: begin
                        FillChar(Msg, SizeOf(Msg), #0);
                        SaveAs(Msg);
                        if Canvas^.CanvasDrag^.Modifyed = True
                        then CanClose := False;
                        end;
                 IDNO: begin
                       end;
                 else
                     CanClose := False;
                 end;
              end;
    end;

    procedure TApplicationWindow.ExitApp(var Msg:TMessage);
    begin
         CloseWindow;
    end;

    procedure TApplicationWindow.About(var Msg:TMessage);
    begin
         ShowAboutDialog(@Self);
    end;

    procedure TApplicationWindow.UpdateWindowTitle;
    var Title: array [0..255] of Char;
    begin
         StrCopy(@Title, 'ZIGZAG - [ ');
         StrCat(@Title, @DrawnFilename);
         StrCat(@Title, ' ]');

         SetWindowText(HWindow, @Title);
    end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

var
   App : TThisApplication;
begin
     App.Init('Program One');
     App.Run;
     App.Done;
end.
