program Control;

uses DataTypes, Crt, Generics, Streams, Dos, Graph, GAPI;

const efSTRINGCUT             = $0001;
      efUSERBREAK             = $0002;
      efREACHLIMIT            = $0004;
      efUNKNOWN               = $0008;
      efEXTERNALSTOP          = $0010;
      efRESERVED1             = $0020;
      efRESERVED2             = $0040;
      efRESERVED3             = $0080;
      efRESERVED4             = $0100;
      efRESERVED5             = $0200;
      efRESERVED6             = $0400;
      efRESERVED7             = $0800;
      efRESERVED8             = $1000;

      efRESERVEDMASK          = $1FE0;
      efJUMPERRORMASK         = efSTRINGCUT or efUSERBREAK or efREACHLIMIT or efUNKNOWN or efRESERVEDMASK or efEXTERNALSTOP;
      efMOVEERRORMASK         = efUSERBREAK or efUNKNOWN or efRESERVEDMASK;
      efRESETPOSERRORMASK     = efUSERBREAK or efUNKNOWN or efRESERVEDMASK;

      errNONE                 = 0;
      errSTRINGCUT            = 1;
      errREACHLIMIT           = 2;
      errUSERBREAK            = 3;
      errCOMMANDBREAK         = 4;
      errEXTERNALSTOP         = 5;
      errUNKNOWN              = -1;

      lmtLOX                   = $04;
      lmtHIX                   = $02;
      lmtLOY                   = $10;
      lmtHIY                   = $08;

      FASTJUMPLIMIT            = 50;
      JUMPSBEFORESLOWACTIVE    = 5;
      STARTUPDOWNCOUNT         = 5;

      MAXWAITTESTS             = 100000;

      prtINIT1                 = $030B;
      prtINIT2                 = $030F;
      prtXMOVE                 = $030C;
      prtYMOVE                 = $030D;
      prtCONTR                 = $030A;
      prtTEST1                 = $0308;
      prtTEST2                 = $0309;

const Color: Integer = 1;
      NidleUp: Boolean = True;

