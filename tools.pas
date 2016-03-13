unit tools;

interface

uses Windows, SysUtils, Classes, Graphics, shapes, Types, Controls, Spin,
  StdCtrls, math, ExtCtrls, scale, typinfo, Editors, Generics.Collections, Forms, Dialogs, TransMemo;

type
  TFTool = class
  private
    NewShape: TFShape; // ������� ������
    MainEditor: MainPropEditor;
    CanvasOut: TCanvas;
    shapes: TFShapeList;
  public
    isActive: Boolean;
    Zoomer: TZoomer;
    AddLayer: Boolean;
    BtnTag: Integer;
    PaintBox: TPaintBox;
    Form: TForm;
    procedure MouseDown(X, Y: Integer); virtual; abstract;
    procedure MouseMove(X, Y: Integer); virtual; abstract;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState; Button: TMouseButton);
      virtual; abstract;
    procedure RegisterUI(PanelOut: TWinControl); virtual;
    procedure UnRegisterUI(PanelOut: TWinControl); virtual;
    constructor Create(CanvasSource: TCanvas;
      ShapesSource: TFShapeList); virtual;
  end;

type
  TFHandMove = class(TFTool)
  private
    tPos: TPoint;
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
    procedure RegisterUI(PanelOut: TWinControl);
  end;

type
  TFSelectTool = class(TFTool)
  private
    PropertyList: array of PPropInfo;
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
    procedure CreatePropertyList;
    procedure RegisterUI(PanelOut: TWinControl); override;
    procedure UnRegisterUI(PanleOut: TWinControl); override;
  end;

type
  TFZoom = class(TFTool) { Free Class }
  private
    ZoomValueEdit: ZoomValueEditor;
  public
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
    procedure RegisterUI(PanelOut: TWinControl); override;
  end;

type
  TFZoomIn = class(TFZoom)
  public
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFZoomOut = class(TFZoom)
  public
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFRectZoom = class(TFZoom)
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
  end;

type
  TFRedactTool = class(TFTool)
  public
    StartMoveP: TPoint;
    tmpPos: TPoint;
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
    procedure RegisterUI(PanelOut: TWinControl); override;
  end;

type
  TFLinesTool = class(TFTool)
  private
    PenWidthEdit: PenWidthEditor;
    PenStyleEdit: PenStyleEditor;
  public
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
    procedure GetShapePropeties; virtual;
    procedure RegisterUI(PanelOut: TWinControl); override;
    procedure UnRegisterUI(PanelOut: TWinControl); override;
    // constructor Create(CanvasSource: TCanvas;
    // ShapesSource: TFShapeList); override;
  end;

type
  TPencilTool = class(TFLinesTool)
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
  end;

type
  TFStandartShapeTool = class(TFLinesTool)
  private
    BrushStyleEdit: BrushStyleEditor;
    procedure GetShapePropeties; override;
  public
    procedure RegisterUI(PanelOut: TWinControl); override;
  end;

type
  TFPolyLineTool = class(TFLinesTool)
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
  end;

type
  TFLineTool = class(TFLinesTool)
  public
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFRectTool = class(TFStandartShapeTool)
  public
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFEllipseTool = class(TFStandartShapeTool)
  public
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFRoundRectTool = class(TFStandartShapeTool)
  private
    RoundValueEditX, RoundValueEditY: RoundPropsEditor;
  public
    procedure RegisterUI(PanelOut: TWinControl); override;
    procedure MouseDown(X, Y: Integer); override;
  end;

type
  TFPolygonTool = class(TFStandartShapeTool)
  private
    AngleCountEdit: AngelCountEditor;
  public
    procedure RegisterUI(PanelOut: TWinControl); override;
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Button: TMouseButton); overload;
  end;

type
  TFCustomPolygon = class(TFStandartShapeTool)
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState;
      Button: TMouseButton); override;
  end;

type
  TFStarTool = class(TFStandartShapeTool)
  private
    AngleCountEdit: AngelCountEditor;
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Button: TMouseButton); overload;
    procedure RegisterUI(PanelOut: TWinControl); override;
  end;

