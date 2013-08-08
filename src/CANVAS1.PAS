unit Canvas1;

interface

uses WinTypes, WinProcs, OWindows, WIN31,
     Generics, SpeedButtons, Aligner, Streams,
     DlgBoxes, DataTypes, Show, Strings;

const
      DrawnFileID : TFileID = 'ZIGZAGV1.05';

      MAXZOOM             = 32;
      MINZOOM             = 1 / 32;
      BEZIERPOINTSCOUNT   = 50;

      RefreshLock: Longint = 0;

      comFlipVertical       = 1;
      comFlipHorizontal     = 2;
      comDeleteCurrent      = 3;
      comRotate             = 4;
      comGroup              = 5;
      comUnGroup            = 6;
      comClone              = 7;
      comMakeTwin           = 8;
      comFlipStopPoint      = 9;
      comMakeFirst          = 10;
      comBreakGroup         = 11;
      comExtendPolligon     = 12;
      comMakeFirstPoint     = 13;
      comZoomIn             = 14;
      comZoomOut            = 15;
      comZoomFit            = 16;
      comInsertNewObject    = 17;
      comEditProperty       = 18;
      comZoomInPosition     = 19;
      comGotoPreview        = 20;
      comEditGuitLines      = 21;
      comArray              = 22;
      comReversePath        = 23;
      comSnapSwitch         = 24;
      comAllign             = 25;
      comMakeLinear         = 26;
      comGotoCenter         = 27;
      comStreach            = 28;

      SCROLLSTEPS        = 300;
      DRAGHANDLEWIDTH    = 5;

      OUTPUTZOOM         = 1;
      MAXJUMPLENGTH      = 120;

      { Effect id(s) }
      efFlipHorizontal      = 1;
      efFlipVertical        = 2;
      efStretch             = 3;
      efRotate              = 4;
      efShiftOrder          = 5;
      efClone               = 6;
      efFlipStopPoint       = 7;
      efSeparate            = 8;
      efAppendPoints        = 9;
      efMakeFirst           = 10;
      efAppendPathToItem    = 11;
      efGetInRectObjects    = 12;
      efGotoNormalState     = 13;
      efAppendNewObject     = 14;
      efEditProperty        = 15;
      efDeleteCurrent       = 16;
      efInitPreviewData     = 17;
      efFreePreviewData     = 18;
      efGotoPreview         = 19;
      efEditGuideLines      = 20;
      efArray               = 21;
      efReversePath         = 22;
      efEditCanvasOptions   = 23;
      efAllignLeft          = 24;
      efAllignRight         = 25;
      efAllignTop           = 26;
      efAllignBottom        = 27;
      efAllignCenterHor     = 28;
      efAllignCenterVer     = 29;
      efAllign              = 30;
      efStreach             = 31;


      { Drag type id(s) }
      dtMove                = 1;
      dtRotate              = 2;
      dtSetupHash           = 3;
      dtRectularSellect     = 4;
      dtExpandXY            = 5;
      dtExpandX             = 6;
      dtExpandY             = 7;
      dtInsertNewObject     = 8;

      { Pick reagons id(s) }
      prNone             = 1;
      prMove             = 2;
      prRotate           = 3;
      prExpandXY         = 4;
      prExpandX          = 5;
      prExpandY          = 6;

      { Modal type id(s) }
      mtAppend              = 1;
      mtAppendNewObject     = 2;
      mtShift               = 3;

      {Canvas window state }
      cwsNormal          = 0;
      cwsZoomInPosition  = 1;

      { Respoce to respoce action }
      raCreateTwinItem   = 1;
      raCreateShifter    = 2;
      raEditProperty     = 3;
      raSetListPosition  = 4;
      raAllign           = 5;
      raCreateLinearItem = 6;
      raStreach          = 7;

      tiDragObject        = 100;
      tiDragGroup         = 101;
      tiDragRoot          = 102;
      tiDragPoint         = 103;
      tiDragShifter       = 104;
      tiDragPollygonPoint = 105;
      tiPath              = 106;
      tiDragPolligon      = 107;
      tiDrawnItem         = 108;
      tiTwinDrawnItem     = 109;
      tiLinearDrawnItem   = 110;
      tiStopPoint         = 111;
      tiDragMultiPoint    = 112;
      tiDragBezierPoint   = 113;
      tiDragBezier        = 114;

