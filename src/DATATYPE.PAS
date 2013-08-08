unit DataTypes;

interface

uses Generics, Streams;

const modNormal       = 1;
      modSlow         = 2;
      modStop         = 3;
      modReset        = 4;

      MaxTableSize    = 10000;

type
     TFileID = string[20];

     PJumpRec = ^TJumpRec;
     TJumpRec = record
        Mode: Byte;
        DeltaX: Integer;
        DeltaY: Integer;
        end;

     PJumpTable = ^TJumpTable;
     TJumpTable = record
        Prev: PJumpTable;
        Next: PJumpTable;
        Size: Word;
        Used: Word;
        Items: array[1..1] of TJumpRec;
        end;

     PJumpTableCollection = ^TJumpTableCollection;
     TJumpTableCollection = record
        First: PJumpTable;
        Last: PJumpTable;
        Size: Longint;

        CurrentTable: PJumpTable;
        CurrentItem: Word;
        CurrentIndex: Longint;
        end;

     PBookmarkInfo = ^TBookmarkInfo;
     TBookmarkInfo = record
        JumpTableCollection: PJumpTableCollection;
        Table: PJumpTable;
        Item: Word;
        ItemIndex: Longint;
        end;

const
      ControlFileID : TFileID = 'ZIGCONTV1.02';


function AllocateJumpTable(ASize: Word): PJumpTable;
procedure FreeJumpTable(ATable: PJumpTable);
function AppendItemToTable(ATable: PJumpTable; var AItem: TJumpRec): Boolean;
procedure InitJumpTableCollection( var ACollection: TJumpTableCollection);
function AppendTableToCollection( var ACollection: TJumpTableCollection; ATable: PJumpTable): Boolean;
procedure FreeJmpTableCollection( var ACollection: TJumpTableCollection);
function GetFirstJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function MoveToFirstJumpItem( var ACollection: TJumpTableCollection): Boolean;
function GetLastJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function MoveToLastJumpItem( var ACollection: TJumpTableCollection): Boolean;
function GetNextJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function GetPrevJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function MoveToNextJumpItem( var ACollection: TJumpTableCollection): Boolean;
function MoveToPrevJumpItem( var ACollection: TJumpTableCollection): Boolean;
function GetCurrentJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function SetCurrentJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
function IsFirstJumpItem( var ACollection: TJumpTableCollection): Boolean;
function IsLastJumpItem( var ACollection: TJumpTableCollection): Boolean;
function GetBookmarkInfo( var ACollection: TJumpTableCollection; var ABookmarkInfo: TBookmarkInfo): Boolean;
function GotoBookmark( var ACollection: TJumpTableCollection; var ABookmarkInfo: TBookmarkInfo): Boolean;
function GetCurrentIndex(var ACollection: TJumpTableCollection): Longint;

implementation

function AllocateJumpTable(ASize: Word): PJumpTable;
var JumpTable: PJumpTable;
begin
     if (ASize > 0)
     then begin
          GetMem( JumpTable, SizeOf(TJumpTable)
                             + SizeOf(TJumpRec) * (ASize - 1));
          JumpTable^.Prev := nil;
          JumpTable^.Next := nil;
          JumpTable^.Size := ASize;
          JumpTable^.Used := 0;
          AllocateJumpTable := JumpTable;
          end
     else AllocateJumpTable := nil;
end;

procedure FreeJumpTable(ATable: PJumpTable);
begin
     if (ATable <> nil)
     then begin
          FreeMem(ATable, SizeOf(TJumpTable)
                          + SizeOf(TJumpRec) * (ATable^.Size - 1));
          end;
end;

function AppendItemToTable(ATable: PJumpTable; var AItem: TJumpRec): Boolean;
begin
     if (ATable <> nil)
     then begin
          if (ATable^.Used < ATable^.Size)
          then begin
               ATable^.Used := ATable^.Used + 1;
               ATable^.Items[ATable^.Used] := AItem;
               AppendItemToTable := True;
               end
          else AppendItemToTable := False;
          end
     else AppendItemToTable := True;