type
  TFTextTool = class(TFTool)
  private
    //TextTRMemo: TTransparentMemo;
    FontEditor: TFontEditor;
  public
    procedure MouseDown(X, Y: Integer); override;
    procedure MouseMove(X, Y: Integer); override;
    procedure MouseUp(X, Y: Integer; Shift: TShiftState; Button: TMouseButton); override;
    procedure RegisterUI(PanelOut: TWinControl); override;
  end;

type
  KindOfTool = class of TFTool;

type
  TNewTool = record // ���������� ������ �����������
    Name: string;
    IconPath: String;
    SType: KindOfTool;
  end;

type
  TClassArray = class of MainPropEditor;

Var
  ToolsArray: array of TNewTool; // ������ ������������
  FuncDict: TDictionary<String, TClassArray>;

implementation

const
  MaxZoom = 10;
  MinZoom = 0.01;

const
  PLeft = 8;
  PTop = 4;

var
  NextTop: Integer; // ���������� Top ��� �������� ����������

function GetClassIndex(CLassName: string): Integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to High(ToolsArray) do
    if CLassName = ToolsArray[i].SType.CLassName then
    begin
      result := i;
      exit;
    end;
end;

function GetNextTop(X: Integer): Integer;
// ��������� Top ��� �������� ���������� � ������ ��� ���������
begin
  result := NextTop;
  Inc(NextTop, X + PTop);
end;

// ��������� �������� ��������� ��� ����� ����: ����� / ���������
procedure SetCommonView(Control, PanelOut: TWinControl; ControlLabel: TLabel);
begin
  with Control do
  begin
    ControlLabel.Top := GetNextTop(Height) + 3;
    Top := ControlLabel.Top - 3;
    ControlLabel.Left := PLeft;
    Left := PanelOut.Width - PLeft - Width;
    Parent := PanelOut;
    ControlLabel.Parent := PanelOut;
  end;
end;

{ TFTool }

constructor TFTool.Create(CanvasSource: TCanvas; ShapesSource: TFShapeList);
begin
  CanvasOut := CanvasSource;
  shapes := ShapesSource;
end;

// ��������� � ������ ����� �� ������ � ������� �� �����������
{
  constructor TFLinesTool.Create(CanvasSource: TCanvas;
  ShapesSource: TFShapeList);
  begin
  inherited;

  end; }

procedure TFLinesTool.GetShapePropeties;
begin

end;

procedure TFTool.RegisterUI(PanelOut: TWinControl);
begin

end;

procedure TFTool.UnRegisterUI(PanelOut: TWinControl);
begin
  MainEditor.FreeAllProps(PanelOut);
end;

// �������� ����������� �� ��������� ������ ��������
procedure TFLinesTool.RegisterUI(PanelOut: TWinControl);
begin
  PenWidthEdit := PenWidthEditor.Create(PanelOut, shapes);
  PenStyleEdit := PenStyleEditor.Create(PanelOut, shapes);
end;

procedure TFLinesTool.UnRegisterUI(PanelOut: TWinControl);
var
  i: Integer;
begin
  inherited;
  for i := 0 to PanelOut.ControlCount - 1 do
    PanelOut.Controls[0].Free;
end;

{ TPencilTool }
procedure TPencilTool.MouseDown(X, Y: Integer);
begin
  NewShape := TPencil.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle);
  SetLength(NewShape.Points, 1);
  NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

procedure TPencilTool.MouseMove(X: Integer; Y: Integer);
begin
  if isActive then
  begin
    NewShape.PaintShape(Zoomer.Scrn2Wrld(X, Y), CanvasOut);
    SetImageSize(shapes, Zoomer);
    Zoomer.SetScrolls;
    PaintBox.Invalidate
  end;
end;

