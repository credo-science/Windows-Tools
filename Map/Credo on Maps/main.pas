unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls,  EditBtn, DateTimePicker, SynHighlighterPython,
  DateUtils, mvGeoNames, mvMapViewer, mvTypes, wincrt, WinInet,
  lconvencoding, LCLIntf, Menus;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button2: TButton;
    Button3: TButton;
    CbDoubleBuffer: TCheckBox;
    CbProviders: TComboBox;
    CbUseThreads: TCheckBox;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    Label10: TLabel;
    FileName: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LblProviders: TLabel;
    LblZoom: TLabel;
    MapView: TMapView;
    GeoNames: TMVGeoNames;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    TrackBar1: TTrackBar;
    ZoomTrackBar: TTrackBar;
     procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
     procedure CbDoubleBufferChange(Sender: TObject);
    procedure CbFoundLocationsDrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure CbProvidersChange(Sender: TObject);
    procedure CbUseThreadsChange(Sender: TObject);
     procedure DateTimePicker1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
     procedure MapViewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
      procedure MapViewZoomChange(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
     procedure TrackBar1Change(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);

  private
     procedure UpdateDropdownWidth(ACombobox: TCombobox);

  public
    procedure ReadFromIni;
    procedure WriteToIni;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  LCLType, IniFiles, Math, mvGpsObj, mvExtraData,
  gpslistform;

type
  TLocationParam = class
    Descr: string;
    Loc: TRealPoint;
  end;

const
  MAX_LOCATIONS_HISTORY = 50;
  HOMEDIR = '';

var
  PointFormatSettings: TFormatsettings;
  gape: integer;

function CalcIniName: string;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
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


procedure TMainForm.Button1Click(Sender: TObject);
var
  F: TGpsListViewer;
begin
  F := TGpsListViewer.Create(nil);
  try
    F.MapViewer := MapView;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
  gape := 1;
  Trackbar1.Position := Trackbar1.Position - 1;
end;

procedure TMainForm.Button11Click(Sender: TObject);
begin
  gape := 1;
  Trackbar1.Position := Trackbar1.Position + 1;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  gape := 30;
  Trackbar1.Position := Trackbar1.Position - 60;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  gape := 30;
  Trackbar1.Position := Trackbar1.Position + 60;
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  rPt: TRealPoint;
  gpsPt: TGpsPoint;
  dir, gpsName, user, user_name, team, lat, lon, spacja: string;
  time: qword;
  i : integer;
  productFileIn: TextFile;
   Date: TDateTime;
begin
  label4.Caption := 'Detection for 24 h of day : ' + DateTimeToStr(DateTimePicker1.Date);
  FileName.Caption := (FormatDateTime('dd.mm.yyyy', Datetimepicker1.date));
  dir := GetCurrentDir;
  chdir(dir + '\DATA');
  if FileExists(FileName.Caption + '.txt') = False then       {FileName. dla ....}
    if InternetConnected = True then

      UrlCopyFile2('http://credo2.cyfronet.pl/auto/images/02/' + FileName.Caption +
        '.txt', FileName.Caption + '.txt', 5);
  //  MessageDlg('nie ma neta ', mtWarning, [mbOK], 0);

  if FileExists(FileName{2}.Caption + '.txt') then
  begin
    assignFile(productFileIn, FileName.Caption + '.txt');

    try
      reset(productFileIn);
      i := 0;
      while not EOF(productFileIn) do
      begin
        i := i + 1;
        readLn(productFileIn, time);
        rpt.czas := (time);
        readLn(productFileIn, lat);
        rpt.lat := strtofloat(lat);

        readLn(productFileIn, lon);
        rpt.lon := strtofloat(lon);

        readLn(productFileIn, user_name);
        // user_name:=CP1250ToUTF8(user_name);
        rpt.user := (user_name);
        readLn(productFileIn, user);
        readLn(productFileIn, team);
        readLn(productFileIn, team);


        readLn(productFileIn, spacja);


        gpsPt := TGpsPoint.CreateFrom(rPt);

        gpsPt.Name := (user_name);

        MapView.GpsItems.Add(gpsPt, i);

      end;

    finally

      closefile(productFileIn);
      label9.Caption := ' All Visable Detection : ' + IntToStr(i);
    end;
  end;
  chdir(dir);

end;





procedure TMainForm.CbDoubleBufferChange(Sender: TObject);
begin
  MapView.DoubleBuffered := CbDoubleBuffer.Checked;
end;

procedure TMainForm.CbFoundLocationsDrawItem(Control: TWinControl;
  Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  s: string;
  P: TLocationParam;
  combo: TCombobox;
  x, y: integer;
begin
  combo := TCombobox(Control);
  if (State * [odSelected, odFocused] <> []) then
  begin
    combo.Canvas.Brush.Color := clHighlight;
    combo.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    combo.Canvas.Brush.Color := clWindow;
    combo.Canvas.Font.Color := clWindowText;
  end;
  combo.Canvas.FillRect(ARect);
  combo.Canvas.Brush.Style := bsClear;
  s := combo.Items.Strings[Index];
  P := TLocationParam(combo.Items.Objects[Index]);
  x := ARect.Left + 2;
  y := ARect.Top + 2;
  combo.Canvas.Font.Style := [fsBold];
  combo.Canvas.TextOut(x, y, s);
  Inc(y, combo.Canvas.TextHeight('Tg'));
  combo.Canvas.Font.Style := [];
  combo.Canvas.TextOut(x, y, P.Descr);
end;

procedure TMainForm.CbProvidersChange(Sender: TObject);
begin
  MapView.MapProvider := CbProviders.Text;
end;

procedure TMainForm.CbUseThreadsChange(Sender: TObject);
begin
  MapView.UseThreads := CbUseThreads.Checked;
end;




procedure TMainForm.DateTimePicker1Change(Sender: TObject);
var
  rPt: TRealPoint;
  gpsPt: TGpsPoint;
  dir, gpsName, user, lat, lon, spacja, user_name, team: string;
  time: qword;
  i, xx: integer;
  productFileIn: TextFile;
begin
  FileName.Caption := (FormatDateTime('dd.mm.yyyy', Datetimepicker1.date));

  Label1.Caption := (IntToStr(dateTimetounix(DateTimePicker1.Date)));
  label4.Caption := 'Detection for 24 h of day : ' + DateTimeToStr(DateTimePicker1.Date);
  dir := GetCurrentDir;
  chdir(dir + '\DATA');
  //form4.Label6.Caption:=FileName.Caption + '.txt';
  if FileExists(FileName.Caption + '.txt') = False then
    if InternetConnected = True then

      UrlCopyFile2('http://credo2.cyfronet.pl/auto/images/02/' + FileName.Caption +
        '.txt', FileName.Caption + '.txt', 5);
  //  MessageDlg('nie ma neta ', mtWarning, [mbOK], 0);

  if FileExists(FileName.Caption + '.txt') then
  begin
    assignFile(productFileIn, FileName.Caption + '.txt');

    try
      reset(productFileIn);
      i := 0;
      MapView.GpsItems.Clear(0);//(_CLICKED_POINTS_) ;

      if gpslistform.GPSListViewer.ListView.ItemIndex > 0 then
        gpslistform.GPSListViewer.ListView.Clear;
      while not EOF(productFileIn) do
      begin
        i := i + 1;
        readLn(productFileIn, time);
        rpt.czas := (time);

        readLn(productFileIn, lat);
        rpt.lat := strtofloat(lat);

        readLn(productFileIn, lon);
        rpt.lon := strtofloat(lon);

        readLn(productFileIn, user_name);
        // user_name:=CP1250ToUTF8(user_name);
        rpt.user := (user_name);
        readLn(productFileIn, user);
        readLn(productFileIn, team);
        readLn(productFileIn, team);


        readLn(productFileIn, spacja);


        gpsPt := TGpsPoint.CreateFrom(rPt);
        gpsPt.Name := (user_name);

        MapView.GpsItems.Add(gpsPt, i);

      end;

    finally

      closefile(productFileIn);
      label9.Caption := 'Detection at moment : ' + IntToStr(i);
    end;
  end
  else
    ShowMessage('Brak pliku dla tego dnia');
  chdir(dir);
end;



procedure TMainForm.FormCreate(Sender: TObject);
begin
  ForceDirectories(HOMEDIR + 'cache/');
  MapView.CachePath := HOMEDIR + 'cache/';
  MapView.GetMapProviders(CbProviders.Items);
  CbProviders.ItemIndex := CbProviders.Items.Indexof(MapView.MapProvider);
  MapView.DoubleBuffered := True;
  MapView.Zoom := 1;
  CbUseThreads.Checked := MapView.UseThreads;
  CbDoubleBuffer.Checked := MapView.DoubleBuffered;
  FileName.Caption := (FormatDateTime('dd.mm.yyyy', Datetimepicker1.date));
  Label1.Caption := (IntToStr(dateTimetounix(DateTimePicker1.Date)));
  Label6.Caption := (IntToStr(dateTimetounix(DateTimePicker1.Date) + 86399));
  //   button4.Click;
  ReadFromIni;
  gape := 30;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  WriteToIni;
  //ClearFoundLocations;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MapView.Active := True;
end;



procedure TMainForm.MapViewMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
const
  DELTA = 3;
var
  rArea: TRealArea;
  gpsList: TGpsObjList;
  L: TStrings;
  ax: qword;
  i: integer;
  a, at: string;
  DT: TDateTime;

begin
  FileName.Caption := (FormatDateTime('dd.mm.yyyy', Datetimepicker1.date));

  Label1.Caption := (IntToStr(dateTimetounix(DateTimePicker1.Date)));
  Label6.Caption := (IntToStr(dateTimetounix(DateTimePicker1.Date) + 86399));
  // Determine area, in GPS coordinates, around the current mouse position +/- DELTA pixels
  rArea.TopLeft := MapView.ScreenToLonLat(Point(X - DELTA, Y - DELTA));
  rArea.BottomRight := MapView.ScreenToLonLat(Point(X + DELTA, Y + DELTA));
  // Retrieve the gps objects in this area
  gpsList := MapView.GpsItems.GetObjectsInArea(rArea);
  try
    if gpsList.Count > 0 then
    begin
      // Create a string from the gps objects found: Name + gps coordinates
      L := TStringList.Create;
      try
        for i := 0 to gpsList.Count - 1 do
          if gpsList[i] is TGpsPoint then
            with TGpsPoint(gpsList[i]) do
            begin
              ax := (czas div 1000);
              DT := unixToDateTime((ax));

              at := datetimetostr(dt);
              L.Add(Name + ' -  ' + at + ' UTC'{+  Lat, Lon, user});
            end;
        memo1.Text := L.Text;
      finally
        L.Free;
      end;
    end
  finally
    gpsList.Free;
  end;
end;


procedure TMainForm.MapViewZoomChange(Sender: TObject);
begin
  ZoomTrackbar.Position := MapView.Zoom;
end;

procedure TMainForm.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  FileName.Caption := DateTimeToStr(DateTimePicker1.Date);
end;





procedure TMainForm.TrackBar1Change(Sender: TObject);
var
  TS: TTimeStamp;
  DT: TDateTime;
  time, i, tt: qword;
  rPt: TRealPoint;
  gpsPt: TGpsPoint;
  dir, a, gpsName, user, user_name, lat, lon, team, spacja: string;
  productFileIn: TextFile;

begin
  i := 0;
  Tt := StrToInt(label1.Caption) + trackbar1.Position;
  ts.Time := tt;
  a := IntToStr(tt);
  DT := unixToDateTime(Tt);
  label4.Caption := ('Detection at : ' + DateTimeToStr(DT));
  dir := GetCurrentDir;
  chdir(dir + '\DATA');

  assignFile(productFileIn, FileName.Caption + '.txt');
  if FileExists(FileName.Caption + '.txt') then
  begin

    try
      MapView.GpsItems.Clear(0);//(_CLICKED_POINTS_) ;
      if gpslistform.GPSListViewer.ListView.ItemIndex > 0 then
        gpslistform.GPSListViewer.ListView.Clear;
      reset(productFileIn);
      while not EOF(productFileIn) do
      begin
        readLn(productFileIn, time);
        readLn(productFileIn, lat);
        readLn(productFileIn, lon);
        readLn(productFileIn, user_name);
        readLn(productFileIn, user);
        readLn(productFileIn, team);
        readLn(productFileIn, team);
        readLn(productFileIn, spacja);
        time := time div 1000;
        if (time < tt + gape) and (time > tt - gape) then
        begin
          Inc(i);
          rpt.czas := (time * 1000);
          rpt.Lat := strtofloat(lat);
          rpt.Lon := strtofloat(lon);
          rpt.user := (user);

          gpsPt := TGpsPoint.CreateFrom(rPt);
          gpsPt.Name := (user_name);
          MapView.GpsItems.Add(gpsPt, i);
        end;

      end;

    finally

      closefile(productFileIn);
      label9.Caption := ' All Visable Detection : ' + IntToStr(i);
     end;
  end;
  chdir(dir);
end;

procedure TMainForm.ReadFromIni;
var
  ini: TCustomIniFile;
  List: TStringList;
  L, T, W, H: integer;
  R: TRect;
  i: integer;
   s: string;
  pt: TRealPoint;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    R := Screen.DesktopRect;
    L := ini.ReadInteger('MainForm', 'Left', Left);
    T := ini.ReadInteger('MainForm', 'Top', Top);
    W := ini.ReadInteger('MainForm', 'Width', Width);
    H := ini.ReadInteger('MainForm', 'Height', Height);
    if L + W > R.Right then
      L := R.Right - W;
    if L < R.Left then
      L := R.Left;
    if T + H > R.Bottom then
      T := R.Bottom - H;
    if T < R.Top then
      T := R.Top;
    SetBounds(L, T, W, H);

    MapView.MapProvider := ini.ReadString('MapView', 'Provider', MapView.MapProvider);
    CbProviders.Text := MapView.MapProvider;
    MapView.Zoom := ini.ReadInteger('MapView', 'Zoom', MapView.Zoom);
    pt.Lon := StrToFloatDef(ini.ReadString('MapView', 'Center.Longitude', ''),
      0.0, PointFormatSettings);
    pt.Lat := StrToFloatDef(ini.ReadString('MapView', 'Center.Latitude', ''),
      0.0, PointFormatSettings);
    MapView.Center := pt;

    List := TStringList.Create;
    try
      ini.ReadSection('Locations', List);
      for i := 0 to List.Count - 1 do
      begin
        s := ini.ReadString('Locations', List[i], '');
       { if s <> '' then
          CbLocations.Items.Add(s);  }
      end;
    finally
      List.Free;
    end;

  finally
    ini.Free;
  end;
end;

procedure TMainForm.UpdateDropdownWidth(ACombobox: TCombobox);
var
  cnv: TControlCanvas;
  i, w: integer;
  s: string;
  P: TLocationParam;
begin
  w := 0;
  cnv := TControlCanvas.Create;
  try
    cnv.Control := ACombobox;
    cnv.Font.Assign(ACombobox.Font);
    for i := 0 to ACombobox.Items.Count - 1 do
    begin
      cnv.Font.Style := [fsBold];
      s := ACombobox.Items.Strings[i];
      w := Max(w, cnv.TextWidth(s));
      P := TLocationParam(ACombobox.Items.Objects[i]);
      cnv.Font.Style := [];
      w := Max(w, cnv.TextWidth(P.Descr));
    end;
    ACombobox.ItemWidth := w + 16;
    ACombobox.ItemHeight := 2 * cnv.TextHeight('Tg') + 6;
  finally
    cnv.Free;
  end;
end;

procedure TMainForm.WriteToIni;
var
  ini: TCustomIniFile;
  //L: TStringList;
  //i: integer;
begin
  ini := TMemIniFile.Create(CalcIniName);
  try
    ini.WriteInteger('MainForm', 'Left', Left);
    ini.WriteInteger('MainForm', 'Top', Top);
    ini.WriteInteger('MainForm', 'Width', Width);
    ini.WriteInteger('MainForm', 'Height', Height);

    ini.WriteString('MapView', 'Provider', MapView.MapProvider);
    ini.WriteInteger('MapView', 'Zoom', MapView.Zoom);
    ini.WriteString('MapView', 'Center.Longitude',
      FloatToStr(MapView.Center.Lon, PointFormatSettings));
    ini.WriteString('MapView', 'Center.Latitude',
      FloatToStr(MapView.Center.Lat, PointFormatSettings));

    ini.EraseSection('Locations');
    // for i := 0 to CbLocations.Items.Count-1 do
    // ini.WriteString('Locations', 'Item'+IntToStr(i), CbLocations.Items[i]);

  finally
    ini.Free;
  end;
end;

procedure TMainForm.ZoomTrackBarChange(Sender: TObject);
begin
  MapView.Zoom := ZoomTrackBar.Position;
  LblZoom.Caption := Format('Zoom (%d):', [ZoomTrackbar.Position]);
end;


initialization
  PointFormatSettings.DecimalSeparator := '.';

end.
