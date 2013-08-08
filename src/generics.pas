{*************************************************}
{*                                               *}
{*   Generics unit                               *}
{*                                               *}
{*************************************************}

unit Generics;

interface

{$IFDEF DEBUGSTATE}
var DebugOutput: Text;
{$ENDIF}

type
    PString = ^string;

    PPGeneric = ^PGeneric;
    PGeneric = ^TGeneric;
    TGeneric = object
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure Free; virtual;
        end;

    PError = ^TError;
    TError = object( TGeneric)
        end;

    PMessageError = ^TMessageError;
    TMessageError = object( TError)
    private
        Message: PString;
    public
        constructor Create( AMessage: string);
        destructor Destroy; virtual;
        function GetMessage: string;
        end;

    PErrGeneric = ^TErrGeneric;
    TErrGeneric = object( TGeneric)
    private
        Owner: PErrGeneric;
    public
        constructor Create( AOwner: PErrGeneric);
        function AddError( AError: PError): Boolean; virtual;
        function AnyError: Boolean; virtual;
        function GetErrorsCount: Word; virtual;
        function GetError( AErrorIndex: Word): PError; virtual;
        end;

    PItemLink = ^TItemLink;
    TItemLink = record
        Item : PGeneric;
        Next : PItemLink;
        Prev : PItemLink;
        end;

    PCollection = ^TCollection;
    TCollection = object( TGeneric)
    private
        First, Last, Current: PItemLink;
    public
        constructor Create;
        destructor Destroy; virtual;
        procedure Clear;
        procedure WhenFreeCollectionItem( AItem: PGeneric); virtual;
        function GetItemsCount: Word;
        procedure PushLast( AItem: PGeneric);
        function PopLast: PGeneric;
        procedure PushFirst( AItem: PGeneric);
        function PopFirst: PGeneric;
        function RemoveFromCollection( AItem: PGeneric): Boolean;
        function GetFirst: PGeneric;
        function GetLast: PGeneric;
        function GetNext: PGeneric;
        function GetPrev: PGeneric;
        function GetByIndex( AIndex: Integer): PGeneric;
        function GetAfter( AItem: PGeneric): PGeneric;
        function GetBefore( AItem: PGeneric): PGeneric;
        function InsertAfter( AItem, NewItem: PGeneric): Boolean;
        function InsertBefore( AItem, NewItem: PGeneric): Boolean;
        end;

    PContainerCollection = ^TContainerCollection;
    TContainerCollection = object( TCollection)
    public
        procedure WhenFreeCollectionItem( AItem: PGeneric); virtual;
        end;

    PTopErrGeneric = ^TTopErrGeneric;
    TTopErrGeneric = object( TErrGeneric)
    private
        Errors: PContainerCollection;
    public
        constructor Create;
        destructor Destroy; virtual;
        function AddError( AError: PError): Boolean; virtual;
        function AnyError: Boolean; virtual;
        function GetErrorsCount: Word; virtual;
        function GetError( AErrorIndex: Word): PError; virtual;
        end;

    function AllocateString( AString: string): PString;
    procedure FreeString( AString: PString);

implementation

function AllocateString( AString: string): PString;
var NewString: PString;
begin
     if ( Length( AString) > 0)
     then begin
          GetMem( NewString, Length( AString) + 1);
          NewString^ := AString;
          AllocateString := NewString;
          end
     else AllocateString := nil;
end;

procedure FreeString( AString: PString);
begin
     if ( AString <> nil)
     then FreeMem( AString, Length( AString^) + 1);
end;


constructor TGeneric.Create;
begin
end;

destructor TGeneric.Destroy;
begin
end;

procedure TGeneric.Free;
var TempGeneric : PGeneric;
begin
     TemPGeneric := @Self;
     Dispose( TempGeneric, Destroy);
end;


constructor TMessageError.Create( AMessage: string);
begin
     inherited Create;
     Message := AllocateString( AMessage);
end;

destructor TMessageError.Destroy;
begin
     FreeString( Message);
     inherited Destroy;
end;

function TMessageError.GetMessage: string;
begin
     if ( Message <> nil)
     then GetMessage := Message^
     else GetMessage := '';
end;


constructor TErrGeneric.Create( AOwner: PErrGeneric);
begin
     inherited Create;
     Owner := AOwner;
end;

function TErrGeneric.AddError( AError: PError): Boolean;
begin
     if ( Owner <> nil)
     then AddError := Owner^.AddError( AError)
     else begin
          AError^.Free;
          AddError := False;
          end;
end;

function TErrGeneric.AnyError: Boolean;
begin
     if ( Owner <> nil)
     then begin
          AnyError := Owner^.AnyError;
          end
     else AnyError := False;
end;