procedure TPencilTool.MouseUp(X: Integer; Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  if isActive then
  begin
    isActive := false;
    shapes.ChangeCoords(NewShape);
    shapes.Items[shapes.Count - 1].BtnTag := GetClassIndex(self.CLassName);
    AddLayer := True;
    NewShape.DrawIt := True;
    NewShape.Selected := True;
  end;
end;

{ TFlinesTool }
procedure TFLineTool.MouseDown(X: Integer; Y: Integer);
begin
  NewShape := TLine.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle);
  GetShapePropeties;
  SetLength(NewShape.Points, 2);
  NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

{ TFStandartShapeExTool }
procedure TFStandartShapeTool.RegisterUI(PanelOut: TWinControl);
begin
  // inherited;
  PenWidthEdit := PenWidthEditor.Create(PanelOut, shapes);
  PenStyleEdit := PenStyleEditor.Create(PanelOut, shapes);
  BrushStyleEdit := BrushStyleEditor.Create(PanelOut, shapes);
end;

procedure TFStandartShapeTool.GetShapePropeties;
begin

end;

{ TFRectTool }
procedure TFRectTool.MouseDown(X: Integer; Y: Integer);
begin
  NewShape := TRectangle.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle, BrushStyleEdit.GetBrushStyle);
  GetShapePropeties;
  SetLength(NewShape.Points, 2);
  NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

{ TFEllipseTool }
procedure TFEllipseTool.MouseDown(X: Integer; Y: Integer);
begin
  NewShape := TEllipse.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle, BrushStyleEdit.GetBrushStyle);
  GetShapePropeties;
  SetLength(NewShape.Points, 2);
  NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

{ TFRoundRectTool }
procedure TFRoundRectTool.MouseDown(X: Integer; Y: Integer);
begin
  NewShape := TRoundRect.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle, BrushStyleEdit.GetBrushStyle,
    RoundValueEditX.GetRoundValueX, RoundValueEditY.GetRoundValueY);
  GetShapePropeties; // ��������� ������� �� �����������
  SetLength(NewShape.Points, 2);
  NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
  (NewShape as TRoundRect).RoundValueX := RoundValueEditX.GetRoundValueX;
  (NewShape as TRoundRect).RoundValueY := RoundValueEditY.GetRoundValueY;
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

procedure TFRoundRectTool.RegisterUI(PanelOut: TWinControl);
begin
  inherited;
  RoundValueEditX := RoundPropsEditor.Create(PanelOut, shapes);
  RoundValueEditY := RoundPropsEditor.Create(PanelOut, shapes);
end;

{ Other }

procedure RegisterTool(sName, sIconPath: string; sSType: KindOfTool);
begin
  SetLength(ToolsArray, Length(ToolsArray) + 1);
  with ToolsArray[High(ToolsArray)] do
  begin
    Name := sName;
    IconPath := ExtractFilePath(Paramstr(0)) + sIconPath;
    SType := sSType;
  end;
end;

{ TPolyLineTool }

procedure TFPolyLineTool.MouseDown(X, Y: Integer);
begin
  if isActive then
  begin
    SetLength(NewShape.Points, Length(NewShape.Points) + 1);
    NewShape.Points[high(NewShape.Points)] := Zoomer.Scrn2Wrld(X, Y);
  end;
  if isActive = false then
  begin
    NewShape := TPolyLine.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
      PenStyleEdit.GetPenStyle);
    GetShapePropeties;
    SetLength(NewShape.Points, Length(NewShape.Points) + 2);
    NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
    shapes.Add(NewShape);
    isActive := True;
    NewShape.DrawIt := True;
  end;
end;

procedure TFPolyLineTool.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
var
  i: Integer;
begin
  if (Button = mbRight) then
  begin
    SetLength(NewShape.Points, Length(NewShape.Points) + 1);
    NewShape.Points[high(NewShape.Points)] := Zoomer.Scrn2Wrld(X, Y);
    shapes.ChangeCoords(NewShape);
    shapes.Items[shapes.Count - 1].BtnTag := GetClassIndex(self.CLassName);
    isActive := false;
    AddLayer := True;
    NewShape.DrawIt := True;
    for i := 0 to shapes.Count - 1 do
      shapes.Items[i].Selected := false;
    NewShape.Selected := True;
  end;
end;

