unit UI.Suite;

interface

uses
  Galaxy.FileDriver,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types, FMX.Graphics, FMX.Controls,
  FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Layouts,
  FMX.SegmentedProgresBar;

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
    CheckBox1: TCheckBox;
    Layout4: TLayout;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FProgBar: TSegmentedProgresBar;
    FFileDriver: TgFileDriver;
    FColorInWork: TAlphaColor;
    FColorDone: TAlphaColor;
    FColorError: TAlphaColor;
    procedure UpdateProgressBarCount;
    function GetItemName(const I: integer; const IsHD: Boolean): string;
    function ItemNameToIndex(const AName: string): integer;
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

procedure TUiSuite.Button1Click(Sender: TObject);
var
  I: integer;
begin
  UpdateProgressBarCount;

  for I := Round(NumberBox1.Value) to Round(NumberBox2.Value) do
  begin
    FProgBar.Segmet[I] := ColorInWork;
    FFileDriver.Download(GetItemName(I, True),
      procedure(AID, AFilename: string)
      begin
        if FileExists(AFilename) then
          FProgBar.Segmet[ItemNameToIndex(AID)] := FColorDone
        else
          FProgBar.Segmet[ItemNameToIndex(AID)] := FColorError;
      end);
  end;
end;

constructor TUiSuite.Create(AOwner: TComponent);
begin
  inherited;
  FProgBar := TSegmentedProgresBar.Create(nil);
  FProgBar.Parent := Layout3;
  FProgBar.Align := TAlignLayout.Client;
  FProgBar.BackgroundColor := TAlphaColorRec.Beige;
  FFileDriver := TgFileDriver.Create(ParamStr(0) + 'Resource\');

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

function TUiSuite.GetItemName(const I: integer; const IsHD: Boolean): string;
begin
  Result := (Round(NumberBox1.Value) + I).ToString;
end;

function TUiSuite.ItemNameToIndex(const AName: string): integer;
begin
  Result := AName.ToInteger - Round(NumberBox1.Value);
end;

procedure TUiSuite.UpdateProgressBarCount;
var
  lFrom, lTo: integer;
begin
  lFrom := Round(NumberBox1.Value);
  lTo := Round(NumberBox2.Value);
  FProgBar.SegmentsCount := lTo + 1 - lFrom;
end;

initialization

UiSuite := TUiSuite.Create(nil);
UiSuite.Align := TAlignLayout.Client;

finalization

// UiSuite.Free;

end.