end;

procedure InitJumpTableCollection( var ACollection: TJumpTableCollection);
begin
     ACollection.First := nil;
     ACollection.Last := nil;
     ACollection.Size := 0;
     ACollection.CurrentTable := nil;
     ACollection.CurrentItem := 0;
     ACollection.CurrentIndex := 0;
end;

procedure FreeJmpTableCollection( var ACollection: TJumpTableCollection);
var TempTable: PJumpTable;
begin
     while (ACollection.First <> nil)
     do begin
        ACollection.Last := ACollection.First;
        ACollection.First := ACollection.First^.Next;
        FreeJumpTable(ACollection.Last);
        end;
     ACollection.First := nil;
     ACollection.Last := nil;
     ACollection.Size := 0;
     ACollection.CurrentTable := nil;
     ACollection.CurrentItem := 0;
     ACollection.CurrentIndex := 0;
end;

function AppendTableToCollection( var ACollection: TJumpTableCollection; ATable: PJumpTable): Boolean;
begin
     if (ATable <> nil)
     then begin
          ACollection.CurrentTable := nil;
          ACollection.CurrentItem := 0;
          ACollection.CurrentIndex := 0;
          if ((ACollection.Last = nil) or (ACollection.First = nil))
          then begin
               ATable^.Prev := nil;
               ATable^.Next := nil;
               ACollection.Last := ATable;
               ACollection.First := ATable;
               ACollection.Size := ATable^.Used;
               end
          else begin
               ATable^.Prev := ACollection.Last;
               ATable^.Next := nil;
               ACollection.Last^.Next := ATable;
               ACollection.Last := ATable;
               ACollection.Size := ACollection.Size + ATable^.Used;
               end;
          AppendTableToCollection := True;
          end
     else AppendTableToCollection := False;
end;

function IsFirstJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     IsFirstJumpItem := (ACollection.CurrentIndex = 1) or (ACollection.CurrentIndex = 0);
end;

function IsLastJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     IsLastJumpItem := (ACollection.CurrentIndex = ACollection.Size) or (ACollection.CurrentIndex = 0);
end;

function GetBookmarkInfo( var ACollection: TJumpTableCollection; var ABookmarkInfo: TBookmarkInfo): Boolean;
begin
     if ACollection.CurrentTable <> nil
     then begin
          ABookmarkInfo.JumpTableCollection := @ACollection;
          ABookmarkInfo.Table := ACollection.CurrentTable;
          ABookmarkInfo.Item := ACollection.CurrentItem;
          ABookmarkInfo.ItemIndex := ACollection.CurrentIndex;
          GetBookmarkInfo := True;
          end
     else begin
          ABookmarkInfo.JumpTableCollection := nil;
          ABookmarkInfo.Table := nil;
          ABookmarkInfo.Item := 0;
          ABookmarkInfo.ItemIndex := 0;
          GetBookmarkInfo := False;
          end;
end;

function GetCurrentIndex(var ACollection: TJumpTableCollection): Longint;
begin
     if ACollection.CurrentTable <> nil
     then GetCurrentIndex := ACollection.CurrentIndex
     else GetCurrentIndex := 0;
end;

function GotoBookmark( var ACollection: TJumpTableCollection; var ABookmarkInfo: TBookmarkInfo): Boolean;
begin
     if (ABookmarkInfo.JumpTableCollection = @ACollection)
     then begin
          ACollection.CurrentTable := ABookmarkInfo.Table;
          ACollection.CurrentItem := ABookmarkInfo.Item;
          ACollection.CurrentIndex := ABookmarkInfo.ItemIndex;
          GotoBookmark := True;
          end
     else GotoBookmark := False;
end;

function MoveToFirstJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     if (ACollection.First <> nil)
     then begin
          ACollection.CurrentTable := ACollection.First;
          ACollection.CurrentItem := 0;
          while ((ACollection.CurrentTable <> nil)
                and (ACollection.CurrentTable^.Used = 0))
          do ACollection.CurrentTable := ACollection.CurrentTable^.Next;
          if (ACollection.CurrentTable <> nil)
          then begin
               ACollection.CurrentIndex := 1;
               ACollection.CurrentItem := 1;
               MoveToFirstJumpItem := True;
               end
          else begin
               ACollection.CurrentIndex := 0;
               ACollection.CurrentItem := 0;
               MoveToFirstJumpItem := False;
               end;
          end
     else MoveToFirstJumpItem := False;
end;

function GetFirstJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if (ACollection.First <> nil)
     then begin
          ACollection.CurrentTable := ACollection.First;
          ACollection.CurrentItem := 0;
          while ((ACollection.CurrentTable <> nil)
                and (ACollection.CurrentTable^.Used = 0))
          do ACollection.CurrentTable := ACollection.CurrentTable^.Next;
          if (ACollection.CurrentTable <> nil)
          then begin
               ACollection.CurrentIndex := 1;
               ACollection.CurrentItem := 1;
               AItem := ACollection.CurrentTable^.Items[1];
               GetFirstJumpItem := True;
               end
          else begin
               ACollection.CurrentIndex := 0;
               ACollection.CurrentItem := 0;
               GetFirstJumpItem := False;
               end;
          end
     else GetFirstJumpItem := False;
end;

function MoveToLastJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     if (ACollection.Last <> nil)
     then begin
          ACollection.CurrentTable := ACollection.Last;
          ACollection.CurrentItem := 0;
          while ((ACollection.CurrentTable <> nil)
                and (ACollection.CurrentTable^.Used = 0))
          do ACollection.CurrentTable := ACollection.CurrentTable^.Prev;
          if (ACollection.CurrentTable <> nil)
          then begin
               ACollection.CurrentIndex := ACollection.Size;
               ACollection.CurrentItem := ACollection.CurrentTable^.Used;
               MoveToLastJumpItem := True;
               end
          else begin
               ACollection.CurrentIndex := 0;
               ACollection.CurrentItem := 0;
               MoveToLastJumpItem := False;
               end;
          end
     else MoveToLastJumpItem := False;
end;


function GetLastJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if (ACollection.Last <> nil)
     then begin
          ACollection.CurrentTable := ACollection.Last;
          ACollection.CurrentItem := 0;
          while ((ACollection.CurrentTable <> nil)
                and (ACollection.CurrentTable^.Used = 0))
          do ACollection.CurrentTable := ACollection.CurrentTable^.Prev;
          if (ACollection.CurrentTable <> nil)
          then begin
               ACollection.CurrentIndex := ACollection.Size;
               ACollection.CurrentItem := ACollection.CurrentTable^.Used;
               AItem := ACollection.CurrentTable^.Items[ACollection.CurrentItem];
               GetLastJumpItem := True;
               end
          else begin
               ACollection.CurrentIndex := 0;
               ACollection.CurrentItem := 0;
               GetLastJumpItem := False;
               end;
          end
     else GetLastJumpItem := False;
end;

function MoveToNextJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     if (ACollection.CurrentTable <> nil)
     then begin
          if (ACollection.CurrentItem < ACollection.CurrentTable^.Used)
          then begin
               ACollection.CurrentIndex := ACollection.CurrentIndex + 1;
               ACollection.CurrentItem := ACollection.CurrentItem + 1;
               MoveToNextJumpItem := True;
               end
          else begin
               MoveToNextJumpItem := False;
               while (ACollection.CurrentTable <> nil)
               do begin
                  ACollection.CurrentTable := ACollection.CurrentTable^.Next;
                  if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentTable^.Used > 0))
                  then begin
                       ACollection.CurrentIndex := ACollection.CurrentIndex + 1;
                       ACollection.CurrentItem := 1;
                       MoveToNextJumpItem := True;
                       Break;
                       end;
                  end;
               end;
          end
     else MoveToNextJumpItem := False;
