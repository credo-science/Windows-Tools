{ Map Viewer Geolocation Engine for geonames.org

  Copyright (C) 2011 Maciej Kaczkowski / keit.co

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit mvGeoNames;

interface

uses
  SysUtils, Classes, StrUtils,
  mvTypes, mvDownloadEngine;

type
  TNameFoundEvent = procedure (const AName: string; const ADescr: String;
    const ALoc: TRealPoint) of object;

  TStringArray = array of string;

  TResRec = record
    Name: String;
    Descr: String;
    Loc: TRealPoint;
  end;


  { TMVGeoNames }

  TMVGeoNames = class(TComponent)
  private
    FLocationName: string;
    FInResTable: Boolean;
    FInDataRows: Boolean;
    FNamePending: Boolean;
    FLongitudePending: Boolean;
    FLatitudePending: Boolean;
    FCol: Integer;
    FCountry: String;
    FSmall: Boolean;
    FFirstLocation: TResRec;
    FFoundLocation: TResRec;
    FOnNameFound: TNameFoundEvent;
    procedure FoundTagHandler(NoCaseTag, ActualTag: string);
    procedure FoundTextHandler(AText: String);
    function Parse(AStr: PChar): TRealPoint;
//    function RemoveTag(const str: String): TStringArray;
  public
    function Search(ALocationName: String;
      ADownloadEngine: TMvCustomDownloadEngine): TRealPoint;
  published
    property LocationName: string read FLocationName;
    property OnNameFound : TNameFoundEvent read FOnNameFound write FOnNameFound;
  end;


implementation

uses
  FastHtmlParser;

const
  SEARCH_URL = 'http://geonames.org/search.html?q=%s'; //&country=%s';


function CleanLocationName(x: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(x) do
  begin
    if x[i] in ['A'..'Z', 'a'..'z', '0'..'9'] then
      Result := Result + x[i]
    else
      Result := Result + '+'
  end;
end;


{ TMVGeoNames }

procedure TMvGeoNames.FoundTagHandler(NoCaseTag, ActualTag: String);
begin
  if not FInResTable and (NoCaseTag = '<TABLE CLASS="RESTABLE">') then begin
    FInResTable := true;
    FInDataRows := false;
    FNamePending := false;
    FLatitudePending := false;
    FLongitudePending := false;
    FSmall := false;
  end else
  if FInResTable and (NoCaseTag = '</TABLE>') then
    FInResTable := false;

  if FInResTable then begin
    if NoCaseTag = '</TH>' then
      FInDataRows := true;

    if FInDataRows then begin
      if NoCaseTag = '<TR>' then begin
        FCol := 0;
        with FFoundLocation do begin
          Name := ''; Descr := ''; Loc.Lon := 0; Loc.Lat := 0;
        end;
      end;

      if NoCaseTag = '<TD>' then
        inc(FCol);

      if FCol = 2 then begin
        if not FNamePending and (pos('<A HREF=', NoCaseTag) = 1) then
          FNamePending := true
        else if FNamePending and (NoCaseTag = '</A>') then
          FNamePending := false;

        if not FLatitudePending and (NoCaseTag = '<SPAN CLASS="LATITUDE">') then
          FLatitudePending := true
        else if FLatitudePending and (NoCaseTag = '</SPAN>') then
          FLatitudePending := false;

        if not FLongitudePending and (NoCaseTag = '<SPAN CLASS="LONGITUDE">') then
          FLongitudePending := true
        else if FLongitudePending and (NoCasetag = '</SPAN>') then
          FLongitudePending := false;
      end;

      if FCol = 3 then
        if not FSmall and (NoCaseTag = '<SMALL>') then
          FSmall := true
        else if FSmall and (NoCaseTag = '</SMALL>') then
          FSmall := false;

      if NoCaseTag = '</TR>' then begin
        if (FFirstLocation.Name = '') then
          FFirstLocation := FFoundLocation;
        if Assigned(FOnNameFound) and (FFoundLocation.Name <> '') then
          with FFoundLocation do
            FOnNameFound(Name, Descr, Loc);
      end;
    end;
  end;
end;

procedure TMvGeoNames.FoundTextHandler(AText: String);
var
  code: Integer;
begin
  if not FInDataRows or (AText = #10) then
    exit;

  if FNamePending then
    FFoundLocation.Name := AText
  else if FLatitudePending then
    val(AText, FFoundLocation.Loc.Lat, code)
  else if FLongitudePending then
    val(AText, FFoundLocation.Loc.Lon, code)
  else if (FCol = 3) and not FSmall then
    FCountry := FCountry + AText
  else if FCol = 4 then begin
    if FFoundLocation.Descr = '' then
      FFoundLocation.Descr := AText
    else
      FFoundLocation.Descr := FFoundLocation.Descr + ', ' + aText;
    if FCountry <> '' then
      FFoundLocation.Name := FFoundLocation.Name + ' (' + FCountry + ')';
    FCountry := '';
  end;
end;

function TMVGeonames.Parse(AStr: PChar): TRealPoint;
var
  parser: THtmlParser;
begin
  FFirstLocation.Name := '';
  parser := THtmlParser.Create(AStr);
  try
    parser.OnFoundTag := @FoundTagHandler;
    parser.OnFoundText := @FoundTextHandler;
    parser.Exec;
    Result := FFirstLocation.Loc;
  finally
    parser.Free;
  end;
end;
  (*
function TMVGeoNames.RemoveTag(Const str : String) : TStringArray;
var iStart,iEnd,i : Integer;
    tmp : String;
    lst : TStringList;
Begin
  SetLength(Result,0);
  tmp := StringReplace(str,'<br>',#13,[rfReplaceall]);
  tmp := StringReplace(tmp,'&nbsp;',' ',[rfReplaceall]);
  tmp := StringReplace(tmp,'  ',' ',[rfReplaceall]);
  repeat
    iEnd:=-1;
    iStart:=pos('<',tmp);
    if iStart>0 then
    Begin
      iEnd:=posEx('>',tmp,iStart);
      if iEnd>0 then
      Begin
        tmp:=copy(tmp,1,iStart-1)+copy(tmp,iEnd+1,length(tmp));
      end;
    end;
  until iEnd<=0;
  lst:=TStringList.Create;
  try
    lst.Text:=tmp;
    SetLEngth(Result,lst.Count);
    For i:=0 to pred(lst.Count) do
      Result[i]:=trim(lst[i]);
  finally
    freeAndNil(lst);
  end;

end;
       *)
function TMVGeoNames.Search(ALocationName: String;
  ADownloadEngine: TMvCustomDownloadEngine): TRealPoint;
const
  LAT_ID = '<span class="latitude">';
  LONG_ID = '<span class="longitude">';
var
  s: string;

  function gs(id: string;Start : integer): string;
  var
    i: Integer;
    ln: Integer;
  begin
    Result := '';
    ln := Length(s);
    i := PosEx(id, s,start) + Length(id);
    while (s[i] <> '<') and (i < ln) do
    begin
      if s[i] = '.' then
        Result := Result + FormatSettings.DecimalSeparator
      else
        Result := Result + s[i];
      Inc(i);
    end;
  end;

var
  ms: TMemoryStream;
  iRes,i : integer;
  lstRes : Array  of TResRec;
  iStartDescr : integer;
  lst : TStringArray;
  url: String;
begin
  FLocationName := ALocationName;
  ms := TMemoryStream.Create;
  try
    url := Format(SEARCH_URL, [CleanLocationName(FLocationName)]);
    ADownloadEngine.DownloadFile(url, ms);
    ms.Position := 0;
    SetLength(s, ms.Size);
    ms.Read(s[1], ms.Size);
  finally
    ms.Free;
  end;

  Result := Parse(PChar(s));
  (*
  Result.Lon := 0;
  Result.Lat := 0;
  SetLength(lstRes, 0);
  iRes := Pos('<span class="geo"',s);
  while (iRes>0) do
  begin
    SetLength(lstRes,length(lstRes)+1);
    lstRes[high(lstRes)].Loc.Lon := StrToFloat(gs(LONG_ID,iRes));
    lstRes[high(lstRes)].Loc.Lat := StrToFloat(gs(LAT_ID,iRes));
    iStartDescr := RPosex('<td>',s,iRes);
    if iStartDescr>0 then
    begin
      lst:=RemoveTag(Copy(s,iStartDescr,iRes-iStartDescr));
      if length(lst)>0 then
        lstRes[high(lstRes)].Name:=lst[0];
      lstRes[high(lstRes)].Descr:='';
      for i:=1 to high(lst) do
        lstRes[high(lstRes)].Descr+=lst[i];
    end;

    Result.Lon += lstRes[high(lstRes)].Loc.Lon;
    Result.Lat += lstRes[high(lstRes)].Loc.Lat;
    iRes := PosEx('<span class="geo"',s,iRes+17);
  end;

  if Length(lstRes) > 0 then
  begin
    if Length(lstRes) > 1 then
    begin
      Result.Lon := Result.Lon/length(lstRes);
      Result.Lat := Result.Lat/length(lstRes);
    end;
    if Assigned(FOnNameFound) then
      for iRes:=low(lstRes) to high(lstRes) do
      begin
        FOnNameFound(lstRes[iRes].Name, lstRes[iRes].Descr, lstRes[iRes].Loc);
      end;
  end;
  *)
end;

end.
