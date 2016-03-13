unit Editors;

interface

Uses
  Windows, SysUtils, Classes, Graphics, Types, Controls, Spin,
  StdCtrls, math, ExtCtrls, scale, typinfo, shapes, Dialogs, TransMemo,
  sSpeedButton, Forms;

type
  MainPropEditor = class
  private
    shapes: TFShapeList;
  public
    procedure FreeAllProps(PanelOut: TWinControl);
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); virtual;
  end;

type
  PenWidthEditor = class(MainPropEditor)
  private
    PenWidthSpin: TSpinEdit;
    PenWidthLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure EditSelected(Sender: TObject);
    function GetPenWidth: Integer;
  end;

type
  PenStyleEditor = class(MainPropEditor)
  private
    PenStyleCombo: TComboBox;
    PenStyleLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure PenStyleDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure EditSelected(Sender: TObject);
    function GetPenStyle: TPenStyle;
  end;

type
  BrushStyleEditor = class(MainPropEditor)
  private
    BrushStyleCombo: TComboBox;
    BrushStyleLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure BrushStyleDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure EditSelected(Sender: TObject);
    function GetBrushStyle: TBrushStyle;
  end;

type
  RoundPropsEditor = class(MainPropEditor)
  private
    RoundValueSpin: TSpinEdit;
    RoundValueLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure EditSelected(Sender: TObject);
    function GetRoundValueX: Integer;
    function GetRoundValueY: Integer;
  end;

type
  AngelCountEditor = class(MainPropEditor)
  private
    AngleCountSpin: TSpinEdit;
    AngleCountLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure EditSelected(Sender: TObject);
    function GetAngleCount: Integer;
  end;

type
  ZoomValueEditor = class(MainPropEditor)
  private
    ZoomValueSpin: TSpinEdit;
    ZoomValueLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
    function GetZoomValue: Integer;
  end;

type
  TFontEditor = class(MainPropEditor)
  private
    // FontButton: TsSpeedButton;
    FontNameBox: TComboBox;
    FontNameLabel: TLabel;
    FontStyleBox: TComboBox;
    FontStyleLabel: TLabel;
    FontSizeSpin: TSpinEdit;
    FontSizeLabel: TLabel;
    FontDialog: TFontDialog;
    TextMemo: TMemo;
  public
    constructor Create(PanelOut: TWinControl; shapelist: TFShapeList); override;
    procedure EditSelected(Sender: TObject);
    procedure EditText(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditFontName(Sender: TObject);
    procedure EditFontStyle(Sender: TObject);
    procedure EditFontSize(Sender: TObject);
    function GetFontName: String;
    function GetFontStyle: Integer;
    function GetFontSize: Integer;
    function GetFont: TFont;
  end;

implementation

const
  PLeft = 8;
  PTop = 4;

var
  NextTop: Integer; // ���������� Top ��� �������� ����������
  Kind: Boolean;

function GetNextTop(X: Integer): Integer;
// ��������� Top ��� �������� ���������� � ������ ��� ���������
begin
  result := NextTop;
  Inc(NextTop, X + PTop);
end;

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

{ MainPropEditor }

constructor MainPropEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  shapes := shapelist;
end;

procedure MainPropEditor.FreeAllProps(PanelOut: TWinControl);
var
  i: Integer;
begin
  for i := 0 to PanelOut.ControlCount - 1 do
    PanelOut.Controls[0].Free;
end;

{ PenPropEditor }

constructor PenWidthEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  inherited;
  NextTop := PTop;
  PenWidthSpin := TSpinEdit.Create(nil);
  PenWidthLabel := TLabel.Create(nil);
  shapes := shapelist;
  with PenWidthSpin do
  begin
    PenWidthLabel.Caption := 'Pen Width:';
    Width := 60;
    MinValue := 1;
    MaxValue := 100;
    // if shapes.Count <> 0 then
    // Value := shapes.Items[shapes.Count - 1].PenWidth
    // else
    Value := MinValue;
    OnChange := EditSelected;
    SetCommonView(PenWidthSpin, PanelOut, PenWidthLabel);
    Inc(NextTop, PTop);
  end;
end;

{ BrushStyleEditor }

procedure BrushStyleEditor.BrushStyleDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  with TComboBox(Control).Canvas do
  begin
    if (TBrushStyle(Index) <> bsClear) then
    begin
      Brush.Style := TBrushStyle(Index);
      Brush.Color := clBlack;
      Pen.Color := clSilver;
      Rectangle(ARect);
    end
    else
    begin
      Brush.Color := clSilver;
      FrameRect(ARect);
    end;
  end;
end;

constructor BrushStyleEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  inherited;
  BrushStyleCombo := TComboBox.Create(nil);
  BrushStyleLabel := TLabel.Create(nil);
  BrushStyleLabel.Caption := 'Brush Style:';
  with BrushStyleCombo do
  begin
    Width := 90;
    Style := csOwnerDrawFixed;
    SetCommonView(BrushStyleCombo, PanelOut, BrushStyleLabel);
    OnDrawItem := BrushStyleDrawItem;
    OnChange := EditSelected;
    Items.DelimitedText := '"","","","","","","",""';
    ItemIndex := 0;
    if shapes.Count <> 0 then
      if shapes.Items[shapes.Count - 1].ClassParent = TStandartSHape then
        ItemIndex := Integer((shapes.Items[shapes.Count - 1] as TStandartSHape)
          .BrushStyle);
  end;
end;

procedure BrushStyleEditor.EditSelected;
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'BrushStyle', BrushStyleCombo.ItemIndex);
  RefreshCanvas;
