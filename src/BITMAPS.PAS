unit Canvas;

interface

uses WinTypes, WinProcs, OWindows, WIN31,
     Generics, SpeedButtons, Aligner, Streams,
     DlgBoxes;

const IDM_PALIND = 301;


type TBitmap = object(TGeneric)
     private
         Loaded: Boolean;
         hDIBInfo: THandle;
         hDDBitmap: HBitmap;
         hOldBitmap: HBitmap;

         Palette: HPalette;
         PalHeader: HPalette;

         wPalOp: Word;

         function MakeIndexHeader(lpInfo: PBitmapInfoHeader): THandle;
         function MakeDIBPalette(lpInfo: PBitmapInfoHeader): HPalette;
     public
         constructor Create;
         destructor Destroy; virtual;
         procedure LoadFromFile(AName: string);
         procedure DisplayToWindow( AWindowHandle: HWnd; AX, AY, AW, AH: Integer);
         end;

implementation

type PRGBQuad = ^TRGBQuad;

constructor TBitmap.Create;
begin
     inherited Create;
     Loaded := False;
     hDIBInfo := 0;
     hDDBitmap := 0;
     hOldBitmap := 0;
     Palette := 0;
     PalHeader := 0;
     wPalOp := 0;
end;

destructor TBitmap.Destroy;
begin
     inherited Destroy;
end;

function TBitmap.MakeIndexHeader(lpInfo: PBitmapInfoHeader): THandle;
var hPalInfo: THandle;
    lpPalInfo: PBitmapInfoHeader;
    lpTable: ^Word;
    I: Word;
begin
     if (lpInfo^.biClrUsed > 0)
     then begin
          hPalInfo := GlobalAlloc( GMEM_MOVEABLE, lpInfo^.biSize + lpInfo^.biClrUsed * SizeOf(Word));
          if (hPalInfo = 0)
          then begin
               MakeIndexHeader := 0;
               Exit
               end;

          lpPalInfo := PBitmapInfoHeader(GlobalLock(hPalInfo));
          lpPalInfo^ := lpInfo^;
          lpTable := Pointer(PChar(lpPalInfo) + lpPalInfo^.biSize);

          for I := 0 to lpInfo^.biClrUsed - 1
          do lpTable^ := lpTable^ + i;

          GlobalUnlock(hPalInfo);

          MakeIndexHeader := hPalInfo;
          end
     else MakeIndexHeader := 0;
end;

function TBitmap.MakeDIBPalette(lpInfo: PBitmapInfoHeader): HPalette;
var npPal: PLogPalette;
    PalSize: Word;
    lpRGB: PRGBQuad;
    hLogPal: HPalette;
    I: Word;
begin
     if (lpInfo^.biClrUsed > 0)
     then begin
          {npPal := PLogPalette(LocalAlloc(LMEM_FIXED, SizeOf(TLogPalette))
                    + Word(lpInfo^.biClrUsed) * SizeOf(TPaletteEntry));}
          PalSize := SizeOf(TLogPalette) + Word(lpInfo^.biClrUsed) * SizeOf(TPaletteEntry);
          GetMem(npPal, PalSize);
          npPal^.palVersion := $300;
          npPal^.palNumEntries := Word(lpInfo^.biClrUsed);
          lpRGB := PRGBQuad(PChar(lpInfo) + lpInfo^.biSize);

          for I := 0 to lpInfo^.biClrUsed - 1
          do begin
             npPal^.palPalEntry[I].peRed := lpRGB^.rgbRed;
             npPal^.palPalEntry[I].peGreen := lpRGB^.rgbGreen;
             npPal^.palPalEntry[I].peBlue := lpRGB^.rgbBlue;
             npPal^.palPalEntry[I].peFlags := 0;
             lpRGB := PRGBQuad(PChar(lpRGB) + SizeOf(TRGBQuad))
             end;

          hLogPal := CreatePalette(npPal^);

          FreeMem(npPal, PalSize);
          MakeDIBPalette := hLogPal;
          end
     else MakeDIBPalette := 0;
end;




procedure TBitmap.LoadFromFile(AName: string);
begin
end;

procedure TBitmap.DisplayToWindow( AWindowHandle: HWnd; AX, AY, AW, AH: Integer);
var DC: HDC;
    Rectangle: TRect;
    lpInfo: PBitmapInfoHeader;
    lpHeader: PBitmapInfoHeader;
    hOldPal: HPalette;
    wDIBUse: Word;
label ExitTime;
begin
     DC := GetDC(AWindowHandle);
     lpInfo := PBitmapInfoHeader(GlobalLock(hDIBInfo));

     if ((wPalOp > 0) and (lpInfo^.biClrUsed > 0))
     then begin
          if (Palette = 0)
          then MakeDIBPalette(lpInfo);

          if (Palette = 0)
          then goto ExitTime;

          hOldPal := SelectPalette( DC, Palette, FALSE);
          RealizePalette( DC);

          if ((wPalOp = IDM_PALIND) and (lpInfo^.biBitCount <> 24))
          then begin
               if (hPalHeader = 0)
               then
               end
          else begin
               end;
          end
     else begin
          end;

end;}



end.