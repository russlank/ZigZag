uses Graph, Crt;

type
    Float = Double;

    TRPoint = record
        X,Y : Float;
        end;

     TRRect = record
        A, B: TRPoint;
        end;

var
   Gd, Gm: Integer;
   X0, X1, X2, X3,
   Y0, Y1, Y2, Y3,
   X, Y,
   LastX, LastY: Float;
   T1, T12, T13,
   T2, T22, T23,
   TT1, TT2: Float;
begin
     Gd := Detect;
     InitGraph(Gd, Gm,' ');
     X0 := 200;
     Y0 := 100;

     X3 := 200;
     Y3 := 200;

     X1 := 300;
     Y1 := 10;
     X2 := 0;
     Y2 := 10;
     {X2 := X1;
     Y2 := Y1;}

     Circle(Round(X0),Round(Y0),5);
     Circle(Round(X1),Round(Y1),5);
     Circle(Round(X2),Round(Y2),5);
     Circle(Round(X3),Round(Y3),5);
     Line(Round(X0),Round(Y0),Round(X1),Round(Y1));
     Line(Round(X3),Round(Y3),Round(X2),Round(Y2));

     LastX := X0;
     LastY := Y0;
     T1 := 0.025;
     T2 := 1 - 0.025;
     while T1 <= 1
     do begin
        T12 := T1 * T1;
        T13 := T12 * T1;
        T22 := T2 * T2;
        T23 := T22 * T2;
        TT1 := 3 * T1 * T22;
        TT2 := 3 * T2 * T12;
        X := T23 * X0 + T13 * X3 + TT1 * X1 + TT2 * X2;
        Y := T23 * Y0 + T13 * Y3 + TT1 * Y1 + TT2 * Y2;
        Line(Round(X),Round(Y), Round(LastX), Round(LastY));
        LastX := X;
        LastY := Y;
        T1 := T1 + 0.025;
        T2 := T2 - 0.025;
        end;

     ReadLn;
     CloseGraph;
end.