unit Canvas2;

interface

uses WinTypes, WinProcs, OWindows, WIN31,
     Generics, SpeedButtons, Aligner, Streams,
     DlgBoxes, Canvas1, DataTypes;

const
     MultiPointCount = 3;

type

    PDragRoot = ^TDragRoot;
    TDragRoot = object(TDragRoot_)
       procedure LoadFromStreamAsSymbol(AStream: PStream); virtual;
       function HandleRootEvent( var EventInfo: TEventInfo):Boolean; virtual;
       procedure SendAsResponse( AObject: PDragObject); virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       function CreateObjectInstance(ATypeId: Word): PDragObject; virtual;
       procedure InsertNewObject(ANewObjectData: TNewObjectData); virtual;
       end;

    PCanvasWindow = ^TCanvasWindow;
    TCanvasWindow = object(TCanvasWindow_)
       function CreateCanvasDrag: PDragRoot_; virtual;
       end;


    PDragPoint = ^TDragPoint;
    TDragPoint = object(TDragObject)
       Origin: TRPoint;
       constructor Create( X, Y: Float);
       destructor Destroy;virtual;
       function HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function IsGrouped: Boolean; virtual;
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       function ContainsPoint( APoint:TPoint):Boolean;
       procedure MoveToPos( var APos:TPoint); virtual;
       procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
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

    PStopPoint = ^TStopPoint;
    TStopPoint = object(TDragPoint)
       constructor Create( X,Y: Float);
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure GenerateOutput(AOutputGenerator: POutputGenerator); virtual;
       function HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       end;

    PDragMultiPoint = ^TDragMultiPoint;
    TDragMultiPoint = object(TDragObject)
       Origin: array[1..MultiPointCount] of TRPoint;
       constructor Create( X, Y: Float);
       destructor Destroy;virtual;
       function HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function IsGrouped: Boolean; virtual;
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       function GetPointId( APoint: TPoint): Integer;
       procedure MoveToPos( var APos:TPoint); virtual;
       procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
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

    PDragPollygonPoint = ^TDragPollygonPoint;
    TDragPollygonPoint = object(TDragPoint)
       StopPoint: Boolean;
       constructor Create( X,Y: Float);
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure MakeClone(AOwner: PDragObject); virtual;
       end;

    PDragBezierPoint = ^TDragBezierPoint;
    TDragBezierPoint = object(TDragMultiPoint)
       StopPoint: Boolean;
       procedure DrawBezier( var DrawInfo: TDrawInfo; P0,P1,P2,P3: TRPoint);
       constructor Create( X,Y: Float);
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure MakeClone(AOwner: PDragObject); virtual;
       end;


    PPath = ^TPath;
    TPath = object(TDragGroup)
       function GetSectionLength(ASection: Longint): Float; virtual;
       function GetSectionsCount: Longint; virtual;
       function GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint; virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;

    PDragPolligon = ^TDragPolligon;
    TDragPolligon = object(TPath)
       constructor Create;
       destructor Destroy; virtual;
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       function ContainsPoint( APoint:TPoint):Boolean;
       function HandleEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function GetTheCurrent: PDragObject; virtual;
       function GetSectionLength(ASection: Longint): Float; virtual;
       function GetSectionsCount: Longint; virtual;
       function GetSectionLimits(ASection: Longint; var AStart: PDragPollygonPoint;var AStop: PDragPollygonPoint): Boolean;
       function GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint; virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;

    PDragBezier = ^TDragBezier;
    TDragBezier = object(TPath)
    private
       procedure DrawBezier( var DrawInfo: TDrawInfo; P0,P1,P2,P3: TRPoint);
       function GetBezierLength(P0,P1,P2,P3: TRPoint; ACount: Longint): Float;
       procedure GetBezierPath( P0,P1,P2,P3: TRPoint; ACount: Longint;
                                var AFirstPathPoint: PPathPoint; var ALastPathPoint: PPathPoint);
    public
       constructor Create;
       destructor Destroy; virtual;
       procedure Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       function ContainsPoint( APoint:TPoint):Boolean;
       function HandleEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function GetTheCurrent: PDragObject; virtual;
       function GetSectionLength(ASection: Longint): Float; virtual;
       function GetSectionsCount: Longint; virtual;
       function GetSectionLimits(ASection: Longint; var AStart: PDragBezierPoint; var AStop: PDragBezierPoint): Boolean;
       function GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint; virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean); virtual;
       end;


    PDrawnItem = ^TDrawnItem;
    TDrawnItem = object(TDragGroup)
       LableOrigin: TPoint;
       LableSize: TPoint;
       procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       function HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean; virtual;
       function ContainsPoint( APoint:TPoint):Boolean;
       procedure DisplayLabel(var DrawInfo: TDrawInfo; AX, AY: Integer; ALable: string); virtual;
       function MakeSelfClone: PDragObject; virtual;
       end;

    TTwinDrawnItemProperties = record
       Density: Float;
       StepMode: Integer;
       StepLength: Float;
       StepsCount: Longint;
       end;

    PTwinDrawnItem = ^TTwinDrawnItem;
    TTwinDrawnItem = object(TDrawnItem)
       PathPoints: PPathPoint;
       Density: Float;
       StepMode: Integer;
       StepLength: Float;
       StepsCount: Longint;
       constructor Create;
       destructor Destroy; virtual;
       procedure LeaveChild(AChild: PDragObject); virtual;
       function HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;virtual;
       procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure GenerateOutput(AOutputGenerator: POutputGenerator); virtual;
       function GetPathPoints: PPathPoint; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure Refresh(APassToOwner: Boolean); virtual;
       function IsLockedChild(AChild: PDragObject): Boolean; virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;

    TLinearDrawnItemProperties = record
       Density: Float;
       Mode: Word;
       Width: Float;
       end;

    PLinearDrawnItem = ^TLinearDrawnItem;
    TLinearDrawnItem = object(TDrawnItem)
       PathPoints: PPathPoint;
       Density: Float;
       Mode: Word;
       Width: Float;
       constructor Create;
       destructor Destroy; virtual;
       procedure LeaveChild(AChild: PDragObject); virtual;
       function HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;virtual;
       procedure Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo); virtual;
       procedure GenerateOutput(AOutputGenerator: POutputGenerator); virtual;
       function GetPathPoints: PPathPoint; virtual;
       procedure MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo); virtual;
       procedure CopySelfTo(AObject: PDragObject); virtual;
       function MakeSelfClone: PDragObject; virtual;
       procedure Refresh(APassToOwner: Boolean); virtual;
       function IsLockedChild(AChild: PDragObject): Boolean; virtual;
       procedure GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo); virtual;
       procedure LoadFromStream(AStream: PStream); virtual;
       procedure WriteToStream(AStream: PStream); virtual;
       function GetTypeId: Word; virtual;
       end;



implementation

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

const DefTwinDrawnItemProperties: TTwinDrawnItemProperties = (
       Density: 3;
       StepMode: 2;
       StepLength: 30;
       StepsCount: 1);

    DefLinearDrawnItemProperties: TLinearDrawnItemProperties = (
       Density: 3;
       Mode: 1;
       Width: 0);


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

var NewObjectData: TNewObjectData;

procedure TDragRoot.LoadFromStreamAsSymbol(AStream: PStream);
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
          {ContainerGroup := New(PDragGroup, Create);}
          ContainerGroup := New(PDrawnItem, Create);
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

