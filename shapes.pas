﻿unit shapes;

interface

uses Windows, SysUtils, Classes, Graphics, Types, math, sListView, scale,
  Dialogs, TransMemo, Forms, ExtCtrls;

type
  TRPen = object // Свойства для Обводки
  private
    procedure SetStyle(const Value: TPenStyle);
    procedure SetWidth(const Value: Integer);
  public
    Color: TColor;
    FWidth: Integer;
    FStyle: TPenStyle;
    Mode: TPenMode;
    property PenWidth: Integer read FWidth write SetWidth;
    property Style: TPenStyle read FStyle write SetStyle;
  end;

type
  TRBrush = record // Свойства для фона
    Color: TColor;
    Style: TBrushStyle;
  end;

type
  TPoints = array of TDoublePoint;

Type
  TFShape = class
  private
    PenF: TRPen;
    BrushF: TRBrush;
    TextColor: TColor;
    procedure SetStyle(CanvasOut: TCanvas); virtual;
    // Установка свойств фигуры на канваc
  published
    property PenWidth: Integer read PenF.FWidth write PenF.FWidth;
    property PenStyle: TPenStyle read PenF.FStyle write PenF.FStyle;
    property PenColor: TColor write PenF.Color;
    property BrushColor: TColor write BrushF.Color;
    property TextFontColor: TColor write TextColor;
  public
    Points: TPoints;
    ExtraPoints: TPoints;
    Zoomer: TZoomer;
    Selected: Boolean;
    DrawIt: Boolean;
    ShapeRegion: HRGN;
    ShapeName: String;
    BtnTag: Integer;
    procedure Draw(CanvasOut: TCanvas); virtual; abstract;
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); virtual;
      abstract;
    function GetLeft: Double; virtual; abstract;
    function GetRight: Double; virtual; abstract;
    function GetUp: Double; virtual; abstract;
    function GetDown: Double; virtual; abstract;
    function GetRegion: HRGN; virtual; abstract;
    function GetPointsCount: Integer;
    procedure DrawKeyPoints(CanvasOut: TCanvas); virtual;
    procedure DrawExtraKeyPoints(CanvasOut: TCanvas); virtual;
    function GetKeyPointIndex(X, Y: Integer): Integer; virtual; abstract;
    function GetExtraPointIndex(X, Y: Integer): Integer; virtual; abstract;
    procedure EditKeyPoint(dX, dY, Cube: Integer); virtual; abstract;
    procedure EditExtraPoint(dX, dY, Cube: Integer); virtual; abstract;
    procedure Move(P: TDoublePoint); virtual; abstract;
    function GetSaveData: string; virtual;
    function GetSVGData: string; virtual; abstract;
    procedure LoadSavedData(Data: TStringList); virtual;
    procedure PrepareForCopy;
    constructor Create(sZoomer: TZoomer);
  end;

Type
  TFLineShape = class(TFShape)
  public
    procedure Draw(CanvasOut: TCanvas); override;
    function GetLeft: Double; override;
    function GetRight: Double; override;
    function GetUp: Double; override;
    function GetDown: Double; override;
    function GetKeyPointIndex(X, Y: Integer): Integer; override;
    function GetExtraPointIndex(X, Y: Integer): Integer; override;
    function GetSaveData: string; override;
    procedure EditKeyPoint(dX, dY, Cube: Integer); override;
    procedure EditExtraPoint(dX, dY, Cube: Integer); override;
    procedure Move(P: TDoublePoint); override;
    procedure LoadSavedData(Data: TStringList); override;
    constructor Create(sZoomer: TZoomer; CanvasOut: TCanvas; PenWidth: Integer;
      PenStyle: TPenStyle); virtual;
  end;

Type
  TPencil = class(TFLineShape)
  public
    function GetLeft: Double; override;
    function GetRight: Double; override;
    function GetUp: Double; override;
    function GetDown: Double; override;
    function GetRegion: HRGN; override;
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    procedure Move(P: TDoublePoint); override;
    procedure Draw(CanvasOut: TCanvas); override;
    function GetSVGData: string; override;
  end;

Type
  TStandartShape = class(TFLineShape)
  published
    property BrushStyle: TBrushStyle read BrushF.Style write BrushF.Style;
  public
    function GetSaveData: string; override;
    constructor Create(sZoomer: TZoomer; CanvasOut: TCanvas; PenWidth: Integer;
      PenStyle: TPenStyle; BrushStyle: TBrushStyle);
  end;

type
  TLine = class(TFLineShape)
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    function GetSVGData: string; override;
  end;

type
  TRectangle = class(TStandartShape)
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    function GetSVGData: string; override;
  end;

type
  TEllipse = class(TStandartShape)
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    function GetSVGData: string; override;
  end;

type
  TRoundRect = class(TStandartShape) // Прямоугольник с закругленными краями
  private
    FRoundValueX: Double;
    FRoundValueY: Double; // Радиус закругления
  published
    property RoundValueX: Double write FRoundValueX;
    property RoundValueY: Double write FRoundValueY;
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    function GetSaveData: String; override;
    procedure LoadSavedData(Data: TStringList); override;
    function GetSVGData: string; override;
    constructor Create(sZoomer: TZoomer; CanvasOut: TCanvas; PenWidth: Integer;
      PenStyle: TPenStyle; BrushStyle: TBrushStyle;
      RoundValueX, RoundValueY: Double);

  end;

type
  TPolyline = class(TFLineShape)
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
  end;

type
  TPolygon = class(TStandartShape)
  private
    FAngleCount: Integer;
  published
    property AngleCount: Integer write FAngleCount;
  public
    StartPoint: TPoint;
    R: real;
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    procedure Move(P: TDoublePoint); override;
    function GetSaveData: String; override;
    procedure LoadSavedData(Data: TStringList); override;
    procedure EditKeyPoint(dX, dY, Cube: Integer); override;
    function GetSVGData: string; override;
  end;

type
  TCustomPolygon = class(TStandartShape)
  public
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    function GetRegion: HRGN; override;
    function GetSVGData: string; override;
  end;

type
  TStarSHape = class(TStandartShape)
  private
    FAngleCount: Integer;
  published
    property AngleCount: Integer write FAngleCount;
  public
    StartPoint: TPoint;
    R1, R2: real;
    procedure PaintShape(P: TDoublePoint; CanvasOut: TCanvas); override;
    procedure EditKeyPoint(dX, dY, Cube: Integer); override;
    procedure Move(P: TDoublePoint); override;
    function GetRegion: HRGN; override;
    function GetSaveData: String; override;
    procedure LoadSavedData(Data: TStringList); override;
    procedure DrawExtraKeyPoints(CanvasOut: TCanvas); override;
    procedure EditExtraPoint(dX, dY, Cube: Integer); override;
    function GetSVGData: string; override;
  end;