{ TFPolygonTool }

procedure TFPolygonTool.MouseDown(X, Y: Integer);
begin
  NewShape := TPolygon.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle, BrushStyleEdit.GetBrushStyle);
  SetLength(NewShape.Points, 2);
  (NewShape as TPolygon).StartPoint := Point(X, Y);
  (NewShape as TPolygon).AngleCount := AngleCountEdit.GetAngleCount;
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

procedure TFPolygonTool.MouseMove(X, Y: Integer);
begin
  if isActive then
     begin
    (NewShape as TPolygon).R :=
      sqrt(sqr(X - (NewShape as TPolygon).StartPoint.X) +
      sqr(X - (NewShape as TPolygon).StartPoint.Y));
      PaintBox.Invalidate;
     end;
  inherited;
end;

procedure TFPolygonTool.MouseUp(X, Y: Integer; Button: TMouseButton);
begin
  if Button = mbLeft then
  begin
    shapes.ChangeCoords(NewShape);
    isActive := false;
  end;
end;

procedure TFPolygonTool.RegisterUI(PanelOut: TWinControl);
begin
  inherited;
  AngleCountEdit := AngelCountEditor.Create(PanelOut, shapes);
end;

{ TFCustomPolygon }

procedure TFCustomPolygon.MouseDown(X, Y: Integer);
begin
  if isActive then
  begin
    SetLength(NewShape.Points, Length(NewShape.Points) + 1);
    NewShape.Points[high(NewShape.Points)] := Zoomer.Scrn2Wrld(X, Y);
  end;
  if isActive = false then
  begin
    NewShape := TCustomPolygon.Create(Zoomer, CanvasOut,
      PenWidthEdit.GetPenWidth, PenStyleEdit.GetPenStyle,
      BrushStyleEdit.GetBrushStyle);
    GetShapePropeties; // ��������� ������� �� �����������
    SetLength(NewShape.Points, Length(NewShape.Points) + 2);
    NewShape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
    shapes.Add(NewShape);
    isActive := True;
    NewShape.DrawIt := True;
  end;
end;

procedure TFCustomPolygon.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  if (Button = mbRight) then
  begin
    SetLength(NewShape.Points, Length(NewShape.Points) + 1);
    NewShape.Points[high(NewShape.Points)] := Zoomer.Scrn2Wrld(X, Y);
    shapes.ChangeCoords(NewShape);
    // shapes.Items[shapes.Count - 1].BtnTag := GetClassIndex(self.CLassName);
    isActive := false;
    AddLayer := True;
    NewShape.DrawIt := True;
  end;
end;

{ TFHandMove }

procedure TFHandMove.MouseDown(X, Y: Integer);
begin
  tPos := Point(X, Y);
  isActive := True;
end;

procedure TFHandMove.MouseMove(X, Y: Integer);
begin
  if isActive then
  begin
    Dec(Zoomer.Offset.X, X - tPos.X);
    Dec(Zoomer.Offset.Y, Y - tPos.Y);
    tPos := Point(X, Y);
    // SetImageSize(shapes, Zoomer);
    Zoomer.SetScrolls;
    // if PtInRect(Zoomer.W2S(Zoomer.FullImageSize), Zoomer.Offset) then
    PaintBox.Invalidate;
  end;
end;

procedure TFHandMove.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
var
  T: TDoubleRect;
begin
  if isActive then
  begin
    isActive := false;
  end;
end;

procedure TFHandMove.RegisterUI(PanelOut: TWinControl);
begin

end;

{ TFZoom }

procedure TFZoom.MouseMove(X, Y: Integer);
begin
  { virtual }
end;

procedure TFZoom.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  { virtual }
end;

procedure TFZoom.RegisterUI(PanelOut: TWinControl);
begin
  ZoomValueEdit := ZoomValueEditor.Create(PanelOut);
end;

{ TFZoomIn }

procedure TFZoomIn.MouseDown(X, Y: Integer);
begin
  Zoomer.PBSize := Point(PaintBox.Width, PaintBox.Height);
  Zoomer.SetZoom(min(Zoomer.Zoom + (ZoomValueEdit.GetZoomValue / 100),
    MaxZoom), X, Y);
  PaintBox.Invalidate;
