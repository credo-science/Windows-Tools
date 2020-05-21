unit Unit1;

{$MODE Delphi}

interface

uses
  LCLType, LCLIntf, Classes, SysUtils, DB, BufDataset, sqldb, sqlite3conn,
  FileUtil, TAGraph, TASeries, Forms, Controls, Graphics, Dialogs, Buttons,
  DBGrids, DBCtrls, StdCtrls, ExtCtrls, Menus, ComCtrls, ExtDlgs, EditBtn,
  Calendar, Spin, TADrawUtils, TACustomSeries, TADbSource, TASources,
  TAIntervalSources, TATools, TAChartExtentLink, TARadialSeries,
  SynHighlighterSQL, SynEdit, dateutils, Types, DateTimePicker;


type

  { TForm1 }
  THackDBGrid = class(TDBGrid);

  TForm1 = class(TForm)
    BufDataset1: TBufDataset;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Chart1: TChart;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    FloatSpinEdit1: TFloatSpinEdit;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SpinEdit1: TSpinEdit;
    unkor: TLineSeries;
    os8: TLineSeries;
    ChartExtentLink1: TChartExtentLink;
    os7: TLineSeries;
    Chart2: TChart;
    Chart3: TChart;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    ChartToolset1DataPointClickTool2: TDataPointClickTool;
    ChartToolset1DataPointClickTool3: TDataPointClickTool;
    ChartToolset1DataPointCrosshairTool1: TDataPointCrosshairTool;
    ChartToolset1DataPointCrosshairTool2: TDataPointCrosshairTool;
    ChartToolset1DataPointCrosshairTool3: TDataPointCrosshairTool;
    ChartToolset1PanDragTool1: TPanDragTool;
    ChartToolset1PanDragTool2: TPanDragTool;
    ChartToolset1PanDragTool3: TPanDragTool;
    ChartToolset1ZoomMouseWheelTool1: TZoomMouseWheelTool;
    ChartToolset1ZoomMouseWheelTool2: TZoomMouseWheelTool;
    ChartToolset1ZoomMouseWheelTool3: TZoomMouseWheelTool;
    ChartToolset2: TChartToolset;
    ChartToolset3: TChartToolset;
    DataSource2: TDataSource;
    DataSource3: TDataSource;
    DateTimeIntervalChartSource2: TDateTimeIntervalChartSource;
    DateTimeIntervalChartSource3: TDateTimeIntervalChartSource;
    DbChartSource2: TDbChartSource;
    DbChartSource3: TDbChartSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    DateTimeIntervalChartSource1: TDateTimeIntervalChartSource;

    Button2: TButton;
    Label10: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Memo2: TMemo;
    Label2: TLabel;
    DataSource1: TDataSource;
    DbChartSource1: TDbChartSource;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    os4: TLineSeries;
    os5: TLineSeries;
    os6: TLineSeries;
    SQLite3Connection1: TSQLite3Connection;
    SQLite3Connection2: TSQLite3Connection;
    SQLite3Connection3: TSQLite3Connection;

    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLQuery3: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    SQLTransaction2: TSQLTransaction;
    SQLTransaction3: TSQLTransaction;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ChartToolset1DataPointCrosshairTool3AfterKeyDown(
      ATool: TChartTool; APoint: TPoint);
    procedure os7CustomDrawPointer(ASender: TChartSeries;
      ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
    procedure ChartToolset1DataPointClickTool1AfterKeyDown(ATool: TChartTool;
      APoint: TPoint);
    procedure DateEdit1Change(Sender: TObject);
    procedure DateEdit2Change(Sender: TObject);
       procedure FormCreate(Sender: TObject);
       procedure Label6Click(Sender: TObject);
  private
    { private declarations }

  public
    { public declarations }
    imagenActual: TBitmap;

  end;

var
  Form1: TForm1;
  rutaEXE: string;
  framecol: integer;
  filename: string;
  Data1, data2 : string;


implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
  var dt:tdatetime;
begin
   dt:= datetimepicker1.DateTime;
     data1:=FormatDateTime( 'yyyy-mm-dd',dt );
   dt:= datetimepicker2.DateTime;
     data2:=FormatDateTime( 'yyyy-mm-dd',dt );


  label5.Caption:=data1+'  '+data2;
  button2.Click;
  button3.Click;
  button4.Click;
  button5.Click;
  button6.Click;
  button7.Click;

end;

procedure TForm1.Label6Click(Sender: TObject);
begin

end;



procedure TForm1.Button2Click(Sender: TObject);
  var  val:string;
begin
 // filename := 'wyn.db';
   val:=spinedit1.Value.ToString;

filename := 'po_filtrze_tylko_tmestamp.sqlite';


  rutaEXE := ExtractFilePath(UTF8Encode(Application.ExeName));
  SQLQuery1.SQL.Clear;
  dbgrid1.Clear;
  begin
    SQLite3Connection1.DatabaseName := filename;
    SQLite3Connection1.Connected := True;
    SQLTransaction1.DataBase := SQLite3Connection1;
    SQLQuery1.DataBase := SQLite3Connection1;
    SQLQuery1.PacketRecords:=500000;
    SQLTransaction1.Active := True;
    SQLQuery1.SQL.Text :=
    'select   strftime("%Y-%m-%d %H:",datetime(a.timestamp/1000,"unixepoch")) ||  case when ((cast(strftime("%M", datetime(a.timestamp/1000,"unixepoch")) as int) / '+val+') * '+val+') = 0 then "0" else "" end ||  ((cast(strftime("%M", datetime(a.timestamp/1000,"unixepoch")) as int) / '+val+') * '+val+') || ":00" period,  count(*) counter from detections  as a WHERE  ((datetime(a.timestamp/1000,"unixepoch")> "'+data1+' 00:00:00" AND datetime(a.timestamp/1000,"unixepoch")< "'+data2+' 00:00:00" )) group by period ORDER by datetime(timestamp/1000,"unixepoch")';
      SQLQuery1.Close;
    SQLQuery1.Open;
    DataSource1.DataSet := SQLQuery1;
    DBGrid1.DataSource := DataSource1;
    DBGrid1.AutoFillColumns := True;
    dbgrid1.SelectedIndex := framecol - 1;


  end;

end;

procedure TForm1.Button3Click(Sender: TObject);

   var
  ds: TDataset;
  fperiod, fcounter: TField;
  x, y: Double;

begin

  ds := DBGrid1.Datasource.Dataset;
  ds.DisableControls;
  os7.BeginUpdate;
  try
    fperiod := ds.FieldByName('period');
    fcounter := ds.FieldByName('counter');
    ds.First;
    while not ds.EOF do begin
      x :=  ScanDateTime('yyyy-mm-dd hh:nn:ss',  (fperiod.AsString));
      y :=  fcounter.AsFloat ;
      if y>5 then
      os7.AddXY(x, y);
      ds.Next;

    end;
  finally
    os7.EndUpdate;
    ds.EnableControls;
  end;
end;

   procedure TForm1.Button4Click(Sender: TObject);
begin
   filename := 'DOMC.sqlite';

  rutaEXE := ExtractFilePath(UTF8Encode(Application.ExeName));
  SQLQuery2.SQL.Clear;
  dbgrid2.Clear;
  begin
    SQLite3Connection2.DatabaseName := filename;
    SQLite3Connection2.Connected := True;
    SQLTransaction2.DataBase := SQLite3Connection2;
    SQLQuery2.DataBase := SQLite3Connection2;
      SQLQuery2.PacketRecords:=500000;
    SQLTransaction2.Active := True;
    SQLQuery2.SQL.Text :=
      ('select   * from domc where timeou BETWEEN "'+data1+' 00:00:00" and "'+data2+' 00:00:00"');
     SQLQuery2.Close;
    SQLQuery2.Open;
    DataSource2.DataSet := SQLQuery2;
    DBGrid2.DataSource := DataSource2;
    DBGrid2.AutoFillColumns := True;
    dbgrid2.SelectedIndex := framecol - 1;

  end;


end;

procedure TForm1.Button5Click(Sender: TObject);

   var
  ds: TDataset;
  fperiod, fcounter,uncorr,fpressure: TField;
  x, y: Double;
begin
  ds := DBGrid2.Datasource.Dataset;
  ds.DisableControls;

  os4.BeginUpdate;
  unkor.BeginUpdate;
  try
    fperiod := ds.FieldByName('TimeOU');
    fpressure := ds.FieldByName('Pressure');
    uncorr  := ds.FieldByName('UncorrectedCountRate');
    fcounter:=  ds.FieldByName('CorrectedCountRate');
    ds.First;
    while not ds.EOF do begin
      x := ScanDateTime('yyyy-mm-dd hh:nn:ss', fperiod.AsString);


      if radiobutton1.Checked then begin y := fcounter.AsFloat;
        if y>0 then unkor.AddXY(x , y);  end;


      if radiobutton2.Checked then begin  y := uncorr.AsFloat;
        if y>0 then unkor.AddXY(x , y);   end;

      y := fpressure.AsFloat;
      if y>0 then os4.AddXY(x , y*2 );

      ds.Next;
    end;
  finally

    os4.EndUpdate;
    unkor.EndUpdate;
    ds.EnableControls;
  end;

end;

procedure TForm1.Button6Click(Sender: TObject);
begin
 filename := 'eq3.sqlite';

   rutaEXE := ExtractFilePath(UTF8Encode(Application.ExeName));
  SQLQuery3.SQL.Clear;
  dbgrid3.Clear;
  begin
    SQLite3Connection3.DatabaseName := filename;
    SQLite3Connection3.Connected := True;
    SQLTransaction3.DataBase := SQLite3Connection3;
    SQLQuery3.DataBase := SQLite3Connection3;
      SQLQuery3.PacketRecords:=500000;
    SQLTransaction3.Active := True;
    SQLQuery3.SQL.Text :=
      ('select   * from quereq where (mag>4) and time BETWEEN "'+data1+' 00:00:00" and "'+data2+' 00:00:00"');//where time BETWEEN "2020-01-01 00:00:00" and "2020-01-31 00:00:00"');
    SQLQuery3.Close;
    SQLQuery3.Open;
    DataSource3.DataSet := SQLQuery3;
    DBGrid3.DataSource := DataSource3;
    DBGrid3.AutoFillColumns := True;
    dbgrid3.SelectedIndex := framecol - 1;

  end;


end;

procedure TForm1.Button7Click(Sender: TObject);

   var
  ds: TDataset;
  fperiod,  fmag: TField;
  x, y: Double;
begin
  ds := DBGrid3.Datasource.Dataset;
  ds.DisableControls;
  os5.BeginUpdate;
  try
    fperiod := ds.FieldByName('time');
    fmag := ds.FieldByName('mag');
     ds.First;
    while not ds.EOF do begin
      x := ScanDateTime('yyyy-mm-dd hh:nn:ss', fperiod.AsString);
      y := 0;//fpressure.AsFloat;
         if fmag.AsFloat>floatspinedit1.Value then
     os5.AddXY(x , y );
     // os4.AddXY(x , y );
     // os8.AddXY(x , y );


      ds.Next;
    end;
  finally
    os5.EndUpdate;
    ds.EnableControls;
  end;

end;

procedure TForm1.ChartToolset1DataPointCrosshairTool3AfterKeyDown(
  ATool: TChartTool; APoint: TPoint);
begin

end;

procedure TForm1.os7CustomDrawPointer(ASender: TChartSeries;
  ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
begin

end;

procedure TForm1.ChartToolset1DataPointClickTool1AfterKeyDown(
  ATool: TChartTool; APoint: TPoint);
   var
        //z: int64;
        at: tdatetime;
        x,z:double;
      begin

        with ATool as TDatapointClickTool do
          if (Series is TLineSeries) then
            with TLineSeries(Series) do
            begin

              x :=  (GetXValue(PointIndex));
              z :=  (GetYValue(PointIndex));


            label11.Caption :=  DateTimeToStr(x)+ '   ' +x.ToString;


            end
           else        statictext1.Caption :=''
   end;

procedure TForm1.DateEdit1Change(Sender: TObject);
begin

end;

procedure TForm1.DateEdit2Change(Sender: TObject);
begin


end;





procedure TForm1.Button1Click(Sender: TObject);
   var dt:tdatetime;
begin
   dt:= datetimepicker1.DateTime;
     data1:=FormatDateTime( 'yyyy-mm-dd',dt );
   dt:= datetimepicker2.DateTime;
     data2:=FormatDateTime( 'yyyy-mm-dd',dt );


  label5.Caption:=data1+'  '+data2;

  unkor.clear; os7.Clear;  os4.Clear ;os5.Clear;
  datetimeintervalchartsource1.CleanupInstance;
  datetimeintervalchartsource2.CleanupInstance;
  datetimeintervalchartsource3.CleanupInstance;
  DataSource1.CleanupInstance;
  DataSource2.CleanupInstance;
  DataSource3.CleanupInstance;
  button2.Click;
  button3.Click;
  button4.Click;
  button5.Click;
  button6.Click;
  button7.Click;
end;





end.