function TErrGeneric.GetErrorsCount: Word;
begin
     if ( Owner <> nil)
     then GetErrorsCount := Owner^.GetErrorsCount
     else GetErrorsCount := 0;
end;

function TErrGeneric.GetError( AErrorIndex: Word): PError;
begin
     if ( Owner <> nil)
     then GetError := Owner^.GetError( AErrorIndex)
     else GetError := nil;
end;


constructor TCollection.Create;
begin
     inherited Create;
     First := nil;
     Last := nil;
     Current := nil;
end;

destructor TCollection.Destroy;
begin
     Clear;
     inherited Destroy;
end;

procedure TCollection.Clear;
begin
     Current := First;
     while ( Current <> nil)
     do begin
        WhenFreeCollectionItem( Current^.Item);
        First := Current^.Next;
        Dispose( Current);
        Current := First;
        end;
     Current := nil;
     First := nil;
     Last := nil;
end;

procedure TCollection.WhenFreeCollectionItem( AItem: PGeneric);
begin
end;

function TCollection.GetItemsCount: Word;
var C: Word;
    TempItem: PItemLink;
begin
     TempItem := First;
     C := 0;
     while ( TempItem <> nil)
     do begin
        C := C + 1;
        TempItem := TempItem^.Next;
        end;
     GetItemsCount := C;
end;

procedure TCollection.PushLast( AItem: PGeneric);
var NewItem: PItemLink;
begin
     if ( AItem <> nil)
     then begin
          New( NewItem);
          NewItem^.Next := nil;
          NewItem^.Prev := Last;
          NewItem^.Item := AItem;
          Current := NewItem;
          if ( First <> nil)
          then Last^.Next := NewItem
          else First := NewItem;
          Last := NewItem;
          end;
end;

function TCollection.PopLast: PGeneric;
var TempItem: PItemLink;
begin
     if ( First <> nil)
     then begin
          TempItem := Last;
          Last := Last^.Prev;
          Current := Last;
          if ( Last = nil)
          then First := nil;
          PopLast := TempItem^.Item;
          Dispose( TempItem);
          end
     else PopLast := nil;
end;

procedure TCollection.PushFirst( AItem: PGeneric);
var NewItem: PItemLink;
begin
     New( NewItem);
     NewItem^.Next := First;
     NewItem^.Prev := nil;
     NewItem^.Item := AItem;
     Current := NewItem;
     if ( First <> nil)
     then begin
          First^.Prev := NewItem;
          First := NewItem;
          end
     else begin
          First := NewItem;
          Last := NewItem;
          end;
end;

function TCollection.PopFirst: PGeneric;
var TempItem: PItemLink;
begin
     if ( First <> nil)
     then begin
          TempItem := First;
          First := First^.Next;
          Current := First;
          if ( First = nil)
          then Last := nil;
          PopFirst := TempItem^.Item;
          Dispose( TempItem);
          end
     else PopFirst := nil;
end;

function TCollection.RemoveFromCollection( AItem: PGeneric): Boolean;
var TempItem: PItemLink;
begin
     TempItem := First;
     while ( TempItem <> nil)
     do if ( TempItem^.Item <> AItem)
        then TempItem := TempItem^.Next
        else begin
             if ( TempItem^.Next <> nil)
             then TempItem^.Next^.Prev := TempItem^.Prev
             else Last := TempItem^.Prev;

             if ( TempItem^.Prev <> nil)
             then TempItem^.Prev^.Next := TempItem^.Next
             else First := TempItem^.Next;
             Current := First;
             Dispose( TempItem);
             RemoveFromCollection := True;
             exit;
             end;
     RemoveFromCollection := False;
end;

function TCollection.GetFirst: PGeneric;
begin
     if ( First <> nil)
     then begin
          Current := First;
          GetFirst := Current^.Item;
          end
     else begin
          Current := nil;
          GetFirst := nil;
          end;
end;

function TCollection.GetLast: PGeneric;
begin
     if ( Last <> nil)
     then begin
          Current := Last;
          GetLast := Current^.Item;
          end
     else begin
          Current := nil;
          GetLast := nil;
          end;
end;

function TCollection.GetNext: PGeneric;
begin
     if (( Current <> nil) and ( Current <> Last))
     then begin
          Current := Current^.Next;
          GetNext := Current^.Item;
          end
     else begin
          Current := nil;
          GetNext := nil;
          end;
end;

function TCollection.GetPrev: PGeneric;
begin
     if (( Current <> nil) and ( Current <> First))
     then begin
          Current := Current^.Prev;
          GetPrev := Current^.Item;
          end
     else begin
          Current := nil;
          GetPrev := nil;
          end;
end;

function TCollection.GetByIndex( AIndex: Integer): PGeneric;
var C: Word;
    TempItem: PItemLink;
