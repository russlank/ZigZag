uses Graph, Crt;

type
    Float = Double;

    TRPoint = record
        X,Y : Float;
        end;

     TRRect = record
        A, B: TRPoint;
        end;

     PHashPoint = ^THashPoint;
     THashPoint = record
        Origin: TRPoint;
        Next, Prev: PHashPoint;
        HashLevel: Longint;
        SecondPoint: PHashPoint;
        Drawed: Boolean;
        end;

     PHashPointLink = ^THashPointLink;
     THashPointLink = record
        Next: PHashPointLink;
        Point: PHashPoint;
        Marked: Boolean;
        end;

     PPolPoint = ^TPolPoint;
     TPolPoint = record
        Origin: TRPoint;
        Next, Prev: PPolPoint;
        HashPoints: PHashPoint;
        end;

     PPolligon = ^TPolligon;
     TPolligon = record
        Next, Prev: PPolligon;
        Points: PPolPoint;
        end;

     PForm = ^TForm;
     TForm = record
        Polligons: PPolligon;
        end;


function CreateForm: PForm;
var TempForm: PForm;
begin
     New(TempForm);
     TempForm^.Polligons := nil;
     CreateForm := TempForm;
end;

function CreatePolligon: PPolligon;
var TempPolligon: PPolligon;
begin
     New(TempPolligon);
     TempPolligon^.Next := nil;
     TempPolligon^.Prev := nil;
     TempPolligon^.Points := nil;
     CreatePolligon := TempPolligon;
end;

function AppendHashPoint(APolPoint: PPolPoint; AX, AY: Float; AHashLevel: Longint): PHashPoint;
var TempHashPoint: PHashPoint;
begin
     New(TempHashPoint);
     TempHashPoint^.Origin.X := AX;
     TempHashPoint^.Origin.Y := AY;
     TempHashPoint^.HashLevel := AHashLevel;
     TempHashPoint^.SecondPoint := nil;
     TempHashPoint^.Drawed := False;
     if (APolPoint^.HashPoints <> nil)
     then begin
          TempHashPoint^.Next := APolPoint^.HashPoints;
          TempHashPoint^.Prev := APolPoint^.HashPoints^.Prev;
          APolPoint^.HashPoints^.Prev^.Next := TempHashPoint;
          APolPoint^.HashPoints^.Prev := TempHashPoint;
          end
     else begin
          TempHashPoint^.Next := TempHashPoint;
          TempHashPoint^.Prev := TempHashPoint;
          APolPoint^.HashPoints := TempHashPoint;
          end;
     AppendHashPoint := TempHashPoint;
end;

function AppendPointToPolligon(APolligon: PPolligon; AX, AY: Float): PPolPoint;
var NewPolPoint: PPolPoint;
begin
     New(NewPolPoint);
     NewPolPoint^.Origin.X := AX;
     NewPolPoint^.Origin.Y := AY;
     NewPolPoint^.HashPoints := nil;
     if (APolligon^.Points <> nil)
     then begin
          NewPolPoint^.Next := APolligon^.Points;
          NewPolPoint^.Prev := APolligon^.Points^.Prev;
          APolligon^.Points^.Prev^.Next := NewPolPoint;
          APolligon^.Points^.Prev := NewPolPoint;
          end
     else begin
          NewPolPoint^.Next := NewPolPoint;
          NewPolPoint^.Prev := NewPolPoint;
          APolligon^.Points := NewPolPoint;
          end;
     AppendPointToPolligon := NewPolPoint;
end;

procedure AppendPolligonToForm(AForm: PForm ;APolligon: PPolligon);
begin
     if (AForm^.Polligons <> nil)
     then begin
          APolligon^.Next := AForm^.Polligons;
          APolligon^.Prev := AForm^.Polligons^.Prev;
          AForm^.Polligons^.Prev^.Next := APolligon;
          AForm^.Polligons^.Prev := APolligon;
          end
     else begin
          APolligon^.Next := APolligon;
          APolligon^.Prev := APolligon;
          AForm^.Polligons := APolligon;
          end;
