program vectoredit;

uses
  Forms,
  main in 'main.pas' {f_main},
  shapes in 'shapes.pas',
  tools in 'tools.pas',
  scale in 'scale.pas',
  URegions in 'URegions.pas',
  Editors in 'Editors.pas',
  ImageSizeForm in 'ImageSizeForm.pas' {ImgSizeForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'VPaint';
  Application.CreateForm(Tf_main, f_main);
  Application.CreateForm(TImgSizeForm, ImgSizeForm);
  Application.Run;

end.
