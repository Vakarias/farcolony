{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: text file process routines

============================================================================================
********************************************************************************************
Copyright (c) 2009-2012, Jean-Francois Baconnet

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************************}

unit farc_data_textfiles;

interface

uses
   Classes
   ,SysUtils

   ,MSXMLDOM
   ,XMLIntf
	,XMLDoc
//   ,xmldom

   ,farc_data_game
   ,farc_data_init;

type
   TFCEdtfStCat=
      (
         uistrUI
         ,uistrEncyl
         ,dtfscPrprName
         ,dtfscSCarchShort
         ,dtfscSCarchFull
         ,uistrFstatus
         ,uistrCrRg
         ,uistrIntRg
      );

///<summary>
///   retrieve text for ui/ encyclopaedia or proper names
///</summary>
///    <param name="UISGcateg">text category</param>
///    <param name="UISGtoken">token id to retrieve</param>
function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGtoken: string
   ): string; overload;

///<summary>
///   retrieve text for space unit architecture
///</summary>
///    <param name="UISGcateg">text category</param>
///    <param name="UISGscArch">architecture type</param>
function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGscArch: TFCEscArchTp
   ): string; overload;

///<summary>
///   retrieve text faction's status
///</summary>
///    <param name="UISGstatus">status</param>
function FCFdTFiles_UIStr_Get(
   const UISGstatus: TFCEfacStat
   ): string; overload;

///<summary>
///   retrieve credit line data text
///</summary>
///    <param name="UISGisCrRg">text category</param>
///    <param name="UISGcred">range level</param>
function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGcred: TFCEcrIntRg
   ): string; overload;

///<summary>
///   switch the language.
///</summary>
///<param name="LSlang">string[2] of language asked</param>
procedure FCMdTfiles_Lang_Switch(const LSlang: string);

///<summary>
///   initialize the text files.
///</summary>
procedure FCMdTfiles_UIString_Init;

implementation

uses
   farc_common_func
	,farc_main,
   farc_game_cps;

//===================================END OF INIT============================================

function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGtoken: string
   ): string; overload;
{:Purpose: retrieve text for ui/ encyclopaedia or proper names.
    Additions:
      -2009Nov05- *use ui.xml + encyclopaedia.xml in memory.
}
var
	UISGresDump: string;
	UISGtxtItm, UISGtxtSubItm: IXMLNode;
begin
   Result:='';
	UISGresDump:='';
   UISGtxtItm:=nil;
   UISGtxtSubItm:=nil;
	case UISGcateg of
      uistrUI: UISGtxtItm:=FCWinMain.FCXMLtxtUI.DocumentElement.ChildNodes.FindNode(UISGtoken);
		uistrEncyl: UISGtxtItm:=FCWinMain.FCXMLtxtEncy.DocumentElement.ChildNodes.FindNode(UISGtoken);
      dtfscPrprName: UISGtxtItm:=FCWinMain.FCXMLtxtUI.DocumentElement.ChildNodes.FindNode(UISGtoken);
	end;
	if (UISGtxtItm<>nil)
      and (UISGcateg<>dtfscPrprName)
   then
	begin
		UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
		if UISGtxtSubItm<>nil
      then UISGresDump:=UISGtxtSubItm.Text;
	end
   else if (UISGtxtItm<>nil)
      and (UISGcateg=dtfscPrprName)
   then UISGresDump:=UISGtxtItm.Attributes['name'];
	Result:=UISGresDump;
end;

function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGscArch: TFCEscArchTp
   ): string; overload;
{:Purpose: retrieve text for space unit architecture.
   Additions:
      -2009Nov05- *small code change for memmory streams.
      -2009Sep13- *add strPrprName.
                  *add spacecraft architecture.
      -2009Aug10- *add enclycopaedia reading.
}
var
	UISGresDump,
   UISGarcStr: string;
	UISGtxtItm, UISGtxtSubItm: IXMLNode;
begin
	UISGresDump:='';
	case UISGcateg of
      dtfscSCarchShort:
         begin
            case UISGscArch of
               scarchtpDSV: UISGresDump:='DSV';
               scarchtpHLV: UISGresDump:='HLV';
               scarchtpLV: UISGresDump:='LV';
               scarchtpLAV: UISGresDump:='LAV';
               scarchtpOMV: UISGresDump:='OMV';
               scarchtpSSI: UISGresDump:='SSI';
               scarchtpTAV: UISGresDump:='TAV';
               scarchtpBSV: UISGresDump:='BSV';
            end;
         end;
      dtfscSCarchFull:
         begin
            case UISGscArch of
               scarchtpDSV: UISGarcStr:='scarchtpDSV';
               scarchtpHLV: UISGarcStr:='scarchtpHLV';
               scarchtpLV: UISGarcStr:='scarchtpLV';
               scarchtpLAV: UISGarcStr:='scarchtpLAV';
               scarchtpOMV: UISGarcStr:='scarchtpOMV';
               scarchtpSSI: UISGarcStr:='scarchtpSSI';
               scarchtpTAV: UISGarcStr:='scarchtpTAV';
               scarchtpBSV: UISGarcStr:='scarchtpBSV';
            end;
				UISGtxtItm:=FCWinMain.FCXMLtxtUI.DocumentElement.ChildNodes.FindNode(UISGarcStr);
         end;
	end; {.case UISGcateg of}
	if (UISGtxtItm<>nil)
      and (UISGcateg<>dtfscSCarchShort)
   then
	begin
		UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
		if UISGtxtSubItm<>nil
      then UISGresDump:=UISGtxtSubItm.Text;
	end;
	Result:=UISGresDump;
