unit Unit5;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, TADrawUtils, TACustomSeries, TASources, TAMultiSeries,
  LCLIntf, ComCtrls, ExtDlgs, EditBtn, Calendar, TATypes, TAIntervalSources,
  TAChartAxisUtils, TATools, TAChartListbox, TADataTools, dateutils, Types,
  lconvencoding, WinInet, httpsend;

type

  { TForm4 }

  TForm4 = class(TForm)
    LoadButton: TButton;
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
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    StatusBar1: TStatusBar;
     procedure LoadButtonClick(Sender: TObject);
     procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Calendar1DayChanged(Sender: TObject);
    procedure Chart1AxisList0MarkToText(var AText: string; AMark: double);
     procedure ChartToolset1DataPointClickTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1DataPointCrosshairTool1AfterMouseDown(ATool: TChartTool;
      APoint: TPoint);
    procedure ChartToolset1ZoomMouseWheelTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
      private
    Series_ar: array   of TLineSeries;

  public

  end;

var
  Form4: TForm4;
  ser: array of TLineSeries;
  File_name: string;

implementation

{$R *.lfm}

{ TForm4 }

type
  thit = record
    time: int64;
    lat, long, user_n, user_name: string;
  end;


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


procedure TForm4.LoadButtonClick(Sender: TObject);
const
  BLOCK_SIZE = 1000;
var
  Detections: array of thit;
  f: textfile;
  d, i, j, y, z: integer;
  ex, cc: int64;
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


  if FileExists(calendar1.Date + '.txt') then
  begin

    label9.Caption := 'Chart for date ' + copy(FileName.Caption, 1, 10);

    plik := calendar1.Date + '.txt';//label6.Caption;
    AssignFile(f, plik);
    reset(f);
    i := 0;
    SetLength(Detections, 0);

    while not EOF(f) do
    begin
      if i mod BLOCK_SIZE = 0 then
        SetLength(Detections, Length(Detections) + BLOCK_SIZE);

      readln(f, cc);
      Detections[i].time := cc;
      readln(f, xxx);
      Detections[i].lat := xxx;
      readln(f, xxx);
      Detections[i].long := xxx;

      readln(f, xxx);
      Detections[i].user_name := xxx;

      readln(f, xxx);
      Detections[i].user_n := xxx;
      Users.Add(Detections[i].user_n);

      readln(f, xxx);  //team Name

      readln(f, xxx); //Team Number

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
    //  for j := Low(Series_ar) to  High(Series_ar)
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
      DT := unixToDateTime((Detections[j].time div 1000));//div 1000);

      Series_ar[d].AddXy(dt, StrToInt(Detections[j].user_n));

      Series_ar[d].Title := (Detections[j].user_name);

    end;


   end
  else
    ShowMessage('Brak pliku na dysku lub brak sieci lub plik jeszcze nie istnieje');
   Users.Free;
    LoadButton.Caption := 'Reload Data';
  chdir(dir);

end;





procedure TForm4.Button6Click(Sender: TObject);
var
  x: integer;
begin
  for x := 1 to chartlistbox1.SeriesCount - 1 do
    chartlistbox1.Checked[x] := False;
end;

procedure TForm4.Button7Click(Sender: TObject);
var
  x: integer;
begin
  for x := 0 to chartlistbox1.SeriesCount - 1 do
    chartlistbox1.Checked[x] := True;

end;

procedure TForm4.Calendar1DayChanged(Sender: TObject);
var
  dir: string;
begin
   If Not DirectoryExists('DATA') then
    CreateDir ('DATA');

  dir := GetCurrentDir;
  chdir(dir + '\DATA');
   FileName.Caption := calendar1.Date;

  if FileExists(FileName.Caption + '.txt') = False then       {label2. dla ....}
    if InternetConnected = True then
      UrlCopyFile2('http://credo2.cyfronet.pl/auto/images/02/' + FileName.Caption +
        '.txt', FileName.Caption + '.txt', 5);
  //  MessageDlg('nie ma neta ', mtWarning, [mbOK], 0);
  chdir(dir);
  LoadButton.Click;

end;

procedure TForm4.Chart1AxisList0MarkToText(var AText: string; AMark: double);
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




procedure TForm4.ChartToolset1DataPointClickTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
var
  z, y: double;
  at: tdatetime;
begin

  with ATool as TDatapointClickTool do
    if (Series is TLineSeries) then
      with TLineSeries(Series) do
      begin
        z := (GetXValue(PointIndex));
        Label4.Caption := title + ' ' + FormatDateTime('ddddd hh:nn:ss', z) + 'UTC';
        //+   datetimetostr(z )+ y.ToString;
      end
    else
      Statusbar1.SimpleText := '';

end;

procedure TForm4.ChartToolset1DataPointCrosshairTool1AfterMouseDown(ATool: TChartTool;
  APoint: TPoint);
var
  x, y: double;
begin
  with ATool as TDatapointClickTool do
    if (Series is TLineSeries) then
      with TLineSeries(Series) do
      begin
        x := GetXValue(PointIndex);
        y := GetYValue(PointIndex);
        Statusbar1.SimpleText := Format('%s: x = %f, y = %f', [Title, x, y]);
      end
    else
      Statusbar1.SimpleText := '';
  label5.Caption := 'f';
end;

procedure TForm4.ChartToolset1ZoomMouseWheelTool1AfterKeyDown(ATool: TChartTool;
  APoint: TPoint);
begin
  label8.Caption := ChartToolset1ZoomMouseWheelTool1.zoomfactor.ToString +
    '   ' + ChartToolset1ZoomMouseWheelTool1.ZoomRatio.ToString;
  //ChartToolset1ZoomMouseWheelTool1.
end;




end.
