unit DlgBoxes;

interface

uses WinTypes, WinProcs, OWindows, WIN31,
     Generics, SpeedButtons, Aligner, Streams,
     ODialogs, WinAPI, Strings, Show;

type Float = Double;
     PFloat = ^Float;

     PTwinPropertyRec = ^TTwinPropertyRec;
     TTwinPropertyRec = record
        Densety: Float;
        StepMode: Integer;
        StepLength: Float;
        StepsCount: Longint;
        end;

     PTwinEditorBox = ^TTwinEditorBox;
     TTwinEditorBox = object(TDialog)
        DensityEdit: PEdit;
        FixedCount: PRadioButton;
        FixedLength: PRadioButton;
        StepLengthEdit: PEdit;
        StepCountEdit: PEdit;
        Data: PTwinPropertyRec;
        constructor Init(AParent: PWindowsObject; AData: PTwinPropertyRec);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        procedure ApdateFieldsEnableState;
        procedure CheckFixedCount(var Msg: TMessage); virtual id_First + 102;
        procedure CheckFixedLength(var Msg: TMessage); virtual id_First + 103;
        end;

     PLinearPropertyRec = ^TLinearPropertyRec;
     TLinearPropertyRec = record
        Densety: Float;
        Width: Float;
        Mode: Word;
        end;

     PLinearEditorBox = ^TLinearEditorBox;
     TLinearEditorBox = object(TDialog)
        DensityEdit: PEdit;
        StepModeCheck1: PRadioButton;
        StepModeCheck2: PRadioButton;
        WidthEdit: PEdit;
        Data: PLinearPropertyRec;
        constructor Init(AParent: PWindowsObject; AData: PLinearPropertyRec);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        procedure CheckMode1(var Msg: TMessage); virtual id_First + 102;
        procedure CheckMode2(var Msg: TMessage); virtual id_First + 103;
        procedure UpdateView;
        end;

     PGuideLinesInfoRec = ^TGuideLinesInfoRec;
     TGuideLinesInfoRec = record
        Enabled: Boolean;
        VerticalSet: PContainerCollection;
        HorizontalSet: PContainerCollection;
        end;

     PGuideLine = ^TGuideLine;
     TGuideLine = object(TGeneric)
        LinePos: Float;
        end;

     PGuideLinesBox = ^TGuideLinesBox;
     TGuideLinesBox = object(TDialog)
        Data: PGuideLinesInfoRec;
        VerticalEdit: PEdit;
        VerticalList: PListBox;
        HorizontalEdit: PEdit;
        HorizontalList: PListBox;

        constructor Init(AParent: PWindowsObject; AData: PGuideLinesInfoRec);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        procedure SellectVertical(var Msg: TMessage); virtual id_First + 101;
        procedure SellectHorizontal(var Msg: TMessage); virtual id_First + 102;
        procedure AddVertical(var Msg: TMessage); virtual id_First + 105;
        procedure AddHorizontal(var Msg: TMessage); virtual id_First + 107;
        procedure RemoveVertical(var Msg: TMessage); virtual id_First + 106;
        procedure RemoveHorizontal(var Msg: TMessage); virtual id_First + 108;
        procedure RemoveAllVertical(var Msg: TMessage); virtual id_First + 109;
        procedure RemoveAllHorizontal(var Msg: TMessage); virtual id_First + 110;
        end;

     PArrayInfo = ^TArrayInfo;
     TArrayInfo = record
        case RepeatPath:(rpCircle, rpLine, rpPath)
        of rpCircle: ();
           rpLine: ();
           rpPath: ();
        end;

     PArrayBox = ^TArrayBox;
     TArrayBox = object(TDialog)
        Data: PArrayInfo;
        constructor Init(AParent: PWindowsObject; AData: PArrayInfo);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;

        procedure DisplayCircularInterface;
        procedure DisplayLinearInterface;
        procedure DisplayPathInterface;
        procedure CheckCircularInterface(var Msg: TMessage); virtual id_First + 101;
        procedure CheckLinearInterface(var Msg: TMessage); virtual id_First + 102;
        procedure CheckPathInterface(var Msg: TMessage); virtual id_First + 103;
        procedure CheckSetByMouse(var Msg: TMessage); virtual id_First + 202;
        end;

     PPolligonEditorBox = ^TPolligonEditorBox;
     TPolligonEditorBox = object(TDialog)
        end;

     PSequenceAction = ^TSequenceAction;
     TSequenceAction = (saNone, saMakeFirst, saMakeLast, saMoveForward, saMoveBack, saFlipPath);

     PSequenceBox = ^TSequenceBox;
     TSequenceBox = object(TDialog)
        Action: PSequenceAction;
        constructor Init(AParent: PWindowsObject; AAction: PSequenceAction);
        procedure Button1(var Msg: TMessage); virtual id_First + 101;
        procedure Button2(var Msg: TMessage); virtual id_First + 102;
        procedure Button3(var Msg: TMessage); virtual id_First + 103;
        procedure Button4(var Msg: TMessage); virtual id_First + 104;
        procedure Button5(var Msg: TMessage); virtual id_First + 105;
        end;

     PAllignAction = ^TAllignAction;
     TAllignAction = (aaNone, aaTop, aaBottom, aaLeft, aaRight, aaVerCenter, aaHorCenter);

     PAllignBox = ^TAllignBox;
     TAllignBox = object(TDialog)
        Action: PAllignAction;
        constructor Init(AParent: PWindowsObject; AAction: PAllignAction);
        procedure Button1(var Msg: TMessage); virtual id_First + 101;
        procedure Button2(var Msg: TMessage); virtual id_First + 102;
        procedure Button3(var Msg: TMessage); virtual id_First + 103;
        procedure Button4(var Msg: TMessage); virtual id_First + 104;
        procedure Button5(var Msg: TMessage); virtual id_First + 105;
        procedure Button6(var Msg: TMessage); virtual id_First + 106;
        end;


     POptionsRec = ^TOptionsRec;
     TOptionsRec = record
        DisplayGrid,
        Snap,
        DsiplayGuideLines: Boolean;
        GridSizeX,
        GridSizeY: Float;
        end;

     POptionsBox = ^TOptionsBox;
     TOptionsBox = object(TDialog)
        Data: POptionsRec;
        DisplayCheck: PCheckBox;
        SnapToGrid: PCheckBox;
        DisplayGuide: PCheckBox;
        SizeX: PEdit;
        SizeY: PEdit;
        constructor Init(AParent: PWindowsObject; AData: POptionsRec);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        end;

     PRotateBox = ^TRotateBox;
     TRotateBox = object(TDialog)
        Data: PFloat;
        AngleEdit: PEdit;
        constructor Init(AParent: PWindowsObject; AData: PFloat);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        end;

     PStreachData = ^TStreachData;
     TStreachData = record
        XSize,
        YSize: Float;
        end;

     PStreachBox = ^TStreachBox;
     TStreachBox = object(TDialog)
        Data: PStreachData;
        XSizeEdit: PEdit;
        YSizeEdit: PEdit;
        constructor Init(AParent: PWindowsObject; AData: PStreachData);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        end;

     TDrawObject = (doNone, doPolligon, doLine, doRectangle, doEllipse, doStopPoint, doBezier);
     PNewObjectData = ^TNewObjectData;
     TNewObjectData = record
        DrawObject: TDrawObject;
        X1,Y1,X2,Y2: Float;
        Count: Longint;
        UsingMouse: Boolean;
        end;


     PNewObjectBox = ^TNewObjectBox;
     TNewObjectBox = object(TDialog)
        Data: PNewObjectData;

        PolligonRadio: PRadioButton;
        SoftPolligonRadio: PRadioButton;
        LineRadio: PRadioButton;
        EllipseRadio: PRadioButton;
        RectangleRadio: PRadioButton;
        StopPointRadio: PRadioButton;
        UsingMouseCheck: PCheckBox;
        X1Edit: PEdit;
        Y1Edit: PEdit;
        X2Edit: PEdit;
        Y2Edit: PEdit;
        CountEdit: PEdit;

        constructor Init(AParent: PWindowsObject; AData: PNewObjectData);
        procedure SetupWindow; virtual;
        function LoadFields: Boolean;
        procedure SetFields;
        procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
        procedure UpdateView;

        procedure Check1(var Msg: TMessage); virtual id_First + 101;
        procedure Check2(var Msg: TMessage); virtual id_First + 102;
        procedure Check3(var Msg: TMessage); virtual id_First + 103;
        procedure Check4(var Msg: TMessage); virtual id_First + 104;
        procedure Check5(var Msg: TMessage); virtual id_First + 105;
        procedure Check6(var Msg: TMessage); virtual id_First + 110;
        end;

     PAboutBox = ^TAboutBox;
     TAboutBox = object(TDialog)
        Bitmap: HBitmap;
        constructor Init(AParent: PWindowsObject);
        destructor Done; virtual;
        procedure SetupWindow; virtual;
        procedure WMPaint(var Msg: TMessage); virtual wm_First + wm_Paint;
        procedure DrawAbout;
        end;

