unit Streams;

interface

uses Generics;

type
    PStream = ^TStream;
    TStream = object(TGeneric)
       constructor Create;
       destructor Destroy; virtual;
       procedure Reset; virtual;
       procedure WriteBlock(var Buf; ASize: Word); virtual;
       procedure ReadBlock(var Buf; ASize: Word); virtual;
       function Size: Longint; virtual;
       function EOS: Boolean; virtual;
       function BOS: Boolean; virtual;
       procedure Seek(APos: Longint); virtual;
       function Pos: Longint; virtual;
       function ErrorCode: Word; virtual;
       end;

    PFileStream = ^TFileStream;
    TFileStream = object(TStream)
    private
           F: File;
           Error: Word;
    public
       constructor Create(AFileName: string);
       destructor Destroy; virtual;
       procedure Reset; virtual;
       procedure WriteBlock(var Buf; ASize: Word); virtual;
       procedure ReadBlock(var Buf; ASize: Word); virtual;
       function Size: Longint; virtual;
       function EOS: Boolean; virtual;
       function BOS: Boolean; virtual;
       procedure Seek(APos: Longint); virtual;
       function Pos: Longint; virtual;
       function ErrorCode: Word; virtual;
       end;

implementation

constructor TStream.Create;
begin
     Inherited Create;
end;

destructor TStream.Destroy;
begin
     inherited Destroy;
end;

procedure TStream.Reset;
begin
end;

procedure TStream.WriteBlock(var Buf; ASize: Word);
begin
end;

procedure TStream.ReadBlock(var Buf; ASize: Word);
begin
     FillChar(Buf, ASize, #0);
end;

function TStream.Size: Longint;
begin
     Size := 0;
end;

function TStream.EOS: Boolean;
begin
     EOS := True;
end;

function TStream.BOS: Boolean;
begin
     BOS := True;
end;

procedure TStream.Seek(APos: Longint);
begin
end;

function TStream.Pos: Longint;
begin
     Pos := 0;
end;

function TStream.ErrorCode: Word;
begin
     ErrorCode := 0;
end;




constructor TFileStream.Create(AFileName: string);
begin
     inherited Create;
{$I-}
     System.Assign(F, AFileName);
     System.Reset(F,1);
     if (System.IOResult <> 0)
     then begin
          System.Rewrite(F,1);
          Error := System.IOResult;
          end
     else Error := 0;
end;

destructor TFileStream.Destroy;
begin
     System.Close(F);
     inherited Destroy;
end;

procedure TFileStream.Reset;
begin
     if (Error = 0)
     then begin
          Close(F);
          Erase(F);
          Rewrite(F,1);
          Error := IOResult;
          end;
end;

procedure TFileStream.WriteBlock(var Buf; ASize: Word);
begin
     if (Error = 0)
     then begin
          System.BlockWrite(F, Buf, ASize);
          Error := System.IOResult;
          end;
end;

procedure TFileStream.ReadBlock(var Buf; ASize: Word);
begin
     if (Error = 0)
     then begin
          System.BlockRead(F, Buf, ASize);
          Error := System.IOResult;
          end;
end;

function TFileStream.Size: Longint;
begin
     Size := System.FileSize(F);
     Error := System.IOResult;
end;

function TFileStream.EOS: Boolean;
begin
     EOS := System.EOF(F);
     Error := System.IOResult;
end;

function TFileStream.BOS: Boolean;
begin
     BOS := (System.FilePos(F) = 0);
     Error := System.IOResult;
end;

procedure TFileStream.Seek(APos: Longint);
begin
     if (Error = 0)
     then begin
          System.Seek(F, APos);
          Error := System.IOResult;
          end;
end;

function TFileStream.Pos: Longint;
begin
     Pos := System.FilePos(F);
     Error := System.IOResult;
end;

function TFileStream.ErrorCode: Word;
begin
     ErrorCode := Error;
end;

end.