function TDragRoot.HandleRootEvent( var EventInfo: TEventInfo):Boolean;
var RRect: TRRect;
    Point: TPoint;
    Shifter: PDragShifter;
    TempFloat: Float;
    RPoint: TRPoint;
    NewObjectData: TNewObjectData;
    MouseState: Word;

    procedure DrawNewObjectShape(ADC: HDC; var ANewObjectData: TNewObjectData);
    var Point1, Point2: TPoint;
        RPoint: TRPoint;
        Brush, OldBrush: HBrush;
        LB: TLOGBRUSH;
    begin
         case ANewObjectData.DrawObject
         of doPolligon: begin
                        end;
            doBezier: begin
                      end;
            doStopPoint: begin
                         end;
            doLine: begin
                    RPoint.X := ANewObjectData.X1;
                    RPoint.Y := ANewObjectData.Y1;
                    ConvertToView( RPoint, Point1);
                    RPoint.X := ANewObjectData.X2;
                    RPoint.Y := ANewObjectData.Y2;
                    ConvertToView( RPoint, Point2);
                    MoveTo(ADC, Point1.X, Point1.Y);
                    LineTo(ADC, Point2.X, Point2.Y);
                    end;
            doRectangle: begin
                         RPoint.X := ANewObjectData.X1;
                         RPoint.Y := ANewObjectData.Y1;
                         ConvertToView( RPoint, Point1);
                         RPoint.X := ANewObjectData.X2;
                         RPoint.Y := ANewObjectData.Y2;
                         ConvertToView( RPoint, Point2);
                         MoveTo(ADC, Point1.X, Point1.Y);
                         LineTo(ADC, Point2.X, Point1.Y);
                         LineTo(ADC, Point2.X, Point2.Y);
                         LineTo(ADC, Point1.X, Point2.Y);
                         LineTo(ADC, Point1.X, Point1.Y);
                         end;
            doEllipse: begin
                       RPoint.X := ANewObjectData.X1;
                       RPoint.Y := ANewObjectData.Y1;
                       ConvertToView( RPoint, Point1);
                       RPoint.X := ANewObjectData.X2;
                       RPoint.Y := ANewObjectData.Y2;
                       ConvertToView( RPoint, Point2);
                       MoveTo(ADC, Point1.X, Point1.Y);
                       LineTo(ADC, Point2.X, Point1.Y);
                       LineTo(ADC, Point2.X, Point2.Y);
                       LineTo(ADC, Point1.X, Point2.Y);
                       LineTo(ADC, Point1.X, Point1.Y);
                       FillChar(LB, SizeOf(LB), #0);
                       LB.lbStyle := BS_NULL;
                       Brush := CreateBrushIndirect(LB);
                       OldBrush := SelectObject(ADC, Brush);
                       Ellipse(ADC, Point1.X, Point1.Y, Point2.X, Point2.Y);
                       SelectObject(ADC, OldBrush);
                       DeleteObject(Brush);
                       end;
            end;
    end;
begin
     case EventInfo.Event
     of evMouseLDown: begin
                      if (StateInfo.State = stEdit)
                      then begin
                           SetState(stDrag, @Self);
                           StateInfo.DragInfo.DragType := dtRectularSellect;
                           StateInfo.DragInfo.Rect.Top := EventInfo.ViewPos.Y;
                           StateInfo.DragInfo.Rect.Left := EventInfo.ViewPos.X;
                           StateInfo.DragInfo.Rect.Bottom := EventInfo.ViewPos.Y;
                           StateInfo.DragInfo.Rect.Right := EventInfo.ViewPos.X;
                           SetROP2(StateInfo.DragInfo.DrawInfo.DrawDC,r2_Not);
                           DrawSellectRectangle(StateInfo.DragInfo.DrawInfo, StateInfo.DragInfo.Rect);
                           HandleRootEvent := True;
                           end
                      else if StateInfo.State = stModal
                      then case StateInfo.ModalInfo.ModalType
                           of mtAppendNewObject: begin
                                                 case StateInfo.ModalInfo.NewObjectData.DrawObject
                                                 of doStopPoint,
                                                    doPolligon: begin
                                                                ConvertToLogic(EventInfo.ViewPos, RPoint);
                                                                StateInfo.ModalInfo.NewObjectData.X1 := RPoint.X;
                                                                StateInfo.ModalInfo.NewObjectData.Y1 := RPoint.Y;
                                                                LockRefresh;
                                                                SetState(stEdit, @Self);
                                                                UnlockRefresh;
                                                                InsertNewObject(StateInfo.ModalInfo.NewObjectData);
                                                                end;
                                                    doBezier: begin
                                                              ConvertToLogic(EventInfo.ViewPos, RPoint);
                                                              StateInfo.ModalInfo.NewObjectData.X1 := RPoint.X;
                                                              StateInfo.ModalInfo.NewObjectData.Y1 := RPoint.Y;
                                                              LockRefresh;
                                                              SetState(stEdit, @Self);
                                                              UnlockRefresh;
                                                              InsertNewObject(StateInfo.ModalInfo.NewObjectData);
                                                              end;
                                                    doEllipse,
                                                    doRectangle,
                                                    doLine: begin
                                                            ConvertToLogic(EventInfo.ViewPos, RPoint);
                                                            StateInfo.ModalInfo.NewObjectData.X1 := RPoint.X;
                                                            StateInfo.ModalInfo.NewObjectData.Y1 := RPoint.Y;
                                                            StateInfo.ModalInfo.NewObjectData.X2 := RPoint.X;
                                                            StateInfo.ModalInfo.NewObjectData.Y2 := RPoint.Y;
                                                            StateInfo.ModalInfo.MouseState := 1;

                                                            NewObjectData := StateInfo.ModalInfo.NewObjectData;
                                                            MouseState := StateInfo.ModalInfo.MouseState;

                                                            SetState(stDrag, @Self);
                                                            if StateInfo.State = stDrag
                                                            then begin
                                                                 StateInfo.DragInfo.DragType := dtInsertNewObject;
                                                                 StateInfo.DragInfo.NewObjectData := NewObjectData;
                                                                 StateInfo.DragInfo.MouseState := MouseState;
                                                                 SetROP2(StateInfo.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                                 DrawNewObjectShape( StateInfo.DragInfo.DrawInfo.DrawDC,
                                                                                     NewObjectData);
                                                                 end;
                                                            end;
                                                    else
                                                        SetState(stEdit, @Self);
                                                    end;
                                                 end;
                           else
                               HandleRootEvent := False;
                           end
                      else HandleRootEvent := False;
                      end;
        evMouseLUp: begin
                    case StateInfo.DragInfo.DragType
                    of dtRectularSellect:
                          begin
                          if (StateInfo.State = stDrag)
                          then begin
                               DrawSellectRectangle(StateInfo.DragInfo.DrawInfo, StateInfo.DragInfo.Rect);
                               Stateinfo.DragInfo.Rect.Bottom := EventInfo.ViewPos.Y;
                               Stateinfo.DragInfo.Rect.Right := EventInfo.ViewPos.X;
                               Point.X := Stateinfo.DragInfo.Rect.Left;
                               Point.Y := Stateinfo.DragInfo.Rect.Top;
                               ConvertToLogic(Point, RRect.A);
                               Point.X := Stateinfo.DragInfo.Rect.Right;
                               Point.Y := Stateinfo.DragInfo.Rect.Bottom;
                               ConvertToLogic(Point, RRect.B);
                               if (RRect.B.X < RRect.A.X)
                               then begin
                                    TempFloat := RRect.B.X;
                                    RRect.B.X := RRect.A.X;
                                    RRect.A.X := TempFloat;
                                    end;
                               if (RRect.B.Y < RRect.A.Y)
                               then begin
                                    TempFloat := RRect.B.Y;
                                    RRect.B.Y := RRect.A.Y;
                                    RRect.A.Y := TempFloat;
                                    end;

                               ResponceAction := raCreateShifter;
                               if (Collection <> nil)
                               then Collection^.Free;
                               Collection := New(PCollection, Create);
                               MakeEffect(efGetInRectObjects, RRect, @StateInfo);
                               SetState(stEdit, @Self);

                               if (Collection^.GetItemsCount > 0)
                               then begin
                                    Shifter := New(PDragShifter, Create(RRect.A.X, RRect.A.Y,
                                            RRect.B.X - RRect.A.X, RRect.B.Y - RRect.A.Y, Collection));
                                    Collection := nil;
                                    Insert(Shifter);
                                    Shifter^.MakeCurrent;
                                    SetState(stModal, Shifter);
                                    if (Stateinfo.State = stModal)
                                    then StateInfo.ModalInfo.ModalType := mtShift;
                                    RefreshFromChilds(True);
                                    end
                               else begin
                                    Collection^.Free;
                                    Collection := nil;
                                    end;
                               HandleRootEvent := True;
                               end;
                         end;
                       dtInsertNewObject: begin
                                          DrawNewObjectShape( StateInfo.DragInfo.DrawInfo.DrawDC,
                                                              NewObjectData);
                                          ConvertToLogic(EventInfo.ViewPos, RPoint);
                                          StateInfo.DragInfo.NewObjectData.X2 := RPoint.X;
                                          StateInfo.DragInfo.NewObjectData.Y2 := RPoint.Y;
                                          StateInfo.DragInfo.MouseState := 0;
                                          NewObjectData := StateInfo.DragInfo.NewObjectData;
                                          LockRefresh;
                                          SetState(stEdit, @Self);
                                          UnlockRefresh;
                                          InsertNewObject(NewObjectData);
                                          end;
                       else HandleRootEvent := False;
                       end;
                    end;
        evMouseMove: begin
                     if (StateInfo.State = stDrag)
                     then case StateInfo.DragInfo.DragType
                          of dtRectularSellect: begin
                                                DrawSellectRectangle( StateInfo.DragInfo.DrawInfo,
                                                                      StateInfo.DragInfo.Rect);
                                                StateInfo.DragInfo.Rect.Bottom := EventInfo.ViewPos.Y;
                                                StateInfo.DragInfo.Rect.Right := EventInfo.ViewPos.X;
                                                DrawSellectRectangle( StateInfo.DragInfo.DrawInfo,
                                                                      StateInfo.DragInfo.Rect);
                                                HandleRootEvent := True;
                                                end;
                             dtInsertNewObject: begin
                                                DrawNewObjectShape( StateInfo.DragInfo.DrawInfo.DrawDC,
                                                                    StateInfo.DragInfo.NewObjectData);
                                                ConvertToLogic(EventInfo.ViewPos, RPoint);
                                                StateInfo.DragInfo.NewObjectData.X2 := RPoint.X;
                                                StateInfo.DragInfo.NewObjectData.Y2 := RPoint.Y;
                                                DrawNewObjectShape( StateInfo.DragInfo.DrawInfo.DrawDC,
                                                                    StateInfo.DragInfo.NewObjectData);
                                                end;

                          else
                              HandleRootEvent := False;
                          end
                     else HandleRootEvent := False;
                     end;
        else
            HandleRootEvent := False;
        end;
end;

procedure TDragRoot.SendAsResponse( AObject: PDragObject);
var RP:TRPoint;
    TwinProperty: TTwinPropertyRec;
    LinearProperty: TLinearPropertyRec;
    Menu: HMenu;
    Pos: TPoint;
    Action: TSequenceAction;
    Allign: TAllignAction;
    TempOwner: PDragObject;
    StraechData: TStreachData;
    RRect: TRRect;
begin
     case ResponceAction
     of raCreateTwinItem: begin
                          if ((NewItem <> nil) and (AObject <> nil))
                          then begin
                               if not AObject^.IsLockedByParent
                               then begin
                                    if (AObject^.Owner <> nil)
                                    then AObject^.Owner^.LeaveChild(AObject);
                                    NewItem^.Insert(AObject);
                                    if (NewItem^.GetChildsCount = 2)
                                    then begin
                                         LockRefresh;
                                         Insert(NewItem);
                                         AObject^.MakeCurrent;
                                         UnlockRefresh;
                                         NewItem^.RefreshFromChilds(True);
                                         NewItem := nil;
                                         end
                                    else Refresh(True);
                                    end;
                               end;
                          end;
        raCreateLinearItem: begin
                            if ((NewItem <> nil) and (AObject <> nil))
                            then begin
                                 if not AObject^.IsLockedByParent
                                 then begin
                                      if (AObject^.Owner <> nil)
                                      then AObject^.Owner^.LeaveChild(AObject);
                                      NewItem^.Insert(AObject);
                                      LockRefresh;
                                      Insert(NewItem);
                                      AObject^.MakeCurrent;
                                      UnlockRefresh;
                                      NewItem^.RefreshFromChilds(True);
                                      NewItem := nil;
                                      end;
                                 end;
                            end;
        raCreateShifter: begin
                         if ((AObject <> nil) and (Collection <> nil))
                         then Collection^.PushLast(AObject);
                         end;
        raSetListPosition: begin
                           if (AObject <> nil)
                           then begin
                                GetSequenceAction(CanvasWindow, Action, 0,0);
                                case Action
                                of saNone: begin
                                           end;
                                   saMakeFirst: begin
                                                AObject^.MakeFirst;
                                                RefreshFromChilds(True);
                                                end;
                                   saMakeLast: begin
                                               AObject^.MakeLast;
                                               RefreshFromChilds(True);
                                               end;
                                   saMoveForward: begin
                                                  AObject^.MakeAfterNext;
                                                  RefreshFromChilds(True);
                                                  end;
                                   saMoveBack: begin
                                               AObject^.MakeBeforePrev;
                                               RefreshFromChilds(True);
                                               end;
                                   saFlipPath: begin
                                               MakeEffect(efReversePath, PChar(nil)^, nil);
                                               RefreshFromChilds(True);
                                               end;
                                   end;
                                end;
                           end;
        raAllign: begin
                  if (AObject <> nil)
                  then begin
                       GetAllignAction(CanvasWindow, Allign);
                       case Allign
                       of aaNone: begin
                                  end;
                          aaTop: begin
                                 AObject^.MakeEffect(efAllignTop, PChar(nil)^, @StateInfo);
                                 end;
                          aaBottom: begin
                                    AObject^.MakeEffect(efAllignBottom, PChar(nil)^,  @StateInfo);
                                    end;
                          aaLeft: begin
                                  AObject^.MakeEffect(efAllignLeft, PChar(nil)^,  @StateInfo);
                                  end;
                          aaRight: begin
                                   AObject^.MakeEffect(efAllignRight, PChar(nil)^,  @StateInfo);
                                   end;
                          aaVerCenter: begin
                                       AObject^.MakeEffect(efAllignCenterVer, PChar(nil)^,  @StateInfo);
                                       end;
                          aaHorCenter: begin
                                       AObject^.MakeEffect(efAllignCenterHor, PChar(nil)^,  @StateInfo);
                                       end;
                          end;
                       end;
                  end;
        raStreach: begin
                   if (AObject <> nil)
                   then begin
                        AObject^.GetItemsRect(RRect, True);
                        if ((RRect.B.X <> RRect.A.X) and (RRect.B.Y <> RRect.A.Y))
                        then begin
                             StraechData.XSize := RRect.B.X - RRect.A.X;
                             StraechData.YSize := RRect.B.Y - RRect.A.Y;
                             if GetStreachInfo(CanvasWindow, StraechData)
                             then begin
                                  LockRefresh;
                                  AObject^.Expand(RRect.A, StraechData.XSize / (RRect.B.X - RRect.A.X),
                                                      StraechData.YSize / (RRect.B.Y - RRect.A.Y));
                                  UnlockRefresh;
                                  AObject^.RefreshFromChilds(True);
                                  end;
                             end
                        else if (RRect.B.X <> RRect.A.X)
                        then begin
                             StraechData.XSize := RRect.B.X - RRect.A.X;
                             if GetStreachInfo(CanvasWindow, StraechData)
                             then begin
                                  LockRefresh;
                                  AObject^.Expand(RRect.A, StraechData.XSize / (RRect.B.X - RRect.A.X), 1);
                                  UnlockRefresh;
                                  AObject^.RefreshFromChilds(True);
                                  end;
                             end
                        else if (RRect.B.Y <> RRect.A.Y)
                        then begin
                             StraechData.YSize := RRect.B.Y - RRect.A.Y;
                             if GetStreachInfo(CanvasWindow, StraechData)
                             then begin
                                  LockRefresh;
                                  AObject^.Expand(RRect.A, 1, StraechData.YSize / (RRect.B.Y - RRect.A.Y));
                                  UnlockRefresh;
                                  AObject^.RefreshFromChilds(True);
                                  end;
                             end
                        end;
                   end;
        raEditProperty: begin
                        if (AObject <> nil)
                        then case AObject^.GetTypeId
                             of tiTwinDrawnItem: begin
                                                 TwinProperty.Densety := PTwinDrawnItem(AObject)^.Density;
                                                 TwinProperty.StepMode := PTwinDrawnItem(AObject)^.StepMode;
                                                 TwinProperty.StepLength := PTwinDrawnItem(AObject)^.StepLength;
                                                 TwinProperty.StepsCount := PTwinDrawnItem(AObject)^.StepsCount;
                                                 if EditTwinProperties(CanvasWindow, TwinProperty)
                                                 then begin
                                                      PTwinDrawnItem(AObject)^.Density := TwinProperty.Densety;
                                                      PTwinDrawnItem(AObject)^.StepMode := TwinProperty.StepMode;
                                                      PTwinDrawnItem(AObject)^.StepLength := TwinProperty.StepLength;
                                                      PTwinDrawnItem(AObject)^.StepsCount := TwinProperty.StepsCount;

                                                      DefTwinDrawnItemProperties.Density := TwinProperty.Densety;
                                                      DefTwinDrawnItemProperties.StepMode := TwinProperty.StepMode;
                                                      DefTwinDrawnItemProperties.StepLength := TwinProperty.StepLength;
                                                      DefTwinDrawnItemProperties.StepsCount := TwinProperty.StepsCount;
                                                      end;
                                                 AObject^.Refresh(True);
                                                 end;
                                tiLinearDrawnItem: begin
                                                   LinearProperty.Densety := PLinearDrawnItem(AObject)^.Density;
                                                   LinearProperty.Width := PLinearDrawnItem(AObject)^.Width;
                                                   LinearProperty.Mode := PLinearDrawnItem(AObject)^.Mode;
                                                   if EditLinearProperties(CanvasWindow, LinearProperty)
                                                   then begin
                                                        PLinearDrawnItem(AObject)^.Density := LinearProperty.Densety;
                                                        PLinearDrawnItem(AObject)^.Width := LinearProperty.Width;
                                                        PLinearDrawnItem(AObject)^.Mode := LinearProperty.Mode;

                                                        DefLinearDrawnItemProperties.Density := LinearProperty.Densety;
                                                        DefLinearDrawnItemProperties.Width := LinearProperty.Width;
                                                        DefLinearDrawnItemProperties.Mode := LinearProperty.Mode;
                                                        end;
                                                   AObject^.Refresh(True);
                                                   end;
                             end;
                        end;
        end;
end;

procedure TDragRoot.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var ArrayInfo: TArrayInfo;
begin
     case AEffect
     of efAppendPathToItem: begin
                            case TItemBuildInfo(AEffectInfo).ItemType
                            of itTwin: begin
                                       if (NewItem = nil)
                                       then NewItem := New(PTwinDrawnItem, Create);
                                       ResponceAction := raCreateTwinItem;
                                       end;
                               itLinear: begin
                                         if (NewItem <> nil)
                                         then NewItem^.Free;
                                         NewItem := New(PLinearDrawnItem, Create);
                                         ResponceAction := raCreateLinearItem;
                                         end;
                               end;
                            inherited MakeEffect(AEffect, AEffectInfo, @StateInfo);
                            end;
        efGotoNormalState: begin
                           case StateInfo.State
                           of stDrag: begin
                                      StateInfo.DragInfo.DragObject^.MakeEffect( efGotoNormalState, AEffectInfo,
                                                                                 @StateInfo);
                                      end;
                              stModal: begin
                                       StateInfo.ModalInfo.ModalObject^.MakeEffect( efGotoNormalState, AEffectInfo,
                                                                                    @StateInfo);
                                       end;
                              end;
                           end;
        efEditCanvasOptions: begin
                      EditOptions(CanvasWindow, CanvasInfo.Settings);
                      RefreshFromChilds(True);
                      end;
        efAppendNewObject: begin
                             if GetObjectData(CanvasWindow, NewObjectData)
                             then begin
                                  if (NewObjectData.DrawObject <> doNone)
                                  then begin
                                       if NewObjectData.UsingMouse
                                       then begin
                                            SetState(stModal, @Self);
                                            if (Stateinfo.State = stModal)
                                            then begin
                                                 Stateinfo.ModalInfo.NewObjectData := NewObjectData;
                                                 Stateinfo.ModalInfo.MouseState := 0;
                                                 StateInfo.ModalInfo.ModalType := mtAppendNewObject;
                                                 RefreshFromChilds(True);
                                                 end;
                                            end
                                       else begin
                                            InsertNewObject(NewObjectData);
                                            end;
                                       end;
                                  end;
                             end;
        efEditProperty: begin
                        ResponceAction := raEditProperty;
                        inherited MakeEffect(AEffect, AEffectInfo, @StateInfo);
                        end;
        efStreach: begin
                   ResponceAction := raStreach;
                   inherited MakeEffect(AEffect, AEffectInfo, @StateInfo);
                   end;
        efEditGuideLines: begin
                          EditGuideLines(CanvasWindow, GuideLinesInfoRec);
                          Refresh(True);
                          end;
        efArray: begin
                 EditArray(CanvasWindow, ArrayInfo);
                 end;
        efGotoPreview: begin
                       if StateInfo.State = stEdit
                       then begin
                            inherited MakeEffect(efInitPreviewData, AEffectInfo, @StateInfo);
                            ResponceAction := raSetListPosition;
                            SetState(stPreview, @Self);
                            Refresh(True);
                            end
                       else begin
                            inherited MakeEffect(efFreePreviewData, AEffectInfo, @StateInfo);
                            SetState(stEdit, @Self);
                            Refresh(True);
                            end;

                       end;
     else
         inherited MakeEffect(AEffect, AEffectInfo, @StateInfo);
     end;
end;

function TDragRoot.CreateObjectInstance(ATypeId: Word): PDragObject;
begin
     case ATypeId
     of tiDragObject: CreateObjectInstance := New(PDragObject, Create);
        tiDragGroup: CreateObjectInstance := New(PDragGroup, Create);
        tiDragRoot: CreateObjectInstance := nil;
        tiDragPoint: CreateObjectInstance := New(PDragPoint, Create(0,0));
        tiStopPoint: CreateObjectInstance := New(PStopPoint, Create(0,0));
        tiDragShifter: CreateObjectInstance := nil;
        tiDragPollygonPoint: CreateObjectInstance := New(PDragPollygonPoint, Create(0,0));
        tiPath: CreateObjectInstance := New(PPath, Create);
        tiDragPolligon: CreateObjectInstance := New(PDragPolligon, Create);
        tiDrawnItem: CreateObjectInstance := New(PDrawnItem, Create);
        tiTwinDrawnItem: CreateObjectInstance := New(PTwinDrawnItem, Create);
        tiLinearDrawnItem: CreateObjectInstance := New(PLinearDrawnItem, Create);
        tiDragMultiPoint: CreateObjectInstance := New(PDragMultiPoint, Create(0,0));
        tiDragBezierPoint: CreateObjectInstance := New(PDragBezierPoint, Create(0,0));
        tiDragBezier: CreateObjectInstance := New(PDragBezier, Create);
        else
            CreateObjectInstance := nil;
        end
end;

procedure TDragRoot.InsertNewObject(ANewObjectData: TNewObjectData);
var TempPoint: PDragPollygonPoint;
    TempPol: PDragPolligon;
    TempBezier: PDragBezier;
    TempBezierPoint: PDragBezierPoint;
    TempStopPoint: PStopPoint;
    Length: Float;
    LengthDelta: Float;
    Delta: TRPoint;
    NewPos: TRPoint;
    Count: Longint;
    RadX, RadY: Float;
    Center: TRPoint;
begin
     case ANewObjectData.DrawObject
     of doPolligon: begin
                    LockRefresh;
                    TempPol := New(PDragPolligon, Create);
                    TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X1, ANewObjectData.Y1));
                    TempPol^.Insert(TempPoint);
                    Insert(TempPol);
                    SetState(stEdit, @Self);
                    TempPoint^.MakeCurrent;
                    UnlockRefresh;
                    TempPol^.RefreshFromChilds(True);
                    end;
        doBezier: begin
                  LockRefresh;
                  TempBezier := New(PDragBezier, Create);
                  TempBezierPoint := New(PDragBezierPoint, Create( ANewObjectData.X1, ANewObjectData.Y1));
                  TempBezier^.Insert(TempBezierPoint);
                  Insert(TempBezier);
                  SetState(stEdit, @Self);
                  TempBezierPoint^.MakeCurrent;
                  UnlockRefresh;
                  TempBezier^.RefreshFromChilds(True);
                  end;
        doStopPoint: begin
                     LockRefresh;
                     TempStopPoint := New(PStopPoint, Create( ANewObjectData.X1, ANewObjectData.Y1));
                     Insert(TempStopPoint);
                     SetState(stEdit, @Self);
                     TempStopPoint^.MakeCurrent;
                     UnlockRefresh;
                     TempStopPoint^.RefreshFromChilds(True);
                     end;
        doLine: begin
                if (ANewObjectData.Count > 1)
                then begin
                     Length := Sqrt(Sqr(ANewObjectData.X2 - ANewObjectData.X1) + Sqr(ANewObjectData.Y2 - ANewObjectData.Y1));
                     if (Length > 0)
                     then begin
                          LockRefresh;
                          TempPol := New(PDragPolligon, Create);
                          LengthDelta := Length / (ANewObjectData.Count - 1);
                          Delta.X := LengthDelta / Length * (ANewObjectData.X2 - ANewObjectData.X1);
                          Delta.Y := LengthDelta / Length * (ANewObjectData.Y2 - ANewObjectData.Y1);
                          NewPos.X := ANewObjectData.X1;
                          NewPos.Y := ANewObjectData.Y1;
                          TempPoint := New(PDragPollygonPoint, Create( NewPos.X, NewPos.Y));
                          TempPol^.Insert(TempPoint);
                          Count := 1;
                          while (Count < ANewObjectData.Count)
                          do begin
                             NewPos.X := NewPos.X + Delta.X;
                             NewPos.Y := NewPos.Y + Delta.Y;
                             TempPoint := New(PDragPollygonPoint, Create( NewPos.X, NewPos.Y));
                             TempPol^.Insert(TempPoint);
                             Count := Count + 1;
                             end;
                          Insert(TempPol);
                          TempPoint^.MakeCurrent;
                          UnlockRefresh;
                          TempPol^.RefreshFromChilds(True);
                          end;
                     end;
                end;
        doRectangle: begin
                     if ((ANewObjectData.X1 <> ANewObjectData.X2)
                        and (ANewObjectData.Y1 <> ANewObjectData.Y2))
                     then begin
                          LockRefresh;
                          TempPol := New(PDragPolligon, Create);
                          TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X1, ANewObjectData.Y1));
                          TempPol^.Insert(TempPoint);
                          TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X2, ANewObjectData.Y1));
                          TempPol^.Insert(TempPoint);
                          TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X2, ANewObjectData.Y2));
                          TempPol^.Insert(TempPoint);
                          TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X1, ANewObjectData.Y2));
                          TempPol^.Insert(TempPoint);
                          TempPoint := New(PDragPollygonPoint, Create( ANewObjectData.X1, ANewObjectData.Y1));
                          TempPol^.Insert(TempPoint);
                          Insert(TempPol);
                          TempPoint^.MakeCurrent;
                          UnlockRefresh;
                          TempPol^.RefreshFromChilds(True);
                          end;
                     end;
        doEllipse: begin
                   if ((ANewObjectData.X1 <> ANewObjectData.X2)
                        and (ANewObjectData.Y1 <> ANewObjectData.Y2)
                        and (ANewObjectData.Count >= 2))
                   then begin
                        LockRefresh;
                        TempPol := New(PDragPolligon, Create);
                        RadX := (ANewObjectData.X2 - ANewObjectData.X1) / 2;
                        RadY := (ANewObjectData.Y2 - ANewObjectData.Y1) / 2;
                        Center.X := (ANewObjectData.X1 + ANewObjectData.X2) / 2;
                        Center.Y := (ANewObjectData.Y1 + ANewObjectData.Y2) / 2;
                        LengthDelta := (Pi * 2) / (ANewObjectData.Count - 1);
                        Length := 0;
                        Count := 0;
                        while (Count < ANewObjectData.Count)
                        do begin
                           NewPos.X := Center.X + RadX * Cos(Length);
                           NewPos.Y := Center.Y + RadY * Sin(Length);
                           TempPoint := New(PDragPollygonPoint, Create( NewPos.X, NewPos.Y));
                           TempPol^.Insert(TempPoint);
                           Length := Length + LengthDelta;
                           Count := Count + 1;
                           end;
                        Insert(TempPol);
                        TempPoint^.MakeCurrent;
                        UnlockRefresh;
                        TempPol^.RefreshFromChilds(True);
                        end;

                   end;
        end;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