function EditTwinProperties(AParentWondow: PWindowsObject; var AProperties: TTwinPropertyRec): Boolean;
function EditLinearProperties(AParentWondow: PWindowsObject; var AProperties: TLinearPropertyRec): Boolean;
function EditGuideLines(AParentWondow: PWindowsObject; var AInfo: TGuideLinesInfoRec): Boolean;
function EditArray(AParentWondow: PWindowsObject; var AInfo: TArrayInfo): Boolean;
function GetSequenceAction(AParentWondow: PWindowsObject; var AAction: TSequenceAction; X, Y: Integer): Boolean;
function GetAllignAction(AParentWondow: PWindowsObject; var AAction: TAllignAction): Boolean;
function EditOptions(AParentWondow: PWindowsObject; var AOptions: TOptionsRec): Boolean;
function GetAngle(AParentWondow: PWindowsObject): Float;
function GetObjectData(AParentWondow: PWindowsObject; var AData: TNewObjectData): Boolean;
function GetStreachInfo(AParentWondow: PWindowsObject; var AData: TStreachData): Boolean;
procedure ShowAboutDialog(AParentWindow: PWindowsObject);

implementation

const



{TheAboutText : PChar = ' ’„Ì„ «· ÃÂÌ“« '#10
                          + '«·„Â‰œ” „Õ„œ Ã„«· √»Ê €œ… ’»«€'#10
                          + '«·„Â‰œ” Œ«·œ ⁄„— √»Ê €œ… ’»«€'#10
                          + 'Õ·» - ”Ê—Ì« - Â« › (021) 232979'#10#10
                          + '»—„Ã…'#10
                          + '«·„Â‰œ” —”·«‰ ﬂ›—Ì'#10
                          + 'Õ„«Â - ”Ê—Ì« - Â« › (033) 237297';
}

TheKey : array[1..10] of Byte = (10,200,1,15,33,44,255,100,2,26);
TheAboutText : PChar = #192#29#226#226#194#12#56#133#200
                       +#214#239#37#211#200#235#38#56#133
                       +#225#255#238#7#210#47#194#225#28
                       +#171#34#214#233#15#224#47#226#228
                       +#25#68#217#213#195#232#212#199#230
                       +#247#245#163#227#249#239#44#206#220
                       +#1#226#56#133#205#58#208#43#208
                       +#47#226#228#25#68#217#213#195#232
                       +#212#199#230#247#245#169#227#210#42
                       +#229#33#220#199#253#18#163#34#55
                       +#42#45#198#197#252#12#215#84#48
                       +#43#35#232#51#60#19#21#200#93
                       +#8#16#194#25#226#195#232#38#56
                       +#133#225#255#238#7#210#47#240#255
                       +#30#163#230#58#213#21#208#226#43
                       +#225#28#163#231#58#39#232#210#233
                       +#240#193#56#68#47#58#239#15#203
                       +#210#1#4#207#87#49#51#42#250
                       +#50#56#19#21#200;


procedure SetFloat(AEdit: PEdit; AFloat: Float; I,F: Integer);
var Buf: string;
begin
     Str(AFloat:I:F, Buf);
     Buf := Buf + #0;
     AEdit^.SetText(@Buf[1]);
