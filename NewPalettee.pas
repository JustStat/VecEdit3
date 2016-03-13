unit NewPalettee;

interface

uses Windows, SysUtils, Classes, Graphics, shapes, scale;

 type
 TRectangle = class
  private
    PenF: TRPen;
    BrushF: TRBrush;
    Points: Array of TPoint;
 public
    procedure Move(P: TPoint);
    procedure PaintShape(P: TPoint; CanvasOut: TCanvas);
 end;

type
 TPalRects = class
   private
   List: array of TRectangle;
   function GetItem(Index: Integer): TRectangle;
   procedure PutItem(Index: Integer; Item: TRectangle);
   function GetCount: Integer;
   public
   function Add(Sender: TRectangle): Integer;
   property Count: Integer read GetCount;
   property Items[Index: Integer]: TRectangle read GetItem write PutItem;
   procedure DrawAll(CanvasOut: TCanvas);
   procedure Delete(Index: Integer);
   procedure Clear;
 end;

type
  TFPalette = class
  private
    PalRects: TPalRects;
    CanvasOut: TCanvas;
  public
    SelectedColor: Integer;
    IHeigth: Integer;
    Zoomer: TZoomer;
    PalColors: Array of TColor;
    function Select(Index: Integer): TColor;
    function GetIndex(X, Y: Integer): Integer;
    function Scroll(Tag, PWidth: Integer): boolean;
    procedure ClearPalette;
    procedure AddColor(Color: TColor);
    procedure Delete(Index: Integer);
    procedure Draw;
    procedure LoadFromFile(Path: string);
    procedure SaveToFile(Path: string);
    procedure DoSelection(Index: Integer);
    procedure Free;
    constructor Create(Canvas: TCanvas; sIHeigth: Integer);
  end;

implementation

constructor TFPalette.Create(Canvas: TCanvas; sIHeigth: Integer);

const
  ColorsCount = 20;

var
  i: Integer;
  Tmp, Step: TColor;
begin
  IHeigth := sIHeigth;
  SelectedColor := -1;
  CanvasOut := Canvas;
  Tmp := $FFFFFF;
  Step := $000001;
  Zoomer := TZoomer.Create;
  PalRects := TPalRects.Create;
  for i := 1 to ColorsCount do
  begin
    AddColor(Tmp);
    Tmp := Tmp + Step;
  end;
end;

procedure TFPalette.Free;
begin
  PalRects.Free;
  Zoomer.Free;
  inherited Free;
end;

procedure TFPalette.ClearPalette;
begin
  SetLength(PalColors, 0);
  PalRects.Clear;
end;

procedure TFPalette.DoSelection(Index: Integer);
begin
  if (Index < 0) or (Index > high(PalColors)) then
    exit;
  with (PalRects.Items[Index] as TRectangle) do
    with CanvasOut do
    begin
      Brush.Style := bsCLear;
      Pen.Style := psSolid;
      Pen.Color := clBlue;
      Pen.Width := 1;
      Rectangle(Trunc(Points[0].X), Trunc(Points[0].Y), Trunc(Points[1].X),
        Trunc(Points[1].Y));
      Pen.Color := clWhite;
      Rectangle(Trunc(Points[0].X) + 1, Trunc(Points[0].Y) + 1,
        Trunc(Points[1].X) - 1, Trunc(Points[1].Y) - 1);
    end;
end;

procedure TFPalette.Draw;
var
  i: Integer;
begin
  for i := 0 to High(PalColors) do
    PalRects.Items[i].BrushF.Color := PalColors[i];
  PalRects.DrawAll(CanvasOut);
  DoSelection(SelectedColor);
end;

procedure TFPalette.AddColor(Color: TColor);
var
  X1, X2, Y1, Y2: Integer;
  NewRect: TRectangle;
begin
  SetLength(PalColors, length(PalColors) + 1);
  PalColors[ High(PalColors)] := Color;
  NewRect := TRectangle.Create;
  NewRect.BrushF.Style := bsSolid;
  Y1 := 1;
  X1 := (length(PalColors) div 2) * IHeigth + 1;
  if ((length(PalColors) mod 2) = 0) then
  begin
    if length(PalColors) > 1 then
      Dec(X1, IHeigth);
    if length(PalColors) > 0 then
      Y1 := IHeigth + 1;
  end;
  X2 := X1 + IHeigth - 1;
  Y2 := Y1 + IHeigth - 1;
  with NewRect do
  begin
    Points[0] := Point(X1, Y1);
    Points[0] := Point(X2, Y2);
    BrushF.Color := Color;
    PenF.Style := psSolid;
    Draw();
  end;
  PalRects.Add(NewRect);