function TCanvasWindow.CreateCanvasDrag: PDragRoot_;
begin
     CreateCanvasDrag := New(PDragRoot, Create(@Self));
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragPoint.Create(X,Y: Float);
begin
     inherited Create;
     Origin.X := X;
     Origin.Y := Y;
end;

destructor TDragPoint.Destroy;
begin
     inherited Destroy;
end;

procedure TDragPoint.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Origin, SizeOf(Origin));
end;

procedure TDragPoint.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Origin, SizeOf(Origin));
end;

function TDragPoint.GetTypeId: Word;
begin
     GetTypeId := tiDragPoint;
end;


function TDragPoint.IsGrouped: Boolean;
begin
     IsGrouped := True;
end;

function TDragPoint.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Point: TPoint;
begin
     if AStateInfo = nil
     then Exit;

     if AStateInfo = nil then Exit;
     if (Owner <> nil)
     then begin
          ConvertToView(Origin, Point);
          case EventInfo.Event
          of evMouseLDown: case AStateInfo^.State
                           of stEdit: begin
                                        if ContainsPoint(EventInfo.ViewPos)
                                        then begin
                                             SetState(stDrag, @Self);
                                             if AStateInfo^.State = stDrag
                                             then begin
                                                  AStateInfo^.DragInfo.DragType := dtMove;
                                                  AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                  AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                  AStateInfo^.DragInfo.Moved := False;
                                                  SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                  Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                  end;
                                             HandleGroupEvent := True;
                                             end
                                        else HandleGroupEvent := False;
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
                                               if AStateInfo^.DragInfo.Moved
                                               then Origin := EventInfo.LogicPos;
                                               SetState(stEdit, @Self);
                                               MakeCurrent;
                                               UnlockRefresh;
                                               RefreshFromChilds(True);
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
                          of stDrag: begin
                                     case AStateInfo^.DragInfo.DragType
                                     of dtMove: begin
                                                AStateInfo^.DragInfo.Moved := True;
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                MoveToPos(EventInfo.ViewPos);
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateinfo);
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

procedure TDragPoint.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point: TPoint;
begin
     if AStateInfo = nil
     then Exit;

     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          ConvertToView(Origin, Point);
          if (Owner^.IsCurrent)
          then begin
               Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
               if (Owner^.Current = @Self)
               then begin
                    Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                    Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                    end;
               end
          else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
          end;
end;


function TDragPoint.ContainsPoint(APoint:TPoint):Boolean;
var Point: TPoint;
begin
     ConvertToView(Origin, Point);
     if (Owner^.IsCurrent)
     then ContainsPoint := ((APoint.X >= Point.X - 3) and (APoint.Y >= Point.Y - 3)
                           and (APoint.X <= Point.X + 3) and (APoint.Y <= Point.Y + 3))
     else ContainsPoint := ((APoint.X >= Point.X - 1) and (APoint.Y >= Point.Y - 1)
                           and (APoint.X <= Point.X + 2) and (APoint.Y <= Point.Y + 2))

end;

procedure TDragPoint.MoveToPos(var APos:TPoint);
begin
     ConvertToLogic(APos, Origin);
end;

procedure TDragPoint.Rotate( var ACenter: TRPoint; ASin, ACos : Float);
var NewOrigin: TRPoint;
begin
     Origin.X := Origin.X - ACenter.X;
     Origin.Y := Origin.Y - ACenter.Y;
     NewOrigin.X := Origin.X * ACos + Origin.Y * ASin + ACenter.X;
     NewOrigin.Y := - Origin.X * ASin + Origin.Y * ACos + ACenter.Y;
     Origin := NewOrigin;
end;

procedure TDragPoint.Expand( var ACenter: TRPoint; AXRate, AYRate: Float);
var NewOrigin: TRPoint;
begin
     Origin.X := (Origin.X - ACenter.X) * AXRate + ACenter.X;
     Origin.Y := (Origin.Y - ACenter.Y) * AYRate + ACenter.Y;
end;


procedure TDragPoint.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
begin
     if ATheFirst
     then begin
          ARRect.A := Origin;
          ARRect.B := Origin;
          end
     else begin
          if (Origin.X < ARRect.A.X)
          then ARRect.A.X := Origin.X
          else if (Origin.X > ARRect.B.X)
               then ARRect.B.X := Origin.X;
          if (Origin.Y < ARRect.A.Y)
          then ARRect.A.Y := Origin.Y
          else if (Origin.Y > ARRect.B.Y)
               then ARRect.B.Y := Origin.Y;
          end;
end;

procedure TDragPoint.MakeOffset(ARPoint: TRPoint);
var I: Longint;
begin
     Origin.X := Origin.X + ARPoint.X;
     Origin.Y := Origin.Y + ARPoint.Y;
end;

procedure TDragPoint.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var NewOrigin: TRPoint;
    TempDrag: PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipHorizontal: begin
                          if not TFlipEffectInfo(AEffectInfo).DeterminedCenter
                          then Exit;
                          LockRefresh;
                          Origin.X := 2 * TFlipEffectInfo(AEffectInfo).Center.X - Origin.X;
                          UnlockRefresh;
                          RefreshFromChilds(True);
                          end;
        efFlipVertical: begin
                        if not TFlipEffectInfo(AEffectInfo).DeterminedCenter
                        then Exit;
                        LockRefresh;
                        Origin.Y := 2 * TFlipEffectInfo(AEffectInfo).Center.Y - Origin.Y;
                        UnLockRefresh;
                        RefreshFromChilds(True);
                        end;
        efRotate: begin
                  if not TRotationEffectInfo(AEffectInfo).DeterminedCenter
                  then Exit;
                  LockRefresh;
                  Origin.X := Origin.X - TRotationEffectInfo(AEffectInfo).Center.X;
                  Origin.Y := Origin.Y - TRotationEffectInfo(AEffectInfo).Center.Y;
                  NewOrigin.X := Origin.X * TRotationEffectInfo(AEffectInfo).Cos{Cos}
                                    + Origin.Y * TRotationEffectInfo(AEffectInfo).Sin{Sin}
                                    + TRotationEffectInfo(AEffectInfo).Center.X;
                  NewOrigin.Y := - Origin.X * TRotationEffectInfo(AEffectInfo).Sin
                                    + Origin.Y * TRotationEffectInfo(AEffectInfo).Cos
                                    + TRotationEffectInfo(AEffectInfo).Center.Y;
                  Origin := NewOrigin;
                  UnlockRefresh;
                  RefreshFromChilds(True);
                  end;
        efClone: begin
                 if IsGrouped
                 then MakeClone(Owner)
                 else if (Current <> nil)
                      then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        else
            inherited MakeEffect(AEffect,AEffectInfo,AStateInfo);
        end;
end;

function TDragPoint.GetTheCurrent: PDragObject;
begin
     GetTheCurrent := @Self;
end;

procedure TDragPoint.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PDragPoint(AObject)^.Origin := Origin;
          end;
end;

function TDragPoint.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragPoint, Create(Origin.X, Origin.Y));
end;

procedure TDragPoint.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comDeleteCurrent:  AEnable := (True and (AStateInfo^.State = stEdit));
        comClone: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragMultiPoint.Create(X,Y: Float);
var I: Integer;
begin
     inherited Create;
     for I := 1 to MultiPointCount
     do begin
        Origin[I].X := X;
        Origin[I].Y := Y;
        end;
end;

destructor TDragMultiPoint.Destroy;
begin
     inherited Destroy;
end;

procedure TDragMultiPoint.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Origin, SizeOf(Origin));
end;

procedure TDragMultiPoint.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Origin, SizeOf(Origin));
end;

function TDragMultiPoint.GetTypeId: Word;
begin
     GetTypeId := tiDragMultiPoint;
end;


function TDragMultiPoint.IsGrouped: Boolean;
begin
     IsGrouped := True;
end;

function TDragMultiPoint.GetPointId( APoint: TPoint): Integer;
var I: Integer;
    Point: TPoint;
    Last: Integer;

    function Contains(ARPoint: TRPoint): Boolean;
    var Point: TPoint;
    begin
         ConvertToView(ARPoint, Point);
         Contains := (((Owner^.IsCurrent) and ((APoint.X >= Point.X - 3) and (APoint.Y >= Point.Y - 3)
                           and (APoint.X <= Point.X + 3) and (APoint.Y <= Point.Y + 3)))
                     or ((APoint.X >= Point.X - 1) and (APoint.Y >= Point.Y - 1)
                           and (APoint.X <= Point.X + 2) and (APoint.Y <= Point.Y + 2)));
    end;
begin
     {if IsCurrent
     then Last := MultiPointCount
     else Last := 1;}
     if (Owner <> nil)
     then begin
          if Owner^.IsCurrent
          then begin
               if ((Owner^.FirstChild <> @Self) and Contains(Origin[3]))
               then GetPointId := 3
               else if ((Owner^.FirstChild <> Next) and Contains(Origin[2]))
               then GetPointId := 2
               else if Contains(Origin[1])
               then GetPointId := 1
               else GetPointId := 0
               end
          else if Contains(Origin[1])
               then GetPointId := 1
               else GetPointId := 0;
          end
     else GetPointId := 0;
end;

function TDragMultiPoint.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var Point: TPoint;
    ID : Integer;
begin
     if AStateInfo = nil
     then Exit;

     if AStateInfo = nil then Exit;
     if (Owner <> nil)
     then begin
          case EventInfo.Event
          of evMouseLDown: case AStateInfo^.State
                           of stEdit: begin
                                      ID := GetPointId(EventInfo.ViewPos);
                                      if (ID <> 0)
                                      then begin
                                           SetState(stDrag, @Self);
                                           if AStateInfo^.State = stDrag
                                           then begin
                                                ConvertToView(Origin[ID], Point);
                                                AStateInfo^.DragInfo.Int := ID;
                                                AStateInfo^.DragInfo.DragType := dtMove;
                                                AStateInfo^.DragInfo.TuchPlace.X := EventInfo.ViewPos.X - Point.X;
                                                AStateInfo^.DragInfo.TuchPlace.Y := EventInfo.ViewPos.Y - Point.Y;
                                                AStateInfo^.DragInfo.Moved := False;
                                                SetROP2(AStateInfo^.DragInfo.DrawInfo.DrawDC,r2_Not);
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                end;
                                           HandleGroupEvent := True;
                                           end
                                      else HandleGroupEvent := False;
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
                                               if AStateInfo^.DragInfo.Moved
                                               then Origin[AStateInfo^.DragInfo.Int] := EventInfo.LogicPos;
                                               SetState(stEdit, @Self);
                                               MakeCurrent;
                                               UnlockRefresh;
                                               RefreshFromChilds(True);
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
                          of stDrag: begin
                                     case AStateInfo^.DragInfo.DragType
                                     of dtMove: begin
                                                AStateInfo^.DragInfo.Moved := True;
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateInfo);
                                                if AStateInfo^.DragInfo.Int > 1
                                                then Origin[AStateInfo^.DragInfo.Int] := EventInfo.LogicPos
                                                else MoveToPos(EventInfo.ViewPos);
                                                Draw(AStateInfo^.DragInfo.DrawInfo, AStateinfo);
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

procedure TDragMultiPoint.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point: TPoint;
    Point1,
    Point2: TPoint;
    I: Integer;
begin
     if AStateInfo = nil
     then Exit;

     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          ConvertToView(Origin[1], Point);
          if (Owner^.IsCurrent)
          then begin
               Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
               if (Owner^.Current = @Self)
               then begin
                    Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                    if (Owner^.FirstChild <> @Self)
                    then begin
                         ConvertToView(Origin[2], Point1);
                         Rectangle(DrawInfo.DrawDC,Point1.X - 1,Point1.Y - 1,Point1.X + 2,Point1.Y + 2);
                         MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
                         LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                         end;
                    if (Owner^.FirstChild <> Next)
                    then begin
                         ConvertToView(Origin[3], Point1);
                         Rectangle(DrawInfo.DrawDC,Point1.X - 1,Point1.Y - 1,Point1.X + 2,Point1.Y + 2);
                         MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
                         LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                         end;
                    end;
               end
          else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
          end;
end;


{function TDragBezierPoint.ContainsPoint(APoint:TPoint):Boolean;
var Point: TPoint;
begin
     ConvertToView(Origin, Point);
     if (Owner^.IsCurrent)
     then ContainsPoint := ((APoint.X >= Point.X - 3) and (APoint.Y >= Point.Y - 3)
                           and (APoint.X <= Point.X + 3) and (APoint.Y <= Point.Y + 3))
     else ContainsPoint := ((APoint.X >= Point.X - 1) and (APoint.Y >= Point.Y - 1)
                           and (APoint.X <= Point.X + 2) and (APoint.Y <= Point.Y + 2))
end;}



