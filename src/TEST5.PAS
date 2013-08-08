uses Machine, Crt, Graph, Generics, Streams, DataTypes;

var TheMachine: TMachine;
    InputStream: PStream;
    Gd, Gm: Integer;
begin
     ClrScr;
     WriteLn('Mem :', MemAvail);
     TheMachine.Create;
     InputStream := New(PFileStream, Create('OUTPUT.TXT'));
     TheMachine.LoadDataFromStream(InputStream);
     Gd := Detect;
     InitGraph(Gd, Gm,' ');
     OutText('Press any key to draw ...');
     ReadKey;
     ClearDevice;
     TheMachine.Run;
     TheMachine.Destroy;
     ReadLn;
     CloseGraph;
     WriteLn('Mem :', MemAvail);
     ReadLn;
end.