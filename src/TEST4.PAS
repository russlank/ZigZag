uses DataTypes, Crt, Generics, Streams, Graph;

var Data: TSendData;
    InputStream: PStream;
    Gd, Gm: Integer;

    procedure DrawData( AData: PSendData; AZoom: Integer);
    var DeltaX, DeltaY: Integer;
        Mode: Byte;
        LastX, LastY, NewX, NewY: Integer;
        I: Longint;
        FirstTime: Boolean;
    begin
         SetColor(12);
         MoveTo( 0, 0);
         LineTo( (AData^.MaxX - AData^.MinX) div AZoom, 0);
         LineTo( (AData^.MaxX - AData^.MinX) div AZoom, (AData^.MaxY - AData^.MinY) div AZoom);
         LineTo( 0, (AData^.MaxY - AData^.MinY) div AZoom);
         LineTo( 0, 0);
         SetColor(7);
         MoveTo( - AData^.MinX div AZoom, - AData^.MinY div AZoom);
         LastX := - AData^.MinX;
         LastY := - AData^.MinY;
         if (AData^.GetFirst(Mode, DeltaX, DeltaY) and (Mode = modReset))
         then begin
              MoveTo(LastX div AZoom, LastY div AZoom);
              while Data.GetNext(Mode, DeltaX, DeltaY)
              do begin
                 NewX := LastX + DeltaX;
                 NewY := LastY + DeltaY;
                 case Mode
                 of modNormal: LineTo(NewX div AZoom, NewY div AZoom);
                    modSlow: begin
                             SetColor( 9);
                             LineTo( NewX div AZoom, NewY div AZoom);
                             SetColor( 7);
                             end;
                    modStop: begin
                             LineTo( NewX div AZoom, NewY div AZoom);
                             SetColor( 14);
                             Circle( NewX div AZoom, NewY div AZoom, 5);
                             SetColor( 7);
                             MoveTo( NewX div AZoom, NewY div AZoom);
                             end;
                    end;
                 LastX := NewX;
                 LastY := NewY;
                 if KeyPressed
                 then begin
                      while KeyPressed
                      do ReadKey;
                      SetColor(5);
                      Data.GetCurrent( Mode, DeltaX, DeltaY);
                      I := 50;
                      repeat
                         I := I - 1;
                         NewX := LastX - DeltaX;
                         NewY := LastY - DeltaY;
                         LineTo( NewX div AZoom, NewY div AZoom);
                         LastX := NewX;
                         LastY := NewY;
                         Delay(10);
                         Data.GetPrev( Mode, DeltaX, DeltaY);
                      until ((Data.IsFirst) or (I = 0));
                      SetColor(7);
                      end;

                 if Data.IsFirst
                 then begin
                      Sound(2000);
                      Delay(100);
                      NoSound;
                      end;

                 if Data.IsLast
                 then begin
                      Sound(3000);
                      Delay(100);
                      NoSound;
                      end;

                 Delay(10);
                 end;
              end;
    end;

begin
     ClrScr;
     WriteLn('Mem :', MemAvail);
     Data.Create;
     InputStream := New(PFileStream, Create('OUTPUT.TXT'));
     Data.LoadDataFromStream(InputStream);
     WriteLn('Processing jumps ...');
     Data.ProcessDistanceJumps(50);
     WriteLn('Processing jumps finished ...');
     InputStream^.Free;
     Gd := Detect;
     InitGraph(Gd, Gm,' ');
     OutText('Press any key to draw ...');
     ReadKey;
     ClearDevice;
     DrawData(@Data, 1);
     Data.Destroy;
     ReadLn;
     CloseGraph;
     WriteLn('Mem :', MemAvail);
     ReadLn;
end.