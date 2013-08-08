uses Graph;

type
    Float = Double;

    TRPoint = record
        X,Y : Float;
        end;

     TRRect = record
        A, B: TRPoint;
        end;

     PPathPoint = ^TPathPoint;
     TPathPoint = record
        Point: TRPoint;
        Next: PPathPoint;
        end;

    procedure AppendPoint(var APath: PPathPoint; AX, AY: Float);
    var Temp: PPathPoint;
    begin
         if (APath = nil)
         then begin
              New(APath);
              APath^.Next := nil;
              APath^.Point.X := AX;
              APath^.Point.Y := AY;
              end
         else begin
              Temp := APath;
              while (Temp^.Next <> nil)
              do Temp := Temp^.Next;
              New(Temp^.Next);
              Temp^.Next^.Next := nil;
              Temp^.Next^.Point.X := AX;
              Temp^.Next^.Point.Y := AY;
              end;
    end;

    procedure DrawPolligon(APath: PPathPoint);
    var Temp: PPathPoint;
    begin
         Temp := APath;
         if (Temp <> nil)
         then begin
              MoveTo(Round(Temp^.Point.X), Round(Temp^.Point.Y));
              Temp := Temp^.Next;
              while (Temp <> nil)
              do begin
                 LineTo(Round(Temp^.Point.X), Round(Temp^.Point.Y));
                 Temp := Temp^.Next;
                 end;
              end;
    end;

    procedure DrawPoints(APath: PPathPoint);
    var Temp: PPathPoint;
    begin
         Temp := APath;
         while (Temp <> nil)
         do begin
            Rectangle(Round(Temp^.Point.X) - 2,Round(Temp^.Point.Y) - 2,Round(Temp^.Point.X) + 2,Round(Temp^.Point.Y) + 2);
            Temp := Temp^.Next;
            end;
    end;


    function GetPolligonLength(APath: PPathPoint): Float;
    var Temp: PPathPoint;
        Length: Float;
        LastX, LastY : Float;
    begin
         Length := 0;
         Temp := APath;
         if (Temp <> nil)
         then begin
              LastX := Temp^.Point.X;
              LastY := Temp^.Point.Y;
              Temp := Temp^.Next;
              while (Temp <> nil)
              do begin
                 Length := Length + Sqrt(Sqr(Temp^.Point.X - LastX) + Sqr(Temp^.Point.Y - LastY));
                 LastX := Temp^.Point.X;
                 LastY := Temp^.Point.Y;
                 Temp := Temp^.Next;
                 end;
              end;
         GetPolligonLength := Length;
    end;

    function GetPathPoints(APath: PPathPoint; ACount: Integer): PPathPoint;
    var StepLength: Float;
        PrevTemp, Temp: PPathPoint;
        Remain: Float;
        Path: PPathPoint;
        CurrentRemainLength: Float;
        LastX, LastY: Float;
        KX, KY, NewX, NewY: Float;
    begin
         Path := nil;
         StepLength := GetPolligonLength(APath) / (ACount - 1);
         Temp := APath;
         Remain := StepLength;
         if (Temp <> nil)
         then begin
              LastX := Temp^.Point.X;
              LastY := Temp^.Point.Y;
              AppendPoint(Path, LastX, LastY);
              PrevTemp := Temp;
              Temp := Temp^.Next;
              while (Temp <> nil)
              do begin
                 CurrentRemainLength := Sqrt(Sqr(Temp^.Point.X - LastX) + Sqr(Temp^.Point.Y - LastY));
                 KX := (Temp^.Point.X - LastX) / CurrentRemainLength;
                 KY := (Temp^.Point.Y - LastY) / CurrentRemainLength;
                 while (CurrentRemainLength > Remain)
                 do begin
                    LastX := LastX + KX * Remain;
                    LastY := LastY + KY * Remain;
                    AppendPoint(Path, LastX, LastY);
                    CurrentRemainLength := CurrentRemainLength - Remain;
                    Remain := StepLength;
                    end;
                 Remain := Remain - CurrentRemainLength;
                 LastX := Temp^.Point.X;
                 LastY := Temp^.Point.Y;
                 PrevTemp := Temp;
                 Temp := Temp^.Next;
                 end;
              AppendPoint(Path, PrevTemp^.Point.X, PrevTemp^.Point.Y);
              end;
         GetPathPoints := Path;
    end;

    function MergePoints(PointsA, PointsB: PPathPoint): PPathPoint;
    var ResultPoints: PPathPoint;
        TempA, TempB: PPathPoint;
    begin
         TempA := PointsA;
         TempB := PointsB;
         ResultPoints := nil;
         while ((TempA <> nil) and (TempB <> nil))
         do begin
            AppendPoint(ResultPoints, TempA^.Point.X, TempA^.Point.Y);
            AppendPoint(ResultPoints, TempB^.Point.X, TempB^.Point.Y);
            TempA := TempA^.Next;
            TempB := TempB^.Next;
            end;
         MergePoints := ResultPoints;
    end;

var PolligonA, PolligonB: PPathPoint;
    PathPointsA, PathPointsB: PPathPoint;
    ResltPath: PPathPoint;
    Gd, Gm: Integer;
    Radius: Integer;
begin
     Gd := Detect;
     InitGraph(Gd, Gm,' ');
     PolligonA := nil;
     AppendPoint(PolligonA, 100,100);
     AppendPoint(PolligonA, 100,200);
     AppendPoint(PolligonA, 200,200);
     AppendPoint(PolligonA, 300,300);
     AppendPoint(PolligonA, 200,400);
     PolligonB := nil;
     AppendPoint(PolligonB, 110,120);
     AppendPoint(PolligonB, 410,220);
     AppendPoint(PolligonB, 410,420);
     {AppendPoint(PolligonB, 210,220);
     AppendPoint(PolligonB, 310,320);
     AppendPoint(PolligonB, 210,420);}
     DrawPolligon(PolligonA);
     DrawPolligon(PolligonB);
     PathPointsA := GetPathPoints(PolligonA, 20);
     PathPointsB := GetPathPoints(PolligonB, 20);
     ReadLn;
     {ClearDevice;}
     DrawPoints(PathPointsA);
     DrawPoints(PathPointsB);
     WriteLn('Length A = ',GetPolligonLength(PolligonA):10:3);
     WriteLn('Length B = ',GetPolligonLength(PolligonB):10:3);
     ReadLn;
     ResltPath := MergePoints(PathPointsA, PathPointsB);
     ClearDevice;
     DrawPolligon(ResltPath);
     ReadLn;
     CloseGraph;
end.



