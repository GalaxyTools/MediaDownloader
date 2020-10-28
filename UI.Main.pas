unit UI.Main;

interface

uses
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
  FMX.ListBox;

type
  TUiMain = class(TForm)
    MultiView1: TMultiView;
    Layout1: TLayout;
    ToolBar1: TToolBar;
    Button1: TButton;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCurrentView: TFrame;
  public
    { Public declarations }
    procedure ShowView(AView: TFrame);
  end;

var
  UiMain: TUiMain;

implementation

uses
  UI.Suite;
{$R *.fmx}

procedure TUiMain.FormCreate(Sender: TObject);
begin
  ShowView(UiSuite);
end;

procedure TUiMain.FormDestroy(Sender: TObject);
begin
  ShowView(nil);
end;

procedure TUiMain.ShowView(AView: TFrame);
begin
  if Assigned(FCurrentView) then
    FCurrentView.Parent := nil;
  if Assigned(AView) then
  begin
    AView.Parent := Layout1;
    Label1.Text := AView.Hint;
  end;
end;

end.