end;

{ TFZoomOut }

procedure TFZoomOut.MouseDown(X, Y: Integer);
begin
  Zoomer.PBSize := Point(PaintBox.Width, PaintBox.Height);
  Zoomer.SetZoom(max(Zoomer.Zoom - (ZoomValueEdit.GetZoomValue / 100),
    MinZoom), X, Y);
  PaintBox.Invalidate;
end;

{ TFRectZoom }

procedure TFRectZoom.MouseDown(X, Y: Integer);
begin
  if shapes.Count = 0 then
    exit;
  Zoomer.PBSize := Point(PaintBox.Width, PaintBox.Height);
  with shapes.SelRect do
  begin
    SetLength(Points, 2);
    Points[0] := Zoomer.Scrn2Wrld(X, Y);
    Points[1] := Zoomer.Scrn2Wrld(X, Y);
    DrawIt := True;
  end;
  isActive := True;
end;

procedure TFRectZoom.MouseMove(X, Y: Integer);
begin
  if isActive then
  begin
    shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    PaintBox.Invalidate;
  end;
end;

procedure TFRectZoom.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  if isActive then
  begin
    isActive := false;
    shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    shapes.SelRect.DrawIt := false;
    Zoomer.SetRectZoom(DoubleRect(shapes.SelRect.Points[0],
      shapes.SelRect.Points[1]));
  end;
end;

{ TFSelectTool }

procedure TFSelectTool.CreatePropertyList;
var
  i, j, n: Integer;
  found: Boolean;
  PropList: PPropList;
  ShapeDict: TDictionary<String, TClassArray>;
begin
  FuncDict := TDictionary<String, TClassArray>.Create();
  ShapeDict := TDictionary<String, TClassArray>.Create();
  with FuncDict do
  begin
    Add('PenWidth', PenWidthEditor);
    Add('PenStyle', PenStyleEditor);
    Add('BrushStyle', BrushStyleEditor);
    Add('RoundValueX', RoundPropsEditor);
    Add('RoundValueY', RoundPropsEditor);
    Add('AngleCount', AngelCountEditor);
    Add('TextFontName', TFontEditor);
  end;
  SetLength(PropertyList, 0);
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
    begin
      n := GetPropList(shapes.Items[i].ClassInfo, PropList);
      begin
        if not((Length(PropertyList) <> 0) and (n > Length(PropertyList))) then
        begin
          SetLength(PropertyList, n);
          for j := 0 to High(PropertyList) do
            PropertyList[j] := PropList^[j];
        end;
      end;
    end;
end;

procedure TFSelectTool.MouseDown(X, Y: Integer);
begin
  shapes.SelRect := TRectangle.Create(Zoomer, CanvasOut, 1, psDot, bsClear);
  with shapes.SelRect do
  begin
    SetLength(Points, 2);
    Points[0] := Zoomer.Scrn2Wrld(X, Y);
    Points[1] := Zoomer.Scrn2Wrld(X, Y);
    // CreatePropertyList;
    DrawIt := True;
  end;
  isActive := True;
end;

procedure TFSelectTool.MouseMove(X, Y: Integer);
var
  SelectRect: TRect;
begin
  if isActive then
  begin
    shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    SelectRect := Classes.Rect(Zoomer.Wrld2Scrn(shapes.SelRect.Points[0]),
      Zoomer.Wrld2Scrn(shapes.SelRect.Points[1]));
    CheckAllRegions(shapes, SelectRect);
    PaintBox.Refresh;
  end;
end;

procedure TFSelectTool.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
var
  i: Integer;
begin
  if isActive then
  begin
    shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    shapes.SelRect.DrawIt := false;
    CreatePropertyList;
    isActive := false;
    AddLayer := True;
  end;
end;

procedure TFSelectTool.RegisterUI(PanelOut: TWinControl);
var
  i: Integer;
