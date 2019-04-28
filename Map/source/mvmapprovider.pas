{
  (c) 2014 ti_dic

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
unit mvMapProvider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TTileId }
  TTileId = record
    X, Y: int64;
    Z: integer;
  end;


  TGetSvrStr = function (id: integer): string of object;
  TGetValStr = function (const Tile: TTileId): String of object;

  { TMapProvider }

  TMapProvider = Class
    private
      FLayer: integer;
      idServer: Array of Integer;
      FName: String;
      FUrl: Array of string;
      FNbSvr: Array of integer;
      FGetSvrStr: Array of TGetSvrStr;
      FGetXStr: Array of TGetValStr;
      FGetYStr: Array of TGetValStr;
      FGetZStr: Array of TGetValStr;
      FMinZoom: Array of integer;
      FMaxZoom: Array of integer;
      function GetLayerCount: integer;
      procedure SetLayer(AValue: integer);

    public
      constructor Create(AName: String);
      destructor Destroy; override;
      procedure AddURL(Url: String; NbSvr, aMinZoom, aMaxZoom: integer;
        GetSvrStr: TGetSvrStr; GetXStr: TGetValStr; GetYStr: TGetValStr;
        GetZStr: TGetValStr);
      procedure GetZoomInfos(out AZoomMin, AZoomMax: integer);
      Function GetUrlForTile(id: TTileId): String;
      property Name: String read FName;
      property LayerCount: integer read GetLayerCount;
      property Layer: integer read FLayer write SetLayer;
  end;


implementation

{ TMapProvider }

function TMapProvider.getLayerCount: integer;
begin
  Result:=length(FUrl);
end;

procedure TMapProvider.SetLayer(AValue: integer);
begin
  if FLayer=AValue then Exit;
  if (aValue<low(FUrl)) and (aValue>high(FUrl)) then
  Begin
    Raise Exception.create('bad Layer');
  end;
  FLayer:=AValue;
end;

constructor TMapProvider.Create(aName: String);
begin
  FName:=aName;
end;

destructor TMapProvider.Destroy;
begin
  Finalize(idServer);
  Finalize(FName);
  Finalize(FUrl);
  Finalize(FNbSvr);
  Finalize(FGetSvrStr);
  Finalize(FGetXStr);
  Finalize(FGetYStr);
  Finalize(FGetZStr);
  Finalize(FMinZoom);
  Finalize(FMaxZoom);
  inherited;
end;

procedure TMapProvider.AddURL(Url: String; NbSvr: integer;
  aMinZoom : integer;aMaxZoom :  integer;
  GetSvrStr: TGetSvrStr; GetXStr: TGetValStr; GetYStr: TGetValStr;
  GetZStr: TGetValStr);
var nb : integer;
begin
  nb:=length(FUrl)+1;
  SetLength(IdServer,nb);
  SetLength(FUrl,nb);
  SetLength(FNbSvr,nb);
  SetLength(FGetSvrStr,nb);
  SetLength(FGetXStr,nb);
  SetLength(FGetYStr,nb);
  SetLength(FGetZStr,nb);
  SetLength(FMinZoom,nb);
  SetLength(FMaxZoom,nb);
  nb:=high(FUrl);
  FUrl[nb]:=Url;
  FNbSvr[nb]:=NbSvr;
  FMinZoom[nb]:=aMinZoom;
  FMaxZoom[nb]:=aMaxZoom;
  FGetSvrStr[nb]:=GetSvrStr;
  FGetXStr[nb]:=GetXStr;
  FGetYStr[nb]:=GetYStr;
  FGetZStr[nb]:=GetZStr;
  FLayer:=low(FUrl);
end;

procedure TMapProvider.GetZoomInfos(out AZoomMin, AZoomMax: integer);
begin
  AZoomMin := FMinZoom[layer];
  AZoomMax := FMaxZoom[layer];
end;

function TMapProvider.GetUrlForTile(id: TTileId): String;
var
  i: integer;
  XVal, yVal, zVal, SvrVal: String;
  idsvr: integer;
begin
  Result := '';
  i := layer;
  if (i > High(idServer)) or (i < Low(idServer)) or (FNbSvr[i] = 0) then
    exit;

  idsvr := idServer[i] mod FNbSvr[i];
  idServer[i] += 1;

  SvrVal := IntToStr(idsvr);
  XVal := IntToStr(id.X);
  YVal := IntToStr(id.Y);
  ZVal := IntToStr(id.Z);
  if Assigned(FGetSvrStr[i]) then
    SvrVal := FGetSvrStr[i](idsvr);
  if Assigned(FGetXStr[i]) then
    XVal := FGetXStr[i](id);
  if Assigned(FGetYStr[i]) then
    YVal := FGetYStr[i](id);
  if Assigned(FGetZStr[i]) then
    ZVal := FGetZStr[i](id);
  Result := StringReplace(FUrl[i], '%serv%', SvrVal, [rfreplaceall]);
  Result := StringReplace(Result, '%x%', XVal, [rfreplaceall]);
  Result := StringReplace(Result, '%y%', YVal, [rfreplaceall]);
  Result := StringReplace(Result, '%z%', ZVal, [rfreplaceall]);
end;

end.