procedure TDragMultiPoint.MoveToPos(var APos:TPoint);
var NewPos: TRPoint;
    I: Integer;
begin
     ConvertToLogic(APos, NewPos);

     Origin[1].X := NewPos.X - Origin[1].X;
     Origin[1].Y := NewPos.Y - Origin[1].Y;

     for I := 2 to MultiPointCount
     do begin
        Origin[I].X := Origin[I].X + Origin[1].X;
        Origin[I].Y := Origin[I].Y + Origin[1].Y;
        end;

     Origin[1] := NewPos;
end;

procedure TDragMultiPoint.Rotate( var ACenter: TRPoint; ASin, ACos : Float);
var NewOrigin: TRPoint;
    I: Integer;
begin
     for I := 1 to MultiPointCount
     do begin
        Origin[I].X := Origin[I].X - ACenter.X;
        Origin[I].Y := Origin[I].Y - ACenter.Y;
        NewOrigin.X := Origin[I].X * ACos + Origin[I].Y * ASin + ACenter.X;
        NewOrigin.Y := - Origin[I].X * ASin + Origin[I].Y * ACos + ACenter.Y;
        Origin[I] := NewOrigin;
        end;
end;

procedure TDragMultiPoint.Expand( var ACenter: TRPoint; AXRate, AYRate: Float);
var NewOrigin: TRPoint;
    I: Integer;
begin
     for I := 1 to MultiPointCount
     do begin
        Origin[I].X := (Origin[I].X - ACenter.X) * AXRate + ACenter.X;
        Origin[I].Y := (Origin[I].Y - ACenter.Y) * AYRate + ACenter.Y;
        end;
end;


procedure TDragMultiPoint.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
begin
     if ATheFirst
     then begin
          ARRect.A := Origin[1];
          ARRect.B := Origin[1];
          end
     else begin
          if (Origin[1].X < ARRect.A.X)
          then ARRect.A.X := Origin[1].X
          else if (Origin[1].X > ARRect.B.X)
               then ARRect.B.X := Origin[1].X;
          if (Origin[1].Y < ARRect.A.Y)
          then ARRect.A.Y := Origin[1].Y
          else if (Origin[1].Y > ARRect.B.Y)
               then ARRect.B.Y := Origin[1].Y;
          end;
end;

procedure TDragMultiPoint.MakeOffset(ARPoint: TRPoint);
var I: Integer;
begin
     for I := 1 to MultiPointCount
     do begin
        Origin[I].X := Origin[I].X + ARPoint.X;
        Origin[I].Y := Origin[I].Y + ARPoint.Y;
        end;
end;

procedure TDragMultiPoint.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var NewOrigin: TRPoint;
    TempDrag: PDragObject;
    I: Integer;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipHorizontal: begin
                          if not TFlipEffectInfo(AEffectInfo).DeterminedCenter
                          then Exit;
                          LockRefresh;
                          for I := 1 to MultiPointCount
                          do Origin[I].X := 2 * TFlipEffectInfo(AEffectInfo).Center.X - Origin[I].X;
                          UnlockRefresh;
                          RefreshFromChilds(True);
                          end;
        efFlipVertical: begin
                        if not TFlipEffectInfo(AEffectInfo).DeterminedCenter
                        then Exit;
                        LockRefresh;
                        for I := 1 to MultiPointCount
                        do Origin[I].Y := 2 * TFlipEffectInfo(AEffectInfo).Center.Y - Origin[I].Y;
                        UnLockRefresh;
                        RefreshFromChilds(True);
                        end;
        efRotate: begin
                  if not TRotationEffectInfo(AEffectInfo).DeterminedCenter
                  then Exit;
                  LockRefresh;
                  for I := 1 to MultiPointCount
                  do begin
                     Origin[I].X := Origin[I].X - TRotationEffectInfo(AEffectInfo).Center.X;
                     Origin[I].Y := Origin[I].Y - TRotationEffectInfo(AEffectInfo).Center.Y;
                     NewOrigin.X := Origin[I].X * TRotationEffectInfo(AEffectInfo).Cos{Cos}
                                    + Origin[I].Y * TRotationEffectInfo(AEffectInfo).Sin{Sin}
                                    + TRotationEffectInfo(AEffectInfo).Center.X;
                     NewOrigin.Y := - Origin[I].X * TRotationEffectInfo(AEffectInfo).Sin
                                    + Origin[I].Y * TRotationEffectInfo(AEffectInfo).Cos
                                    + TRotationEffectInfo(AEffectInfo).Center.Y;
                     Origin[I] := NewOrigin;
                     end;
                  UnlockRefresh;
                  RefreshFromChilds(True);
                  end;
        efClone: begin
                 if IsGrouped
                 then MakeClone(Owner)
                 else if (Current <> nil)
                      then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        else
            inherited MakeEffect(AEffect,AEffectInfo,AStateInfo);
        end;
end;

function TDragMultiPoint.GetTheCurrent: PDragObject;
begin
     GetTheCurrent := @Self;
end;

procedure TDragMultiPoint.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PDragMultiPoint(AObject)^.Origin := Origin;
          end;
end;

function TDragMultiPoint.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragMultiPoint, Create(Origin[1].X, Origin[1].Y));
end;

procedure TDragMultiPoint.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comDeleteCurrent:  AEnable := (True and (AStateInfo^.State = stEdit));
        comClone: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TStopPoint.Create( X,Y: Float);
begin
     inherited Create(X, Y);
end;

procedure TStopPoint.Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point1,
    Point2: TPoint;
    Pen, OldPen: HPen;
begin
     case AStateInfo^.State
     of stPreview: begin
                   inherited Draw(DrawInfo, AStateInfo);
                   ConvertToView(Origin, Point1);
                   ConvertToView(AStateInfo^.PreviewInfo.LastPos, Point2);
                   Pen := CreatePen(PS_DOT, 0, RGB(255, 0, 0));
                   OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                   MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                   LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                   SelectObject(DrawInfo.DrawDC, OldPen);
                   DeleteObject(Pen);
                   AStateInfo^.PreviewInfo.LastPos := Origin;
                   end;
        else
            inherited Draw(DrawInfo, AStateInfo);
        end;
end;

procedure TStopPoint.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
     PStopPoint(AObject)^.Origin := Origin;
end;

function TStopPoint.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PStopPoint, Create(Origin.X, Origin.Y));
end;

procedure TStopPoint.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
end;

procedure TStopPoint.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comDeleteCurrent:  AEnable := (True and (AStateInfo^.State = stEdit));
        comClone: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;

procedure TStopPoint.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
end;

procedure TStopPoint.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
end;

function TStopPoint.GetTypeId: Word;
begin
     GetTypeId := tiStopPoint;
end;

procedure TStopPoint.GenerateOutput(AOutputGenerator: POutputGenerator);
begin
     if AOutputGenerator = nil then Exit;

     if AOutputGenerator^.AddJump(Origin)
     then AOutputGenerator^.AddStop;
end;


function TStopPoint.HandleGroupEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
begin
     if AStateInfo = nil then Exit;
     if (AStateInfo^.State = stPreview)
     then begin
          case EventInfo.Event
          of evMouseLDown: begin
                           if ContainsPoint(EventInfo.ViewPos)
                           then begin
                                SendAsResponse(@Self);
                                HandleGroupEvent := True;
                                end
                           else HandleGroupEvent := False;
                           end;
          else
              HandleGroupEvent := False;
          end;
          end
     else HandleGroupEvent := inherited HandleGroupEvent(EventInfo, AStateInfo);
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragPollygonPoint.Create( X,Y: Float);
begin
     inherited Create(X, Y);
     StopPoint := False;
end;

procedure TDragPollygonPoint.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(StopPoint, SizeOf(StopPoint));
end;

procedure TDragPollygonPoint.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(StopPoint, SizeOf(StopPoint));
end;

function TDragPollygonPoint.GetTypeId: Word;
begin
     GetTypeId := tiDragPollygonPoint;
end;


procedure TDragPollygonPoint.Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point: TPoint;
    Point1: TPoint;
    Pen, OldPen: HPen;
begin
     if AStateInfo = nil
     then Exit;

     {inherited Draw(DrawInfo,AStateInfo);}

     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          ConvertToView(Origin, Point);
          case AStateInfo^.State of
          stEdit: begin
                    if StopPoint
                    then begin
                         Pen := CreatePen(PS_SOLID, 1, RGB(255,0,0));
                         OldPen := SelectObject(DrawInfo.DrawDC,Pen);
                         if (Owner^.FirstChild <> @Self)
                         then begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                              end
                         else begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 4,Point.Y - 4,Point.X + 5,Point.Y + 5);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                              end;
                         SelectObject(DrawInfo.DrawDC,OldPen);
                         DeleteObject(Pen);
                         end
                    else begin
                         if (Owner^.FirstChild <> @Self)
                         then begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                              end
                         else begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 4,Point.Y - 4,Point.X + 5,Point.Y + 5);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                              end;
                         end;
                    end;
          stDrag: begin
                  Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                  if ((Next <> nil) and (Owner^.FirstChild <> Next))
                  then begin
                       ConvertToView(PDragPollygonPoint(Next)^.Origin, Point1);
                       MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
                       LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                       end;
                  if ((Prev <> nil) and (Owner^.FirstChild <> @Self))
                  then begin
                       ConvertToView(PDragPollygonPoint(Prev)^.Origin, Point1);
                       MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
                       LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                       end;
                  end;
          stModal: begin
                   end;
          stPreview: begin
                     end;
          end;
          end;
end;

procedure TDragPollygonPoint.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
     PDragPollygonPoint(AObject)^.Origin := Origin;
     PDragPollygonPoint(AObject)^.StopPoint := StopPoint;
end;

function TDragPollygonPoint.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragPollygonPoint, Create(Origin.X, Origin.Y));
end;

procedure TDragPollygonPoint.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipStopPoint: begin
                         StopPoint := not StopPoint;
                         RefreshFromChilds(True);
                         end;
     else
         inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