end;

function GetNextJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if (ACollection.CurrentTable <> nil)
     then begin
          if (ACollection.CurrentItem < ACollection.CurrentTable^.Used)
          then begin
               ACollection.CurrentIndex := ACollection.CurrentIndex + 1;
               ACollection.CurrentItem := ACollection.CurrentItem + 1;
               AItem := ACollection.CurrentTable^.Items[ACollection.CurrentItem];
               GetNextJumpItem := True;
               end
          else begin
               GetNextJumpItem := False;
               while (ACollection.CurrentTable <> nil)
               do begin
                  ACollection.CurrentTable := ACollection.CurrentTable^.Next;
                  if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentTable^.Used > 0))
                  then begin
                       ACollection.CurrentIndex := ACollection.CurrentIndex + 1;
                       ACollection.CurrentItem := 1;
                       AItem := ACollection.CurrentTable^.Items[1];
                       GetNextJumpItem := True;
                       Break;
                       end;
                  end;
               end;
          end
     else GetNextJumpItem := False;
end;

function MoveToPrevJumpItem( var ACollection: TJumpTableCollection): Boolean;
begin
     if (ACollection.CurrentTable <> nil)
     then begin
          if (ACollection.CurrentItem > 1)
          then begin
               ACollection.CurrentIndex := ACollection.CurrentIndex - 1;
               ACollection.CurrentItem := ACollection.CurrentItem - 1;
               MoveToPrevJumpItem := True;
               end
          else begin
               MoveToPrevJumpItem := False;
               while (ACollection.CurrentTable <> nil)
               do begin
                  ACollection.CurrentTable := ACollection.CurrentTable^.Prev;
                  if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentTable^.Used > 0))
                  then begin
                       ACollection.CurrentIndex := ACollection.CurrentIndex - 1;
                       ACollection.CurrentItem := ACollection.CurrentTable^.Used;
                       MoveToPrevJumpItem := True;
                       Break;
                       end;
                  end;
               end;
          end
     else MoveToPrevJumpItem := False;
end;

function GetPrevJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if (ACollection.CurrentTable <> nil)
     then begin
          if (ACollection.CurrentItem > 1)
          then begin
               ACollection.CurrentIndex := ACollection.CurrentIndex - 1;
               ACollection.CurrentItem := ACollection.CurrentItem - 1;
               AItem := ACollection.CurrentTable^.Items[ACollection.CurrentItem];
               GetPrevJumpItem := True;
               end
          else begin
               GetPrevJumpItem := False;
               while (ACollection.CurrentTable <> nil)
               do begin
                  ACollection.CurrentTable := ACollection.CurrentTable^.Prev;
                  if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentTable^.Used > 0))
                  then begin
                       ACollection.CurrentIndex := ACollection.CurrentIndex - 1;
                       ACollection.CurrentItem := ACollection.CurrentTable^.Used;
                       AItem := ACollection.CurrentTable^.Items[ACollection.CurrentItem];
                       GetPrevJumpItem := True;
                       Break;
                       end;
                  end;
               end;
          end
     else GetPrevJumpItem := False;
end;

function GetCurrentJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentItem <> 0))
     then begin
          AItem := ACollection.CurrentTable^.Items[ACollection.CurrentItem];
          GetCurrentJumpItem := True;
          end
     else GetCurrentJumpItem := False;
end;

function SetCurrentJumpItem( var ACollection: TJumpTableCollection; var AItem: TJumpRec): Boolean;
begin
     if ((ACollection.CurrentTable <> nil) and (ACollection.CurrentItem <> 0))
     then begin
          ACollection.CurrentTable^.Items[ACollection.CurrentItem] := AItem;
          SetCurrentJumpItem := True;
          end
     else SetCurrentJumpItem := False;
end;

end.