end;

procedure AppendHashPointLinks(var AFirstHashPointLink, AHashPointLink: PHashPointLink);
begin
     AHashPointLink^.Next := AFirstHashPointLink;
     AHashPointLink^.Marked := False;
     AFirstHashPointLink := AHashPointLink;
end;

procedure FreeHashPointLinks(AHashPointLink: PHashPointLink);
var Temp: PHashPointLink;
begin
     Temp := AHashPointLink;
     while (Temp <> nil)
     do begin
        AHashPointLink := Temp^.Next;
        Dispose(Temp);
        Temp := AHashPointLink;
        end;
end;

procedure DrawHashes(AForm: PForm);
var TempPolligon: PPolligon;
    TempPolPoint: PPolPoint;
    TempHashPoint: PHashPoint;
begin
     TempPolligon := AForm^.Polligons;
     if (TempPolligon <> nil)
     then repeat
          {DrawPolligon(TempPolligon);}
          TempPolPoint := TempPolligon^.Points;
          if (TempPolPoint <> nil)
          then begin
               repeat
               {SetColor(7);
               MoveTo(Round(TempPolPoint^.Origin.X),Round(TempPolPoint^.Origin.Y));
               LineTo(Round(TempPolPoint^.Next^.Origin.X),Round(TempPolPoint^.Next^.Origin.Y));}
               SetColor(15);
               TempHashPoint := TempPolPoint^.HashPoints;
               if (TempHashPoint <> nil)
               then repeat
                    if (TempHashPoint^.SecondPoint <> nil)
                    then begin
                         if (not TempHashPoint^.Drawed)
                         then begin
                              TempHashPoint^.Drawed := True;
                              TempHashPoint^.SecondPoint^.Drawed := True;
                              {MoveTo(Round(TempHashPoint^.Origin.X), Round(TempHashPoint^.Origin.Y));}
                              LineTo(Round(TempHashPoint^.Origin.X), Round(TempHashPoint^.Origin.Y));
                              SetColor(12);
                              LineTo(Round(TempHashPoint^.SecondPoint^.Origin.X), Round(TempHashPoint^.SecondPoint^.Origin.Y));
                              PutPixel(Round(TempHashPoint^.Origin.X), Round(TempHashPoint^.Origin.Y), 15);
                              PutPixel(Round(TempHashPoint^.SecondPoint^.Origin.X),
                                Round(TempHashPoint^.SecondPoint^.Origin.Y), 15);
                              Delay(100);
                              end;
                         end
                    else Circle(Round(TempHashPoint^.Origin.X), Round(TempHashPoint^.Origin.Y), 5);
                    TempHashPoint := TempHashPoint^.Next;
                    until (TempHashPoint = TempPolPoint^.HashPoints);
               TempPolPoint := TempPolPoint^.Next;
               until (TempPolPoint = TempPolligon^.Points);
               end;
          TempPolligon := TempPolligon^.Next;
          until (TempPolligon = AForm^.Polligons);

end;


