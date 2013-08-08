unit Show;

interface

uses WinTypes, WinProcs, WIN31;

procedure ImageShow(Wnd: HWnd; X,Y: Integer; Bitmap: HBitmap; BlockSize: Integer; Delay: Integer; Dens: Integer);

implementation

procedure ImageShow(Wnd: HWnd; X,Y: Integer; Bitmap: HBitmap; BlockSize: Integer; Delay: Integer; Dens: Integer);
var DestDC, SrcDC: HDC;
    Dim: Longint;
    LX, LY: Integer;
    CX, CY, SX, CCX, I: Integer;
    OldBitmap: HBitmap;
    BMInfo: TBitmap;
begin
     if ((Wnd <> 0) and (Bitmap <> 0) and (BlockSize > 0))
     then begin
          GetObject(Bitmap,SizeOf(BMInfo),@BMInfo);
          LX := BMInfo.bmWidth div BlockSize;
          LY := BMInfo.bmHeight div BlockSize;
          DestDC := GetDC(Wnd);
          SrcDC := CreateCompatibleDC(DestDC);
          OldBitmap := SelectObject(SrcDC, Bitmap);
          for CX := 0 to LX - 1
          do begin
             if CX > Delay
             then begin
                  SX := CX - Delay;
                  BitBlt( DestDC, X + (SX - 1) * BlockSize, Y, BlockSize, LY*BlockSize,
                          SrcDC, (SX - 1) * BlockSize, 0, SRCCOPY);
                  end
             else SX := 0;
             for I := 1 to Dens
             do begin
                for CCX := SX to CX
                do begin
                   CY := Random(LY);
                   BitBlt( DestDC, X + CCX * BlockSize, Y + CY * BlockSize, BlockSize, BlockSize,
                           SrcDC, CCX * BlockSize, CY * BlockSize, SRCCOPY);
                   end;
                end;
             end;
          for CX := SX to LX
          do begin
             for CCX := CX to LX
             do begin
                for I := 1 to Dens
                do begin
                   CY := Random(LY);
                   BitBlt( DestDC, X + CCX * BlockSize, Y + CY * BlockSize, BlockSize, BlockSize,
                           SrcDC, CCX * BlockSize, CY * BlockSize, SRCCOPY);
                   end;
                end;
             BitBlt( DestDC, X + CX * BlockSize, Y, BlockSize, LY*BlockSize,
                     SrcDC, CX * BlockSize, 0, SRCCOPY);
             end;
          SelectObject(SrcDC, OldBitmap);
          DeleteDC(SrcDC);
          ReleaseDC(Wnd, DestDC);
          end;
end;

end.
