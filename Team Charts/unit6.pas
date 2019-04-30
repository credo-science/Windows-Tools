unit Unit6;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, TADrawUtils, TACustomSeries, TASources, TAMultiSeries,
  LCLIntf, ComCtrls, ExtCtrls, ExtDlgs, Calendar, TATypes, TAIntervalSources,
  TAChartAxisUtils, TATools, TAChartListbox, TADataTools, dateutils, Types,
  lconvencoding, httpsend, WinInet;

type

  { TForm5 }

  TForm5 = class(TForm)
    Reload: TButton;
    Button6: TButton;
    Button7: TButton;
    Calendar1: TCalendar;
    Chart1: TChart;
    ChartListbox1: TChartListbox;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1DataPointCrosshairTool1: TDataPointCrosshairTool;
    ChartToolset1PanDragTool1: TPanDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    DateTimeIntervalChartSource1: TDateTimeIntervalChartSource;
    FileName: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListChartSource1: TListChartSource;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Calendar1DayChanged(Sender: TObject);
    procedure Chart1AxisList0MarkToText(var AText: string; AMark: double);
    procedure Chart1AxisList1MarkToText(var AText: string; AMark: double);
    procedure ChartListbox1Click(Sender: TObject);
    procedure ChartToolset1DataPointClickTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1ZoomMouseWheelTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ReloadClick(Sender: TObject);

  private
    Series_ar: array of TLineSeries;

  public

  end;

var
  Form5: TForm5;
  ser: array of TLineSeries;
  File_name: string;


implementation

{$R *.lfm}

{ TForm5 }

type
  thit = record
    time: int64;
    lat, long, user_n, user_name, team: string;
  end;

var
  Detections: array of thit;


function InternetConnected: boolean;
var
  dwConnectionTypes: DWord;
begin
  dwConnectionTypes := INTERNET_CONNECTION_MODEM or INTERNET_CONNECTION_LAN or
    INTERNET_CONNECTION_PROXY;
  Result := InternetGetConnectedState(@dwConnectionTypes, 0);
end;

function URLDownloadToFile(Caller: IUnknown; URL: PChar; FileName: PChar;
  Reserved: DWORD; StatusCB: IUnknown): HResult;
  stdcall; external 'URLMON.DLL' Name 'URLDownloadToFileA';

procedure UrlCopyFile2(const AUrl, AFileName: string; const AMaxRedirection: integer);
begin
  UrlDownloadToFile(nil, PChar(AUrl), PChar(AFileName), 0, nil);
end;



procedure TForm5.reloadClick(Sender: TObject);
const
  BLOCK_SIZE = 1000;
var
  f: textfile;
  ile, z, d, i, j: integer;
  cc: int64;
  plik, dir, xxx: string;
  dt: tdatetime;
  Users: TStringList;
begin
  Users := TStringList.Create;
  Users.Duplicates := dupIgnore;
  Users.Sorted := True;
  Chart1.ClearSeries;
  dir := GetCurrentDir;
  chdir(dir + '\DATA');
  if FileExists(FileName.Caption + '.txt') then
  begin
    label9.Caption := 'Chart for date ' + copy(filename.Caption, 1, 10);

    plik := FileName.Caption + '.txt';
    AssignFile(f, plik);
    reset(f);
    i := 0;
    SetLength(Detections, 0);

    while not EOF(f) do
    begin
      if i mod BLOCK_SIZE = 0 then
        SetLength(Detections, Length(Detections) + BLOCK_SIZE);

      readln(f, Detections[i].time);
      readln(f, Detections[i].lat);
      readln(f, Detections[i].long);

      readln(f, Detections[i].team);

      readln(f, xxx);

      readln(f, Detections[i].user_name);  //team Name
      if Detections[i].user_name = '' then
        Detections[i].user_name := 'No Named';

      readln(f, Detections[i].user_n); //Team Number
      if Detections[i].user_n = '' then
        Detections[i].user_n := '20000';
      Users.Add(Detections[i].user_n);

      readln(f, xxx);
      Inc(i);
    end;
    closefile(f);
    SetLength(Detections, i);

    // The stringlist "UserNames" contains the list of all user names. Each user
    // name should have its own line series.


    SetLength(Series_ar, Users.Count);

    z := 0;
    label4.Caption := i.ToString;
    for j := 0 to Users.Count - 1 do

    begin
      Series_ar[j] := TLineSeries.Create(Chart1);
      Series_ar[j].ShowPoints := True;
      Series_ar[j].Pointer.Brush.Color := rgb(Random(256), Random(256), Random(256));
      Series_ar[j].Pointer.Pen.Color := clBlack;
      Series_ar[j].Pointer.Style := psCircle;
      Series_ar[j].Title := '';
      Chart1.AddSeries(Series_ar[j]);
      progressbar1.Position := j;
    end;
    progressbar1.Max := i;
    d := 0;

    for j := 0 to High(Detections) do
    begin
      d := Users.IndexOf(Detections[j].User_n);
      if d = -1 then
        continue;
      progressbar1.Position := j;
      DT := unixToDateTime((Detections[j].time div 1000));
      Series_ar[d].AddXy(dt, StrToInt(Detections[j].user_n), Detections[j].user_name + ' (' +
        Detections[j].team + ')'); // text
      Series_ar[d].Title := (Detections[j].user_name);

    end;
    d := 0;
    for j := 0 to Users.Count - 1 do
    begin
      Series_ar[j].Title :=
        Series_ar[j].Title + ' (' + Series_ar[j].Count.ToString + ')';

    end;

  end
  else
    ShowMessage('Brak pliku na dysku lub brak sieci lub plik jeszcze nie istnieje');


  chdir(dir);
  Users.Free;