procedure HashForm(AForm: PForm; Density: Float);
var CurrentLevel: Longint;
    CurrentLevelPoints: PHashPointLink;
    HashLevelY: Float;
    FirstTime: Boolean;
    procedure FindCurrentLevelHashPoints;
    var TempPolligon: PPolligon;
        TempPoint: PPolPoint;
        X1,Y1,X2,Y2,X3,Y3: Float;
        NewX, NewY: Float;
        HashPointLink: PHashPointLink;
    begin
         TempPolligon := AForm^.Polligons;
         if (TempPolligon <> nil)
         then repeat
              TempPoint := TempPolligon^.Points;
              if (TempPoint <> nil)
              then if (TempPoint^.Next <> TempPoint)
                   then repeat
                        Y1 := TempPoint^.Origin.Y;
                        Y2 := TempPoint^.Next^.Origin.Y;
                        if (Y1 <> Y2)
                        then begin
                             if (((HashLevelY > Y1) and (HashLevelY < Y2))
                                or ((HashLevelY < Y1) and (HashLevelY > Y2)))
                             then begin
                                  X1 := TempPoint^.Origin.X;
                                  X2 := TempPoint^.Next^.Origin.X;
                                  NewY := HashLevelY;
                                  NewX := (NewY - Y1) * ((X2 - X1) / (Y2 - Y1)) + X1;
                                  New(HashPointLink);
                                  HashPointLink^.Point := AppendHashPoint(TempPoint, NewX, NewY, CurrentLevel);
                                  AppendHashPointLinks(CurrentLevelPoints, HashPointLink);
                                  end
                             else begin
                                  if (HashLevelY = Y1)
                                  then begin
                                       Y3 := TempPoint^.Prev^.Origin.Y;
                                       if (((Y3 > Y1) and (Y2 < Y1))
                                          or ((Y3 < Y1) and (Y2 > Y1)))
                                       then begin
                                            NewY := HashLevelY;
                                            NewX := TempPoint^.Origin.X;;
                                            New(HashPointLink);
                                            HashPointLink^.Point := AppendHashPoint(TempPoint, NewX, NewY, CurrentLevel);
                                            AppendHashPointLinks(CurrentLevelPoints, HashPointLink);
                                            end;
                                       end;
                                  end;
                             end;
                        TempPoint := TempPoint^.Next;
                        until (TempPoint = TempPolligon^.Points);
              TempPolligon := TempPolligon^.Next;
              until (TempPolligon = AForm^.Polligons);
    end;

    function FindLeftmostHashPointInCurrentLevel: PHashPointLink;
    var TempHashPointLink: PHashPointLink;
        FirstFoundX: Float;
        FirstFoundHashpoint: PHashPointLink;
    begin
         if (CurrentLevelPoints <> nil)
         then begin
              FirstFoundHashpoint := nil;
              TempHashPointLink := CurrentLevelPoints;
              repeat
                    if (not TempHashPointLink^.Marked)
                    then begin
                         FirstFoundHashpoint := TempHashPointLink;
                         FirstFoundX := TempHashPointLink^.Point^.Origin.X;
                         TempHashPointLink := TempHashPointLink^.Next;
                         Break;
                         end;
                    TempHashPointLink := TempHashPointLink^.Next;
              until (TempHashPointLink = nil);


              while (TempHashPointLink <> nil)
              do begin
                 if (not TempHashPointLink^.Marked)
                 then begin
                      if (TempHashPointLink^.Point^.Origin.X < FirstFoundX)
                      then begin
                           FirstFoundHashpoint := TempHashPointLink;
                           FirstFoundX := FirstFoundHashpoint^.Point^.Origin.X;
                           end;
                      end;
                 TempHashPointLink := TempHashPointLink^.Next;
                 end;
              end
         else FirstFoundHashpoint := nil;
         FindLeftmostHashPointInCurrentLevel := FirstFoundHashpoint;
    end;

    procedure ConnectCurrentLevelHashPoints;
    var PointLinkA, PointLinkB: PHashPointLink;
    begin
         PointLinkA := FindLeftmostHashPointInCurrentLevel;
         PointLinkA^.Marked := True;
         PointLinkB := FindLeftmostHashPointInCurrentLevel;
         PointLinkB^.Marked := True;
         while ((PointLinkA <> nil) and (PointLinkB <> nil))
         do begin
            PointLinkA^.Point^.SecondPoint := PointLinkB^.Point;
            PointLinkB^.Point^.SecondPoint := PointLinkA^.Point;
            PointLinkA := FindLeftmostHashPointInCurrentLevel;
            PointLinkA^.Marked := True;
            PointLinkB := FindLeftmostHashPointInCurrentLevel;
            PointLinkB^.Marked := True;
            end;
    end;
var
   Original: Longint;
