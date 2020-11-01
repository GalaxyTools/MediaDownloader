unit UI.Main;

interface

uses
  DownloadTask,
  FMX.SegmentedProgresBar,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.MultiView,
  FMX.ListBox, FMX.Objects, System.Generics.Collections;

type
  TUiMain = class(TForm)
    VertScrollBox1: TVertScrollBox;
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
    FDT: TgrDownloadTaskManager;
    FProgBars: TObjectList<TSegmentedProgresBar>;
    FSwitches: TObjectList<TSwitch>;
    FColorError: TAlphaColor;
    FColorInWork: TAlphaColor;
    FColorDone: TAlphaColor;
    procedure BuildView(ATask: TgrDownloadTask);
    procedure OnSwitch(Sender: TObject);
    procedure StartTask(const AIndx: Integer);
  public
    { Public declarations }
    property ColorInWork: TAlphaColor read FColorInWork write FColorInWork;
    property ColorDone: TAlphaColor read FColorDone write FColorDone;
    property ColorError: TAlphaColor read FColorError write FColorError;
  end;

var
  UiMain: TUiMain;

implementation

uses
  UI.Suite,
  System.Threading,
  Galaxy.FileDriver;
{$R *.fmx}

procedure TUiMain.BuildView(ATask: TgrDownloadTask);
var
  lContainer: TPanel;
  lText: TLabel;
begin
  lContainer := TPanel.Create(VertScrollBox1);
  lContainer.Height := 50;
  lContainer.Align := TAlignLayout.Top;
  lContainer.Padding.Left := 5;
  lContainer.Padding.Top := 2;
  lContainer.Padding.Right := 5;
  lContainer.Padding.Bottom := 2;
  VertScrollBox1.AddObject(lContainer);
  FProgBars.Add(TSegmentedProgresBar.Create(nil));
  FProgBars.Last.SegmentsCount := ATask.TotalTasks;
  FProgBars.Last.BackgroundColor := 0;
  FProgBars.Last.Align := TAlignLayout.Client;
  lContainer.AddObject(FProgBars.Last);
  FSwitches.Add(TSwitch.Create(nil));
  FSwitches.Last.OnSwitch := OnSwitch;
  FSwitches.Last.Tag := FSwitches.Count - 1;
  FSwitches.Last.Margins.Left := 10;
  FSwitches.Last.Margins.Top := 10;
  FSwitches.Last.Margins.Right := 10;
  FSwitches.Last.Margins.Bottom := 10;
  FSwitches.Last.Align := TAlignLayout.Left;
  FSwitches.Last.Width := 50;
  lContainer.AddObject(FSwitches.Last);
  lText := TLabel.Create(lContainer);
  lText.Parent := lContainer;
  lText.Align := TAlignLayout.Client;
  lText.Text := ATask.Name + #13#10 + ATask.Description;
//  lText.Color := TAlphaColorRec.Black;
end;

procedure TUiMain.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FProgBars := TObjectList<TSegmentedProgresBar>.Create;
  FSwitches := TObjectList<TSwitch>.Create;
  ColorInWork := $FFFFF3CD; // TAlphaColorRec.Blue;
  ColorDone := $FFD4EDDA; // TAlphaColorRec.Green;
  ColorError := $FFF8D7DA; // TAlphaColorRec.Red;
  FDT := TgrDownloadTaskManager.Create;
  FDT.LoadTasks(ExtractFilePath(ParamStr(0)) + 'tasks');
  for I := 0 to FDT.Tasks.Count - 1 do
  begin
    BuildView(FDT.Tasks[I]);
  end;
end;

procedure TUiMain.FormDestroy(Sender: TObject);
begin
  FDT.Free;
  FProgBars.Free;
  FSwitches.Free;
end;

procedure TUiMain.OnSwitch(Sender: TObject);
var
  lSwich: TSwitch;
begin
  lSwich := (Sender as TSwitch);
  if lSwich.IsChecked then
    StartTask(lSwich.Tag);
end;

procedure TUiMain.StartTask(const AIndx: Integer);
var
  lDwnldTsk: TgrDownloadTask;
begin
  lDwnldTsk := FDT.Tasks[AIndx];
  TTask.Run(
    procedure
    var
      lItems: TArray<string>;
      LIndx: Integer;
      FFileDriver: TgFileDriver;
    begin

      FFileDriver := TgFileDriver.Create('');
      LIndx := AIndx;
      lItems := lDwnldTsk.BuildTasks;
      TThread.Synchronize(nil,
        procedure
        begin
          FProgBars[LIndx].SegmentsCount := Length(lItems);
        end);
      TParallel.For(0, High(lItems),
        procedure(I: Integer)
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              FProgBars[LIndx].Segmet[I] := ColorInWork;
            end);

          if FFileDriver.IsReady(lItems[I]) then
          begin
            FProgBars[LIndx].Segmet[I] := FColorDone
          end
          else
            FFileDriver.Download(lItems[I],
              procedure(AID, AFilename: string)
              begin
                if FileExists(AFilename) then
                  FProgBars[LIndx].Segmet[I] := FColorDone
                else
                  FProgBars[LIndx].Segmet[I] := FColorError;
              end);
          if I = High(lItems) - 1 then
            TThread.Synchronize(nil,
              procedure
              begin
                FSwitches[LIndx].IsChecked := False;
              end);
        end);
    end);

end;

end.
