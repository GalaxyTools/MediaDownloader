unit DownloadTask;

interface

uses
  System.JSON.Serializers,
  System.Generics.Collections;

type
  TgrEnumInfo = record
  private
    [JsonName('from')]
    FFrom: Integer;
    [JsonName('to')]
    FTo: Integer;
  public
    // 1
    property From: Integer read FFrom write FFrom;
    // 10
    property &To: Integer read FTo write FTo;
  end;

  TgrDownloadTask = record
  private
    // Аура
    [JsonName('name')]
    FName: string;
    [JsonName('description')]
    FDescription: string;
    // aura/{a}_{b}
    [JsonName('downloadUrl')]
    FDownloadUrl: string;
    [JsonName('enumInfo')]
    FEnumInfo: TgrEnumInfo;
  public
    function TotalTasks: Integer;
    function BuildTasks: TArray<string>;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property DownloadUrl: string read FDownloadUrl write FDownloadUrl;
    property EnumInfo: TgrEnumInfo read FEnumInfo write FEnumInfo;
  end;

  TgrDownloadTaskManager = class
  private
    FTasks: TList<TgrDownloadTask>;
    FSerializer: TJsonSerializer;
  public
    procedure LoadTasks(const ADir: string);
    procedure SaveTasks(const ADir: string);
    constructor Create;
    destructor Destroy; override;
    property Tasks: TList<TgrDownloadTask> read FTasks write FTasks;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

{ TgrDownloadTaskManager }

constructor TgrDownloadTaskManager.Create;
begin
  FTasks := TList<TgrDownloadTask>.Create;
  FSerializer := TJsonSerializer.Create;
end;

destructor TgrDownloadTaskManager.Destroy;
begin
  FTasks.Free;
  FSerializer.Free;
  inherited;
end;

procedure TgrDownloadTaskManager.LoadTasks(const ADir: string);
var
  LFiles: TArray<string>;
  LFileName: string;
  lFileSource: string;
  LTask: TgrDownloadTask;
begin
  LFiles := TDirectory.GetFiles(ADir, '*.json');
  for LFileName in LFiles do
  begin
    lFileSource := TFile.ReadAllText(LFileName, tencoding.UTF8);
    LTask := FSerializer.Deserialize<TgrDownloadTask>(lFileSource);
    FTasks.Add(LTask);
  end;
end;

procedure TgrDownloadTaskManager.SaveTasks(const ADir: string);
var
  I: Integer;
  lFileSource: string;
begin
  for I := 0 to FTasks.Count - 1 do
  begin
    lFileSource := FSerializer.Serialize<TgrDownloadTask>(FTasks[I]);
    TFile.WriteAllText(ADir + '\' + FTasks[I].Name, lFileSource);
  end;
end;

{ TgrDownloadTask }

function TgrDownloadTask.BuildTasks: TArray<string>;
var
  I, J: Integer;
  lList: TList<string>;
  lLine: string;
begin
  lList := TList<string>.Create;
  try
    for I := EnumInfo.From to EnumInfo.&To do
    begin
      lLine := DownloadUrl.Replace('%d', I.ToString);
      lList.Add(lLine);
    end;
    Result := lList.ToArray;
  finally
    lList.Free;
  end;

end;

function TgrDownloadTask.TotalTasks: Integer;

begin
  Result := FEnumInfo.FTo - FEnumInfo.FFrom;
end;

end.
