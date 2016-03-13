unit Unit1;

interface

Uses
  Windows, SysUtils, Classes, Graphics, Types, shapes, Controls, Spin,
  StdCtrls, math, ExtCtrls, scale, tools, typinfo;

type
  MainPropEditor = class
  public
    procedure FreeAllProps(PanelOut: TWinControl);
  end;

type
  PenPropEditor = class(MainPropEditor)
  private
    PenWidthSpin: TSpinEdit;
    PenWidthLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
    function GetPenWidth: Integer;
  end;

type
  PenStyleEditor = class(MainPropEditor)
  private
    PenStyleCombo: TComboBox;
    PenStyleLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
    procedure PenStyleDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    function GetPenStyle: TPenStyle;
  end;

type
  BrushStyleEditor = class(MainPropEditor)
  private
    BrushStyleCombo: TComboBox;
    BrushStyleLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
    procedure BrushStyleDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
  end;

type
  RoundPropsEditor = class(MainPropEditor)
  private
    RoundValueSpin: TSpinEdit;
    RoundValueLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
  end;

type
  AngelCountEditor = class(MainPropEditor)
  private
    AngleCountSpin: TSpinEdit;
    AngleCountLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
  end;

type
  ZoomValueEditor = class(MainPropEditor)
  private
    ZoomValueSpin: TSpinEdit;
    ZoomValueLabel: TLabel;
  public
    constructor Create(PanelOut: TWinControl);
  end;

implementation

const
  PLeft = 8;
  PTop = 4;

var
  NextTop: Integer; // координата Top для текущего компонента

function GetNextTop(X: Integer): Integer;
// получение Top для текущего компонента и расчет для следущего
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

procedure MainPropEditor.FreeAllProps(PanelOut: TWinControl);
var
  i: Integer;
begin
  for i := 0 to PanelOut.ControlCount - 1 do
    PanelOut.Controls[0].Free;
end;

{ PenPropEditor }

constructor PenPropEditor.Create(PanelOut: TWinControl);
begin
  NextTop := PTop;
  PenWidthSpin := TSpinEdit.Create(nil);
  PenWidthLabel := TLabel.Create(nil);
  with PenWidthSpin do
  begin
    PenWidthLabel.Caption := 'Pen Width:';
    Width := 60;
    MinValue := 1;
    MaxValue := 100;
    Value := MinValue;
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

constructor BrushStyleEditor.Create(PanelOut: TWinControl);
begin
  BrushStyleCombo := TComboBox.Create(nil);
  BrushStyleLabel := TLabel.Create(nil);
  BrushStyleLabel.Caption := 'Brush Style:';
  with BrushStyleCombo do
  begin
    Width := 90;
    Style := csOwnerDrawFixed;
    SetCommonView(BrushStyleCombo, PanelOut, BrushStyleLabel);
    OnDrawItem := BrushStyleDrawItem;
    Items.DelimitedText := '"","","","","",""';
    ItemIndex := 0;
  end;
end;

{ RoundPropsEditor }

constructor RoundPropsEditor.Create(PanelOut: TWinControl);
begin
  RoundValueSpin := TSpinEdit.Create(nil);
  RoundValueLabel := TLabel.Create(nil);
  with RoundValueSpin do
  begin
    RoundValueLabel.Caption := 'Round Value:';
    Width := 60;
    MinValue := 0;
    MaxValue := 1000000;
    Value := 50;
    SetCommonView(RoundValueSpin, PanelOut, RoundValueLabel);
  end;
end;

{ AngelCountEditor }

constructor AngelCountEditor.Create(PanelOut: TWinControl);
begin
  AngleCountSpin := TSpinEdit.Create(nil);
  AngleCountLabel := TLabel.Create(nil);
  with AngleCountSpin do
  begin
    AngleCountLabel.Caption := 'Angle Count:';
    Width := 60;
    MinValue := 3;
    MaxValue := 9;
    Value := 3;
    SetCommonView(AngleCountSpin, PanelOut, AngleCountLabel);
  end;
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

{ PenStyleEditor }

constructor PenStyleEditor.Create(PanelOut: TWinControl);
begin
   PenStyleCombo := TComboBox.Create(nil);
  PenStyleLabel := TLabel.Create(nil);
  with PenStyleCombo do
  begin
    PenStyleLabel.Caption := 'Pen Style:';
    Width := 90;
    Style := csOwnerDrawFixed;
    SetCommonView(PenStyleCombo, PanelOut, PenStyleLabel);
    OnDrawItem := PenStyleDrawItem;
    Items.DelimitedText := '"","","","","",""';
    ItemIndex := 0;
  end;
end;

function PenStyleEditor.GetPenStyle: TPenStyle;
begin

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

end.