begin
     CurrentLevel := 0;
     HashLevelY := 40;
     CurrentLevelPoints := nil;
     FirstTime := True;
     Original := MemAvail;
     while ((CurrentLevelPoints <> nil) or FirstTime)
     do begin
        Write('Mem used = ', Original - MemAvail ,'      ', #13);
        FirstTime := False;
        ConnectCurrentLevelHashPoints;
        FreeHashPointLinks(CurrentLevelPoints);
        CurrentLevelPoints := nil;
        CurrentLevel := CurrentLevel + 1;
        HashLevelY := HashLevelY + Density;
        FindCurrentLevelHashPoints;
        end;
     ReadKey;
end;


















procedure DrawPolligon(APolligon: PPolligon);
var TempPoint: PPolPoint;
begin
     TempPoint := APolligon^.Points;
     if (TempPoint <> nil)
     then begin
          MoveTo(Round(TempPoint^.Origin.X), Round(TempPoint^.Origin.Y));
          repeat
                TempPoint := TempPoint^.Next;
                LineTo(Round(TempPoint^.Origin.X), Round(TempPoint^.Origin.Y));
          until (TempPoint = APolligon^.Points)
          end;
end;

procedure DrawForm(AForm: PForm);
var TempPolligon: PPolligon;
begin
     TempPolligon := AForm^.Polligons;
     if (TempPolligon <> nil)
     then repeat
          DrawPolligon(TempPolligon);
          TempPolligon := TempPolligon^.Next;
          until TempPolligon = AForm^.Polligons;
end;



var
   Polligon: PPolligon;
   Form: PForm;
   Gd, Gm: Integer;

begin
     Gd := Detect;
     InitGraph(Gd, Gm,' ');
     Form := CreateForm;
     (*
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 100, 100);
     AppendPointToPolligon(Polligon, 300, 100);
     AppendPointToPolligon(Polligon, 300, 300);
                                     {AppendPointToPolligon(Polligon, 300, 300);}
     AppendPointToPolligon(Polligon, 200, 400);
     AppendPolligonToForm(Form, Polligon);
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 120, 120);
     AppendPointToPolligon(Polligon, 320, 120);
     AppendPointToPolligon(Polligon, 320, 320);
                                     {AppendPointToPolligon(Polligon, 320, 320);}
     AppendPointToPolligon(Polligon, 220, 420);
     AppendPolligonToForm(Form, Polligon);
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 140, 140);
     AppendPointToPolligon(Polligon, 340, 140);
     AppendPointToPolligon(Polligon, 340, 340);
     AppendPointToPolligon(Polligon, 240, 240);
                                     {AppendPointToPolligon(Polligon, 340, 340);}
     AppendPointToPolligon(Polligon, 240, 440);
     AppendPolligonToForm(Form, Polligon);
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 160, 160);
     AppendPointToPolligon(Polligon, 360, 160);
     AppendPointToPolligon(Polligon, 360, 360);
                                     {AppendPointToPolligon(Polligon, 360, 360);}
     AppendPointToPolligon(Polligon, 260, 460);
     AppendPolligonToForm(Form, Polligon);
     *)
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 100, 100);
     AppendPointToPolligon(Polligon, 200, 40);
     AppendPointToPolligon(Polligon, 400, 100);
     AppendPointToPolligon(Polligon, 400, 400);
     AppendPointToPolligon(Polligon, 100, 400);
     AppendPolligonToForm(Form, Polligon);
     Polligon := CreatePolligon;
     AppendPointToPolligon(Polligon, 150, 150);
     AppendPointToPolligon(Polligon, 200, 200);
     AppendPointToPolligon(Polligon, 350, 150);
     AppendPointToPolligon(Polligon, 350, 350);
     AppendPointToPolligon(Polligon, 150, 350);
     AppendPolligonToForm(Form, Polligon);
     SetColor(15);
     DrawForm(Form);
     Readln;
     SetColor(12);
     RestoreCrtMode;
     HashForm(Form, 4);
     SetGraphMode(GM);
     {ClearDevice;}
     SetColor(12);
     DrawHashes(Form);
     ReadLn;
     CloseGraph;
end.