end;

function BrushStyleEditor.GetBrushStyle: TBrushStyle;
begin
  result := TBrushStyle(BrushStyleCombo.ItemIndex);
end;

{ RoundPropsEditor }

constructor RoundPropsEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  inherited;
  RoundValueSpin := TSpinEdit.Create(nil);
  RoundValueLabel := TLabel.Create(nil);
  with RoundValueSpin do
  begin
    Width := 60;
    MinValue := 0;
    MaxValue := 1000000;
    Value := 50;
    OnChange := EditSelected;
    if not Kind then
      RoundValueLabel.Caption := 'RoundValueX'
    else
      RoundValueLabel.Caption := 'RoundValueY'
  end;
  SetCommonView(RoundValueSpin, PanelOut, RoundValueLabel);
  Kind := not Kind;
end;

procedure RoundPropsEditor.EditSelected;
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
    begin
      // if Kind then
      SetPropValue(shapes.Items[i], 'RoundValueX', RoundValueSpin.Value);
      // else
      SetPropValue(shapes.Items[i], 'RoundValueY', RoundValueSpin.Value);
    end;
  RefreshCanvas;
end;

function RoundPropsEditor.GetRoundValueX: Integer;
begin
  result := RoundValueSpin.Value;
end;

function RoundPropsEditor.GetRoundValueY: Integer;
begin
  result := RoundValueSpin.Value;
end;

{ AngelCountEditor }

constructor AngelCountEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  inherited;
  AngleCountSpin := TSpinEdit.Create(nil);
  AngleCountLabel := TLabel.Create(nil);
  with AngleCountSpin do
  begin
    AngleCountLabel.Caption := 'Angle Count:';
    Width := 60;
    MinValue := 3;
    MaxValue := 100;
    Value := 4;
    OnChange := EditSelected;
    SetCommonView(AngleCountSpin, PanelOut, AngleCountLabel);
  end;
end;

procedure AngelCountEditor.EditSelected;
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'AngleCount', AngleCountSpin.Value);
  RefreshCanvas;
end;

function AngelCountEditor.GetAngleCount: Integer;
begin
  result := AngleCountSpin.Value;
end;

{ ZoomValueEditor }

constructor ZoomValueEditor.Create(PanelOut: TWinControl);
begin
  NextTop := PTop;
  { ZoomValue }
  ZoomValueSpin := TSpinEdit.Create(nil);
  ZoomValueLabel := TLabel.Create(nil);
  with ZoomValueSpin do
  begin
    ZoomValueLabel.Caption := 'Zoom Value:';
    Width := 60;
    MinValue := 1;
    MaxValue := 100;
    Value := 10;
    SetCommonView(ZoomValueSpin, PanelOut, ZoomValueLabel);
    Inc(NextTop, PTop);
  end;
end;

function ZoomValueEditor.GetZoomValue: Integer;
begin
  result := ZoomValueSpin.Value;
end;

{ PenStyleEditor }

constructor PenStyleEditor.Create(PanelOut: TWinControl;
  shapelist: TFShapeList);
begin
  inherited;
  PenStyleCombo := TComboBox.Create(nil);
  PenStyleLabel := TLabel.Create(nil);
  with PenStyleCombo do
  begin
    PenStyleLabel.Caption := 'Pen Style:';
    Width := 90;
    Style := csOwnerDrawFixed;
    SetCommonView(PenStyleCombo, PanelOut, PenStyleLabel);
    OnDrawItem := PenStyleDrawItem;
    OnChange := EditSelected;
    Items.DelimitedText := '"","","","",""';
    ItemIndex := 0;
  end;
end;

procedure PenStyleEditor.EditSelected;
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'PenStyle', PenStyleCombo.ItemIndex);
  RefreshCanvas;
end;

function PenStyleEditor.GetPenStyle: TPenStyle;
begin
  result := TPenStyle(PenStyleCombo.ItemIndex);
end;

procedure PenStyleEditor.PenStyleDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  HCenter: Integer;
begin
  HCenter := ARect.Top + (ARect.Bottom - ARect.Top) shr 1;
  with TComboBox(Control).Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(ARect);
    Pen.Style := TPenStyle(Index);
    Pen.Width := 1;
    MoveTo(ARect.Left, HCenter);
    LineTo(ARect.Right, HCenter);
  end;