end;

procedure SetInteger(AEdit: PEdit; AInteger: Longint);
var Buf: string;
begin
     Str(AInteger, Buf);
     Buf := Buf + #0;
     AEdit^.SetText(@Buf[1]);
end;


function GetFloat(AEdit: PEdit; var AFloat: Float; AMin, AMax: Float; AMend: Boolean): Boolean;
var Buf: string;
    Code: Integer;
begin
     AEdit^.GetText(@Buf[1], SizeOf(Buf) - 1);
     Buf[0] := Char(StrLen(@Buf[1]));
     Val(Buf, AFloat, Code);
     {if ((Code <> 0) or ((AMin <> AMax) and ((AFloat < AMin) or (AFloat > AMax))))
     then begin
          SetFocus(AEdit^.HWindow);
          MessageBeep(MB_OK);
          GetFloat := False
          end
     else GetFloat := True;}
     if (Code <> 0)
     then begin
          SetFocus(AEdit^.HWindow);
          MessageBeep(MB_OK);
          GetFloat := False
          end
     else begin
          GetFloat := True;
          if ((AMin <> AMax) and ((AFloat < AMin) or (AFloat > AMax)))
          then if AMend
               then begin
                    if AFloat < AMin
                    then AFloat := AMin
                    else AFloat := AMax;
                    end
               else begin
                    SetFocus(AEdit^.HWindow);
                    MessageBeep(MB_OK);
                    GetFloat := False;
                    end;
          end;
end;

function GetInteger(AEdit: PEdit; var AInteger: Longint; AMin, AMax: Longint; AMend: Boolean): Boolean;
var Buf: string;
    Code: Integer;
begin
     AEdit^.GetText(@Buf[1], SizeOf(Buf) - 1);
     Buf[0] := Char(StrLen(@Buf[1]));
     Val(Buf, AInteger, Code);
     if Code <> 0
     then begin
          SetFocus(AEdit^.HWindow);
          MessageBeep(MB_OK);
          GetInteger := False
          end
     else begin
          if (AInteger > AMax) or (AInteger < AMin)
          then begin
               if AMend
               then begin
                    if (AInteger > AMax)
                    then AInteger := AMax
                    else AInteger := AMin;
                    GetInteger := True;
                    end
               else begin
                    SetFocus( AEdit^.HWindow);
                    MessageBeep(MB_OK);
                    GetInteger := False;
                    end;
               end
          else GetInteger := True;
          end
end;

constructor TTwinEditorBox.Init(AParent: PWindowsObject; AData: PTwinPropertyRec);
begin
     inherited Init(AParent, 'DLG_TWINPROPERTY');

     DensityEdit := New(PEdit, InitResource(@Self, 101, 20));
     FixedCount := New(PRadioButton, InitResource(@Self, 102));
     FixedLength := New(PRadioButton, InitResource(@Self, 103));
     StepCountEdit :=  New(PEdit, InitResource(@Self, 104, 10));
     StepLengthEdit := New(PEdit, InitResource(@Self, 105, 20));

     Data := AData;
end;

procedure TTwinEditorBox.SetupWindow;
var Msg: TMessage;
begin
     inherited SetupWindow;
     SetFields;
end;

procedure TTwinEditorBox.ApdateFieldsEnableState;
begin
     if FixedCount^.GetCheck = bf_Checked
     then begin
          EnableWindow(StepLengthEdit^.HWindow, False);
          EnableWindow(StepCountEdit^.HWindow, True);
          end
     else if FixedLength^.GetCheck = bf_Checked
     then begin
          EnableWindow(StepLengthEdit^.HWindow, True);
          EnableWindow(StepCountEdit^.HWindow, False);
          end
     else begin
          EnableWindow(StepLengthEdit^.HWindow, False);
          EnableWindow(StepCountEdit^.HWindow, False);
          end;
end;

procedure TTwinEditorBox.CheckFixedCount(var Msg: TMessage);
begin
     ApdateFieldsEnableState;
end;

procedure TTwinEditorBox.CheckFixedLength(var Msg: TMessage);
begin
     ApdateFieldsEnableState;
end;

function TTwinEditorBox.LoadFields: Boolean;
var Buf: string;
    F1,F2: Float;
    L1: Longint;
    Mode: Integer;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(DensityEdit, F1, 0.5, 200, True)
          then Exit;
          if FixedCount^.GetCheck = bf_Checked
          then begin
               if not GetInteger(StepCountEdit, L1, 1, 300, True)
               then Exit;
               Mode := 1;
               end
          else if FixedLength^.GetCheck = bf_Checked
          then begin
               if not GetFloat(StepLengthEdit, F2, 1, 100, True)
               then Exit;
               Mode := 2;
               end
          else begin
               Mode := -1;
               Exit;
               end;
          Data^.Densety := F1;
          Data^.StepMode := Mode;
          case Mode
          of 1: Data^.StepsCount := L1;
             2: Data^.StepLength := F2;
             end;
          LoadFields := True;
          end
     else LoadFields := False;
end;

procedure TTwinEditorBox.SetFields;
begin
     if (Data <> nil)
     then begin
          SetFloat(DensityEdit, Data^.Densety, 1, 3);
          SetFloat(StepLengthEdit, Data^.StepLength, 1,3);
          SetInteger(StepCountEdit, Data^.StepsCount);
          case Data^.StepMode
          of 1: begin
                FixedCount^.SetCheck(1);
                FixedLength^.SetCheck(0);
                end;
             2: begin
                FixedCount^.SetCheck(0);
                FixedLength^.SetCheck(1);
                end
             else
                FixedCount^.SetCheck(1);
                FixedLength^.SetCheck(0);
             end;
          ApdateFieldsEnableState;
          end;
end;

procedure TTwinEditorBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;


function EditTwinProperties(AParentWondow: PWindowsObject; var AProperties: TTwinPropertyRec): Boolean;
var Dlg: PTwinEditorBox;
begin
     Dlg := New(PTwinEditorBox, Init(AParentWondow, @AProperties));
     Application^.ExecDialog(Dlg);
     EditTwinProperties := True;
end;