type
  TText = class(TFLineShape)
  private
    FFontColor: TColor;
    FFontStyle: Integer;
    FFontSize: Integer;
    FFontName: String;
    FFontHeight: Integer;
    FFontWidth: Integer;
    FStringCount: Integer;
    FText: String;
    TextList: TStringList;
  published
    property TextFontStyle: Integer read FFontStyle write FFontStyle;
    property TextFontColor: TColor read FFontColor write FFontColor;
    property TextFontSize: Integer read FFontSize write FFontSize;
    property TextFontName: String read FFontName write FFontName;
    property Text: String read FText write FText;
  public
    procedure Draw(CanvasOut: TCanvas); override;
    // procedure EditKeyPoint(dX, dY, Cube: Integer); override;
    // procedure Move(P: TDoublePoint); override;
    function GetRegion: HRGN; override;
    function GetSaveData: String; override;
    procedure LoadSavedData(Data: TStringList); override;
    procedure DrawKeyPoints(CanvasOut: TCanvas); override;
    function GetSVGData: string; override;
    // procedure TextHide(sender: TObject);
    procedure TextToCanvas(sender: TObject);
    // procedure TextRedact(sender: TObject);
    // procedure TextMemoCreate(AForm: TForm; ARect: TREct; PAintBox: TPaintBox);
    constructor Create(sZoomer: TZoomer; TextColor: TColor; CanvasOut: TCanvas;
      TextSize: Integer; TextName: String; TextStyle: Integer); overload;
  end;

type // Shapes
  TPropsItem = (piPen, piBrush, piRound);
  TPropsList = set of TPropsItem;

const // Shapes
  // MaxPropsList = [piPen, piBrush, piRound];
  DefaultIconsCOunt = 16; // Изменить в случае добавления иконок

type
  TMEvent = (eFree, eMove, eEdit, eEditExtra);

