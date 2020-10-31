unit UI.Suite;

interface

uses
  Galaxy.FileDriver,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Layouts,
  FMX.SegmentedProgresBar, System.Threading;

type
  TUiSuite = class(TFrame)
    Layout1: TLayout;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    NumberBox1: TNumberBox;
    Layout3: TLayout;
    Layout2: TLayout;
    Label2: TLabel;
    NumberBox2: TNumberBox;
    Layout4: TLayout;
    Button1: TButton;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FTask: ITask;
    FProgBar: TSegmentedProgresBar;
    FFileDriver: TgFileDriver;
    FColorInWork: TAlphaColor;
    FColorDone: TAlphaColor;
    FColorError: TAlphaColor;
    procedure UpdateProgressBarCount;
    function GetItemName(const I: Integer): string;
    function ItemNameToIndex(const AName: string): Integer;
    procedure StartDownload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
    property ColorInWork: TAlphaColor read FColorInWork write FColorInWork;
    property ColorDone: TAlphaColor read FColorDone write FColorDone;
    property ColorError: TAlphaColor read FColorError write FColorError;
  end;

var
  UiSuite: TUiSuite;

implementation

{$R *.fmx}
{ TUiSuite }

procedure TUiSuite.Button2Click(Sender: TObject);

begin
  FProgBar.SegmentsCount := 100;

  TTask.Run(
    procedure
    var
      I: Integer;
      x: Integer;
    begin
      x := -1;
      for I := 0 to FProgBar.SegmentsCount - 2 do
      begin
        TTask.Run(
          procedure
          begin
            Inc(x);
            TThread.Synchronize(nil,
              procedure
              begin
                FProgBar.Segmet[x] := ColorInWork;
              end);
            Sleep(3000);
            TThread.Synchronize(nil,
              procedure
              begin
                FProgBar.Segmet[x] := ColorDone;
              end);
          end);
      end;
    end);

end;

constructor TUiSuite.Create(AOwner: TComponent);
begin
  inherited;
  FProgBar := TSegmentedProgresBar.Create(nil);
  FProgBar.Parent := Layout3;
  FProgBar.Align := TAlignLayout.Client;
  FProgBar.BackgroundColor := TAlphaColorRec.Beige;
  FFileDriver := TgFileDriver.Create(ParamStr(0) + '\Resource\');

  ColorInWork := TAlphaColorRec.Blue;
  ColorDone := TAlphaColorRec.Green;
  ColorError := TAlphaColorRec.Red;
end;

destructor TUiSuite.Destroy;
begin
  FFileDriver.Free;
  FProgBar.Free;
  inherited;
end;

function TUiSuite.GetItemName(const I: Integer): string;
begin
  Result := (Round(NumberBox1.Value) + I).ToString;
end;

function TUiSuite.ItemNameToIndex(

  const AName: string): Integer;
begin
  Result := AName.ToInteger - Round(NumberBox1.Value);
end;

procedure TUiSuite.Button1Click(Sender: TObject);
begin
  UpdateProgressBarCount;
  StartDownload;
end;

procedure TUiSuite.StartDownload;
var
  lMin: Integer;
  lMax: Integer;
begin
  lMin := Round(NumberBox1.Value);
  lMax := Round(NumberBox2.Value);
  FTask := TTask.Run(
    procedure
    begin
      TParallel.For(0, lMax - lMin - 1,
        procedure(I: Integer)
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              FProgBar.Segmet[I] := ColorInWork;
            end);

          if FFileDriver.IsReady(GetItemName(I)) then
          begin
            FProgBar.Segmet[I] := FColorDone
          end
          else
            FFileDriver.Download(GetItemName(I),
              procedure(AID, AFilename: string)
              begin
                if FileExists(AFilename) then
                  FProgBar.Segmet[ItemNameToIndex(AID)] := FColorDone
                else
                  FProgBar.Segmet[ItemNameToIndex(AID)] := FColorError;
              end);
        end);
    end);
end;

procedure TUiSuite.UpdateProgressBarCount;
var
  lFrom, lTo: Integer;
begin
  FProgBar.Clear;
  lFrom := Round(NumberBox1.Value);
  lTo := Round(NumberBox2.Value);
  FProgBar.SegmentsCount := lTo - lFrom;
end;

initialization

UiSuite := TUiSuite.Create(nil);
UiSuite.Align := TAlignLayout.Client;

finalization

// UiSuite.Free;

end.