end;

function TFPalette.GetIndex(X, Y: Integer): Integer;
begin
  Result := ((X + Abs(Trunc(PalRects.Items[0].Points[0].X)) - 1) div IHeigth) * 2
    + (Y div IHeigth);
end;

function TFPalette.Select(Index: Integer): TColor;
begin
  Result := $0;
  if Index > High(PalColors) then
    exit;
  Result := PalColors[Index];
  SelectedColor := Index;
  Draw;
  DoSelection(SelectedColor);
end;

procedure TFPalette.Delete(Index: Integer);
var
  i: Integer;
begin
  if PalRects.Count <= 1 then
    exit;
  PalRects.Delete(PalRects.Count - 1);
  for i := Index to High(PalColors) - 1 do
    PalColors[i] := PalColors[i + 1];
  SetLength(PalColors, length(PalColors) - 1);
  if SelectedColor = Index then
    SelectedColor := -1
  else
    Dec(SelectedColor);
  Draw;
end;

procedure TFPalette.LoadFromFile(Path: string);
var
  f: TextFile;
  i: Integer;
  s: string;
begin
  PalRects.Clear;
  SetLength(PalColors, 0);
  Assignfile(f, Path);
  Reset(f);
  Readln(f, s);
  for i := 1 to StrToInt(s) do
  begin
    Readln(f, s);
    AddColor(StringToColor(s));
  end;
end;

procedure TFPalette.SaveToFile(Path: string);
var
  f: TextFile;
  i: Integer;
begin
  Assignfile(f, Path);
  Rewrite(f);
  Writeln(f, PalRects.Count);
  for i := 0 to PalRects.Count - 1 do
    Writeln(f, ColorToString(PalColors[i]));
  closefile(f);
end;

function TFPalette.Scroll(Tag, PWidth: Integer): boolean;
var
  i, X: Integer;
begin
  Result := false;
  if ((PWidth > (PalRects.Items[PalRects.Count - 1] as TRectangle).Points[1].X) and
    (Tag = 1)) or ((PalRects.Items[0].Points[0].X > 0) and (Tag = -1)) then
    exit;
  Result := true;
  if Tag = 1 then
    X := -IHeigth
  else
    X := IHeigth;
  for i := 0 to PalRects.Count - 1 do
    PalRects.Items[i].Move(Point(X, 0));
  Draw;
end;

{ TRectangle }

procedure TRectangle.Move(P: TPoint);
var
  i: Integer;
begin
  for i := 0 to high(Points) do
    Points[i] := Point(Points[i].X + P.X, Points[i].Y + P.Y);
end;

procedure TRectangle.PaintShape(P: TPoint; CanvasOut: TCanvas);
begin
    CanvasOut.Rectangle(Points[0].X, Points[0].Y,
      P.X, P.Y);
end;

{ TPalRects }

function TPalRects.Add(Sender: TRectangle): Integer;
begin
  SetLength(List, length(List) + 1);
  List[High(List)] := Sender;
end;

procedure TPalRects.Clear;
var
  P: TFShape;
begin
  if List = nil then
    exit;
  for P in List do
    P.Free;
  SetLength(List, 0);
end;

procedure TPalRects.Delete(Index: Integer);
  var
  i: Integer;
begin
  if List <> nil then
  begin
    List[Index].Free;
    for i := Index to High(List) - 1 do
      List[i] := List[i + 1];
    SetLength(List, length(List) - 1);
  end;
end;

procedure TPalRects.DrawAll(CanvasOut: TCanvas);
var
  P: TRectangle;
begin
  if List <> nil then
  begin
    for P in List do
        P.PaintShape(P.Points[1], CanvasOut);
      end;
  end;

function TPalRects.GetCount: Integer;
begin
  Result := length(List);
end;

function TPalRects.GetItem(Index: Integer): TRectangle;
begin
  Result := List[Index];
end;

procedure TPalRects.PutItem(Index: Integer; Item: TRectangle);
begin
  List[Index] := Item;
end;

end.