constructor TLinearEditorBox.Init(AParent: PWindowsObject; AData: PLinearPropertyRec);
begin
     inherited Init(AParent, 'DLG_LINEARPROPERTY');
     DensityEdit := New(PEdit, InitResource(@Self, 101, 20));
     StepModeCheck1 := New(PRadioButton, InitResource(@Self, 102));
     StepModeCheck2 := New(PRadioButton, InitResource(@Self, 103));
     WidthEdit := New(PEdit, InitResource(@Self, 104, 20));
     Data := AData;
end;

procedure TLinearEditorBox.SetupWindow;
var Msg: TMessage;
begin
     inherited SetupWindow;
     SetFields;
end;

procedure TLinearEditorBox.UpdateView;
begin
     if StepModeCheck1^.GetCheck = bf_Checked
     then begin
          EnableWindow(DensityEdit^.HWindow, True);
          EnableWindow(WidthEdit^.HWindow, True);
          end
     else if StepModeCheck2^.GetCheck = bf_Checked
     then begin
          EnableWindow(DensityEdit^.HWindow, True);
          EnableWindow(WidthEdit^.HWindow, False);
          end
     else begin
          EnableWindow(DensityEdit^.HWindow, False);
          EnableWindow(WidthEdit^.HWindow, False);
          end;
end;

procedure TLinearEditorBox.CheckMode1(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TLinearEditorBox.CheckMode2(var Msg: TMessage);
begin
     UpdateView;
end;

function TLinearEditorBox.LoadFields: Boolean;
var Buf: string;
    F1,F2: Float;
    Code: Integer;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(DensityEdit, F1, 0.5, 200, True)
          then Exit;
          if not GetFloat(WidthEdit, F2, 0, 500, True)
          then Exit;

          Data^.Densety := F1;
          Data^.Width := F2;

          if StepModeCheck1^.GetCheck = bf_Checked
          then Data^.Mode := 1
          else if StepModeCheck2^.GetCheck = bf_Checked
          then Data^.Mode := 2
          else Data^.Mode := 1;

          LoadFields := True;
          end
     else LoadFields := False;
end;

procedure TLinearEditorBox.SetFields;
begin
     if (Data <> nil)
     then begin
          SetFloat(DensityEdit, Data^.Densety, 1, 3);
          SetFloat(WidthEdit, Data^.Width, 1, 3);
          case Data^.Mode
          of 1: begin
                StepModeCheck1^.SetCheck(1);
                StepModeCheck2^.SetCheck(0);
                end;
             2: begin
                StepModeCheck1^.SetCheck(0);
                StepModeCheck2^.SetCheck(1);
                end;
             else
             StepModeCheck1^.SetCheck(1);
             end;
          end;
     UpdateView;
end;

procedure TLinearEditorBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;


function EditLinearProperties(AParentWondow: PWindowsObject; var AProperties: TLinearPropertyRec): Boolean;
var Dlg: PLinearEditorBox;
begin
     Dlg := New(PLinearEditorBox, Init(AParentWondow, @AProperties));
     Application^.ExecDialog(Dlg);
     EditLinearProperties := True;
end;


function EditGuideLines(AParentWondow: PWindowsObject; var AInfo: TGuideLinesInfoRec): Boolean;
var Dlg: PGuideLinesBox;
begin
     Dlg := New(PGuideLinesBox, Init(AParentWondow, @AInfo));
     Application^.ExecDialog(Dlg);
     EditGuideLines := True;
end;

function EditArray(AParentWondow: PWindowsObject; var AInfo: TArrayInfo): Boolean;
var Dlg: PArrayBox;
begin
     Dlg := New(PArrayBox, Init(AParentWondow, @AInfo));
     Application^.ExecDialog(Dlg);
     EditArray := True;
end;


constructor TGuideLinesBox.Init(AParent: PWindowsObject; AData: PGuideLinesInfoRec);
begin
     inherited Init(AParent, 'DLG_EDITGUIDELINES');
     VerticalEdit := New(PEdit, InitResource(@Self, 103, 20));
     VerticalList := New(PListBox, InitResource(@Self, 101));
     HorizontalEdit := New(PEdit, InitResource(@Self, 104, 20));;
     HorizontalList := New(PListBox, InitResource(@Self, 102));
     Data := AData;
end;

procedure TGuideLinesBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;

function TGuideLinesBox.LoadFields: Boolean;
     procedure LoadList(ASet: PContainerCollection; AListBox: PListBox);
     var TempGuide: PGuideLine;
         S: string;
         Count, Index: Integer;
         Code: Integer;
         LinePos: Float;
     begin
          if ((ASet = nil) or (AListBox = nil))
          then Exit;
          ASet^.Clear;
          Count := AListbox^.GetCount;
          if (Count > 0)
          then for Index := 0 to Count - 1
               do begin
                  AListbox^.GetString(@S[1],Index);
                  S[0] := Char(StrLen(@S[1]));
                  Val(S, LinePos, Code);
                  if (Code = 0)
                  then begin
                       TempGuide := New(PGuideLine, Create);
                       TempGuide^.LinePos := LinePos;
                       ASet^.Pushlast(TempGuide);
                       end;
                  end;
     end;
begin
     if (Data <> nil)
     then begin
          LoadList(Data^.VerticalSet, VerticalList);
          LoadList(Data^.HorizontalSet, HorizontalList);
          end;
     LoadFields := True;
end;

procedure TGuideLinesBox.SetFields;
    procedure FillList(ASet: PContainerCollection; AListBox: PListBox);
    var TempGuide: PGuideLine;
        S: string;
    begin
         if ((ASet = nil) or (AListBox = nil))
         then Exit;
         TempGuide := PGuideLine(ASet^.GetFirst);
         while (TempGuide <> nil)
         do begin
            Str(TempGuide^.LinePos:0:3, S);
            S := S + #0;
            AListBox^.AddString(@S[1]);
            TempGuide := PGuideLine(ASet^.GetNext);
            end;
    end;
begin
     if (Data <> nil)
     then begin
          FillList(Data^.VerticalSet, VerticalList);
          FillList(Data^.HorizontalSet, HorizontalList);
          end;
end;

procedure TGuideLinesBox.SellectVertical(var Msg: TMessage);
var S: string;
    Index: Integer;
begin
     Index := VerticalList^.GetSelIndex;
     if (Index >= 0)
     then begin
          VerticalList^.GetString(@S[1], Index);
          VerticalEdit^.SetText(@S[1]);
          end;
end;

procedure TGuideLinesBox.SellectHorizontal(var Msg: TMessage);
var S: string;
    Index: Integer;
begin
     Index := HorizontalList^.GetSelIndex;
     if (Index >= 0)
     then begin
          HorizontalList^.GetString(@S[1], Index);
          HorizontalEdit^.SetText(@S[1]);
          end;
end;

procedure TGuideLinesBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;

procedure TGuideLinesBox.AddVertical(var Msg: TMessage);
var NewLinePos: Float;
    S: string;
begin
     if GetFloat(VerticalEdit, NewLinePos, 0, 0, True)
     then begin
          Str(NewLinePos:0:3, S);
          S := S + #0;
          VerticalList^.AddString(@S[1]);
          VerticalEdit^.Clear;
          end
     else MessageBeep(mb_iconhand);
     SetFocus(VerticalEdit^.HWindow);
end;

procedure TGuideLinesBox.AddHorizontal(var Msg: TMessage);
var NewLinePos: Float;
    S: string;
begin
     if GetFloat(HorizontalEdit, NewLinePos, 0, 0, True)
     then begin
          Str(NewLinePos:0:3, S);
          S := S + #0;
          HorizontalList^.AddString(@S[1]);
          HorizontalEdit^.Clear;
          end
     else MessageBeep(mb_iconhand);
     SetFocus(HorizontalEdit^.HWindow);
end;

procedure TGuideLinesBox.RemoveVertical(var Msg: TMessage);
var Index: Integer;
begin
     Index := VerticalList^.GetSelIndex;
     if (Index >= 0)
     then VerticalList^.DeleteString(Index);
end;

procedure TGuideLinesBox.RemoveHorizontal(var Msg: TMessage);
var Index: Integer;
begin
     Index := HorizontalList^.GetSelIndex;
     if (Index >= 0)
     then HorizontalList^.DeleteString(Index);
end;

procedure TGuideLinesBox.RemoveAllVertical(var Msg: TMessage);
begin
     VerticalList^.ClearList;
end;

procedure TGuideLinesBox.RemoveAllHorizontal(var Msg: TMessage);
begin
     HorizontalList^.ClearList;
end;


constructor TArrayBox.Init(AParent: PWindowsObject; AData: PArrayInfo);
begin
     inherited Init(AParent, 'DLG_ARRAY');
     Data := AData;
end;

procedure TArrayBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;

function TArrayBox.LoadFields: Boolean;
begin
     LoadFields := True;
end;

procedure TArrayBox.SetFields;
begin
     DisplayCircularInterface;
end;

procedure TArrayBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;

procedure TArrayBox.DisplayCircularInterface;
begin
     SendMessage(GetDlgItem(HWindow, 101), BM_SETCHECK, 1, 0);
     SendMessage(GetDlgItem(HWindow, 102), BM_SETCHECK, 0, 0);
     SendMessage(GetDlgItem(HWindow, 103), BM_SETCHECK, 0, 0);

     ShowWindow(GetDlgItem(HWindow, 201), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 251), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 202), SW_SHOW);

     ShowWindow(GetDlgItem(HWindow, 301), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 351), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 302), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 352), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 303), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 353), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 304), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 354), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 305), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 355), SW_SHOW);

     ShowWindow(GetDlgItem(HWindow, 401), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 451), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 402), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 452), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 403), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 453), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 404), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 454), SW_HIDE);
