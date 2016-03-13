unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, sPanel, ExtCtrls, ComCtrls, Menus,
  sStatusBar, StdCtrls, sLabel, sListBox, sCheckListBox, sEdit,
  sSpinEdit, shapes, sDIalogs, Buttons, tools,
  sSpeedButton, ImgList, acAlphaImageList, Types, math, CheckLst, sListView,
  sSkinManager, Spin, scale, sScrollBar, Vcl.Grids, typinfo, ClipBrd, CopyPaste,
  UndoRedo, JPEG, TransMemo;

type
  Tf_main = class(TForm)
    panel_buttons: TsPanel;
    dlg_color: TColorDialog;
    bar_status: TsStatusBar;
    panel_colors: TsPanel;
    shp_bc: TShape;
    shp_pc: TShape;
    panel_UI: TsPanel;
    pb: TPaintBox;
    ScrollHorz: TsScrollBar;
    sPanel1: TsPanel;
    ScrollVert: TsScrollBar;
    panel_prop: TsPanel;
    sbt_downlayer: TsSpeedButton;
    sbt_uplayer: TsSpeedButton;
    sbt_deletelayer: TsSpeedButton;
    list_layers: TsListView;
    images_tools: TsAlphaImageList;
    DrawGrid1: TDrawGrid;
    mm: TMainMenu;
    mm_file: TMenuItem;
    mm_print: TMenuItem;
    mm_save: TMenuItem;
    mm_saveas: TMenuItem;
    mm_open: TMenuItem;
    mm_sep02: TMenuItem;
    mm_exit: TMenuItem;
    mm_edit: TMenuItem;
    mm_swapcolors: TMenuItem;
    mm_sep01: TMenuItem;
    mm_clear: TMenuItem;
    mm_view: TMenuItem;
    mm_viewpal: TMenuItem;
    mm_viewtools: TMenuItem;
    mm_viewprop: TMenuItem;
    mm_help: TMenuItem;
    mm_about: TMenuItem;
    N1: TMenuItem;
    CopyBtn: TMenuItem;
    PasteBtn: TMenuItem;
    CutBtn: TMenuItem;
    N2: TMenuItem;
    Label4: TLabel;
    UndoButton: TMenuItem;
    RedoButton: TMenuItem;
    N3: TMenuItem;
    VecSave: TMenuItem;
    S1: TMenuItem;
    JpegButton: TMenuItem;
    procedure pbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure shp_pcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure shp_bcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure colorsMouseEnter(Sender: TObject);
    procedure colorsMouseLeave(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure RegisterToolButton(Params: TNewTool);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbPaint(Sender: TObject);
    procedure CLearButtonClick(Sender: TObject);
    procedure ScrollHorzScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ScrollVertScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckInfo;
    procedure sbt_downlayerClick(Sender: TObject);
    procedure sbt_uplayerClick(Sender: TObject);
    procedure sbt_deletelayerClick(Sender: TObject);
    procedure list_layersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure list_layersItemChecked(Sender: TObject; Item: TListItem);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mm_saveClick(Sender: TObject);
    procedure mm_openClick(Sender: TObject);
    procedure mm_viewpalClick(Sender: TObject);
    procedure mm_viewtoolsClick(Sender: TObject);
    procedure mm_viewpropClick(Sender: TObject);
    procedure mm_aboutClick(Sender: TObject);
    procedure SetFormCaption;
    procedure mm_swapcolorsClick(Sender: TObject);
    procedure mm_clearClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure UndoButtonClick(Sender: TObject);
    procedure RedoButtonClick(Sender: TObject);
    procedure VecSaveClick(Sender: TObject);
    procedure JpegButtonClick(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure TransparentMemo1Enter(Sender: TObject);
    procedure TransparentMemo1Exit(Sender: TObject);
  private
    ToolButtons: array of TsSpeedButton;
    CurrentTool: Integer;
    shapes: TFSHapeList;
    UseTool: TFTool;
    MainZoomer: TZoomer;
    MainChangesRecorder: TChangesRecorder;
    Saved: Boolean;
    FirstSave: Boolean;
    FileName: String;
  end;
type
  TFileFormat = (VEC, SVG, JPG);

const
  Sign = 'Test';

var
  f_main: Tf_main;
  bmp : TBitmap;
  FIleFormat: TFIleFormat;

  Palette: array [0 .. 1, 0 .. 9] of TColor = ((clBlack, clGray, clMaroon,
    $CE807F, clOlive, clGreen, clTeal, clNavy, clPurple, clWhite),
    (clWhite, clSilver, clRed, $008EFF, clYellow, clLime, clAqua, clBlue,
    clFuchsia, clWhite));

implementation

{$R *.dfm}

uses ImageSizeForm;

function SaveFile(title, format: string): string;
var
  dialog: tssaveDialog;
begin
  dialog := tssaveDialog.Create(f_main);
  with dialog do
  begin
    title := title;
    InitialDir := extractfilepath(paramstr(0));
    Filter := format;
    Create(f_main);
    if Execute then
      Result := FileName;
  end;
end;

procedure Tf_main.CopyBtnClick(Sender: TObject);
var
  t: TStringList;
  i: Integer;
begin
  t := TStringList.Create;
  t.Append(Sign);
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      t.Add(shapes.Items[i].GetSaveData);
  ClipBoard.AsText := t.Text;
  t.Free;
end;

procedure Tf_main.CutBtnClick(Sender: TObject);
var
  t: TStringList;
  i: Integer;
begin
  t := TStringList.Create;
  t.Append(Sign);
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      t.Add(shapes.Items[i].GetSaveData);
  ClipBoard.AsText := t.Text;
  t.Free;
  for i := 0 to shapes.Count - 1 do
    if shapes.Items[i].Selected then
      shapes.Delete(i);
  shapes.UpdateLayers;
  pb.Invalidate;
end;

procedure Tf_main.CheckInfo;
begin
  // Label2.Caption := Format('%d, %d, %d, %d', [Round(MainZoomer.FullImageSize.L), Round(MainZoomer.FullImageSize.U), Round(MainZoomer.FullImageSize.R), ROund(MainZoomer.FullImageSize.D)]);
  // Label4.Caption := inttostr(scrollvert.Min);
  // Label6.Caption := inttostr(scrollvert.Max);
  // Label8.Caption := inttostr(scrollvert.PageSize);
end;

procedure Tf_main.RedoButtonClick(Sender: TObject);
var
 t : TStringList;
begin
 if MainChangesRecorder.CurrentChange < MainChangesRecorder.ChangesList.Count -1 then
 begin
 Inc(MainChangesRecorder.CurrentChange);
 shapes.Clear;
 MainZoomer.Clear;
 t := TStringList.Create;
 t := MainChangesRecorder.SelectShange(MainChangesRecorder.CurrentChange);
 shapes.AddShapes(t, MainZoomer);
 shapes.UpdateLayers;
 SetFormCaption;
 pb.Invalidate;
 end;
end;

procedure Tf_main.RegisterToolButton(Params: TNewTool);
begin
  SetLength(ToolButtons, length(ToolButtons) + 1);
  ToolButtons[high(ToolButtons)] := TsSpeedButton.Create(panel_buttons);
  with ToolButtons[high(ToolButtons)] do
  begin
    Top := 10 + high(ToolButtons) * 30;
    Left := 9;
    Height := 25;
    Width := 25;
    Tag := high(ToolButtons) + 1;
    OnClick := ToolButtonClick;
    Hint := Params.Name;
    Images := images_tools;
    ShowHint := True;
    GroupIndex := 1;
    if fileexists(Params.IconPath) then
    begin
      images_tools.LoadFromFile(Params.IconPath);
      ImageIndex := images_tools.Count - 1;
      flat := True;
    end;
    if high(ToolButtons) = 0 then
    begin
      CurrentTool := high(ToolButtons) + 1;
      Down := True;
    end;
    Parent := panel_buttons;
  end;
end;

procedure Tf_main.S1Click(Sender: TObject);
var
  S: string;
  t: TStringList;
  ImgWidth, ImgHeight: integer;
  PreZoom : Double;
  PreOffset: TPoint;
begin
ImgSizeForm.ShowModal;
if ImgSizeForm.ModalResult = mrOk then
begin
  S := SaveFile('Save Image As', 'SVG (*.svg)|*.svg| All Files|*.*');
  if length(S) = 0 then
    exit;
  // SysUtils.ChangeFileExt()
  S := extractfilepath(S) + ExtractFileName(S) + '.svg';
  FileName := S;
  ImgWidth := strtoint(ImgSizeForm.EditWidth.Text);
  ImgHeight := strtoint(ImgSizeForm.EditHeight.Text);
  PreZoom := MainZoomer.Zoom;
  PreOffset := MainZoomer.Offset;
  MainZoomer.SetJPegZoom(MainZoomer.FullImageSize, ImgWidth, ImgHeight);
  t := shapes.GetAllSVGData(MainZoomer, ImgWidth, ImgHeight);
  MainZoomer.Zoom := PreZoom;
  MainZoomer.Offset := PreOffset;
  try
    t.SaveToFile(FileName);
  except
    on E: Exception do
    begin
      showmessage(E.Message);
      exit;
    end;
  end;
  FirstSave := false;
  Saved := True;
  FileFormat := SVG;
  MainChangesRecorder.SavedChange := MainChangesRecorder.CurrentChange;
  SetFormCaption;
end;
end;

procedure Tf_main.sbt_deletelayerClick(Sender: TObject);
begin
  if shapes.Count < 1 then
    exit;
  with list_layers do
  begin
    if SelCount <> 1 then
      exit;
    if (ItemIndex < 0) or (ItemIndex > shapes.Count - 1) then
      exit;
    shapes.Delete(ItemIndex);
  end;
  shapes.UpdateLayers;
  pb.Invalidate;
end;

procedure Tf_main.sbt_downlayerClick(Sender: TObject);
begin
  if shapes.Count < 1 then
    exit;
  with list_layers do
  begin
    // if SelCount <> 1 then
    // exit;
    if (ItemIndex < 0) or (ItemIndex >= shapes.Count - 1) then
      exit; // �������!
    shapes.Swap(ItemIndex, ItemIndex + 1);
  end;
  shapes.UpdateLayers;
  pb.Invalidate;
end;

procedure Tf_main.sbt_uplayerClick(Sender: TObject);
begin
  if shapes.Count < 1 then
    exit;
  with list_layers do
  begin
    if SelCount <> 1 then
      exit;
    if (ItemIndex <= 0) or (ItemIndex > shapes.Count - 1) then
      exit;
    shapes.Swap(ItemIndex, ItemIndex - 1);
  end;
  shapes.UpdateLayers;
  pb.Invalidate;
end;

procedure Tf_main.ScrollHorzScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  MainZoomer.Offset.X := ScrollPos;
  pb.Invalidate;
end;

procedure Tf_main.ScrollVertScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  MainZoomer.Offset.Y := ScrollPos;
  pb.Invalidate;
end;

procedure Tf_main.ToolButtonClick(Sender: TObject);
begin
  CurrentTool := (Sender as TsSpeedButton).Tag - 1;
  if UseTool <> nil then
    UseTool.UnRegisterUI(panel_UI);
  UseTool.Free;
  UseTool := ToolsArray[CurrentTool].SType.Create(pb.Canvas, shapes);
  UseTool.Zoomer := MainZoomer;
  UseTool.PaintBox := pb;
  UseTool.Form := f_main;
  UseTool.RegisterUI(panel_UI);
end;





procedure Tf_main.TransparentMemo1Enter(Sender: TObject);
begin
  showMessage('Hello');
end;

procedure Tf_main.TransparentMemo1Exit(Sender: TObject);
begin
ShowMessage('Bye');
end;

procedure Tf_main.UndoButtonClick(Sender: TObject);
var
 t : TStringList;
begin
 if MainChangesRecorder.CurrentChange > 0 then
 begin
 Dec(MainChangesRecorder.CurrentChange);
 shapes.Clear;
 MainZoomer.Clear;
 t := TStringList.Create;
 t := MainChangesRecorder.SelectShange(MainChangesRecorder.CurrentChange);
 shapes.AddShapes(t, MainZoomer);
 shapes.UpdateLayers;
 SetFormCaption;
 pb.Invalidate;
 end;
end;



procedure Tf_main.Button1Click(Sender: TObject);
var
  Sc: Integer;
begin
  MainZoomer.SetRectZoom(MainZoomer.FullImageSize);
  pb.Invalidate;
end;

procedure Tf_main.CLearButtonClick(Sender: TObject);
begin
  MainZoomer := TZoomer.Create;
  MainZoomer.Horz := ScrollHorz;
  MainZoomer.Vert := ScrollVert;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  MainZoomer.FullImageSize.L := 0;
  MainZoomer.FullImageSize.U := 0;
  MainZoomer.FullImageSize.R := pb.Width;
  MainZoomer.FullImageSize.D := pb.Height;
  shapes := TFSHapeList.Create(MainZoomer, pb.Canvas);
  shapes.Table := list_layers;
  pb.Invalidate;
  UseTool.isActive := false;
end;

procedure Tf_main.colorsMouseEnter(Sender: TObject);
begin
  bar_status.Panels[2].Text :=
    'LButton = Pen Color; RButton = Brush Color; Shift + Click = Change Color; CTRL + Click = Add Color';
end;

procedure Tf_main.colorsMouseLeave(Sender: TObject);
begin
  bar_status.Panels[2].Text := '';
end;

procedure Tf_main.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  DrawGrid1.Canvas.Brush.Color := Palette[ARow, ACol];
  DrawGrid1.Canvas.FillRect(Rect);
end;

procedure Tf_main.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  { if Shift = [ssCtrl] then
    begin
    if dlg_color.Execute then
    begin
    Palette.AddColor(dlg_color.Color);
    end;
    end;
    if Shift = [ssShift] then
    if dlg_color.Execute then
    Palette.palcolors[t] := dlg_color.Color; }
  if Button = mbLeft then
  begin
    shp_pc.Brush.Color := Palette[Y div 25, X div 25];
    if shapes.Count <> 0 then
      for i := 0 to shapes.Count - 1 do
        if shapes.Items[i].Selected then
        begin
          SetPropValue(shapes.Items[i], 'PenColor', shp_pc.Brush.Color);
          SetPropValue(shapes.Items[i], 'TextFontColor', shp_pc.Brush.Color);
        end;
  end;
  if Button = mbRight then
  begin
    shp_bc.Brush.Color := Palette[Y div 25, X div 25];
    for i := 0 to shapes.Count - 1 do
      if shapes.Items[i].Selected then
        SetPropValue(shapes.Items[i], 'BrushColor', shp_bc.Brush.Color);
  end;
  pb.Refresh;
end;

procedure Tf_main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FirstSave then
    if shapes.Count = 0 then
      exit;
  if not Saved then
  begin
    case MessageDlg('Save Changes?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes:
        mm_saveClick(nil);
      mrCancel:
        CanClose := false;
    end;
  end;
end;

procedure Tf_main.FormCreate(Sender: TObject);
var
  i: Integer;
  t: TStringList;
begin
  //Palette := TFPalette.Create(colors.Canvas, colors.Height div 2);
  FileName := 'Unnamed.vec';
  FirstSave := True;
  MainZoomer := TZoomer.Create;
  MainChangesRecorder := TChangesRecorder.Create;
  SetFormCaption;
  MainZoomer.Horz := ScrollHorz;
  MainZoomer.Vert := ScrollVert;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  MainZoomer.FullImageSize.L := 0;
  MainZoomer.FullImageSize.U := 0;
  MainZoomer.FullImageSize.R := pb.Width;
  MainZoomer.FullImageSize.D := pb.Height;
  shapes := TFSHapeList.Create(MainZoomer, pb.Canvas);
  shapes.Table := list_layers;
  f_main.DoubleBuffered := True;
  t := shapes.GetAllSaveData;
  MainChangesRecorder.CurrentChange := -1;
  MainChangesRecorder.AddChange(t);
  RefreshCanvas := pb.Refresh;
  for i := 0 to high(ToolsArray) do
    RegisterToolButton(ToolsArray[i]);
  ToolButtonClick(ToolButtons[0]);
  //bmp.Free;
end;

procedure Tf_main.FormResize(Sender: TObject);
begin
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  SetImageSize(shapes, MainZoomer);
  MainZoomer.SetScrolls;
  pb.Invalidate;
end;

procedure Tf_main.JpegButtonClick(Sender: TObject);
var
JpegIm: TJpegImage;
bmp: TBitMap;
S: string;
PreZoom : Double;
PreOffset: TPoint;
begin
ImgSizeForm.ShowModal;
if ImgSizeForm.ModalResult = mrOk then
begin
bmp := TBitmap.Create;
bmp.Width := strtoInt(ImgSizeForm.EditWidth.Text);
bmp.Height := strtoInt(ImgSizeForm.EditHeight.Text);
PreZoom := MainZoomer.Zoom;
PreOffset := MainZoomer.Offset;
MainZoomer.SetJPegZoom(MainZoomer.FullImageSize, bmp.Width, bmp.Height);
shapes.DrawAll(bmp.Canvas);
MainZoomer.Zoom := PreZoom;
MainZoomer.Offset := PreOffset;
JpegIm := TJpegImage.Create;
JpegIm.Assign(bmp);
JpegIm.CompressionQuality := 20;
JPegIm.Compress;
S := SaveFile('Save Image As', 'JPEG (*.jpg)|*.jpg| All Files|*.*');
  if length(S) = 0 then
    exit;
  S := extractfilepath(S) + ExtractFileName(S) + '.jpg';
  FileName := S;
JPegIm.SaveToFile(FileName);
bmp.Destroy;
JPegIm.Destroy;
FileFormat:= JPG;
end;
end;

procedure Tf_main.list_layersItemChecked(Sender: TObject; Item: TListItem);
begin
  if not shapes.ReInvalidate then
    exit;
  shapes.Items[Item.Index].DrawIT := Item.Checked;
  pb.Invalidate;
end;

procedure Tf_main.list_layersSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if not shapes.ReInvalidate then
    exit;
  shapes.Items[Item.Index].Selected := Selected;
  { if (UseTool is TFSelectTool) then
    begin
    UseTool.UnRegisterUI(panel_UI);
    UseTool.RegisterUI(panel_UI);
    end; }
  pb.Invalidate;
end;

procedure Tf_main.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
if Key = #13 then
   Text := 'Test';
end;

procedure Tf_main.SetFormCaption;
var
  t: string;
begin
  if Saved or (MainChangesRecorder.CurrentChange = MainChangesRecorder.SavedChange) then
    t := ''
  else
    t := ' *';
  f_main.Caption := 'VPaint [' + FileName + ']' + t;
end;



function LoadFile(title, format: string): string;
var
  dialog: tsOpenDialog;
begin
  dialog := tsOpenDialog.Create(f_main);
  with dialog do
  begin
    title := title;
    InitialDir := extractfilepath(paramstr(0));
    Filter := format;
    Create(f_main);
    if Execute then
      Result := FileName;
  end;
end;

procedure Tf_main.mm_aboutClick(Sender: TObject);
begin
  // f_about.Show;
end;

procedure Tf_main.VecSaveClick(Sender: TObject);
var
  S: string;
  t: TStringList;
begin
  S := SaveFile('Save Image As', 'Vector Graphics (*.vec)|*.vec| All Files|*.*');
  if length(S) = 0 then
    exit;
  // SysUtils.ChangeFileExt()
  S := extractfilepath(S) + ExtractFileName(S) + '.vec';
  FileName := S;
  t := shapes.GetAllSaveData;
  try
    t.SaveToFile(FileName);
  except
    on E: Exception do
    begin
      showmessage(E.Message);
      exit;
    end;
  end;
  FirstSave := false;
  Saved := True;
  FileFormat := VEC;
  MainChangesRecorder.SavedChange := MainChangesRecorder.CurrentChange;
  SetFormCaption;
end;

procedure Tf_main.mm_clearClick(Sender: TObject);
begin
  MainZoomer.Clear;
  shapes.Clear;
  list_layers.Clear;
  SetImageSize(shapes, MainZoomer);
  MainZoomer.SetScrolls;
  pb.Invalidate;
  Saved := false;
  SetFormCaption;
end;

procedure Tf_main.mm_openClick(Sender: TObject);
var
  t: TStringList;
  S: string;
begin
  if FirstSave then
    if shapes.Count = 0 then
      exit;
  if not Saved then
  begin
    case MessageDlg('Save Changes?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes:
        mm_saveClick(nil);
      mrCancel:
        exit;
    end;
  end;
  S := LoadFile('Load Image', 'Vector Graphic (*.vec)|*.vec| All Files|*.*');
  if (length(S) = 0) then
  begin
    showmessage('������ ������ �����');
    exit;
  end;
  t := TStringList.Create;
  t.LoadFromFile(S);
  if (t.Strings[0] <> Sign) then
  begin
    showmessage('Error! This format can not be readed!');
    exit;
  end;
  shapes.Clear;
  MainZoomer.Clear;
  try
    shapes.AddShapes(t, MainZoomer);
  except
    showmessage('Error! This file currupted!');
    exit;
  end;
  t.Free;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  SetImageSize(shapes, MainZoomer);
  MainZoomer.SetScrolls;
  pb.Invalidate;
  shapes.UpdateLayers;
  Saved := True;
  FileName := S;
  SetFormCaption;
end;

procedure Tf_main.mm_saveClick(Sender: TObject);
var
  t: TStringList;
begin
  if FirstSave then
  begin
    VecSaveClick(nil);
    exit;
  end;
  t := shapes.GetAllSaveData;
  t.SaveToFile(FileName);
  FirstSave := false;
  Saved := True;
  MainChangesRecorder.SavedChange := MainChangesRecorder.CurrentChange;
  SetFormCaption;
end;

procedure Tf_main.mm_swapcolorsClick(Sender: TObject);
var
  tmp: TColor;
begin
  tmp := shp_pc.Brush.Color;
  shp_pc.Brush.Color := shp_bc.Brush.Color;
  shp_bc.Brush.Color := tmp;
end;

procedure Tf_main.mm_viewpalClick(Sender: TObject);
var
  X: Integer;
begin
  mm_viewpal.Checked := not mm_viewpal.Checked;
  if mm_viewpal.Checked then
    X := -panel_colors.Height - 6
  else
    X := panel_colors.Height + 6;
  panel_colors.Visible := mm_viewpal.Checked;
  ScrollHorz.Top := ScrollHorz.Top + X;
  ScrollVert.Height := ScrollVert.Height + X;
  panel_buttons.Height := panel_buttons.Height + X;
  panel_prop.Height := panel_prop.Height + X;
  sPanel1.Top := sPanel1.Top + X;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  MainZoomer.SetScrolls;
end;

procedure Tf_main.mm_viewpropClick(Sender: TObject);
var
  X: Integer;
begin
  mm_viewprop.Checked := not mm_viewprop.Checked;
  if mm_viewprop.Checked then
    X := -panel_prop.Width - 6
  else
    X := panel_prop.Width + 6;
  panel_prop.Visible := mm_viewprop.Checked;
  panel_UI.Visible := mm_viewprop.Checked;
  pb.Width := pb.Width + X;
  ScrollVert.Left := ScrollVert.Left + X;
  ScrollHorz.Width := ScrollHorz.Width + X;
  sPanel1.Left := sPanel1.Left + X;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  MainZoomer.SetScrolls;
end;

procedure Tf_main.mm_viewtoolsClick(Sender: TObject);
var
  X: Integer;
begin
  mm_viewtools.Checked := not mm_viewtools.Checked;
  if mm_viewtools.Checked then
    X := panel_buttons.Width + 6
  else
    X := -panel_buttons.Width - 6;
  panel_buttons.Visible := mm_viewtools.Checked;
  pb.Left := pb.Left + X;
  ScrollHorz.Left := ScrollHorz.Left + X;
  ScrollHorz.Width := ScrollHorz.Width - X;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  MainZoomer.SetScrolls;
end;

procedure Tf_main.N1Click(Sender: TObject);
var
  Sc: Integer;
begin
  MainZoomer.SetRectZoom(MainZoomer.FullImageSize);
  pb.Invalidate;
end;

procedure Tf_main.PasteBtnClick(Sender: TObject);
var
  i: Integer;
  t: TStringList;
  PropStr: String;
  PropSubStr: String;
  PropMemo: TMemo;
begin
  t := TStringList.Create;
  t.Text := ClipBoard.AsText;
  if (t.Count = 0) or (t.Strings[0] <> Sign) then
    exit;
  try
    shapes.AddShapes(t, MainZoomer);
  finally
    t.Free;
  end;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  SetImageSize(shapes, MainZoomer);
  MainZoomer.SetScrolls;
  pb.Invalidate;
  shapes.UpdateLayers;

end;



procedure Tf_main.pbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then
    exit;
  pb.Canvas.Pen.Color := shp_pc.Brush.Color;
  pb.Font.Color := shp_pc.Brush.Color;
  pb.Canvas.Brush.Color := shp_bc.Brush.Color;
  panel_colors.SetFocus;
  UseTool.MouseDown(X, Y);
end;

procedure Tf_main.pbMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  begin
    bar_status.Panels[0].Text := inttostr(X) + ',' + inttostr(Y);
    UseTool.MouseMove(X, Y);
    SetImageSize(shapes, MainZoomer);
    MainZoomer.SetScrolls;
    if CurrentTool <> 15 then
     //pb.Refresh; // �����-�� ��� � Invalidate
  end;
end;

procedure Tf_main.pbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 t: TStringList;
begin
  UseTool.MouseUp(X, Y, Shift, Button);
  if UseTool.AddLayer then
    shapes.UpdateLayers;
  MainZoomer.PBSize := Point(pb.Width, pb.Height);
  SetImageSize(shapes, MainZoomer);
  MainZoomer.SetScrolls;
  if UseTool.ClassName = 'TFSelectTool' then
  begin
    UseTool.UnRegisterUI(panel_UI);
    UseTool.RegisterUI(panel_UI);
  end;
  t :=TStringList.Create;
  t := shapes.GetAllSaveData;
  MainChangesRecorder.AddChange(t);
  pb.Refresh;
  Saved := false;
  SetFormCaption;
end;

procedure Tf_main.pbPaint(Sender: TObject);
var
  Test: TCOlor;
begin
  bmp := TBitmap.Create;
  bmp.Height := pb.Height;
  bmp.Width := pb.Width;
  bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));
  shapes.DrawAll(bmp.Canvas);
  pb.Canvas.Draw(0, 0, bmp);
  bar_status.Panels[1].Text := inttostr(Round(MainZoomer.Zoom * 100)) + '%';
  bmp.Free;
end;

procedure Tf_main.shp_bcMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if dlg_color.Execute then
    shp_bc.Brush.Color := dlg_color.Color;
end;

procedure Tf_main.shp_pcMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if dlg_color.Execute then
    begin
    shp_pc.Brush.Color := dlg_color.Color;
    end;
end;

end.