type
     PSendData = ^TSendData;

     PBookMark = ^TBookMark;
     TBookMark = object(TGeneric)
        Info: TBookMarkInfo;
        constructor Create;
        end;

     TSendData = object(TGeneric)
     private
        Data: TJumpTableCollection;
     public
        OffsetX, OffsetY: Longint;
        Width, Height: Longint;
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear; virtual;
        function LoadDataFromStream(AStream: PStream): Boolean;
        procedure ProcessDistanceJumps(ASlowLength: Integer); virtual;
        function IsFirst: Boolean; virtual;
        function IsLast: Boolean; virtual;
        function GetCurrent( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean; virtual;
        function GetFirst( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean; virtual;
        function GetLast( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean; virtual;
        function GetNext( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean; virtual;
        function GetPrev( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean; virtual;
        function MoveToFirst: Boolean; virtual;
        function MoveToLast: Boolean; virtual;
        function MoveToNext: Boolean; virtual;
        function MoveToPrev: Boolean; virtual;
        function GetBookMark: PBookMark; virtual;
        function GetCurrentIndex: Longint; virtual;
        function GotoBookMark( ABookMark: PBookMark): Boolean; virtual;
        function GetNumCommands: Longint;
        end;

     PViewPort = ^TViewPort;

     PMachine = ^TMachine;
     TMachine = object(TGeneric)
     private
        OutputPort: PViewPort;

        LimitsErrorOcred: Boolean; { Switched to True if limits reached
        at normal work state (not in pos. rest operation) }
        UserBreakOcured: Boolean; { Switched to True if detected ESC key
        down while testing error, and rested to False at the first call
        of ~Jump~ or ~Move~ or any extrenal Method  }
        ExternalBreakOcured: Boolean;

        LastCntrolOut: Byte; { Keeps the last control byte sended to machine
        and used to detect machine working states }

        function IsEngineWorks: Boolean; { Test one bit
        of ~LastCntrolOut~ variable }
        function SwitchEngineOn: Boolean; { Sends Engine whitch on command
        and wait nidle move from up to down, if no motion detected it outs
        engine switch off command and return false }
        function SwitchEngineOff: Boolean; { Waits for nidle up state and
        out engine switch off command, if not matched nidle up state
        is return false, but the switch off command sended in all cases }
        function IsSlowMode: Boolean; { it tests only the ~LastCntrolOut~
        variable and return result accordingly }
        function SwitchToNormalMode: Boolean; { Outs the normal speed command
        only }
        function SwitchToSlowMode(AWaitForSlow: Boolean): Boolean; { Outs the
        slow speed command and if engine on it waits smoe moves of nidle
        from up to down and then returns true if moves ocured correctly }
        function GetLimitsState: Byte; { getslimts flags by reading the
        in value from the port }
        function IsNidleUp: Boolean;
        function WaitForNidleUp: Boolean;
        function WaitForNidleDown: Boolean;

        procedure OutInitializeCommands;
        procedure OutQuitCommands;
        procedure OutMoveCommand(AX, AY: Integer);
        procedure OutSlowModeCommand;
        procedure OutNormalModeCommand;
        procedure OutSwitchOffCommand;
        procedure OutSwitchOnCommand;
     public
        constructor Create( AMessagePort: PViewPort);
        destructor Destroy; virtual;
        function GetErrorFalgs: Word;
        function Jump(AX, AY: Integer; ALongJump: Boolean): Boolean;
        function Move(AX, AY: Integer): Boolean;
        function Stop: Boolean;
        function ResetPos: Boolean;
        function WaitNidleUpDown(ACount: Longint): Boolean;
        end;

     TViewPort = object(TGeneric)
     private
        X1, X2, Y1 , Y2: Integer;
        BackColor, TextColor: Integer;
        Zoom: Integer;
     public
        constructor Create(AX1, AY1, AX2, AY2, ABackColor, ATextColor: Integer);
        destructor Destroy; virtual;
        procedure SetZoom(AZoom: Integer);
        procedure Activate;
        function GetWidth: Integer;
        function GetHeight: Integer;
        function GetOriginX: Integer;
        function GetOriginY: Integer;
        procedure Clear;
        procedure SetTextColor(AColor: Integer);
        function GetTextColor: Integer;
        procedure OutTextXY(AX, AY: Integer; AS: string; ATransparent: Boolean);
        procedure Line(AX1, AY1, AX2, AY2: Integer);
        procedure DrawJump(AX1, AY1, AX2, AY2: Integer);
        procedure Circle(AX, AY, ARadios: Integer);
        procedure Bar(AX1, AY1, AX2, AY2: Integer);
        procedure Rectangle(AX1, AY1, AX2, AY2: Integer);
        end;

     PCanvas = ^TCanvas;
     TCanvas = object(TGeneric)
     private
     public
        DrawnViewPort,
        InfoViewPort,
        SignalsViewPort,
        MessagesViewPort: TViewPort;
        constructor Create;
        destructor Destroy; virtual;
        procedure DrawFrame;
        function GetOption(ATextColor, ABackColor: Integer; AOptions: string; ADefault: Integer): Integer;
        procedure OutMessage(AMessage: string);
        function InputString(ATitle: string; var AStr: string; AMaxLength: Integer): Boolean;
        function InputInteger(ATitle: string; var AValue: Longint; Min, Max: Longint): Boolean;
        end;

     PController = ^TController;
     TController = object(TGeneric)
     private
        ErrorCode: Integer;
        Data: TSendData;
        Machine: TMachine;
        ViewSendData: Boolean;
        CurrentX, CurrentY: Integer;
        procedure ProcessMachineError;
     public
        Canvas: TCanvas;
        constructor Create;
        destructor Destroy; virtual;
        procedure Run;
        function LoadDataFromFile( AFileName: string): Boolean;
        function InitSendData: Boolean;
        function SendData: Boolean;
        function MoveBack(ACount: Longint): Boolean;
        function MoveForward(ACount: Longint): Boolean;
        procedure DisplayDrawn;
        procedure DisplayUntilCurrentPos;
        function GetErrorCode: Integer;
        procedure UpdateInfoView;
        function ShiftNidle(AOffsetX, AOffsetY: Integer): Boolean;
        end;

     PState = ^TState;
     TState = object(TGeneric)
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        function Enter: Boolean; virtual;
        function Leave: Boolean; virtual;
        end;

     PControllerState = ^TControllerState;
     TControllerState = object(TState)
     private
        Controller: PController;
     public
        constructor Create( AController: PController);
        end;

     PMainMenuState = ^TMainMenuState;
     TMainMenuState = object(TControllerState)
     private
        Option: Integer;
     public
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

     PLoadDataState = ^TLoadDataState;
     TLoadDataState = object(TControllerState)
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

     PViewDataState = ^TViewDataState;
     TViewDataState = object(TControllerState)
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

     PSendDataState = ^TSendDataState;
     TSendDataState = object(TControllerState)
     private
        SendResult: Boolean;
        UserBreakAtInitialize: Boolean;
     public
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        function Enter: Boolean; virtual;
        function Leave: Boolean; virtual;
        end;

     PResumeSendDataState = ^TResumeSendDataState;
     TResumeSendDataState = object(TSendDataState)
        procedure RunState; virtual;
        end;

     PBreakState = ^TBreakState;
     TBreakState = object(TControllerState)
     private
        UserCommand: Integer;
     public
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

     PJumpsManipulationState = ^TJumpsManipulationState;
     TJumpsManipulationState = object(TControllerState)
     private
        ErrorOcured: Boolean;
     public
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

     PExternalManipulationState = ^TExternalManipulationState;
     TExternalManipulationState = object(TControllerState)
     private
        ErrorOcured: Boolean;
     public
        procedure RunState; virtual;
        function GetNextState: PState; virtual;
        end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const ActiveViewPort: PViewPort = nil;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

constructor TBookMark.Create;
begin
     inherited Create;
     FillChar(Info, SizeOf(Info), #0);
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

constructor TSendData.Create;
begin
     inherited Create;
     InitJumpTableCollection( Data);
end;

destructor TSendData.Destroy;
begin
     FreeJmpTableCollection( Data);
     inherited Destroy;
end;

procedure TSendData.Clear;
begin
     FreeJmpTableCollection( Data);
end;

function TSendData.LoadDataFromStream(AStream: PStream): Boolean;
var Table: PJumpTable;
    Count: Longint;
    TableSize: Longint;
    TempFileID: TFileID;
begin
     if (AStream <> nil)
     then begin
          AStream^.ReadBlock(TempFileID, SizeOf(TempFileID));
          if (TempFileID = ControlFileID)
          then begin
               AStream^.ReadBlock(Count, SizeOf(Count));
               AStream^.ReadBlock(OffsetX, SizeOf(OffsetX));
               AStream^.ReadBlock(OffsetY, SizeOf(OffsetY));
               AStream^.ReadBlock(Width, SizeOf(Width));
               AStream^.ReadBlock(Height, SizeOf(Height));
               while (Count > 0)
               do begin
                  if (Count >= MaxTableSize)
                  then TableSize := MaxTableSize
                  else TableSize := Count;
                  Table := AllocateJumpTable( TableSize );
                  AStream^.ReadBlock( Table^.Items, SizeOf(TJumpRec) * TableSize);
                  Table^.Used := TableSize;
                  AppendTableToCollection( Data, Table);
                  Count := Count - TableSize;
                  end;
               LoadDataFromStream := True;
               end
          else LoadDataFromStream := False;
          end
     else LoadDataFromStream := False;
end;

procedure TSendData.ProcessDistanceJumps(ASlowLength: Integer);
var Item: TJumpRec;
    SqrLength: Longint;
    Count: Longint;
    SkipX, SkipY: Integer;
begin
     { Simple processing for long jumps,
       Depends on the length of the juump only ...}

     SkipX := 0;
     SkipY := 0;
     SqrLength := LongInt(ASlowLength) * LongInt(ASlowLength);
     if GetFirstJumpItem(Data, Item)
     then repeat
          if ((Item.Mode <> modStop) and (Item.Mode <> modReset))
          then begin
               Item.DeltaX := Item.DeltaX + SkipX;
               Item.DeltaY := Item.DeltaY + SkipY;
               if ((Item.DeltaX = 1) or (Item.DeltaX = -1))
               then begin
                    SkipX := Item.DeltaX;
                    Item.DeltaX := 0;
                    {Sound(1000);
                    Delay(10);
                    NoSound;}
                    end
               else SkipX := 0;
               if ((Item.DeltaY = 1) or (Item.DeltaY = -1))
               then begin
                    SkipY := Item.DeltaY;
                    Item.DeltaY := 0;
                    {Sound(1000);
                    Delay(10);
                    NoSound;}
                    end
               else SkipY := 0;
               if ((Longint(Longint(Item.DeltaX) * Longint(Item.DeltaX))
                  + Longint(Longint(Item.DeltaY) * Longint(Item.DeltaY))) >= SqrLength)
               then Item.Mode := modSlow
               else Item.Mode := modNormal;
               SetCurrentJumpItem(Data, Item);
               end;
          until not GetNextJumpItem(Data, Item);

     Count := JUMPSBEFORESLOWACTIVE;
     if GetLastJumpItem(Data, Item)
     then repeat
          if (Item.Mode = modSlow)
          then Count := JUMPSBEFORESLOWACTIVE
          else if ((Count > 0) and (Item.Mode = modNormal))
               then begin
                    Item.Mode := modSlow;
                    SetCurrentJumpItem(Data, Item);
                    Count := Count - 1;
                    end
               else if (Item.Mode = modStop)
                    then Count := 0;
          until not GetPrevJumpItem(Data, Item);
end;

function TSendData.IsFirst: Boolean;
begin
     IsFirst := IsFirstJumpItem(Data);
end;

function TSendData.IsLast: Boolean;
begin
     IsLast := IsLastJumpItem(Data);
end;

function TSendData.GetCurrent( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean;
var Item: TJumpRec;
begin
     GetCurrent := GetCurrentJumpItem(Data, Item);
     AMode := Item.Mode;
     ADeltaX := Item.DeltaX;
     ADeltaY := Item.DeltaY;
end;

function TSendData.MoveToFirst: Boolean;
begin
     MoveToFirst := MoveToFirstJumpItem(Data);
end;

function TSendData.MoveToLast: Boolean;
begin
     MoveToLast := MoveToLastJumpItem(Data);
end;

function TSendData.MoveToNext: Boolean;
begin
     MoveToNext := MoveToNextJumpItem(Data);
end;

function TSendData.MoveToPrev: Boolean;
begin
     MoveToPrev := MoveToPrevJumpItem(Data);
end;

function TSendData.GetFirst( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean;
var Item: TJumpRec;
begin
     GetFirst := GetFirstJumpItem(Data, Item);
     AMode := Item.Mode;
     ADeltaX := Item.DeltaX;
     ADeltaY := Item.DeltaY;
end;

function TSendData.GetLast( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean;
var Item: TJumpRec;
begin
     GetLast := GetLastJumpItem(Data, Item);
     AMode := Item.Mode;
     ADeltaX := Item.DeltaX;
     ADeltaY := Item.DeltaY;
end;

function TSendData.GetNext( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean;
var Item: TJumpRec;
begin
     GetNext := GetNextJumpItem(Data, Item);
     AMode := Item.Mode;
     ADeltaX := Item.DeltaX;
     ADeltaY := Item.DeltaY;
end;

function TSendData.GetPrev( var AMode: Byte; var ADeltaX, ADeltaY: Integer): Boolean;
var Item: TJumpRec;
begin
     GetPrev := GetPrevJumpItem(Data, Item);
     AMode := Item.Mode;
     ADeltaX := Item.DeltaX;
     ADeltaY := Item.DeltaY;
end;

function TSendData.GetBookMark: PBookMark;
var BookMark: PBookMark;
    BookMarkInfo: TBookMarkInfo;
begin
     if GetBookMarkInfo(Data, BookMarkInfo)
     then begin
          BookMark := New(PBookMark, Create);
          BookMark^.Info := BookMarkInfo;
          GetBookMark := BookMark;
          end
     else GetBookMark := nil;
end;

function TSendData.GetCurrentIndex: Longint;
begin
     GetCurrentIndex := DataTypes.GetCurrentIndex(Data);
end;

function TSendData.GotoBookMark( ABookMark: PBookMark): Boolean;
begin
     if (ABookMark <> nil)
     then GotoBookMark := DataTypes.GotoBookmark(Data, ABookMark^.Info)
     else GotoBookMark := False;
end;

function TSendData.GetNumCommands: Longint;
begin
     GetNumCommands := Data.Size
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

function TMachine.GetErrorFalgs: Word;
var ErrorFlags: Word;
    Temp: Byte;
    TheKey: Char;
    Port1Value, Port2Value: Byte;
begin
     ErrorFlags := $00;

     if LimitsErrorOcred
     then ErrorFlags := ErrorFlags or efREACHLIMIT;

     if ExternalBreakOcured
     then ErrorFlags := ErrorFlags or efEXTERNALSTOP
     else if UserBreakOcured
     then ErrorFlags := ErrorFlags or efUSERBREAK
     else if KeyPressed
          then begin
               TheKey := ReadKey;
               if TheKey = #27
               then begin
                    UserBreakOcured := True;
                    ErrorFlags := (ErrorFlags or efUSERBREAK);
                    end
               { just for simlation ..., it must be an external signal readen from
                 I/O port ... }
               else if TheKey = ' '
               then begin
                    ExternalBreakOcured := True;
                    ErrorFlags := (ErrorFlags or efEXTERNALSTOP);
                    end;
               end;
     {Original test for error inputs ...}

     Port1Value := Port[prtTEST1];
     Port2Value := Port[prtTEST2];

     {  Must to make test for currect bit,
        that bit whitch recive an external stop command ....
     if (((Port1Value and ... ) <> 0) or ((Port2Value and ... ) <> 0))
     then ErrorFlags := (ErrorFlags or efEXTERNALSTOP);}

     {if (((Port1Value and $E0) <> 0) or ((Port2Value and $37) <> 0))
     then ErrorFlags := (ErrorFlags or efUNKNOWN);}

     {if (((Port1Value and $E0) <> 0) or ((Port1Value and $37) <> 0))
     then begin
          ErrorFlags := (ErrorFlags or Word((Port1Value and $E0) shr 5) shl 4);
          ErrorFlags := (ErrorFlags or Word((Port2Value and $3F) shl 3) shl 4);
          end;}
     { May be not complete }
     GetErrorFalgs := ErrorFlags;
end;

function TMachine.IsEngineWorks: Boolean;
begin
     IsEngineWorks := ((LastCntrolOut and $01) = 0);
end;

function TMachine.SwitchEngineOn: Boolean;
begin
     SwitchEngineOn := False;
     OutSwitchOnCommand;
     if WaitForNidleUp
     then begin
          if WaitForNidleDown
          then SwitchEngineOn := True
          else OutSwitchOffCommand;
          end
     else OutSwitchOffCommand;
end;

function TMachine.SwitchEngineOff: Boolean;
begin
     SwitchEngineOff := WaitForNidleUp;
     OutSwitchOffCommand;
     Delay(1000);
end;

function TMachine.IsSlowMode: Boolean;
begin
     IsSlowMode := ((LastCntrolOut and $02) <> 0);
end;

function TMachine.SwitchToNormalMode: Boolean;
begin
     OutNormalModeCommand;
     SwitchToNormalMode := True;
end;

function TMachine.SwitchToSlowMode(AWaitForSlow: Boolean): Boolean;
var I: Integer;
begin
     if not IsSlowMode
     then begin
          OutSlowModeCommand;
          if IsEngineWorks
          then begin
               I := JUMPSBEFORESLOWACTIVE;
               if AWaitForSlow
               then repeat
                    if not WaitForNidleUp
                    then begin
                         SwitchToSlowMode := False;
                         Exit;
                         end;
                    if not WaitForNidleDown
                    then begin
                         SwitchToSlowMode := False;
                         Exit;
                         end;
                    I := I - 1;
                    until (I = 0);
               end;
          end;

     SwitchToSlowMode := True;
end;

function TMachine.GetLimitsState: Byte;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}
     GetLimitsState := 0;
     {
     Original function body ...
     GetLimitsState := (Port[prtTEST1] and (lmtLOX or lmtHIX or lmtLOY or lmtHIY));
     }
end;

function TMachine.IsNidleUp: Boolean;
const NidleUp: Boolean = True;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}


     if IsEngineWorks
     then begin
          IsNidleUp := NidleUp;
          NidleUp := not NidleUp;

          {
          Original body ...
          IsNidleUp :=  ((Port[prtTEST1] and $01) <> 0)
          }

          if IsSlowMode
          then Delay(100)
          else Delay(1);
          end
     else IsNidleUp := True;
end;

function TMachine.WaitForNidleUp: Boolean;
var I: Longint;
begin
     I := MAXWAITTESTS;

     while ((not IsNidleUp) and (I > 0))
     do I := I - 1;

     if (I > 0)
     then WaitForNidleUp := True { Nidel is up ... Ok. }
     else WaitForNidleUp := False; { Time out state ... efor }
end;

function TMachine.WaitForNidleDown: Boolean;
var I: Longint;
begin
     I := MAXWAITTESTS;

     while (IsNidleUp and (I > 0))
     do I := I - 1;

     if (I > 0)
     then WaitForNidleDown := True { Nidel is down ... Ok. }
     else WaitForNidleDown := False; { Time out state ... efor }
end;

procedure TMachine.OutInitializeCommands;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Initialize ');
     Delay(2000);}

     Port[prtINIT1] := $92;
     Port[prtINIT2] := $30;
     Port[prtINIT2] := $70;

     LastCntrolOut := $03;
     Port[prtCONTR] := LastCntrolOut;
     OutMoveCommand(2,2);
end;

procedure TMachine.OutQuitCommands;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Quit       ');
     Delay(2000);}
end;

procedure TMachine.OutMoveCommand(AX, AY: Integer);
var X,Y: Word;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     { Don`t forget to test limits switch and set that an efor ocured
       if there is any limit reached }

     if (AX > 0)
     then begin
          X := AX;
          LastCntrolOut := LastCntrolOut or $04;
          end
     else begin
          X := - AX;
          LastCntrolOut := LastCntrolOut and ($0F xor $04);
          end;

     if (AY > 0)
     then begin
          Y := AY;
          LastCntrolOut := LastCntrolOut or $08;
          end
     else begin
          Y := - AY;
          LastCntrolOut := LastCntrolOut and ($0F xor $08);
          end;

     { You can test nidle up state here before send move command }

     Port[prtCONTR] := LastCntrolOut;
     if (X > 1)
     then begin
          X := X - 1;
          Port[prtXMOVE] := Lo(X);
          Port[prtXMOVE] := Hi(X);
          end;
     if (Y > 1)
     then begin
          Y := Y - 1;
          Port[prtYMOVE] := Lo(Y);
          Port[prtYMOVE] := Hi(Y);
          end;
end;

procedure TMachine.OutSlowModeCommand;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Slow       ');
     Delay(2000);}

     LastCntrolOut := LastCntrolOut or $02;
     Port[prtCONTR] := LastCntrolOut;
end;

procedure TMachine.OutNormalModeCommand;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Normal     ');
     Delay(2000);}

     LastCntrolOut := LastCntrolOut and ($0F xor $02);
     Port[prtCONTR] := LastCntrolOut;
end;

procedure TMachine.OutSwitchOffCommand;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Engine off ');
     Delay(2000);}

     LastCntrolOut := LastCntrolOut or $01;
     Port[prtCONTR] := LastCntrolOut;
end;

procedure TMachine.OutSwitchOnCommand;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     {OutputPort^.OutTextXY(0,0,'Engine on  ');
     Delay(2000);}

     LastCntrolOut := LastCntrolOut and ($0F xor $01);
     Port[prtCONTR] := LastCntrolOut;
end;


constructor TMachine.Create( AMessagePort: PViewPort);
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     inherited Create;
     OutInitializeCommands;

     LimitsErrorOcred := False;
     UserBreakOcured := False;
     ExternalBreakOcured := False;
     LastCntrolOut  := $00;
end;

destructor TMachine.Destroy;
begin
     {***********************************}
     {*                                 *}
     {*   Virtual body of the methode   *}
     {*                                 *}
     {***********************************}

     OutQuitCommands;
     inherited Destroy;
end;

function TMachine.Jump(AX, AY: Integer; ALongJump: Boolean): Boolean;
begin
     UserBreakOcured := False;
     ExternalBreakOcured := False;
     if ((GetErrorFalgs and efJUMPERRORMASK) = 0)
     then begin
          if not IsEngineWorks
          then if not SwitchEngineOn
               then begin
                    { Engine not switched on, there is an efor }
                    SwitchEngineOff;
                    Jump := False;
                    Exit;
                    end;

          if ALongJump
          then begin
               if not IsSlowMode
               then if not SwitchToSlowMode(False{True})
               { You can send slow command before some normal steps
                 to make the actevity of slow mode now}
                    then begin
                         SwitchEngineOff;
                         Jump := False;
                         Exit;
                         end;
               end
          else begin
               if IsSlowMode
               then if not SwitchToNormalMode
                    then begin
                         SwitchEngineOff;
                         Jump := False;
                         Exit;
                         end;
               end;

          if not WaitForNidleUp
          then begin
               SwitchEngineOff;
               Jump := False;
               Exit;
               end;

          OutMoveCommand(AX, AY);

          if not WaitForNidleDown
          then begin
               SwitchEngineOff;
               Jump := False;
               Exit;
               end;

          if (GetLimitsState = 0)
          then Jump := True
          else begin
               SwitchEngineOff;
               LimitsErrorOcred := True;
               Jump := False;
               end;
          end
     else begin
          SwitchEngineOff;
          Jump := False;
          end;
end;

function TMachine.Move(AX, AY: Integer): Boolean;
begin
     UserBreakOcured := False;
     ExternalBreakOcured := False;
     if ((GetErrorFalgs and efMOVEERRORMASK) = 0)
     then begin
          if IsEngineWorks
          then begin
               if not SwitchEngineOff
               then begin
                    SwitchEngineOff;
                    Move := False;
                    Exit;
                    end;
               end;
          OutMoveCommand(AX, AY);
          Move := (GetLimitsState = 0);
          end
     else begin
          SwitchEngineOff;
          Move := False;
          end;
end;

function TMachine.Stop: Boolean;
begin
     Stop := SwitchEngineOff;
end;

function TMachine.ResetPos: Boolean;
begin
     UserBreakOcured := False;
     ExternalBreakOcured := False;
     if ((GetErrorFalgs and efRESETPOSERRORMASK) = 0)
     then begin
          if IsEngineWorks
          then if not SwitchEngineOff
               then begin
                    ResetPos := False;
                    Exit;
                    end;

          Delay(1000);

          {
          Original body of function ...

          while (((GetLimitsState and lmtLOX) = 0) and ((GetErrorFalgs and efRESETPOSERRORMASK) = 0))
          do OutMoveCommand(-5, 0);

          while (((GetLimitsState and lmtLOX) <> 0) and ((GetErrorFalgs and efRESETPOSERRORMASK) = 0))
          do OutMoveCommand(10, 0);

          while (((GetLimitsState and lmtLOY) = 0) and ((GetErrorFalgs and efRESETPOSERRORMASK) = 0))
          do OutMoveCommand(0, -5);

          while (((GetLimitsState and lmtLOY) <> 0) and ((GetErrorFalgs and efRESETPOSERRORMASK) = 0))
          do OutMoveCommand(0, 10);
          }

          LimitsErrorOcred := False;

          ResetPos :=  ((GetErrorFalgs and efRESETPOSERRORMASK) = 0);
          end
     else begin
          SwitchEngineOff;
          ResetPos := False;
          end;
end;

function TMachine.WaitNidleUpDown(ACount: Longint): Boolean;
var I: Longint;
begin
     I := ACount;

     if I > 0
     then begin
          WaitNidleUpDown := False;
          if not IsEngineWorks
          then if not SwitchEngineOn
               then begin
                    { Engine not switched on, there is an efor }
                    SwitchEngineOff;
                    Exit;
                    end;
          repeat
                if not WaitForNidleUp
                then Exit;
                if not WaitForNidleDown
                then Exit;
                I := I - 1;
          until I = 0;
          end;
     WaitNidleUpDown := True;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

constructor TViewPort.Create(AX1, AY1, AX2, AY2, ABackColor, ATextColor: Integer);
begin
     inherited Create;
     X1 := AX1;
     Y1 := AY1;
     X2 := AX2;
     Y2 := AY2;
     BackColor := ABackColor;
     TextColor := ATextColor;
     Zoom := 1;
end;

destructor TViewPort.Destroy;
begin
     inherited Destroy;
end;

procedure TViewPort.SetZoom(AZoom: Integer);
begin
     if (AZoom > 0)
     then Zoom := AZoom;
end;

procedure TViewPort.Activate;
begin
     SetViewPort(X1, Y1, X2, Y2, False);
     SetColor(TextColor);
     ActiveViewPort := @Self;
end;

function TViewPort.GetWidth: Integer;
begin
     GetWidth := X2 - X1;
end;

function TViewPort.GetHeight: Integer;
begin
     GetHeight := Y2 - Y1;
end;

function TViewPort.GetOriginX: Integer;
begin
     GetOriginX := X1;
end;

function TViewPort.GetOriginY: Integer;
begin
     GetOriginY := Y1;
end;

procedure TViewPort.Clear;
begin
     Activate;
     SetFillPattern(Solid, BackColor);
     Graph.Bar(0, 0, X2 - X1, Y2 - Y1);
end;

procedure TViewPort.SetTextColor(AColor: Integer);
begin
     TextColor := AColor;
     if (ActiveViewPort = @Self)
     then Graph.SetColor( AColor)
     else Activate;
end;

function TViewPort.GetTextColor: Integer;
begin
     GetTextColor := TextColor;
end;

procedure TViewPort.OutTextXY(AX,AY: Integer; AS: string; ATransparent: Boolean);
begin
     if not (ActiveViewPort = @Self)
     then Activate;

     if not ATransparent
     then begin
          SetFillPattern(Solid, BackColor);
          Bar(AX, AY, TextWidth(AS) + AX, TextHeight(AS) + AY);
          end;
     Graph.OutTextXY(AX, AY, AS);
end;

procedure TViewPort.Line(AX1, AY1, AX2, AY2: Integer);
begin
     if not (ActiveViewPort = @Self)
     then Activate;

     Graph.Line(AX1 div Zoom, AY1 div Zoom, AX2 div Zoom, AY2 div Zoom);
     {Graph.PutPixel(AX1 div Zoom, AY1 div Zoom, 15 + 128);
     Graph.PutPixel(AX2 div Zoom, AY2 div Zoom, 15 + 128);}
end;

procedure TViewPort.DrawJump(AX1, AY1, AX2, AY2: Integer);
begin
     if not (ActiveViewPort = @Self)
     then Activate;

     Graph.Line(AX1 div Zoom, AY1 div Zoom, AX2 div Zoom, AY2 div Zoom);
     Graph.PutPixel(AX1 div Zoom, AY1 div Zoom, 15);
     Graph.PutPixel(AX2 div Zoom, AY2 div Zoom, 15);
end;

procedure TViewPort.Circle(AX, AY, ARadios: Integer);
begin
     if not (ActiveViewPort = @Self)
     then Activate;

     Graph.Circle(AX div Zoom, AY div Zoom, ARadios div Zoom);
end;

procedure TViewPort.Bar(AX1, AY1, AX2, AY2: Integer);
begin
     if not (ActiveViewPort = @Self)
     then Activate;

     Graph.Bar(AX1 div Zoom, AY1 div Zoom, AX2 div Zoom, AY2 div Zoom);
end;

procedure TViewPort.Rectangle(AX1, AY1, AX2, AY2: Integer);
begin
     Graph.Rectangle(AX1 div Zoom, AY1 div Zoom, AX2 div Zoom, AY2 div Zoom);
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}


constructor TCanvas.Create;
var Gd, Gm: Integer;
begin
     inherited Create;
     Gd := Detect;
     InitGraph(Gd, Gm,'D:\BORLAND\BGI');

     DrawnViewPort.Create(0, 0, GetMaxX - 20, GetMaxY - 45, 1, 7);
     SignalsViewPort.Create(GetMaxX - 19, 0, GetMaxX, GetMaxY - 45, 9,15);
     InfoViewPort.Create(0, GetMaxY - 44, GetMaxX, GetMaxY - 17, 9, 15);
     MessagesViewPort.Create(0, GetMaxY - 16, GetMaxX, GetMaxY, 7, 0);

     DrawnViewPort.SetZoom(1);
end;

destructor TCanvas.Destroy;
begin
     DrawnViewPort.Destroy;
     MessagesViewPort.Destroy;
     InfoViewPort.Destroy;

     CloseGraph;
     inherited Destroy;
end;

procedure TCanvas.DrawFrame;
begin
     DrawnViewPort.Clear;
     SignalsViewPort.Clear;
     InfoViewPort.Clear;
     MessagesViewPort.Clear;
end;

function TCanvas.GetOption(ATextColor, ABackColor: Integer; AOptions: string; ADefault: Integer): Integer;
begin
     DrawnViewPort.GetHeight;
     GetOption := GAPI.GetOption(10, DrawnViewPort.GetHeight - 10,4,ATextColor, ABackColor,AOptions, ADefault);
end;

procedure TCanvas.OutMessage(AMessage: string);
begin
     MessagesViewPort.Clear;
     MessagesViewPort.OutTextXY(5, 5, AMessage, False);
end;

function TCanvas.InputString(ATitle: string; var AStr: string; AMaxLength: Integer): Boolean;
begin
     MessagesViewPort.OutTextXY(5,5,ATitle, False);
     InputString :=
     GAPI.InputString(MessagesViewPort.GetOriginX + 6 + TextWidth(ATitle),MessagesViewPort.GetOriginY + 2,
                                                  AMaxLength, AStr, True);
     MessagesViewPort.Clear;
end;

function TCanvas.InputInteger(ATitle: string; var AValue: Longint; Min, Max: Longint): Boolean;
var S: string;
    Code: Integer;
    Value: Longint;
label Rep;
begin
     Str(AValue, S);
     MessagesViewPort.OutTextXY(5,5,ATitle, False);

     Rep :
     if GAPI.InputString( MessagesViewPort.GetOriginX + 6 + TextWidth(ATitle),
                          MessagesViewPort.GetOriginY + 2,
                          10, S, True)
     then begin
          Val(S, Value, Code);
          if ((Code = 0) and (Value >= Min) and (Value <= Max))
          then begin
               AValue := Value;
               InputInteger := True;
               end
          else goto Rep;
          end
     else InputInteger := False;
     MessagesViewPort.Clear;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TController.ProcessMachineError;
var ErrorFlags: Word;
    procedure DisplayErrorFlags;
    var I: Integer;
        Mask: Word;
        S: string;
    begin
         Mask := efRESERVED1;
         Canvas.SignalsViewPort.Clear;
         SetFillPattern(Solid, 12);
         for I := 1 to 8
         do begin
            if ((ErrorFlags and Mask ) = Mask)
            then Canvas.SignalsViewPort.Bar( 3, 3 + (I - 1) * 20, Canvas.SignalsViewPort.GetWidth - 4, 2 + I * 20 - 4);
            Mask := Mask shl 1;
            end;
         for I := 1 to 9
         do begin
            Str(I, S);
            Canvas.SignalsViewPort.Rectangle( 2, 2 + (I - 1) * 20, Canvas.SignalsViewPort.GetWidth - 3, 2 + I * 20 - 3);
            Canvas.SignalsViewPort.OutTextXY( 4, 4 + (I - 1) * 20, S, True);
            end;
    end;
begin
     ErrorFlags := Machine.GetErrorFalgs;
     if (ErrorFlags <> 0)
     then begin
          DisplayErrorFlags;
          if ((ErrorFlags and efEXTERNALSTOP) <> 0)
          then ErrorCode := errEXTERNALSTOP
          else if ((ErrorFlags and efRESERVEDMASK) <> 0)
          then ErrorCode := errUNKNOWN
          else if ((ErrorFlags and efSTRINGCUT) <> 0)
          then ErrorCode := errSTRINGCUT
          else if ((ErrorFlags and efREACHLIMIT) <> 0)
          then ErrorCode := errREACHLIMIT
          else if ((ErrorFlags and efUSERBREAK) <> 0)
          then ErrorCode := errUSERBREAK
          else ErrorCode := errUNKNOWN
          end
     else ErrorCode := errNONE;
end;

function TController.LoadDataFromFile( AFileName: string): Boolean;
var FileStream: PFileStream;
    Zoom1, Zoom2: Real;
    Zoom: Longint;
begin
     Data.Clear;
     if FileExists(AFilename)
     then begin
          Canvas.OutMessage('Loadind ...');
          FileStream := New(PFileStream, Create(AFilename));
          FileStream^.Seek(0);
          if Data.LoadDataFromStream( FileStream)
          then begin
               Data.ProcessDistanceJumps(FASTJUMPLIMIT);
               Zoom1 := Data.Width / Canvas.DrawnViewPort.GetWidth;
               Zoom2 := Data.Height / Canvas.DrawnViewPort.GetHeight;
               if Zoom1 < Zoom2
               then Zoom1 := Zoom2;
               if (Trunc(Zoom1) < Zoom1)
               then Zoom := Trunc(Zoom1) + 1
               else Zoom := Trunc(Zoom1);
               Canvas.DrawnViewPort.SetZoom(Zoom);
               Canvas.OutMessage('Ok.');
               OkBeep;
               LoadDataFromFile := True;
               end
          else begin
               Canvas.DrawnViewPort.SetZoom(1);
               Canvas.OutMessage('Bad control data file.');
               ErrorBeep;
               LoadDataFromFile := False;
               end;
          FileStream^.Free;
          UpdateInfoView;
          end
     else begin
          Canvas.OutMessage('Bad file name or file not exists.');
          ErrorBeep;
          LoadDataFromFile := False;
          end;
end;

function TController.InitSendData: Boolean;
begin
     Canvas.OutMessage('Initializing to send data to mochine ...');
     InitSendData := False;
     if Data.MoveToFirst
     then begin
          Canvas.OutMessage('Reseting nidle pos ...');
          if Machine.ResetPos
          then begin
               Canvas.OutMessage('Move nidle pos to drawn (0,0) pos ...');
               if Machine.Move( Data.OffsetX, Data.OffsetY)
               then begin
                    if ViewSendData
                    then begin
                         Canvas.DrawnViewPort.DrawJump(0, 0, Data.OffsetX, Data.OffsetY);
                         CurrentX := Data.OffsetX;
                         CurrentY := Data.OffsetY;
                         end;
                    InitSendData := Machine.WaitNidleUpDown(STARTUPDOWNCOUNT);
                    end
               end;
          end;

end;

function TController.SendData: Boolean;
var DeltaX, DeltaY: Integer;
    Mode: Byte;
begin
     Canvas.OutMessage('Sending data to machine ...');
     if Data.GetCurrent(Mode, DeltaX, DeltaY)
     then repeat
          case Mode
          of modNormal: if not Machine.Jump(DeltaX, DeltaY, False)
                        then begin
                             ProcessMachineError;
                             SendData := False;
                             Exit;
                             end
                        else if ViewSendData
                             then begin
                                  Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                                  CurrentX := CurrentX + DeltaX;
                                  CurrentY := CurrentY + DeltaY;
                                  end;
             modSlow: if not Machine.Jump(DeltaX, DeltaY, True)
                      then begin
                           ProcessMachineError;
                           SendData := False;
                           Exit;
                           end
                      else if ViewSendData
                           then begin
                                Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                                CurrentX := CurrentX + DeltaX;
                                CurrentY := CurrentY + DeltaY;
                                end;
             modStop: begin
                      SendData := False;
                      if not Machine.Stop
                      then ProcessMachineError
                      else if ViewSendData
                           then begin
                                end;
                      Data.GetNext(Mode, DeltaX, DeltaY);
                      SendData := False;
                      Exit;
                      end;
             modReset: {if not Machine.ResetPos
                       then begin
                            SendData := False;
                            ProcessMachineError;
                            Exit;
                            end;}
             else

             end;
          until not Data.GetNext(Mode, DeltaX, DeltaY);
     Machine.SwitchEngineOff;
     SendData := True;
end;

function TController.MoveBack(ACount: Longint): Boolean;
var DeltaX, DeltaY,
    JumpDistanceX, JumpDistanceY: Integer;
    Mode: Byte;
    I: Longint;
begin
     if ACount < 1
     then Exit;
     JumpDistanceX := 0;
     JumpDistanceY := 0;
     I := ACount;
     while I > 0
     do if Data.GetPrev(Mode, DeltaX, DeltaY)
        then begin
             if ((Mode = modSlow) or (Mode = modNormal))
             then begin
                  JumpDistanceX := JumpDistanceX - DeltaX;
                  JumpDistanceY := JumpDistanceY - DeltaY;
                  end;
             I := I - 1;
             end
        else begin
             Data.MoveToFirst;
             Break;
             end;
     if Machine.Move(JumpDistanceX, JumpDistanceY)
     then begin
          Canvas.DrawnViewPort.SetTextColor(14);
          Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + JumpDistanceX, CurrentY + JumpDistanceY);
          CurrentX := CurrentX + JumpDistanceX;
          CurrentY := CurrentY + JumpDistanceY;
          MoveBack := True;
          end
     else MoveBack := False;
end;

function TController.MoveForward(ACount: Longint): Boolean;
var DeltaX, DeltaY,
    JumpDistanceX, JumpDistanceY: Integer;
    Mode: Byte;
    I: Longint;
begin
     if ACount < 1
     then Exit;
     if not Data.GetCurrent(Mode, DeltaX, DeltaY)
     then Exit;
     JumpDistanceX := DeltaX;
     JumpDistanceY := DeltaY;
     I := ACount - 1;
     while I > 0
     do if Data.GetNext(Mode, DeltaX, DeltaY)
        then begin
             if ((Mode = modSlow) or (Mode = modNormal))
             then begin
                  JumpDistanceX := JumpDistanceX + DeltaX;
                  JumpDistanceY := JumpDistanceY + DeltaY;
                  end;
             I := I - 1;
             end
        else Break;
     Data.GetNext(Mode, DeltaX, DeltaY);
     if Machine.Move(JumpDistanceX, JumpDistanceY)
     then begin
          Canvas.DrawnViewPort.SetTextColor(14);
          Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + JumpDistanceX, CurrentY + JumpDistanceY);
          CurrentX := CurrentX + JumpDistanceX;
          CurrentY := CurrentY + JumpDistanceY;
          MoveForward := True;
          end
     else MoveForward := False;
end;


procedure TController.DisplayDrawn;
var DeltaX, DeltaY: Integer;
    Mode: Byte;
begin
     Canvas.OutMessage('Drawing data ...');
     Canvas.DrawnViewPort.Clear;
     Canvas.DrawnViewPort.SetTextColor(0);
     Canvas.DrawnViewPort.DrawJump(0, 0, Data.OffsetX, Data.OffsetY);
     CurrentX := Data.OffsetX;
     CurrentY := Data.OffsetY;
     Data.MoveToFirst;
     Canvas.DrawnViewPort.SetTextColor(7);
     if Data.GetCurrent(Mode, DeltaX, DeltaY)
     then repeat
          case Mode
          of modNormal: begin
                        Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                        CurrentX := CurrentX + DeltaX;
                        CurrentY := CurrentY + DeltaY;
                        end;
             modSlow: begin
                      Canvas.DrawnViewPort.SetTextColor(12);
                      Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                      CurrentX := CurrentX + DeltaX;
                      CurrentY := CurrentY + DeltaY;
                      Canvas.DrawnViewPort.SetTextColor(7);
                      end;
             modStop: begin
                      Canvas.DrawnViewPort.SetTextColor(14);
                      Canvas.DrawnViewPort.Circle(CurrentX, CurrentY, 5 * Canvas.DrawnViewPort.Zoom);
                      Canvas.DrawnViewPort.SetTextColor(7);
                      end;
             modReset: begin
                       end;
             else

             end;
          until not Data.GetNext(Mode, DeltaX, DeltaY);
     Canvas.DrawnViewPort.SetTextColor(7);
     Canvas.OutMessage('Ok.');
     OkBeep;
end;

procedure TController.DisplayUntilCurrentPos;
var DeltaX, DeltaY: Integer;
    Mode: Byte;
    BookMark: PBookMark;
    Count: Longint;
begin
     Canvas.OutMessage('Drawing data ...');
     Canvas.DrawnViewPort.Clear;

     BookMark := Data.GetBookMark;
     Count := Data.GetCurrentIndex;

     if (Count > 1)
     then begin
          Canvas.DrawnViewPort.SetTextColor(0);
          Canvas.DrawnViewPort.DrawJump(0, 0, Data.OffsetX, Data.OffsetY);
          CurrentX := Data.OffsetX;
          CurrentY := Data.OffsetY;
          Data.MoveToFirst;
          Canvas.DrawnViewPort.SetTextColor(7);
          if Data.GetCurrent(Mode, DeltaX, DeltaY)
          then repeat
               case Mode
               of modNormal: begin

                             Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                             CurrentX := CurrentX + DeltaX;
                             CurrentY := CurrentY + DeltaY;
                             end;
                  modSlow: begin
                           Canvas.DrawnViewPort.SetTextColor(12);
                           Canvas.DrawnViewPort.DrawJump(CurrentX, CurrentY, CurrentX + DeltaX, CurrentY + DeltaY);
                           CurrentX := CurrentX + DeltaX;
                           CurrentY := CurrentY + DeltaY;
                           Canvas.DrawnViewPort.SetTextColor(7);
                           end;
                  modStop: begin
                           Canvas.DrawnViewPort.SetTextColor(14);
                           Canvas.DrawnViewPort.Circle(CurrentX, CurrentY, 5 * Canvas.DrawnViewPort.Zoom);
                           Canvas.DrawnViewPort.SetTextColor(7);
                           Canvas.DrawnViewPort.SetTextColor(7);
                           end;
                  modReset: begin
                            end;
                  else
                  end;
               Count := Count - 1;
               until ((not Data.GetNext(Mode, DeltaX, DeltaY)) or (Count <= 1));
          end;

     Data.GotoBookMark( BookMark);
     Canvas.DrawnViewPort.SetTextColor(7);
     Canvas.OutMessage('Ok.');
     OkBeep;
end;

constructor TController.Create;
begin
     inherited Create;
     Canvas.Create;
     Data.Create;
     Machine.Create( @Canvas.MessagesViewPort);
     ViewSendData := True;
end;

destructor TController.Destroy;
begin
     Machine.Destroy;
     Data.Destroy;
     Canvas.Destroy;
     inherited Destroy;
end;

procedure TController.Run;
var State: PState;
    NewState: PState;
begin
     Canvas.DrawFrame;

     UpdateInfoView;
     NewState := New(PMainMenuState, Create(@Self));
     repeat
           State := NewState;
           State^.Enter;
           State^.RunState;
           State^.Leave;
           NewState := State^.GetNextState;
           State^.Free;
     until (NewState = nil);
end;

function TController.GetErrorCode;
begin
     GetErrorCode := ErrorCode;
end;

function TController.ShiftNidle(AOffsetX, AOffsetY: Integer): Boolean;
begin
     ShiftNidle := Machine.Move( AOffsetX, AOffsetY);
end;

procedure TController.UpdateInfoView;
var S: string;
    L: Longint;
begin
     Str(MemAvail, S);
     S := 'Free memory    : ' + S + '';
     while Length(S) < 27
     do S := S + ' ';
     Canvas.InfoViewPort.OutTextXY(5,15,S, False);

     Str(Data.GetNumCommands, S);
     S:= 'Commands count : ' + S;
     while Length(S) < 27
     do S := S + ' ';
     Canvas.InfoViewPort.OutTextXY(5,5,S, False);

     L := Data.Width;
     Str(L, S);
     S:= 'Width  : ' + S;
     while Length(S) < 27
     do S := S + ' ';
     Canvas.InfoViewPort.OutTextXY(305,5,S, False);

     L := Data.Height;
     Str(L, S);
     S:= 'Height : ' + S;
     while Length(S) < 27
     do S := S + ' ';
     Canvas.InfoViewPort.OutTextXY(305,15,S, False);

end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TState.RunState;
begin
end;

function TState.GetNextState: PState;
begin
     GetNextState := nil;
end;

function TState.Enter: Boolean;
begin
     Enter := True;
end;

function TState.Leave: Boolean;
begin
     Leave := True;
end;


{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

constructor TControllerState.Create( AController: PController);
begin
     inherited Create;
     Controller := AController;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const MainMenuDefault: Integer = 1;

procedure TMainMenuState.RunState;
label Rep;
begin
     Option := 0;
Rep:
     MainMenuDefault := Controller^.Canvas.GetOption( 14, 8,'Load data file'#0'Display data'#0'Send data to machine'#0'Exit'#0,
                                                      MainMenuDefault);
     case MainMenuDefault
     of 1  : Option := 1;
        2  : Option := 2;
        3  : Option := 3;
        4  : Option := 0;
     else
         goto Rep;
     end;
end;

function TMainMenuState.GetNextState: PState;
begin
     case Option
     of 1: GetNextState := New(PLoadDataState, Create(Controller));
        2: GetNextState := New(PViewDataState, Create(Controller));
        3: GetNextState := New(PSendDataState, Create(Controller));
     else
         GetNextState := nil;
     end;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const LoadedFileName: string = 'NONAME.ZCD';

procedure TLoadDataState.RunState;
begin
     if Controller^.Canvas.InputString('Enter file name :', LoadedFileName, 50)
     then if LoadedFileName <> ''
          then Controller^.LoadDataFromFile(LoadedFileName);
end;

function TLoadDataState.GetNextState: PState;
begin
     GetNextState := New(PMainMenuState, Create( Controller));
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TViewDataState.RunState;
begin
     Controller^.DisplayDrawn;
end;

function TViewDataState.GetNextState: PState;
begin
     GetNextState := New(PMainMenuState, Create( Controller))
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TSendDataState.RunState;
begin
     Controller^.Canvas.DrawnViewPort.Clear;
     Controller^.Canvas.DrawnViewPort.SetTextColor(7);
     UserBreakAtInitialize := False;
     Delay(3000);
     if Controller^.InitSendData
     then SendResult := Controller^.SendData
     else begin
          SendResult := False;
          UserBreakAtInitialize := True;
          end;

     Controller^.ProcessMachineError;
     case Controller^.GetErrorCode
     of errNONE: begin
                 if SendResult
                 then Controller^.Canvas.OutMessage('Ok.')
                 else Controller^.Canvas.OutMessage('Stop command.');
                 OkBeep;
                 end;
        errSTRINGCUT: begin
                      Controller^.Canvas.OutMessage('String cut error.');
                      ErrorBeep;
                      end;
        errREACHLIMIT: begin
                       Controller^.Canvas.OutMessage('Limits error.');
                       ErrorBeep;
                       end;
        errUSERBREAK: begin
                      Controller^.Canvas.OutMessage('User break');
                      ErrorBeep;
                      end;
        errEXTERNALSTOP: begin
                         Controller^.Canvas.OutMessage('User external break');
                         ErrorBeep;
                         end;
        errCOMMANDBREAK: begin
                         Controller^.Canvas.OutMessage('User break');
                         OkBeep;
                         end;
        errUNKNOWN: begin
                    Controller^.Canvas.OutMessage('Unknown error.');
                    ErrorBeep;
                    end;
        end;
end;

function TSendDataState.Enter: Boolean;
var Gd, Gm: Integer;
begin
     Enter := True;
end;

function TSendDataState.Leave: Boolean;
begin
     Leave := True;
end;

function TSendDataState.GetNextState: PState;
begin
     {Controller^.ProcessMachineError;}
     case Controller^.GetErrorCode
     of errNONE: begin
                 if SendResult
                 then GetNextState := New(PMainMenuState, Create( Controller))
                 else GetNextState := New(PBreakState, Create( Controller));
                 end;
        errSTRINGCUT: begin
                      GetNextState := New(PBreakState, Create( Controller));
                      end;
        errREACHLIMIT: begin
                       GetNextState := New(PMainMenuState, Create( Controller))
                       end;
        errUSERBREAK: begin
                      if UserBreakAtInitialize
                      then GetNextState := New(PMainMenuState, Create( Controller))
                      else GetNextState := New(PBreakState, Create( Controller));
                      end;
        errEXTERNALSTOP: begin
                         if UserBreakAtInitialize
                         then GetNextState := New(PMainMenuState, Create( Controller))
                         else GetNextState := New(PExternalManipulationState, Create( Controller));
                         end;
        errCOMMANDBREAK: begin
                         GetNextState := New(PBreakState, Create( Controller));
                         end;
        errUNKNOWN: begin
                    GetNextState := New(PMainMenuState, Create( Controller))
                    end;
        else
            Halt(1);
        end;

end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TResumeSendDataState.RunState;
begin
     Controller^.Canvas.DrawnViewPort.Activate;
     Controller^.Canvas.DrawnViewPort.SetTextColor(7);
     SendResult := Controller^.SendData;
     Controller^.ProcessMachineError;
     case Controller^.GetErrorCode
     of errNONE: begin
                 if SendResult
                 then Controller^.Canvas.OutMessage('Ok.')
                 else Controller^.Canvas.OutMessage('Stop command.');
                 OkBeep;
                 end;
        errSTRINGCUT: begin
                      Controller^.Canvas.OutMessage('String cut error.');
                      ErrorBeep;
                      end;
        errREACHLIMIT: begin
                       Controller^.Canvas.OutMessage('Limits error.');
                       ErrorBeep;
                       end;
        errUSERBREAK: begin
                      Controller^.Canvas.OutMessage('User break');
                      ErrorBeep;
                      end;
        errEXTERNALSTOP: begin
                         Controller^.Canvas.OutMessage('User external break');
                         ErrorBeep;
                         end;
        errCOMMANDBREAK: begin
                         Controller^.Canvas.OutMessage('Command break');
                         OkBeep;
                         end;
        errUNKNOWN: begin
                    Controller^.Canvas.OutMessage('Unknown error.');
                    ErrorBeep;
                    end;
        end;

end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const BreakState: Integer = 1;

procedure TBreakState.RunState;
label Rep;
var Key: Char;
begin
     Controller^.DisplayUntilCurrentPos;
Rep:
     BreakState := Controller^.Canvas.GetOption(14,3,'Manipulate pos'#0'Resume data sending'#0'Stop sending'#0, BreakState);
     case BreakState
     of 1 : UserCommand := 3;
        2 : UserCommand := 1;
        3,0 : begin
              WarningBeep;
              if Controller^.Canvas.GetOption(14,12,'No, don`t stop sending'#0'Yes, stop sending'#0, 1) = 2
              then UserCommand := 2
              else goto Rep;
              end;
     else
         goto Rep;
     end;
end;

function TBreakState.GetNextState: PState;
var Gd, Gm: Integer;
begin
     case UserCommand
     of 1: GetNextState := New(PResumeSendDataState, Create( Controller));
        2: GetNextState := New(PMainMenuState, Create( Controller));
        3: GetNextState := New(PJumpsManipulationState, Create( Controller));
     else
         GetNextState := nil;
     end;
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

const ManipulationCommand: Integer = 1;

procedure TJumpsManipulationState.RunState;
label Rep;
var Jumps: Longint;
begin
     ErrorOcured := False;
     Jumps := 10;
     Rep:
     {ManipulationCommand := Controller^.Canvas.GetOption(14,3,
       'Move forward (1)'#0'Move backword (1)'#0'Move forward (N)'#0'Move backword (N)'#0'Return'#0,
       ManipulationCommand);}
     ManipulationCommand := Controller^.Canvas.GetOption(14,3,
       'Move forward (1)'#0'Move backword (1)'#0'Move forward (N)'#0'Move backword (N)'#0
       +'Shift up'#0'Shift down'#0'Shift left'#0'Shift right'#0'Return'#0,
       ManipulationCommand);
     case ManipulationCommand
     of 1: begin
           if Controller^.MoveForward(1)
           then goto Rep
           else ErrorOcured := True;
           end;
        2: begin
           if Controller^.MoveBack(1)
           then goto Rep
           else ErrorOcured := True;
           end;
        3: begin
           if Controller^.Canvas.InputInteger('Enter jumps count :',Jumps ,1, 1000)
           then begin
                if Controller^.MoveForward(Jumps)
                then goto Rep
                else ErrorOcured := True;
                end
           else goto Rep;
           end;
        4: begin
           if Controller^.Canvas.InputInteger('Enter jumps count :',Jumps ,1, 1000)
           then begin
                if Controller^.MoveBack(Jumps)
                then goto Rep
                else ErrorOcured := True;
                end
           else goto Rep;
           end;
        5: begin
           { Move up ... }
           Controller^.ShiftNidle(0,-10);
           goto Rep;
           end;
        6: begin
           { Move down ... }
           Controller^.ShiftNidle(0,+10);
           goto Rep;
           end;
        7: begin
           { Move left ... }
           Controller^.ShiftNidle(-10,0);
           goto Rep;
           end;
        8: begin
           { Move right ... }
           Controller^.ShiftNidle(+10,0);
           goto Rep;
           end;
     else
         end;
end;

function TJumpsManipulationState.GetNextState: PState;
begin
     if ErrorOcured
     then GetNextState := New(PMainMenuState, Create(Controller))
     else GetNextState := New(PBreakState, Create(Controller));
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}

procedure TExternalManipulationState.RunState;
label Rep;
var TheKey: Char;
begin
     ErrorOcured := False;
Rep:
     { Just for simulation ..., the command must be recived from I/O port
       not from key board ...
       from a bit of Port[prtTEST1] or Port[prtTEST2] }
     case TheKey
     of ' ': begin
             if Controller^.MoveBack(1)
             then goto Rep
             else ErrorOcured := True;
             end;
        #13: begin
             end
        else
            goto Rep;
        end;
end;

function TExternalManipulationState.GetNextState: PState;
begin
     if ErrorOcured
     then GetNextState := New(PMainMenuState, Create( Controller))
     else GetNextState := New(PResumeSendDataState, Create( Controller));
end;

{*************************************************************}
{*                                                           *}
{*                                                           *}
{*************************************************************}


var Controller: TController;
begin
     Controller.Create;
     Controller.Run;
     Controller.Destroy;
end.
