unit Machine;

interface

uses DataTypes, Crt, Generics, Streams, Graph;

type
     TMachineState = (msOk, msError, msUserStop, msDataEnd);

     PMachine = ^TMachine;
     TMachine = object(TGeneric)
     private
        State: TMachineState;
        SendData: TSendData;
        Zoom: Integer;
        CurrentX,
        CurrentY: Integer;
        procedure ResetPos;
        procedure Slow;
        procedure Stop;
        procedure Fast;
        procedure Move(ADeltaX, ADeltaY: Integer);
        procedure MoveBack(ADeltaX, ADeltaY: Integer);
        function StartMove: TMachineState;
        function MoveStep: TMachineState;
        function GetMachineState: TMachineState;
     public
        constructor Create;
        destructor Destroy; virtual;
        procedure LoadDataFromStream(AStream: PStream);
        procedure Run; virtual;
        end;

implementation

constructor TMachine.Create;
begin
     inherited Create;
     SendData.Create;
     CurrentX := 0;
     CurrentY := 0;
     State := msOk;
end;

destructor TMachine.Destroy;
begin
     SendData.Destroy;
     inherited Destroy;
end;

procedure TMachine.LoadDataFromStream(AStream: PStream);
begin
     SendData.Clear;
     SendData.LoadDataFromStream(AStream);
     SendData.ProcessDistanceJumps(50);
     {
     CurrentX := 0;
     CurrentY := 0;
     }
     CurrentX := - SendData.MinX;
     CurrentY := - SendData.MinY;
end;

procedure TMachine.ResetPos;
begin
     CurrentX := - SendData.MinX;
     CurrentY := - SendData.MinY;
end;

procedure TMachine.Slow;
begin
end;

procedure TMachine.Stop;
begin
end;

procedure TMachine.Fast;
begin
end;

procedure TMachine.Move(ADeltaX, ADeltaY: Integer);
var NewX, NewY: Longint;
begin
     NewX := CurrentX + ADeltaX;
     NewY := CurrentY + ADeltaY;
     Line(CurrentX, CurrentY, NewX, NewY);
     CurrentX := NewX;
     CurrentY := NewY;
end;

procedure TMachine.MoveBack(ADeltaX, ADeltaY: Integer);
var NewX, NewY: Longint;
begin
     NewX := CurrentX - ADeltaX;
     NewY := CurrentY - ADeltaY;
     Line(CurrentX, CurrentY, NewX, NewY);
     CurrentX := NewX;
     CurrentY := NewY;
end;

function TMachine.GetMachineState: TMachineState;
begin
     State := msOk;
     GetMachineState := State;
end;

function TMachine.StartMove: TMachineState;
var DeltaX, DeltaY: Integer;
    Mode: Byte;
begin
     if (GetMachineState = msOk)
     then begin
          if (SendData.GetFirst(Mode, DeltaX, DeltaY) and (Mode = modReset))
          then ResetPos
          else State := msDataEnd;
          end;
     StartMove := State;
end;

function TMachine.MoveStep: TMachineState;
var DeltaX, DeltaY: Integer;
    Mode: Byte;
begin
     if (GetMachineState = msOk)
     then begin
          if SendData.GetNext(Mode, DeltaX, DeltaY)
          then begin
               case Mode
               of modNormal: begin
                             Fast;
                             Move(DeltaX, DeltaY);
                             end;
                  modSlow: begin
                           Slow;
                           Move(DeltaX, DeltaY);
                           end;
                  modStop: begin
                           Stop;
                           end;
                  end;
               State := msOk;
               end
          else State := msDataEnd;
          end;
     MoveStep := State;
end;


procedure TMachine.Run;
{var DeltaX, DeltaY: Integer;
    TotalDeltaX, TotalDeltaY: Integer;
    Mode: Byte;
    I: Integer;}
begin
     if StartMove = msOk
     then while MoveStep = msOk do;
     {if (SendData.GetFirst(Mode, DeltaX, DeltaY) and (Mode = modReset))
     then begin
          SetColor(7);
          while SendData.GetNext(Mode, DeltaX, DeltaY)
          do begin
             case Mode
             of modNormal: begin
                           Fast;
                           Move(DeltaX, DeltaY);
                           end;
                modSlow: begin
                         Slow;
                         Move(DeltaX, DeltaY);
                         end;
                modStop: begin
                         Stop;
                         end;
                end;

             if KeyPressed
             then begin
                  while KeyPressed
                  do ReadKey;
                  SetColor(5);
                  SendData.GetCurrent( Mode, DeltaX, DeltaY);
                  TotalDeltaX := 0;
                  TotalDeltaY := 0;
                  I := 200;
                  repeat
                        I := I - 1;
                        TotalDeltaX := TotalDeltaX + DeltaX;
                        TotalDeltaY := TotalDeltaY + DeltaY;
                        SendData.GetPrev( Mode, DeltaX, DeltaY);
                  until ((SendData.IsFirst) or (I = 0));
                  MoveBack(TotalDeltaX, TotalDeltaY);
                  SetColor(7);
                  end;

             if SendData.IsFirst
             then begin
                  Sound(2000);
                  Delay(100);
                  NoSound;
                  end;

             if SendData.IsLast
             then begin
                  Sound(3000);
                  Delay(100);
                  NoSound;
                  end;
             end;
          end;}
end;

end.