end;

procedure TArrayBox.DisplayLinearInterface;
begin
     SendMessage(GetDlgItem(HWindow, 101), BM_SETCHECK, 0, 0);
     SendMessage(GetDlgItem(HWindow, 102), BM_SETCHECK, 1, 0);
     SendMessage(GetDlgItem(HWindow, 103), BM_SETCHECK, 0, 0);

     ShowWindow(GetDlgItem(HWindow, 201), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 251), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 202), SW_SHOW);

     ShowWindow(GetDlgItem(HWindow, 301), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 351), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 302), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 352), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 303), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 353), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 304), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 354), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 305), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 355), SW_HIDE);

     ShowWindow(GetDlgItem(HWindow, 401), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 451), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 402), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 452), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 403), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 453), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 404), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 454), SW_SHOW);
end;

procedure TArrayBox.DisplayPathInterface;
begin
     SendMessage(GetDlgItem(HWindow, 101), BM_SETCHECK, 0, 0);
     SendMessage(GetDlgItem(HWindow, 102), BM_SETCHECK, 0, 0);
     SendMessage(GetDlgItem(HWindow, 103), BM_SETCHECK, 1, 0);

     ShowWindow(GetDlgItem(HWindow, 201), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 251), SW_SHOW);
     ShowWindow(GetDlgItem(HWindow, 202), SW_SHOW);

     ShowWindow(GetDlgItem(HWindow, 301), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 351), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 302), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 352), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 303), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 353), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 304), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 354), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 305), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 355), SW_HIDE);

     ShowWindow(GetDlgItem(HWindow, 401), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 451), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 402), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 452), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 403), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 453), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 404), SW_HIDE);
     ShowWindow(GetDlgItem(HWindow, 454), SW_HIDE);
end;

procedure TArrayBox.CheckCircularInterface(var Msg: TMessage);
begin
     DisplayCircularInterface;
end;

procedure TArrayBox.CheckLinearInterface(var Msg: TMessage);
begin
     DisplayLinearInterface;
end;

procedure TArrayBox.CheckPathInterface(var Msg: TMessage);
begin
     DisplayPathInterface;
end;

