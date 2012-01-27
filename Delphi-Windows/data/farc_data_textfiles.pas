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
	,farc_main
   ,farc_game_cps
   ,farc_game_spm
   ,farc_ui_html;

//===================================END OF INIT============================================

function FCFdTFiles_UIStr_Get(
   const UISGcateg: TFCEdtfStCat;
   const UISGtoken: string
   ): string; overload;
{:Purpose: retrieve text for ui/ encyclopaedia or proper names.
    Additions:
      -2012Jan26- *add: complete special reformatting for SPMi (WIP).
      -2011Mar23- *add/mod: special reformatting system for encyclopedia texts.
      -2009Nov05- *use ui.xml + encyclopaedia.xml in memory.
}
var
	UISGreqCnt
   ,UISGreqMax: integer;

   UISGresDump
   ,UISGresDump1
   ,UISGresDump2
   ,UISGresDump3
   ,UISGresDump4: string;

   UISGencyItem
   ,UISGtxtItm
   ,UISGtxtSubItm: IXMLNode;

   UISGspmi: TFCRdgSPMi;
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
//	if (UISGtxtItm<>nil)
//      and (UISGcateg<>dtfscPrprName)
//   then
//	begin
//		UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
//		if UISGtxtSubItm<>nil
//      then UISGresDump:=UISGtxtSubItm.Text;
//	end
//   else if (UISGtxtItm<>nil)
//      and (UISGcateg=dtfscPrprName)
//   then UISGresDump:=UISGtxtItm.Attributes['name'];
   //ADDON TEST
   if (UISGtxtItm<>nil)
      and (UISGcateg=dtfscPrprName)
   then UISGresDump:=UISGtxtItm.Attributes['name']
   else if (UISGtxtItm<>nil)
      and (UISGcateg=uistrEncyl)
   then
   begin
      UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode('EncyEntry');
      if UISGtxtSubItm<>nil
      then
      begin
         {.SPMi encyclopedia formatting}
         if UISGtxtSubItm.Attributes['format']='SPMi'
         then
         begin
            UISGresDump:='';
            UISGspmi:=FCFgSPM_SPMIData_Get(UISGtxtItm.NodeName, false);
            {.SPMi area}
            UISGresDump:='<b>'+FCFdTFiles_UIStr_Get(uistrUI ,'SPMiFormat_Area')+':</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_Area_GetString(UISGspmi.SPMI_area));
            {.SPMi type + SPMi notice}
            UISGresDump2:='';
            if UISGspmi.SPMI_isPolicy
            then
            begin
               UISGresDump1:='SPMiFormat_TypePolicy';
               {.SPMi notice}
               if UISGspmi.SPMI_isUnique2set
               then
               begin
                  if FCVlang='EN'
                  then UISGresDump3:=' ';
                  case UISGspmi.SPMI_area of
                     dgADMIN: UISGresDump3:='UMIgvtPolSys';
                     dgECON: UISGresDump3:='UMIgvtEcoSys';
                     dgMEDCA: UISGresDump3:='UMIgvtHcareSys';
                     dgSPI: UISGresDump3:='UMIgvtRelSys';
                  end;
                  UISGresDump2:='<font color="clyellow"><b>'
                     +FCFdTFiles_UIStr_Get(uistrUI, 'SPMiFormat_Notice')+FCFdTFiles_UIStr_Get(uistrUI, UISGresDump3)
                     +'</b></font><br>';
               end;
            end
            else if not UISGspmi.SPMI_isPolicy
            then UISGresDump1:='SPMiFormat_TypeMeme';
            UISGresDump:=UISGresDump
               +'<ind x="200"><b>'+FCFdTFiles_UIStr_Get(uistrUI ,'SPMiFormat_Type')+':</b> '
               +FCFdTFiles_UIStr_Get(uistrUI, UISGresDump1)
               +'<br>'
               +UISGresDump2;
            {.SPMi description}
            UISGencyItem:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
            if UISGtxtSubItm<>nil
            then UISGresDump:=UISGresDump
               +'<b>'+FCFdTFiles_UIStr_Get(uistrUI ,'SPMiFormat_Description')+':</b> '
               +UISGencyItem.Text
               +'<br><ul>';
            {.SPMi requirements}