end;




procedure TForm5.Button3Click(Sender: TObject);
begin

end;

procedure TForm5.Button6Click(Sender: TObject);
var
  x: integer;
begin
  for x := 1 to chartlistbox1.SeriesCount - 1 do
    chartlistbox1.Checked[x] := False;
end;

procedure TForm5.Button7Click(Sender: TObject);
var
  x: integer;
begin
  for x := 0 to chartlistbox1.SeriesCount - 1 do
    chartlistbox1.Checked[x] := True;

end;

procedure TForm5.Calendar1DayChanged(Sender: TObject);
var
  dir: string;
begin
  if not DirectoryExists('DATA') then
    CreateDir('DATA');

  dir := GetCurrentDir;
  chdir(dir + '\DATA');

  FileName.Caption := calendar1.Date;
  Filename.Caption := (FormatDateTime('dd.mm.yyyy', calendar1.DateTime));

  if FileExists(FileName.Caption + '.txt') = False then       {label2. dla ....}
    if InternetConnected = True then
      UrlCopyFile2('http://credo2.cyfronet.pl/auto/images/02/' +
        FileName.Caption + '.txt', FileName.Caption + '.txt', 5);
  chdir(dir);
  reload.Enabled := True;
  reload.Click;

end;

procedure TForm5.Chart1AxisList0MarkToText(var AText: string; AMark: double);
var
  idx: integer;
begin
  // AMark is the y value to which the axis wants to place a label. But the y values are equal to the
  // series indexes in our case. Therefore, we can select the label text to be the series title which
  // contains the user_name
  idx := round(AMark);
  if (idx < 0) or (idx >= Length(Series_ar)) then
    AText := ''
  else
    AText := Series_ar[idx].Title;
end;



procedure TForm5.Chart1AxisList1MarkToText(var AText: string; AMark: double);
begin

end;

procedure TForm5.ChartListbox1Click(Sender: TObject);
begin

end;

procedure TForm5.ChartToolset1DataPointClickTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
var
  y, z: double;
  s: string;
begin

  with ATool as TDatapointClickTool do
    if (Series is TLineSeries) then
      with TLineSeries(Series) do
      begin
        z := (GetXValue(PointIndex));
        y := round(GetyValue(PointIndex));
        s := Source[PointIndex]^.Text;
        Label4.Caption := s + ' ' + DateTimeToStr(z);

      end;

end;


procedure TForm5.ChartToolset1ZoomMouseWheelTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
begin
  label8.Caption := ChartToolset1ZoomMouseWheelTool1.zoomfactor.ToString +
    '   ' + ChartToolset1ZoomMouseWheelTool1.ZoomRatio.ToString;

end;



procedure TForm5.FormClose(Sender: TObject; var CloseAction: TCloseAction);

begin

  Chart1.ClearSeries;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  Statusbar1.SimpleText := 'Mouse Click : Left-Info/Right-Drag/MouseWhell-Zoom';

end;

end.
