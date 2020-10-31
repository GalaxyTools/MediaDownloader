program GalaxyMediaDownloader;

uses
  System.StartUpCopy,
  FMX.Forms,
  UI.Main in 'UI.Main.pas' {UiMain},
  UI.Suite in 'UI.Suite.pas' {UiSuite: TFrame},
  DownloadTask in 'DownloadTask.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TUiMain, UiMain);
  Application.Run;
end.