//            UISGreqCnt:=1;
//            UISGreqMax:=length(SPMI_req)-1;
//            while UISGreqCnt<=UISGreqMax do
//            begin
//               UISGresDump1:='<ind x="15"><li><b>';
//               UISGresDump2:='';
//               case SPMI_req[UISGreqCnt].SPMIR_type of
//                  dgBuilding:
//                  begin
//                     UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, GSPMspmi.SPMI_req[PPreqCnt].SPMIR_infToken)+'</b> '
//                        +FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqInf1')+' <b>'+IntToStr(GSPMspmi.SPMI_req[PPreqCnt].SPMIR_percCol)+'</b> % '
//                        +FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqInf2');
//                  end;
//                  dgFacData:
//                  begin
//                     case SPMI_req[UISGreqCnt].SPMIR_datTp of
//                        rfdFacLv1..rfdFacLv9:
//                        begin
//                           UISGdump3:=IntToStr(Integer(SPMI_req[UISGreqCnt].SPMIR_datTp)+1);
//                           UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'faclvl') +'... ('
//                              +UISGdump3+')-'+FCFdTFiles_UIStr_Get(uistrUI,'faclvl'+UISGdump3)+' +</b>';
//                        end;
//                        rfdFacStab:
//                        begin
//                           UISGresDump3:=IntToStr(SPMI_req[UISGreqCnt].SPMIR_datValue);
//                           UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatEquil') +'... >= '+UISGresDump3+' +</b>';
//                        end;
//                        rfdInstrLv:
//                        begin
//                           UISGresDump3:=IntToStr(SPMI_req[UISGreqCnt].SPMIR_datValue);
//                           UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatInstLvl') +'... >= '+UISGresDump3+' +</b>';
//                        end;
//                        rfdLifeQ:
//                        begin
//                           UISGresDump3:=IntToStr(SPMI_req[UISGreqCnt].SPMIR_datValue);
//                           UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatLifeQ') +'... >= '+UISGresDump3+' +</b>';
//                        end;
//                        rfdEquil:
//                        begin
//                           UISGresDump3:=IntToStr(SPMI_req[UISGreqCnt].SPMIR_datValue);
//                           UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatEquil') +'... >= '+UISGresDump3+' +</b>';
//                        end;
//                     end; //==END== case SPMI_req[UISGreqCnt].SPMIR_datTp of ==//
//                  end;
//                  dgTechSci:
//                  begin
//                     UISGresDump2:=FCFdTFiles_UIStr_Get(uistrUI, 'TechnoSciLabel') +'... '+FCFdTFiles_UIStr_Get(uistrUI, SPMI_req[UISGreqCnt].SPMIR_tsToken); 
//                      {:EDEV NOTES: complete it by the new additions in the doc !}
//                  end;
//                  dgUC:
//                  begin
//
//                  //233    type TFCEdgSPMiReqUC=(
//                  //234    {.fixed value}
//                  //235    dgFixed
//                  //236    ,dgFixed_yr
//                  //237    {.calculation - population}
//                  //238    ,dgCalcPop
//                  //239    ,dgCalcPop_yr
//                  //240    {.calculation - colonies}
//                  //241    ,dgCalcCol
//                  //242    ,dgCalcCol_yr
//                  end;
//               end; //==END== case SPMI_req[UISGreqCnt].SPMIR_type of ==//
//               UISGresDump:=UISGresDump+UISGresDump1+UISGresDump2;
//               inc(UISGreqCnt);
//            end; //==END== while UISGreqCnt<=UISGreqMax do ==//
            {.basic modifiers}
            UISGresDump1:='<b>'+FCFdTFiles_UIStr_Get(uistrUI ,'SPMiFormat_BasMod')+'</b><br>'
               +FCCFidxL+FCFdTFiles_UIStr_Get(uistrUI ,'colDcohes')+'<br>'
               +FCCFidxL+FCFuiHTML_Modifier_GetFormat(UISGspmi.SPMI_modCohes, true);
            UISGresDump:=UISGresDump+UISGresDump1;

         end; //==END== if UISGtxtSubItm.Attributes['format']='SPMi' ==//
      end //==END== if UISGtxtSubItm<>nil ==//
      {.keep the comptability with the old format}
      else
      begin
         UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
         if UISGtxtSubItm<>nil
         then UISGresDump:=UISGtxtSubItm.Text;
      end;
   end
   else if UISGtxtItm<>nil
   then
   begin
      UISGtxtSubItm:=UISGtxtItm.ChildNodes.FindNode(FCVlang);
      if UISGtxtSubItm<>nil
      then UISGresDump:=UISGtxtSubItm.Text;
   end;
   //END ADDON
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