procedure TArrayBox.CheckSetByMouse(var Msg: TMessage);
var EnableFields: Boolean;
begin
     if (SendMessage( GetDlgItem(HWindow, 202), BM_GETCHECK, 0, 0) = 0)
     then begin
          SendMessage( GetDlgItem(HWindow, 202), BM_SETCHECK, 1, 0);
          EnableFields := False
          end
     else begin
          SendMessage( GetDlgItem(HWindow, 202), BM_SETCHECK, 0, 0);
          EnableFields := True
          end;
     EnableWindow(GetDlgItem(HWindow, 301), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 351), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 302), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 352), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 303), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 353), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 304), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 354), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 305), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 355), EnableFields);

     EnableWindow(GetDlgItem(HWindow, 401), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 451), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 402), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 452), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 403), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 453), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 404), EnableFields);
     EnableWindow(GetDlgItem(HWindow, 454), EnableFields);
end;

constructor TSequenceBox.Init(AParent: PWindowsObject; AAction: PSequenceAction);
begin
     inherited Init(AParent, 'DLG_SETSEQUENCE');
     Action := AAction;
     Action^ := saNone;
end;

procedure TSequenceBox.Button1(var Msg: TMessage);
begin
     Action^ := saMakeFirst;
     EndDialog(HWindow, 0);
end;

procedure TSequenceBox.Button2(var Msg: TMessage);
begin
     Action^ := saMakeLast;
     EndDialog(HWindow, 0);
end;

procedure TSequenceBox.Button3(var Msg: TMessage);
begin
     Action^ := saMoveForward;
     EndDialog(HWindow, 0);
end;

procedure TSequenceBox.Button4(var Msg: TMessage);
begin
     Action^ := saMoveBack;
     EndDialog(HWindow, 0);
end;

procedure TSequenceBox.Button5(var Msg: TMessage);
begin
     Action^ := saFlipPath;
     EndDialog(HWindow, 0);
end;

function GetSequenceAction(AParentWondow: PWindowsObject; var AAction: TSequenceAction; X, Y: Integer): Boolean;
var Dlg: PSequenceBox;
begin
     Dlg := New(PSequenceBox, Init(AParentWondow, @AAction));
     Application^.ExecDialog(Dlg);
     GetSequenceAction := True;
end;

constructor TAllignBox.Init(AParent: PWindowsObject; AAction: PAllignAction);
begin
     inherited Init(AParent, 'DLG_ALLIGN');
     Action := AAction;
     Action^ := aaNone;
end;

procedure TAllignBox.Button1(var Msg: TMessage);
begin
     Action^ := aaTop;
     EndDialog(HWindow, 0);
end;

procedure TAllignBox.Button2(var Msg: TMessage);
begin
     Action^ := aaBottom;
     EndDialog(HWindow, 0);
end;

procedure TAllignBox.Button3(var Msg: TMessage);
begin
     Action^ := aaLeft;
     EndDialog(HWindow, 0);
end;

procedure TAllignBox.Button4(var Msg: TMessage);
begin
     Action^ := aaRight;
     EndDialog(HWindow, 0);
end;

procedure TAllignBox.Button5(var Msg: TMessage);
begin
     Action^ := aaVerCenter;
     EndDialog(HWindow, 0);
end;

procedure TAllignBox.Button6(var Msg: TMessage);
begin
     Action^ := aaHorCenter;
     EndDialog(HWindow, 0);
end;

function GetAllignAction(AParentWondow: PWindowsObject; var AAction: TAllignAction): Boolean;
var Dlg: PAllignBox;
begin
     Dlg := New(PAllignBox, Init(AParentWondow, @AAction));
     Application^.ExecDialog(Dlg);
     GetAllignAction := True;
end;



constructor TOptionsBox.Init(AParent: PWindowsObject; AData: POptionsRec);
begin
     inherited Init(AParent, 'DLG_OPTIONS');
     DisplayCheck := New(PCheckBox, InitResource(@Self, 101));
     SnapToGrid := New(PCheckBox, InitResource(@Self, 102));
     DisplayGuide := New(PCheckBox, InitResource(@Self, 103));
     SizeX := New(PEdit, InitResource(@Self, 104, 20));
     SizeY := New(PEdit, InitResource(@Self, 105, 20));
     Data := AData;
end;

procedure TOptionsBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;


function TOptionsBox.LoadFields: Boolean;
var X, Y: Float;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(SizeX, X, 0, 0, True)
          then Exit;
          if not GetFloat(SizeY, Y, 0, 0, True)
          then Exit;
          Data^.GridSizeX := X;
          Data^.GridSizeY := Y;

          Data^.DisplayGrid := DisplayCheck^.GetCheck = 1;
          Data^.Snap := SnapToGrid^.GetCheck = 1;
          Data^.DsiplayGuideLines := DisplayGuide^.GetCheck = 1;
          LoadFields := True;
          end
     else LoadFields := False;
end;

procedure TOptionsBox.SetFields;
begin
     if Data <> nil
     then begin
          if Data^.DisplayGrid
          then DisplayCheck^.SetCheck(1)
          else DisplayCheck^.SetCheck(0);

          if Data^.Snap
          then SnapToGrid^.SetCheck(1)
          else SnapToGrid^.SetCheck(0);

          if Data^.DsiplayGuideLines
          then DisplayGuide^.SetCheck(1)
          else DisplayGuide^.SetCheck(0);

          SetFloat(SizeX, Data^.GridSizeX, 1, 3);
          SetFloat(SizeY, Data^.GridSizeY, 1, 3);
          end;
end;

procedure TOptionsBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;


function EditOptions(AParentWondow: PWindowsObject; var AOptions: TOptionsRec): Boolean;
var Dlg: POptionsBox;
begin
     Dlg := New(POptionsBox, Init(AParentWondow, @AOptions));
     Application^.ExecDialog(Dlg);
     EditOptions := True;
end;


constructor TRotateBox.Init(AParent: PWindowsObject; AData: PFloat);
begin
     inherited Init(AParent, 'DLG_ROTATE');
     AngleEdit := New(PEdit, InitResource(@Self, 101, 20));
     Data := AData;
end;

procedure TRotateBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;

function TRotateBox.LoadFields: Boolean;
var Value: Float;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(AngleEdit, Value, -360, + 360, False)
          then Exit;

          Data^ := Value;
          LoadFields := True;
          end
     else LoadFields := True;
end;

procedure TRotateBox.SetFields;
begin
     SetFloat(AngleEdit, Data^, 1, 3);
end;

procedure TRotateBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;