type

   TRPoint = record
      X,Y : Float;
      end;

   TRRect = record
      A, B: TRPoint;
      end;

   TEvent = (evMouseLDown, evMouseLUp, evMouseRDown, evMouseRUp, evMouseMove);

   TState = (stIdle, stEdit, stDrag, stModal, stPreView);

   TRotationEffectInfo = record
      DeterminedCenter: Boolean;
      Center: TRPoint;
      Cos, Sin: Float;
      end;

   TFlipEffectInfo = record
      DeterminedCenter: Boolean;
      Center: TRPoint;
      end;

   TItemType = (itNone, itTwin, itLinear);

   TItemBuildInfo = record
      ItemType: TItemType;
      end;

   PDragObject = ^TDragObject;

   PDrawInfo = ^TDrawInfo;
   TDrawInfo = record
       DrawDC: HDC;
       ExposedViewRect: TRect;
       ExposedLogicRect: TRRect;
       end;

   TDragInfo = record
       DragObject: PDragObject;
       DragType: Word;
       DrawInfo: TDrawInfo;
       TuchPlace: TPoint;
       ExtraInfo: Pointer;
       LastValue: Float;
       Center: TRPoint;
       RRect: TRRect;
       Rect: TRect;
       NewObjectData: TNewObjectData;
       Int: Longint;
       MouseState: Word;
       Moved: Boolean;
       end;

   TModalInfo = record
       ModalObject: PDragObject;
       ModalType: Word;
       NewObjectData: TNewObjectData;
       MouseState: Word;
       end;

   TPreviewInfo = record
       LastPos: TRPoint;
       Count: Longint;
       LabelEnable: Boolean;
       end;

   PStateInfo = ^TStateInfo;
   TStateInfo = record
       case State: TState
       of stEdit: ( );
          stDrag: ( DragInfo: TDragInfo);
          stModal: ( ModalInfo: TModalInfo);
          stPreview: ( PreviewInfo: TPreviewInfo);
       end;

   PCanvasInfo = ^TCanvasInfo;
   TCanvasInfo = record
      Zoom: Float;
      Delta: TRPoint;
      Settings: TOptionsRec;
      end;

   PPathPoint = ^TPathPoint;
   TPathPoint = record
       Point: TRPoint;
       Next: PPathPoint;
       Valid: Boolean;
       end;

   PEventInfo = ^TEventInfo;
   TEventInfo = record
       Event: TEvent;
       LogicPos: TRPoint;
       ViewPos: TPoint;
       end;

   POutputGenerator = ^TOutputGenerator;
   TOutputGenerator = object(TGeneric)
   private
      FirstPoint: Boolean;
      OutputZoom: Float;
      DrawnRect: TRRect;
      LastPos: TRPoint;
      FirstPos: TRPoint;
      Count: Longint;
      OutputStream: PStream;
   public
      constructor Create( AOutputStream: PStream; AOutputZoom: Float);
      destructor Destroy; virtual;
      function AddJump( APoint: TRPoint): Boolean;
      function AddStop: Boolean;
      end;


   PCanvasWindow_ = ^TCanvasWindow_;
   TDragObject = object(TGeneric)
      Next : PDragObject;
      Prev : PDragObject;
      Owner : PDragObject;
      FirstChild : PDragObject;
      Current : PDragObject;
   public
      constructor Create;
      destructor Destroy; virtual;
      procedure LoadFromStream(AStream: PStream); virtual;
      procedure WriteToStream(AStream: PStream); virtual;
      function GetTypeId: Word; virtual;
      procedure Group; virtual;
      procedure UnGroup; virtual;
      procedure MakeGroup; virtual;
      procedure MakeUnGroup; virtual;
      function IsGrouped: boolean; virtual;
      function IsGroupedOwner: boolean; virtual;
      function IsLockedChild(AChild: PDragObject): Boolean; virtual;
      function IsLockedByParent: Boolean; virtual;
      procedure Insert(AObject: PDragObject);
      procedure LinkBefore(AObject: PDragObject);
      procedure LinkAfter(AObject: PDragObject);
      procedure LeaveChild(AChild: PDragObject); virtual;
      procedure DeleteChild(AChild: PDragObject); virtual;
      procedure Delete; virtual;
      procedure Clear; virtual;
      procedure MakeFirst;
      procedure MakeLast;
      procedure MakeAfterNext;
      procedure MakeBeforePrev;
      procedure MakeCurrent; virtual;
      function IsCurrent: Boolean; virtual;
      function GetTheCurrent: PDragObject; virtual;
      function HandleEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
      function HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
      procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
      procedure GenerateOutput(AOutputGenerator: POutputGenerator); virtual;
      procedure Refresh(APassToOwner: Boolean); virtual;
      procedure RefreshFromChilds(ABegginer: Boolean); virtual;
      function SetState(AState: TState; AObject: PDragObject): PStateInfo; virtual;
      function GetStateInfo: PStateInfo; virtual;
      function GetState: TState; virtual;
      procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
      function GetChildsCount: Longint; virtual;
      function GetChild(AOrd: Longint): PDragObject; virtual;
      procedure CopySelfTo(AObject: PDragObject); virtual;
      function MakeSelfClone: PDragObject; virtual;
      procedure MakeClone(AOwner: PDragObject); virtual;
      function GetCanvasInfo: PCanvasInfo; virtual;
      procedure ConvertToLogic(var APoint: TPoint; var BPoint: TRPoint); virtual;
      procedure ConvertToView(var APoint: TRPoint; var BPoint: TPoint); virtual;
      procedure ConvertToLogicLength(AViewLength: Longint; var ALogicLength: Float); virtual;
      procedure ConvertToViewLength(ALogicLength: Float; var AViewLength: Longint); virtual;
      procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
      procedure Rotate( var ACenter: TRPoint; ASin, ACos : Float); virtual;
      procedure Expand( var ACenter: TRPoint; AXRate, AYRate: Float); virtual;
      procedure MakeOffset(ARPoint: TRPoint); virtual;
      function RefreshLocked: Boolean; virtual;
      procedure LockRefresh; virtual;
      procedure UnLockRefresh; virtual;
      procedure SendAsResponse( AObject: PDragObject); virtual;
      procedure EnableCommand(ACommand: Word; AEnable: Boolean); virtual;
      procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
      function GetTopmostOwner: PDragObject; virtual;
      end;

    PDragGroup = ^TDragGroup;
    TDragGroup = object(TDragObject)
       Grouped: Boolean;
       GroupOrigin: TRPoint;
       GroupSize: TRPoint;
       constructor Create;
       destructor Destroy;virtual;
       function HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       procedure MoveToPos( var APos:TPoint); virtual;
       procedure MakeGroup; virtual;
       procedure MakeUnGroup; virtual;
       function ContainsPoint( APoint:TPoint):Boolean;
       function GetPickRegion( APoint:TPoint):Word;
       procedure MakeOffset(ARPoint: TRPoint); virtual;
       function IsGrouped: boolean; virtual;
       function GetTheCurrent: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure GenerateOutput(AOutputGenerator: POutputGenerator); virtual;
       procedure DrawGroupFrame(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure Refresh(APassToOwner: Boolean); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;

    PDragRoot_ = ^TDragRoot_;
    TDragRoot_ = object(TDragObject)
       CanvasWindow : PCanvasWindow_;
       CanvasInfo: TCanvasInfo;
       StateInfo: TStateInfo;
       NewItem: PDragObject;
       ResponceAction: Word;
       Collection: PCollection;
       GuideLinesInfoRec: TGuideLinesInfoRec;
       Modifyed: Boolean;
       constructor Create(ACanvasWindow: PCanvasWindow_);
       destructor Destroy; virtual;
       procedure Clear; virtual;
       procedure Refresh(APassToOwner: Boolean);virtual;
       function SetState(AState: TState; AObject: PDragObject): PStateInfo; virtual;
       function GetStateInfo: PStateInfo; virtual;
       function HandleEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function HandleRootEvent( var EventInfo: TEventInfo):Boolean; virtual;
       procedure ConvertToLogic(var APoint: TPoint; var BPoint: TRPoint); virtual;
       procedure ConvertToView(var APoint: TRPoint; var BPoint: TPoint); virtual;
       procedure ConvertToLogicLength(AViewLength: Longint; var ALogicLength: Float); virtual;
       procedure ConvertToViewLength(ALogicLength: Float; var AViewLength: Longint); virtual;
       function GetState: TState; virtual;
       procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
       procedure SendAsResponse( AObject: PDragObject); virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure DrawSellectRectangle(var DrawInfo: TDrawInfo; ARect: TRect); virtual;
       procedure EnableCommand(ACommand: Word; AEnable: Boolean); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure UpdateCommandsStatus;
       function CreateObjectInstance(ATypeId: Word): PDragObject; virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure LoadFromStreamAsSymbol(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure GenerateOtputToStream(AStream: PStream); virtual;
       function GetTopmostOwner: PDragObject; virtual;
       procedure InsertNewObject(ANewObjectData: TNewObjectData); virtual;
       end;

    PDragShifter = ^TDragShifter;
    TDragShifter = object(TDragObject)
       Origin: TRPoint;
       Size: TRPoint;
       Items: PCollection;
       constructor Create( X, Y, W, H: Float; AItems: PCollection);
       destructor Destroy; virtual;
       function HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function IsGrouped: Boolean; virtual;
       procedure DrawFrame(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       function GetPickRegion( APoint:TPoint):Word;
       procedure MoveToPos( var APos:TPoint); virtual;
       procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
       procedure Refresh(APassToOwner: Boolean); virtual;
       procedure Rotate( var ACenter: TRPoint; ASin, ACos : Float); virtual;
       procedure Expand( var ACenter: TRPoint; AXRate, AYRate: Float); virtual;
       procedure MakeOffset(ARPoint: TRPoint); virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       function GetTheCurrent: PDragObject; virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;


    PCanvasToolsWindow = ^TCanvasToolsWindow;
    TCanvasToolsWindow = object(TWindow)
       Canvas: PCanvasWindow_;
       SBHandler: PSpeedButtonsHandler;
       SBAHandler: PAlignHandler;
       constructor Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
       destructor Done; virtual;
       procedure SetCanvas(ACanvas: PCanvasWindow_);
       function GetClassName: PChar; virtual;
       procedure GetWindowClass(var WndClass: TWndClass); virtual;
       procedure SetupWindow; virtual;
       procedure EnableCommand(ACommand: Word; AEnable: Boolean);
       procedure WMSize(var Msg:TMessage);
                 virtual wm_First + wm_Size;
       procedure WMPaint(var Msg: TMessage);
                 virtual wm_First + wm_Paint;
       procedure WMLButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_LButtonDown;
       procedure WMLButtonUp(var Msg:TMessage);
                 virtual wm_First + wm_LButtonUp;
       procedure WMMouseMove(var Msg:TMessage);
                 virtual wm_First + wm_MouseMove;
       procedure WMSpeedButton(var Msg: TMessage);
                 virtual wm_First + WM_SPEEDBUTTON;
       end;

    PCanvasInfoWindow = ^TCanvasInfoWindow;
    TCanvasInfoWindow = object(TWindow)
       Font: HFont;
       PanelBM: HBitmap;
       Canvas: PCanvasWindow_;
       LastMemorySize: Longint;
       LastZoom: Float;
       constructor Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
       destructor Done; virtual;
       function GetClassName: PChar; virtual;
       procedure GetWindowClass(var WndClass: TWndClass); virtual;
       procedure SetupWindow; virtual;
       procedure WMPaint(var Msg: TMessage);
                 virtual wm_First + wm_Paint;
       procedure DisplayStatusInfo;
       end;

    PCanvasStatusWindow = ^TCanvasStatusWindow;
    TCanvasStatusWindow = object(TWindow)
       Canvas: PCanvasWindow_;
       SBHandler: PSpeedButtonsHandler;
       SBAHandler: PAlignHandler;
       InfoWindow: PCanvasInfoWindow;
       constructor Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
       destructor Done; virtual;
       procedure SetCanvas(ACanvas: PCanvasWindow_);
       function GetClassName: PChar; virtual;
       procedure GetWindowClass(var WndClass: TWndClass); virtual;
       procedure SetupWindow; virtual;
       procedure EnableCommand(ACommand: Word; AEnable: Boolean);
       procedure WMSize(var Msg:TMessage);
                 virtual wm_First + wm_Size;
       procedure WMPaint(var Msg: TMessage);
                 virtual wm_First + wm_Paint;
       procedure WMLButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_LButtonDown;
       procedure WMLButtonUp(var Msg:TMessage);
                 virtual wm_First + wm_LButtonUp;
       procedure WMMouseMove(var Msg:TMessage);
                 virtual wm_First + wm_MouseMove;
       procedure WMSpeedButton(var Msg: TMessage);
                 virtual wm_First + WM_SPEEDBUTTON;
       procedure DisplayStatusInfo;
       end;

    TCanvasWindow_ = object(TWindow)
       CanvasStatus: PCanvasStatusWindow;
       CanvasTools: PCanvasToolsWindow;
       CanvasDrag: PDragRoot_;
       VPos, HPos: Integer;
       CursorPos: TRPoint;
       RotationEffectInfo: TRotationEffectInfo;
       FlipEffectInfo: TFlipEffectInfo;
       State: Word;
       LastCrossPos: TPoint;
       LastMouseViewPos: TPoint;
       CrossVisible: Boolean;
       SeveralsMenu: HMenu;

       constructor Init(AParent: PWindowsObject);
       destructor Done; virtual;
       function GetClassName: PChar; virtual;
       procedure GetWindowClass(var WndClass: TWndClass); virtual;
       procedure SetupWindow; virtual;
       function CreateCanvasDrag: PDragRoot_; virtual;
       procedure SetCanvasStatusWindow(ACanvasStatus: PCanvasStatusWindow);
       procedure SetToolsWindow(ACanvasTools: PCanvasToolsWindow);
       procedure DrawCrossCursor(AX, AY: Integer);
       procedure HideCross;
       procedure ShowCross;
       procedure MoveCrossTo(AX, AY: Integer);
       procedure SnapMouseEvent(var EventInfo: TEventInfo);
       procedure WMSize(var Msg:TMessage);
                 virtual wm_First + wm_Size;
       procedure WMRButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_RButtonDown;
       procedure WMRButtonUp(var Msg:TMessage);
                 virtual wm_First + wm_RButtonUp;
       procedure WMLButtonDown(var Msg:TMessage);
                 virtual wm_First + wm_LButtonDown;
       procedure WMLButtonUp(var Msg:TMessage);
                 virtual wm_First + wm_LButtonUp;
       procedure WMMouseMove(var Msg:TMessage);
                 virtual wm_First + wm_MouseMove;
       procedure WMPaint(var Msg: TMessage);
                 virtual wm_First + wm_Paint;
       procedure WMVScroll(var Msg: TMessage);
                 virtual wm_First + wm_VScroll;
       procedure WMHScroll(var Msg: TMessage);
                 virtual wm_First + wm_HScroll;
       procedure EnableCommand(ACommand: Word; AEnable: Boolean);
       procedure SetHorizontalPos(APos: Integer; AInvalidate: Boolean);
       procedure SetVerticalPos(APos: Integer; AInvalidate: Boolean);
       procedure UpdateScrollBars;
       procedure ZoomIn;
       procedure ZoomOut;
       procedure ZoomFit;
       procedure ZoomPos(AX, AY: Integer; AZoomRate: Float);
       procedure GroupCurrentObject;
       procedure UnGroupCurrentObject;
       procedure DeleteCurrentObject;
       procedure FlipHorizontal;
       procedure FlipVertical;
       procedure Rotate;
       procedure Streach;
       procedure Clone;
       procedure FlipStopPoint;
       procedure Separate;
       procedure AppendPoints;
       procedure MakeFirst;
       procedure BuildTwinDrawnItem;
       procedure BuildLinearDrawnItem;
       procedure InsertNewPollygon;
       procedure EditItemPropery;
       procedure AllignItems;
       procedure ZoomInPosition;
       procedure GotoPreview;
       procedure EditGuitLines;
       procedure CreateArray;
       procedure ReversePath;
       procedure EditCanvasOptions;

       procedure MakeFisrt(var Msg: TMessage);
                 virtual cm_First + 101;
       end;

procedure FreePathPoints(APoint: PPathPoint);
function FindLastPathPoint(APoint: PPathPoint): PPathPoint;


implementation

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

procedure FreePathPoints(APoint: PPathPoint);
var Temp, Next: PPathPoint;
begin
     Temp := APoint;
     while (Temp <> nil)
     do begin
        Next := Temp^.Next;
        Temp^.Valid := False;
        FillChar(Temp^, SizeOf(Temp^), #0);
        Dispose(Temp);
        Temp := Next;
        end;
end;

function FindLastPathPoint(APoint: PPathPoint): PPathPoint;
var Temp: PPathPoint;
begin
     Temp := APoint;
     if (Temp <> nil)
     then while (Temp^.Next <> nil)
          do Temp := Temp^.Next;
     FindLastPathPoint := temp;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TOutputGenerator.Create( AOutputStream: PStream; AOutputZoom: Float);
var L: Longint;
begin
     inherited Create;
     OutputZoom := AOutputZoom;
     FirstPoint := True;
     DrawnRect.A.X := 0;
     DrawnRect.A.Y := 0;
     DrawnRect.B.X := 0;
     DrawnRect.B.Y := 0;
     LastPos.X := 0;
     LastPos.Y := 0;
     FirstPos.X := 0;
     FirstPos.Y := 0;
     Count := 0;
     OutputStream := AOutputStream;
     if (OutputStream <> nil)
     then begin
          OutputStream^.Reset;
          L := 0;
          OutputStream^.WriteBlock(ControlFileID, SizeOf(ControlFileID));
          OutputStream^.WriteBlock(Count, SizeOf(Count));
          OutputStream^.WriteBlock(L, SizeOf(L));
          OutputStream^.WriteBlock(L, SizeOf(L));
          OutputStream^.WriteBlock(L, SizeOf(L));
          OutputStream^.WriteBlock(L, SizeOf(L));
          end;
end;

destructor TOutputGenerator.Destroy;
var Point: TPoint;
    L: Longint;
begin
     if (OutputStream <> nil)
     then begin
          OutputStream^.Seek(0);
          OutputStream^.WriteBlock(ControlFileID, SizeOf(ControlFileID));
          OutputStream^.WriteBlock(Count, SizeOf(Count));
          L := Round((FirstPos.X - DrawnRect.A.X) * OutputZoom);
          OutputStream^.WriteBlock(L, SizeOf(L));
          L := Round((FirstPos.Y - DrawnRect.A.Y) * OutputZoom);
          OutputStream^.WriteBlock(L, SizeOf(L));
          L := Round((DrawnRect.B.X - DrawnRect.A.X) * OutputZoom);
          OutputStream^.WriteBlock(L, SizeOf(L));
          L := Round((DrawnRect.B.Y - DrawnRect.A.Y) * OutputZoom);
          OutputStream^.WriteBlock(L, SizeOf(L));
          end;

     inherited Destroy;
end;

function TOutputGenerator.AddStop: Boolean;
var Rec: TJumpRec;
begin
     if (OutputStream <> nil)
     then begin
          Rec.Mode := modStop;
          Rec.DeltaX := 0;
          Rec.DeltaY := 0;
          OutputStream^.WriteBlock(Rec, SizeOf(Rec));
          Count := Count + 1;
          AddStop := True;
          end
     else AddStop := False;
end;

{
function TOutputGenerator.AddJump( APoint: TRPoint): Boolean;
var Rec: TJumpRec;
    SqrDeltaX,
    SqrDeltaY: Longint;
    DeltaX,
    DeltaY,
    JumpLength: Longint;
    StepsCount: Longint;
    XStep,
    YStep: Longint;
begin
     if (OutputStream <> nil)
     then begin
          if (not FirstPoint)
          then begin
               if (APoint.X < DrawnRect.A.X)
               then DrawnRect.A.X := APoint.X
               else if (APoint.X > DrawnRect.B.X)
                    then DrawnRect.B.X := APoint.X;

               if (APoint.Y < DrawnRect.A.Y)
               then DrawnRect.A.Y := APoint.Y
               else if (APoint.Y > DrawnRect.B.Y)
                    then DrawnRect.B.Y := APoint.Y;

               DeltaX := Round(APoint.X * OutputZoom) - Round(LastPos.X * OutputZoom);
               DeltaY := Round(APoint.Y * OutputZoom) - Round(LastPos.Y * OutputZoom);
               JumpLength := Round(Sqrt(((DeltaX * DeltaX) + (DeltaY * DeltaY))));

               Rec.Mode := modNormal;
               if (MAXJUMPLENGTH < JumpLength)
               then begin
                    DebugBreak;
                    StepsCount := (JumpLength div MAXJUMPLENGTH) + 1;
                    XStep := DeltaX div StepsCount;
                    YStep := DeltaY div StepsCount;
                    Rec.DeltaX := XStep;
                    Rec.DeltaY := YStep;
                    while (StepsCount > 1)
                    do begin
                       OutputStream^.WriteBlock(Rec, SizeOf(Rec));
                       Count := Count + 1;
                       DeltaX := DeltaX - XStep;
                       DeltaY := DeltaY - YStep;
                       StepsCount := StepsCount - 1;
                       end;
                    end;
               Rec.DeltaX := DeltaX;
               Rec.DeltaY := DeltaY;
               OutputStream^.WriteBlock(Rec, SizeOf(Rec));
               Count := Count + 1;
               LastPos := APoint;
               end
          else begin
               Rec.Mode := modNormal;
               Rec.DeltaX := 0;
               Rec.DeltaY := 0;
               OutputStream^.WriteBlock(Rec, SizeOf(Rec));
               LastPos := APoint;
               FirstPos := APoint;
               DrawnRect.A.X := APoint.X;
               DrawnRect.A.Y := APoint.Y;
               DrawnRect.B.X := APoint.X;
               DrawnRect.B.Y := APoint.Y;
               FirstPoint := False;
               end;
          AddJump := True;
          end
     else AddJump := False;
end;
}

function TOutputGenerator.AddJump( APoint: TRPoint): Boolean;
var Rec: TJumpRec;
    SqrDeltaX,
    SqrDeltaY: Longint;
    DeltaX,
    DeltaY,
    JumpLength: Longint;
    StepsCount: Longint;
    XStep,
    YStep: Longint;
begin
     if (OutputStream <> nil)
     then begin
          if (not FirstPoint)
          then begin
               if (APoint.X < DrawnRect.A.X)
               then DrawnRect.A.X := APoint.X
               else if (APoint.X > DrawnRect.B.X)
                    then DrawnRect.B.X := APoint.X;

               if (APoint.Y < DrawnRect.A.Y)
               then DrawnRect.A.Y := APoint.Y
               else if (APoint.Y > DrawnRect.B.Y)
                    then DrawnRect.B.Y := APoint.Y;

               DeltaX := Round(APoint.X * OutputZoom) - Round(LastPos.X * OutputZoom);
               DeltaY := Round(APoint.Y * OutputZoom) - Round(LastPos.Y * OutputZoom);
               JumpLength := Round(Sqrt(((DeltaX * DeltaX) + (DeltaY * DeltaY))));

               Rec.Mode := modNormal;
               if (MAXJUMPLENGTH < JumpLength)
               then begin
                    DebugBreak;
                    StepsCount := (JumpLength div MAXJUMPLENGTH) + 1;
                    XStep := DeltaX div StepsCount;
                    YStep := DeltaY div StepsCount;
                    Rec.DeltaX := XStep;
                    Rec.DeltaY := YStep;
                    while (StepsCount > 1)
                    do begin
                       OutputStream^.WriteBlock(Rec, SizeOf(Rec));
                       Count := Count + 1;
                       DeltaX := DeltaX - XStep;
                       DeltaY := DeltaY - YStep;
                       StepsCount := StepsCount - 1;
                       end;
                    end;
               Rec.DeltaX := DeltaX;
               Rec.DeltaY := DeltaY;
               OutputStream^.WriteBlock(Rec, SizeOf(Rec));
               Count := Count + 1;
               LastPos := APoint;
               end
          else begin
               Rec.Mode := modNormal;
               Rec.DeltaX := 0;
               Rec.DeltaY := 0;
               OutputStream^.WriteBlock(Rec, SizeOf(Rec));
               LastPos := APoint;
               FirstPos := APoint;
               DrawnRect.A.X := APoint.X;
               DrawnRect.A.Y := APoint.Y;
               DrawnRect.B.X := APoint.X;
               DrawnRect.B.Y := APoint.Y;
               FirstPoint := False;
               end;
          AddJump := True;
          end
     else AddJump := False;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragObject.Create;
begin
     Next := nil;
     Prev := nil;
     FirstChild := nil;
     Current := nil;
     Owner := nil;
end;

destructor TDragObject.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TDragObject.LoadFromStream(AStream: PStream);
begin
end;

procedure TDragObject.WriteToStream(AStream: PStream);
begin
end;

function TDragObject.GetTypeId: Word;
begin
     GetTypeId := tiDragObject;
end;

procedure TDragObject.MakeGroup;
begin
end;

procedure TDragObject.MakeUnGroup;
begin
end;

procedure TDragObject.Group;
begin
     if (Current <> nil)
     then if not Current^.IsGrouped
          then begin
               Current^.Group;
               Exit;
               end;
     if not IsGrouped
     then MakeGroup;
end;

procedure TDragObject.UnGroup;
begin
     if IsGrouped
     then begin
          MakeUnGroup;
          Exit;
          end;
     if (Current <> nil)
     then Current^.UnGroup;
end;

function TDragObject.IsGrouped: boolean;
begin
     if (Owner <> nil)
     then IsGrouped := Owner^.IsGrouped
     else IsGrouped := False;
end;

function TDragObject.IsGroupedOwner: boolean;
begin
     if (Owner <> nil)
     then IsGroupedOwner := PDragObject(Owner)^.IsGrouped
     else IsGroupedOwner := False;
end;

procedure TDragObject.DeleteChild(AChild:PDragObject);
begin
     if (AChild <> nil)
     then begin
          LeaveChild(AChild);
          AChild^.Free;
          end;
end;

procedure TDragObject.LeaveChild(AChild: PDragObject);
begin
     if (AChild <> nil)
     then if (AChild^.Owner = @Self)
          then begin
               if ((Current = AChild) and (AChild <> AChild^.Next))
               then Current := AChild^.Next
               else Current := nil;
               if ((AChild^.Next = AChild) or (AChild^.Prev = AChild)
                  or (AChild^.Next = nil) or (AChild^.Prev = nil))
               then FirstChild := nil
               else begin
                    if (FirstChild = AChild)
                    then FirstChild := AChild^.Next;
                    AChild^.Next^.Prev := AChild^.Prev;
                    AChild^.Prev^.Next := AChild^.Next;
                    end;
               AChild^.Owner := nil;
               AChild^.Next := nil;
               AChild^.Prev := nil;
               end;
end;

procedure TDragObject.Delete;
begin
     if (Owner <> nil)
     then begin
          SetState(stEdit, @Self);
          Owner^.DeleteChild(@Self);
          end
     else Free;
end;

procedure TDragObject.Clear;
var TempChild : PDragObject;
begin
     while (FirstChild <> nil)
     do DeleteChild(FirstChild);
     Next := nil;
     Prev := nil;
     FirstChild := nil;
     Current := nil;
end;

function TDragObject.IsLockedChild(AChild: PDragObject): Boolean;
begin
     IsLockedChild := False;
end;

function TDragObject.IsLockedByParent: Boolean;
begin
     if (Owner <> nil)
     then IsLockedByParent := Owner^.IsLockedChild(@Self)
     else IsLockedByParent := False;
end;

procedure TDragObject.Insert(AObject:PDragObject);
begin
     if (AObject <> nil)
     then begin
          if (FirstChild <> nil)
          then begin
               AObject^.Next := FirstChild;
               AObject^.Prev := FirstChild^.Prev;

               FirstChild^.Prev^.Next := AObject;
               FirstChild^.Prev := AObject;
               end
          else begin
               AObject^.Next := AObject;
               AObject^.Prev := AObject;
               FirstChild := AObject;
               end;
          AObject^.Owner := @Self;
          end;
end;

procedure TDragObject.LinkBefore(AObject:PDragObject);
begin
     if ((AObject <> nil) and (AObject <> @Self))
     then if (AObject^.Owner = Owner)
          then begin
               if ((Next <> nil) and (Prev <> nil))
               then begin
                    Prev^.Next := Next;
                    Next^.Prev := Prev;
                    end;
               Next := AObject;
               Prev := AObject^.Prev;
               Prev^.Next := @Self;
               Next^.Prev := @Self;
               end;
end;

procedure TDragObject.LinkAfter(AObject:PDragObject);
begin
     if ((AObject <> nil) and (AObject <> @Self))
     then if (AObject^.Owner = Owner)
          then begin
               if ((Next <> nil) and (Prev <> nil))
               then begin
                    Prev^.Next := Next;
                    Next^.Prev := Prev;
                    end;
               Prev := AObject;
               Next := AObject^.Next;
               Prev^.Next := @Self;
               Next^.Prev := @Self;
               end;
end;

function TDragObject.HandleEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Processed:Boolean;
    TempChild : PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     if IsGrouped
     then Processed := HandleGroupEvent(EventInfo,AStateInfo)
     else begin
          if (Current <> nil)
          then Processed := Current^.HandleEvent(EventInfo,AStateInfo)
          else Processed := False;
          if (not Processed)
          then begin
               TempChild := FirstChild;
               if (TempChild <> nil)
               then repeat
                    Processed := TempChild^.HandleEvent(EventInfo,AStateInfo);
                    TempChild := TempChild^.Next;
                    until ((TempChild = FirstChild) or (Processed));
               end;
          end;
     HandleEvent := Processed;
end;

function TDragObject.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Processed:Boolean;
    TempChild : PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     if (Current <> nil)
     then Processed := Current^.HandleGroupEvent(EventInfo,AStateInfo)
     else Processed := False;
     if (not Processed)
     then begin
          TempChild := FirstChild;
          if (TempChild <> nil)
          then repeat
               Processed := TempChild^.HandleGroupEvent(EventInfo,AStateInfo);
               TempChild := TempChild^.Next;
               until ((TempChild = FirstChild) or (Processed));
          end;
     HandleGroupEvent := Processed;
end;

procedure TDragObject.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var TempChild : PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     if (FirstChild <> nil)
     then begin
          TempChild := FirstChild;
          if (AStateInfo^.State <> stPreview)
          then begin
               repeat
                     TempChild := TempChild^.Prev;
                     if (TempChild <> Current)
                     then TempChild^.Draw(DrawInfo, AStateInfo);
               until (TempChild = FirstChild);
               if (Current <> nil)
               then Current^.Draw(DrawInfo, AStateInfo);
               end
          else begin
               repeat
                     TempChild^.Draw(DrawInfo, AStateInfo);
                     TempChild := TempChild^.Next;
               until (TempChild = FirstChild);
               end;
          end;
end;

procedure TDragObject.GenerateOutput(AOutputGenerator: POutputGenerator);
var TempChild: PDragObject;
begin
     { Like draw method work ... }
     if AOutputGenerator = nil then Exit;
     if (FirstChild <> nil)
     then begin
          TempChild := FirstChild;
          repeat
                TempChild^.GenerateOutput(AOutputGenerator);
                TempChild := TempChild^.Next;
          until (TempChild = FirstChild);
          end;
end;

procedure TDragObject.MakeFirst;
begin
     if (Owner <> nil)
     then if (Owner^.FirstChild <> @Self)
          then begin
               if (Owner^.FirstChild <> nil)
               then LinkBefore(Owner^.FirstChild);
               Owner^.FirstChild := @Self;
               end;
end;

procedure TDragObject.MakeLast;
begin
     if (Owner <> nil)
     then begin
          if ((Owner^.FirstChild <> nil) and (Owner^.FirstChild <> @Self))
          then LinkBefore(Owner^.FirstChild)
          else Owner^.FirstChild := Next;
          end;
end;

procedure TDragObject.MakeAfterNext;
begin
     if (Next <> nil)
     then if (Next <> @Self)
          then if (Next^.Next <> @Self)
               then begin
                    LinkAfter(Next);
                    if (Owner <> nil)
                    then if (Owner^.FirstChild = @Self)
                         then Owner^.FirstChild := Prev;
                    end;
end;

procedure TDragObject.MakeBeforePrev;
begin
     if (Prev <> nil)
     then if (Prev <> @Self)
          then if (Prev^.Prev <> @Self)
               then begin
                    LinkBefore(Prev);
                    if (Owner <> nil)
                    then if (Owner^.FirstChild = Next)
                         then Owner^.FirstChild := @Self;
                    end;
end;

procedure TDragObject.MakeCurrent;
begin
     if (Owner <> nil)
     then begin
          Owner^.Current := @Self;
          Owner^.MakeCurrent;
          end;
end;

function TDragObject.SetState(AState: TState; AObject: PDragObject): PStateInfo;
begin
     if (Owner <> nil)
     then SetState := Owner^.SetState(AState, AObject)
     else SetState := nil;
end;

function TDragObject.GetStateInfo: PStateInfo;
begin
     if (Owner <> nil)
     then GetStateInfo := Owner^.GetStateInfo

     else GetStateInfo := nil;
end;

function TDragObject.GetState: TState;
begin
     if (Owner <> nil)
     then GetState := Owner^.GetState
     else GetState := stIdle;
end;


function TDragObject.IsCurrent:Boolean;
begin
     if (Owner<>nil)
     then IsCurrent := ((Owner^.Current = @Self) and (Owner^.IsCurrent))
     else IsCurrent := True;
end;

procedure TDragObject.Refresh(APassToOwner: Boolean);
begin
     if RefreshLocked
     then exit;
     if ((APassToOwner) and (Owner <> nil))
     then Owner^.Refresh(True);
end;

procedure TDragObject.RefreshFromChilds(ABegginer: Boolean);
var Temp: PDragObject;
begin
     if RefreshLocked
     then exit;
     Temp := FirstChild;
     if (Temp <> nil)
     then repeat
          Temp^.RefreshFromChilds(False);
          Temp := Temp^.Next;
          until (Temp = FirstChild);
     Refresh(ABegginer);
end;

function TDragObject.GetTheCurrent: PDragObject;
begin
     if (Current <> nil)
     then GetTheCurrent := Current^.GetTheCurrent
     else GetTheCurrent := nil;
end;

procedure TDragObject.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var Temp: PDragObject;
    RRect: TRRect;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipHorizontal, efFlipVertical:
        begin
        if (TFlipEffectInfo(AEffectInfo).DeterminedCenter or IsGrouped)
        then begin
             LockRefresh;
             Temp := FirstChild;
             if (Temp <> nil)
             then repeat
                  Temp^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                  Temp := Temp^.Next;
                  until ((Temp = FirstChild) or (Temp = nil));
             UnLockRefresh;
             RefreshFromChilds(True);
             end
        else if (Current <> nil)
             then begin
                  Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                  end;
        end;
        efRotate: begin
                  if (TRotationEffectInfo(AEffectInfo).DeterminedCenter or IsGrouped)
                  then begin
                       LockRefresh;
                       Temp := FirstChild;
                       if (Temp <> nil)
                       then repeat
                            Temp^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                            Temp := Temp^.Next;
                            until ((Temp = FirstChild) or (Temp = nil));
                       UnLockRefresh;
                       RefreshFromChilds(True);
                       end
                  else if (Current <> nil)
                       then begin
                            Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                            end;
                  end;
        efReversePath: begin
                    if (IsGrouped)
                    then begin
                         LockRefresh;
                         Temp := FirstChild;
                         if (Temp <> nil)
                         then begin
                              repeat
                              Temp^.Prev := Temp^.Next;
                              Temp := Temp^.Next;
                              until ((Temp = FirstChild) or (Temp = nil));

                              Temp := FirstChild;
                              repeat
                              { Must protect this loop from pointers errors }
                              if (Temp^.Prev <> nil)
                              then begin
                                   Temp^.Prev^.Next := Temp;
                                   Temp := Temp^.Prev;
                                   end
                              else Temp := nil;
                              until ((Temp = FirstChild) or (Temp = nil));

                              FirstChild := FirstChild^.Next;

                              Temp := FirstChild;
                              if (Temp <> nil)
                              then repeat
                                   Temp^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                                   Temp := Temp^.Next;
                                   until ((Temp = FirstChild) or (Temp = nil));
                              end;
                         UnLockRefresh;
                         RefreshFromChilds(True);
                         end
                    else if (Current <> nil)
                         then begin
                              Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                              end;
                    end;
        efClone: begin
                 if IsGrouped
                 then begin
                      Temp := GetTopmostOwner;
                      if (Temp <> nil)
                      then MakeClone(Temp)
                      else MakeClone(Owner)
                      end
                 else if (Current <> nil)
                      then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        efMakeFirst: begin
                     if ((IsGrouped) and (Owner <> nil))
                     then begin
                          if (Owner^.FirstChild <> @Self)
                          then begin
                               Owner^.FirstChild := @Self;
                               Refresh(True);
                               end
                          end
                     else begin
                          if (Current <> nil)
                          then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                          end
                     end;
        efGetInRectObjects: begin
                            if (IsGrouped)
                            then begin
                                 GetItemsRect(RRect, True);
                                 if ((RRect.A.X >= TRRect(AEffectInfo).A.X)
                                    and (RRect.A.Y >= TRRect(AEffectInfo).A.Y)
                                    and (RRect.B.X <= TRRect(AEffectInfo).B.X)
                                    and (RRect.B.Y <= TRRect(AEffectInfo).B.Y))
                                 then SendAsResponse(@Self);
                                 end
                            else begin
                                 Temp := FirstChild;
                                 if (Temp <> nil)
                                 then repeat
                                      Temp^.MakeEffect(AEffect,AEffectInfo,AStateInfo);
                                      Temp := Temp^.Next;
                                      until ((Temp = FirstChild) or (Temp = nil));
                                 end;
                            end;
        efDeleteCurrent: begin
                         if IsGrouped
                         then begin
                              Temp := Owner;
                              Delete;
                              if (Temp <> nil)
                              then Temp^.RefreshFromChilds(True);
                              end
                         else begin
                              if (Current <> nil)
                              then Current^.MakeEffect(AEffect, AEffectInfo, AstateInfo);
                              end;
                         end;
        efInitPreviewData: begin
                           Temp := FirstChild;
                           if (Temp <> nil)
                           then repeat
                                Temp^.MakeEffect(AEffect,AEffectInfo,AStateinfo);
                                Temp := Temp^.Next;
                                until ((Temp = FirstChild) or (Temp = nil));
                           end;
        efFreePreviewData: begin
                           Temp := FirstChild;
                           if (Temp <> nil)
                           then repeat
                                Temp^.MakeEffect(AEffect,AEffectInfo,AStateinfo);
                                Temp := Temp^.Next;
                                until ((Temp = FirstChild) or (Temp = nil));
                           end;
     else
         if ((Current <> nil) and (not IsGrouped))
         then Current^.MakeEffect(AEffect, AEffectInfo, AstateInfo);
     end;
end;

function TDragObject.GetChildsCount: Longint;
var Temp: PDragObject;
    Count: Longint;
begin
     Count := 0;
     Temp := FirstChild;
     if Temp <> nil
     then repeat
          Count := Count + 1;
          Temp := Temp^.Next;
          until ((Temp = FirstChild) or (Temp = nil));
     GetChildsCount := Count;
end;

function TDragObject.GetChild(AOrd: Longint): PDragObject;
var Temp: PDragObject;
    Count: Longint;
begin
     if ((AOrd > 0) and (FirstChild <> nil))
     then begin
          Count := 1;
          Temp := FirstChild;
          while ((Count < AOrd) and (Temp <> nil))
          do begin
             Count := Count + 1;
             Temp := Temp^.Next;
             if (Temp = FirstChild)
             then Temp := nil;
             end;
          GetChild := Temp;
          end
     else GetChild := nil;
end;

function TDragObject.GetCanvasInfo: PCanvasInfo;
begin
     if (Owner <> nil)
     then GetCanvasInfo := PDragObject(Owner)^.GetCanvasInfo
     else GetCanvasInfo := nil;
end;

procedure TDragObject.ConvertToLogic(var APoint: TPoint; var BPoint: TRPoint);
begin
     if (Owner <> nil)
     then PDragObject(Owner)^.ConvertToLogic(APoint, BPoint);
end;

procedure TDragObject.ConvertToLogicLength(AViewLength: Longint; var ALogicLength: Float);
begin
     if (Owner <> nil)
     then PDragObject(Owner)^.ConvertToLogicLength(AViewLength, ALogicLength);
end;

procedure TDragObject.ConvertToViewLength(ALogicLength: Float; var AViewLength: Longint);
begin
     if (Owner <> nil)
     then PDragObject(Owner)^.ConvertToViewLength(ALogicLength, AViewLength);
end;



procedure TDragObject.MakeOffset(ARPoint: TRPoint);
var Temp: PDragObject;
begin
     Temp := PDragObject(FirstChild);
     if (Temp <> nil)
     then repeat
          Temp^.MakeOffset(ARPoint);
          Temp := PDragObject(Temp^.Next);
          until ((Temp = PDragObject(FirstChild)) or (Temp = nil));
     {Refresh(True);123}
end;

procedure TDragObject.Rotate( var ACenter: TRPoint; ASin, ACos : Float);
var Temp: PDragObject;
begin
     Temp := PDragObject(FirstChild);
     if (Temp <> nil)
     then repeat
          Temp^.Rotate(ACenter, ASin, ACos);
          Temp := PDragObject(Temp^.Next);
          until ((Temp = PDragObject(FirstChild)) or (Temp = nil));
     {Refresh(True);}
end;

procedure TDragObject.Expand( var ACenter: TRPoint; AXRate, AYRate: Float);
var Temp: PDragObject;
begin
     Temp := PDragObject(FirstChild);
     if (Temp <> nil)
     then repeat
          Temp^.Expand(ACenter, AXRate, AYRate);
          Temp := PDragObject(Temp^.Next);
          until ((Temp = PDragObject(FirstChild)) or (Temp = nil));
     {Refresh(True);}
end;


procedure TDragObject.ConvertToView(var APoint: TRPoint; var BPoint: TPoint);
begin
     if (Owner <> nil)
     then PDragObject(Owner)^.ConvertToView(APoint, BPoint);
end;

procedure TDragObject.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
var Temp: PDragObject;
    TheFirst: Boolean;
begin
     TheFirst := ATheFirst;
     Temp := PDragObject(FirstChild);
     if (Temp <> nil)
     then repeat
          Temp^.GetItemsRect(ARRect, TheFirst);
          Temp := PDragObject(Temp^.Next);
          TheFirst := False;
          until Temp = PDragObject(FirstChild);
end;

procedure TDragObject.CopySelfTo(AObject: PDragObject);
begin
end;

function TDragObject.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragObject, Create);
end;

procedure TDragObject.MakeClone(AOwner: PDragObject);
var Temp: PDragObject;
    SelfClone: PDragObject;
begin
     if (Owner <> nil)
     then begin
          SelfClone := MakeSelfClone;
          CopySelfTo(SelfClone);
          if (SelfClone <> nil)
          then begin
               AOwner^.Insert(SelfClone);
               Temp := FirstChild;
               if (Temp <> nil)
               then repeat
                    Temp^.MakeClone(SelfClone);
                    Temp := Temp^.Next;
                    until ((Temp = FirstChild) or (Temp = nil));
               SelfClone^.Refresh(False);
               end;
          end;
end;

function TDragObject.RefreshLocked: Boolean;
begin
     RefreshLocked := (RefreshLock <> 0);
end;

procedure TDragObject.LockRefresh;
begin
     RefreshLock := RefreshLock + 1;
end;

procedure TDragObject.UnLockRefresh;
begin
     RefreshLock := RefreshLock - 1;
end;

procedure TDragObject.SendAsResponse( AObject: PDragObject);
begin
     if (Owner <> nil)
     then Owner^.SendAsResponse(AObject);
end;

procedure TDragObject.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (Owner <> nil)
     then Owner^.EnableCommand(ACommand, AEnable);
end;

procedure TDragObject.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     if (Current <> nil)
     then Current^.GetCommandStatus(ACommand, AEnable, AStateInfo);
end;

function TDragObject.GetTopmostOwner: PDragObject;
begin
     if (Owner <> nil)
     then GetTopmostOwner := Owner^.GetTopmostOwner
     else GetTopmostOwner := nil;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragGroup.Create;
begin
     inherited Create;
     Grouped := False;
     GroupOrigin.X := 0;
     GroupOrigin.Y := 0;
     GroupSize.X := 0;
     GroupSize.Y := 0;
end;

destructor TDragGroup.Destroy;
begin
     inherited Destroy;
end;

procedure TDragGroup.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Grouped, SizeOf(Grouped));
     AStream^.ReadBlock(GroupOrigin, SizeOf(GroupOrigin));
     AStream^.ReadBlock(GroupSize, SizeOf(GroupSize));
end;

procedure TDragGroup.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Grouped, SizeOf(Grouped));
     AStream^.WriteBlock(GroupOrigin, SizeOf(GroupOrigin));
     AStream^.WriteBlock(GroupSize, SizeOf(GroupSize));
end;

function TDragGroup.GetTypeId: Word;
begin
     GetTypeId := tiDragGroup;
end;

function TDragGroup.IsGrouped: boolean;
begin
     IsGrouped := Grouped or Inherited IsGrouped;
end;

function TDragGroup.HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Point: TPoint;
    Angle, Rate: Float;
    Delta: TRPoint;
    Processed: Boolean;
    TempChild: PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     if (AStateInfo = nil) then Exit;
     if (Owner <> nil)
     then begin
          ConvertToView(GroupOrigin, Point);
          case EventInfo.Event
          of evMouseLDown: case AStateInfo^.State
                           of stEdit: begin
                                        case GetPickRegion(EventInfo.ViewPos)
                                        of prMove: begin
                                                   SetState(stDrag, @Self);
                                                   if (AStateInfo^.State = stDrag)
                                                   then begin
                                                        AStateInfo^.DragInfo.DragType := dtMove;
                                                        AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                        AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                        SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                        Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                        end;
                                                   HandleGroupEvent := True;
                                                   end;
                                           prRotate: begin
                                                     SetState(stDrag, @Self);
                                                     if (AStateInfo^.State = stDrag)
                                                     then begin
                                                          AStateInfo^.DragInfo.DragType := dtRotate;
                                                          AStateInfo^.DragInfo.Center.X := GroupOrigin.X + GroupSize.X / 2;
                                                          AStateInfo^.DragInfo.Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                                                          ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                          AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                          AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                          AStateInfo^.DragInfo.LastValue :=
                                                           - ArcTan( AStateInfo^.DragInfo.TuchPlace.Y
                                                                     / AStateInfo^.DragInfo.TuchPlace.X);
                                                          SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                          Draw(AStateInfo^.DragInfo.DrawInfo,AStateInfo);
                                                          end;
                                                     HandleGroupEvent := True;
                                                     end;

                                           prExpandXY: begin
                                                       SetState(stDrag, @Self);
                                                       if (AStateInfo^.State = stDrag)
                                                       then begin
                                                            AStateInfo^.DragInfo.DragType := dtExpandXY;
                                                            AStateInfo^.DragInfo.Center.X := GroupOrigin.X + GroupSize.X / 2;
                                                            AStateInfo^.DragInfo.Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                                                            ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                            AStateInfo^.DragInfo.LastValue := Sqrt(
                                                                   Sqr(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X) +
                                                                   Sqr(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y));
                                                            SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                            Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                            end;
                                                       HandleGroupEvent := True;
                                                       end;

                                           prExpandX: begin
                                                      SetState(stDrag, @Self);
                                                      if (AStateInfo^.State = stDrag)
                                                      then begin
                                                           AStateInfo^.DragInfo.DragType := dtExpandX;
                                                           AStateInfo^.DragInfo.Center.X := GroupOrigin.X + GroupSize.X / 2;
                                                           AStateInfo^.DragInfo.Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                                                           AStateInfo^.DragInfo.LastValue := Abs(AStateInfo^.DragInfo.Center.X
                                                                                             - EventInfo.LogicPos.X);
                                                           SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                           Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                           end;
                                                      HandleGroupEvent := True;
                                                      end;
                                           prExpandY: begin
                                                      SetState(stDrag, @Self);
                                                      if (AStateInfo^.State = stDrag)
                                                      then begin
                                                           AStateInfo^.DragInfo.DragType := dtExpandY;
                                                           AStateInfo^.DragInfo.Center.X := GroupOrigin.X + GroupSize.X / 2;
                                                           AStateInfo^.DragInfo.Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                                                           AStateInfo^.DragInfo.LastValue := Abs(AStateInfo^.DragInfo.Center.Y
                                                                                             - EventInfo.LogicPos.Y);
                                                           SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                           Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                           end;
                                                      HandleGroupEvent := True;
                                                      end;
                                        else
                                            HandleGroupEvent := False;
                                        end;
                                        end;
                              { Added after find the logical error, that is the sub objects
                                doesn`t response to mouse events in the preview state ... }
                              stPreView: begin
                                         if (Current <> nil)
                                         then Processed := Current^.HandleEvent(EventInfo,AStateInfo)
                                         else Processed := False;
                                         if (not Processed)
                                         then begin
                                              TempChild := FirstChild;
                                              if (TempChild <> nil)
                                              then repeat
                                                   Processed := TempChild^.HandleEvent(EventInfo,AStateInfo);
                                                   TempChild := TempChild^.Next;
                                                   until ((TempChild = FirstChild) or (Processed));
                                              end;
                                         HandleGroupEvent := Processed;
                                         end;
                           else
                               HandleGroupEvent := False;
                           end;
             evMouseLUp: case AStateInfo^.State
                         of stDrag: begin
                                    case AStateInfo^.DragInfo.DragType
                                    of dtMove: begin
                                               LockRefresh;
                                               Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                               SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                               SetState(stEdit, @Self);
                                               MakeCurrent;
                                               UnLockRefresh;
                                               RefreshFromChilds(True);
                                               HandleGroupEvent := True;
                                               end;
                                       dtRotate: begin
                                                 LockRefresh;
                                                 Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                 SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                                 SetState(stEdit, @Self);
                                                 UnLockRefresh;
                                                 RefreshFromChilds(True);
                                                 HandleGroupEvent := True;
                                                 end;
                                       dtExpandXY,
                                       dtExpandY,
                                       dtExpandX: begin
                                                  LockRefresh;
                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                                  SetState(stEdit, @Self);
                                                  UnLockRefresh;
                                                  RefreshFromChilds(True);
                                                  HandleGroupEvent := True;
                                                  end;
                                    else
                                        HandleGroupEvent := False;
                                    end;
                                    end
                         else
                             HandleGroupEvent := False;
                         end;
             evMouseMove: case AStateInfo^.State
                          of stDrag: begin
                                     case AStateInfo^.DragInfo.DragType
                                     of dtMove: begin
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                Point.X := EventInfo.ViewPos.X - AStateInfo^.DragInfo.TuchPlace.X;
                                                Point.Y := EventInfo.ViewPos.Y - AStateInfo^.DragInfo.TuchPlace.Y;
                                                MoveToPos(Point);
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                HandleGroupEvent := True;
                                                end;
                                        dtRotate: begin
                                                  ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                  Delta.X := EventInfo.ViewPos.X - Point.X;
                                                  Delta.Y := EventInfo.ViewPos.Y - Point.Y;
                                                  if (Delta.X <> 0)
                                                  then begin
                                                       if (Delta.X > 0)
                                                       then Angle :=  - ArcTan( Delta.Y / Delta.X )
                                                       else Angle :=  - ArcTan( Delta.Y / Delta.X ) + Pi;
                                                       end
                                                  else begin
                                                       if (Delta.Y > 0)
                                                       then Angle := - Pi / 2
                                                       else Angle := + Pi / 2;
                                                       end;
                                                  Angle := Angle - AStateInfo^.DragInfo.LastValue;
                                                  AStateInfo^.DragInfo.LastValue := AStateInfo^.DragInfo.LastValue + Angle;

                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  Rotate(AStateInfo^.DragInfo.Center,Sin(Angle),Cos(Angle));
                                                  Refresh(False);
                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  HandleGroupEvent := True;
                                                  end;
                                        dtExpandXY: begin
                                                    Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                    Angle := Sqrt( Sqr(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X) +
                                                                   Sqr(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y));

                                                    if (Abs(Angle) > 0.000001)
                                                    then begin
                                                         Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                         Expand(AStateInfo^.DragInfo.Center, Rate, Rate);
                                                         AStateInfo^.DragInfo.LastValue := Angle;
                                                         end;
                                                    Refresh(False);
                                                    Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                    HandleGroupEvent := True;
                                                    end;
                                        dtExpandX: begin
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   Angle := Abs(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X);
                                                   if (Abs(Angle) > 0.000001)
                                                   then begin
                                                        Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                        Expand(AStateInfo^.DragInfo.Center, Rate, 1);
                                                        AStateInfo^.DragInfo.LastValue := Angle;
                                                        end;
                                                   Refresh(False);
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   HandleGroupEvent := True;
                                                   end;
                                        dtExpandY: begin
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   Angle := Abs(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y);
                                                   if (Abs(Angle) > 0.000001)
                                                   then begin
                                                        Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                        Expand(AStateInfo^.DragInfo.Center, 1, Rate);
                                                        AStateInfo^.DragInfo.LastValue := Angle;
                                                        end;
                                                   Refresh(False);
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   HandleGroupEvent := True;
                                                   end;
                                     else
                                         HandleGroupEvent := True;
                                     end;
                                     end;
                          else
                              HandleGroupEvent := False;
                          end;
             end;
          end
     else HandleGroupEvent := False;
end;

procedure TDragGroup.MoveToPos( var APos:TPoint);
var Offset: TRPoint;
    RPoint: TRPoint;
begin
     ConvertToLogic(APos, RPoint);
     Offset.X := RPoint.X - GroupOrigin.X;
     Offset.Y := RPoint.Y - GroupOrigin.Y;
     MakeOffset(Offset);
end;

procedure TDragGroup.MakeOffset(ARPoint: TRPoint);
begin
     inherited MakeOffset(ARPoint);
     GroupOrigin.X := GroupOrigin.X + ARPoint.X;
     GroupOrigin.Y := GroupOrigin.Y + ARPoint.Y;
end;

procedure TDragGroup.MakeGroup;
begin
     LockRefresh;
     inherited MakeGroup;
     Grouped := True;
     UnLockRefresh;
     RefreshFromChilds(True);
end;

procedure TDragGroup.MakeUnGroup;
begin
     LockRefresh;
     inherited MakeUnGroup;
     Grouped := False;
     UnLockRefresh;
     RefreshFromChilds(True);
end;

function TDragGroup.GetPickRegion( APoint:TPoint):Word;
var RPoint: TRPoint;
    PointA, PointB: TPoint;
    TestValue: Byte;
begin
     ConvertToView(GroupOrigin, PointA);
     RPoint.X := GroupOrigin.X + GroupSize.X;
     RPoint.Y := GroupOrigin.Y + GroupSize.Y;
     ConvertToView(RPoint, PointB);

     TestValue := $00;
     if APoint.X >= PointA.X - DRAGHANDLEWIDTH
     then TestValue := TestValue or $01;
     if APoint.X >= PointA.X
     then TestValue := TestValue or $02;
     if APoint.X > PointB.X
     then TestValue := TestValue or $04;
     if APoint.X > PointB.X + DRAGHANDLEWIDTH
     then TestValue := TestValue or $08;

     if APoint.Y >= PointA.Y - DRAGHANDLEWIDTH
     then TestValue := TestValue or $10;
     if APoint.Y >= PointA.Y
     then TestValue := TestValue or $20;
     if APoint.Y > PointB.Y
     then TestValue := TestValue or $40;
     if APoint.Y > PointB.Y + DRAGHANDLEWIDTH
     then TestValue := TestValue or $80;

     if TestValue = $33
     then GetPickRegion := prMove
     else if IsCurrent
          then begin
               case TestValue
               of $73,
                  $13: begin
                       GetPickRegion := prExpandY
                       end;
                  $31,
                  $37: begin
                       GetPickRegion := prExpandX
                       end;
                  $77: begin
                       GetPickRegion := prExpandXY;
                       end;
                  $17: begin
                       GetPickRegion := prRotate;
                       end;
                  else
                      GetPickRegion := prNone;
                  end;
               end;

end;

function TDragGroup.ContainsPoint( APoint:TPoint):Boolean;
var RPoint: TRPoint;
begin
     ConvertToLogic(APoint, RPoint);
     ContainsPoint := ((RPoint.X > GroupOrigin.X) and (RPoint.Y > GroupOrigin.Y)
                      and (RPoint.X < (GroupOrigin.X + GroupSize.X)) and (RPoint.Y < (GroupOrigin.Y + GroupSize.Y)));
end;

function TDragGroup.GetTheCurrent: PDragObject;
begin
     if IsGrouped
     then GetTheCurrent := @Self
     else if (Current <> nil)
          then GetTheCurrent := Current^.GetTheCurrent
          else GetTheCurrent := nil;
end;

procedure TDragGroup.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var TempChild, Temp: PDragObject;
    RRect: TRRect;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipHorizontal,
        efFlipVertical: begin
                        LockRefresh;
                        if TFlipEffectInfo(AEffectInfo).DeterminedCenter
                        then inherited MakeEffect(AEffect, AEffectInfo, AStateInfo)
                        else begin
                             if IsGrouped
                             then begin
                                  TFlipEffectInfo(AEffectInfo).Center.X := GroupOrigin.X + GroupSize.X / 2;
                                  TFlipEffectInfo(AEffectInfo).Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                                  TFlipEffectInfo(AEffectInfo).DeterminedCenter := True;
                                  inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                                  end
                             else begin
                                  inherited MakeEffect(AEffect, AEffectInfo, AstateInfo);
                                  end;
                             end;
                        UnLockRefresh;
                        RefreshFromChilds(True);
                        end;
        efRotate: begin
                  LockRefresh;
                  if TRotationEffectInfo(AEffectInfo).DeterminedCenter
                  then inherited MakeEffect(AEffect, AEffectInfo, AStateInfo)
                  else begin
                       if IsGrouped
                       then begin
                            TRotationEffectInfo(AEffectInfo).Center.X := GroupOrigin.X + GroupSize.X / 2;
                            TRotationEffectInfo(AEffectInfo).Center.Y := GroupOrigin.Y + GroupSize.Y / 2;
                            TRotationEffectInfo(AEffectInfo).DeterminedCenter := True;
                            inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                            end
                       else begin
                            inherited MakeEffect(AEffect, AEffectInfo, AstateInfo);
                            end;
                       end;
                  UnLockRefresh;
                  RefreshFromChilds(True);
                  end;
        efStreach: begin
                   SendAsResponse(@Self);
                   end;
        efReversePath: begin
                    if (IsGrouped)
                    then begin
                         LockRefresh;
                         TempChild := FirstChild;
                         if (TempChild <> nil)
                         then begin
                              repeat
                              TempChild^.Prev := TempChild^.Next;
                              TempChild := TempChild^.Next;
                              until ((TempChild = FirstChild) or (TempChild = nil));

                              TempChild := FirstChild;
                              repeat
                              { Must protect this loop from pointers errors }
                              if (TempChild^.Prev <> nil)
                              then begin
                                   TempChild^.Prev^.Next := TempChild;
                                   TempChild := TempChild^.Prev;
                                   end
                              else TempChild := nil;
                              until ((TempChild = FirstChild) or (TempChild = nil));
                              FirstChild := FirstChild^.Next;

                              TempChild := FirstChild;
                              if (TempChild <> nil)
                              then repeat
                                   TempChild^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                                   TempChild := TempChild^.Next;
                                   until ((TempChild = FirstChild) or (TempChild = nil));
                              end;
                         UnLockRefresh;
                         RefreshFromChilds(True);
                         end
                    else if (Current <> nil)
                         then begin
                              Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                              end;
                    end;
        efClone: begin
                 if IsGrouped
                 then begin
                      Temp := GetTopmostOwner;
                      if (Temp <> nil)
                      then MakeClone(Temp)
                      else MakeClone(Owner)
                      end
                 else if (Current <> nil)
                      then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        efSeparate: begin
                    LockRefresh;
                    while (FirstChild <> nil)
                    do begin
                       TempChild := FirstChild;
                       LeaveChild(TempChild);
                       if (Owner <> nil)
                       then Owner^.Insert(TempChild)
                       else TempChild^.Free;
                       end;
                    UnlockRefresh;
                    if (Owner <> nil)
                    then begin
                         Owner^.Refresh(True);
                         Owner^.LeaveChild(@Self);
                         end;
                    Free;
                    end;
        efGetInRectObjects: begin
                            if (IsGrouped)
                            then begin
                                 GetItemsRect(RRect, True);
                                 if ((RRect.A.X >= TRRect(AEffectInfo).A.X)
                                    and (RRect.A.Y >= TRRect(AEffectInfo).A.Y)
                                    and (RRect.B.X <= TRRect(AEffectInfo).B.X)
                                    and (RRect.B.Y <= TRRect(AEffectInfo).B.Y))
                                 then SendAsResponse(@Self);
                                 end
                            else begin
                                 TempChild := FirstChild;
                                 if (TempChild <> nil)
                                 then repeat
                                      TempChild^.MakeEffect(AEffect,AEffectInfo,AStateInfo);
                                      TempChild := TempChild^.Next;
                                      until ((TempChild = FirstChild) or (TempChild = nil));
                                 end;
                            end;
        efDeleteCurrent: begin
                         if IsGrouped
                         then begin
                              TempChild := Owner;
                              Delete;
                              if (TempChild <> nil)
                              then TempChild^.RefreshFromChilds(True);
                              end
                         else begin
                              if (Current <> nil)
                              then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                              end;
                         end;
        efInitPreviewData: begin
                           TempChild := FirstChild;
                           if (TempChild <> nil)
                           then repeat
                                TempChild^.MakeEffect(AEffect,AEffectInfo,AStateInfo);
                                TempChild := TempChild^.Next;
                                until ((TempChild = FirstChild) or (TempChild = nil));
                           end;
        efFreePreviewData: begin
                           TempChild := FirstChild;
                           if (TempChild <> nil)
                           then repeat
                                TempChild^.MakeEffect(AEffect,AEffectInfo,AStateinfo);
                                TempChild := TempChild^.Next;
                                until ((TempChild = FirstChild) or (TempChild = nil));
                           end;


        else
            if ((Current <> nil) and (not IsGrouped))
            then Current^.MakeEffect(AEffect, AEffectInfo, AStateinfo);
     end;{case}
end;

procedure TDragGroup.DrawGroupFrame(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point1, Point2, Point3: TPoint;
    RRect: TRRect;
    Pen, OldPen: HPen;
begin
     if AStateInfo = nil
     then Exit;

     if AStateInfo = nil then Exit;
     case AStateInfo^.State
     of stEdit: begin
                   if ((IsGrouped) and (not IsGroupedOwner))
                   then begin
                        if IsCurrent
                        then begin
                             Pen := CreatePen(PS_SOLID, 1, RGB(0,0,255));
                             OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                             RRect.A := GroupOrigin;
                             RRect.B.X := RRect.A.X + GroupSize.X;
                             RRect.B.Y := RRect.A.Y + GroupSize.Y;
                             ConvertToView(RRect.A, Point1);
                             ConvertToView(RRect.B, Point2);
                             Point3.X := (Point1.X + Point2.X) div 2;
                             Point3.Y := (Point1.Y + Point2.Y) div 2;
                             MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                             LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
                             LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                             LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
                             LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                             MoveTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);
                             LineTo(DrawInfo.DrawDC, Point2.X + DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);
                             LineTo(DrawInfo.DrawDC, Point2.X + DRAGHANDLEWIDTH, Point2.Y + DRAGHANDLEWIDTH);
                             LineTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point2.Y + DRAGHANDLEWIDTH);
                             LineTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);
                             Rectangle( DrawInfo.DrawDC, Point2.X - 1, Point1.Y + 2,
                                        Point2.X + DRAGHANDLEWIDTH + 2, Point1.Y - DRAGHANDLEWIDTH - 1);
                             Rectangle( DrawInfo.DrawDC, Point2.X - 1, Point2.Y - 1,
                                        Point2.X + DRAGHANDLEWIDTH + 2, Point2.Y + DRAGHANDLEWIDTH + 2);
                             Ellipse(DrawInfo.DrawDC, Point3.X - 3, Point3.Y - 3, Point3.X + 4, Point3.Y + 4);
                             SelectObject(DrawInfo.DrawDC, OldPen);
                             DeleteObject(Pen);
                             end
                        else begin
                             Pen := CreatePen(PS_DOT, 1, RGB(128,128,128));
                             OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                             RRect.A := GroupOrigin;
                             RRect.B.X := RRect.A.X + GroupSize.X;
                             RRect.B.Y := RRect.A.Y + GroupSize.Y;
                             ConvertToView(RRect.A, Point1);
                             ConvertToView(RRect.B, Point2);
                             MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                             LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
                             LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                             LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
                             LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                             SelectObject(DrawInfo.DrawDC, OldPen);
                             DeleteObject(Pen);
                             end;
                        end;
                   end;
        stDrag: begin
                if ((AStateInfo^.DragInfo.DragObject = @Self) and (IsGrouped) and (not IsGroupedOwner))
                then begin
                     Pen := CreatePen(PS_SOLID, 1, RGB(0,0,255));
                     OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                     RRect.A := GroupOrigin;
                     RRect.B.X := RRect.A.X + GroupSize.X;
                     RRect.B.Y := RRect.A.Y + GroupSize.Y;
                     ConvertToView(RRect.A, Point1);
                     ConvertToView(RRect.B, Point2);
                     MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                     LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
                     LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                     LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
                     LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                     SelectObject(DrawInfo.DrawDC, OldPen);
                     DeleteObject(Pen);
                     end;
                end;
        stModal: begin
                 { No frame for this state ... }
                 end;
        stPreview: begin
                   { No frame for this state ... }
                   end;
        end;
end;

procedure TDragGroup.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
begin
     if AStateInfo = nil
     then Exit;

     DrawGroupFrame(DrawInfo, AStateInfo);
     inherited Draw(DrawInfo, AStateInfo);
end;

procedure TDragGroup.GenerateOutput(AOutputGenerator: POutputGenerator);
var TempChild: PDragObject;
begin
     { Like draw method work ... }
     if AOutputGenerator = nil then Exit;
     if (FirstChild <> nil)
     then begin
          TempChild := FirstChild;
          repeat
                TempChild^.GenerateOutput(AOutputGenerator);
                TempChild := TempChild^.Next;
          until (TempChild = FirstChild);
          end;
end;


procedure TDragGroup.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PDragGroup(AObject)^.Grouped := Grouped;
          PDragGroup(AObject)^.GroupOrigin := GroupOrigin;
          PDragGroup(AObject)^.GroupSize := GroupSize;
          end;
end;

function TDragGroup.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragGroup, create);
end;

procedure TDragGroup.Refresh(APassToOwner: Boolean);
var RRect: TRRect;
begin
     if not RefreshLocked
     then begin
          if Grouped
          then begin
               GetItemsRect(RRect, True);
               GroupSize.X := RRect.B.X - RRect.A.X;
               GroupSize.Y := RRect.B.Y - RRect.A.Y;
               GroupOrigin := RRect.A;
               end;
          inherited Refresh(APassToOwner);
          end;
end;

procedure TDragGroup.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipHorizontal: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comDeleteCurrent:  AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comRotate: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comStreach: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comGroup: AEnable :=  AEnable or (not Grouped and (AStateInfo^.State = stEdit));
        comUnGroup: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comClone: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comReversePath: AEnable:= AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comBreakGroup: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragRoot_.Create(ACanvasWindow: PCanvasWindow_);
begin
     inherited Create;
     CanvasWindow := ACanvasWindow;
     CanvasInfo.Zoom := 1;
     CanvasInfo.Delta.X := 0;
     CanvasInfo.Delta.Y := 0;
     CanvasInfo.Settings.GridSizeX := 10;
     CanvasInfo.Settings.GridSizeY := 10;
     CanvasInfo.Settings.DisplayGrid := True;
     CanvasInfo.Settings.Snap := False;
     CanvasInfo.Settings.DsiplayGuideLines := True;

     StateInfo.State := stEdit;
     NewItem := nil;
     Collection := nil;
     GuideLinesInfoRec.Enabled := True;
     GuideLinesInfoRec.VerticalSet := New(PContainerCollection, Create);
     GuideLinesInfoRec.HorizontalSet := New(PContainerCollection, Create);

     Modifyed := False;
end;

destructor TDragRoot_.Destroy;
begin
     if (NewItem <> nil)
     then NewItem^.Free;
     if (Collection <> nil)
     then Collection^.Free;

     if GuideLinesInfoRec.VerticalSet <> nil
     then GuideLinesInfoRec.VerticalSet^.Free;

     if GuideLinesInfoRec.HorizontalSet <> nil
     then GuideLinesInfoRec.HorizontalSet^.Free;

     inherited Destroy;
end;

function TDragRoot_.HandleRootEvent( var EventInfo: TEventInfo):Boolean;
begin
     HandleRootEvent := False;
end;

function TDragRoot_.HandleEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var LastCurrent: PDragObject;
begin
     { For mouse events only ... }
     if EventInfo.Event = evMouseLDown
     then Modifyed := True;

     case StateInfo.State
     of stDrag: begin
                if (StateInfo.DragInfo.DragObject = @Self)
                then HandleEvent := HandleRootEvent(EventInfo)
                else HandleEvent := StateInfo.DragInfo.DragObject^.HandleEvent(EventInfo, @StateInfo);
                end;
        stModal: begin
                 if (StateInfo.ModalInfo.ModalObject = @Self)
                 then HandleEvent := HandleRootEvent(EventInfo)
                 else HandleEvent := StateInfo.ModalInfo.ModalObject^.HandleEvent(EventInfo, @StateInfo);
                 end;
     else
         if inherited HandleEvent(EventInfo, @StateInfo)
         then HandleEvent := True
         else begin
              if ((Current <> nil) and (EventInfo.Event = evMouseLDown))
              then begin
                   LastCurrent := Current;
                   Current := nil;
                   LastCurrent^.RefreshFromChilds(True);
                   if (CanvasWindow <> nil)
                   then UpdateWindow(CanvasWindow^.HWindow);
                   end;
              HandleEvent := HandleRootEvent(EventInfo);
              end;
     end;
end;

procedure TDragRoot_.ConvertToLogic(var APoint: TPoint; var BPoint: TRPoint);
begin
     BPoint.X := APoint.X / CanvasInfo.Zoom + CanvasInfo.Delta.X;
     BPoint.Y := APoint.Y / CanvasInfo.Zoom + CanvasInfo.Delta.Y;
end;

procedure TDragRoot_.ConvertToView(var APoint: TRPoint; var BPoint: TPoint);
begin
     BPoint.X := Round((APoint.X - CanvasInfo.Delta.X) * CanvasInfo.Zoom);
     BPoint.Y := Round((APoint.Y - CanvasInfo.Delta.Y) * CanvasInfo.Zoom);
end;

procedure TDragRoot_.ConvertToLogicLength(AViewLength: Longint; var ALogicLength: Float);
begin
     ALogicLength := AViewLength / CanvasInfo.Zoom;
end;

procedure TDragRoot_.ConvertToViewLength(ALogicLength: Float; var AViewLength: Longint);
begin
     AViewLength := Round(ALogicLength * CanvasInfo.Zoom);
end;

function TDragRoot_.SetState(AState: TState; AObject: PDragObject): PStateInfo;
   procedure GotoModal;
   begin
        if (AObject <> nil)
        then begin
             StateInfo.State := stModal;
             StateInfo.ModalInfo.ModalObject := AObject;
             end
        else StateInfo.State := stEdit;
   end;

   procedure GotoDrag;
   var P: TPoint;
   begin
        if (AObject <> nil)
        then begin
             StateInfo.State := stDrag;
             GetClientRect(CanvasWindow^.HWindow, StateInfo.DragInfo.DrawInfo.ExposedViewRect);
             P.X := StateInfo.DragInfo.DrawInfo.ExposedViewRect.Left;
             P.Y := StateInfo.DragInfo.DrawInfo.ExposedViewRect.Top;
             ConvertToLogic(P, StateInfo.DragInfo.DrawInfo.ExposedLogicRect.A);
             P.X := StateInfo.DragInfo.DrawInfo.ExposedViewRect.Right;
             P.Y := StateInfo.DragInfo.DrawInfo.ExposedViewRect.Bottom;
             ConvertToLogic(P, StateInfo.DragInfo.DrawInfo.ExposedLogicRect.B);
             StateInfo.DragInfo.DragObject := AObject;
             StateInfo.DragInfo.DrawInfo.DrawDC := GetDC(CanvasWindow^.HWindow);
             SetCapture(CanvasWindow^.HWindow);
             end
        else StateInfo.State := stEdit;
   end;

   procedure GotoPreview;
   begin
        Stateinfo.State := stPreview;
        Stateinfo.PreViewInfo.LastPos.X := 0;
        Stateinfo.PreViewInfo.LastPos.Y := 0;
        Stateinfo.PreViewInfo.Count := 0;
   end;

   procedure GtotoCenter;
   begin
   end;

   procedure GotoEdit;
   begin
        Stateinfo.State := stEdit;
   end;

begin
     case StateInfo.State
     of stEdit: begin
                case AState
                of stEdit: begin
                           {stEdit -> stEdit}
                           GotoEdit;
                           end;
                   stDrag: begin
                           {stEdit -> stDrag}
                           GotoDrag;
                           end;
                   stModal: begin
                            {stEdit -> stModal}
                            GotoModal;
                            end;
                   stPreview: begin
                              {stEdit -> stPreview}
                              GotoPreview;
                              end;
                   end;
                end;
        stDrag: begin
                ReleaseCapture;
                ReleaseDC(CanvasWindow^.HWindow,StateInfo.DragInfo.DrawInfo.DrawDC);
                case AState
                of stEdit: begin
                           {stDrag -> stEdit}
                           GotoEdit;
                           end;
                   stDrag: begin
                           {stDrag -> stDrag}
                           GotoDrag;
                           end;
                   stModal: begin
                            {stDrag -> stModal}
                            GotoModal;
                            end;
                   stPreview: begin
                              {stDrag -> stPreview}
                              GotoPreview;
                              end;
                   end;
                end;
        stModal: begin
                 case AState
                 of stEdit: begin
                            {stModal -> stEdit}
                            GotoEdit;
                            end;
                    stDrag: begin
                            {stModal -> stDrag}
                            GotoDrag;
                            end;
                    stModal: begin
                             {stModal -> stModal}
                             GotoModal;
                             end;
                    stPreview: begin
                               {stModal -> stPreview}
                               GotoPreview;
                               end;
                    end;
                 end;
        stPreview: begin
                   case AState
                   of stEdit: begin
                              {stPreview -> stEdit}
                              GotoEdit;
                              end;
                      stDrag: begin
                              {stPreview -> stDrag}
                              GotoDrag;
                              end;
                      stModal: begin
                               {stPreview -> stModal}
                               GotoModal;
                               end;
                      stPreview: begin
                                 {stPreview -> stPreview}
                                 GotoPreview;
                                 end;
                      end;
                   end;
        end;
     UpdateCommandsStatus;
     SetState := @StateInfo;
end;

function TDragRoot_.GetStateInfo: PStateInfo;
begin
     GetStateInfo := @Stateinfo;
end;

procedure TDragRoot_.Refresh(APassToOwner: Boolean);
begin
     if RefreshLocked
     then exit;
     InvalidateRect(CanvasWindow^.HWindow,nil,False);
end;

function TDragRoot_.GetState: TState;
begin
     GetState := StateInfo.State;
end;

procedure TDragRoot_.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
begin
     ARRect.A.X := -1;
     ARRect.A.Y := -1;
     ARRect.B.X := 1;
     ARRect.B.Y := 1;
     inherited GetItemsRect(ARRect, ATheFirst);
     if (ARRect.A.X = ARRect.B.X)
     then begin
          ARRect.A.X := ARRect.A.X - 0.5;
          ARRect.B.X := ARRect.B.X + 0.5;
          end;
     if (ARRect.A.Y = ARRect.B.Y)
     then begin
          ARRect.A.Y := ARRect.A.Y - 0.5;
          ARRect.B.Y := ARRect.B.Y + 0.5;
          end;
end;

procedure TDragRoot_.SendAsResponse( AObject: PDragObject);
begin
     inherited SendAsResponse( AObject);
end;

procedure TDragRoot_.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
end;

procedure TDragRoot_.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateinfo);
var TempLine: PGuideLine;
    ViewLinePos: Integer;
    RPointA, RPointB: TRPoint;
    PointA, PointB: TPoint;
    Pen, OldPen: HPen;
    Length: Longint;
begin
     if Stateinfo.State = stPreview
     then begin
          StateInfo.PreviewInfo.LastPos.X := 0;
          Stateinfo.PreviewInfo.LastPos.Y := 0;
          StateInfo.PreviewInfo.Count := 0;
          StateInfo.PreviewInfo.LabelEnable := True;
          end;

     if (CanvasInfo.Settings.DisplayGrid and (Stateinfo.State <> stPreview))
     then begin
          Pen := CreatePen(PS_SOLID,0, RGB(192,192,192));
          {Pen := CreatePen(PS_SOLID,0, RGB(128,128,128));}
          OldPen := SelectObject(DrawInfo.DrawDC, Pen);

          ConvertToViewLength(CanvasInfo.Settings.GridSizeX, Length);
          if (Length > 2)
          then begin
               RPointA.X := Round( DrawInfo.ExposedLogicRect.A.X / CanvasInfo.Settings.GridSizeX)
                               * CanvasInfo.Settings.GridSizeX;
               RPointB.X := RPointA.X;
               RPointA.Y := DrawInfo.ExposedLogicRect.A.Y;
               RPointB.Y := DrawInfo.ExposedLogicRect.B.Y;
               while (RPointA.X < DrawInfo.ExposedLogicRect.B.X)
               do begin
                  ConvertToView(RPointA, PointA);
                  ConvertToView(RPointB, PointB);
                  MoveTo(DrawInfo.DrawDC, PointA.X, PointA.Y);
                  LineTo(DrawInfo.DrawDC, PointB.X, PointB.Y);
                  RPointA.X := RPointA.X + CanvasInfo.Settings.GridSizeX;
                  RPointB.X := RPointA.X;
                  end;
               end;

          ConvertToViewLength(CanvasInfo.Settings.GridSizeY, Length);

          if (Length > 2)
          then begin
               RPointA.Y := Round( DrawInfo.ExposedLogicRect.A.Y / CanvasInfo.Settings.GridSizeY)
                               * CanvasInfo.Settings.GridSizeY;
               RPointB.Y := RPointA.Y;
               RPointA.X := DrawInfo.ExposedLogicRect.A.X;
               RPointB.X := DrawInfo.ExposedLogicRect.B.X;
               while (RPointA.Y < DrawInfo.ExposedLogicRect.B.Y)
               do begin
                  ConvertToView(RPointA, PointA);
                  ConvertToView(RPointB, PointB);
                  MoveTo(DrawInfo.DrawDC, PointA.X, PointA.Y);
                  LineTo(DrawInfo.DrawDC, PointB.X, PointB.Y);
                  RPointA.Y := RPointA.Y + CanvasInfo.Settings.GridSizeY;
                  RPointB.Y := RPointA.Y;
                  end;
               end;
          SelectObject(DrawInfo.DrawDC, OldPen);
          DeleteObject(Pen);
          end;

     if (CanvasInfo.Settings.DsiplayGuideLines and (Stateinfo.State <> stPreview))
     then begin
          Pen := CreatePen(PS_DOT,1, RGB(255,0,0));
          OldPen := SelectObject(DrawInfo.DrawDC, Pen);
          if (GuideLinesInfoRec.VerticalSet <> nil)
          then begin
               TempLine := PGuideLine(GuideLinesInfoRec.VerticalSet^.GetFirst);
               while TempLine <> nil
               do begin
                  RPointA.X := TempLine^.LinePos;
                  RPointA.Y := DrawInfo.ExposedLogicRect.A.Y;
                  RPointB.X := TempLine^.LinePos;
                  RPointB.Y := DrawInfo.ExposedLogicRect.B.Y;
                  ConvertToView(RPointA, PointA);
                  ConvertToView(RPointB, PointB);
                  MoveTo(DrawInfo.DrawDC, PointA.X, PointA.Y);
                  LineTo(DrawInfo.DrawDC, PointB.X, PointB.Y);
                  TempLine := PGuideLine(GuideLinesInfoRec.VerticalSet^.GetNext);
                  end;
               end;
          if (GuideLinesInfoRec.HorizontalSet <> nil)
          then begin
               TempLine := PGuideLine(GuideLinesInfoRec.HorizontalSet^.GetFirst);
               while TempLine <> nil
               do begin
                  RPointA.X := DrawInfo.ExposedLogicRect.A.X;
                  RPointA.Y := TempLine^.LinePos;
                  RPointB.X := DrawInfo.ExposedLogicRect.B.X;
                  RPointB.Y := TempLine^.LinePos;
                  ConvertToView(RPointA, PointA);
                  ConvertToView(RPointB, PointB);
                  MoveTo(DrawInfo.DrawDC, PointA.X, PointA.Y);
                  LineTo(DrawInfo.DrawDC, PointB.X, PointB.Y);
                  TempLine := PGuideLine(GuideLinesInfoRec.HorizontalSet^.GetNext);
                  end;
               end;
          SelectObject(DrawInfo.DrawDC, OldPen);
          DeleteObject(Pen);
          end;
     inherited Draw(DrawInfo, @StateInfo);
end;

procedure TDragRoot_.DrawSellectRectangle(var DrawInfo: TDrawInfo; ARect: TRect);
begin
     MoveTo(DrawInfo.DrawDC, ARect.Left, ARect.Top);
     LineTo(DrawInfo.DrawDC, ARect.Right, ARect.Top);
     LineTo(DrawInfo.DrawDC, ARect.Right, ARect.Bottom);
     LineTo(DrawInfo.DrawDC, ARect.Left, ARect.Bottom);
     LineTo(DrawInfo.DrawDC, ARect.Left, ARect.Top);
end;

procedure TDragRoot_.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (CanvasWindow <> nil)
     then CanvasWindow^.EnableCommand(ACommand,AEnable);
end;

procedure TDragRoot_.UpdateCommandsStatus;
    procedure ProcessCommand(ACommand: Word);
    var Enable: Boolean;
    begin
         Enable := False;
         GetCommandStatus(ACommand, Enable, @StateInfo);
         Enablecommand(ACommand, Enable);
    end;
begin
     ProcessCommand(comFlipVertical);
     ProcessCommand(comFlipHorizontal);
     ProcessCommand(comDeleteCurrent);
     ProcessCommand(comRotate);
     ProcessCommand(comStreach);
     ProcessCommand(comGroup);
     ProcessCommand(comUnGroup);
     ProcessCommand(comClone);
     ProcessCommand(comMakeTwin);
     ProcessCommand(comMakeLinear);
     ProcessCommand(comFlipStopPoint);
     ProcessCommand(comMakeFirst);
     ProcessCommand(comBreakGroup);
     ProcessCommand(comExtendPolligon);
     ProcessCommand(comMakeFirstPoint);
     ProcessCommand(comInsertNewObject);
     ProcessCommand(comEditProperty);
     ProcessCommand(comGotoPreview);
     ProcessCommand(comReversePath);
     ProcessCommand(comArray);
     ProcessCommand(comAllign);
     ProcessCommand(0);
end;


procedure TDragRoot_.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comInsertNewObject: AEnable := StateInfo.State = stEdit;
        comGotoPreview: AEnable := ((StateInfo.State = stEdit) or (StateInfo.State = stPreview));
        end;
end;

function TDragRoot_.CreateObjectInstance(ATypeId: Word): PDragObject;
begin
     CreateObjectInstance := nil;
end;

procedure TDragRoot_.Clear;
begin
     Modifyed := False;
     SetState(stEdit, @Self);
     inherited Clear;
end;

procedure TDragRoot_.LoadFromStream(AStream: PStream);
var TempFileId: TFileID;
    TypeId: Word;
    ChildsCount: Longint;
    function LoadObject: PDragObject;
    var Obj: PDragObject;
        ChildsCount: Longint;
    begin
         AStream^.ReadBlock(TypeId, SizeOf(TypeId));
         AStream^.ReadBlock(ChildsCount, SizeOf(ChildsCount));
         Obj := CreateObjectInstance(TypeId);
         if (Obj <> nil)
         then begin
              Obj^.LoadFromStream(AStream);
              while (ChildsCount > 0)
              do begin
                 Obj^.Insert(LoadObject);
                 ChildsCount := ChildsCount - 1;
                 end;
              end;
         LoadObject := Obj;
    end;
begin
     MakeEffect(efGotoNormalState, PChar(nil)^, @StateInfo);
     AStream^.ReadBlock(TempFileID, SizeOf(TempFileID));
     if (TempFileID = DrawnFileID)
     then begin
          AStream^.ReadBlock(CanvasInfo, SizeOf(CanvasInfo));
          AStream^.ReadBlock(ChildsCount, SizeOf(ChildsCount));
          while (ChildsCount > 0)
          do begin
             Insert(LoadObject);
             ChildsCount := ChildsCount - 1;
             end;
          Modifyed := False;
          end
     else MessageBox(CanvasWindow^.HWindow,'„·› »Ì«‰«  Œ«ÿ∆','ZIGZAG',MB_OK or MB_ICONSTOP or $0400 or $0800);
end;

procedure TDragRoot_.LoadFromStreamAsSymbol(AStream: PStream);
var TempFileId: TFileID;
    TypeId: Word;
    ChildsCount: Longint;
    TempCanvasInfo: TCanvasInfo;
    ContainerGroup: PDragGroup;

    function LoadObject: PDragObject;
    var Obj: PDragObject;
        ChildsCount: Longint;
    begin
         AStream^.ReadBlock(TypeId, SizeOf(TypeId));
         AStream^.ReadBlock(ChildsCount, SizeOf(ChildsCount));
         Obj := CreateObjectInstance(TypeId);
         if (Obj <> nil)
         then begin
              Obj^.LoadFromStream(AStream);
              while (ChildsCount > 0)
              do begin
                 Obj^.Insert(LoadObject);
                 ChildsCount := ChildsCount - 1;
                 end;
              end;
         LoadObject := Obj;
    end;

begin
     MakeEffect(efGotoNormalState, PChar(nil)^, @StateInfo);
     AStream^.ReadBlock(TempFileID, SizeOf(TempFileID));
     if (TempFileID = DrawnFileID)
     then begin
          AStream^.ReadBlock(TempCanvasInfo, SizeOf(TempCanvasInfo));
          AStream^.ReadBlock(ChildsCount, SizeOf(ChildsCount));
          ContainerGroup := New(PDragGroup, Create);
          while (ChildsCount > 0)
          do begin
             ContainerGroup^.Insert(LoadObject);
             ChildsCount := ChildsCount - 1;
             end;
          Insert(ContainerGroup);
          end
     else begin
          MessageBox(CanvasWindow^.HWindow,'„·› »Ì«‰«  Œ«ÿ∆','ZIGZAG',MB_OK or MB_ICONSTOP or $0400 or $0800);
          end;
end;

procedure TDragRoot_.WriteToStream(AStream: PStream);
var ChildsCount: Longint;
    TempChild: PDragObject;
    TypeId: Word;
    procedure WriteObject(AObject: PDragObject);
    var ChildsCount: Longint;
        TempChild: PDragObject;
    begin
         TypeId := AObject^.GetTypeId;
         if TypeId = 0
         then begin
              ChildsCount := 0;
              AStream^.WriteBlock(TypeId, SizeOf(TypeId));
              AStream^.WriteBlock(ChildsCount, SizeOf(ChildsCount));
              Exit;
              end;
         ChildsCount := AObject^.GetChildsCount;
         AStream^.WriteBlock(TypeId, SizeOf(TypeId));
         AStream^.WriteBlock(ChildsCount, SizeOf(ChildsCount));
         AObject^.WriteToStream(AStream);
         TempChild := AObject^.FirstChild;
         while (ChildsCount > 0)
         do begin
            WriteObject(TempChild);
            TempChild := TempChild^.Next;
            ChildsCount := ChildsCount - 1;
            end;
    end;
begin
     MakeEffect(efGotoNormalState, PChar(nil)^, @StateInfo);
     ChildsCount := GetChildsCount;
     AStream^.WriteBlock(DrawnFileID, SizeOf(DrawnFileID));
     AStream^.WriteBlock(CanvasInfo, SizeOf(CanvasInfo));
     AStream^.WriteBlock(ChildsCount, SizeOf(ChildsCount));
     TempChild := FirstChild;
     while (ChildsCount > 0)
     do begin
        WriteObject(TempChild);
        ChildsCount := ChildsCount - 1;
        TempChild := TempChild^.Next;
        end;
     Modifyed := False;
end;

function TDragRoot_.GetTypeId: Word;
begin
     GetTypeId := tiDragRoot;
end;

procedure TDragRoot_.GenerateOtputToStream(AStream: PStream);
var OutputGenerator: POutputGenerator;
begin
     if (AStream = nil) then Exit;
     {RefreshFromChilds(True);}
     OutputGenerator := New( POutputGenerator, Create(AStream, OUTPUTZOOM));
     GenerateOutput(OutputGenerator);
     OutputGenerator^.Free;
end;


function TDragRoot_.GetTopmostOwner: PDragObject;
begin
     GetTopmostOwner := @Self;
end;

procedure TDragRoot_.InsertNewObject(ANewObjectData: TNewObjectData);
begin
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragShifter.Create(X, Y, W, H: Float; AItems: PCollection);
begin
     inherited Create;
     Origin.X := X;
     Origin.Y := Y;
     Size.X := W;
     Size.Y := H;
     Items := AItems;
end;

destructor TDragShifter.Destroy;
begin
     if (Items <> nil)
     then Items^.Free;
     inherited Destroy;
end;

procedure TDragShifter.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Origin, SizeOf(Origin));
     AStream^.ReadBlock(Size, SizeOf(Size));
     Items := nil;
end;

procedure TDragShifter.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Origin, SizeOf(Origin));
     AStream^.WriteBlock(Size, SizeOf(Size));
end;

function TDragShifter.GetTypeId: Word;
begin
     GetTypeId := 0;
end;

function TDragShifter.IsGrouped: Boolean;
begin
     IsGrouped := True;
end;

function TDragShifter.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Point: TPoint;
    LastOwner: PDragObject;
    Delta: TPoint;
    Angle, Rate: Float;
begin
     if AStateInfo = nil
     then Exit;

     if (Owner <> nil)
     then begin
          ConvertToView(Origin, Point);
          case EventInfo.Event
          of evMouseLDown: case AStateInfo^.State
                           of stModal: begin
                                       case GetPickRegion( EventInfo.ViewPos)
                                       of prMove: begin
                                                  SetState(stDrag, @Self);
                                                  if AStateInfo^.State = stDrag
                                                  then begin
                                                       AStateInfo^.DragInfo.DragType := dtMove;
                                                       AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                       AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                       SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                       Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                       end;
                                                  HandleGroupEvent := True;
                                                  end;
                                           prRotate: begin
                                                     SetState(stDrag, @Self);
                                                     if (AStateInfo^.State = stDrag)
                                                     then begin
                                                          AStateInfo^.DragInfo.DragType := dtRotate;
                                                          AStateInfo^.DragInfo.Center.X := Origin.X + Size.X / 2;
                                                          AStateInfo^.DragInfo.Center.Y := Origin.Y + Size.Y / 2;
                                                          ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                          AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                          AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                          AStateInfo^.DragInfo.LastValue :=
                                                           - ArcTan(AStateInfo^.DragInfo.TuchPlace.Y
                                                           / AStateInfo^.DragInfo.TuchPlace.X);
                                                          SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                          Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                          end;
                                                     HandleGroupEvent := True;
                                                     end;
                                           prExpandXY: begin
                                                       SetState(stDrag, @Self);
                                                       if (AStateInfo^.State = stDrag)
                                                       then begin
                                                            AStateInfo^.DragInfo.DragType := dtExpandXY;
                                                            AStateInfo^.DragInfo.Center.X := Origin.X + Size.X / 2;
                                                            AStateInfo^.DragInfo.Center.Y := Origin.Y + Size.Y / 2;
                                                            ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                            AStateInfo^.DragInfo.LastValue := Sqrt(
                                                                   Sqr(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X) +
                                                                   Sqr(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y));
                                                            SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                            Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                            end;
                                                       HandleGroupEvent := True;
                                                       end;

                                           prExpandX: begin
                                                      SetState(stDrag, @Self);
                                                      if (AStateInfo^.State = stDrag)
                                                      then begin
                                                           AStateInfo^.DragInfo.DragType := dtExpandX;
                                                           AStateInfo^.DragInfo.Center.X := Origin.X + Size.X / 2;
                                                           AStateInfo^.DragInfo.Center.Y := Origin.Y + Size.Y / 2;
                                                           AStateInfo^.DragInfo.LastValue := Abs(AStateInfo^.DragInfo.Center.X
                                                                                             - EventInfo.LogicPos.X);
                                                           SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                           Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                           end;
                                                      HandleGroupEvent := True;
                                                      end;
                                           prExpandY: begin
                                                      SetState(stDrag, @Self);
                                                      if (AStateInfo^.State = stDrag)
                                                      then begin
                                                           AStateInfo^.DragInfo.DragType := dtExpandY;
                                                           AStateInfo^.DragInfo.Center.X := Origin.X + Size.X / 2;
                                                           AStateInfo^.DragInfo.Center.Y := Origin.Y + Size.Y / 2;
                                                           AStateInfo^.DragInfo.LastValue := Abs(AStateInfo^.DragInfo.Center.Y
                                                                                             - EventInfo.LogicPos.Y);
                                                           SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                           Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                           end;
                                                      HandleGroupEvent := True;
                                                      end;
                                          else
                                              SetState(stEdit, @Self);
                                              LastOwner := Owner;
                                              Delete;
                                              if (LastOwner <> nil)
                                              then LastOwner^.RefreshFromChilds(True);
                                              HandleGroupEvent := True;
                                          end;
                                       end;
                           else
                               HandleGroupEvent := False;
                           end;
             evMouseLUp: case AStateInfo^.State
                         of stDrag: begin
                                    case AStateInfo^.DragInfo.DragType
                                    of dtMove: begin
                                               LockRefresh;
                                               Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                               SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                               SetState(stEdit, @Self);
                                               MakeCurrent;
                                               {Refresh(True);}
                                               SetState(stModal, @Self);
                                               if (AStateinfo^.State = stModal)
                                               then AStateInfo^.ModalInfo.ModalType := mtShift;
                                               UnlockRefresh;
                                               if (Owner <> nil)
                                               then Owner^.RefreshFromChilds(True);
                                               HandleGroupEvent := True;
                                               end;
                                       dtRotate: begin
                                                 LockRefresh;
                                                 Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                 SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                                 SetState(stModal, @Self);
                                                 if (AStateinfo^.State = stModal)
                                                 then AStateInfo^.ModalInfo.ModalType := mtShift;
                                                 UnLockRefresh;
                                                 if (Owner <> nil)
                                                 then Owner^.RefreshFromChilds(True);
                                                 HandleGroupEvent := True;
                                                 end;
                                       dtExpandXY,
                                       dtExpandY,
                                       dtExpandX: begin
                                                  LockRefresh;
                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_COPYPEN);
                                                  SetState(stDrag, @Self);
                                                  SetState(stModal, @Self);
                                                  if (AStateinfo^.State = stModal)
                                                  then AStateInfo^.ModalInfo.ModalType := mtShift;
                                                  UnLockRefresh;
                                                  if (Owner <> nil)
                                                  then Owner^.RefreshFromChilds(True);
                                                  HandleGroupEvent := True;
                                                  end;
                                    else
                                        HandleGroupEvent := False;
                                    end;
                                    end;
                         else
                             HandleGroupEvent := False;
                         end;
             evMouseMove: case AStateInfo^.State
                         of  stDrag: begin
                                     case AStateInfo^.DragInfo.DragType
                                     of dtMove: begin
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                Point.X := EventInfo.ViewPos.X - AStateInfo^.DragInfo.TuchPlace.X;
                                                Point.Y := EventInfo.ViewPos.Y - AStateInfo^.DragInfo.TuchPlace.Y;
                                                MoveToPos(Point);
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                HandleGroupEvent := True;
                                                end;
                                        dtRotate: begin
                                                  ConvertToView(AStateInfo^.DragInfo.Center, Point);
                                                  Delta.X := EventInfo.ViewPos.X - Point.X;
                                                  Delta.Y := EventInfo.ViewPos.Y - Point.Y;
                                                  if (Delta.X <> 0)
                                                  then begin
                                                       if (Delta.X > 0)
                                                       then Angle :=  - ArcTan( Delta.Y / Delta.X )
                                                       else Angle :=  - ArcTan( Delta.Y / Delta.X ) + Pi;
                                                       end
                                                  else begin
                                                       if (Delta.Y > 0)
                                                       then Angle := - Pi / 2
                                                       else Angle := + Pi / 2;
                                                       end;
                                                  Angle := Angle - AStateInfo^.DragInfo.LastValue;
                                                  AStateInfo^.DragInfo.LastValue := AStateInfo^.DragInfo.LastValue + Angle;

                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  Rotate(AStateInfo^.DragInfo.Center,Sin(Angle),Cos(Angle));
                                                  Refresh(False);
                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  HandleGroupEvent := True;
                                                  end;
                                        dtExpandXY: begin
                                                    Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                    Angle := Sqrt( Sqr(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X) +
                                                                   Sqr(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y));

                                                    if (Abs(Angle) > 0.000001)
                                                    then begin
                                                         Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                         Expand(AStateInfo^.DragInfo.Center, Rate, Rate);
                                                         AStateInfo^.DragInfo.LastValue := Angle;
                                                         end;
                                                    Refresh(False);
                                                    Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                    HandleGroupEvent := True;
                                                    end;
                                        dtExpandX: begin
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   Angle := Abs(AStateInfo^.DragInfo.Center.X - EventInfo.LogicPos.X);
                                                   if (Abs(Angle) > 0.000001)
                                                   then begin
                                                        Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                        Expand(AStateInfo^.DragInfo.Center, Rate, 1);
                                                        AStateInfo^.DragInfo.LastValue := Angle;
                                                        end;
                                                   Refresh(False);
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   HandleGroupEvent := True;
                                                   end;
                                        dtExpandY: begin
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   Angle := Abs(AStateInfo^.DragInfo.Center.Y - EventInfo.LogicPos.Y);
                                                   if (Abs(Angle) > 0.000001)
                                                   then begin
                                                        Rate := Angle / AStateInfo^.DragInfo.LastValue;
                                                        Expand(AStateInfo^.DragInfo.Center, 1, Rate);
                                                        AStateInfo^.DragInfo.LastValue := Angle;
                                                        end;
                                                   Refresh(False);
                                                   Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                   HandleGroupEvent := True;
                                                   end;

                                     else
                                         HandleGroupEvent := False;
                                     end;
                                     end
                          else
                              HandleGroupEvent := False;
                          end;
             end;
          end
     else HandleGroupEvent := False;
end;

procedure TDragShifter.DrawFrame(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point1, Point2, Point3: TPoint;
    RRect: TRRect;
    Pen, OldPen: HPen;
    StateInfo: PStateInfo;
begin
     if AStateInfo = nil
     then Exit;

     case AStateInfo^.State
     of stEdit: begin
                end;
        stDrag: begin
                Pen := CreatePen(PS_SOLID, 1, RGB(0,0,255));
                OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                RRect.A := Origin;
                RRect.B.X := RRect.A.X + Size.X;
                RRect.B.Y := RRect.A.Y + Size.Y;
                ConvertToView(RRect.A, Point1);
                ConvertToView(RRect.B, Point2);
                MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
                LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
                LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                SelectObject(DrawInfo.DrawDC, OldPen);
                DeleteObject(Pen);
                end;
        stModal: begin
                 Pen := CreatePen(PS_DOT, 1, RGB(0,0,255));
                 OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                 RRect.A := Origin;
                 RRect.B.X := RRect.A.X + Size.X;
                 RRect.B.Y := RRect.A.Y + Size.Y;
                 ConvertToView(RRect.A, Point1);
                 ConvertToView(RRect.B, Point2);
                 Point3.X := (Point1.X + Point2.X) div 2;
                 Point3.Y := (Point1.Y + Point2.Y) div 2;
                 MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                 LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
                 LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                 LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
                 LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                 MoveTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);
                 LineTo(DrawInfo.DrawDC, Point2.X + DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);
                 LineTo(DrawInfo.DrawDC, Point2.X + DRAGHANDLEWIDTH, Point2.Y + DRAGHANDLEWIDTH);
                 LineTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point2.Y + DRAGHANDLEWIDTH);
                 LineTo(DrawInfo.DrawDC, Point1.X - DRAGHANDLEWIDTH, Point1.Y - DRAGHANDLEWIDTH);

                 SelectObject(DrawInfo.DrawDC, OldPen);
                 DeleteObject(Pen);
                 Pen := CreatePen(PS_SOLID, 1, RGB(0,0,255));
                 OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                 Rectangle( DrawInfo.DrawDC, Point2.X - 1, Point1.Y + 2,
                            Point2.X + DRAGHANDLEWIDTH + 2, Point1.Y - DRAGHANDLEWIDTH - 1);
                 Rectangle( DrawInfo.DrawDC, Point2.X - 1, Point2.Y - 1,
                            Point2.X + DRAGHANDLEWIDTH + 2, Point2.Y + DRAGHANDLEWIDTH + 2);
                 Ellipse(DrawInfo.DrawDC, Point3.X - 3, Point3.Y - 3, Point3.X + 4, Point3.Y + 4);
                 SelectObject(DrawInfo.DrawDC, OldPen);
                 DeleteObject(Pen);
                 end;
        stPreview: begin
                   end;
        end;
end;




procedure TDragShifter.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Temp: PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     if AStateInfo = nil then Exit;
     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          DrawFrame(DrawInfo, AStateInfo);
          if ((AStateInfo^.State = stDrag) and (Items <> nil))
          then begin
               Temp := PDragObject(Items^.GetFirst);
               while (Temp <> nil)
               do begin
                  Temp^.Draw(DrawInfo, AStateInfo);
                  Temp := PDragObject(Items^.GetNext);
                  end;
               end;
          end;
end;

function TDragShifter.GetPickRegion( APoint:TPoint):Word;
var RPoint: TRPoint;
    PointA, PointB: TPoint;
    TestValue: Byte;
begin
     ConvertToView(Origin, PointA);
     RPoint.X := Origin.X + Size.X;
     RPoint.Y := Origin.Y + Size.Y;
     ConvertToView(RPoint, PointB);

     TestValue := $00;
     if APoint.X >= PointA.X - DRAGHANDLEWIDTH
     then TestValue := TestValue or $01;
     if APoint.X >= PointA.X
     then TestValue := TestValue or $02;
     if APoint.X > PointB.X
     then TestValue := TestValue or $04;
     if APoint.X > PointB.X + DRAGHANDLEWIDTH
     then TestValue := TestValue or $08;

     if APoint.Y >= PointA.Y - DRAGHANDLEWIDTH
     then TestValue := TestValue or $10;
     if APoint.Y >= PointA.Y
     then TestValue := TestValue or $20;
     if APoint.Y > PointB.Y
     then TestValue := TestValue or $40;
     if APoint.Y > PointB.Y + DRAGHANDLEWIDTH
     then TestValue := TestValue or $80;

     if TestValue = $33
     then GetPickRegion := prMove
     else if IsCurrent
          then begin
               case TestValue
               of $73,
                  $13: begin
                       GetPickRegion := prExpandY
                       end;
                  $31,
                  $37: begin
                       GetPickRegion := prExpandX
                       end;
                  $77: begin
                       GetPickRegion := prExpandXY;
                       end;
                  $17: begin
                       GetPickRegion := prRotate;
                       end;
                  else
                      GetPickRegion := prNone;
                  end;
               end;

end;

procedure TDragShifter.MoveToPos(var APos:TPoint);
var Offset: TRPoint;
begin
     ConvertToLogic(APos, Offset);
     Offset.X := Offset.X - Origin.X;
     Offset.Y := Offset.Y - Origin.Y;
     MakeOffset(Offset);
end;

procedure TDragShifter.Rotate( var ACenter: TRPoint; ASin, ACos : Float);
var Temp: PDragObject;
begin
     if (Items <> nil)
     then begin
          Temp := PDragObject(Items^.GetFirst);
          while (Temp <> nil)
          do begin
             Temp^.Rotate(ACenter, ASin, ACos);
             Temp := PDragObject(Items^.GetNext);
             end;
          end;
end;

procedure TDragShifter.Expand( var ACenter: TRPoint; AXRate, AYRate: Float);
var Temp: PDragObject;
begin
     if (Items <> nil)
     then begin
          Temp := PDragObject(Items^.GetFirst);
          while (Temp <> nil)
          do begin
             Temp^.Expand( ACenter, AXRate, AYRate);
             Temp := PDragObject(Items^.GetNext);
             end;
          end;
end;

procedure TDragShifter.Refresh(APassToOwner: Boolean);
var RRect: TRRect;
begin
     GetItemsRect(RRect, True);
     Size.X := RRect.B.X - RRect.A.X;
     Size.Y := RRect.B.Y - RRect.A.Y;
     Origin := RRect.A;
     inherited Refresh(APassToOwner);
end;

procedure TDragShifter.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
var Temp: PDragObject;
begin
     if (Items <> nil)
     then begin
          Temp := PDragObject(Items^.GetFirst);
          if (Temp <> nil)
          then begin
               Temp^.GetItemsrect(ARRect, ATheFirst);
               Temp := PDragObject(Items^.GetNext);
               while (Temp <> nil)
               do begin
                  Temp^.GetItemsrect(ARRect, False);
                  Temp := PDragObject(Items^.GetNext);
                  end;
               end;
          end
     else begin
          if ATheFirst
          then begin
               ARRect.A.X := 0;
               ARRect.A.Y := 0;
               ARRect.B.X := 0;
               ARRect.B.Y := 0;
               end;
          end;
end;

procedure TDragShifter.MakeOffset(ARPoint: TRPoint);
var Temp: PDragObject;
begin
     Origin.X := Origin.X + ARPoint.X;
     Origin.Y := Origin.Y + ARPoint.Y;
     if (Items <> nil)
     then begin
          Temp := PDragObject(Items^.GetFirst);
          while (Temp <> nil)
          do begin
             Temp^.MakeOffset(ARPoint);
             Temp := PDragObject(Items^.GetNext);
             end;
          end;
end;

procedure TDragShifter.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var TempChild: PDragObject;
    RRect: TRRect;
    LastOwner: PDragObject;
    Offset: TRPoint;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipHorizontal,
        efFlipVertical: begin
                        LockRefresh;
                        TFlipEffectInfo(AEffectInfo).Center.X := Origin.X + Size.X / 2;
                        TFlipEffectInfo(AEffectInfo).Center.Y := Origin.Y + Size.Y / 2;
                        TFlipEffectInfo(AEffectInfo).DeterminedCenter := True;
                        if (Items <> nil)
                        then begin
                             TempChild := PDragObject(Items^.GetFirst);
                             while (TempChild <> nil)
                             do begin
                                TempChild^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                                TempChild := PDragObject(Items^.GetNext);
                                end;
                             end;
                        UnLockRefresh;
                        RefreshFromChilds(True);
                        end;
        efStreach: begin
                   SendAsResponse(@Self);
                   end;
        efRotate: begin
                  LockRefresh;
                  TRotationEffectInfo(AEffectInfo).Center.X := Origin.X + Size.X / 2;
                  TRotationEffectInfo(AEffectInfo).Center.Y := Origin.Y + Size.Y / 2;
                  TRotationEffectInfo(AEffectInfo).DeterminedCenter := True;
                  if (Items <> nil)
                  then begin
                       TempChild := PDragObject(Items^.GetFirst);
                       while (TempChild <> nil)
                       do begin
                          TempChild^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                          TempChild := PDragObject(Items^.GetNext);
                          end;
                       end;
                  UnLockRefresh;
                  RefreshFromChilds(True);
                  end;
        efGotoNormalState: begin
                           if (AStateInfo^.State = stModal)
                           then begin
                                SetState(stEdit, @Self);
                                LastOwner := Owner;
                                Delete;
                                if (LastOwner <> nil)
                                then LastOwner^.RefreshFromChilds(True);
                                end;
                           end;
        efAllignLeft: begin
                      LockRefresh;
                      if (Items <> nil)
                      then begin
                           TempChild := PDragObject(Items^.GetFirst);
                           while (TempChild <> nil)
                           do begin
                              TempChild^.GetItemsRect(RRect, True);
                              Offset.X := Origin.X - RRect.A.X;
                              Offset.Y := 0;
                              TempChild^.MakeOffset(Offset);
                              TempChild := PDragObject(Items^.GetNext);
                              end;
                           end;
                      UnLockRefresh;
                      RefreshFromChilds(True);
                      end;
        efAllignRight: begin
                       LockRefresh;
                       if (Items <> nil)
                       then begin
                            TempChild := PDragObject(Items^.GetFirst);
                            while (TempChild <> nil)
                            do begin
                               TempChild^.GetItemsRect(RRect, True);
                               Offset.X := Origin.X + Size.X - RRect.B.X;
                               Offset.Y := 0;
                               TempChild^.MakeOffset(Offset);
                               TempChild := PDragObject(Items^.GetNext);
                               end;
                            end;
                       UnLockRefresh;
                       RefreshFromChilds(True);
                       end;
        efAllignTop: begin
                     LockRefresh;
                     if (Items <> nil)
                     then begin
                          TempChild := PDragObject(Items^.GetFirst);
                          while (TempChild <> nil)
                          do begin
                             TempChild^.GetItemsRect(RRect, True);
                             Offset.X := 0;
                             Offset.Y := Origin.Y - RRect.A.Y;
                             TempChild^.MakeOffset(Offset);
                             TempChild := PDragObject(Items^.GetNext);
                             end;
                          end;
                     UnLockRefresh;
                     RefreshFromChilds(True);
                     end;
        efAllignBottom: begin
                        LockRefresh;
                        if (Items <> nil)
                        then begin
                             TempChild := PDragObject(Items^.GetFirst);
                             while (TempChild <> nil)
                             do begin
                                TempChild^.GetItemsRect(RRect, True);
                                Offset.X := 0;
                                Offset.Y := Origin.Y + Size.Y - RRect.B.Y;
                                TempChild^.MakeOffset(Offset);
                                TempChild := PDragObject(Items^.GetNext);
                                end;
                             end;
                        UnLockRefresh;
                        RefreshFromChilds(True);
                        end;
        efAllignCenterHor: begin
                           LockRefresh;
                           if (Items <> nil)
                           then begin
                                TempChild := PDragObject(Items^.GetFirst);
                                while (TempChild <> nil)
                                do begin
                                   TempChild^.GetItemsRect(RRect, True);
                                   Offset.X := Origin.X + Size.X / 2 - (RRect.A.X + RRect.B.X) / 2;
                                   Offset.Y := 0;
                                   TempChild^.MakeOffset(Offset);
                                   TempChild := PDragObject(Items^.GetNext);
                                   end;
                                end;
                           UnLockRefresh;
                           RefreshFromChilds(True);
                           end;
        efAllignCenterVer: begin
                           LockRefresh;
                           if (Items <> nil)
                           then begin
                                TempChild := PDragObject(Items^.GetFirst);
                                while (TempChild <> nil)
                                do begin
                                   TempChild^.GetItemsRect(RRect, True);
                                   Offset.X := 0;
                                   Offset.Y := Origin.Y + Size.Y / 2 - (RRect.A.Y + RRect.B.Y) / 2;
                                   TempChild^.MakeOffset(Offset);
                                   TempChild := PDragObject(Items^.GetNext);
                                   end;
                                end;
                           UnLockRefresh;
                           RefreshFromChilds(True);
                           end;
        efAllign: begin
                  SendAsResponse( @Self);
                  end;
     end;{case}
end;

function TDragShifter.GetTheCurrent: PDragObject;
begin
     GetTheCurrent := @Self;
end;

procedure TDragShifter.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PDragShifter(AObject)^.Origin := Origin;
          PDragShifter(AObject)^.Size := Size;
          PDragShifter(AObject)^.Items := nil;
          end;
end;

function TDragShifter.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragShifter, Create(Origin.X, Origin.Y, Size.X, Size.Y, nil));
end;

procedure TDragShifter.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := True;
        comFlipHorizontal: AEnable := True;
        comDeleteCurrent:  AEnable := False;
        comRotate: AEnable := True;
        comStreach: AEnable := True;
        comGroup: AEnable := False;
        comUnGroup: AEnable := False;
        comClone: AEnable := False;
        comMakeTwin: AEnable := False;
        comMakeLinear: AEnable := False;
        comFlipStopPoint: AEnable := False;
        comMakeFirst: AEnable := False;
        comBreakGroup: AEnable := False;
        comExtendPolligon: AEnable := False;
        comMakeFirstPoint: AEnable := False;
        comReversePath: AEnable := False;
        comAllign: AEnable := True;
        end;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TCanvasToolsWindow.Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
begin
     inherited Init(AParent,'');
     DefaultProc := @DefWindowProc;
     Attr.X := 0;
     Attr.Y := 0;
     Attr.W := 0;
     Attr.H := 0;
     Attr.Style := ws_Visible or ws_Child;
     Canvas := ACanvas;
     SBHandler := nil;
     SBAHandler := nil;
     if (ACanvas <> nil)
     then ACanvas^.SetToolsWindow(@Self);
end;

function TCanvasToolsWindow.GetClassName: PChar;
begin
     GetClassName := 'CanvasToolsWindow';
end;

procedure TCanvasToolsWindow.GetWindowClass(var WndClass: TWndClass);
begin
     inherited GetwindowClass(WndClass);
     WndClass.hbrBackGround := GetStockObject(LtGray_Brush);
     WndClass.hCursor := LoadCursor(HInstance, 'CUR_HAND');
end;

procedure TCanvasToolsWindow.SetupWindow;
var TempSB: PSpeedButton;
begin
     inherited setupWindow;

     SBHandler := New(PSpeedButtonsHandler, Create(HWindow));
     SBAHandler := New(PAlignHandler, Create(HWindow,0));
     TempSB := New(PSpeedButton, Create(80,0,{Command}comDeleteCurrent, {Group}2, 'BM_REMOVE', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(80,0,{Command}comInsertNewObject, {Group}2, 'BM_INSERTOBJECT', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(80,0,{Command}comMakeTwin, {Group}2, 'BM_SETZIGZAGPATH', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);

     TempSB := New(PSpeedButton, Create(80,0,{Command}comMakeLinear, {Group}2, 'BM_BILDLINEAR', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(80,0,{Command}comClone, {Group}2, 'BM_CLONE', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comGroup, {Group}2, 'BM_GROUP2', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comUnGroup, {Group}2, 'BM_UNGROUP2', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comFlipVertical, {Group}2, 'BM_VMIRROR', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comFlipHorizontal, {Group}2, 'BM_HMIRROR', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comRotate, {Group}2, 'BM_ROTATE', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comFlipStopPoint, {Group}2, 'BM_STOP', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comStreach, {Group}2, 'BM_SIZE', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     (*TempSB := New(PSpeedButton, Create(0,0,{Command}comArray, {Group}2, 'BM_ARRAY', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);*)
     TempSB := New(PSpeedButton, Create(0,0,{Command}comAllign, {Group}2, 'BM_ALLIGN', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comExtendPolligon, {Group}2, 'BM_DRAWLINES', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comEditProperty, {Group}2, 'BM_PROPERTY', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comBreakGroup, {Group}2, 'BM_SEPARATE', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comMakeFirst, {Group}2, 'BM_MAKEFIRST', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comReversePath, {Group}2, 'BM_REVERSEPATH', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alRight, TempSB)));
     SBHandler^.InsertButton(TempSB);
     if (Canvas <> nil)
     then Canvas^.CanvasDrag^.UpdateCommandsStatus;
     SBAHandler^.AlignItems;
end;

procedure TCanvasToolsWindow.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (SBHandler <> nil)
     then SBHandler^.EnableCommand(ACommand, AEnable);
end;

destructor TCanvasToolsWindow.Done;
begin
     if (SBHandler <> nil)
     then SBHandler^.Free;

     inherited Done;
end;

procedure TCanvasToolsWindow.WMSize(var Msg:TMessage);
begin
     SBAHandler^.AlignItems;
end;

procedure TCanvasToolsWindow.WMPaint(var Msg: TMessage);
var DC: HDC;
    PaintStruct: TPaintStruct;
    Rect: TRect;
begin
     DC := BeginPaint(HWindow, PaintStruct);
     GetClientRect(HWindow, Rect);

     if (Canvas <> nil)
     then begin
          if (SBHandler <> nil)
          then SBHandler^.Draw(DC);
          end;
     EndPaint(HWindow, PaintStruct);
end;

procedure TCanvasToolsWindow.WMLButtonDown(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMLButtonDown(Msg);
end;

procedure TCanvasToolsWindow.WMLButtonUp(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMLButtonUp(Msg);
end;

procedure TCanvasToolsWindow.WMMouseMove(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMMouseMove(Msg);
end;

procedure TCanvasToolsWindow.WMSpeedButton(var Msg: TMessage);
begin

     case Msg.wParam
     of comMaketwin: begin
                     Canvas^.BuildTwinDrawnItem;
                     end;
        comMakeLinear: begin
                       Canvas^.BuildLinearDrawnItem;
                       end;
        comClone: begin
                  Canvas^.Clone;
                  end;
        comDeleteCurrent: begin
                          Canvas^.DeleteCurrentObject;
                          end;
        comGroup: begin
                  Canvas^.GroupCurrentObject;
                  end;
        comUnGroup: begin
                    Canvas^.UnGroupCurrentObject;
                    end;
        comFlipVertical: begin
                         Canvas^.FlipHorizontal;
                         end;
        comFlipHorizontal: begin
                           Canvas^.FlipVertical;
                           end;
        comRotate: begin
                   Canvas^.Rotate;
                   end;
        comStreach: begin
                    Canvas^.Streach;
                    end;
        comFlipStopPoint: begin
                          Canvas^.FlipStopPoint;
                          end;
        comExtendPolligon: begin
                           Canvas^.AppendPoints;
                           end;
        comArray: begin
                  Canvas^.CreateArray;
                  end;
        comReversePath: begin
                        Canvas^.ReversePath;
                        end;
        comBreakGroup: begin
                       Canvas^.Separate;
                       end;
        comMakeFirst: begin
                      Canvas^.MakeFirst;
                      end;
        comInsertNewObject: begin
                              Canvas^.InsertNewPollygon;
                              end;
        comEditProperty: begin
                         Canvas^.EditItemPropery;
                         end;
        comAllign: begin
                   Canvas^.AllignItems;
                   end;
        end;
     Canvas^.CanvasDrag^.UpdateCommandsStatus;
end;

procedure TCanvasToolsWindow.SetCanvas(ACanvas: PCanvasWindow_);
begin
     Canvas := ACanvas;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TCanvasInfoWindow.Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
var FontRec: TLOGFONT;
begin
     inherited Init(AParent,'');
     DefaultProc := @DefWindowProc;
     Attr.X := 0;
     Attr.Y := 0;
     Attr.W := 0;
     Attr.H := 0;
     Attr.Style := ws_Visible or ws_Child;

     with FontRec
     do begin
        lfHeight        := 15;
        lfWidth         := 6;
        lfEscapement    := 0;
        lfOrientation   := 0;
        lfWeight        := FW_DONTCARE;
        lfItalic        := 0;
        lfUnderline     := 0;
        lfStrikeOut     := 0;
        lfCharSet       := ANSI_CharSet;
        lfOutPrecision  := Out_Default_Precis;
        lfClipPrecision := Clip_Default_Precis;
        lfQuality       := Proof_Quality;
        lfPitchAndFamily:= Fixed_Pitch or FF_Roman;
        StrCopy(lfFaceName,'Courier new');
        end;

     PanelBM := LoadBitmap(hInstance, 'BM_PANEL1');
     Font := CreateFontIndirect(FontRec);
     Canvas := ACanvas;
end;

destructor TCanvasInfoWindow.Done;
begin
     DeleteObject(Font);
     DeleteObject(PanelBM);
     inherited Done;
end;

function TCanvasInfoWindow.GetClassName: PChar;
begin
     GetClassName := 'CanvasInfoWindow';
end;

procedure TCanvasInfoWindow.GetWindowClass(var WndClass: TWndClass);
begin
     inherited GetwindowClass(WndClass);
     WndClass.hbrBackGround := CreateSolidBrush(RGB(192, 192, 192));
end;

procedure TCanvasInfoWindow.SetupWindow;
begin
     inherited setupWindow;
end;

procedure TCanvasInfoWindow.WMPaint(var Msg: TMessage);
var DC: HDC;
    PS: TPAINTSTRUCT;
    Rect: TRect;
begin
     GetClientRect(HWindow, Rect);
     DC := BeginPaint(HWindow, PS);
     DrawBitmap(DC, Rect.Right - 350, 0, 350, 40, PanelBM);
     Endpaint(HWindow, PS);
     LastMemorySize := 0;
     LastZoom := 0;
     DisplayStatusInfo;
end;

procedure TCanvasInfoWindow.DisplayStatusInfo;
var DC: HDC;
    PaintStruct: TPaintStruct;
    S1, S2, S3: string;
    Brush, OldBrush: HBrush;
    Pen, OldPen: HPen;
    Rect: TRect;
    OldFont: HFont;
    MemorySize: Longint;
begin
     if ((Canvas = nil) or (HWindow = 0))
     then Exit;
     GetClientRect(HWindow, Rect);
     DC := GetDC(HWindow);
     OldFont := SelectObject(DC, Font);
     {SetBkColor(DC, RGB(192,192,192));}
     SetBkColor(DC, RGB(0,0,0));
     SetTextColor(DC, RGB(255,255,255));
     SetTextAlign(DC, TA_RIGHT);

     Str(Canvas^.CursorPos.X:1:3, S1);
     Str(Canvas^.CursorPos.Y:1:3, S2);
     S1 := ' ' + S1 + ',' + S2 + ' ';
     TextOut(DC, Rect.Right - 36, 20, PChar(@S1[1]), Length(S1));

     if (LastZoom <> Canvas^.CanvasDrag^.CanvasInfo.Zoom)
     then begin
          Str((1 / Canvas^.CanvasDrag^.CanvasInfo.Zoom):1:3, S1);
          S1 := '  1 : ' + S1 + ' ';
          TextOut(DC, Rect.Right - 36, 4, PChar(@S1[1]), Length(S1));
          LastZoom := Canvas^.CanvasDrag^.CanvasInfo.Zoom;
          end;

     MemorySize := MemAvail;
     if (MemorySize <> LastMemorySize)
     then begin
          Str(MemAvail, S1);
          Insert(' ',S1, Length(S1) - 2);
          Insert(' ',S1, Length(S1) - 6);
          S1 := '  ' + S1 + ' Byte';
          TextOut(DC, Rect.Right - 240, 4, PChar(@S1[1]), Length(S1));
          LastMemorySize := MemorySize;
          end;

     SelectObject(DC, OldFont);
     ReleaseDC(HWindow, DC);
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TCanvasStatusWindow.Init(AParent: PWindowsObject; ACanvas: PCanvasWindow_);
begin
     inherited Init(AParent,'');
     DefaultProc := @DefWindowProc;
     Attr.X := 0;
     Attr.Y := 0;
     Attr.W := 0;
     Attr.H := 0;
     Attr.Style := ws_Visible or ws_Child;
     Canvas := ACanvas;
     InfoWindow := New(PCanvasInfoWindow, Init(@Self, ACanvas));
     SBHandler := nil;
     SBAHandler := nil;
     if (ACanvas <> nil)
     then ACanvas^.SetCanvasStatusWindow(@Self);
end;

function TCanvasStatusWindow.GetClassName: PChar;
begin
     GetClassName := 'CanvasStatusWindow';
end;

procedure TCanvasStatusWindow.GetWindowClass(var WndClass: TWndClass);
begin
     inherited GetwindowClass(WndClass);
     WndClass.hbrBackGround := CreateSolidBrush(RGB(192,192,192));
     WndClass.hCursor := LoadCursor(HInstance, 'CUR_HAND');
end;

procedure TCanvasStatusWindow.SetupWindow;
var TempSB: PSpeedButton;
begin
     inherited setupWindow;
     SBHandler := New(PSpeedButtonsHandler, Create(HWindow));
     SBAHandler := New(PAlignHandler, Create(HWindow,0));
     TempSB := New(PSpeedButton, Create(80,0,{Command}comEditGuitLines, 1, 'BM_GUIDLINES', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(80,0,{Command}comSnapSwitch, 1, 'BM_CANVASOPTIONS', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comGotoPreview, {Group}1, 'BM_PREVIEW', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(40,0,{Command}comZoomOut, 1,'BM_ZOOMOUT', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comZoomIn, 1, 'BM_ZOOMIN', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comZoomInPosition, 1, 'BM_VIEWCENTER', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     TempSB := New(PSpeedButton, Create(0,0,{Command}comGotoCenter, 1, 'BM_CENTER', ''));
     SBAHandler^.InsertItem(New(PSpeedBottonAligner, Create(alLeft, TempSB)));
     SBHandler^.InsertButton(TempSB);
     SBAHandler^.InsertItem(New(PWinndowAligner, Create(alClient, InfoWindow^.HWindow,0)));
     SBAHandler^.AlignItems;
end;

procedure TCanvasStatusWindow.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (SBHandler <> nil)
     then SBHandler^.EnableCommand(ACommand, AEnable);
end;


destructor TCanvasStatusWindow.Done;
begin
     if (SBHandler <> nil)
     then SBHandler^.Free;

     inherited Done;
end;

procedure TCanvasStatusWindow.WMSize(var Msg:TMessage);
begin
     SBAHandler^.AlignItems;
end;

procedure TCanvasStatusWindow.WMPaint(var Msg: TMessage);
var DC: HDC;
    PaintStruct: TPaintStruct;
begin
     DC := BeginPaint(HWindow, PaintStruct);
     if (Canvas <> nil)
     then begin
          if (SBHandler <> nil)
          then SBHandler^.Draw(DC);
          end;
     EndPaint(HWindow, PaintStruct);
     DisplayStatusInfo;
end;

procedure TCanvasStatusWindow.DisplayStatusInfo;
begin
     if (InfoWindow <> nil)
     then InfoWindow^.DisplayStatusInfo;
end;

procedure TCanvasStatusWindow.WMLButtonDown(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMLButtonDown(Msg);
end;

procedure TCanvasStatusWindow.WMLButtonUp(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMLButtonUp(Msg);
end;

procedure TCanvasStatusWindow.WMMouseMove(var Msg:TMessage);
begin
     if (SBHandler <> nil)
     then SBHandler^.WMMouseMove(Msg);
end;

procedure TCanvasStatusWindow.WMSpeedButton(var Msg: TMessage);
var Point: TPoint;
    RPoint: TRPoint;
begin
     if (Canvas <> nil)
     then begin
          case Msg.wParam
          of comZoomIn: begin
                        Canvas^.ZoomIn;
                        end;
             comZoomOut: begin
                         Canvas^.ZoomOut;
                         end;
             comZoomFit: begin
                         Canvas^.ZoomFit;
                         end;
             comZoomInPosition: begin
                                Canvas^.ZoomInPosition;
                                end;
             comEditGuitLines: begin
                               Canvas^.EditGuitLines;
                               end;
             comSnapSwitch: begin
                            Canvas^.EditCanvasOptions;
                            end;
             comGotoPreview: begin
                             Canvas^.GotoPreview;
                             end;
             comGotoCenter: begin
                            RPoint.X := 0;
                            RPoint.Y := 0;
                            Canvas^.CanvasDrag^.ConvertToView(RPoint, Point);
                            Canvas^.ZoomPos(Point.X,Point.Y,1);
                            end;
             end;
        end;
end;

procedure TCanvasStatusWindow.SetCanvas(ACanvas: PCanvasWindow_);
begin
     Canvas := ACanvas;
     UpdateWindow(HWindow);
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TCanvasWindow_.Init(AParent: PWindowsObject);
begin
     inherited Init(AParent,'');
     DefaultProc := @DefWindowProc;
     Attr.X := 0;
     Attr.Y := 0;
     Attr.W := 0;
     Attr.H := 0;
     Attr.Style := ws_Visible or ws_Child;
     Attr.ExStyle := Attr.ExStyle or $00002000;
     CanvasStatus := nil;
     CanvasTools := nil;
     CursorPos.X := 0;
     CursorPos.Y := 0;
     State := cwsNormal;
     CrossVisible := False;
     LastCrossPos.X := 0;
     LastCrossPos.Y := 0;
     LastMouseViewPos.X := 0;
     LastMouseViewPos.Y := 0;
     SeveralsMenu := LoadMenu(HInstance, 'MNU_SEVERALS');
end;

destructor TCanvasWindow_.Done;
begin
     CanvasDrag^.Free;
     DeleteObject(SeveralsMenu);
     inherited Done;
end;

procedure TCanvasWindow_.SetupWindow;
begin
     inherited SetupWindow;
     CanvasDrag := CreateCanvasDrag;
     SetScrollRange(HWindow, SB_HORZ, 0, SCROLLSTEPS, False);
     SetScrollRange(HWindow, SB_VERT, 0, SCROLLSTEPS, False);
     VPos := SCROLLSTEPS div 2;
     HPos := SCROLLSTEPS div 2;
end;

function TCanvasWindow_.CreateCanvasDrag: PDragRoot_;
begin
     CreateCanvasDrag := New(PDragRoot_, Create(@Self));
end;

function TCanvasWindow_.GetClassName: PChar;
begin
     GetClassName := 'CanvasWindow';
end;

procedure TCanvasWindow_.GetWindowClass(var WndClass: TWndClass);
begin
     inherited GetwindowClass(WndClass);
     WndClass.hbrBackGround := GetStockObject(LtGray_Brush);
     WndClass.hCursor := LoadCursor(HInstance, 'CUR_CROSS');
end;

procedure TCanvasWindow_.SetCanvasStatusWindow(ACanvasStatus: PCanvasStatusWindow);
begin
     CanvasStatus := ACanvasStatus;
end;

procedure TCanvasWindow_.SetToolsWindow(ACanvasTools: PCanvasToolsWindow);
begin
     CanvasTools := ACanvasTools;
end;

procedure TCanvasWindow_.EnableCommand(ACommand: Word; AEnable: Boolean);
begin
     if (CanvasStatus <> nil)
     then CanvasStatus^.EnableCommand(ACommand, AEnable);
     if (CanvasTools <> nil)
     then CanvasTools^.EnableCommand(ACommand, AEnable);
end;

procedure TCanvasWindow_.WMSize(var Msg:TMessage);
begin
     SetVerticalPos(VPos, True);
     SetHorizontalPos(HPos, True);
end;

procedure TCanvasWindow_.SnapMouseEvent(var EventInfo: TEventInfo);
begin
     if CanvasDrag^.CanvasInfo.Settings.Snap
     then begin
          EventInfo.LogicPos.X := Round(EventInfo.LogicPos.X / CanvasDrag^.CanvasInfo.Settings.GridSizeX)
                                  * CanvasDrag^.CanvasInfo.Settings.GridSizeX;
          EventInfo.LogicPos.Y := Round(EventInfo.LogicPos.Y / CanvasDrag^.CanvasInfo.Settings.GridSizeY)
                                  * CanvasDrag^.CanvasInfo.Settings.GridSizeY;
          CanvasDrag^.ConvertToView(EventInfo.LogicPos, EventInfo.ViewPos);
          end
end;

procedure TCanvasWindow_.WMRButtonDown(var Msg:TMessage);
var EventInfo: TEventInfo;
begin
     EventInfo.Event := evMouseRDown;
     EventInfo.ViewPos.X := Integer(Msg.LParamLo);
     EventInfo.ViewPos.Y := Integer(Msg.LParamHi);
     CanvasDrag^.ConvertToLogic(EventInfo.ViewPos, EventInfo.LogicPos);
     if ((CanvasDrag^.StateInfo.State <> stEdit)
        and not ((CanvasDrag^.StateInfo.State = stModal)
        and (CanvasDrag^.StateInfo.ModalInfo.ModalType = mtShift)))
     then SnapMouseEvent(EventInfo);
     CanvasDrag^.HandleEvent(EventInfo, nil);
     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;

procedure TCanvasWindow_.WMRButtonUp(var Msg:TMessage);
var EventInfo: TEventInfo;
begin
     EventInfo.Event := evMouseRUp;
     EventInfo.ViewPos.X := Integer(Msg.LParamLo);
     EventInfo.ViewPos.Y := Integer(Msg.LParamHi);
     CanvasDrag^.ConvertToLogic(EventInfo.ViewPos, EventInfo.LogicPos);
     SnapMouseEvent(EventInfo);
     CanvasDrag^.HandleEvent(EventInfo, nil);
     CanvasDrag^.UpdateCommandsStatus;
     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;

procedure TCanvasWindow_.WMLButtonDown(var Msg: TMessage);
var EventInfo: TEventInfo;
begin
     case State
     of cwsNormal: begin
                   EventInfo.Event := evMouseLDown;
                   EventInfo.ViewPos.X := Integer(Msg.LParamLo);
                   EventInfo.ViewPos.Y := Integer(Msg.LParamHi);
                   CanvasDrag^.ConvertToLogic(EventInfo.ViewPos, EventInfo.LogicPos);
                   if ((CanvasDrag^.StateInfo.State <> stEdit)
                      and not ((CanvasDrag^.StateInfo.State = stModal)
                      and (CanvasDrag^.StateInfo.ModalInfo.ModalType = mtShift)))
                   then SnapMouseEvent(EventInfo);
                   CanvasDrag^.HandleEvent(EventInfo, nil);
                   if (CanvasStatus <> nil)
                   then CanvasStatus^.DisplayStatusInfo;
                   end;
        cwsZoomInPosition: begin
                           ZoomPos(Integer(Msg.LParamLo), Integer(Msg.LParamHi), 1);
                           State := cwsNormal;
                           end;
        end;
end;

procedure TCanvasWindow_.WMLButtonUp(var Msg: TMessage);
var EventInfo: TEventInfo;
begin
     EventInfo.Event := evMouseLUp;
     EventInfo.ViewPos.X := Integer(Msg.LParamLo);
     EventInfo.ViewPos.Y := Integer(Msg.LParamHi);
     CanvasDrag^.ConvertToLogic(EventInfo.ViewPos, EventInfo.LogicPos);
     SnapMouseEvent(EventInfo);
     CanvasDrag^.HandleEvent(EventInfo, nil);
     CanvasDrag^.UpdateCommandsStatus;

     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;

procedure TCanvasWindow_.WMMouseMove(var Msg: TMessage);
var EventInfo: TEventInfo;
begin
     EventInfo.Event := evMouseMove;
     EventInfo.ViewPos.X := Integer(Msg.LParamLo);
     EventInfo.ViewPos.Y := Integer(Msg.LParamHi);
     CanvasDrag^.ConvertToLogic(EventInfo.ViewPos, EventInfo.LogicPos);
     SnapMouseEvent(EventInfo);
     if ((LastMouseViewPos.X <> EventInfo.ViewPos.X) or (LastMouseViewPos.Y <> EventInfo.ViewPos.Y))
     then begin
          LastMouseViewPos := EventInfo.ViewPos;
          HideCross;
          CanvasDrag^.HandleEvent(EventInfo, nil);
          CursorPos := EventInfo.LogicPos;
          if (CanvasStatus <> nil)
          then CanvasStatus^.DisplayStatusInfo;
          MoveCrossTo(EventInfo.ViewPos.X, EventInfo.ViewPos.Y);
          ShowCross;
          end;
end;

procedure TCanvasWindow_.WMPaint(var Msg: TMessage);
var DC: HDC;
    PaintStrct: TPaintStruct;
    W,H: Integer;
    OldObject, Bmp: HBitmap;
    Rect: TRect;
    RP: TRPoint;
    P: TPoint;
    OldPen, Pen1, Pen2: HPen;
    DrawInfo: TDrawInfo;

    {BackBrush, OldBrush: HBrush;
    DefaultPen, OldDefaultPen: HPen;}
begin
          DC := BeginPaint(HWindow, PaintStrct);

          {BackBrush := CreateSolidBrush(RGB(0,0,0));
          DefaultPen := CreatePen(PS_SOLID, 1, RGB(255,255,255));
          OldDefaultPen := SelectObject(DC, DefaultPen);

          OldBrush := SelectObject(DC, BackBrush);
          SetBkColor(DC,RGB(0,0,0));}


          GetClientRect(HWindow,Rect);
          W := Rect.Right - Rect.Left;H := Rect.Bottom - Rect.Top;
          Rectangle(DC, - 1, - 1,W + 1,H + 1);
          DrawInfo.DrawDC := DC;
          DrawInfo.ExposedViewRect := Rect;
          P.X := Rect.Left;
          P.Y := Rect.Top;
          CanvasDrag^.ConvertToLogic(P, DrawInfo.ExposedLogicRect.A);
          P.X := Rect.Right;
          P.Y := Rect.Bottom;
          CanvasDrag^.ConvertToLogic(P, DrawInfo.ExposedLogicRect.B);
          CanvasDrag^.Draw(DrawInfo,nil);

          RP.X := 0;
          RP.Y := 0;
          CanvasDrag^.ConvertToView(RP,P);
          Pen1 := CreatePen(PS_DASH, 1, RGB(255,0,0));
          Pen2 := CreatePen(PS_SOLID, 3, RGB(255,0,0));
          OldPen := SelectObject(DC, Pen1);
          MoveTo(DC, Rect.Left, P.Y);
          LineTo(DC, Rect.Right, P.Y);
          MoveTo(DC, P.X, Rect.Top);
          LineTo(DC, P.X, Rect.Bottom);
          SelectObject(DC, Pen2);
          MoveTo(DC, P.X - 20, P.Y);
          LineTo(DC, P.X + 20, P.Y);
          MoveTo(DC, P.X, P.Y - 20);
          LineTo(DC, P.X, P.Y + 20);
          SelectObject(DC, OldPen);
          DeleteObject(Pen1);
          DeleteObject(Pen2);

          {SelectObject(DC, OldBrush);
          DeleteObject(BackBrush);
          SelectObject(DC, OldDefaultPen);
          DeleteObject(DefaultPen);}

          Endpaint(HWindow,PaintStrct);

          UpdateScrollBars;

          if (CanvasStatus <> nil)
          then CanvasStatus^.DisplayStatusInfo;

          if CrossVisible
          then DrawCrossCursor(LastCrossPos.X, LastCrossPos.Y);
end;


procedure TCanvasWindow_.DrawCrossCursor(AX, AY: Integer);
var Rect: TRect;
    DC: HDC;
begin
     GetClientRect(HWindow, Rect);
     DC := GetDC(HWindow);
     SetROP2(DC,r2_Not);
     MoveTO(DC, AX, Rect.Top + 5);
     LineTo(DC, AX, AY - 20);
     MoveTO(DC, AX + 5, Rect.Top);
     LineTo(DC, AX, Rect.Top + 5);
     MoveTO(DC, AX - 5, Rect.Top);
     LineTo(DC, AX, Rect.Top + 5);
     MoveTO(DC, AX + 5, Rect.Top);
     LineTO(DC, AX - 5, Rect.Top);

     MoveTO(DC, AX, Rect.Bottom - 5);
     LineTo(DC, AX, AY + 20);
     MoveTO(DC, AX + 5, Rect.Bottom);
     LineTo(DC, AX, Rect.Bottom - 5);
     MoveTO(DC, AX - 5, Rect.Bottom);
     LineTo(DC, AX, Rect.Bottom - 5);
     MoveTO(DC, AX + 5, Rect.Bottom);
     LineTO(DC, AX - 5, Rect.Bottom);

     MoveTO(DC, Rect.Left + 5, AY);
     LineTO(DC, AX - 20, AY);
     MoveTO(DC, Rect.Left, AY + 5);
     LineTO(DC, Rect.Left + 5, AY);
     MoveTO(DC, Rect.Left, AY - 5);
     LineTO(DC, Rect.Left + 5, AY);
     MoveTO(DC, Rect.Left, AY + 5);
     LineTO(DC, Rect.Left, AY - 5);

     MoveTO(DC, Rect.Right - 5, AY);
     LineTO(DC, AX + 20, AY);
     MoveTO(DC, Rect.Right, AY + 5);
     LineTO(DC, Rect.Right - 5, AY);
     MoveTO(DC, Rect.Right, AY - 5);
     LineTO(DC, Rect.Right - 5, AY);
     MoveTO(DC, Rect.Right, AY + 5);
     LineTo(DC, Rect.Right, AY - 5);

     ReleaseDC(HWindow, DC);
end;

procedure TCanvasWindow_.HideCross;
begin
     if CrossVisible
     then begin
          DrawCrossCursor(LastCrossPos.X, LastCrossPos.Y);
          CrossVisible := False;
          end;
end;

procedure TCanvasWindow_.ShowCross;
begin
     if not CrossVisible
     then begin
          DrawCrossCursor(LastCrossPos.X, LastCrossPos.Y);
          CrossVisible := True;
          end;
end;

procedure TCanvasWindow_.MoveCrossTo(AX, AY: Integer);
begin
     if CrossVisible
     then begin
          HideCross;
          LastCrossPos.X := AX;
          LastCrossPos.Y := AY;
          ShowCross;
          end
     else begin
          LastCrossPos.X := AX;
          LastCrossPos.Y := AY;
          end;
end;


procedure TCanvasWindow_.SetHorizontalPos(APos: Integer; AInvalidate: Boolean);
var Rect: TRect;
    Point1, Point2: TPoint;
    RPoint1, RPoint2: TRPoint;
    ItemsRect, ViewRect: TRRect;
    ViewCenter, ItemsCenter: TRPoint;
    ViewWidth, ItemsWidth: TRPoint;
begin
     HPos := APos;
     GetClientRect(HWindow,Rect);
     Point1.X := Rect.Left;
     Point1.Y := Rect.Top;
     Point2.X := Rect.Right;
     Point2.Y := Rect.Bottom;
     CanvasDrag^.ConvertToLogic(Point1, ViewRect.A);
     CanvasDrag^.ConvertToLogic(Point2, ViewRect.B);
     ViewRect.A.X := ViewRect.A.X - CanvasDrag^.CanvasInfo.Delta.X;
     ViewRect.B.X := ViewRect.B.X - CanvasDrag^.CanvasInfo.Delta.X;
     ItemsRect.A.X := 0;
     ItemsRect.A.Y := 0;
     ItemsRect.B.X := 0;
     ItemsRect.A.Y := 0;
     CanvasDrag^.GetItemsRect(ItemsRect, True);
     ViewCenter.X := (ViewRect.A.X + ViewRect.B.X) / 2;
     ViewCenter.Y := (ViewRect.A.Y + ViewRect.B.Y) / 2;
     ItemsCenter.X := (ItemsRect.A.X + ItemsRect.B.X) / 2;
     ItemsCenter.Y := (ItemsRect.A.Y + ItemsRect.B.Y) / 2;
     ViewWidth.X := ViewRect.B.X - ViewRect.A.X;
     ViewWidth.Y := ViewRect.B.Y - ViewRect.A.Y;
     ItemsWidth.X := ItemsRect.B.X - ItemsRect.A.X;
     ItemsWidth.Y := ItemsRect.B.Y - ItemsRect.A.Y;
     CanvasDrag^.CanvasInfo.Delta.X := ItemsWidth.X*(APos/SCROLLSTEPS)+ItemsRect.A.X-ViewWidth.X/2;
     if AInvalidate
     then begin
          CanvasDrag^.Refresh(True);
          if (CanvasStatus <> nil)
          then CanvasStatus^.DisplayStatusInfo;
          end;
end;

procedure TCanvasWindow_.SetVerticalPos(APos: Integer; AInvalidate: Boolean);
var Rect: TRect;
    Point1, Point2: TPoint;
    RPoint1, RPoint2: TRPoint;
    ItemsRect, ViewRect: TRRect;
    ViewCenter, ItemsCenter: TRPoint;
    ViewWidth, ItemsWidth: TRPoint;
begin
     VPos := APos;
     GetClientRect(HWindow,Rect);
     Point1.X := Rect.Left;
     Point1.Y := Rect.Top;
     Point2.X := Rect.Right;
     Point2.Y := Rect.Bottom;
     CanvasDrag^.ConvertToLogic(Point1, ViewRect.A);
     CanvasDrag^.ConvertToLogic(Point2, ViewRect.B);
     ViewRect.A.X := ViewRect.A.Y - CanvasDrag^.CanvasInfo.Delta.Y;
     ViewRect.B.X := ViewRect.B.Y - CanvasDrag^.CanvasInfo.Delta.Y;
     ItemsRect.A.X := 0;
     ItemsRect.A.Y := 0;
     ItemsRect.B.X := 0;
     ItemsRect.A.Y := 0;
     CanvasDrag^.GetItemsRect(ItemsRect, True);
     ViewCenter.X := (ViewRect.A.X + ViewRect.B.X) / 2;
     ViewCenter.Y := (ViewRect.A.Y + ViewRect.B.Y) / 2;
     ItemsCenter.X := (ItemsRect.A.X + ItemsRect.B.X) / 2;
     ItemsCenter.Y := (ItemsRect.A.Y + ItemsRect.B.Y) / 2;
     ViewWidth.X := ViewRect.B.X - ViewRect.A.X;
     ViewWidth.Y := ViewRect.B.Y - ViewRect.A.Y;
     ItemsWidth.X := ItemsRect.B.X - ItemsRect.A.X;
     ItemsWidth.Y := ItemsRect.B.Y - ItemsRect.A.Y;
     CanvasDrag^.CanvasInfo.Delta.Y := ItemsWidth.Y*(APos/SCROLLSTEPS)+ItemsRect.A.Y-ViewWidth.Y/2;
     if AInvalidate
     then begin
          CanvasDrag^.Refresh(True);
          if (CanvasStatus <> nil)
          then CanvasStatus^.DisplayStatusInfo;
          end;
end;

procedure TCanvasWindow_.WMVScroll(var Msg: TMessage);
begin
     case Msg.wParam
     of SB_THUMBPOSITION: SetVerticalPos(LOWORD(Msg.lParam), True);
        SB_LINEUP: begin
                   if (VPos > 0)
                   then SetVerticalPos(VPos - 1, True);
                   end;
        SB_LINEDOWN: begin
                     if (VPos < SCROLLSTEPS)
                     then SetVerticalPos(VPos + 1, True);
                     end;
        SB_PAGEUP: begin
                   if ((VPos - 10) > 0)
                   then SetVerticalPos(VPos - 10, True)
                   else SetVerticalPos(0, True);
                   end;
        SB_PAGEDOWN: begin
                     if ((VPos + 10) < SCROLLSTEPS)
                     then SetVerticalPos(VPos + 10, True)
                     else SetVerticalPos(SCROLLSTEPS, True);
                     end;
        end;
end;



procedure TCanvasWindow_.WMHScroll(var Msg: TMessage);
begin
     case Msg.wParam
     of SB_THUMBPOSITION: SetHorizontalPos(LOWORD(Msg.lParam), True);
        SB_LINEUP: begin
                   if (HPos > 0)
                   then SetHorizontalPos(HPos - 1, True);
                   end;
        SB_LINEDOWN: begin
                     if (HPos < SCROLLSTEPS)
                     then SetHorizontalPos(HPos + 1, True);
                     end;
        SB_PAGEUP: begin
                   if ((HPos - 10) > 0)
                   then SetHorizontalPos(HPos - 10, True)
                   else SetHorizontalPos(0, True);
                   end;
        SB_PAGEDOWN: begin
                     if ((HPos + 10) <  SCROLLSTEPS)
                     then SetHorizontalPos(HPos + 10, True)
                     else SetHorizontalPos(SCROLLSTEPS, True);
                     end;
        end;
end;

procedure TCanvasWindow_.UpdateScrollBars;
var
    Rect: TRect;
    Point1, Point2: TPoint;
    RPoint1, RPoint2: TRPoint;
    ItemsRect, ViewRect: TRRect;
    ViewCenter, ItemsCenter: TRPoint;
    ViewWidth, ItemsWidth: TRPoint;
begin
     GetClientRect(HWindow,Rect);
     if ((Rect.Left < Rect.Right) and (Rect.Top < Rect.Bottom))
     then begin
          CanvasDrag^.GetItemsRect(ItemsRect, True);
          if ((ItemsRect.A.X < ItemsRect.B.X) and (ItemsRect.A.Y < ItemsRect.B.Y))
          then begin
               Point1.X := Rect.Left;
               Point1.Y := Rect.Top;
               Point2.X := Rect.Right;
               Point2.Y := Rect.Bottom;
               CanvasDrag^.ConvertToLogic(Point1, ViewRect.A);
               CanvasDrag^.ConvertToLogic(Point2, ViewRect.B);
               ViewCenter.X := (ViewRect.A.X + ViewRect.B.X) / 2;
               ViewCenter.Y := (ViewRect.A.Y + ViewRect.B.Y) / 2;
               ItemsCenter.X := (ItemsRect.A.X + ItemsRect.B.X) / 2;
               ItemsCenter.Y := (ItemsRect.A.Y + ItemsRect.B.Y) / 2;
               ViewWidth.X := ViewRect.B.X - ViewRect.A.X;
               ViewWidth.Y := ViewRect.B.Y - ViewRect.A.Y;
               ItemsWidth.X := ItemsRect.B.X - ItemsRect.A.X;
               ItemsWidth.Y := ItemsRect.B.Y - ItemsRect.A.Y;
               HPos := Round(SCROLLSTEPS*((ViewCenter.X - ItemsRect.A.X)/ItemsWidth.X));
               VPos := Round(SCROLLSTEPS*((ViewCenter.Y - ItemsRect.A.Y)/ItemsWidth.Y));
               SetScrollPos(HWindow, SB_HORZ,HPos, True);
               SetScrollPos(HWindow, SB_VERT,VPos, True);
               end;
          end;
end;

procedure TCanvasWindow_.ZoomPos(AX, AY: Integer; AZoomRate: Float);
var ItemsRect: TRRect;
    RPos: TRPoint;
    Pos: TPoint;
    RHPos, RVPos: Float;
begin
     Pos.X := AX;
     Pos.Y := AY;
     CanvasDrag^.ConvertToLogic(Pos, RPos);
     CanvasDrag^.GetItemsRect(ItemsRect, True);
     if RPos.X < ItemsRect.A.X
     then RPos.X := ItemsRect.A.X
     else if RPos.X > ItemsRect.B.X
     then RPos.X := ItemsRect.B.X;
     if RPos.Y < ItemsRect.A.Y
     then RPos.Y := ItemsRect.A.Y
     else if RPos.Y > ItemsRect.B.Y
     then RPos.Y := ItemsRect.B.Y;
     RHPos := ((RPos.X - ItemsRect.A.X) / (ItemsRect.B.X - ItemsRect.A.X)) * SCROLLSTEPS;
     RVPos := ((RPos.Y - ItemsRect.A.Y) / (ItemsRect.B.Y - ItemsRect.A.Y)) * SCROLLSTEPS;
     CanvasDrag^.CanvasInfo.Zoom := CanvasDrag^.CanvasInfo.Zoom * AZoomRate;
     SetVerticalPos(Round(RVPos), True);
     SetHorizontalPos(Round(RHPos), True);
     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;


procedure TCanvasWindow_.ZoomIn;
begin
     if CanvasDrag^.CanvasInfo.Zoom >= MAXZOOM
     then Exit;
     CanvasDrag^.CanvasInfo.Zoom := CanvasDrag^.CanvasInfo.Zoom * 2;
     SetHorizontalPos(HPos, False);
     SetVerticalPos(VPos, False);
     CanvasDrag^.Refresh(True);
     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;

procedure TCanvasWindow_.ZoomOut;
begin
     if (CanvasDrag^.CanvasInfo.Zoom <= MINZOOM)
     then Exit;
     CanvasDrag^.CanvasInfo.Zoom := CanvasDrag^.CanvasInfo.Zoom / 2;
     SetHorizontalPos(HPos, False);
     SetVerticalPos(VPos, False);
     CanvasDrag^.Refresh(True);
     if (CanvasStatus <> nil)
     then CanvasStatus^.DisplayStatusInfo;
end;

procedure TCanvasWindow_.ZoomFit;
begin
end;


procedure TCanvasWindow_.GroupCurrentObject;
begin
     CanvasDrag^.Group;
end;

procedure TCanvasWindow_.UnGroupCurrentObject;
begin
     CanvasDrag^.UnGroup;
end;


procedure TCanvasWindow_.DeleteCurrentObject;
begin
     CanvasDrag^.MakeEffect(efDeleteCurrent, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.FlipHorizontal;
var EffectInfo: TFlipEffectInfo;
begin
     EffectInfo.Center.X := 0;
     EffectInfo.Center.Y := 0;
     EffectInfo.DeterminedCenter := False;
     CanvasDrag^.MakeEffect(efFlipHorizontal, EffectInfo, nil);
end;

procedure TCanvasWindow_.FlipVertical;
var EffectInfo: TFlipEffectInfo;
begin
     EffectInfo.Center.X := 0;
     EffectInfo.Center.Y := 0;
     EffectInfo.DeterminedCenter := False;
     CanvasDrag^.MakeEffect(efFlipVertical, EffectInfo, nil);
end;

procedure TCanvasWindow_.Rotate;
var EffectInfo: TRotationEffectInfo;
    Angle: Float;
begin
     Angle := GetAngle(@Self);
     if (Angle <> 0)
     then begin
          EffectInfo.Center.X := 0;
          EffectInfo.Center.Y := 0;
          EffectInfo.DeterminedCenter := False;
          EffectInfo.Cos := Cos(Angle * Pi / 180);
          EffectInfo.Sin := Sin(Angle * Pi / 180);
          CanvasDrag^.MakeEffect(efRotate, EffectInfo, nil);
          end;
end;

procedure TCanvasWindow_.Streach;
begin
     CanvasDrag^.MakeEffect(efStreach, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.Clone;
begin
     CanvasDrag^.MakeEffect(efClone, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.FlipStopPoint;
begin
     CanvasDrag^.MakeEffect(efFlipStopPoint, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.Separate;
begin
     CanvasDrag^.MakeEffect(efSeparate, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.AppendPoints;
begin
     CanvasDrag^.MakeEffect(efAppendPoints, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.MakeFirst;
begin
     CanvasDrag^.MakeEffect(efMakeFirst, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.BuildTwinDrawnItem;
var Info: TItemBuildInfo;
begin
     Info.ItemType := itTwin;
     CanvasDrag^.MakeEffect(efAppendPathToItem, Info, nil);
end;

procedure TCanvasWindow_.BuildLinearDrawnItem;
var Info: TItemBuildInfo;
begin
     Info.ItemType := itLinear;
     CanvasDrag^.MakeEffect(efAppendPathToItem, Info, nil);
end;

procedure TCanvasWindow_.InsertNewPollygon;
begin
     CanvasDrag^.MakeEffect(efAppendNewObject, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.EditItemPropery;
begin
     CanvasDrag^.MakeEffect(efEditProperty, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.ZoomInPosition;
begin
     State := cwsZoomInPosition;
end;

procedure TCanvasWindow_.GotoPreview;
begin
     CanvasDrag^.MakeEffect(efGotoPreview, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.EditGuitLines;
begin
     CanvasDrag^.MakeEffect(efEditGuideLines, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.CreateArray;
begin
     CanvasDrag^.MakeEffect(efArray, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.ReversePath;
begin
     CanvasDrag^.MakeEffect(efReversePath, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.MakeFisrt(var Msg: TMessage);
begin
end;

procedure TCanvasWindow_.EditCanvasOptions;
begin
     CanvasDrag^.MakeEffect(efEditCanvasOptions, PChar(nil)^, nil);
end;

procedure TCanvasWindow_.AllignItems;
begin
     CanvasDrag^.ResponceAction := raAllign;
     CanvasDrag^.MakeEffect(efAllign, PChar(nil)^, nil);
end;

end.