begin
     TempItem := First;
     C := 1;
     while ( TempItem <> nil)
     do if (C <> AIndex)
        then begin
             C := C + 1;
             TempItem := TempItem^.Next;
             end
        else begin
             Current := TempItem;
             GetByIndex := TempItem^.Item;
             exit;
             end;
     GetByIndex := nil;
end;

function TCollection.GetAfter( AItem: PGeneric): PGeneric;
var TempCurrent: PItemLink;
begin
     TempCurrent := First;
     while ( TempCurrent <> nil)
     do begin
        if ( TempCurrent^.Item = AItem)
        then if ( TempCurrent^.Next <> nil)
             then begin
                  Current := TempCurrent^.Next;
                  GetAfter := TempCurrent^.Next^.Item;
                  exit;
                  end;
        TempCurrent := TempCurrent^.Next;
        end;
     GetAfter := nil;
end;

function TCollection.GetBefore( AItem: PGeneric): PGeneric;
var TempCurrent: PItemLink;
begin
     TempCurrent := First;
     while ( TempCurrent <> nil)
     do begin
        if ( TempCurrent^.Item = AItem)
        then begin
             if ( TempCurrent^.Prev <> nil)
             then begin
                  Current := TempCurrent^.Prev;
                  GetBefore := TempCurrent^.Prev^.Item;
                  exit;
                  end
             else begin
                  GetBefore := nil;
                  exit;
                  end;
             end;
        TempCurrent := TempCurrent^.Next;
        end;
     GetBefore := nil;
end;

function TCollection.InsertAfter( AItem, NewItem: PGeneric): Boolean;
var TempCurrent: PItemLink;
    NewLink: PItemLink;
begin
     if (( AItem <> nil) and ( NewItem <> nil))
     then begin
          TempCurrent := First;
          while ( TempCurrent <> nil)
          do if ( TempCurrent^.Item = AItem)
             then begin
                  New( NewLink);
                  NewLink^.Item := NewItem;
                  NewLink^.Prev := TempCurrent;
                  if ( TempCurrent^.Next <> nil)
                  then begin
                       TempCurrent^.Next^.Prev := NewLink;
                       NewLink^.Next := TempCurrent^.Next;
                       end
                  else begin
                       Last := NewLink;
                       NewLink^.Next := nil;
                       end;
                  TempCurrent^.Next := NewLink;
                  Current := NewLink;
                  InsertAfter := True;
                  Exit;
                  end
             else TempCurrent := TempCurrent^.Next;
          end;
          InsertAfter := False;
end;

function TCollection.InsertBefore( AItem, NewItem: PGeneric): Boolean;
var TempCurrent: PItemLink;
    NewLink: PItemLink;
begin
     if (( AItem <> nil) and ( NewItem <> nil))
     then begin
          TempCurrent := First;
          while ( TempCurrent <> nil)
          do if ( TempCurrent^.Item = AItem)
             then begin
                  New( NewLink);
                  NewLink^.Item := NewItem;
                  NewLink^.Next := TempCurrent;
                  if ( TempCurrent^.Prev <> nil)
                  then begin
                       TempCurrent^.Prev^.Next := NewLink;
                       NewLink^.Prev := TempCurrent^.Prev;
                       end
                  else begin
                       First := NewLink;
                       NewLink^.Prev := nil;
                       end;
                  TempCurrent^.Prev := NewLink;
                  Current := NewLink;
                  InsertBefore := True;
                  Exit;
                  end
             else TempCurrent := TempCurrent^.Next;
          end;
          InsertBefore := False;
end;


procedure TContainerCollection.WhenFreeCollectionItem( AItem: PGeneric);
begin
     if ( AItem <> nil)
     then AItem^.Free;
end;


constructor TTopErrGeneric.Create;
begin
     inherited Create( nil);
     Errors := New( PContainerCollection, Create);
end;

destructor TTopErrGeneric.Destroy;
begin
     Errors^.Free;
     inherited Destroy;
end;

function TTopErrGeneric.AddError( AError: PError): Boolean;
begin
{$IFDEF DEBUGSTATE}
     WriteLn( DebugOutput, 'An error aded . . . .');
{$ENDIF}
     Errors^.PushLast( AError);
     AddError := true;
end;

function TTopErrGeneric.AnyError: Boolean;
begin
     AnyError := ( Errors^.GetItemsCount > 0);
end;

function TTopErrGeneric.GetErrorsCount: Word;
begin
     GetErrorsCount := Errors^.GetItemsCount;
end;

function TTopErrGeneric.GetError( AErrorIndex: Word): PError;
begin
     GetError := PError( Errors^.GetByIndex( AErrorIndex));
end;

end.