begin
  if PropertyList <> nil then
  begin
    for i := 0 to Length(PropertyList) - 1 do
    begin
      if FuncDict.ContainsKey(PropertyList[i]^.Name) then
        FuncDict.ExtractPair(PropertyList[i]^.Name)
          .Value.Create(PanelOut, shapes);
    end;
  end;
end;

procedure TFSelectTool.UnRegisterUI(PanleOut: TWinControl);
begin
  MainEditor.FreeAllProps(PanleOut);
end;

{ TFRedactTool }

procedure TFRedactTool.MouseDown(X, Y: Integer);
var
  i: Integer;
begin
  isActive := True;
  tmpPos := Point(X, Y);
  AddLayer := false;
  shapes.EditEvent := eFree;
  StartMoveP := Point(X, Y);
  // for i := 0 to shapes.Count - 1 do
  // shapes.Items[i].MoveDirect := 0;
end;

procedure TFRedactTool.MouseMove(X, Y: Integer);
begin
  if isActive then
  begin
    shapes.MoveSelected(Round((X + Zoomer.Offset.X) * Zoomer.Zoom),
      Round((Y + Zoomer.Offset.Y) * Zoomer.Zoom),
      Round((StartMoveP.X) * Zoomer.Zoom), Round((StartMoveP.Y) * Zoomer.Zoom),
      tmpPos + Zoomer.Offset); // ��������� �����������
    tmpPos := Point(X, Y);
    PaintBox.Invalidate;
  end;
end;

procedure TFRedactTool.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  isActive := false;
  shapes.EditEvent := eFree;
  PaintBox.Invalidate;
end;

procedure TFRedactTool.RegisterUI(PanelOut: TWinControl);
begin

end;

{ TLinesTool }

procedure TFLinesTool.MouseMove(X, Y: Integer);
begin
  if isActive then
  begin
    NewShape.PaintShape(Zoomer.Scrn2Wrld(X, Y), CanvasOut);
    NewShape.Points[high(NewShape.Points)] := Zoomer.Scrn2Wrld(X, Y);
    shapes.ChangeCoords(NewShape);
    // SetImageSize(shapes, Zoomer);
    Zoomer.SetScrolls;
    PaintBox.Invalidate;
  end;
end;

procedure TFLinesTool.MouseUp(X, Y: Integer; Shift: TShiftState;
  Button: TMouseButton);
begin
  if Button <> mbLeft then
    exit;
  if isActive then
  begin
    NewShape.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    shapes.Items[shapes.Count - 1].BtnTag := GetClassIndex(self.CLassName);
    isActive := false;
    AddLayer := True;
    CheckAllRegions(shapes, Classes.Rect(Round(Zoomer.FullImageSize.L) - 1,
      Round(Zoomer.FullImageSize.U) - 1, Round(Zoomer.FullImageSize.L) - 1,
      Round(Zoomer.FullImageSize.U) - 1));
    NewShape.Selected := True;
  end;
end;

{ TFStarTool }

procedure TFStarTool.MouseDown(X, Y: Integer);
begin
  NewShape := TStarSHape.Create(Zoomer, CanvasOut, PenWidthEdit.GetPenWidth,
    PenStyleEdit.GetPenStyle, BrushStyleEdit.GetBrushStyle);
  SetLength(NewShape.Points, 2);
  (NewShape as TStarSHape).StartPoint := Point(X, Y);
  (NewShape as TStarSHape).AngleCount := AngleCountEdit.GetAngleCount;
  shapes.Add(NewShape);
  isActive := True;
  NewShape.DrawIt := True;
end;

procedure TFStarTool.MouseMove(X, Y: Integer);
begin
  if isActive then
  begin
    (NewShape as TStarSHape).R1 :=
      sqrt(sqr(X - (NewShape as TStarSHape).StartPoint.X) +
      sqr(Y - (NewShape as TStarSHape).StartPoint.Y));
    (NewShape as TStarSHape).R2 := (NewShape as TStarSHape).R1 / 2;
    PaintBox.Invalidate;
    inherited;
  end;
end;