type
  TFShapeList = class // Список фигур
  private
    List: array of TFShape;
    SelectedList: array of TFShape;
    function GetItem(Index: Integer): TFShape;
    procedure PutItem(Index: Integer; Item: TFShape);
    function GetCount: Integer;
  public
    SelRect: TRectangle;
    FullImageRect: TRectangle;
    Table: TsListView;
    ReInvalidate: Boolean;
    EditEvent: TMEvent;
    Cube: Integer;
    CurShapeEdit: TFShape;
    // function GetFullRect(SelectedOnly: Boolean = false): TDoubleRect;
    function Add(sender: TFShape): Integer;
    function AddSelected(sender: TFShape): Integer;
    procedure Delete(Index: Integer);
    function ChangeCoords(sender: TFShape): Integer;
    procedure Swap(Index1, Index2: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TFShape read GetItem write PutItem;
    procedure Clear;
    procedure DrawAll(CanvasOut: TCanvas);
    function GetFullRect(SelectedOnly: Boolean = false): TDoubleRect;
    procedure MoveSelected(dX, dY, BX, BY: Integer; tmpPos: TPoint);
    procedure UpdateLayers;
    procedure AddShapes(T: TStringList; Zoomer: TZoomer);
    function GetAllSaveData: TStringList;
    function GetAllSVGData(Zoomer: TZoomer; ImgWidth, ImgHeight: Integer)
      : TStringList;
    procedure PrepareForCopy;

    constructor Create(sZoomer: TZoomer; CanvasOut: TCanvas);
  end;

type
  KindOfShape = class of TFShape;

type
  TShapesArray = record
    SType: KindOfShape;
    Properties: TPropsList;
  end;

type
  TEvent = procedure of object;

function GetShapeIndex(s: string): Integer;

const
  Delim = '|';

var
  ShapesArray: array of TShapesArray;
  RefreshCanvas: TEvent;

var
  a: Integer;
procedure SetImageSize(shapes: TFShapeList; Zoomer: TZoomer);
procedure CheckAllRegions(shapes: TFShapeList; SelectRect: TREct);
function MoveAllShapes(shapes: TFShapeList; tStart: TPoint; tEnd: TPoint)
  : TDoublePoint;
procedure SetSelectStyle(CanvasOut: TCanvas);

implementation

function SVGColor(GetColor: TColor): string;
var
  PenColorString: String;
begin
  PenColorString := ColorToString(GetColor);
  Delete(PenColorString, 1, 2);
  Result := PenColorString;
end;

function ReplaceDelim(s: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to length(s) do
    if s[i] = Delim then
      Result := Result + #13#10
    else
      Result := Result + s[i];
end;

function GetShapeIndex(s: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to high(ShapesArray) do
    if ShapesArray[i].SType.ClassName = s then
    begin
      Result := i;
      exit;
    end;
end;

function CheckRect(LU, RD, T, T2: TPoint): Boolean;
Var
  Temp, R1, R2: TREct;
Begin
  Result := false;
  R1 := Rect(LU.X, LU.Y, RD.X, RD.Y);
  R2 := Rect(T.X, T.Y, T2.X, T2.Y);
  If Not UnionRect(Temp, R1, R2) Then
    exit;
  If (Temp.Right - Temp.Left <= R1.Right - R1.Left + R2.Right - R2.Left) And
    (Temp.Bottom - Temp.Top <= R1.Bottom - R1.Top + R2.Bottom - R2.Top) Then
    Result := true;
End;

procedure TFShapeList.MoveSelected(dX, dY, BX, BY: Integer; tmpPos: TPoint);
var
  P: TFShape;
  T, E: Integer;
begin
  if Count = 0 then
    exit;
  if EditEvent = eFree then
  begin
    EditEvent := eMove;
    for P in List do
    begin
      T := P.GetKeyPointIndex(BX, BY);
      E := P.GetExtraPointIndex(BX, BY);
      if T <> -1 then
      begin
        Cube := T;
        EditEvent := eEdit;
        CurShapeEdit := P;
        break;
      end;
      if E <> -1 then
      begin
        Cube := E;
        EditEvent := eEditExtra;
        CurShapeEdit := P;
        break;
      end;
    end;
  end;
  case EditEvent of
    eMove:
      begin
        for P in List do
          if P.Selected then
            P.Move(DoublePoint(dX - tmpPos.X / P.Zoomer.zoom,
              dY - tmpPos.Y / P.Zoomer.zoom));
      end;
    eEdit:
      for P in List do
        if P.Selected then
          CurShapeEdit.EditKeyPoint(dX, dY, Cube);
    eEditExtra:
      for P in List do
        if P.Selected then
          CurShapeEdit.EditExtraPoint(dX - tmpPos.X, dY - tmpPos.Y, Cube);
  end;
end;

function TFShapeList.GetAllSaveData: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  Result.Append('Test');
  for i := 0 to Count - 1 do
    Result.Add(Items[i].GetSaveData);
end;

function TFShapeList.GetAllSVGData(Zoomer: TZoomer;
  ImgWidth, ImgHeight: Integer): TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  Result.Append('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="'
    + inttostr(ImgWidth) + '" height="' + inttostr(ImgHeight) + '">');
  for i := 0 to Count - 1 do
    Result.Add(Items[i].GetSVGData);
  Result.Add('</svg>')
end;

function TFShapeList.GetCount: Integer;
begin
  Result := length(List);
end;

procedure SetSelectStyle(CanvasOut: TCanvas);
begin
  with CanvasOut do
  begin
    Pen.Width := 1;
    Pen.Color := clBlack;
    Pen.Mode := pmNotXor;
    Brush.Style := bsClear;
  end;
end;

procedure CheckAllRegions(shapes: TFShapeList; SelectRect: TREct);
var
  i: Integer;
begin
  for i := 0 to High(shapes.List) do
  begin
    shapes.List[i].ShapeRegion := shapes.List[i].GetRegion;
    if RectInRegion(shapes.List[i].ShapeRegion, SelectRect) then
    begin
      shapes.List[i].Selected := true;
      shapes.AddSelected(shapes.List[i]);
    end
    else
    begin
      shapes.List[i].Selected := false;
    end;
  end;
end;

procedure SetImageSize(shapes: TFShapeList; Zoomer: TZoomer);
var
  T: TDoubleRect;
begin
  if length(shapes.List) = 0 then
    exit;
  T := shapes.GetFullRect;
  with Zoomer do
  begin
    FullImageSize.L := Round(T.L { * {zoom } );
    if FullImageSize.L > Zoomer.Offset.X then
      FullImageSize.L := Zoomer.Offset.X;
    FullImageSize.R := Round(T.R { * zoom } );
    // if FullImageSize.R < PBSize.X then
    // FullImageSize.R := PBSize.X;
    FullImageSize.U := Round(T.U { * zoom } );
    if FullImageSize.U > Zoomer.Offset.X then
      FullImageSize.U := Zoomer.Offset.X;
    FullImageSize.D := Round(T.D { * zoom } );
    // if FullImageSize.D < PBSize.Y then
    // FullImageSize.D := PBSize.Y;
    // SetLength(shapes.FullImageRect.Points, 2);
  end;
end;

function MoveAllShapes(shapes: TFShapeList; tStart: TPoint; tEnd: TPoint)
  : TDoublePoint;
var
  i: Integer;
  T: TDoubleRect;
  MovePoint1, MovePoint2: TDoublePoint;
begin
  for i := 0 to high(shapes.List) do
  begin
    MovePoint1 := shapes.List[i].Points[0];
    MovePoint2 := shapes.List[i].Points[1];
    if tStart.X > tEnd.Y then
    begin
      MovePoint1.X := MovePoint1.X - abs(tStart.X - tEnd.X);
      MovePoint2.X := MovePoint2.X - abs(tStart.X - tEnd.X);
    end
    else
    begin
      MovePoint1.X := MovePoint1.X + abs(tEnd.X - tStart.X);
      MovePoint2.X := MovePoint2.X + abs(tEnd.X - tStart.X);
    end;
    if tStart.Y > tEnd.Y then
    begin
      MovePoint1.Y := MovePoint1.Y - abs(tStart.Y - tEnd.Y);
      MovePoint2.Y := MovePoint2.Y - abs(tStart.Y - tEnd.Y);
    end
    else
    begin
      MovePoint1.Y := MovePoint1.Y + abs(tEnd.Y - tStart.Y);
      MovePoint2.Y := MovePoint2.Y + abs(tEnd.Y - tStart.Y);
    end;
  end;
end;

{ TFShapeList }

function TFShapeList.AddSelected(sender: TFShape): Integer;
begin
  SetLength(SelectedList, length(SelectedList) + 1);
  SelectedList[High(SelectedList)] := sender;
end;

procedure TFShapeList.AddShapes(T: TStringList; Zoomer: TZoomer);
var
  i: Integer;
  NewShape: TFShape;
  Data: TStringList;
begin
  Data := TStringList.Create;
  for i := 0 to T.Count - 1 do
  begin
    Data.Text := ReplaceDelim(T[i]);
    if GetShapeIndex(Data.Values['ClassName']) = -1 then
      continue;
    NewShape := ShapesArray[GetShapeIndex(Data.Values['ClassName'])
      ].SType.Create(Zoomer);
    NewShape.LoadSavedData(Data);
    Add(NewShape);
    Data.Clear;
  end;
  Data.Free;
end;

function TFShapeList.ChangeCoords(sender: TFShape): Integer;
begin
  List[High(List)] := sender;
end;

procedure TFShapeList.Clear;
var
  P: TFShape;
begin
  if List = nil then
    exit;
  for P in List do
    P.Free;
  SetLength(List, 0);
end;

constructor TFShapeList.Create(sZoomer: TZoomer; CanvasOut: TCanvas);
begin
  SelRect := TRectangle.Create(sZoomer, CanvasOut, 1, psDot, bsClear);
  // FullImageRect := TRectangle.Create(Zoomer);
  // with SelRect do
  // begin
  // PenF.Style := psDot;
  // PenF.Mode := pmNotXor;
  // end;
end;

function TFShapeList.Add(sender: TFShape): Integer;
begin
  SetLength(List, length(List) + 1);
  List[High(List)] := sender;
end;

procedure TFShapeList.Delete(Index: Integer);
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

procedure TFShapeList.DrawAll(CanvasOut: TCanvas);
var
  P: TFShape;
  Test: TColor;
begin
  if List <> nil then
  begin
    for P in List do
      if P.DrawIt then
      begin
        P.Draw(CanvasOut);
        SetSelectStyle(CanvasOut);
      end;
    for P in List do
      if P.Selected then
      begin
        P.DrawKeyPoints(CanvasOut);
        P.DrawExtraKeyPoints(CanvasOut);
      end;
    SelRect.Draw(CanvasOut);
    Test := CanvasOut.Font.Color;
    // FullImageRect.Draw(CanvasOut);
  end;
end;

function TFShapeList.GetFullRect(SelectedOnly: Boolean): TDoubleRect;
var
  i: Integer;
  X: Double;
begin
  Result.L := maxint;
  Result.R := -maxint;
  Result.U := maxint;
  Result.D := -maxint;
  for i := 0 to high(List) do
  begin
    X := Items[i].GetLeft;
    if X < Result.L then
      Result.L := X;
    X := Items[i].GetRight;
    if X > Result.R then
      Result.R := X;
    X := Items[i].GetUp;
    if X < Result.U then
      Result.U := X;
    X := Items[i].GetDown;
    if X > Result.D then
      Result.D := X;
  end;
end;

function TFShapeList.GetItem(Index: Integer): TFShape;
begin
  Result := List[Index];
end;

procedure TFShapeList.PrepareForCopy;
var
  i: Integer;
begin
  if List <> nil then
  begin
    for i := 0 to Count - 1 do
      Items[i].Selected := false;
    with Items[Count - 1] do
    begin
      for i := 0 to High(Points) do
      begin
        Points[i].X := Points[i].X + 15;
        Points[i].Y := Points[i].Y - 15;
      end;
      Selected := true;
    end;
  end;
end;

procedure TFShapeList.PutItem(Index: Integer; Item: TFShape);
begin
  List[Index] := Item;
end;

procedure TFShapeList.Swap(Index1, Index2: Integer);
var
  tmp: TFShape;
begin
  tmp := List[Index1];
  List[Index1] := List[Index2];
  List[Index2] := tmp;
end;

procedure TFShapeList.UpdateLayers;
var
  i: Integer;
begin
  ReInvalidate := false;
  Table.Clear;
  with Table do
    for i := 0 to high(List) do
    begin
      AddItem(List[i].ClassName, Columns[0]);
      Items[Items.Count - 1].ImageIndex := DefaultIconsCOunt + List[i].BtnTag;;
      Items[Items.Count - 1].Checked := List[i].DrawIt;
      Items[Items.Count - 1].Selected := List[i].Selected;
    end;
  Table.Refresh;
  ReInvalidate := true;
end;

{ TFShape }
constructor TFShape.Create;
begin
  PenF.Color := clBlack;
  PenF.PenWidth := 1;
  PenF.Style := psSolid;
  PenF.Mode := pmCopy;
  BrushF.Color := clWhite;
  BrushF.Style := bsClear;
  Zoomer := sZoomer;
  Selected := false;
  SetLength(ExtraPoints, 2);
end;

procedure TFShape.DrawExtraKeyPoints(CanvasOut: TCanvas);
begin
  // Добавление доп. точки для фигур
end;

procedure TFShape.DrawKeyPoints(CanvasOut: TCanvas);
var
  T, T2: TPoint;
  i: Integer;
begin
  with CanvasOut do
  begin
    T := Zoomer.Wrld2Scrn(DoublePoint(GetLeft, GetUp));
    T2 := Zoomer.Wrld2Scrn(DoublePoint(GetRight, GetDown));
    Pen.Style := psDot;
    Brush.Style := bsClear;
    Rectangle(T.X - 1, T.Y - 1, T2.X + 1, T2.Y + 1);
    Pen.Mode := pmNotXor;
    Pen.Style := psSolid;
    Pen.Mode := pmCopy;
    Brush.Color := clWhite;
    Brush.Style := BSSolid;
    for i := 0 to High(Points) do
    begin
      T := Zoomer.Wrld2Scrn(Points[i]);
      Rectangle(T.X - 3, T.Y - 3, T.X + 4, T.Y + 4);
    end;
  end;
end;

function TFShape.GetPointsCount: Integer;
begin
  Result := length(Points);
end;

function TFShape.GetSaveData: string;
begin
  Result := 'ClassName=' + ClassName + Delim + 'PenWidth=' +
    inttostr(PenF.FWidth) + Delim + 'PenColor=' + ColorToString(PenF.Color) +
    Delim + 'PenStyle=' + inttostr(Ord(PenF.Style)) + Delim + 'BrushColor=' +
    ColorToString(BrushF.Color) + Delim + 'Start.X=' + Floattostr(Points[0].X) +
    Delim + 'Start.Y=' + Floattostr(Points[1].Y) + Delim + 'DrawIt=' +
    BoolToStr(DrawIt) + Delim + 'PointsCount=' + inttostr(High(Points)) + Delim
    + 'BtnTag=' + inttostr(BtnTag);
end;

procedure TFShape.SetStyle(CanvasOut: TCanvas);
begin
  with CanvasOut do
  begin
    Pen.Color := PenF.Color;
    Pen.Width := PenF.PenWidth;
    Pen.Style := PenF.Style;
    // Pen.Mode := PenF.Mode;
    Pen.Mode := pmCopy;
    Brush.Color := BrushF.Color;
    Brush.Style := BrushF.Style;
  end;
end;

{ TPencil }

function TPencil.GetDown: Double;
var
  i: Integer;
begin
  Result := Points[0].Y;
  for i := 1 to High(Points) do
    if Points[i].Y > Result then
      Result := Points[i].Y + 1;
end;

function TPencil.GetLeft: Double;
var
  i: Integer;
begin
  Result := Points[0].X;
  for i := 1 to High(Points) do
    if Points[i].X < Result then
      Result := Points[i].X
end;

function TPencil.GetRegion: HRGN;
var
  i: Integer;
  PencilRgn: HRGN;
  LinePos: array of TPoint;
begin
  SetLength(LinePos, 2 * length(Points) - 1);
  for i := 0 to High(Points) do
    LinePos[i] := Zoomer.Wrld2Scrn(Points[i]);
  for i := high(Points) downto 0 do
    LinePos[2 * high(Points) - 1 - i] :=
      ExpandPoint(Zoomer.Wrld2Scrn(Points[i]), 1);
  Result := CreatePolygonRgn(LinePos[0], high(LinePos), WINDING);
end;

function TPencil.GetRight: Double;
var
  i: Integer;
begin
  Result := Points[0].X;
  for i := 1 to High(Points) do
    if Points[i].X > Result then
      Result := Points[i].X + 1;
end;

function TPencil.GetSVGData: string;
var
  s: String;
  i: Integer;
begin;
  for i := 0 to High(Points) do
    s := s + ' ' + Floattostr(Zoomer.Wrld2Scrn(Points[i]).X) + ',' +
      Floattostr(Zoomer.Wrld2Scrn(Points[i]).Y);
  Result := '<polyline points="' + s + '" stroke-width="' +
    inttostr(PenF.FWidth) + '" stroke="' + SVGColor(PenF.Color) +
    '" fill="white"/>'
end;

function TPencil.GetUp: Double;
var
  i: Integer;
begin
  Result := Points[0].Y;
  for i := 1 to High(Points) do
    if Points[i].Y < Result then
      Result := Points[i].Y;
end;

procedure TPencil.Move(P: TDoublePoint);
var
  i: Integer;
begin
  for i := 0 to high(Points) do
    Points[i] := DoublePoint(Points[i].X + P.X, Points[i].Y + P.Y);
end;

procedure TPencil.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
begin
  SetLength(Points, length(Points) + 1);
  Points[High(Points)] := P;
  with CanvasOut, Zoomer do
  begin
    SetStyle(CanvasOut);
    if length(Points) = 1 then
      // MoveTo(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y);
      LineTo(Wrld2Scrn(P).X, Wrld2Scrn(P).Y);
  end;
end;

procedure TPencil.Draw(CanvasOut: TCanvas);
var
  P: TDoublePoint;
begin
  SetStyle(CanvasOut);
  with CanvasOut, Zoomer do
  begin
    if length(Points) > 1 then
    begin
      Pixels[Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y] := PenF.Color;
      MoveTo(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y);
      for P in Points do
        LineTo(Wrld2Scrn(P).X, Wrld2Scrn(P).Y);
    end;
  end;
end;

{ TFStandartShape }

constructor TFLineShape.Create(sZoomer: TZoomer; CanvasOut: TCanvas;
  PenWidth: Integer; PenStyle: TPenStyle);
begin
  PenF.Color := CanvasOut.Pen.Color;
  PenF.PenWidth := PenWidth;
  PenF.Style := PenStyle;
  BrushF.Style := bsClear;
  Zoomer := sZoomer;
end;

procedure TFLineShape.Draw(CanvasOut: TCanvas);
begin
  if DrawIt then
    PaintShape(Points[high(Points)], CanvasOut);
end;

{ TFLine }

function TLine.GetRegion: HRGN;
var
  LinePos: Array [0 .. 3] of TPoint;
begin
  LinePos[0] := ExpandPoint(Zoomer.Wrld2Scrn(Points[0]), 1);
  LinePos[1] := Zoomer.Wrld2Scrn(Points[0]);
  LinePos[2] := Zoomer.Wrld2Scrn(Points[1]);
  LinePos[3] := ExpandPoint(Zoomer.Wrld2Scrn(Points[1]), 1);
  Result := CreatePolygonRgn(LinePos[0], 4, WINDING);
end;

function TLine.GetSVGData: string;
begin
  Result := '<line x1="' + Floattostr(Zoomer.Wrld2Scrn(Points[0]).X) + '" y1="'
    + Floattostr(Zoomer.Wrld2Scrn(Points[0]).Y) + '" x2="' +
    Floattostr(Zoomer.Wrld2Scrn(Points[1]).X) + '" y2="' +
    Floattostr(Zoomer.Wrld2Scrn(Points[1]).Y) + '" stroke-width="' +
    inttostr(PenF.FWidth) + '" stroke="' + SVGColor(PenF.Color) + '"/>'
end;

procedure TLine.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
begin
  SetStyle(CanvasOut);
  with CanvasOut, Zoomer do
  begin
    MoveTo(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y);
    LineTo(Wrld2Scrn(P).X, Wrld2Scrn(P).Y);
  end;
end;
{ TRectangle }

function TRectangle.GetRegion: HRGN;
begin
  with Zoomer do
  begin
    Result := createRectRgn(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(Points[1]).X, Wrld2Scrn(Points[1]).Y);
  end;

end;

function TRectangle.GetSVGData: string;
begin
  Result := '<rect x="' + Floattostr(Zoomer.Wrld2Scrn(Points[0]).X) + '" y="' +
    Floattostr(Zoomer.Wrld2Scrn(Points[0]).Y) + '" width="' +
    Floattostr(Zoomer.Wrld2Scrn(Points[1]).X - Zoomer.Wrld2Scrn(Points[0]).X) +
    '" height="' + Floattostr(Zoomer.Wrld2Scrn(Points[1]).Y -
    Zoomer.Wrld2Scrn(Points[0]).Y) + '" style="fill:' + SVGColor(BrushF.Color) +
    ';stroke:' + SVGColor(PenF.Color) + ';stroke-width:' +
    inttostr(PenF.FWidth) + '" />'
end;

procedure TRectangle.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
begin
  SetStyle(CanvasOut);
  with Zoomer do
    CanvasOut.Rectangle(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(P).X, Wrld2Scrn(P).Y);
end;
{ TFEllipse }

function TEllipse.GetRegion: HRGN;
begin
  with Zoomer do
    Result := CreateEllipticRgn(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(Points[1]).X, Wrld2Scrn(Points[1]).Y);
end;

function TEllipse.GetSVGData: string;
begin

end;

procedure TEllipse.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
begin
  SetStyle(CanvasOut);
  with Zoomer do
    CanvasOut.Ellipse(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(P).X, Wrld2Scrn(P).Y);
end;
{ TRoundRect }

constructor TRoundRect.Create(sZoomer: TZoomer; CanvasOut: TCanvas;
  PenWidth: Integer; PenStyle: TPenStyle; BrushStyle: TBrushStyle;
  RoundValueX, RoundValueY: Double);
begin
  PenF.Color := CanvasOut.Pen.Color;
  PenF.PenWidth := PenWidth;
  PenF.Style := PenStyle;
  Zoomer := sZoomer;
  BrushF.Color := CanvasOut.Brush.Color;
  BrushF.Style := BrushStyle;
  FRoundValueX := RoundValueX;
  FRoundValueY := RoundValueY;
end;

function TRoundRect.GetRegion: HRGN;
begin
  with Zoomer do
  begin
    Result := createRectRgn(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(Points[1]).X, Wrld2Scrn(Points[1]).Y);
  end;
end;

function TRoundRect.GetSaveData: String;
begin
  Result := inherited + Delim + 'RoundValueX=' + Floattostr(FRoundValueX) +
    Delim + 'RoundValueY=' + Floattostr(FRoundValueY);
end;

function TRoundRect.GetSVGData: string;
begin
  Result := '<rect x="' + Floattostr(Zoomer.Wrld2Scrn(Points[0]).X) + '" y="' +
    Floattostr(Zoomer.Wrld2Scrn(Points[0]).Y) + '" rx="' +
    Floattostr(FRoundValueX) + '" ry="' + Floattostr(FRoundValueY) + '" width="'
    + Floattostr(Zoomer.Wrld2Scrn(Points[1]).X - Zoomer.Wrld2Scrn(Points[0]).X)
    + '" height="' + Floattostr(Zoomer.Wrld2Scrn(Points[1]).Y -
    Zoomer.Wrld2Scrn(Points[0]).Y) + '" style="fill:' + SVGColor(BrushF.Color) +
    ';stroke:' + SVGColor(PenF.Color) + ';stroke-width:' +
    inttostr(PenF.FWidth) + '" />'
end;

procedure TRoundRect.LoadSavedData(Data: TStringList);
begin
  inherited;
  if Data.Values['RoundValueX'] <> '' then
    FRoundValueX := strtofloat(Data.Values['RoundValueX']);
  if Data.Values['RoundValueY'] <> '' then
    FRoundValueY := strtofloat(Data.Values['RoundValueY']);
end;

procedure TRoundRect.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
begin
  SetStyle(CanvasOut);
  with Zoomer do
    CanvasOut.RoundRect(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(P).X, Wrld2Scrn(P).Y, Round(FRoundValueX), Round(FRoundValueY));
end;

function TPolyline.GetRegion: HRGN;
var
  i: Integer;
  LinePos: array of TPoint;
begin
  SetLength(LinePos, 2 * length(Points) - 1);
  for i := 0 to High(Points) do
    LinePos[i] := Zoomer.Wrld2Scrn(Points[i]);
  for i := High(Points) downto 0 do
    LinePos[2 * length(Points) - 1 - i] :=
      ExpandPoint(Zoomer.Wrld2Scrn(Points[i]), 1);
  Result := CreatePolygonRgn(LinePos[0], length(LinePos), WINDING);
end;

procedure TPolyline.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
var
  i: Integer;
  PolyPoints: array of TPoint;
begin
  SetStyle(CanvasOut);
  SetLength(PolyPoints, length(Points));
  with Zoomer do
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
  CanvasOut.Polyline(PolyPoints)
end;

{ TPolygon }

procedure TPolygon.EditKeyPoint(dX, dY, Cube: Integer);
begin
  inherited;
  R := sqrt(sqr(Points[Cube].X - StartPoint.X) +
    sqr(Points[Cube].Y - StartPoint.Y));
end;

function TPolygon.GetRegion: HRGN;
var
  i: Integer;
  PolyPoints: array of TPoint;
begin
  SetLength(PolyPoints, length(Points));
  with Zoomer do
  begin
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
  end;
  Result := CreatePolygonRgn(PolyPoints[0], high(PolyPoints), WINDING)
end;

function TPolygon.GetSaveData: String;
begin
  Result := inherited + Delim + 'AngleCount=' + inttostr(FAngleCount) + Delim +
    'StartPointPX=' + inttostr(StartPoint.X) + Delim + 'StartPointPY=' +
    inttostr(StartPoint.Y) + Delim + 'Radius=' + Floattostr(R);
end;

function TPolygon.GetSVGData: string;
var
  s: String;
  i: Integer;
begin
  s := '"';
  for i := 0 to High(Points) do
    s := s + ' ' + Floattostr(Zoomer.Wrld2Scrn(Points[i]).X) + ',' +
      Floattostr(Zoomer.Wrld2Scrn(Points[i]).Y);
  s := s + '"';
  Result := '<polygon points=' + s + 'fill="' + SVGColor(BrushF.Color) +
    '" stroke-width="' + inttostr(PenF.FWidth) + '" stroke=' +
    SVGColor(PenF.Color) + '/>'
end;

procedure TPolygon.LoadSavedData(Data: TStringList);
begin
  inherited;
  if Data.Values['AngleCount'] <> '' then
    FAngleCount := strtoint(Data.Values['AngleCount']);
  if Data.Values['StartPointPX'] <> '' then
    StartPoint.X := strtoint(Data.Values['StartPointPX']);
  if Data.Values['StartPointPY'] <> '' then
    StartPoint.Y := strtoint(Data.Values['StartPointPY']);
  if Data.Values['Radius'] <> '' then
    R := strtofloat(Data.Values['Radius']);
end;

procedure TPolygon.Move(P: TDoublePoint);
begin
  inherited;
  StartPoint := Zoomer.Wrld2Scrn(DoublePoint(StartPoint.X + P.X,
    StartPoint.Y + P.Y));
end;

procedure TPolygon.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
var
  i: Integer;
  a, da: real;
  PolyPoints: array of TPoint;
begin
  SetStyle(CanvasOut);
  da := 360 / FAngleCount;
  SetLength(Points, FAngleCount + 1);
  a := 90;
  for i := 0 to FAngleCount do
  begin
    Points[i].X := StartPoint.X + Round(R * cos(a * pi / 180));
    Points[i].Y := StartPoint.Y - Round(R * sin(a * pi / 180));
    a := a + da;
  end;
  Points[FAngleCount].X := Points[0].X;
  Points[FAngleCount].Y := Points[0].Y;
  SetLength(PolyPoints, length(Points));
  with Zoomer do
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
  CanvasOut.Polygon(PolyPoints);
end;

{ TCustomPolygon }

function TCustomPolygon.GetRegion: HRGN;
var
  i: Integer;
  PolyPoints: array of TPoint;
begin
  SetLength(PolyPoints, length(Points));
  with Zoomer do
  begin
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
  end;
  Result := CreatePolygonRgn(PolyPoints[0], high(PolyPoints), WINDING)
end;

function TCustomPolygon.GetSVGData: string;
var
  s: String;
  i: Integer;
begin
  s := '"';
  for i := 0 to High(Points) do
    s := s + ' ' + Floattostr(Zoomer.Wrld2Scrn(Points[i]).X) + ',' +
      Floattostr(Zoomer.Wrld2Scrn(Points[i]).Y);
  s := s + '"';
  Result := '<polygon points=' + s + 'fill="' + SVGColor(BrushF.Color) +
    '" stroke-width="' + inttostr(PenF.FWidth) + '" stroke="' +
    SVGColor(PenF.Color) + '"/>'
end;

procedure TCustomPolygon.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
var
  i: Integer;
  PolyPoints: array of TPoint;
begin
  SetStyle(CanvasOut);
  SetLength(PolyPoints, length(Points));
  with CanvasOut, Zoomer do
  begin
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
    Polygon(PolyPoints);
  end;
end;

procedure TFLineShape.EditExtraPoint(dX, dY, Cube: Integer);
begin
  ExtraPoints[Cube].X := dX / Zoomer.zoom;
  ExtraPoints[Cube].Y := dY / Zoomer.zoom;
end;

procedure TFLineShape.EditKeyPoint(dX, dY, Cube: Integer);
begin
  Points[Cube].X := dX / Zoomer.zoom;
  Points[Cube].Y := dY / Zoomer.zoom;
end;

function TFLineShape.GetDown: Double;
var
  i: Integer;
begin
  Result := Points[0].Y;
  for i := 1 to High(Points) do
    if Points[i].Y > Result then
      Result := Points[i].Y + 1;
end;

function TFLineShape.GetExtraPointIndex(X, Y: Integer): Integer;
var
  i: Integer;
  T: TPoint;
begin
  Result := -1;
  for i := 0 to high(ExtraPoints) do
  begin
    T := Zoomer.Wrld2Scrn(ExtraPoints[i]);
    if CheckRect(Point(X, Y), Point(X, Y), Point(T.X - 3, T.Y - 3),
      Point(T.X + 4, T.Y + 4)) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TFLineShape.GetKeyPointIndex(X, Y: Integer): Integer;
var
  i: Integer;
  T: TPoint;
begin
  Result := -1;
  for i := 0 to high(Points) do
  begin
    T := Zoomer.Wrld2Scrn(Points[i]);
    if CheckRect(Point(X, Y), Point(X, Y), Point(T.X - 3, T.Y - 3),
      Point(T.X + 4, T.Y + 4)) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TFLineShape.GetLeft: Double;
var
  i: Integer;
begin
  Result := Points[0].X;
  for i := 1 to High(Points) do

    if Points[i].X < Result then
      Result := Points[i].X
end;

function TFLineShape.GetRight: Double;
var
  i: Integer;
begin
  Result := Points[0].X;
  for i := 1 to High(Points) do
    if Points[i].X > Result then
      Result := Points[i].X + 1;
end;

function TFLineShape.GetSaveData: string;
var
  i: Integer;
begin
  Result := inherited;
  for i := 0 to High(Points) do
    // Result := Result + Format(
    // '%sX%d=%g%sY%d=%g', [Delim, i, Points[i].X, Delim, i, Points[i].Y]);
    // Result := Result + Format(
    // ' X%d=%g Y%d=%g', [i, Points[i].X, i, Points[i].Y]);
    Result := Result + Delim + 'X' + inttostr(i) + '=' + Floattostr(Points[i].X)
      + Delim + 'Y' + inttostr(i) + '=' + Floattostr(Points[i].Y);
end;

function TFLineShape.GetUp: Double;
var
  i: Integer;
begin
  Result := Points[0].Y;
  for i := 1 to High(Points) do
    if Points[i].Y < Result then
      Result := Points[i].Y;
end;

procedure TFLineShape.LoadSavedData(Data: TStringList);
var
  K, i: Integer;
begin
  inherited;
  K := strtoint(Data.Values['PointsCount']);
  SetLength(Points, K + 1);
  for i := 0 to K do
  begin
    Points[i].X := strtofloat(Data.Values['X' + inttostr(i)]);
    Points[i].Y := strtofloat(Data.Values['Y' + inttostr(i)]);
  end;
end;

procedure TFShape.LoadSavedData(Data: TStringList);
begin
  PenF.FWidth := strtoint(Data.Values['PenWidth']);
  if Data.Values['PenStyle'] <> '' then
    PenF.Style := TPenStyle(strtoint(Data.Values['PenStyle']));
  PenF.Color := StringToColor(Data.Values['PenColor']);
  if Data.Values['BrushStyle'] <> '' then
    BrushF.Style := TBrushStyle(strtoint(Data.Values['BrushStyle']));
  if Data.Values['BrushColor'] <> '' then
    BrushF.Color := StringToColor(Data.Values['BrushColor']);
  SetLength(Points, 1);
  if Data.Values['BtnTag'] <> '' then
    BtnTag := strtoint(Data.Values['BtnTag']);
  Points[0].X := strtofloat(Data.Values['Start.X']);
  Points[0].Y := strtofloat(Data.Values['Start.Y']);
  DrawIt := strtoBool(Data.Values['DrawIt']);
end;

procedure TFShape.PrepareForCopy;
var
  i: Integer;
begin
  for i := 0 to High(Points) do
  begin
    Points[i].X := Points[i].X + 15;
    Points[i].Y := Points[i].Y - 15;
  end;
  Selected := true;
end;

procedure TFLineShape.Move(P: TDoublePoint);
var
  i: Integer;
begin
  for i := 0 to high(Points) do
    Points[i] := DoublePoint(Points[i].X + P.X, Points[i].Y + P.Y);
end;

procedure AddShape(SType: KindOfShape; Props: TPropsList);
begin
  SetLength(ShapesArray, length(ShapesArray) + 1);
  ShapesArray[high(ShapesArray)].SType := SType;
  ShapesArray[high(ShapesArray)].Properties := Props;
end;

{ TStandartShape }

constructor TStandartShape.Create(sZoomer: TZoomer; CanvasOut: TCanvas;
  PenWidth: Integer; PenStyle: TPenStyle; BrushStyle: TBrushStyle);
begin
  PenF.Color := CanvasOut.Pen.Color;
  PenF.PenWidth := PenWidth;
  PenF.Style := PenStyle;
  Zoomer := sZoomer;
  BrushF.Color := CanvasOut.Brush.Color;
  BrushF.Style := BrushStyle;
end;

function TStandartShape.GetSaveData: string;
begin
  Result := inherited + Delim + 'BrushStyle=' + inttostr(Ord(BrushF.Style));
end;

{ TRPen }

procedure TRPen.SetStyle(const Value: TPenStyle);
begin
  if FStyle = psDot then
    FStyle := Value;
  FStyle := Value;
end;

procedure TRPen.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

{ TStarSHape }

procedure TStarSHape.DrawExtraKeyPoints(CanvasOut: TCanvas);
var
  T, T2: TPoint;
  i: Integer;
begin
  T := Zoomer.Wrld2Scrn(DoublePoint(GetLeft, GetUp));
  T2 := Zoomer.Wrld2Scrn(DoublePoint(GetRight, GetDown));
  SetLength(ExtraPoints, 2);
  ExtraPoints[0] := Zoomer.Scrn2Wrld(T.X, T.Y);
  ExtraPoints[1] := Zoomer.Scrn2Wrld(T2.X, T2.Y);
  CanvasOut.Rectangle(T.X - 3, T.Y - 3, T.X + 4, T.Y + 4);
  CanvasOut.Rectangle(T2.X - 3, T2.Y - 3, T2.X + 4, T2.Y + 4);
end;

procedure TStarSHape.EditExtraPoint(dX, dY, Cube: Integer);
begin
  ExtraPoints[Cube].X := (ExtraPoints[Cube].X + dX) / Zoomer.zoom;
  ExtraPoints[Cube].Y := (ExtraPoints[Cube].Y + dY) / Zoomer.zoom;
  R1 := R1 + dX;
  R2 := R1 / 2;
end;

procedure TStarSHape.EditKeyPoint(dX, dY, Cube: Integer);
begin
  inherited;
  if Cube mod 2 = 0 then
  begin
    R1 := sqrt(sqr(Points[Cube].X - StartPoint.X) +
      sqr(Points[Cube].Y - StartPoint.Y));
  end
  else
    R2 := sqrt(sqr(Points[Cube].X - StartPoint.X) +
      sqr(Points[Cube].Y - StartPoint.Y));

end;

function TStarSHape.GetRegion: HRGN;
var
  i: Integer;
  PolyPoints: array of TPoint;
begin
  SetLength(PolyPoints, length(Points));
  with Zoomer do
  begin
    for i := 0 to high(Points) do
    begin
      PolyPoints[i] := Wrld2Scrn(Points[i]);
    end;
  end;
  Result := CreatePolygonRgn(PolyPoints[0], high(PolyPoints), WINDING)
end;

function TStarSHape.GetSaveData: String;
begin
  Result := inherited + Delim + 'AngleCount=' + inttostr(FAngleCount) + Delim +
    'StartPointPX=' + inttostr(StartPoint.X) + Delim + 'StartPointPY=' +
    inttostr(StartPoint.Y) + Delim + 'R1=' + Floattostr(R1) + Delim + 'R2=' +
    Floattostr(R2);
end;

function TStarSHape.GetSVGData: string;
var
  s: String;
  i: Integer;
begin
  s := '"';
  for i := 0 to High(Points) do
    s := s + ' ' + Floattostr(Zoomer.Wrld2Scrn(Points[i]).X) + ',' +
      Floattostr(Zoomer.Wrld2Scrn(Points[i]).Y);
  s := s + '"';
  Result := '<polygon points=' + s + 'fill="' + SVGColor(BrushF.Color) +
    '" stroke-width="' + inttostr(PenF.FWidth) + '" stroke="' +
    SVGColor(PenF.Color) + '"/>'
end;

procedure TStarSHape.LoadSavedData(Data: TStringList);
begin
  inherited;
  if Data.Values['AngleCount'] <> '' then
    FAngleCount := strtoint(Data.Values['AngleCount']);
  if Data.Values['StartPointPX'] <> '' then
    StartPoint.X := strtoint(Data.Values['StartPointPX']);
  if Data.Values['StartPointPY'] <> '' then
    StartPoint.Y := strtoint(Data.Values['StartPointPY']);
  if Data.Values['R1'] <> '' then
    R1 := strtofloat(Data.Values['R1']);
  if Data.Values['R2'] <> '' then
    R2 := strtofloat(Data.Values['R2']);
end;

procedure TStarSHape.Move(P: TDoublePoint);
begin
  inherited;
  StartPoint := Zoomer.Wrld2Scrn(DoublePoint(StartPoint.X + P.X,
    StartPoint.Y + P.Y));
end;

procedure TStarSHape.PaintShape(P: TDoublePoint; CanvasOut: TCanvas);
var
  PolyPoints: array of TPoint; // массив вершин звезды
  yO, xO: real;
  i, K: Integer;
  a: real;
begin
  SetStyle(CanvasOut);
  begin
    a := 270; // начальный угол поворота
    K := FAngleCount * 2;
    SetLength(Points, K + 1); // размер массива
    xO := StartPoint.X;
    yO := StartPoint.Y; // точки центра
    for i := 0 to K do
    begin
      if (i mod 2 = 0) then
      begin
        Points[i].X := xO + (R1) * cos(a * pi / 180); // радиус 1
        Points[i].Y := yO + (R1) * sin(a * pi / 180); //
      end
      else
      begin
        Points[i].X := xO + Round(R2 * cos(a * pi / 180)); // радиус 2
        Points[i].Y := yO + Round(R2 * sin(a * pi / 180));
      end;
      a := a + 360 / (K);
    end;
  end;
  SetLength(PolyPoints, length(Points));
  for i := 0 to high(Points) do
    PolyPoints[i] := Zoomer.Wrld2Scrn(Points[i]);
  // PolyPoints[k + 1].X := PolyPoints[0].X;
  // PolyPoints[k + 1].Y := PolyPoints[0].Y;
  CanvasOut.Polygon(PolyPoints); // рисем закрашенную звезду
end;

{ TText }

function TText.GetRegion: HRGN;
begin
  with Zoomer do
  begin
    Result := createRectRgn(Wrld2Scrn(Points[0]).X, Wrld2Scrn(Points[0]).Y,
      Wrld2Scrn(Points[1]).X, Wrld2Scrn(Points[1]).Y);
  end;
end;

function TText.GetSaveData: String;
var
  i: Integer;
begin
  Result := 'ClassName=' + ClassName + Delim + 'TextFontStyle=' +
    inttostr(FFontStyle) + Delim + 'TextFontSize=' + inttostr(FFontSize) + Delim
    + 'TextFontName=' + FFontName + Delim + 'TextFontColor=' +
    ColorToString(FFontColor) + Delim + 'Start.X=' + Floattostr(Points[0].X) +
    Delim + 'Start.Y=' + Floattostr(Points[0].Y) + Delim + 'DrawIt=' +
    BoolToStr(DrawIt) + Delim + 'PointsCount=' + inttostr(High(Points)) + Delim
    + 'BtnTag=' + inttostr(BtnTag) + Delim + 'StringsCount=' +
    inttostr(TextList.Count - 1) + Delim;
  for i := 0 to TextList.Count - 1 do
    Result := Result + inttostr(i) + '=' + TextList.Strings[i] + Delim;
end;

function TText.GetSVGData: string;
begin
    Result := '<text x="' + FloatToStr(Zoomer.Wrld2Scrn(Points[0]).X) +
  '" y="' + FloatToStr(Zoomer.Wrld2Scrn(Points[0]).Y + FFontHeight)+
  '" font-size="' + IntToStr(FFontSize) +
  '" fill="' + SVGColor(FFontColor) + '">' + FText + '</text>'; 
end;

procedure TText.LoadSavedData(Data: TStringList);
var
  i: Integer;
  TextStrings: TStringList;
begin
  FFontName := Data.Values['TextFontName'];
  if Data.Values['TextFontColor'] <> '' then
    FFontColor := StringToColor(Data.Values['TextFontColor']);
  if Data.Values['TextFontSize'] <> '' then
    FFontSize := strtoint(Data.Values['TextFontSize']);
  if Data.Values['TextFontStyle'] <> '' then
    FFontStyle := strtoint(Data.Values['TextFontStyle']);
  if Data.Values['BtnTag'] <> '' then
    BtnTag := strtoint(Data.Values['BtnTag']);
  if Data.Values['StringsCount'] <> '' then
  Begin
    TextStrings := TStringList.Create;
    for i := 0 to MaxInt do
      if Data.Values[inttostr(i)] <> '' then
        TextStrings.Add(Data.Values[inttostr(i)]);
    FText := TextStrings.Text;
  End;
  SetLength(Points, 2);
  Points[0].X := strtofloat(Data.Values['Start.X']);
  Points[0].Y := strtofloat(Data.Values['Start.Y']);
  DrawIt := strtoBool(Data.Values['DrawIt']);

end;

procedure TText.TextToCanvas(sender: TObject);
begin
  DrawIt := true;
  Selected := false;
end;

constructor TText.Create(sZoomer: TZoomer; TextColor: TColor;
  CanvasOut: TCanvas; TextSize: Integer; TextName: String; TextStyle: Integer);
begin
  Zoomer := sZoomer;
  FFontName := TextName;
  FFontStyle := TextStyle;
  FFontColor := TextColor;
  FFontSize := Round(TextSize * Zoomer.zoom);
end;

procedure TText.Draw(CanvasOut: TCanvas);
var
  i, K: Integer;
begin
  TextList := TStringList.Create;
  TextList.Text := FText;
  if TextList.Count = 0 then
    exit;
  FFontWidth := CanvasOut.TextWidth(TextList.Strings[0]);
  K := 0;
  for i := 0 to TextList.Count - 1 do
    // if i > 1 then
    if CanvasOut.TextWidth(TextList.Strings[K]) < CanvasOut.TextWidth
      (TextList.Strings[i]) then
      K := i;
  CanvasOut.Font.Name := FFontName;
  CanvasOut.Font.Style := TFontStyles(byte(FFontStyle));
  CanvasOut.Font.Color := FFontColor;
  CanvasOut.Font.Size := Round(FFontSize * Zoomer.zoom);
  FFontWidth := CanvasOut.TextWidth(TextList.Strings[K]);
  FFontHeight := CanvasOut.TextHeight(FText);
  FStringCount := TextList.Count;
  for i := 0 to TextList.Count - 1 do
    CanvasOut.TextOut(Zoomer.Wrld2Scrn(Points[0]).X + 4,
      Zoomer.Wrld2Scrn(Points[0]).Y + 2 + (i) * FFontHeight,
      TextList.Strings[i]);
end;

procedure TText.DrawKeyPoints(CanvasOut: TCanvas);
var
  i, K: Integer;
  StringWidth: Integer;
begin
  if FText = '' then
    exit;
  Points[1].X := Points[0].X + FFontWidth + 10;
  Points[1].Y := Points[0].Y + (FFontHeight * FStringCount);
  inherited;
end;

initialization

AddShape(TPencil, [piPen]);
AddShape(TLine, [piPen]);
AddShape(TRectangle, [piPen, piBrush]);
AddShape(TEllipse, [piPen, piBrush]);
AddShape(TRoundRect, [piPen, piBrush, piRound]);
AddShape(TPolyline, [piPen]);
AddShape(TPolygon, [piPen, piBrush]);
AddShape(TCustomPolygon, [piPen, piBrush]);
AddShape(TStarSHape, [piPen]);
AddShape(TText, [piPen]);

end.