procedure TDragPollygonPoint.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comDeleteCurrent:  AEnable := (True and (AStateInfo^.State = stEdit));
        comClone: AEnable := (True and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := (True and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := (True and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := (True and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;

procedure TDragPollygonPoint.MakeClone(AOwner: PDragObject);
var Temp: PDragObject;
    SelfClone: PDragObject;
begin
     if (Owner <> nil)
     then begin
          SelfClone := MakeSelfClone;
          if (SelfClone <> nil)
          then begin
               LockRefresh;
               CopySelfTo(SelfClone);
               AOwner^.Insert(SelfClone);
               SelfClone^.LinkAfter(@Self);
               UnLockRefresh;
               SelfClone^.Refresh(True);
               end;
          end;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragBezierPoint.Create( X,Y: Float);
begin
     inherited Create(X, Y);
     StopPoint := False;
end;

procedure TDragBezierPoint.DrawBezier( var DrawInfo: TDrawInfo; P0,P1,P2,P3: TRPoint);
const DeltaT = 1 / BEZIERPOINTSCOUNT;
var T, T2, T3: Float;
    AX, BX, CX, DX,
    AY, BY, CY, DY: Float;
    RPoint: TRPoint;
    Point: TPoint;
begin
     RPoint := P0;
     ConvertToView(RPoint, Point);
     MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);

     AX := (- P0.X + 3 * P1.X - 3 * P2.X + P3.X);
     BX := (3 * P0.X - 6 * P1.X + 3 * P2.X);
     CX := (- 3 * P0.X + 3 * P1.X);
     DX := P0.X;

     AY := (- P0.Y + 3 * P1.Y - 3 * P2.Y + P3.Y);
     BY := (3 * P0.Y - 6 * P1.Y + 3 * P2.Y);
     CY := (- 3 * P0.Y + 3 * P1.Y);
     DY := P0.Y;

     T := DeltaT;
     while T < 1
     do begin
        T2 := T * T;
        T3 := T2 * T;
        RPoint.X := AX * T3 + BX * T2 + CX * T + DX;
        RPoint.Y := AY * T3 + BY * T2 + CY * T + DY;
        ConvertToView(RPoint, Point);
        LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
        T := T + DeltaT;
        end;
     ConvertToView(P3, Point);
     LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
end;


procedure TDragBezierPoint.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(StopPoint, SizeOf(StopPoint));
end;

procedure TDragBezierPoint.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(StopPoint, SizeOf(StopPoint));
end;

function TDragBezierPoint.GetTypeId: Word;
begin
     GetTypeId := tiDragBezierPoint;
end;

{
procedure TDragMultiPoint.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point: TPoint;
    Point1,
    Point2: TPoint;
    I: Integer;
begin
     if AStateInfo = nil
     then Exit;

     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          ConvertToView(Origin[1], Point);
          if (Owner^.IsCurrent)
          then begin
               Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
               if (Owner^.Current = @Self)
               then begin
                    Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                    for I := 2 to MultiPointCount
                    do begin
                       ConvertToView(Origin[I], Point1);
                       Rectangle(DrawInfo.DrawDC,Point1.X - 3,Point1.Y - 3,Point1.X + 4,Point1.Y + 4);
                       MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
                       LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                       end;
                    end;
               end
          else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
          end;
end;
}

procedure TDragBezierPoint.Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point: TPoint;

    Pen, OldPen: HPen;


    procedure DrawExtraPoints;
    var I: Integer;
        Point1: TPoint;
    begin
         if (Owner^.FirstChild <> Next)
         then begin
              ConvertToView(Origin[2], Point1);
              {Rectangle(DrawInfo.DrawDC,Point1.X - 3,Point1.Y - 3,Point1.X + 4,Point1.Y + 4);}
              MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
              LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
              Ellipse(DrawInfo.DrawDC,Point1.X - 2,Point1.Y - 2,Point1.X + 3,Point1.Y + 3);
              end;
         if (Owner^.FirstChild <> @Self)
         then begin
              ConvertToView(Origin[3], Point1);
              {Rectangle(DrawInfo.DrawDC,Point1.X - 3,Point1.Y - 3,Point1.X + 4,Point1.Y + 4);}
              MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
              LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
              Ellipse(DrawInfo.DrawDC,Point1.X - 2,Point1.Y - 2,Point1.X + 3,Point1.Y + 3);
              end;
    end;
begin
     if AStateInfo = nil
     then Exit;
     if ((@DrawInfo <> nil) and (Owner <> nil))
     then begin
          ConvertToView(Origin[1], Point);
          case AStateInfo^.State of
          stEdit: begin
                    if StopPoint
                    then begin
                         Pen := CreatePen(PS_SOLID, 1, RGB(255,0,0));
                         OldPen := SelectObject(DrawInfo.DrawDC,Pen);
                         if (Owner^.FirstChild <> @Self)
                         then begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   DrawExtraPoints;
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                              end
                         else begin
                              Rectangle(DrawInfo.DrawDC,Point.X - 4,Point.Y - 4,Point.X + 5,Point.Y + 5);
                              if (Owner^.Current = @Self)
                              then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                              DrawExtraPoints;
                              end;
                         SelectObject(DrawInfo.DrawDC,OldPen);
                         DeleteObject(Pen);
                         end
                    else begin
                         if (Owner^.FirstChild <> @Self)
                         then begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 3,Point.Y - 3,Point.X + 4,Point.Y + 4);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   DrawExtraPoints;
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                              end
                         else begin
                              if (Owner^.IsCurrent)
                              then begin
                                   Rectangle(DrawInfo.DrawDC,Point.X - 4,Point.Y - 4,Point.X + 5,Point.Y + 5);
                                   if (Owner^.Current = @Self)
                                   then Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                                   DrawExtraPoints;
                                   end
                              else Rectangle(DrawInfo.DrawDC,Point.X - 2,Point.Y - 2,Point.X + 3,Point.Y + 3);
                              end;
                         end;
                    end;
          stDrag: begin
                  Rectangle(DrawInfo.DrawDC,Point.X - 1,Point.Y - 1,Point.X + 2,Point.Y + 2);
                  if IsCurrent
                  then DrawExtraPoints;
                  if (AStateInfo^.DragInfo.DragObject = @Self)
                  then begin
                       if ((Next <> nil) and (Owner^.FirstChild <> Next))
                       then DrawBezier( DrawInfo, Origin[1], Origin[2],
                                   PDragBezierPoint(Next)^.Origin[3], PDragBezierPoint(Next)^.Origin[1]);
                       end;
                       if ((Prev <> nil) and (Owner^.FirstChild <> @Self))
                       then DrawBezier( DrawInfo, PDragBezierPoint(Prev)^.Origin[1], PDragBezierPoint(Prev)^.Origin[2],
                                             Origin[3], Origin[1]);
                  end;
          stModal: begin
                   end;
          stPreview: begin
                     end;
          end;
          end;
end;

procedure TDragBezierPoint.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
     PDragBezierPoint(AObject)^.Origin := Origin;
     PDragBezierPoint(AObject)^.StopPoint := StopPoint;
end;

function TDragBezierPoint.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragBezierPoint, Create(Origin[1].X, Origin[1].Y));
end;

procedure TDragBezierPoint.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var TempRPoint: TRPoint;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efFlipStopPoint: begin
                         StopPoint := not StopPoint;
                         RefreshFromChilds(True);
                         end;
        efReversePath: begin
                       TempRPoint := Origin[2];
                       Origin[2] := Origin[3];
                       Origin[3] := TempRPoint;
                       end;
     else
         inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

procedure TDragBezierPoint.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comDeleteCurrent:  AEnable := (True and (AStateInfo^.State = stEdit));
        comClone: AEnable := (True and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := (True and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := (True and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := (True and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := (True and (AStateInfo^.State = stEdit));
        end;
end;

procedure TDragBezierPoint.MakeClone(AOwner: PDragObject);
var Temp: PDragObject;
    SelfClone: PDragObject;
begin
     if (Owner <> nil)
     then begin
          SelfClone := MakeSelfClone;
          if (SelfClone <> nil)
          then begin
               LockRefresh;
               CopySelfTo(SelfClone);
               AOwner^.Insert(SelfClone);
               SelfClone^.LinkAfter(@Self);
               UnLockRefresh;
               SelfClone^.Refresh(True);
               end;
          end;
end;


{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

procedure TPath.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
end;

procedure TPath.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
end;

function TPath.GetTypeId: Word;
begin
     GetTypeId := tiPath;
end;

function TPath.GetSectionLength(ASection: Longint): Float;
begin
     GetSectionLength := 0;
end;

function TPath.GetSectionsCount: Longint;
begin
     GetSectionsCount := 0;
end;

function TPath.GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint;
begin
     GetSectionPoints := nil;
end;

procedure TPath.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
end;

function TPath.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PPath, create);
end;

procedure TPath.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efSeparate: begin
                    end;
        efAppendPathToItem: begin
                            SendAsResponse(@Self);
                            end;
        efStreach: begin
                   SendAsResponse(@Self);
                   end;
     else
         inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragPolligon.Create;
begin
     inherited Create;
end;

destructor TDragPolligon.Destroy;
begin
     inherited Destroy;
end;

procedure TDragPolligon.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
end;

procedure TDragPolligon.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
end;

function TDragPolligon.GetTypeId: Word;
begin
     GetTypeId := tiDragPolligon;
end;

procedure TDragPolligon.Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Pen, OldPen: HPen;
    LB: TLogBrush;
    Point, Point1, Point2, Point3: TPoint;
    RRect: TRRect;

    procedure DrawPoints;
    var Pen, OldPen: HPen;
    begin
         if (not IsGrouped)
         then begin
              Pen := CreatePen(0,PS_SOLID,RGB(0,0,255));
              OldPen := SelectObject(DrawInfo.DrawDC, Pen);
              inherited Draw(DrawInfo,AStateInfo);
              SelectObject(DrawInfo.DrawDC,OldPen);
              DeleteObject(Pen);
              end;
    end;

    procedure DrawPolligon;
    var TempChild: PDragPoint;
        Point: TPoint;
    begin
         if ((FirstChild <> nil) and ((not IsGroupedOwner) or (not (AStateInfo^.State = stEdit))))
         then begin
              TempChild := PDragPoint(FirstChild);
              ConvertToView(TempChild^.Origin, Point);
              MoveTo(DrawInfo.DrawDC,Point.X,Point.Y);
              TempChild := PDragPoint(TempChild^.Next);
              while (TempChild <> PDragPoint(FirstChild))
              do begin
                 ConvertToView(TempChild^.Origin, Point);
                 LineTo(DrawInfo.DrawDC,Point.X,Point.Y);
                 TempChild := PDragPoint(TempChild^.Next);
                 end;
              end;
    end;

begin
     if AStateInfo = nil
     then Exit;

     case AStateInfo^.State
     of stEdit: begin
                DrawPoints;
                DrawPolligon;
                end;
        stModal: begin
                 DrawPoints;
                 if (AStateInfo^.ModalInfo.ModalObject = @Self)
                 then begin
                      if (FirstChild <> nil)
                      then if (FirstChild^.Prev <> nil)
                           then begin
                                Pen := CreatePen(0,PS_SOLID,RGB(255,0,0));
                                OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                                ConvertToView(PDragPoint(FirstChild^.Prev)^.Origin, Point);
                                Ellipse(DrawInfo.DrawDC, Point.X - 3, Point.Y - 3, Point.X + 4, Point.Y + 4);
                                SelectObject(DrawInfo.DrawDC,OldPen);
                                DeleteObject(Pen);
                                end;
                      end;
                 DrawPolligon;
                 end;
        stDrag: begin
                DrawPoints;
                DrawPolligon;
                end;
        stPreview: begin
                   end;
        end;
     DrawGroupFrame(DrawInfo, AStateInfo);
end;

function TDragPolligon.ContainsPoint( APoint:TPoint):Boolean;
begin
     ContainsPoint := False;
end;

function TDragPolligon.HandleEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var NewPoint: PDragPollygonPoint;
    RPoint: TRPoint;
label HandleOld;
begin
     if AStateInfo = nil
     then Exit;

     if (AStateInfo^.State = stModal)
     then begin
          case AStateInfo^.ModalInfo.ModalType
          of mtAppend: begin
                       if (EventInfo.Event = evMouseLDown)
                       then begin
                            ConvertToLogic(EventInfo.ViewPos, RPoint);
                            NewPoint := New(PDragPollygonPoint, Create(RPoint.X, RPoint.Y));
                            Insert(NewPoint);
                            Refresh(True);
                            end
                       else if (EventInfo.Event = evMouseRDown)
                       then begin
                            SetState(stEdit, @Self);
                            Refresh(True);
                            end;
                       HandleEvent := True;
                       end;
          else
              goto HandleOld;
          end;
          end
     else begin
          HandleOld:
          if inherited HandleEvent( EventInfo, AStateInfo)
          then begin
               MakeCurrent;
               HandleEvent := True;
               end
          else begin
               HandleEvent := False;
               end;
          end;
end;

function TDragPolligon.GetTheCurrent: PDragObject;
begin
     GetTheCurrent := Inherited GetTheCurrent;
     {GetTheCurrent := @Self;}
end;

function TDragPolligon.GetSectionsCount: Longint;
var Count: Longint;
    Temp :PDragPollygonPoint;
begin
     Temp := PDragPollygonPoint(FirstChild);
     Count := 1;
     repeat
           if ((Temp^.StopPoint) and (Temp <> PDragPollygonPoint(FirstChild)))
           then Count := Count + 1;
           Temp := PDragPollygonPoint(Temp^.Next);
     until (Temp = PDragPollygonPoint(FirstChild));
     GetSectionsCount := Count;
end;

function TDragPolligon.GetSectionLimits(ASection: Longint; var AStart, AStop: PDragPollygonPoint): Boolean;
var Section: Longint;
    StartPoint, StopPoint :PDragPollygonPoint;
begin
     if (ASection <> 0)
     then begin
          Section := 1;
          StartPoint := PDragPollygonPoint(FirstChild);
          while ((Section < ASection) and (StartPoint <> PDragPollygonPoint(FirstChild^.Prev)))
          do begin
             StartPoint := PDragPollygonPoint(StartPoint^.Next);
             if (StartPoint^.StopPoint)
             then Section := Section + 1;
             end;
          if (StartPoint <> PDragPollygonPoint(FirstChild^.Prev))
          then begin
               StopPoint := PDragPollygonPoint(StartPoint^.Next);
               while ((not StopPoint^.StopPoint) and (StopPoint <> PDragPollygonPoint(FirstChild^.Prev)))
               do StopPoint := PDragPollygonPoint(StopPoint^.Next);
               end
          else StopPoint := StartPoint;
          end
     else begin
          StartPoint := PDragPollygonPoint(FirstChild);
          StopPoint := PDragPollygonPoint(FirstChild^.Prev);
          end;

     AStart := StartPoint;
     AStop := StopPoint;
     GetSectionLimits := True;
end;

function TDragPolligon.GetSectionLength(ASection: Longint): Float;
var TempChild: PDragPollygonPoint;
    StartPoint, StopPoint :PDragPollygonPoint;
    Length: Float;
    LastX, LastY: Float;
begin
     GetSectionLimits(ASection, StartPoint, StopPoint);
     TempChild := StartPoint;

     Length := 0;
     if (TempChild <> nil)
     then begin
          LastX := TempChild^.Origin.X;
          LastY := TempChild^.Origin.Y;
          repeat;
                 TempChild := PDragPollygonPoint(TempChild^.Next);
                 Length := Length + Sqrt(Sqr(TempChild^.Origin.X - LastX) + Sqr(TempChild^.Origin.Y - LastY));
                 LastX := TempChild^.Origin.X;
                 LastY := TempChild^.Origin.Y;
          until (TempChild = StopPoint);
          end;
     GetSectionLength := Length;
end;


function TDragPolligon.GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint;
var PrevTemp, Temp: PDragPollygonPoint;
    StartPoint, StopPoint: PDragPollygonPoint;
    FirstPoint, LastPoint: PPathPoint;
    CurrentRemainLength,
    StepLength,
    Remain,
    LastX, LastY,
    KX, KY : Float;
    I: Longint;

    procedure AppendPoint( AX, AY: Float);
    var Temp: PPathPoint;
    begin
         New( Temp);
         Temp^.Valid := True;
         Temp^.Next := nil;
         Temp^.Point.X := AX;
         Temp^.Point.Y := AY;
         if (FirstPoint <> nil)
         then begin
              LastPoint^.Next := Temp;
              LastPoint := Temp;
              end
         else begin
              FirstPoint := Temp;
              LastPoint := Temp;
              end;
    end;
begin
     FirstPoint := nil;
     LastPoint := nil;
     StepLength := GetSectionLength(ASection) / (APointsCount - 1);
     if (StepLength > 0)
     then begin
          Remain := StepLength;
          GetSectionLimits(ASection, StartPoint, StopPoint);
          Temp := StartPoint;
          if (Temp <> nil)
          then begin
               LastX := Temp^.Origin.X;
               LastY := Temp^.Origin.Y;
               AppendPoint( LastX, LastY);
               PrevTemp := Temp;
               repeat
                     Temp := PDragPollygonPoint(Temp^.Next);
                     CurrentRemainLength := Sqrt(Sqr(Temp^.Origin.X - LastX) + Sqr(Temp^.Origin.Y - LastY));
                     if (CurrentRemainLength > 0)
                     then begin
                          KX := (Temp^.Origin.X - LastX) / CurrentRemainLength;
                          KY := (Temp^.Origin.Y - LastY) / CurrentRemainLength;
                          while (CurrentRemainLength > Remain)
                          do begin
                             LastX := LastX + KX * Remain;
                             LastY := LastY + KY * Remain;
                             AppendPoint(LastX, LastY);
                             CurrentRemainLength := CurrentRemainLength - Remain;
                             Remain := StepLength;
                             end;
                          Remain := Remain - CurrentRemainLength;
                          end;
                     LastX := Temp^.Origin.X;
                     LastY := Temp^.Origin.Y;
                     PrevTemp := Temp;
               until (Temp = StopPoint);
               AppendPoint(PrevTemp^.Origin.X, PrevTemp^.Origin.Y);
               end;
          end
     else begin
          if (Temp <> nil)
          then begin
               LastX := PDragPoint(FirstChild)^.Origin.X;
               LastY := PDragPoint(FirstChild)^.Origin.Y;
               for I := 1 to APointsCount
               do AppendPoint(LastX, LastY);
               end;
          end;
     GetSectionPoints := FirstPoint;
end;

procedure TDragPolligon.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
end;

function TDragPolligon.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragPolligon, Create);
end;

procedure TDragPolligon.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var Temp: PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efDeleteCurrent: begin
                         if ((IsGrouped) or (GetChildsCount <= 1))
                         then begin
                              Temp := Owner;
                              Delete;
                              if (Temp <> nil)
                              then Temp^.RefreshFromChilds(True);
                              end
                         else begin
                              if (Current <> nil)
                              then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                              end;
                         end;
        efAppendPoints: begin
                        SetState(stModal, @Self);
                        if (AStateinfo^.State = stModal)
                        then begin
                             AStateInfo^.ModalInfo.ModalType := mtAppend;
                             Refresh(True);
                             end;
                        end;
        else
            inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
        end;
end;

procedure TDragPolligon.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipHorizontal: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comDeleteCurrent:  AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comRotate: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comGroup: AEnable := AEnable or (not Grouped and (AStateInfo^.State = stEdit));
        comUnGroup: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comClone: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comMakeTwin: AEnable := AEnable or (not IsLockedByParent and (AStateInfo^.State = stEdit));
        comMakeLinear: AEnable := AEnable or (not IsLockedByParent and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TDragBezier.Create;
begin
     inherited Create;
end;

destructor TDragBezier.Destroy;
begin
     inherited Destroy;
end;

procedure TDragBezier.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
end;

procedure TDragBezier.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
end;

function TDragBezier.GetTypeId: Word;
begin
     GetTypeId := tiDragBezier;
end;

{procedure TDragBezier.DrawBezier( var DrawInfo: TDrawInfo; P0,P1,P2,P3: TRPoint);
var T1, T12, T13,
    T2, T22, T23,
    TT1, TT2: Float;
    RPoint: TRPoint;
    Point: TPoint;
begin
     RPoint := P0;
     ConvertToView(RPoint, Point);
     MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);
     T1 := 0.02;
     T2 := 1 - 0.02;
     while T1 <= 1
     do begin
        T12 := T1 * T1;
        T13 := T12 * T1;
        T22 := T2 * T2;
        T23 := T22 * T2;
        TT1 := 3 * T1 * T22;
        TT2 := 3 * T2 * T12;
        RPoint.X := T23 * P0.X + T13 * P3.X + TT1 * P1.X + TT2 * P2.X;
        RPoint.Y := T23 * P0.Y + T13 * P3.Y + TT1 * P1.Y + TT2 * P2.Y;
        ConvertToView(RPoint, Point);
        LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
        T1 := T1 + 0.02;
        T2 := T2 - 0.02;
        end;
     ConvertToView(P3, Point);
     LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
end;}

procedure TDragBezier.DrawBezier( var DrawInfo: TDrawInfo; P0,P1,P2,P3: TRPoint);
const DeltaT = 1 / BEZIERPOINTSCOUNT;
var T, T2, T3: Float;
    AX, BX, CX, DX,
    AY, BY, CY, DY: Float;
    RPoint: TRPoint;
    Point: TPoint;
begin
     RPoint := P0;
     ConvertToView(RPoint, Point);
     MoveTo(DrawInfo.DrawDC, Point.X, Point.Y);

     AX := (- P0.X + 3 * P1.X - 3 * P2.X + P3.X);
     BX := (3 * P0.X - 6 * P1.X + 3 * P2.X);
     CX := (- 3 * P0.X + 3 * P1.X);
     DX := P0.X;

     AY := (- P0.Y + 3 * P1.Y - 3 * P2.Y + P3.Y);
     BY := (3 * P0.Y - 6 * P1.Y + 3 * P2.Y);
     CY := (- 3 * P0.Y + 3 * P1.Y);
     DY := P0.Y;

     T := DeltaT;
     while T < 1
     do begin
        T2 := T * T;
        T3 := T2 * T;
        RPoint.X := AX * T3 + BX * T2 + CX * T + DX;
        RPoint.Y := AY * T3 + BY * T2 + CY * T + DY;
        ConvertToView(RPoint, Point);
        LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
        T := T + DeltaT;
        end;
     ConvertToView(P3, Point);
     LineTo(DrawInfo.DrawDC, Point.X, Point.Y);
end;

procedure TDragBezier.GetItemsRect(var ARRect: TRRect; ATheFirst: Boolean);
var Temp1, Temp2: PDragBezierPoint;
     procedure GetBezierRect( P0,P1,P2,P3: TRPoint);
     var A, B, C, D: Float;
         Delta: Float;
         T, T2, T3: Float;
         MaxMin: Float;
     begin
          A := (- P0.X + 3 * P1.X - 3 * P2.X + P3.X);
          B := (3 * P0.X - 6 * P1.X + 3 * P2.X);
          C := (- 3 * P0.X + 3 * P1.X);
          D := P0.X;
          Delta := 4 * B * B - 12 * A * C;
          if ((Delta >= 0) and (A <> 0))
          then begin
               T := (- 2 * B - Sqrt(Delta)) / (6 * A);
               if ((T >= 0) and (T <= 1))
               then begin
                    T2 := T * T;
                    T3 := T2 * T;
                    MaxMin := A * T3 + B * T2 + C * T + D;
                    if MaxMin > ARRect.B.X
                    then ARRect.B.X := MaxMin
                    else if MaxMin < ARRect.A.X
                    then ARRect.A.X := MaxMin;
                    end;
               T := (- 2 * B + Sqrt(Delta)) / (6 * A);
               if ((T >= 0) and (T <= 1))
               then begin
                    T2 := T * T;
                    T3 := T2 * T;
                    MaxMin := A * T3 + B * T2 + C * T + D;
                    if MaxMin > ARRect.B.X
                    then ARRect.B.X := MaxMin
                    else if MaxMin < ARRect.A.X
                    then ARRect.A.X := MaxMin;
                    end;
               end;

          A := (- P0.Y + 3 * P1.Y - 3 * P2.Y + P3.Y);
          B := (3 * P0.Y - 6 * P1.Y + 3 * P2.Y);
          C := (- 3 * P0.Y + 3 * P1.Y);
          D := P0.Y;
          Delta := 4 * B * B - 12 * A * C;
          if ((Delta >= 0) and (A <> 0))
          then begin
               T := (- 2 * B - Sqrt(Delta)) / (6 * A);
               if ((T >= 0) and (T <= 1))
               then begin
                    T2 := T * T;
                    T3 := T2 * T;
                    MaxMin := A * T3 + B * T2 + C * T + D;
                    if MaxMin > ARRect.B.Y
                    then ARRect.B.Y := MaxMin
                    else if MaxMin < ARRect.A.Y
                    then ARRect.A.Y := MaxMin;
                    end;
               T := (- 2 * B + Sqrt(Delta)) / (6 * A);
               if ((T >= 0) and (T <= 1))
               then begin
                    T2 := T * T;
                    T3 := T2 * T;
                    MaxMin := A * T3 + B * T2 + C * T + D;
                    if MaxMin > ARRect.B.Y
                    then ARRect.B.Y := MaxMin
                    else if MaxMin < ARRect.A.Y
                    then ARRect.A.Y := MaxMin;
                    end;
               end;
     end;
begin
     inherited GetItemsRect(ARRect, ATheFirst);
     Temp2 := PDragBezierPoint(FirstChild);
     if (FirstChild <> nil)
     then begin
          Temp1 := PDragBezierPoint(FirstChild);
          Temp2 := PDragBezierPoint(Temp1^.Next);
          while (Temp2 <> PDragBezierPoint(FirstChild))
          do begin
             GetBezierRect(Temp1^.Origin[1], Temp1^.Origin[2], Temp2^.Origin[3], Temp2^.Origin[1]);
             Temp1 := Temp2;
             Temp2 := PDragBezierPoint(Temp1^.Next);
             end;
          end;
end;

function TDragBezier.GetBezierLength( P0,P1,P2,P3: TRPoint; ACount: Longint ): Float;
var T, T2, T3: Float;
    AX, BX, CX, DX,
    AY, BY, CY, DY: Float;
    RPoint1, RPoint2: TRPoint;
    DeltaT: Float;
    Length: Float;
begin
     DeltaT := 1 / ACount;
     RPoint1 := P0;
     AX := (- P0.X + 3 * P1.X - 3 * P2.X + P3.X);
     BX := (3 * P0.X - 6 * P1.X + 3 * P2.X);
     CX := (- 3 * P0.X + 3 * P1.X);
     DX := P0.X;
     AY := (- P0.Y + 3 * P1.Y - 3 * P2.Y + P3.Y);
     BY := (3 * P0.Y - 6 * P1.Y + 3 * P2.Y);
     CY := (- 3 * P0.Y + 3 * P1.Y);
     DY := P0.Y;
     Length := 0;
     T := DeltaT;
     while T < 1
     do begin
        T2 := T * T;
        T3 := T2 * T;
        RPoint2.X := AX * T3 + BX * T2 + CX * T + DX;
        RPoint2.Y := AY * T3 + BY * T2 + CY * T + DY;
        Length := Length + Sqrt(Sqr(RPoint2.X - RPoint1.X) + Sqr(RPoint2.Y - RPoint1.Y));
        T := T + DeltaT;
        RPoint1 := RPoint2;
        end;
     Length := Length + Sqrt(Sqr(P3.X - RPoint1.X) + Sqr(P3.Y - RPoint1.Y));
     GetBezierLength := Length;
end;

procedure TDragBezier.GetBezierPath( P0,P1,P2,P3: TRPoint; ACount: Longint;
                                     var AFirstPathPoint: PPathPoint; var ALastPathPoint: PPathPoint);
var T, T2, T3: Float;
    AX, BX, CX, DX,
    AY, BY, CY, DY: Float;
    RPoint1, RPoint2: TRPoint;
    DeltaT: Float;
begin
     DeltaT := 1 / ACount;
     RPoint1 := P0;
     AX := (- P0.X + 3 * P1.X - 3 * P2.X + P3.X);
     BX := (3 * P0.X - 6 * P1.X + 3 * P2.X);
     CX := (- 3 * P0.X + 3 * P1.X);
     DX := P0.X;
     AY := (- P0.Y + 3 * P1.Y - 3 * P2.Y + P3.Y);
     BY := (3 * P0.Y - 6 * P1.Y + 3 * P2.Y);
     CY := (- 3 * P0.Y + 3 * P1.Y);
     DY := P0.Y;
     T := DeltaT;
     if (AFirstPathPoint <> nil)
     then begin
          New(ALastPathPoint^.Next);
          ALastPathPoint := ALastPathPoint^.Next;
          end
     else begin
          New(ALastPathPoint);
          AFirstPathPoint := ALastPathPoint;
          end;
     ALastPathPoint^.Valid := True;
     while T < 1
     do begin
        T2 := T * T;
        T3 := T2 * T;
        RPoint2.X := AX * T3 + BX * T2 + CX * T + DX;
        RPoint2.Y := AY * T3 + BY * T2 + CY * T + DY;
        ALastPathPoint^.Point := RPoint2;
        T := T + DeltaT;
        RPoint1 := RPoint2;
        New(ALastPathPoint^.Next);
        ALastPathPoint := ALastPathPoint^.Next;
        ALastPathPoint^.Valid := True;
        end;
     ALastPathPoint^.Next := nil;
     ALastPathPoint^.Point := P3;
end;

procedure TDragBezier.Draw( var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Pen, OldPen: HPen;
    LB: TLogBrush;
    Point, Point1, Point2, Point3: TPoint;
    RRect: TRRect;

    procedure DrawPoints;
    var Pen, OldPen: HPen;
    begin
         if (not IsGrouped)
         then begin
              Pen := CreatePen(0,PS_SOLID,RGB(0,0,255));
              OldPen := SelectObject(DrawInfo.DrawDC, Pen);
              inherited Draw(DrawInfo,AStateInfo);
              SelectObject(DrawInfo.DrawDC,OldPen);
              DeleteObject(Pen);
              end;
    end;

    procedure DrawTheBezier;
    var {TempChild: PDragMultiPoint;}
        Point: TPoint;
        Temp1, Temp2: PDragMultiPoint;
    begin
         if ((FirstChild <> nil) and ((not IsGroupedOwner) or (not (AStateInfo^.State = stEdit))))
         then begin
              Temp1 := PDragMultiPoint(FirstChild);
              Temp2 := PDragMultiPoint(Temp1^.Next);
              while (Temp2 <> PDragMultiPoint(FirstChild))
              do begin
                 DrawBezier( DrawInfo, Temp1^.Origin[1], Temp1^.Origin[2], Temp2^.Origin[3], Temp2^.Origin[1]);
                 Temp1 := Temp2;
                 Temp2 := PDragMultiPoint(Temp1^.Next);
                 end;
              end;
    end;

begin
     if AStateInfo = nil
     then Exit;

     case AStateInfo^.State
     of stEdit: begin
                DrawPoints;
                DrawTheBezier;
                end;
        stModal: begin
                 DrawPoints;
                 if (AStateInfo^.ModalInfo.ModalObject = @Self)
                 then begin
                      if (FirstChild <> nil)
                      then if (FirstChild^.Prev <> nil)
                           then begin
                                Pen := CreatePen(0,PS_SOLID,RGB(255,0,0));
                                OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                                ConvertToView(PDragMultiPoint(FirstChild^.Prev)^.Origin[1], Point);
                                Ellipse(DrawInfo.DrawDC, Point.X - 3, Point.Y - 3, Point.X + 4, Point.Y + 4);
                                SelectObject(DrawInfo.DrawDC,OldPen);
                                DeleteObject(Pen);
                                end;
                      end;
                 DrawTheBezier;
                 end;
        stDrag: begin
                DrawPoints;
                DrawTheBezier;
                end;
        stPreview: begin
                   end;
        end;
     DrawGroupFrame(DrawInfo, AStateInfo);
end;

function TDragBezier.ContainsPoint( APoint:TPoint):Boolean;
begin
     ContainsPoint := False;
end;

function TDragBezier.HandleEvent( var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
var NewPoint: PDragBezierPoint;
    RPoint: TRPoint;
label HandleOld;
begin
     if AStateInfo = nil
     then Exit;

     if (AStateInfo^.State = stModal)
     then begin
          case AStateInfo^.ModalInfo.ModalType
          of mtAppend: begin
                       if (EventInfo.Event = evMouseLDown)
                       then begin
                            ConvertToLogic(EventInfo.ViewPos, RPoint);
                            NewPoint := New(PDragBezierPoint, Create(RPoint.X, RPoint.Y));
                            Insert(NewPoint);
                            Refresh(True);
                            end
                       else if (EventInfo.Event = evMouseRDown)
                       then begin
                            SetState(stEdit, @Self);
                            Refresh(True);
                            end;
                       HandleEvent := True;
                       end;
          else
              goto HandleOld;
          end;
          end
     else begin
          HandleOld:
          if inherited HandleEvent( EventInfo, AStateInfo)
          then begin
               MakeCurrent;
               HandleEvent := True;
               end
          else begin
               HandleEvent := False;
               end;
          end;
end;

function TDragBezier.GetTheCurrent: PDragObject;
begin
     GetTheCurrent := Inherited GetTheCurrent;
     {GetTheCurrent := @Self;}
end;

function TDragBezier.GetSectionsCount: Longint;
var Count: Longint;
    Temp :PDragBezierPoint;
begin
     Temp := PDragBezierPoint(FirstChild);
     Count := 1;
     repeat
           if ((Temp^.StopPoint) and (Temp <> PDragBezierPoint(FirstChild)))
           then Count := Count + 1;
           Temp := PDragBezierPoint(Temp^.Next);
     until (Temp = PDragBezierPoint(FirstChild));
     GetSectionsCount := Count;
end;

function TDragBezier.GetSectionLimits(ASection: Longint; var AStart, AStop: PDragBezierPoint): Boolean;
var Section: Longint;
    StartPoint, StopPoint :PDragBezierPoint;
begin
     if (ASection <> 0)
     then begin
          Section := 1;
          StartPoint := PDragBezierPoint(FirstChild);
          while ((Section < ASection) and (StartPoint <> PDragBezierPoint(FirstChild^.Prev)))
          do begin
             StartPoint := PDragBezierPoint(StartPoint^.Next);
             if (StartPoint^.StopPoint)
             then Section := Section + 1;
             end;
          if (StartPoint <> PDragBezierPoint(FirstChild^.Prev))
          then begin
               StopPoint := PDragBezierPoint(StartPoint^.Next);
               while ((not StopPoint^.StopPoint) and (StopPoint <> PDragBezierPoint(FirstChild^.Prev)))
               do StopPoint := PDragBezierPoint(StopPoint^.Next);
               end
          else StopPoint := StartPoint;
          end
     else begin
          StartPoint := PDragBezierPoint(FirstChild);
          StopPoint := PDragBezierPoint(FirstChild^.Prev);
          end;

     AStart := StartPoint;
     AStop := StopPoint;
     GetSectionLimits := True;
end;

function TDragBezier.GetSectionLength(ASection: Longint): Float;
var TempChild: PDragBezierPoint;
    StartPoint, StopPoint :PDragBezierPoint;
    Length: Float;
begin
     GetSectionLimits(ASection, StartPoint, StopPoint);
     TempChild := StartPoint;

     Length := 0;
     if (TempChild <> nil)
     then repeat;
                 Length := Length + GetBezierLength( TempChild^.Origin[1],
                                                     TempChild^.Origin[2],
                                                     PDragBezierPoint(TempChild^.Next)^.Origin[3],
                                                     PDragBezierPoint(TempChild^.Next)^.Origin[1],
                                                     BEZIERPOINTSCOUNT);
{DrawBezier( DrawInfo, Origin[1], Origin[2],
                                   PDragBezierPoint(Next)^.Origin[3], PDragBezierPoint(Next)^.Origin[1]);}
                 TempChild := PDragBezierPoint(TempChild^.Next);
          until (TempChild = StopPoint);
     GetSectionLength := Length;
end;


function TDragBezier.GetSectionPoints(APointsCount: Longint; ASection: Longint): PPathPoint;
var PrevTemp, Temp: PPathPoint;
    StartPoint, StopPoint,
    TempPoint: PDragBezierPoint;

    FirstBezierPoint, LastBezierPoint: PPathPoint;
    FirstPathPoint, LastPathPoint: PPathPoint;
    CurrentRemainLength,
    StepLength,
    Remain,
    LastX, LastY,
    KX, KY : Float;
    I: Longint;

    procedure AppendPoint( AX, AY: Float);
    var Temp: PPathPoint;
    begin
         New( Temp);
         Temp^.Valid := True;
         Temp^.Next := nil;
         Temp^.Point.X := AX;
         Temp^.Point.Y := AY;
         if (FirstPathPoint <> nil)
         then begin
              LastPathPoint^.Next := Temp;
              LastPathPoint := Temp;
              end
         else begin
              FirstPathPoint := Temp;
              LastPathPoint := Temp;
              end;
    end;
begin
     FirstPathPoint := nil;
     LastPathPoint := nil;
     StepLength := GetSectionLength(ASection) / (APointsCount - 1);
     GetSectionLimits(ASection, StartPoint, StopPoint);

     if ((StartPoint <> nil) and (StopPoint <> nil) and (StartPoint <> StopPoint) and (StepLength > 0))
     then begin
          TempPoint := StartPoint;
          New(FirstBezierPoint);
          FirstBezierPoint^.Valid := True;
          FirstBezierPoint^.Point := TempPoint^.Origin[1];
          FirstBezierPoint^.Next := nil;
          LastBezierPoint := FirstBezierPoint;
          while (TempPoint <> StopPoint)
          do begin
             GetBezierPath( TempPoint^.Origin[1], TempPoint^.Origin[2],
                            PDragBezierPoint(TempPoint^.Next)^.Origin[3],
                            PDragBezierPoint(TempPoint^.Next)^.Origin[1], BEZIERPOINTSCOUNT,
                            FirstBezierPoint, LastBezierPoint);
             TempPoint := PDragBezierPoint(TempPoint^.Next);
             end;
          if (FirstBezierPoint <> nil)
          then begin
               Remain := StepLength;
               Temp := FirstBezierPoint;
               LastX := Temp^.Point.X;
               LastY := Temp^.Point.Y;
               AppendPoint( LastX, LastY);
               PrevTemp := Temp;
               repeat
                     Temp := Temp^.Next;
                     CurrentRemainLength := Sqrt(Sqr(Temp^.Point.X - LastX) + Sqr(Temp^.Point.Y - LastY));
                     if (CurrentRemainLength > 0)
                     then begin
                          KX := (Temp^.Point.X - LastX) / CurrentRemainLength;
                          KY := (Temp^.Point.Y - LastY) / CurrentRemainLength;
                          while (CurrentRemainLength > Remain)
                          do begin
                             LastX := LastX + KX * Remain;
                             LastY := LastY + KY * Remain;
                             AppendPoint(LastX, LastY);
                             CurrentRemainLength := CurrentRemainLength - Remain;
                             Remain := StepLength;
                             end;
                          Remain := Remain - CurrentRemainLength;
                          end;
                     LastX := Temp^.Point.X;
                     LastY := Temp^.Point.Y;
                     PrevTemp := Temp;
               until (Temp = LastBezierPoint);
               AppendPoint(PrevTemp^.Point.X, PrevTemp^.Point.Y);
               end;
          FreePathPoints(FirstBezierPoint);
          end
     else begin
          if (Temp <> nil)
          then begin
               LastX := PDragBezierPoint(FirstChild)^.Origin[1].X;
               LastY := PDragBezierPoint(FirstChild)^.Origin[1].Y;
               for I := 1 to APointsCount
               do AppendPoint(LastX, LastY);
               end;
          end;
     GetSectionPoints := FirstPathPoint;
end;

procedure TDragBezier.CopySelfTo(AObject: PDragObject);
begin
     inherited CopySelfTo(AObject);
end;

function TDragBezier.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDragBezier, Create);
end;

procedure TDragBezier.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
var Temp: PDragObject;
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efDeleteCurrent: begin
                         if ((IsGrouped) or (GetChildsCount <= 1))
                         then begin
                              Temp := Owner;
                              Delete;
                              if (Temp <> nil)
                              then Temp^.RefreshFromChilds(True);
                              end
                         else begin
                              if (Current <> nil)
                              then Current^.MakeEffect(AEffect, AEffectInfo, AStateInfo);
                              end;
                         end;
        efAppendPoints: begin
                        SetState(stModal, @Self);
                        if (AStateinfo^.State = stModal)
                        then begin
                             AStateInfo^.ModalInfo.ModalType := mtAppend;
                             Refresh(True);
                             end;
                        end;
        else
            inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
        end;
end;

procedure TDragBezier.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipHorizontal: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comDeleteCurrent:  AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comRotate: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comGroup: AEnable := AEnable or (not Grouped and (AStateInfo^.State = stEdit));
        comUnGroup: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comClone: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comMakeTwin: AEnable := AEnable or (not IsLockedByParent and (AStateInfo^.State = stEdit));
        comMakeLinear: AEnable := AEnable or (not IsLockedByParent and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

procedure TDrawnItem.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
end;

procedure TDrawnItem.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
end;

function TDrawnItem.GetTypeId: Word;
begin
     GetTypeId := tiDrawnItem;
end;

procedure TDrawnItem.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     case AEffect
     of efInitPreviewData: begin
                           if not Grouped
                           then MakeGroup;
                           end;
        efFreePreviewData: begin
                           end;
     else inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

function TDrawnItem.ContainsPoint( APoint:TPoint):Boolean;
begin
     if ((APoint.X >= LableOrigin.X) and (APoint.X <= (LableOrigin.X + LableSize.X))
        and (APoint.Y >= LableOrigin.Y) and (APoint.Y <= (LableOrigin.Y + LableSize.Y)))
     then ContainsPoint := True
     else ContainsPoint := False;
end;

procedure TDrawnItem.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var S: string;
    Origin: TPoint;
    RRect: TRRect;
    Point1,
    Point2: TPoint;
    Pen, OldPen: HPen;
    LastState: Boolean;
begin
     if (AStateInfo^.State = stPreview)
     then begin
          LastState := AStateInfo^.PreviewInfo.LabelEnable;
          AStateInfo^.PreviewInfo.LabelEnable := False;
          inherited Draw(DrawInfo, AStateInfo);
          if LastState
          then begin
               GetItemsRect(RRect, True);
               ConvertToView(RRect.A, Point1);
               ConvertToView(RRect.B, Point2);
               Pen := CreatePen(PS_SOLID, 0, RGB(192, 192, 192));
               OldPen := SelectObject(DrawInfo.DrawDC, Pen);
               MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
               LineTo(DrawInfo.DrawDC, Point2.X, Point1.Y);
               LineTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
               LineTo(DrawInfo.DrawDC, Point1.X, Point2.Y);
               LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
               SelectObject(DrawInfo.DrawDC, OldPen);
               AStateInfo^.PreViewInfo.Count := AStateInfo^.PreViewInfo.Count + 1;
               Str(AStateInfo^.PreViewInfo.Count, S);
               DisplayLabel(DrawInfo, Point1.X, Point1.Y, S);
               end;
          AStateInfo^.PreviewInfo.LabelEnable := LastState;
          end
     else inherited Draw(DrawInfo, AStateInfo);
end;

procedure TDrawnItem.DisplayLabel(var DrawInfo: TDrawInfo; AX, AY: Integer; ALable: string);
var Extent: Longint;
begin
     Extent := GetTextExtent(DrawInfo.DrawDC, @ALable[1], Length(ALable));
     Rectangle(DrawInfo.DrawDC, AX - 2, AY - 1, AX + LOWORD(Extent) + 2, AY + HIWORD(Extent) + 1);
     TextOut(DrawInfo.DrawDC, AX, AY, @ALable[1], Length(ALable));

     LableOrigin.X := AX - 2;
     LableOrigin.Y := AY - 1;
     LableSize.X := LOWORD(Extent) + 2;
     LableSize.Y := HIWORD(Extent) + 1;
end;

function TDrawnItem.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
begin
     if AStateInfo = nil then Exit;
     if (AStateInfo^.State = stPreview)
     then begin
          case EventInfo.Event
          of evMouseLDown: begin
                           if ContainsPoint(EventInfo.ViewPos)
                           then begin
                                SendAsResponse(@Self);
                                HandleGroupEvent := True;
                                end
                           else HandleGroupEvent := inherited HandleGroupEvent(EventInfo, AStateInfo);
                           end;
          else
              HandleGroupEvent := False;
          end;
          end
     else HandleGroupEvent := inherited HandleGroupEvent(EventInfo, AStateInfo);
end;

function TDrawnItem.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PDrawnItem, Create);
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TTwinDrawnItem.Create;
begin
     inherited Create;
     PathPoints := nil;
     Density := DefTwinDrawnItemProperties.Density;
     StepMode := DefTwinDrawnItemProperties.StepMode;
     StepLength := DefTwinDrawnItemProperties.StepLength;
     StepsCount := DefTwinDrawnItemProperties.StepsCount;
end;

destructor TTwinDrawnItem.Destroy;
begin
     FreePathPoints(PathPoints);
     PathPoints := nil;
     inherited Destroy;
end;

procedure TTwinDrawnItem.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Density, SizeOf(Density));
     AStream^.ReadBlock(StepMode, SizeOf(StepMode));
     AStream^.ReadBlock(StepLength, SizeOf(StepLength));
     AStream^.ReadBlock(StepsCount, SizeOf(StepsCount));
     PathPoints := nil;
end;

procedure TTwinDrawnItem.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Density, SizeOf(Density));
     AStream^.WriteBlock(StepMode, SizeOf(StepMode));
     AStream^.WriteBlock(StepLength, SizeOf(StepLength));
     AStream^.WriteBlock(StepsCount, SizeOf(StepsCount));
     PathPoints := nil;
end;

function TTwinDrawnItem.GetTypeId: Word;
begin
     GetTypeId := tiTwinDrawnItem;
end;

procedure TTwinDrawnItem.LeaveChild(AChild: PDragObject);
begin
     inherited LeaveChild(AChild);
     FreePathPoints(PathPoints);
     PathPoints := nil;
end;

function TTwinDrawnItem.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
begin
     if AStateInfo = nil
     then Exit;

     if inherited HandleGroupEvent(EventInfo, AStateInfo)
     then begin
          MakeCurrent;
          HandleGroupEvent := True;
          end
     else begin
          HandleGroupEvent := False;
          end;
end;

procedure TTwinDrawnItem.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point1, Point2, Point3: TPoint;
    RRect: TRRect;
    Pen, OldPen: HPen;
    Temp: PPathPoint;
    S: string[20];
    procedure DrawPath;
    var Temp: PPathPoint;
        OldPen, Pen: HPen;
        LastPoint: TPoint;
    begin
         Pen := CreatePen(PS_SOLID, 0,RGB(0,255,0));
         OldPen := SelectObject(DrawInfo.DrawDC, Pen);
         Temp := PathPoints;
         if (Temp <> nil)
         then begin
              ConvertToView(Temp^.Point, Point1);
              MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
              Point2 := Point1;
              Temp := Temp^.Next;
              while (Temp <> nil)
              do begin
                 ConvertToView(Temp^.Point, Point1);
                 LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                 SetPixel(DrawInfo.DrawDC, Point2.X, Point2.Y, RGB(0,0,0));
                 Point2 := Point1;
                 Temp := Temp^.Next;
                 end;
              SetPixel(DrawInfo.DrawDC, Point2.X, Point2.Y, RGB(0,0,0));
              end;
         SelectObject(DrawInfo.DrawDC, OldPen);
         DeleteObject(Pen);
    end;
begin
     if AStateInfo = nil
     then Exit;

     case AStateInfo^.State
     of stEdit: begin
                inherited Draw(DrawInfo, AStateInfo);
                if IsGrouped
                then DrawPath;
                end;
        stDrag: begin
                inherited Draw(DrawInfo, AStateInfo);
                end;
        stModal: begin
                 inherited Draw(DrawInfo, AStateInfo);
                 end;
        stPreview: begin

                   Temp := PathPoints;
                   if (Temp <> nil)
                   then begin
                        ConvertToView(Temp^.Point, Point3);
                        ConvertToView(AStateInfo^.PreviewInfo.LastPos, Point2);
                        Pen := CreatePen(PS_DOT, 0, RGB(255, 0, 0));
                        OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                        MoveTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                        LineTo(DrawInfo.DrawDC, Point3.X, Point3.Y);
                        SelectObject(DrawInfo.DrawDC, OldPen);
                        DeleteObject(Pen);
                        while (Temp^.Next <> nil)
                        do begin
                           ConvertToView(Temp^.Point, Point1);
                           LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                           Temp := Temp^.Next;
                           end;
                        ConvertToView(Temp^.Point, Point1);
                        LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                        AStateInfo^.PreviewInfo.LastPos := Temp^.Point;
                        if AStateInfo^.PreviewInfo.LabelEnable
                        then begin
                             AStateInfo^.PreViewInfo.Count := AStateInfo^.PreViewInfo.Count + 1;
                             Str(AStateInfo^.PreViewInfo.Count, S);
                             DisplayLabel(DrawInfo, Point3.X, point3.Y, S);
                             end;
                        end;
                   end;
        else
        end;
end;

procedure TTwinDrawnItem.GenerateOutput(AOutputGenerator: POutputGenerator);
var Temp1, Temp2: PPathPoint;
    Point: TRPoint;
    Length: Float;
    Delta: TRpoint;
    Count: Longint;
begin
     if AOutputGenerator = nil then Exit;
     if PathPoints = nil
     then PathPoints := GetPathPoints;

     case StepMode
     of 1: begin
           if (StepsCount <= 1)
           then begin
                Temp1 := PathPoints;
                while (Temp1 <> nil)
                do begin
                   AOutputGenerator^.AddJump(Temp1^.Point);
                   Temp1 := Temp1^.Next;
                   end;
                end
           else begin
                if (PathPoints <> nil)
                then begin
                     Temp1 := PathPoints;
                     Temp2 := PathPoints^.Next;
                     while (Temp2 <> nil)
                     do begin
                        AOutputGenerator^.AddJump(Temp1^.Point);
                        Length := Sqrt(Sqr(Temp2^.Point.X - Temp1^.Point.X) + Sqr(Temp2^.Point.Y - Temp1^.Point.Y));
                        Count := StepsCount;
                        if (Count > 0)
                        then begin
                             Delta.X := (Temp2^.Point.X - Temp1^.Point.X) / Count;
                             Delta.Y := (Temp2^.Point.Y - Temp1^.Point.Y) / Count;
                             Point := Temp1^.Point;
                             while (Count > 1)
                             do begin
                                Point.X := Point.X + Delta.X;
                                Point.Y := Point.Y + Delta.Y;
                                AOutputGenerator^.AddJump(Point);
                                Count := Count - 1;
                                end;
                             end;
                        Temp1 := Temp2;
                        Temp2 := Temp2^.Next;
                        end;
                     AOutputGenerator^.AddJump(Temp1^.Point);
                     end;
                end;
           end;
        2: begin
           if (PathPoints <> nil)
           then begin
                Temp1 := PathPoints;
                Temp2 := PathPoints^.Next;
                while (Temp2 <> nil)
                do begin
                   AOutputGenerator^.AddJump(Temp1^.Point);
                   Length := Sqrt(Sqr(Temp2^.Point.X - Temp1^.Point.X) + Sqr(Temp2^.Point.Y - Temp1^.Point.Y));
                   Count := Trunc(Length / StepLength) + 1;
                   if (Count > 0)
                   then begin
                        Delta.X := (Temp2^.Point.X - Temp1^.Point.X) / Count;
                        Delta.Y := (Temp2^.Point.Y - Temp1^.Point.Y) / Count;
                        Point := Temp1^.Point;
                        while (Count > 1)
                        do begin
                           Point.X := Point.X + Delta.X;
                           Point.Y := Point.Y + Delta.Y;
                           AOutputGenerator^.AddJump(Point);
                           Count := Count - 1;
                           end;
                        end;
                   Temp1 := Temp2;
                   Temp2 := Temp2^.Next;
                   end;
                AOutputGenerator^.AddJump(Temp1^.Point);
                end;
           end;
        end;


     {if (StepMode <> 2)
     then begin
          Temp1 := PathPoints;
          while (Temp1 <> nil)
          do begin
             AOutputGenerator^.AddJump(Temp1^.Point);
             Temp1 := Temp1^.Next;
             end;
          end
     else begin
          if (PathPoints <> nil)
          then begin
               Temp1 := PathPoints;
               Temp2 := PathPoints^.Next;
               while (Temp2 <> nil)
               do begin
                  AOutputGenerator^.AddJump(Temp1^.Point);
                  Length := Sqrt(Sqr(Temp2^.Point.X - Temp1^.Point.X) + Sqr(Temp2^.Point.Y - Temp1^.Point.Y));
                  Count := Trunc(Length / StepLength) + 1;
                  if (Count > 0)
                  then begin
                       Delta.X := (Temp2^.Point.X - Temp1^.Point.X) / Count;
                       Delta.Y := (Temp2^.Point.Y - Temp1^.Point.Y) / Count;
                       Point := Temp1^.Point;
                       while (Count > 0)
                       do begin
                          Point.X := Point.X + Delta.X;
                          Point.Y := Point.Y + Delta.Y;
                          AOutputGenerator^.AddJump(Point);
                          Count := Count - 1;
                          end;
                       end;
                  Temp1 := Temp2;
                  Temp2 := Temp2^.Next;
                  end;
               AOutputGenerator^.AddJump(Temp1^.Point);
               end;
          end;}
end;

function TTwinDrawnItem.GetPathPoints: PPathPoint;
var PointsA, PointsB,
    Points: PPathPoint;
    PathA, PathB: PPath;
    I, SectionCount: Longint;

    function MergePoints(PointsA, PointsB: PPathPoint): PPathPoint;
    var HeadA, HeadB, TempAB,
        Result, Last: PPathPoint;
    begin
         Result := nil;
         Last := nil;
         HeadA := PointsA;
         HeadB := PointsB;
         if (HeadA <> nil)
         then begin
              Result := HeadA;
              Last := HeadA;
              HeadA := HeadA^.Next;
              if (HeadB <> nil)
              then begin
                   Last^.Next := HeadB;
                   Last := Last^.Next;
                   HeadB := HeadB^.Next;
                   end;
              Last^.Next := nil;
              end;
         while ((HeadA <> nil) and (HeadB <> nil))
         do begin
            Last^.Next := HeadA;
            HeadA := HeadA^.Next;
            Last := Last^.Next;
            Last^.Next := HeadB;
            HeadB := HeadB^.Next;
            Last := Last^.Next;
            end;
         if Last <> nil
         then Last^.Next := nil;
         FreePathPoints(HeadA);
         FreePathPoints(HeadB);
         MergePoints := Result;
    end;

    procedure AppendPoints(APoints: PPathPoint);
    var TempPoint: PPathPoint;
    begin
         TempPoint := Points;
         if (TempPoint <> nil)
         then begin
              while (TempPoint^.Next <> nil)
              do TempPoint := TempPoint^.Next;
              TempPoint^.Next := APoints
              end
         else Points := APoints;
    end;

var LengthA, LengthB, AVLength: Float;
    Count: Longint;
    MaxCount: Longint;
begin
     Points := nil;
     PathA := PPath(GetChild(1));
     PathB := PPath(GetChild(2));
     if ((PathA <> nil) and (PathB <> nil))
     then begin
          SectionCount := PathA^.GetSectionsCount;
          if (SectionCount = PathB^.GetSectionsCount)
          then begin
               for I := 1 to SectionCount
               do begin
                  LengthA := PathA^.GetSectionLength(I);
                  LengthB := PathB^.GetSectionLength(I);

                  if (LengthA <= LengthB)
                  then MaxCount := Trunc(LengthA / 6)
                  else MaxCount := Trunc(LengthB / 6);

                  AVLength := LengthA + LengthB / 2;
                  if (Density < AVLength)
                  then begin
                       Count := Trunc(AVLength / Density);
                       if Count > MaxCount
                       then Count := MaxCount;
                       if (Count > 0)
                       then begin
                            PointsA := PathA^.GetSectionPoints(Count, I);
                            PointsB := PathB^.GetSectionPoints(Count, I);
                            AppendPoints(MergePoints(PointsA, PointsB));
                            end;
                       end;
                  end;
               end
          else Points := nil;
          end
     else Points := nil;
     GetPathPoints := Points;
end;

procedure TTwinDrawnItem.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efClone: begin
                 inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        efEditProperty: begin
                        SendAsResponse( @Self);
                        end;
        efInitPreviewData: begin
                           inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                           if (PathPoints = nil)
                           then PathPoints := GetPathPoints;
                           end;
        efFreePreviewData: begin
                           inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                           end;
     else inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

procedure TTwinDrawnItem.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PTwinDrawnItem(AObject)^.PathPoints := nil;
          PTwinDrawnItem(AObject)^.Density := Density;
          PTwinDrawnItem(AObject)^.StepMode := StepMode;
          PTwinDrawnItem(AObject)^.StepLength := StepLength;
          PTwinDrawnItem(AObject)^.StepsCount := StepsCount;
          end;
end;

function TTwinDrawnItem.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PTwinDrawnItem, Create);
end;

procedure TTwinDrawnItem.Refresh(APassToOwner: Boolean);
var StateInfo: PStateInfo;
begin
     if RefreshLocked
     then exit;
     StateInfo := GetStateInfo;
     if StateInfo = nil then Exit;
     FreePathPoints(PathPoints);
     PathPoints := nil;
     if (IsGrouped and ((StateInfo^.State = stEdit) or (StateInfo^.State = stPreview))){and redo calculation flag on}
     then begin
          PathPoints := GetPathPoints;
          end;
     inherited Refresh(APassToOwner);
end;

function TTwinDrawnItem.IsLockedChild(AChild: PDragObject): Boolean;
begin
     if (AChild <> nil)
     then begin
          if (AChild^.Owner = @Self)
          then IsLockedChild := True
          else IsLockedChild := False;
          end
     else IsLockedChild := False;
end;

procedure TTwinDrawnItem.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipHorizontal: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comDeleteCurrent:  AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comRotate: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comGroup: AEnable := (not Grouped and (AStateInfo^.State = stEdit));
        comUnGroup: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comClone: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comBreakGroup: AEnable := (True and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comEditProperty: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        end;
end;

{**************************************}
{*                                    *}
{*                                    *}
{*                                    *}
{**************************************}

constructor TLinearDrawnItem.Create;
begin
     inherited Create;
     PathPoints := nil;
     Density := DefLinearDrawnItemProperties.Density;
     Mode := DefLinearDrawnItemProperties.Mode;
     Width := DefLinearDrawnItemProperties.Width;
end;

destructor TLinearDrawnItem.Destroy;
begin
     FreePathPoints(PathPoints);
     PathPoints := nil;
     inherited Destroy;
end;

procedure TLinearDrawnItem.LoadFromStream(AStream: PStream);
begin
     inherited LoadFromStream(AStream);
     AStream^.ReadBlock(Density, SizeOf(Density));
     AStream^.ReadBlock(Mode, SizeOf(Mode));
     AStream^.ReadBlock(Width, SizeOf(Width));
     PathPoints := nil;
end;

procedure TLinearDrawnItem.WriteToStream(AStream: PStream);
begin
     inherited WriteToStream(AStream);
     AStream^.WriteBlock(Density, SizeOf(Density));
     AStream^.WriteBlock(Mode, SizeOf(Mode));
     AStream^.WriteBlock(Width, SizeOf(Width));
     PathPoints := nil;
end;

function TLinearDrawnItem.GetTypeId: Word;
begin
     GetTypeId := tiLinearDrawnItem;
end;

procedure TLinearDrawnItem.LeaveChild(AChild: PDragObject);
begin
     inherited LeaveChild(AChild);
     FreePathPoints(PathPoints);
     PathPoints := nil;
end;

function TLinearDrawnItem.HandleGroupEvent(var EventInfo: TEventInfo; AStateInfo: PStateInfo):Boolean;
begin
     if AStateInfo = nil
     then Exit;

     if inherited HandleGroupEvent(EventInfo, AStateInfo)
     then begin
          MakeCurrent;
          HandleGroupEvent := True;
          end
     else begin
          HandleGroupEvent := False;
          end;
end;

procedure TLinearDrawnItem.Draw(var DrawInfo: TDrawInfo; AStateInfo: PStateInfo);
var Point1, Point2, Point3: TPoint;
    RRect: TRRect;
    Pen, OldPen: HPen;
    Temp: PPathPoint;
    S: string[20];
    procedure DrawPath;
    var Temp: PPathPoint;
        OldPen, Pen: HPen;
        LastPoint: TPoint;
    begin
         Pen := CreatePen(PS_SOLID, 0,RGB(0,255,0));
         OldPen := SelectObject(DrawInfo.DrawDC, Pen);
         Temp := PathPoints;
         if (Temp <> nil)
         then begin
              ConvertToView(Temp^.Point, Point1);
              MoveTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
              Point2 := Point1;
              Temp := Temp^.Next;
              while (Temp <> nil)
              do begin
                 ConvertToView(Temp^.Point, Point1);
                 LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                 SetPixel(DrawInfo.DrawDC, Point2.X, Point2.Y, RGB(0,0,0));
                 Point2 := Point1;
                 Temp := Temp^.Next;
                 end;
              SetPixel(DrawInfo.DrawDC, Point2.X, Point2.Y, RGB(0,0,0));
              end;
         SelectObject(DrawInfo.DrawDC, OldPen);
         DeleteObject(Pen);
    end;

begin
     if AStateInfo = nil
     then Exit;

     case AStateInfo^.State
     of stEdit: begin
                inherited Draw(DrawInfo, AStateInfo);
                if IsGrouped
                then DrawPath;
                end;
        stDrag: begin
                inherited Draw(DrawInfo, AStateInfo);
                end;
        stModal: begin
                 inherited Draw(DrawInfo, AStateInfo);
                 end;
        stPreview: begin
                   Temp := PathPoints;
                   if (Temp <> nil)
                   then begin
                        ConvertToView(Temp^.Point, Point3);
                        ConvertToView(AStateInfo^.PreviewInfo.LastPos, Point2);
                        Pen := CreatePen(PS_DOT, 0, RGB(255, 0, 0));
                        OldPen := SelectObject(DrawInfo.DrawDC, Pen);
                        MoveTo(DrawInfo.DrawDC, Point2.X, Point2.Y);
                        LineTo(DrawInfo.DrawDC, Point3.X, Point3.Y);
                        SelectObject(DrawInfo.DrawDC, OldPen);
                        DeleteObject(Pen);
                        while (Temp^.Next <> nil)
                        do begin
                           ConvertToView(Temp^.Point, Point1);
                           LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                           Temp := Temp^.Next;
                           end;
                        ConvertToView(Temp^.Point, Point1);
                        LineTo(DrawInfo.DrawDC, Point1.X, Point1.Y);
                        AStateInfo^.PreviewInfo.LastPos := Temp^.Point;
                        if AStateInfo^.PreviewInfo.LabelEnable
                        then begin
                             AStateInfo^.PreViewInfo.Count := AStateInfo^.PreViewInfo.Count + 1;
                             Str(AStateInfo^.PreViewInfo.Count, S);
                             DisplayLabel(DrawInfo, Point3.X, point3.Y, S);
                             end;
                        end;
                   end;
        else
        end;
end;

procedure TLinearDrawnItem.GenerateOutput(AOutputGenerator: POutputGenerator);

    {procedure WritePoint(var APoint: TRPoint);
    var S1,S2: string;
    begin
          AOutputInfo^.Count := AOutputInfo^.Count + 1;
          Str(AOutputInfo^.Count, S1);
          S1 := S1 + ' : ';
          Str(APoint.X:0:3, S2);
          S1 := S1 + S2 + ',';
          Str(APoint.Y:0:3, S2);
          S1 := S1 + S2 + #10#13;
          AOutputInfo^.Stream^.WriteBlock(S1[1], Length(S1));
          AOutputInfo^.LastPos := APoint;
    end;}

    procedure GenerateSimple;
    var Temp: PPathPoint;
    begin
         Temp := PathPoints;
         while (Temp <> nil)
         do begin
            AOutputGenerator^.AddJump(Temp^.Point);
            Temp := Temp^.Next;
            end;
    end;

    procedure GenerateExtended(ABackSteps: Integer);
    var Temp: array[1..32] of PPathPoint;
        Count: integer;
        I: Integer;
    begin
         if ABackSteps < 2
         then Exit;
         Temp[1] := PathPoints;
         for I := 2 to ABackSteps
         do Temp[I] := nil;
         Count := 1;

         if Temp[1] <> nil
         then AOutputGenerator^.AddJump(Temp[1]^.Point);

         while ((Temp[1] <> nil) and (Count <= ABackSteps))
         do begin
            for I := ABackSteps downto 2
            do Temp[I] := Temp[I - 1];
            Count := Count + 1;
            Temp[1] := Temp[1]^.Next;
            end;

         while (Temp[1] <> nil)
         do begin
            AOutputGenerator^.AddJump(Temp[1]^.Point);
            AOutputGenerator^.AddJump(Temp[ABackSteps]^.Point);
            for I := ABackSteps downto 2
            do Temp[I] := Temp[I - 1];
            Temp[1] := Temp[1]^.Next;
            end;

         if (Temp[2] <> nil)
         then AOutputGenerator^.AddJump(Temp[2]^.Point);
    end;

begin
     if AOutputGenerator = nil then Exit;

     if PathPoints = nil
     then PathPoints := GetPathPoints;

     case Mode
     of 1: GenerateSimple;
        2: GenerateExtended(2);
        else
            GenerateSimple;
        end;
end;

function TLinearDrawnItem.GetPathPoints: PPathPoint;
var Points: PPathPoint;
    Path: PPath;
    Length: Float;
    Count: Longint;

    RPoint: array[0..2] of TRPoint;
    Point: array[0..2] of PPathPoint;
    I: Integer;
    Dir, M, MMM, LastM: Float;
    DeltaY: Float;

    ActualDensity: Float;
begin
     Points := nil;
     Path := PPath(GetChild(1));
     if (Path <> nil)
     then begin
          if (Width > 6)
          then begin
               if (Density < 3)
               then ActualDensity := 3
               else ActualDensity := Density;
               end
          else begin
               if (Density < 6)
               then ActualDensity := 6
               else ActualDensity := Density;
               end;

          Length := Path^.GetSectionLength(0);
          Count := Trunc(Length / ActualDensity);
          if (Count > 0)
          then begin
               Points := Path^.GetSectionPoints(Count, 0)
               end
          else Points := nil;
          end
     else Points := nil;

     if ((Width <> 0) and (Points <> nil) and (Mode = 1))
     then begin
          Point[0] := Points;
          I := 2;
          while ((Point[0] <> nil) and (I > 0))
          do begin
             Point[2] := Point[1];
             Point[1] := Point[0];
             Point[0] := Point[0]^.Next;
             I := I - 1;
             end;

          if (Point[0] <> nil)
          then begin
               Dir := Width / 2;
               RPoint[1] := Point[1]^.Point;
               RPoint[2] := Point[2]^.Point;
               LastM := 0;
               repeat
                     RPoint[0] := Point[0]^.Point;
                     DeltaY := RPoint[2].Y - RPoint[0].Y;
                     if (Abs(DeltaY) > 0.001)
                     then begin
                          M := (RPoint[0].X - RPoint[2].X) / DeltaY;
                          MMM := Sqrt(1 + Sqr(M));
                          if ((LastM > 0) and (M < 0)) or ((LastM < 0) and (M > 0))
                          then Dir := - Dir;
                          Point[1]^.Point.X := Point[1]^.Point.X + Dir / MMM;
                          Point[1]^.Point.Y := Point[1]^.Point.Y + M * Dir / MMM;
                          LastM := M;
                          end
                     else if (RPoint[2].X > RPoint[0].X)
                     then Point[1]^.Point.Y := Point[1]^.Point.Y - Dir
                     else Point[1]^.Point.Y := Point[1]^.Point.Y + Dir;

                     RPoint[2] := RPoint[1];
                     RPoint[1] := RPoint[0];
                     Point[2] := Point[1];
                     Point[1] := Point[0];
                     Point[0] := Point[0]^.Next;
                     Dir := - Dir;
               until (Point[0] = nil);
               end;
          end;
     GetPathPoints := Points;
end;

procedure TLinearDrawnItem.MakeEffect(AEffect: Word; var AEffectInfo; AStateInfo: PStateInfo);
begin
     if AStateInfo = nil
     then Exit;

     case AEffect
     of efClone: begin
                 inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                 end;
        efEditProperty: begin
                        SendAsResponse( @Self);
                        end;
        efInitPreviewData: begin
                           inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                           if (PathPoints = nil)
                           then PathPoints := GetPathPoints;
                           end;
        efFreePreviewData: begin
                           inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
                           end;
     else inherited MakeEffect(AEffect, AEffectInfo, AStateInfo);
     end;
end;

procedure TLinearDrawnItem.CopySelfTo(AObject: PDragObject);
begin
     if (AObject <> nil)
     then begin
          inherited CopySelfTo(AObject);
          PLinearDrawnItem(AObject)^.PathPoints := nil;
          PLinearDrawnItem(AObject)^.Density := Density;
          PLinearDrawnItem(AObject)^.Mode := Mode;
          PLinearDrawnItem(AObject)^.Width := Width;
          end;
end;

function TLinearDrawnItem.MakeSelfClone: PDragObject;
begin
     MakeSelfClone := New(PLinearDrawnItem, Create);
end;

procedure TLinearDrawnItem.Refresh(APassToOwner: Boolean);
var StateInfo: PStateInfo;
begin
     if RefreshLocked
     then exit;
     StateInfo := GetStateInfo;
     if StateInfo = nil then Exit;
     FreePathPoints(PathPoints);
     PathPoints := nil;
     if (IsGrouped and ((StateInfo^.State = stEdit) or (StateInfo^.State = stPreview))){and redo calculation flag on}
     then begin
          PathPoints := GetPathPoints;
          end;
     inherited Refresh(APassToOwner);
end;

function TLinearDrawnItem.IsLockedChild(AChild: PDragObject): Boolean;
begin
     if (AChild <> nil)
     then begin
          if (AChild^.Owner = @Self)
          then IsLockedChild := True
          else IsLockedChild := False;
          end
     else IsLockedChild := False;
end;

procedure TLinearDrawnItem.GetCommandStatus(ACommand: Word; var AEnable: Boolean; AStateInfo: PStateInfo);
begin
     inherited GetCommandStatus(ACommand, AEnable, AStateInfo);
     case ACommand
     of comFlipVertical: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipHorizontal: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comDeleteCurrent:  AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comRotate: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comGroup: AEnable := (not Grouped and (AStateInfo^.State = stEdit));
        comUnGroup: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comClone: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        comFlipStopPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirst: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comBreakGroup: AEnable := (True and (AStateInfo^.State = stEdit));
        comExtendPolligon: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comMakeFirstPoint: AEnable := AEnable and (not Grouped and (AStateInfo^.State = stEdit));
        comEditProperty: AEnable := AEnable or (Grouped and (AStateInfo^.State = stEdit));
        end;
end;

begin
     NewObjectData.DrawObject := doPolligon;
     NewObjectData.X1 := 0;
     NewObjectData.Y1 := 0;
     NewObjectData.X2 := 0;
     NewObjectData.Y2 := 0;
     NewObjectData.Count := 2;
     NewObjectData.UsingMouse := True;
end.