function GetAngle(AParentWondow: PWindowsObject): Float;
var Dlg: PRotateBox;
    Angle: Float;
begin
     Dlg := New(PRotateBox, Init(AParentWondow, @Angle));
     Angle := 0;
     Application^.ExecDialog(Dlg);
     GetAngle := Angle;
end;

constructor TStreachBox.Init(AParent: PWindowsObject; AData: PStreachData);
begin
     inherited Init(AParent, 'DLG_STREACH');
     Data := AData;
     XSizeEdit := New(PEdit, InitResource(@Self, 101, 20));
     YSizeEdit := New(PEdit, InitResource(@Self, 102, 20));
end;

procedure TStreachBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;

function TStreachBox.LoadFields: Boolean;
var Value1: Float;
    Value2: Float;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(XSizeEdit, Value1, 0, 20000, False)
          then Exit;
          if not GetFloat(YSizeEdit, Value2, 0, 20000, False)
          then Exit;
          Data^.XSize := Value1;
          Data^.YSize := Value2;
          LoadFields := True;
          end
     else LoadFields := True;
end;

procedure TStreachBox.SetFields;
begin
     if (Data <> nil)
     then begin
          SetFloat(XSizeEdit, Data^.XSize, 1, 3);
          SetFloat(YSizeEdit, Data^.YSize, 1, 3);
          end;
end;

procedure TStreachBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;


function GetStreachInfo(AParentWondow: PWindowsObject; var AData: TStreachData): Boolean;
var Dlg: PStreachBox;
begin
     Dlg := New(PStreachBox, Init(AParentWondow, @AData));
     GetStreachInfo := Application^.ExecDialog(Dlg) = 1;
end;

constructor TNewObjectBox.Init(AParent: PWindowsObject; AData: PNewObjectData);
begin
     inherited Init(AParent, 'DLG_INSERTOBJECT');
     Data := AData;

     PolligonRadio := New(PRadioButton, InitResource(@Self, 101));
     SoftPolligonRadio := New(PRadioButton, InitResource(@Self, 102));
     LineRadio := New(PRadioButton, InitResource(@Self, 103));
     EllipseRadio := New(PRadioButton, InitResource(@Self, 104));
     RectangleRadio := New(PRadioButton, InitResource(@Self, 105));
     StopPointRadio := New(PRadioButton, InitResource(@Self, 106));

     UsingMouseCheck := New(PCheckBox, InitResource(@Self, 110));

     X1Edit :=  New(PEdit, InitResource(@Self, 111, 20));
     Y1Edit :=  New(PEdit, InitResource(@Self, 112, 20));
     X2Edit :=  New(PEdit, InitResource(@Self, 113, 20));
     Y2Edit :=  New(PEdit, InitResource(@Self, 114, 20));
     CountEdit :=  New(PEdit, InitResource(@Self, 115, 20));
end;

procedure TNewObjectBox.SetupWindow;
begin
     inherited SetupWindow;
     SetFields;
end;

function TNewObjectBox.LoadFields: Boolean;
var Value1: Float;
    Value2: Float;
    Value3: Float;
    Value4: Float;
    Value5: Longint;
begin
     if (Data <> nil)
     then begin
          LoadFields := False;
          if not GetFloat(X1Edit, Value1, 0, 0, True)
          then Exit;
          if not GetFloat(Y1Edit, Value2, 0, 0, True)
          then Exit;
          if not GetFloat(X2Edit, Value3, 0, 0, True)
          then Exit;
          if not GetFloat(Y2Edit, Value4, 0, 0, True)
          then Exit;
          if LineRadio^.GetCheck = bf_Checked
          then begin
               if not GetInteger(CountEdit, Value5, 2, 100, True)
               then Exit;
               end
          else begin
               if EllipseRadio^.GetCheck = bf_Checked
               then begin
                    if not GetInteger(CountEdit, Value5, 4, 100, True)
                    then Exit;
                    end
               else if not GetInteger(CountEdit, Value5, 0, 100, True)
                    then Exit;
               end;


          if UsingMouseCheck^.GetCheck = bf_Checked
          then Data^.UsingMouse := True
          else Data^.UsingMouse := False;

          if PolligonRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doPolligon
          else if SoftPolligonRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doBezier
          else if LineRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doLine
          else if EllipseRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doEllipse
          else if RectangleRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doRectangle
          else if StopPointRadio^.GetCheck = bf_Checked
          then Data^.DrawObject := doStopPoint
          else Data^.DrawObject := doNone;

          Data^.X1 := Value1;
          Data^.Y1 := Value2;
          Data^.X2 := Value3;
          Data^.Y2 := Value4;
          Data^.Count := Value5;

          LoadFields := True;
          end
     else LoadFields := True;
end;

procedure TNewObjectBox.SetFields;
begin
     if (Data <> nil)
     then begin
          if Data^.UsingMouse
          then UsingMouseCheck^.SetCheck(1)
          else UsingMouseCheck^.SetCheck(0);

          case Data^.DrawObject
          of doPolligon: PolligonRadio^.SetCheck(1);
             doBezier: SoftPolligonRadio^.SetCheck(1);
             doLine: LineRadio^.SetCheck(1);
             doEllipse: EllipseRadio^.SetCheck(1);
             doRectangle: RectangleRadio^.SetCheck(1);
             doStopPoint: StopPointRadio^.SetCheck(1);
          else
             PolligonRadio^.SetCheck(0);
             SoftPolligonRadio^.SetCheck(0);
             LineRadio^.SetCheck(0);
             EllipseRadio^.SetCheck(0);
             RectangleRadio^.SetCheck(0);
             StopPointRadio^.SetCheck(0);
          end;

          SetFloat(X1Edit, Data^.X1,1,3);
          SetFloat(Y1Edit, Data^.Y1,1,3);
          SetFloat(X2Edit, Data^.X2,1,3);
          SetFloat(Y2Edit, Data^.Y2,1,3);
          SetInteger(CountEdit, Data^.Count);

          UpdateView;
          end;
end;