end;

procedure PenWidthEditor.EditSelected;
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'PenWidth', PenWidthSpin.Value);
  RefreshCanvas;
end;

function PenWidthEditor.GetPenWidth: Integer;
begin
  result := PenWidthSpin.Value;
end;

{ FontEditor }

constructor TFontEditor.Create(PanelOut: TWinControl; shapelist: TFShapeList);
var
  i, k: Integer;
begin
  inherited;
  FreeAllProps(PanelOut);
  NextTop := PTop;
  FontNameBox := TComboBox.Create(nil);
  FontNameLabel := TLabel.Create(nil);
  FontNameLabel.Caption := 'Font Name:';
  with FontNameBox do
  begin
    Width := 90;
    SetCommonView(FontNameBox, PanelOut, FontNameLabel);
    OnChange := EditFontName;
    Items.Assign(Screen.Fonts);
    Items.Insert(0, '');
    ItemIndex := 199;
    for i := 0 to shapes.Count - 1 do
      if shapes.Items[i].Selected then
        for k := 1 to screen.Fonts.Count - 1 do
         if Items[k].Equals(GetPropValue(shapes.Items[i], 'TextFontName')) then
         begin
        ItemIndex:= k;
        break;
         end
         else
         ItemIndex := 0;
  end;

  FontStyleBox := TComboBox.Create(nil);
  FontStyleLabel := TLabel.Create(nil);
  with FontStyleBox do
  begin
    FontStyleLabel.Caption := 'Font Style';
    Width := 90;
    SetCommonView(FontStyleBox, PanelOut, FontStyleLabel);
    OnChange := EditFontStyle;
    Items.Add('Normal');
    Items.Add('Bold');
    Items.Add('Italic');
    Items.Add('StrikeOut');
    Items.Add('Underline');
    ItemIndex := 0;
    for i := 0 to shapes.Count - 1 do
      if shapes.Items[i].Selected then
        ItemIndex := GetPropValue(shapes.Items[i], 'TextFontStyle');
  end;

  FontSizeSpin := TSpinEdit.Create(nil);
  FontSizeLabel := TLabel.Create(nil);
  with FontSizeSpin do
  begin
    FontSizeLabel.Caption := 'Font Size:';
    Width := 60;
    MinValue := 1;
    MaxValue := 100;
    Value := 8;
    for i := 0 to shapes.Count - 1 do
      if shapes.Items[i].Selected then
      Value := GetPropValue(shapes.Items[i], 'TextFontSize');
    OnChange := EditFontSize;
    SetCommonView(FontSizeSpin, PanelOut, FontSizeLabel);
    Inc(NextTop, PTop);
  end;

  TextMemo := TMemo.Create(nil);
  with TextMemo do
  begin
    Top := NextTop;
    Width := PanelOut.Width - 5;
    Height := Round(PanelOut.Height / 2 + 20);
    Parent := PanelOut;
    onKeyUp := EditText;
    for i := 0 to shapes.Count - 1 do
      if shapes.Items[i].Selected then
        Text := GetPropValue(shapes.Items[i], 'Text');
  end;
end;

procedure TFontEditor.EditFontName(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'TextFontName', FontNameBox.Items[FontNameBox.ItemIndex]);
  RefreshCanvas;
end;

procedure TFontEditor.EditFontSize(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      SetPropValue(shapes.Items[i], 'TextFontSize', FontSizeSpin.Value);
  RefreshCanvas;
end;

procedure TFontEditor.EditFontStyle(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
    begin
      SetPropValue(shapes.Items[i], 'TextFontStyle', FontStyleBox.ItemIndex);
    end;
  RefreshCanvas;
end;

procedure TFontEditor.EditSelected(Sender: TObject);
var
  i: Integer;
  CurrentFont: TFont;
begin
  FontDialog := TFontDialog.Create(nil);
  if FontDialog.Execute then
  begin
    CurrentFont := FontDialog.Font;
    for i := 0 to shapes.Count - 1 do
  end;
  RefreshCanvas;
end;

procedure TFontEditor.EditText(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
    begin
      SetPropValue(shapes.Items[i], 'Text', TextMemo.Lines.Text);
      RefreshCanvas;
    end;
end;

function TFontEditor.GetFont: TFont;
begin
  if FontDialog.Execute then
    result := FontDialog.Font;
end;

function TFontEditor.GetFontName: String;
begin
 Result := FontNameBox.Items[FontNameBox.ItemIndex];
end;

function TFontEditor.GetFontSize: Integer;
begin
  Result := FontSizeSpin.Value;
end;

function TFontEditor.GetFontStyle: Integer;
begin
  Result := FontStyleBox.ItemIndex;
end;

end.