procedure TFStarTool.MouseUp(X, Y: Integer; Button: TMouseButton);
begin
  if Button = mbLeft then
  begin
    shapes.ChangeCoords(NewShape);
    isActive := false;
  end;
end;

procedure TFStarTool.RegisterUI(PanelOut: TWinControl);
begin
  inherited;
  AngleCountEdit := AngelCountEditor.Create(PanelOut, shapes);
end;

{ TFTextTool }

procedure TFTextTool.MouseDown(X, Y: Integer);
var
  a: Word;
  State: TShiftState;
begin
   a := 0;
   NewShape := TText.Create(Zoomer, PaintBox.Canvas.Pen.Color, CanvasOut, FontEditor.GetFontSize, FontEditor.GetFontName, FontEditor.GetFontStyle);
   SetLength(NewShape.Points, 2);
   NewSHape.Points[0] := Zoomer.Scrn2Wrld(X, Y);
   NewSHape.Selected := True;
   shapes.Add(NewShape);
   FontEditor.EditText(nil, a, State);
   NewShape.Points[1].X  := NewShape.Points[0].X + CanvasOut.TextWidth((NewShape as TTExt).Text);
   NewShape.Points[1].Y  := NewShape.Points[0].Y + CanvasOut.TextHeight((NewShape as TTExt).Text);
   NewShape.DrawIt := True;
  (NewShape as TTExt).Draw(CanvasOut);
  AddLayer := True;
  isActive := True;
end;

procedure TFTextTool.MouseMove(X, Y: Integer);
begin
  if isActive then
    begin
    //shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    //PaintBox.Invalidate;
    end;
end;

procedure TFTextTool.MouseUp(X, Y: Integer; Shift: TShiftState; Button: TMouseButton);
var
  i: Integer;
  SelectRect: TRect;
  FontDialog: TFontDialog;
  bmp: TBitMap;
begin
  {if isActive then
  begin
    {//shapes.SelRect.Points[1] := Zoomer.Scrn2Wrld(X, Y);
    //shapes.SelRect.DrawIt := false;
    NewSHape.Points[1] := ;
    isActive := false;
    AddLayer := True;
        SelectRect := Rect(Round(shapes.SelRect.GetLeft),
        Round(shapes.SelRect.GetUp),
        Round(shapes.SelRect.GetRight),
        Round(shapes.SelRect.GetDown));
    (NewShape as TTExt).TextMemoCreate(Form, SelectRect, PaintBox);
    end;
    NewSHape.Selected := True;
    shapes.Add(NewShape); }
end;

procedure TFTextTool.RegisterUI(PanelOut: TWinControl);
begin
  inherited;
  FontEditor := TFontEditor.Create(PanelOut, shapes);
end;

initialization

RegisterTool('Select Figs', 'icons\cursor.png', TFSelectTool);
RegisterTool('HandMove', 'icons\handmove.png', TFHandMove);
RegisterTool('Redact Shapes', 'icons\move.png', TFRedactTool);
RegisterTool('Pen', 'icons\pencil.png', TPencilTool);
RegisterTool('Line', 'icons\line.png', TFLineTool);
RegisterTool('Rectangle', 'icons\rect.png', TFRectTool);
RegisterTool('Ellipse', 'icons\ellipse.png', TFEllipseTool);
RegisterTool('Round Rectangle', 'icons\roundrect.png', TFRoundRectTool);
RegisterTool('Polyline', 'icons\polyline.png', TFPolyLineTool);
RegisterTool('Polygon', 'icons\polygon.png', TFPolygonTool);
RegisterTool('Custom Polygon', 'icons\polygon.png', TFCustomPolygon);
RegisterTool('Zoom In', 'icons\zoomin.png', TFZoomIn);
RegisterTool('Zoom Out', 'icons\zoomout.png', TFZoomOut);
RegisterTool('Rect Zoom', 'icons\select.png', TFRectZoom);
RegisterTool('Star', 'icons\star.png', TFStarTool);
RegisterTool('Text', 'icons\...', TFTextTool);

end.