end;

function FCFdTFiles_UIStr_Get(
   const UISGstatus: TFCEfacStat
   ): string; overload;
{:Purpose: retrieve text faction's status.
    Additions:
}

var
	UISGresDump,
   UISGstatStr: string;
	UISGtxtItm, UISGtxtSubItm: IXMLNode;
begin
	UISGresDump:='';
   case UISGstatus of
      fs0NViable: UISGstatStr:='cpsStatNV';
      fs1StabFDep: UISGstatStr:='cpsStatFD';
      fs2DepVar: UISGstatStr:='cpsStatSD';
      fs3Indep: UISGstatStr:='cpsStatFI';
   end;
   UISGtxtItm:=FCWinMain.FCXMLtxtUI.DocumentElement.ChildNodes.FindNode(UISGstatStr);
	if UISGtxtItm<>nil
   then
	begin
		UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
		if UISGtxtSubItm<>nil
      then UISGresDump:=UISGtxtSubItm.Text;
	end;
	Result:=UISGresDump;
end;

function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGcred: TFCEcrIntRg
   ): string; overload;
{:Purpose: retrieve credit line data text.
    Additions:
}
var
	UISGresDump,
   UISGcredStr: string;
begin
	UISGresDump:='';
	case UISGcateg of
      uistrCrRg:
      begin
         case UISGcred of
            crirPoor_Insign: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiPoor, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaPoor, ',');
            crirUndFun_Low: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiUnde, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaUnde, ',');
            crirBelAvg_Mod: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiBAvg, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaBAvg, ',');
            crirAverage: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiAvge, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaAvge, ',');
            crirAbAvg_Maj: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiAbAv, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaAbAv, ',');
            crirRch_High: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiRich, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaRich, ',');
            crirOvrFun_Usu: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiOvFu, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaOvFu, ',');
            crirUnl_Ins: UISGresDump:=FCFcFunc_ThSep(TFCcps.CRmiUnli, ',')+' - '+FCFcFunc_ThSep(TFCcps.CRmaUnli, ',');
         end;
      end;
      uistrIntRg:
      begin
         case UISGcred of
            crirPoor_Insign: UISGresDump:=FloatToStr(TFCcps.IRmiPoor)+' - '+FloatToStr(TFCcps.IRmaPoor);
            crirUndFun_Low: UISGresDump:=FloatToStr(TFCcps.IRmiUnde)+' - '+FloatToStr(TFCcps.IRmaUnde);
            crirBelAvg_Mod: UISGresDump:=FloatToStr(TFCcps.IRmiBAvg)+' - '+FloatToStr(TFCcps.IRmaBAvg);
            crirAverage: UISGresDump:=FloatToStr(TFCcps.IRmiAvge)+' - '+FloatToStr(TFCcps.IRmaAvge);
            crirAbAvg_Maj: UISGresDump:=FloatToStr(TFCcps.IRmiAbAv)+' - '+FloatToStr(TFCcps.IRmaAbAv);
            crirRch_High: UISGresDump:=FloatToStr(TFCcps.IRmiRich)+' - '+FloatToStr(TFCcps.IRmaRich);
            crirOvrFun_Usu: UISGresDump:=FloatToStr(TFCcps.IRmiOvFu)+' - '+FloatToStr(TFCcps.IRmaOvFu);
            crirUnl_Ins: UISGresDump:=FloatToStr(TFCcps.IRmiUnli)+' - '+FloatToStr(TFCcps.IRmaUnli);
         end;
      end;
	end; {.case UISGcateg of}
	Result:=UISGresDump;
end;

procedure FCMdTfiles_Lang_Switch(const LSlang: string);
{:Purpose: switch the language.
   Additions:
}
begin
   if (LSlang='EN')
      and (FCVlang<>'EN')
   then FCVlang:='EN'
   else if (LSlang='FR')
      and (FCVlang<>'FR')
   then FCVlang:='FR';
end;

procedure FCMdTfiles_UIString_Init;
{:Purpose:  initialize the text files.
   Additions:
      -2009Nov05- *put ui.xml in a dedicated memory stream.
                  *put encyclopaedia.xml in a dedicated memory stream.
      -2009Aug10- *add enclycopaedia file.
}
var
   UISIfstream: TFileStream;
begin
   {.initialize ui.xml in memory}
   UISIfstream:= TFileStream.Create(FCVpathXML+'\text\ui.xml', fmOpenRead);
   FCVmemUI:= TMemoryStream.Create;
   FCVmemUI.Size:= UISIfstream.Size;
   FCVmemUI.CopyFrom(UISIfstream, UISIfstream.Size);
   UISIfstream.Free;
   FCWinMain.FCXMLtxtUI.LoadFromStream(FCVmemUI);
   {.initialize encyclopaedia.xml in memory}
   UISIfstream:= TFileStream.Create(FCVpathXML+'\text\encyclopaedia.xml', fmOpenRead);
   FCVmemEncy:= TMemoryStream.Create;
   FCVmemEncy.Size:= UISIfstream.Size;
   FCVmemEncy.CopyFrom(UISIfstream, UISIfstream.Size);
   UISIfstream.Free;
   FCWinMain.FCXMLtxtEncy.LoadFromStream(FCVmemEncy);
end;

end.