procedure TNewObjectBox.UpdateView;
begin
     if UsingMouseCheck^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, False);
          EnableWindow(Y1Edit^.HWindow, False);
          EnableWindow(X2Edit^.HWindow, False);
          EnableWindow(Y2Edit^.HWindow, False);
          if ((PolligonRadio^.GetCheck = bf_Checked)
             or (SoftPolligonRadio^.GetCheck = bf_Checked)
             or (RectangleRadio^.GetCheck = bf_Checked)
             or (StopPointRadio^.GetCheck = bf_Checked))
          then EnableWindow(CountEdit^.HWindow, False)
          else EnableWindow(CountEdit^.HWindow, True);
          end
     else if PolligonRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, False);
          EnableWindow(Y2Edit^.HWindow, False);
          EnableWindow(CountEdit^.HWindow, False);
          end
     else if SoftPolligonRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, False);
          EnableWindow(Y2Edit^.HWindow, False);
          EnableWindow(CountEdit^.HWindow, False);
          end
     else if LineRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, True);
          EnableWindow(Y2Edit^.HWindow, True);
          EnableWindow(CountEdit^.HWindow, True);
          end
     else if EllipseRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, True);
          EnableWindow(Y2Edit^.HWindow, True);
          EnableWindow(CountEdit^.HWindow, True);
          end
     else if RectangleRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, True);
          EnableWindow(Y2Edit^.HWindow, True);
          EnableWindow(CountEdit^.HWindow, False);
          end
     else if StopPointRadio^.GetCheck = bf_Checked
     then begin
          EnableWindow(X1Edit^.HWindow, True);
          EnableWindow(Y1Edit^.HWindow, True);
          EnableWindow(X2Edit^.HWindow, False);
          EnableWindow(Y2Edit^.HWindow, False);
          EnableWindow(CountEdit^.HWindow, False);
          end
     else begin
          EnableWindow(X1Edit^.HWindow, False);
          EnableWindow(Y1Edit^.HWindow, False);
          EnableWindow(X2Edit^.HWindow, False);
          EnableWindow(Y2Edit^.HWindow, False);
          EnableWindow(CountEdit^.HWindow, False);
          end;
end;

procedure TNewObjectBox.Ok(var Msg: TMessage);
begin
     if LoadFields
     then inherited Ok(Msg);
end;

procedure TNewObjectBox.Check1(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TNewObjectBox.Check2(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TNewObjectBox.Check3(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TNewObjectBox.Check4(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TNewObjectBox.Check5(var Msg: TMessage);
begin
     UpdateView;
end;

procedure TNewObjectBox.Check6(var Msg: TMessage);
begin
     UpdateView;
end;

function GetObjectData(AParentWondow: PWindowsObject; var AData: TNewObjectData): Boolean;
var Dlg: PNewObjectBox;
begin
     Dlg := New(PNewObjectBox, Init(AParentWondow, @AData));
     GetObjectData := Application^.ExecDialog(Dlg) = 1;
end;


constructor TAboutBox.Init(AParent: PWindowsObject);
begin
     inherited Init(AParent, 'DLG_ABOUT');
     Bitmap := LoadBitmap(hInstance, 'BM_ZIGZAGSPLASH2'{'BM_DEMO'});
end;

destructor TAboutBox.Done;
begin
     DeleteObject(Bitmap);
     inherited Done;
end;

procedure TAboutBox.SetupWindow;
var ScreenWidth,
    ScreenHeight,
    WindowWidth,
    WindowHeight: Integer;
    WindowRect: TRect;
begin
     inherited SetupWindow;

     ScreenWidth := GetSystemMetrics( SM_CXSCREEN);
     ScreenHeight := GetSystemMetrics( SM_CYSCREEN);
     GetWindowRect(HWindow, WindowRect);
     WindowWidth := WindowRect.Right - WindowRect.Left;
     WindowHeight := WindowRect.Bottom - WindowRect.Top;
     MoveWindow(HWindow, Round((ScreenWidth - WindowWidth) / 2),
                         Round((ScreenHeight - WindowHeight) / 2),
                         WindowWidth, WindowHeight, False);

end;

procedure TAboutBox.DrawAbout;
var Rect: TRect;
    DC: HDC;
begin

     {ImageShow(HWindow, 0, Rect.Bottom - 32, Bitmap, 4, 30, 1);}
     GetClientRect(HWindow, Rect);
     ImageShow(HWindow, ((Rect.Left + Rect.Right) div 2) - 150, ((Rect.Left + Rect.Right) div 2) - 150, Bitmap, 4, 30, 10);
     Rect.Top := Rect.Top + (((Rect.Left + Rect.Right) div 2) - 155) * 1 + 200 + 20;
     Rect.Left := Rect.Left + 20;
     Rect.Right := Rect.Right - 10;
     Rect.Bottom := Rect.Bottom - 10;
     DC := GetDC(HWindow);
     SetBkMode(DC, TRANSPARENT);


     {SetTextColor(DC, RGB(128,128,128));}
     SetTextColor(DC, RGB(128,128,128));

     Rect.Top := Rect.Top + 1;
     Rect.Left := Rect.Left + 1;
     DrawText(DC, TheAboutText, strLen(TheAboutText), Rect, DT_CENTER);
     SetTextColor(DC, RGB(0,0,0));

     Rect.Top := Rect.Top - 1;
     Rect.Left := Rect.Left - 1;
     DrawText(DC, TheAboutText, strLen(TheAboutText), Rect, DT_CENTER);

     ReleaseDC(HWindow, DC);
     {ImageShow(Wnd: HWnd; X,Y: Integer; Bitmap: HBitmap; BlockSize: Integer; Delay: Integer; Dens: Integer);}
end;

procedure TAboutBox.WMPaint(var Msg: TMessage);
var PS: TPaintStruct;
    DC: HDC;
begin
     DC := BeginPaint(HWindow, PS);
     EndPaint(HWindow, PS);
     DrawAbout;
end;

procedure ShowAboutDialog(AParentWindow: PWindowsObject);
var Dlg: PAboutBox;
begin
     Dlg  := New(PAboutBox, Init(AParentWindow));
     Application^.ExecDialog(Dlg);
end;

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

begin
     Decode(@TheKey, TheAboutText, SizeOf(TheKey), StrLen(TheAboutText));
end.