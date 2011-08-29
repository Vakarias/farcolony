{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: data file (XML) process routines

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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

unit farc_data_files;

interface

uses
   Math
   ,SysUtils
   ,Windows
   ,XMLIntf;

{list of switch for DBstarSys_Process}
type TFCEdfstSysProc=(
   {process all star systems w/o orbital objects and satellites}
   dfsspStarSys
   {process orbital objects and satellites of a designed star}
   ,dfsspOrbObj
   );

///<summary>
///   Read the data in the .xml configuration file.
///</summary>
///   <param name="CFRreadGtime">true= load the current game time</param>
procedure FCMdF_ConfigFile_Read(const CFRreadGtime: boolean);

///<summary>
///   Write the data in the .xml configuration file.
///</summary>
///   <param name="CFWupdGtime">true= save the current game time</param>
procedure FCMdF_ConfigFile_Write(const CFWupdGtime:boolean);

///<summary>
///   Read the factions database xml file.
///</summary>
procedure FCMdF_DBFactions_Read;

///<summary>
///   Read the infrastructure database xml file.
///</summary>
procedure FCMdF_DBInfra_Read;

///<summary>
///   Read the products database xml file
///</summary>
procedure FCMdF_DBProducts_Read;

///<summary>
///   read database concerning space units (internal structures and designs)
///</summary>
procedure FCMdF_DBSpaceCrafts_Read;

///<summary>
///   read SPM items database
///</summary>
procedure FCMdF_DBSPMi_Read;

///<summary>
///   read the universe database xml file.
///</summary>
///    <param name="DBSSPaction">switch wich indicate either to process all star systems
///    w/o orbital objects and satellites or to process orbital objects and satellites of a
///   designed star</param>
procedure FCMdF_DBstarSys_Process(
   const DBSSPaction: TFCEdfstSysProc;
   const DBSSPstarSysID
         ,DBSSPstarID: string
   );

///<summary>
///   load the current game
///</summary>
procedure FCMdF_Game_Load;

///<summary>
///   save the current game
///</summary>
procedure FCMdF_Game_Save;

///<summary>
///   save the current game and flush all other save game files than the current one
///</summary>
procedure FCMdF_Savegame_FlushOthr;

///<summary>
///   load the topics-definitions
///</summary>
procedure FCMdF_HelpTDef_Load;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_research
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_gameflow
   ,farc_main
   ,farc_univ_func
   ,farc_win_debug;

//===================================END OF INIT============================================

procedure FCMdF_ConfigFile_Read(const CFRreadGtime: boolean);
{:Purpose: read the data in the .xml configuration file.
   Additions:
      -2010Sep07- *add: current time frame is now in the configuration file.
                  *add: CFRreadGtime switch.
      -2010Jun14- *add: colony/faction panel location.
      -2010Jun08- *mod: regroup mainwin data.
                  *add: cps + help panel location.
      -2010Jan20- *add: debug data.
      -2010Jan11- *add: FCV3DstdTresHR.
      -2009Nov18- *add wide screen option.
      -2009Nov08- *add current game game.
}
var
	CFRxmlCfgItm: IXMLNode;
begin
	{.read the document}
	FCWinMain.FCXMLcfg.FileName:=FCVpathCfg;
	FCWinMain.FCXMLcfg.Active:=true;
	{.read the locale setting}
   CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('locale');
   if CFRxmlCfgItm<>nil
   then FCVlang:=CFRxmlCfgItm.Attributes['lang'];
   {.read the main window data}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('mainwin');
	if CFRxmlCfgItm<>nil
   then
	begin
		FCVwinMsizeW:=CFRxmlCfgItm.Attributes['mwwidth'];
		FCVwinMsizeH:=CFRxmlCfgItm.Attributes['mwheight'];
		FCVwinMlocL:=CFRxmlCfgItm.Attributes['mwlft'];
		FCVwinMlocT:=CFRxmlCfgItm.Attributes['mwtop'];
	end;
   {.read the panels data}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('panels');
	if CFRxmlCfgItm<>nil
   then
	begin
      FCVwMcolfacPstore:=CFRxmlCfgItm.Attributes['colfacStore'];
      if FCVwMcolfacPstore
      then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=CFRxmlCfgItm.Attributes['cfacX'];
         FCWinMain.FCWM_ColDPanel.Top:=CFRxmlCfgItm.Attributes['cfacY'];
      end
      else if not FCVwMcolfacPstore
      then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=20;
         FCWinMain.FCWM_ColDPanel.Top:=80;
      end;
      FCVwMcpsPstore:=CFRxmlCfgItm.Attributes['cpsStore'];
      if assigned(FCcps)
         and (FCVwMcpsPstore)
      then
      begin
         FCcps.CPSpX:=CFRxmlCfgItm.Attributes['cpsX'];
         FCcps.CPSpY:=CFRxmlCfgItm.Attributes['cpsY'];
      end
      else if not assigned(FCcps)
         and (FCVwMcpsPstore)
      then
      begin
         FCWinMain.FCGLSHUDcpsCredL.Tag:=CFRxmlCfgItm.Attributes['cpsX'];
         FCWinMain.FCGLSHUDcpsTlft.Tag:=CFRxmlCfgItm.Attributes['cpsY'];
      end;
		FCVwMhelpPstore:=CFRxmlCfgItm.Attributes['helpStore'];
      if FCVwMhelpPstore
      then
      begin
         FCWinMain.FCWM_HelpPanel.Left:=CFRxmlCfgItm.Attributes['helpX'];
         FCWinMain.FCWM_HelpPanel.Top:=CFRxmlCfgItm.Attributes['helpY'];
      end;
	end;
   {.read the graphic setting}
   CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('gfx');
   if CFRxmlCfgItm<>nil
   then
   begin
      FCVwinWideScr:=CFRxmlCfgItm.Attributes['wide'];
      FCV3DstdTresHR:=CFRxmlCfgItm.Attributes['hrstdt'];
   end;
   {.read the current game data}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
	if CFRxmlCfgItm<>nil
   then
   begin
      FCRplayer.P_gameName:=CFRxmlCfgItm.Attributes['gname'];
      if CFRreadGtime
      then
      begin
         FCRplayer.P_timeTick:=CFRxmlCfgItm.Attributes['tfTick'];
         FCRplayer.P_timeMin:=CFRxmlCfgItm.Attributes['tfMin'];
         FCRplayer.P_timeHr:=CFRxmlCfgItm.Attributes['tfHr'];
         FCRplayer.P_timeday:=CFRxmlCfgItm.Attributes['tfDay'];
         FCRplayer.P_timeMth:=CFRxmlCfgItm.Attributes['tfMth'];
         FCRplayer.P_timeYr:=CFRxmlCfgItm.Attributes['tfYr'];
      end;
   end;
   {.read the debug info}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('debug');
	if CFRxmlCfgItm<>nil
   then FCGdebug:=CFRxmlCfgItm.Attributes['dswitch'];
	{.free the memory}
	FCWinMain.FCXMLcfg.Active:=false;
	FCWinMain.FCXMLcfg.FileName:='';
end;

procedure FCMdF_ConfigFile_Write(const CFWupdGtime:boolean);
{:Purpose: write the data in the .xml configuration file.
   Additions:
      -2010Sep07- *add: current game time frame is now in the configuration file.
                  *add: CFWupdGtime switch.
      -2010Jun14- *add: colony/faction panel location.
      -2010Jun08- *mod: regroup mainwin data.
                  *add: cps + help panel location.
      -2010Jan20- *add: debug data.
      -2010Jan11- *add: FCV3DstdTresHR.
      -2009Nov18- *add wide screen option.
      -2009Nov08- *add current game game.
}
var
   CFWtimeday
   ,CFWtimeHr
   ,CFWtimeMin
   ,CFWtimeMth
   ,CFWtimeTick
   ,CFWtimeYr: integer;

	CFWxmlRoot,
	CFWxmlCfgItm: IXMLNode;
begin
   {.clear the old file if it exists}
   if FileExists(FCVpathCfg)
   then
   begin
      if FCRplayer.P_gameName<>''
      then
      begin
         {.read the document}
         FCWinMain.FCXMLcfg.FileName:=FCVpathCfg;
         FCWinMain.FCXMLcfg.Active:=true;
         CFWxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
         if CFWxmlCfgItm<>nil
         then
         begin
            CFWtimeTick:=CFWxmlCfgItm.Attributes['tfTick'];
            CFWtimeMin:=CFWxmlCfgItm.Attributes['tfMin'];
            CFWtimeHr:=CFWxmlCfgItm.Attributes['tfHr'];
            CFWtimeday:=CFWxmlCfgItm.Attributes['tfDay'];
            CFWtimeMth:=CFWxmlCfgItm.Attributes['tfMth'];
            CFWtimeYr:=CFWxmlCfgItm.Attributes['tfYr'];
         end;
         {.free the memory}
         FCWinMain.FCXMLcfg.Active:=false;
         FCWinMain.FCXMLcfg.FileName:='';
      end;
      DeleteFile(pchar(FCVpathCfg));
   end;
   {.create the document}
   FCWinMain.FCXMLcfg.Active:=true;
   {.create the root node of the configuration file}
   CFWxmlRoot:=FCWinMain.FCXMLcfg.AddChild('configfile');
   {.create the config item "locale"}
   CFWxmlCfgItm:= CFWxmlRoot.AddChild('locale');
   CFWxmlCfgItm.Attributes['lang']:= FCVlang;
   {.create the config item "mainwin"}
   CFWxmlCfgItm:= CFWxmlRoot.AddChild('mainwin');
   CFWxmlCfgItm.Attributes['mwwidth']:= FCVwinMsizeW;
   CFWxmlCfgItm.Attributes['mwheight']:= FCVwinMsizeH;
   CFWxmlCfgItm.Attributes['mwlft']:= FCVwinMlocL;
   CFWxmlCfgItm.Attributes['mwtop']:= FCVwinMlocT;
   {.create the config item "panels"}
	CFWxmlCfgItm:=CFWxmlRoot.AddChild('panels');
   CFWxmlCfgItm.Attributes['colfacStore']:=FCVwMcolfacPstore;
   if FCVwMcolfacPstore
   then begin
      CFWxmlCfgItm.Attributes['cfacX']:=FCWinMain.FCWM_ColDPanel.Left;
      CFWxmlCfgItm.Attributes['cfacY']:=FCWinMain.FCWM_ColDPanel.Top;
   end
   else
   begin
      CFWxmlCfgItm.Attributes['cfacX']:=20;
      CFWxmlCfgItm.Attributes['cfacY']:=80;
   end;
   CFWxmlCfgItm.Attributes['cpsStore']:=FCVwMcpsPstore;
   if not FCVwMcpsPstore
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=0;
      CFWxmlCfgItm.Attributes['cpsY']:=0;
   end
   else if assigned(FCcps)
      and (FCVwMcpsPstore)
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=FCcps.CPSobjPanel.Left;
      CFWxmlCfgItm.Attributes['cpsY']:=FCcps.CPSobjPanel.Top;
   end
   else if not assigned(FCcps)
      and (FCVwMcpsPstore)
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=2;
      CFWxmlCfgItm.Attributes['cpsY']:=40;
   end;
   CFWxmlCfgItm.Attributes['helpStore']:=FCVwMhelpPstore;
   if FCVwMhelpPstore
   then begin
      CFWxmlCfgItm.Attributes['helpX']:=FCWinMain.FCWM_HelpPanel.Left;
      CFWxmlCfgItm.Attributes['helpY']:=FCWinMain.FCWM_HelpPanel.Top;
   end
   else
   begin
      CFWxmlCfgItm.Attributes['helpX']:=0;
      CFWxmlCfgItm.Attributes['helpY']:=0;
   end;
   {.create the graphic setting}
   CFWxmlCfgItm:=CFWxmlRoot.AddChild('gfx');
   CFWxmlCfgItm.Attributes['wide']:=FCVwinWideScr;
   CFWxmlCfgItm.Attributes['hrstdt']:=FCV3DstdTresHR;
   {.create the current game data}
	CFWxmlCfgItm:=CFWxmlRoot.AddChild('currGame');
	CFWxmlCfgItm.Attributes['gname']:=FCRplayer.P_gameName;
   if (CFWupdGtime)
      and (FCRplayer.P_gameName<>'')
   then
   begin
      CFWxmlCfgItm.Attributes['tfTick']:= FCRplayer.P_timeTick;
      CFWxmlCfgItm.Attributes['tfMin']:= FCRplayer.P_timeMin;
      CFWxmlCfgItm.Attributes['tfHr']:= FCRplayer.P_timeHr;
      CFWxmlCfgItm.Attributes['tfDay']:= FCRplayer.P_timeday;
      CFWxmlCfgItm.Attributes['tfMth']:= FCRplayer.P_timeMth;
      CFWxmlCfgItm.Attributes['tfYr']:= FCRplayer.P_timeYr;
   end
   else if (CFWupdGtime)
      and (FCRplayer.P_gameName='')
   then
   begin
      CFWxmlCfgItm.Attributes['tfTick']:=0;
      CFWxmlCfgItm.Attributes['tfMin']:=0;
      CFWxmlCfgItm.Attributes['tfHr']:=0;
      CFWxmlCfgItm.Attributes['tfDay']:=0;
      CFWxmlCfgItm.Attributes['tfMth']:=0;
      CFWxmlCfgItm.Attributes['tfYr']:=0;
   end
   else if not CFWupdGtime
   then
   begin
      CFWxmlCfgItm.Attributes['tfTick']:=CFWtimeTick;
      CFWxmlCfgItm.Attributes['tfMin']:=CFWtimeMin;
      CFWxmlCfgItm.Attributes['tfHr']:=CFWtimeHr;
      CFWxmlCfgItm.Attributes['tfDay']:=CFWtimeday;
      CFWxmlCfgItm.Attributes['tfMth']:=CFWtimeMth;
      CFWxmlCfgItm.Attributes['tfYr']:=CFWtimeYr;
   end;
   {.create the debug info}
	CFWxmlCfgItm:=CFWxmlRoot.AddChild('debug');
	CFWxmlCfgItm.Attributes['dswitch']:=FCGdebug;
   {.write the file and free the memory}
   FCWinMain.FCXMLcfg.SaveToFile(FCVpathCfg);
   FCWinMain.FCXMLcfg.Active:=false;
end;

function FCFdF_DBFactCred_FStr(const DBFCFScred: string): TFCEcrIntRg;
{:Purpose: retrieve the TFCEcrIntRg / credit-interest range from the corresponding string.
    Additions:
}
begin
   Result:= crirPoor_Insign;
   if DBFCFScred='crirPoor_Insign'
   then Result:= crirPoor_Insign
   else if DBFCFScred='crirUndFun_Low'
   then Result:= crirUndFun_Low
   else if DBFCFScred='crirBelAvg_Mod'
   then Result:= crirBelAvg_Mod
   else if DBFCFScred='crirAverage'
   then Result:= crirAverage
   else if DBFCFScred='crirAbAvg_Maj'
   then Result:= crirAbAvg_Maj
   else if DBFCFScred='crirRch_High'
   then Result:= crirRch_High
   else if DBFCFScred='crirOvrFun_Usu'
   then Result:= crirOvrFun_Usu
   else if DBFCFScred='crirUnl_Ins'
   then Result:= crirUnl_Ins;
end;

function FCFdF_DBFactStat_FStr(const DBFSFSstatus: string): TFCEfacStat;
{:Purpose: retrieve the TFCEfacStat from the corresponding string.
    Additions:
}
begin
   Result:= fs0NViable;
   if DBFSFSstatus='fs0NViable'
   then Result:= fs0NViable
   else if DBFSFSstatus='fs1StabFDep'
   then Result:= fs1StabFDep
   else if DBFSFSstatus='fs2DepVar'
   then Result:= fs2DepVar
   else if DBFSFSstatus='fs3Indep'
   then Result:= fs3Indep;
end;

procedure FCMdF_DBFactions_Read;
{:Purpose: read the factions database xml file.
   Additions:
      -2011Apr25- *mod: XML refactoring and clarifications for equipment items.
                  *code: clarifications.
                  *add: product equipment item.
      -2010Nov28- *add: fix and complete meme data loading.
      -2010Nov02- *mod: change the meme detection for faction's SPM.
                  *add: SPMi duration.
      -2010Oct06- *add: memes values + policy status.
      -2010Sep30- *fix: SPM setting loading.
      -2010Sep23- *add: SPM setting.
      -2010Sep21- *mod: replace faction type by the faction level.
      -2010Mar11- *fix: viability objective type bugfix.
      -2010Mar10- *add: cps viability objectives.
      -2010Mar07- *add: docking information for space units.
      -2010Mar04- *add: CPS data.
      -2010Mar03- *add: colonization modes.
                  *mod: put the dotation items inside colonization mode structure.
      -2009Oct20- *add item current available energy/reaction mass.
      -2009Sep23- *add owned space unit proper name.
      -2009Sep15- *initialize dotation and starting location lists.
      -2009Sep12- *completion of dotation list loading.
                  *add starting location list loading.
      -2009Sep11- *add dotation list.
      -2009Aug28- *support now #comment by bypassing them.
      -2009Aug09- *clear faction data structure before loading.
                  *load data in the data structure.
}
const
   DBFRblocCnt=512;
var
   DBFRviabObjCnt: integer;
   DBFRfacItem
   ,DBFRfacSubItem
   ,DBFRfacEquipItm
   ,DBFRspmItm: IXMLNode;

   DBFRitmCnt
   ,DBFRequItmCnt
   ,DBFRstartLocCnt
   ,DBFRspmiCnt
   ,DBFRcolMdCnt
   ,DBFRdockRoot
   ,DBFRdockDmp: Integer;

   DBFRdoItmDmpStr
   ,DBFRspmiStr: string;
begin
	{.clear the data structure}
	DBFRitmCnt:=1;
	while DBFRitmCnt<= Length(FCDBfactions)-1 do
	begin
		FCDBfactions[DBFRitmCnt]:=FCDBfactions[0];
      setlength(FCDBfactions[DBFRitmCnt].F_facCmode,0);
      setlength(FCDBfactions[DBFRitmCnt].F_facStartLocList,0);
      setlength(FCDBfactions[DBFRitmCnt].F_spm,0);
		inc(DBFRitmCnt);
	end;
	DBFRitmCnt:=1;
   DBFRequItmCnt:=0;
	{.read the document}
	FCWinMain.FCXMLdbFac.FileName:=FCVpathXML+'\env\factionsdb.xml';
	FCWinMain.FCXMLdbFac.Active:=true;
	DBFRfacItem:= FCWinMain.FCXMLdbFac.DocumentElement.ChildNodes.First;
	while DBFRfacItem<>nil do
	begin
      if DBFRfacItem.NodeName<>'#comment'
      then
      begin
         DBFRcolMdCnt:=0;
         DBFRstartLocCnt:=0;
         DBFRspmiCnt:=0;
         setlength(FCDBfactions[DBFRitmCnt].F_facCmode, 1);
         setlength(FCDBfactions[DBFRitmCnt].F_facStartLocList, 1);
         setlength(FCDBfactions[DBFRitmCnt].F_spm,1);
         {.faction token}
         FCDBfactions[DBFRitmCnt].F_token:=DBFRfacItem.Attributes['token'];
         FCDBfactions[DBFRitmCnt].F_lvl:=DBFRfacItem.Attributes['level'];
         {.faction data processing loop}
         DBFRfacSubItem:= DBFRfacItem.ChildNodes.First;
         while DBFRfacSubItem<>nil do
         begin
            if DBFRfacSubItem.NodeName='facColMode'
            then
            begin
               DBFRdockRoot:=0;
               DBFRviabObjCnt:=0;
               DBFRequItmCnt:=0;
               inc(DBFRcolMdCnt);
               SetLength(FCDBfactions[DBFRitmCnt].F_facCmode, DBFRcolMdCnt+1);
               {.colonization mode token}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_token:=DBFRfacSubItem.Attributes['token'];
               {.starting status - econ}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsEconS:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['sstateco']);
               {.starting status - soc}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsSocS:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['sstatsoc']);
               {.starting status - mil}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsMilS:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['sstatmil']);
               {.max status - econ}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsEconM:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['mstateco']);
               {.max status - soc}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsSocM:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['mstatsoc']);
               {.max status - mil}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsMilM:=FCFdF_DBFactStat_FStr(DBFRfacSubItem.Attributes['mstatmil']);
               {.credit range}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsCrRg:=FCFdF_DBFactCred_FStr(DBFRfacSubItem.Attributes['creditrng']);
               {.interest range}
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsIntRg:=FCFdF_DBFactCred_FStr(DBFRfacSubItem.Attributes['intrng']);
               {.equipment list items}
               DBFRfacEquipItm:=DBFRfacSubItem.ChildNodes.First;
               while DBFRfacEquipItm<>nil do
               begin
                  {.viability objectives}
                  if DBFRfacEquipItm.NodeName='facViabObj'
                  then
                  begin
                     inc(DBFRviabObjCnt);
                     SetLength(FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj, DBFRviabObjCnt+1);
                     {.viability type}
                     DBFRdoItmDmpStr:=DBFRfacEquipItm.Attributes['objTp'];
                     if DBFRdoItmDmpStr='cpsotEcoEnEff'
                     then FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp
                        :=cpsotEcoEnEff
                     else if DBFRdoItmDmpStr='cpsotEcoLowCr'
                     then FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp
                        :=cpsotEcoLowCr
                     else if DBFRdoItmDmpStr='cpsotEcoSustCol'
                     then FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp
                        :=cpsotEcoSustCol
                     else if DBFRdoItmDmpStr='cpsotSocSecPop'
                     then FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp
                        :=cpsotSocSecPop;
                  end
                  {.equipment items list}
                  else if DBFRfacEquipItm.NodeName='facEqupItm'
                  then
                  begin
                     inc(DBFRequItmCnt);
                     if DBFRequItmCnt >= Length(FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList)
                     then SetLength
                        (
                           FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList
                           , Length(FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList)+DBFRblocCnt
                        );
                     DBFRdoItmDmpStr:=DBFRfacEquipItm.Attributes['itemTp'];
                     if DBFRdoItmDmpStr='feitProduct'
                     then
                     begin
                        //WATCH OUT COPY/PASTE
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_itemType:=feitProduct;
                        {.product token}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_prodToken:=DBFRfacEquipItm.Attributes['prodToken'];
                        {.number of unit}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_prodUnit:=DBFRfacEquipItm.Attributes['unit'];
                        {.carried by}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_prodCarriedBy:=DBFRfacEquipItm.Attributes['carriedBy'];
                     end
                     {.space unit}
                     else if DBFRdoItmDmpStr='feitSpaceCraft'
                     then
                     begin
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_itemType:=feitSpaceUnit;
                        {.proper name token}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_spuProperNameToken:=DBFRfacEquipItm.Attributes['properName'];
                        {.design token id}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_spuDesignToken:=DBFRfacEquipItm.Attributes['designToken'];
                        {.status}
                           FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_spuStatus:=DBFRfacEquipItm.Attributes['status'];
                        {.dock status}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_spuDockInfo:=DBFRfacEquipItm.Attributes['spuDock'];
                        {.current available energy / reaction mass}
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList[DBFRequItmCnt].FCMEI_spuAvailEnRM:=DBFRfacEquipItm.Attributes['availEnRM'];
                     end;
                  end;
                  DBFRfacEquipItm:=DBFRfacEquipItm.NextSibling;
               end; //==END== while DBFRfacDotItm<>nil ==//
               SetLength(FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_dotList, DBFRequItmCnt+1);
            end //==END== else if DBFRfacSubItem.NodeName='facColMode' ==//
            else if DBFRfacSubItem.NodeName='facStartLoc'
            then
            begin
               inc(DBFRstartLocCnt);
               if DBFRstartLocCnt >= Length(FCDBfactions[DBFRitmCnt].F_facStartLocList)
               then SetLength
                  (FCDBfactions[DBFRitmCnt].F_facStartLocList, Length(FCDBfactions[DBFRitmCnt].F_facStartLocList)+DBFRblocCnt);
               {.starting location - star system}
               FCDBfactions[DBFRitmCnt].F_facStartLocList[DBFRstartLocCnt].FSL_locSSys:=DBFRfacSubItem.Attributes['locSSys'];
               {.starting location - star}
               FCDBfactions[DBFRitmCnt].F_facStartLocList[DBFRstartLocCnt].FSL_locStar:=DBFRfacSubItem.Attributes['locStar'];
               {.dotation item location - orbital object}
               FCDBfactions[DBFRitmCnt].F_facStartLocList[DBFRstartLocCnt].FSL_locObObj:=DBFRfacSubItem.Attributes['locObObj'];
            end
            else if DBFRfacSubItem.NodeName='facSPM'
            then
            begin
               DBFRspmItm:=DBFRfacSubItem.ChildNodes.First;
               while DBFRspmItm<>nil do
               begin
                  SetLength(FCDBfactions[DBFRitmCnt].F_spm, length(FCDBfactions[DBFRitmCnt].F_spm)+1);
                  inc(DBFRspmiCnt);
                  FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_token:=DBFRspmItm.Attributes['token'];
                  FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_duration:=DBFRspmItm.Attributes['duration'];
                  FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_isPolicy:=true;
                  FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_isSet:=DBFRspmItm.Attributes['isSet'];
                  FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_aprob:=DBFRspmItm.Attributes['aprob'];
                  if FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_aprob=-2
                  then
                  begin
                     FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_isPolicy:=false;
                     DBFRspmiStr:=DBFRspmItm.Attributes['belieflev'];
                     if DBFRspmiStr='dgUnknown'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgUnknown
                     else if DBFRspmiStr='dgFleeting'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgFleeting
                     else if DBFRspmiStr='dgUncommon'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgUncommon
                     else if DBFRspmiStr='dgCommon'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgCommon
                     else if DBFRspmiStr='dgStrong'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgStrong
                     else if DBFRspmiStr='dgKbyAll'
                     then FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_bLvl:=dgKbyAll;
                     FCDBfactions[DBFRitmCnt].F_spm[DBFRspmiCnt].SPMS_sprdVal:=DBFRspmItm.Attributes['spreadval'];
                  end;
                  DBFRspmItm:=DBFRspmItm.NextSibling;
               end; //==END== while DBFRspmItm<>nil ==//
            end;
            DBFRfacSubItem:= DBFRfacSubItem.NextSibling;
         end; //==END== while DBFRfacSubItem<>nil ==//
         {.resize to real table size}
         SetLength(FCDBfactions[DBFRitmCnt].F_facCmode, DBFRcolMdCnt+1);
         SetLength(FCDBfactions[DBFRitmCnt].F_facStartLocList, DBFRstartLocCnt+1);
         inc(DBFRitmCnt);
      end; //==END== if DBFRfacItem.NodeName<>'#comment' ==//
      DBFRfacItem:= DBFRfacItem.NextSibling;
	end;{.while DBFRfacitem<>nil}
	{.disable}
	FCWinMain.FCXMLdbFac.Active:=false;
end;

procedure FCMdF_DBInfra_Read;
{:Purpose: Read the infrastructure database xml file.
    Additions:
      -2011Jul17- *add: 2 custom effects: energy generation and energy storage.
      -2011Jul11- *add: base power.
      -2011May19- *add/mod: complete the custom effect: product storage.
      -2011May15- *add: only load level data concerning the current infrastructure level range.
                  *mod: the VolMat line is now only loaded for built infrastructures.
                  *rem: the life support custom effects are removed (useless).
      -2011May13- *add: function energy / fission - add fixed values for each infrastructure levels.
      -2011May12- *add: custom effect - product storage.
      -2011Apr24- *add: 'any' environment for particular multi-environment infrastructures.
                  *add: energy function - nuclear fission - fixed production data.
      -2011Apr17- *rem: research stage requirement is removed (useless).
                  *fix: construction material section is corrected.
      -2011Mar14- *add: new mode of energy generation.
      -2011Mar07- *add: environment.
      -2011Mar02- *add: custom effects section initialization.
                  *add: basic/primary/secondary HQ + life support Food/Oxygen/Water custom effects.
      -2011Feb27- *add: resource spot and technoscience requirement.
                  *add: energy, housing and production function data.
      -2011Feb26- *add: requirements section.
                  *add: hydrosphere, construction materials and region soil requirements.
      -2011Feb24- *add: a new section <infFunc>.
                  *add: surface, volume and material volume.
                  *mod: locate the levels range in <infBuild>.
      -2011Feb22- *add: isSurfaceOnly.
      -2011Feb10- *mod: change the level by the level range.
      -2011Feb07- *add: complete functions.
}
var
   DBIRcnt
   ,DBIRcustFXcnt
   ,DBIRlevel
   ,DBIRpmodeCnt
   ,DBIRreqCMatCnt
   ,DBIRsizeCnt: integer;

   DBIRstr: string;

   DBIRnode
   ,DBIRconstMat
   ,DBIRcustFX
   ,DBIRpmode
   ,DBIRreqsub
   ,DBIRsizeN
   ,DBIRsubN: IXMLnode;
begin
   {.clear the data structure}
   FCDBinfra:=nil;
   SetLength(FCDBinfra, 1);
   DBIRcnt:=1;
   {.read the document}
	FCWinMain.FCXMLdbInfra.FileName:=FCVpathXML+'\env\infrastrucdb.xml';
	FCWinMain.FCXMLdbInfra.Active:=true;
	DBIRnode:=FCWinMain.FCXMLdbInfra.DocumentElement.ChildNodes.First;
	while DBIRnode<>nil do
	begin
      if DBIRnode.NodeName<>'#comment'
      then
      begin
         SetLength(FCDBinfra, length(FCDBinfra)+1);
         FCDBinfra[DBIRcnt].I_token:=DBIRnode.Attributes['token'];
         DBIRstr:=DBIRnode.Attributes['environment'];
         if DBIRstr='ANY'
         then FCDBinfra[DBIRcnt].I_environment:=envAny
         else if DBIRstr='FE'
         then FCDBinfra[DBIRcnt].I_environment:=freeLiving
         else if DBIRstr='RE'
         then FCDBinfra[DBIRcnt].I_environment:=restrict
         else if DBIRstr='SE'
         then FCDBinfra[DBIRcnt].I_environment:=space;
         DBIRsubN:=DBIRnode.ChildNodes.First;
         while DBIRsubN<>nil do
         begin
            if DBIRsubN.NodeName='infBuild'
            then
            begin
               DBIRstr:=DBIRsubN.Attributes['construct'];
               if DBIRstr='cBuilt'
               then FCDBinfra[DBIRcnt].I_constr:=cBuilt
               else if DBIRstr='cPrefab'
               then FCDBinfra[DBIRcnt].I_constr:=cPrefab
               else if DBIRstr='cConv'
               then FCDBinfra[DBIRcnt].I_constr:=cConv;
               FCDBinfra[DBIRcnt].I_isSurfOnly:=DBIRsubN.Attributes['isSurfOnly'];
               FCDBinfra[DBIRcnt].I_minLevel:=DBIRsubN.Attributes['minlevel'];
               FCDBinfra[DBIRcnt].I_maxLevel:=DBIRsubN.Attributes['maxlevel'];
               DBIRsizeN:=DBIRsubN.ChildNodes.First;
               while DBIRsizeN<>nil do
               begin
                  if DBIRsizeN.NodeName='ibSurf'
                  then
                  begin
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_surface[DBIRsizeCnt]:=DBIRsizeN.Attributes['surflv'+IntToStr(DBIRsizeCnt)];
                        inc(DBIRsizeCnt);
                     end;
                  end
                  else if DBIRsizeN.NodeName='ibVol'
                  then
                  begin
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_volume[DBIRsizeCnt]:=DBIRsizeN.Attributes['vollv'+IntToStr(DBIRsizeCnt)];
                        inc(DBIRsizeCnt);
                     end;
                  end
                  else if DBIRsizeN.NodeName='ibBasePwr'
                  then
                  begin
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_basePwr[DBIRsizeCnt]:=DBIRsizeN.Attributes['pwrlv'+IntToStr(DBIRsizeCnt)];
                        inc(DBIRsizeCnt);
                     end;
                  end
                  else if DBIRsizeN.NodeName='ibVolMat'
                  then
                  begin
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_surface[DBIRsizeCnt]:=DBIRsizeN.Attributes['volmatlv'+IntToStr(DBIRsizeCnt)];
                        inc(DBIRsizeCnt);
                     end;
                  end;
                  DBIRsizeN:=DBIRsizeN.NextSibling;
               end; //==END== while DBIRsizeN<>nil do ==//
            end //==END== if DBIRsubN.NodeName='infBuild' ==//
            else if DBIRsubN.NodeName='infReq'
            then
            begin
               DBIRreqsub:=DBIRsubN.ChildNodes.First;
               while DBIRreqsub<>nil do
               begin
                  if DBIRreqsub.NodeName='irHydro'
                  then
                  begin
                     DBIRstr:=DBIRreqsub.Attributes['hydrotype'];
                     if DBIRstr='hrAny'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrAny
                     else if DBIRstr='hrLiquid_LiquidNH3'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrLiquid_LiquidNH3
                     else if DBIRstr='hrNone'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrNone
                     else if DBIRstr='hrVapour'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrVapour
                     else if DBIRstr='hrLiquid'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrLiquid
                     else if DBIRstr='hrIceSheet'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrIceSheet
                     else if DBIRstr='hrCrystal'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrCrystal
                     else if DBIRstr='hrLiquidNH3'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrLiquidNH3
                     else if DBIRstr='hrCH4'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrCH4;
                  end
                  else if DBIRreqsub.NodeName='irConstrMat'
                  then
                  begin
                     SetLength(FCDBinfra[DBIRcnt].I_reqConstrMat, 1);
                     DBIRreqCMatCnt:=0;
                     DBIRconstMat:=DBIRreqsub.ChildNodes.First;
                     while DBIRconstMat<>nil do
                     begin
                        inc(DBIRreqCMatCnt);
                        SetLength(FCDBinfra[DBIRcnt].I_reqConstrMat, DBIRreqCMatCnt+1);
                        FCDBinfra[DBIRcnt].I_reqConstrMat[DBIRreqCMatCnt].RCM_token:=DBIRconstMat.Attributes['token'];
                        FCDBinfra[DBIRcnt].I_reqConstrMat[DBIRreqCMatCnt].RCM_percent:=DBIRconstMat.Attributes['percent'];
                        DBIRconstMat:=DBIRconstMat.NextSibling;
                     end;
                  end
                  else if DBIRreqsub.NodeName='irRegionSoil'
                  then
                  begin
                     DBIRstr:=DBIRreqsub.Attributes['allowtype'];
                     if DBIRstr='rsrAny'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAny
                     else if DBIRstr='rsrAnyExceptVolcanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyExceptVolcanic
                     else if DBIRstr='rsrAnyCoastal'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyCoastal
                     else if DBIRstr='rsrAnyCoastalExceptVolcanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyCoastalExceptVolcanic
                     else if DBIRstr='rsrAnySterile'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnySterile
                     else if DBIRstr='rsrFertile'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrFertile
                     else if DBIRstr='rsOceanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsOceanic;
                  end
                  else if DBIRreqsub.NodeName='irRsrcSpot'
                  then
                  begin
                     DBIRstr:=DBIRreqsub.Attributes['spottype'];
                     if DBIRstr='rssrN_A'
                     then FCDBinfra[DBIRcnt].I_reqRsrcSpot:=rssrN_A
                     else if DBIRstr='rssrany'
                     then FCDBinfra[DBIRcnt].I_reqRsrcSpot:=rssrany
                     else if DBIRstr='rssrMetalIcyRareMetCarbRadOre'
                     then FCDBinfra[DBIRcnt].I_reqRsrcSpot:=rssrMetalIcyRareMetCarbRadOre;
                  end
                  else if DBIRreqsub.NodeName='irTechSci'
                  then
                  begin
                     DBIRstr:=DBIRreqsub.Attributes['sector'];
                     if DBIRstr='rsNone'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsNone
                     else if DBIRstr='rsAerospaceEng'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsAerospaceEng
                     else if DBIRstr='rsBiogenetics'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsBiogenetics
                     else if DBIRstr='rsEcosciences'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsEcosciences
                     else if DBIRstr='rsIndustrialTech'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsIndustrialTech
                     else if DBIRstr='rsMedicine'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsMedicine
                     else if DBIRstr='rsNanotech'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsNanotech
                     else if DBIRstr='rsPhysics'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsPhysics;
                     FCDBinfra[DBIRcnt].I_reqTechSci.RTS_token:=DBIRreqsub.Attributes['token'];
                  end;
                  DBIRreqsub:=DBIRreqsub.NextSibling;
               end; //==END== while DBIRreqsub<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infReq' ==//
            else if DBIRsubN.NodeName='infCustFX'
            then
            begin
               SetLength(FCDBinfra[DBIRcnt].I_customFx, 1);
               DBIRcustFXcnt:=0;
               DBIRcustFX:=DBIRsubN.ChildNodes.First;
               while DBIRcustFX<>nil do
               begin
                  inc(DBIRcustFXcnt);
                  SetLength(FCDBinfra[DBIRcnt].I_customFx, DBIRcustFXcnt+1);
                  if DBIRcustFX.NodeName='icfxEnergyGen'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxEnergyGen;

                     DBIRstr:=DBIRsubN.Attributes['genMode'];
                     if DBIRstr='egmAntimatter'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmAntimatter
                     else if DBIRstr='egmFission'
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmFission;
                        DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                        while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                        begin
                           FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_fissionFPlvl[DBIRsizeCnt]:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)];
                           FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_fissionFPlvlByDL[DBIRsizeCnt]:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)+'byDL'];
                           inc(DBIRsizeCnt);
                        end;
                     end
                     else if DBIRstr='egmFusionDT'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmFusionDT
                     else if DBIRstr='egmFusionH2'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmFusionH2
                     else if DBIRstr='egmFusionHe3'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmFusionHe3
                     else if DBIRstr='egmPhoton'
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_productionModes:=egmPhoton;
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_photonArea:=DBIRsubN.Attributes['area'];
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_photonEfficiency:=DBIRsubN.Attributes['efficiency'];
                     end;
                  end
                  else if DBIRcustFX.NodeName='cfxEnergyStor'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxEnergyStor;
                     DBIRlevel:=DBIRcustFX.Attributes['storlevel'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enStorLvl[DBIRlevel]:=DBIRcustFX.Attributes['storCapacity'];
                  end
                  else if DBIRcustFX.NodeName='icfxHQbasic'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxHQPrimary
                  else if DBIRcustFX.NodeName='icfxHQSecondary'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxHQbasic
                  else if DBIRcustFX.NodeName='icfxHQPrimary'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxHQSecondary
                  else if DBIRcustFX.NodeName='cfxProductStorage'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=cfxProductStorage;
                     DBIRlevel:=DBIRcustFX.Attributes['storlevel'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_solid:=DBIRcustFX.Attributes['storSolid'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_liquid:=DBIRcustFX.Attributes['storLiquid'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_gas:=DBIRcustFX.Attributes['storGas'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_biologic:=DBIRcustFX.Attributes['storBio'];
                  end;
                  DBIRcustFX:=DBIRcustFX.NextSibling;
               end; //==END== while DBIRcustFX<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infCustFX' ==//
            else if DBIRsubN.NodeName='infFunc'
            then
            begin
               DBIRstr:=DBIRsubN.Attributes['infFunc'];
               if DBIRstr='fEnergy'
               then
               begin
                  FCDBinfra[DBIRcnt].I_function:=fEnergy;
                  DBIRstr:=DBIRsubN.Attributes['emode'];
                  if DBIRstr='egmAntimatter'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmAntimatter
						else if DBIRstr='egmFission'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmFission;
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_fissionFPlvl[DBIRsizeCnt]:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)];
                        FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_fissionFPlvlByDL[DBIRsizeCnt]:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)+'byDL'];
                        inc(DBIRsizeCnt);
                     end;
                  end
						else if DBIRstr='egmFusionDT'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmFusionDT
						else if DBIRstr='egmFusionH2'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmFusionH2
						else if DBIRstr='egmFusionHe3'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmFusionHe3
                  else if DBIRstr='egmPhoton'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_productionModes:=egmPhoton;
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_photonArea:=DBIRsubN.Attributes['area'];
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_photonEfficiency:=DBIRsubN.Attributes['efficiency'];
                  end;
               end
               else if DBIRstr='fHousing'
               then
               begin
                  FCDBinfra[DBIRcnt].I_function:=fHousing;
                  FCDBinfra[DBIRcnt].I_fHousPopulationCap:=DBIRsubN.Attributes['pcap'];
                  FCDBinfra[DBIRcnt].I_fHousQualityOfLife:=DBIRsubN.Attributes['qol'];
               end
               else if DBIRstr='fIntelligence'
               then FCDBinfra[DBIRcnt].I_function:=fIntelligence
               else if DBIRstr='fMiscellaneous'
               then FCDBinfra[DBIRcnt].I_function:=fMiscellaneous
               else if DBIRstr='fProduction'
               then
               begin
                  FCDBinfra[DBIRcnt].I_function:=fProduction;
                  DBIRpmode:=DBIRsubN.ChildNodes.First;
                  DBIRpmodeCnt:=1;
                  while DBIRpmodeCnt<=FCCpModeMax do
                  begin
                     FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmNone;
                     FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_roofArea:=0;
                     FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_trapArea:=0;
                     inc(DBIRpmodeCnt);
                  end;
                  DBIRpmodeCnt:=0;
                  while DBIRpmode<>nil do
                  begin
                     inc(DBIRpmodeCnt);
                     DBIRstr:=DBIRpmode.Attributes['pmode'];
                     if DBIRstr='pmCarbonaceousOreRefining'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmCarbonaceousOreRefining
                     else if DBIRstr='pmHumidityGathering'
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmHumidityGathering;
                        FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_roofArea:=DBIRpmode.Attributes['roofArea'];
                        FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_trapArea:=DBIRpmode.Attributes['trapArea'];
                     end
                     else if DBIRstr='pmMetallicOreRefining'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmMetallicOreRefining
                     else if DBIRstr='pmRadioactiveOreRefining'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmRadioactiveOreRefining
                     else if DBIRstr='pmRareMetalsOreRefining'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmRareMetalsOreRefining
                     else if DBIRstr='pmResourceMining'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmResourceMining
                     else if DBIRstr='pmWaterElectrolysis'
                     then FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmWaterElectrolysis;
                     DBIRpmode:=DBIRpmode.NextSibling;
                  end;
               end;
            end; //==END== else if DBIRsubN.NodeName='infFunc' ==//
            DBIRsubN:=DBIRsubN.NextSibling;
         end; //==END== while DBIRsubN<>nil do ==//
         inc(DBIRcnt);
      end; //==END== if DBIRnode.NodeName<>'#comment' ==//
      DBIRnode:=DBIRnode.NextSibling;
   end; //==END== while DBIRnode<>nil ==//
   {.disable}
	FCWinMain.FCXMLdbInfra.Active:=false;
end;

procedure FCMdF_DBProducts_Read;
{:Purpose: Read the products database xml file.
   Additions:
      -2011Aug28- *add: energy generation function.
      -2011May13-	*add: infrastructure kit function - add level data.
      -2011May11- *rem: environment for infrastructure kits is removed, it's the same kit for all type of environment.
      -2011May05- *add: storage type.
                  *fix: put a line of code correctly in the main loop for not prevent to load the products.
                  *fix: remove the duplicate of attributes with infrakit function.
                  *fix: for materials, load correctly the corrosive class.
      -2011Apr24- *add: infrastructure kit function.
                  *rem: energy generation function (redundancy with the infrastructure function).
      -2011Apr17- *add: technoscience requirement.
      -2011Mar15-	*rem: deletion of 2 useless tags.
                  *add: prfuManConstruction + prfuMechConstruction + prfuOxygen + prfuWater functions.
                  *add: volume/unit and mass/unit
      -2011Mar14-	*add: prfuBuildingMat + prfuEnergyGeneration + prfuFood + prfuMultipurposeMat + prfuSpaceMat functions.
}
{:DEV NOTES: WARNING: when updating one material function, update all the other ones too.}
var
	DBPRcnt: integer;

	DBPRdumpStr: string;

	DBPRnode
	,DBPRsub
	,DBPRtag: IXMLNode;
begin
   FCDBProducts:=nil;
   SetLength(FCDBProducts, 1);
   DBPRcnt:=0;
   {.read the document}
   FCWinMain.FCXMLdbProducts.FileName:=FCVpathXML+'\env\productsdb.xml';
   FCWinMain.FCXMLdbProducts.Active:=true;
   DBPRnode:= FCWinMain.FCXMLdbProducts.DocumentElement.ChildNodes.First;
   while DBPRnode<>nil do
   begin
      if DBPRnode.NodeName<>'#comment'
      then
      begin
         inc(DBPRcnt);
         SetLength(FCDBProducts, DBPRcnt+1);
         FCDBProducts[DBPRcnt].PROD_token:=DBPRnode.Attributes['token'];
         DBPRdumpStr:=DBPRnode.Attributes['class'];
         if DBPRdumpStr='prclResource'
         then FCDBProducts[DBPRcnt].PROD_class:=prclResource
         else if DBPRdumpStr='prcEnergyRelItem'
         then FCDBProducts[DBPRcnt].PROD_class:=prcEnergyRelItem
         else if DBPRdumpStr='prcMaterial'
         then FCDBProducts[DBPRcnt].PROD_class:=prcMaterial
         else if DBPRdumpStr='prcBioproduct'
         then FCDBProducts[DBPRcnt].PROD_class:=prcBioproduct
         else if DBPRdumpStr='prcEquipment'
         then FCDBProducts[DBPRcnt].PROD_class:=prcEquipment;
         DBPRdumpStr:=DBPRnode.Attributes['storage'];
         if DBPRdumpStr='stSolid '
         then FCDBProducts[DBPRcnt].PROD_storage:=stSolid
         else if DBPRdumpStr='stLiquid'
         then FCDBProducts[DBPRcnt].PROD_storage:=stLiquid
         else if DBPRdumpStr='stGas'
         then FCDBProducts[DBPRcnt].PROD_storage:=stGas
         else if DBPRdumpStr='stBiologic'
         then FCDBProducts[DBPRcnt].PROD_storage:=stBiologic;
         DBPRdumpStr:=DBPRnode.Attributes['cargo'];
         {:DEV NOTE: complete cargo type loading here}
         FCDBProducts[DBPRcnt].PROD_volByUnit:=DBPRnode.Attributes['volbyunit'];
         FCDBProducts[DBPRcnt].PROD_massByUnit:=DBPRnode.Attributes['massbyunit'];
         DBPRsub:=DBPRnode.ChildNodes.First;
         while DBPRsub<>nil do
         begin
            if DBPRsub.NodeName='function'
            then
            begin
               DBPRdumpStr:=DBPRsub.Attributes['token'];
               if DBPRdumpStr='prfuBuildingMat'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuBuildingMat;
                  FCDBProducts[DBPRcnt].PROD_fBmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                  FCDBProducts[DBPRcnt].PROD_fBmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fBmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                  FCDBProducts[DBPRcnt].PROD_fBmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fBmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                  FCDBProducts[DBPRcnt].PROD_fBmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                  DBPRdumpStr:=DBPRsub.Attributes['corrosiveclass'];
                  if DBPRdumpStr='prciDpoor'
                  then FCDBProducts[DBPRcnt].PROD_fBmatCorrosiveClass:=prciDpoor
                  else if DBPRdumpStr='prciCfair'
                  then FCDBProducts[DBPRcnt].PROD_fBmatCorrosiveClass:=prciCfair
                  else if DBPRdumpStr='prciBgood'
                  then FCDBProducts[DBPRcnt].PROD_fBmatCorrosiveClass:=prciBgood
                  else if DBPRdumpStr='prciAexcellent'
                  then FCDBProducts[DBPRcnt].PROD_fBmatCorrosiveClass:=prciAexcellent;
               end
               else if DBPRdumpStr='prfuEnergyGeneration'
               then FCDBProducts[DBPRcnt].PROD_function:=prfuEnergyGeneration
               else if DBPRdumpStr='prfuFood'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuFood;
                  FCDBProducts[DBPRcnt].PROD_fFoodPoint:=DBPRsub.Attributes['foodpoint'];
               end
               else if DBPRdumpStr='prfuInfraKit'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuInfraKit;
                  FCDBProducts[DBPRcnt].PROD_fInfKitToken:=DBPRsub.Attributes['infratoken'];
                  FCDBProducts[DBPRcnt].PROD_fInfKitLevel:=DBPRsub.Attributes['infralevel'];
               end
               else if DBPRdumpStr='prfuManConstruction'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuManConstruction;
                  FCDBProducts[DBPRcnt].PROD_fManConstWCPcoef:=DBPRsub.Attributes['wcpcoef'];
               end
               else if DBPRdumpStr='prfuManufacturingMat'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuManufacturingMat;
               end
               else if DBPRdumpStr='prfuMechConstruction'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuMechConstruction;
                  FCDBProducts[DBPRcnt].PROD_fMechConstWCP:=DBPRsub.Attributes['wcp'];
                  FCDBProducts[DBPRcnt].PROD_fMechConstCrew:=DBPRsub.Attributes['crew'];
               end
               else if DBPRdumpStr='prfuMultipurposeMat'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuMultipurposeMat;
                  FCDBProducts[DBPRcnt].PROD_fMmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                  FCDBProducts[DBPRcnt].PROD_fMmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fMmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                  FCDBProducts[DBPRcnt].PROD_fMmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fMmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                  FCDBProducts[DBPRcnt].PROD_fMmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                  DBPRdumpStr:=DBPRsub.Attributes['corrosiveclass'];
                  if DBPRdumpStr='prciDpoor'
                  then FCDBProducts[DBPRcnt].PROD_fMmatCorrosiveClass:=prciDpoor
                  else if DBPRdumpStr='prciCfair'
                  then FCDBProducts[DBPRcnt].PROD_fMmatCorrosiveClass:=prciCfair
                  else if DBPRdumpStr='prciBgood'
                  then FCDBProducts[DBPRcnt].PROD_fMmatCorrosiveClass:=prciBgood
                  else if DBPRdumpStr='prciAexcellent'
                  then FCDBProducts[DBPRcnt].PROD_fMmatCorrosiveClass:=prciAexcellent;
               end
               else if DBPRdumpStr='prfuOxygen'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuOxygen;
                  FCDBProducts[DBPRcnt].PROD_fOxyPoint:=DBPRsub.Attributes['oxypoint'];
               end
               else if DBPRdumpStr='prfuSpaceMat'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuSpaceMat;
                  FCDBProducts[DBPRcnt].PROD_fSmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                  FCDBProducts[DBPRcnt].PROD_fSmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fSmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                  FCDBProducts[DBPRcnt].PROD_fSmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                  FCDBProducts[DBPRcnt].PROD_fSmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                  FCDBProducts[DBPRcnt].PROD_fSmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                  DBPRdumpStr:=DBPRsub.Attributes['corrosiveclass'];
                  if DBPRdumpStr='prciDpoor'
                  then FCDBProducts[DBPRcnt].PROD_fSmatCorrosiveClass:=prciDpoor
                  else if DBPRdumpStr='prciCfair'
                  then FCDBProducts[DBPRcnt].PROD_fSmatCorrosiveClass:=prciCfair
                  else if DBPRdumpStr='prciBgood'
                  then FCDBProducts[DBPRcnt].PROD_fSmatCorrosiveClass:=prciBgood
                  else if DBPRdumpStr='prciAexcellent'
                  then FCDBProducts[DBPRcnt].PROD_fSmatCorrosiveClass:=prciAexcellent;
               end
               else if DBPRdumpStr='prfuWater'
               then
               begin
                  FCDBProducts[DBPRcnt].PROD_function:=prfuWater;
                  FCDBProducts[DBPRcnt].PROD_fWaterPoint:=DBPRsub.Attributes['waterpoint'];
               end;
            end //==END== if DBPRsub.NodeName='function' ==//
            else if DBPRsub.NodeName='techsci'
            then
            begin
               DBPRdumpStr:=DBPRsub.Attributes['sector'];
               if DBPRdumpStr='rsNone'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsNone
               else if DBPRdumpStr='rsAerospaceEng'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsAerospaceEng
               else if DBPRdumpStr='rsBiogenetics'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsBiogenetics
               else if DBPRdumpStr='rsEcosciences'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsEcosciences
               else if DBPRdumpStr='rsIndustrialTech'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsIndustrialTech
               else if DBPRdumpStr='rsMedicine'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsMedicine
               else if DBPRdumpStr='rsNanotech'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsNanotech
               else if DBPRdumpStr='rsPhysics'
               then FCDBProducts[DBPRcnt].PROD_tsSector:=rsPhysics;
               FCDBProducts[DBPRcnt].PROD_tsToken:=DBPRsub.Attributes['token'];
            end //==END== if DBPRsub.NodeName='techsci' ==//
            else if DBPRsub.NodeName='tags'
            then
            begin
               DBPRtag:=DBPRsub.ChildNodes.First;
               while DBPRtag<>nil do
               begin
                  FCDBProducts[DBPRcnt].PROD_tagHazEnv:=false;
                  FCDBProducts[DBPRcnt].PROD_tagHazFire:=false;
                  FCDBProducts[DBPRcnt].PROD_tagHazRad:=false;
                  FCDBProducts[DBPRcnt].PROD_tagHazToxic:=false;
                  if DBPRtag.NodeName='hazEnv'
                  then FCDBProducts[DBPRcnt].PROD_tagHazEnv:=true
                  else if DBPRtag.NodeName='hazFire'
                  then FCDBProducts[DBPRcnt].PROD_tagHazFire:=true
                  else if DBPRtag.NodeName='hazRad'
                  then FCDBProducts[DBPRcnt].PROD_tagHazRad:=true
                  else if DBPRtag.NodeName='hazToxic'
                  then FCDBProducts[DBPRcnt].PROD_tagHazToxic:=true;
                  DBPRtag:=DBPRtag.NextSibling;
               end; {.while DBPRtag<>nil}
            end; //==END== if DBPRsub.NodeName='tags' ==//
            DBPRsub:= DBPRsub.NextSibling;
         end; //==END== while DBPRsub<>nil ==//
      end; //==END== if DBPRnode.NodeName<>'#comment' ==//
		DBPRnode:=DBPRnode.NextSibling;
	end; //==END== while (DBPRnode<>nil) and (DBPRnode.NodeName<>'#comment') do ==//
end;

procedure FCMdF_DBSpaceCrafts_Read;
{:Purpose: read databases concerning space units (internal structures and designs).
    Additions:
      -2010Apr10- *add: design capabilities.
      -2009Sep13- *fix final setlength.
}
const
   DBSCRblocCnt=1024;
var
   DBSCRcount
   ,DBSCRdmp
   ,DBSCRiStrcnt
   ,DBSCRiStrIdx: integer;

   DBSCRdmpStr: string;

   DBSCRnode: IXMLNode;
begin
   {.clear the data structures}
   FCDBscIntStruc:=nil;
   FCDBscDesigns:=nil;
   SetLength(FCDBscIntStruc, 1);
   SetLength(FCDBscDesigns, 1);
   DBSCRcount:=1;
   {.INTERNAL STRUCTURES}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVpathXML+'\env\scintstrucdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   DBSCRnode:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while DBSCRnode<>nil do
   begin
      if DBSCRcount >= Length(FCDBscintStruc)
      then SetLength(FCDBscintStruc, Length(FCDBscintStruc)+DBSCRblocCnt);
      if DBSCRnode.NodeName<>'#comment' then
      begin
         {.internal structure token}
         FCDBscintStruc[DBSCRcount].SCIS_token:=DBSCRnode.Attributes['token'];
         {.internal structure shape}
         DBSCRdmpStr:=DBSCRnode.Attributes['shape'];
         if DBSCRdmpStr='stAssem' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stAssem
         else if DBSCRdmpStr='stModul' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stModul
         else if DBSCRdmpStr='stSpher' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stSpher
         else if DBSCRdmpStr='stCylin' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stCylin
         else if DBSCRdmpStr='stCylSt' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stCylSt
         else if DBSCRdmpStr='stDelta' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stDelta
         else if DBSCRdmpStr='stBox' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stBox
         else if DBSCRdmpStr='stTorus' then FCDBscintStruc[DBSCRcount].SCIS_shape:=stTorus;
         {.internal structure architecture type}
         DBSCRdmpStr:=DBSCRnode.Attributes['archtp'];
         if DBSCRdmpStr='scarchtpDSV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpDSV
         else if DBSCRdmpStr='scarchtpHLV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpHLV
         else if DBSCRdmpStr='scarchtpLV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpLV
         else if DBSCRdmpStr='scarchtpLAV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpLAV
         else if DBSCRdmpStr='scarchtpOMV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpOMV
         else if DBSCRdmpStr='scarchtpSSI'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpSSI
         else if DBSCRdmpStr='scarchtpTAV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpTAV
         else if DBSCRdmpStr='scarchtpBSV'
         then FCDBscintStruc[DBSCRcount].SCIS_archTp:=scarchtpBSV;
         {.internal structure allowed control module}
         if DBSCRdmpStr='cmtCockpit'
         then FCDBscintStruc[DBSCRcount].SCIS_contMdlAllwd:=sccmtCockpit
         else if DBSCRdmpStr='cmtBridge'
         then FCDBscintStruc[DBSCRcount].SCIS_contMdlAllwd:=sccmtBridge
         else if DBSCRdmpStr='cmtUnna'
         then FCDBscintStruc[DBSCRcount].SCIS_contMdlAllwd:=sccmtUnna;
         {.internal structure length}
         FCDBscintStruc[DBSCRcount].SCIS_length:=DBSCRnode.Attributes['length'];
         {.internal structure wingspans}
         FCDBscintStruc[DBSCRcount].SCIS_wingsp:=DBSCRnode.Attributes['wgspan'];
         {.internal structure height}
         FCDBscintStruc[DBSCRcount].SCIS_height:=DBSCRnode.Attributes['height'];
         {.internal structure available volume}
         FCDBscintStruc[DBSCRcount].SCIS_availStrVol:=DBSCRnode.Attributes['availvol'];
         {.internal structure available surface}
         FCDBscintStruc[DBSCRcount].SCIS_availStrSur:=DBSCRnode.Attributes['availsur'];
         {.internal structure available spacedrive usable volume}
         FCDBscintStruc[DBSCRcount].SCIS_driveMaxVol:=DBSCRnode.Attributes['spdrvmaxvol'];
         {.internal structure available spacedrive usable surface}
         FCDBscintStruc[DBSCRcount].SCIS_driveMaxSur:=DBSCRnode.Attributes['spdrvmaxsur'];
         inc(DBSCRcount);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      DBSCRnode:= DBSCRnode.NextSibling;
   end; {.while DBSCRnode<>nil}
   {.resize to real table size}
   SetLength(FCDBscintStruc, DBSCRcount);
   FCWinMain.FCXMLdbSCraft.Active:=false;
   DBSCRcount:=1;
   {.DESIGNS}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVpathXML+'\env\scdesignsdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   DBSCRnode:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while DBSCRnode<>nil do
   begin
      if DBSCRcount >= Length(FCDBscDesigns)
      then SetLength(FCDBscDesigns, Length(FCDBscDesigns)+DBSCRblocCnt);
      if DBSCRnode.NodeName<>'#comment' then
      begin
         {.design token}
         FCDBscDesigns[DBSCRcount].SUD_token:=DBSCRnode.Attributes['token'];
         {.internal structure token linked to the current design (datastructure is cloned)}
         DBSCRdmpStr:=DBSCRnode.Attributes['intstrtoken'];
         {.retrieve internal structure db}
         DBSCRiStrcnt:=1;
         DBSCRiStrIdx:=0;
         while DBSCRiStrcnt<=Length(FCDBscIntStruc)-1 do
         begin
            if FCDBscIntStruc[DBSCRiStrcnt].SCIS_token=DBSCRdmpStr
            then
            begin
               DBSCRiStrIdx:=DBSCRiStrcnt;
               Break;
            end;
            inc(DBSCRiStrcnt);
         end;
         FCDBscDesigns[DBSCRcount].SCD_intStrClone:=FCDBscIntStruc[DBSCRiStrIdx];
         {.design used volume}
         FCDBscDesigns[DBSCRcount].SCD_usedVol:=DBSCRnode.Attributes['usedvol'];
         {.design used surface}
         FCDBscDesigns[DBSCRcount].SCD_usedSur:=DBSCRnode.Attributes['usedsurf'];
         {.design empty mass}
         FCDBscDesigns[DBSCRcount].SCD_massEmp:=DBSCRnode.Attributes['massempty'];
         {.design spacedrive isp}
         FCDBscDesigns[DBSCRcount].SCD_spDriveISP:=DBSCRnode.Attributes['spdrvISP'];
         {.design maximum reaction mass volume}
         FCDBscDesigns[DBSCRcount].SCD_spDriveRMassMaxVol:=DBSCRnode.Attributes['spdrvRMmax'];
         {.design capabilities}
         FCDBscDesigns[DBSCRcount].SUD_capInterstel:=DBSCRnode.Attributes['capInter'];
         FCDBscDesigns[DBSCRcount].SUD_capColoniz:=DBSCRnode.Attributes['capColon'];
         FCDBscDesigns[DBSCRcount].SUD_capPassngr:=DBSCRnode.Attributes['capPassgr'];
         FCDBscDesigns[DBSCRcount].SUD_capCombat:=DBSCRnode.Attributes['capCombt'];
         inc(DBSCRcount);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      DBSCRnode := DBSCRnode.NextSibling;
   end; {.while DBSCRnode<>nil}
   {.resize to real table size}
   SetLength(FCDBscDesigns, DBSCRcount);
   FCWinMain.FCXMLdbSCraft.Active:=false;
end;

procedure FCMdF_DBSPMi_Read;
{:Purpose: read SPM items database.
    Additions:
      -2011Aug14- *add: custom effects - complete EIOUT and REVTX.
      -2011Aug12- *add: custom effects.
      -2010Dec27- *rem: HQ structure: dgMirrNet removed.
                  *add: HQ structure: RTM (reorganization time modifier).
      -2010Nov14- *add: SPMI influences.
      -2010Nov09- *rem: SPMi requirement - UC - drop gravitational sphere.
      -2010Nov07- *add: SPMi requirement - faction data value.
      -2010Oct22- *add: SPMi requirements.
      -2010Sep30- *fix: data initialization correction.
                  *fix: SPMi attributes reading.
      -2010Sep28- *add: clusters and federative HQ structures.
                  *add: SPMI_isPolicy, forgot it when implemented the basic data structure.
}
const
   DBFRblocCnt=512;
var
   DBSPMIcnt
   ,DBSPMIcntCustomFx
   ,DBSPMIcntInfl
   ,DBSPMIcntReq: Integer;

   DBSPMIstr
   ,DBSPMIstr1: string;

   DBSPMIcustomFx
   ,DBSPMIinfl
   ,DBSPMIitm
   ,DBSPMIitmSub
   ,DBSPMIreq: IXMLNode;
begin
   SetLength(FCDBdgSPMi, 1);
   DBSPMIcnt:=0;
	{.read the document}
	FCWinMain.FCXMLdbSPMi.FileName:=FCVpathXML+'\env\spmdb.xml';
	FCWinMain.FCXMLdbSPMi.Active:=true;
	DBSPMIitm:= FCWinMain.FCXMLdbSPMi.DocumentElement.ChildNodes.First;
	while DBSPMIitm<>nil do
	begin
      if DBSPMIitm.NodeName<>'#comment'
      then
      begin
         inc(DBSPMIcnt);
         SetLength(FCDBdgSPMi, DBSPMIcnt+1);
         SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_req, 1);
         SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_infl, 1);
         SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList, 1);
         DBSPMIcntReq:=0;
         DBSPMIcntInfl:=0;
         DBSPMIcntCustomFx:=0;
         FCDBdgSPMi[DBSPMIcnt].SPMI_token:=DBSPMIitm.Attributes['token'];
         DBSPMIstr:=DBSPMIitm.Attributes['area'];
         if DBSPMIstr='dgADMIN'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgADMIN
         else if DBSPMIstr='dgECON'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgECON
         else if DBSPMIstr='dgMEDCA'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgMEDCA
         else if DBSPMIstr='dgSOC'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgSOC
         else if DBSPMIstr='dgSPOL'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgSPOL
         else if DBSPMIstr='dgSPI'
         then FCDBdgSPMi[DBSPMIcnt].SPMI_area:=dgSPI;
         FCDBdgSPMi[DBSPMIcnt].SPMI_isUnique2set:=DBSPMIitm.Attributes['isunique'];
         FCDBdgSPMi[DBSPMIcnt].SPMI_isPolicy:=DBSPMIitm.Attributes['ispolicy'];
         {.SPMi sub data}
         DBSPMIitmSub:=DBSPMIitm.ChildNodes.First;
         while DBSPMIitmSub<>nil do
         begin
            {.SPMi modifiers}
            if DBSPMIitmSub.NodeName='spmmod'
            then
            begin
               FCDBdgSPMi[DBSPMIcnt].SPMI_modCohes:=DBSPMIitmSub.Attributes['mcohes'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modTens:=DBSPMIitmSub.Attributes['mtens'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modSec:=DBSPMIitmSub.Attributes['msec'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modEdu:=DBSPMIitmSub.Attributes['medu'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modNat:=DBSPMIitmSub.Attributes['mnat'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modHeal:=DBSPMIitmSub.Attributes['mhealth'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modBur:=DBSPMIitmSub.Attributes['mbur'];
               FCDBdgSPMi[DBSPMIcnt].SPMI_modCorr:=DBSPMIitmSub.Attributes['mcorr'];
            end
            {.SPMI requirements}
            else if DBSPMIitmSub.NodeName='spmreq'
            then
            begin
               DBSPMIreq:=DBSPMIitmSub.ChildNodes.First;
               while DBSPMIreq<>nil do
               begin
                  SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_req, length(FCDBdgSPMi[DBSPMIcnt].SPMI_req)+1);
                  inc(DBSPMIcntReq);
                  DBSPMIstr:=DBSPMIreq.Attributes['token'];
                  if DBSPMIstr='dgBuilding'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_type:=dgBuilding;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_infToken:=DBSPMIreq.Attributes['buildtoken'];
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_percCol:=DBSPMIreq.Attributes['buildperc'];
                  end
                  else if DBSPMIstr='dgFacData'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_type:=dgFacData;
                     DBSPMIstr:=DBSPMIreq.Attributes['fdatType'];
                     if DBSPMIstr='rfdFacLv1'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv1
                     else if DBSPMIstr='rfdFacLv2'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv2
                     else if DBSPMIstr='rfdFacLv3'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv3
                     else if DBSPMIstr='rfdFacLv4'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv4
                     else if DBSPMIstr='rfdFacLv5'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv5
                     else if DBSPMIstr='rfdFacLv6'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv6
                     else if DBSPMIstr='rfdFacLv7'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv7
                     else if DBSPMIstr='rfdFacLv8'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv8
                     else if DBSPMIstr='rfdFacLv9'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacLv9
                     else if DBSPMIstr='rfdFacStab'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdFacStab
                     else if DBSPMIstr='rfdInstrLv'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdInstrLv
                     else if DBSPMIstr='rfdLifeQ'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdLifeQ
                     else if DBSPMIstr='rfdEquil'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datTp:=rfdEquil;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_datValue:=DBSPMIreq.Attributes['fdatValue'];
                  end
                  else if DBSPMIstr='dgTechSci'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_type:=dgTechSci;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_tsToken:=DBSPMIreq.Attributes['tstoken'];
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_masterLvl:=DBSPMIreq.Attributes['tsmastlvl'];
                  end
                  else if DBSPMIstr='dgUC'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_type:=dgUC;
                     DBSPMIstr:=DBSPMIreq.Attributes['ucmethod'];
                     if DBSPMIstr='dgFixed'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgFixed
                     else if DBSPMIstr='dgFixed_yr'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgFixed_yr
                     else if DBSPMIstr='dgCalcPop'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgCalcPop
                     else if DBSPMIstr='dgCalcPop_yr'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgCalcPop_yr
                     else if DBSPMIstr='dgCalcCol'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgCalcCol
                     else if DBSPMIstr='dgCalcCol_yr'
                     then FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucMethod:=dgCalcCol_yr;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_req[DBSPMIcntReq].SPMIR_ucVal:=DBSPMIreq.Attributes['ucval'];
                  end;
                  DBSPMIreq:=DBSPMIreq.NextSibling;
               end; //==END== while DBSPMIreq<>nil do ==//
            end //==END== else if DBSPMIitmSub.NodeName='spmreq' ==//
            {.HeadQuarter data}
            else if DBSPMIitmSub.NodeName='spmHQ'
            then
            begin
               DBSPMIstr:=DBSPMIitmSub.Attributes['hqstruc'];
               if DBSPMIstr='dgCentral'
               then FCDBdgSPMi[DBSPMIcnt].SPMI_hqStruc:=dgCentral
               else if DBSPMIstr='dgClust'
               then FCDBdgSPMi[DBSPMIcnt].SPMI_hqStruc:=dgClust
               else if DBSPMIstr='dgCorpo'
               then FCDBdgSPMi[DBSPMIcnt].SPMI_hqStruc:=dgCorpo
               else if DBSPMIstr='dgFed'
               then FCDBdgSPMi[DBSPMIcnt].SPMI_hqStruc:=dgFed;
               FCDBdgSPMi[DBSPMIcnt].SPMI_hqRTM:=DBSPMIitmSub.Attributes['hqrtm'];
            end
            {.custom effects}
            else if DBSPMIitmsub.NodeName='spmfx'
            then
            begin
               DBSPMIcustomFx:=DBSPMIitmSub.ChildNodes.First;
               while DBSPMIcustomFx<>nil do
               begin
                  inc(DBSPMIcntCustomFx);
                  SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList, DBSPMIcntCustomFx+1);
                  DBSPMIstr:=DBSPMIcustomFx.Attributes['code'];
                  if DBSPMIstr='EIOUT'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList[DBSPMIcntCustomFx].CFX_code:=cfxEIOUT;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList[DBSPMIcntCustomFx].CFX_eioutMod:=DBSPMIcustomFx.Attributes['modifier'];
                     FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList[DBSPMIcntCustomFx].CFX_eioutIsBurMod:=DBSPMIcustomFx.Attributes['isburmod'];
                  end
                  else if DBSPMIstr='REVTX'
                  then
                  begin
                     FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList[DBSPMIcntCustomFx].CFX_code:=cfxREVTX;
                     FCDBdgSPMi[DBSPMIcnt].SPMI_customFxList[DBSPMIcntCustomFx].CFX_revtxCoef:=DBSPMIcustomFx.Attributes['coef'];
                  end;
                  DBSPMIcustomFx:=DBSPMIcustomFx.NextSibling;
               end;
            end
            {.influence matrix}
            else if DBSPMIitmSub.NodeName='spminfluences'
            then
            begin
               DBSPMIinfl:=DBSPMIitmSub.ChildNodes.First;
               while DBSPMIinfl<>nil do
               begin
                  inc(DBSPMIcntInfl);
                  SetLength(FCDBdgSPMi[DBSPMIcnt].SPMI_infl, DBSPMIcntInfl+1);
                  FCDBdgSPMi[DBSPMIcnt].SPMI_infl[DBSPMIcntInfl].SPMII_token:=DBSPMIinfl.Attributes['vstoken'];
                  FCDBdgSPMi[DBSPMIcnt].SPMI_infl[DBSPMIcntInfl].SPMII_influence:=DBSPMIinfl.Attributes['vsmod'];
                  DBSPMIinfl:=DBSPMIinfl.NextSibling;
               end; //==END== while DBSPMIinfl<>nil do ==//
            end;
            DBSPMIitmSub:=DBSPMIitmSub.NextSibling;
         end; //==END== while DBSPMIitmSub<>nil do ==//
      end; //==END== if DBSPMIitm.NodeName<>'#comment' ==//
      DBSPMIitm:= DBSPMIitm.NextSibling;
	end;{.while DBSPMIitm<>nil}
	{.disable}
	FCWinMain.FCXMLdbSPMi.Active:=false;
end;

procedure FCMdF_DBstarSys_Process(
   const DBSSPaction: TFCEdfstSysProc;
   const DBSSPstarSysID
         ,DBSSPstarID: string
   );
{:Purpose: read the universe database xml file.
   Additions:
      -2011Jun14- *add: region environmnent modifier.
      -2011Feb14- *initialize region's settlement data.
      -2010Jul15- *add: companion star data
      -2010Jun19- *add: environments.
      -2010Feb02- *add: regions loading for satellites.
      -2010Jan26- *add: set the right number of regions at the end of loading.
      -2010Jan17- *add: complete region loading.
      -2010Jan14- *add: begin region loading.
      -2010Jan07- *add: orbital period list + hydrosphere for satellites.
      -2010Jan06- *add: orbital period list data.
                  *add: hydrosphere type and area.
      -2009Dec15- *fix: debug satellite token.
      -2009Dec12- *add: atmosphere detailed composition.
      -2009Dec08- *add clouds cover.
      -2009Dec07- *add OOS_atmPress.
      -2009Dec06- *load satellites, if there's any.
      -2009Sep14- *add gravity sphere of influence radius.
      -2009Sep13- *fix final setlength.
      -2009Aug29- *add OO_angle1stDay calculation.
      -2009Aug28- *support now #comment by bypassing them.
                  *nb of stars for star systems is removed (useless).
                  *addition of basic orbital object data loading (w/o tectonics /
                  atmosphere / biosphere and regions).
      -2009Aug25- *modify subroutine concerning star class according to datastructure
                  changes.
      -2009Aug23- *routine completion for star systems and stars data.
      -2009Aug14- *remove debug statements with real load in FCDBstarSys and it's child.
                  *finalize star system loading (w/o orbital objects).
}
const
   DBSSblocCnt=1024;
var
   DBSSPstarSysNode
   ,DBSSPstarNode
   ,DBSSPstarSubNode
   ,DBSSPorbObjNode
   ,DBSSPsatNode
   ,DBSSPperOrbNode
   ,DBSSPregNode: IXMLNode;

   DBSSPstarSysCnt
   ,DBSSPstarCnt
   ,DBSSPorbObjCnt
   ,DBSSPsatCnt
   ,DBSSPperOrbCnt
   ,DBSSPregCnt: Integer;

   DBSSPcompOrb
   ,DBSSPstarClass
   ,DBSSPorbObjdmp
   ,DBSSPperOrbDmp
   ,DBSSPhydroTp
   ,DBSSPregDmp: string;
begin
   if DBSSPaction=dfsspStarSys then
   begin
      {.clear the data structure}
      SetLength(FCDBsSys,1);
      DBSSPstarSysCnt:=1;
      {.read the document}
      FCWinMain.FCXMLdbUniv.FileName:=FCVpathXML+'\univ\universe.xml';
      FCWinMain.FCXMLdbUniv.Active:=true;
      DBSSPstarSysNode:= FCWinMain.FCXMLdbUniv.DocumentElement.ChildNodes.First;
      while DBSSPstarSysNode<>nil do
      begin
         if DBSSPstarSysCnt >= Length(FCDBsSys)
         then SetLength(FCDBsSys, Length(FCDBsSys)+DBSSblocCnt);
         if DBSSPstarSysNode.NodeName<>'#comment'
         then
         begin
            {.star system token + nb of stars it contains}
            FCDBsSys[DBSSPstarSysCnt].SS_token:=DBSSPstarSysNode.Attributes['sstoken'];
            {.star system location}
            FCDBsSys[DBSSPstarSysCnt].SS_gLocX:= DBSSPstarSysNode.Attributes['steslocx'];
            FCDBsSys[DBSSPstarSysCnt].SS_gLocY:= DBSSPstarSysNode.Attributes['steslocy'];
            FCDBsSys[DBSSPstarSysCnt].SS_gLocZ:= DBSSPstarSysNode.Attributes['steslocz'];
            {.stars data processing loop}
            DBSSPstarCnt:=1;
            DBSSPstarNode:= DBSSPstarSysNode.ChildNodes.First;
            while DBSSPstarNode<>nil do
            begin
               DBSSPorbObjCnt:=0;
               {.star token id and class}
               FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_token
                  :=DBSSPstarNode.Attributes['startoken'] ;
               DBSSPstarClass:= DBSSPstarNode.Attributes['starclass'] ;
               if DBSSPstarClass='cB5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cB5
               else if DBSSPstarClass='cB6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cB6
               else if DBSSPstarClass='cB7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cB7
               else if DBSSPstarClass='cB8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cB5
               else if DBSSPstarClass='cB9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cB9
               else if DBSSPstarClass='cA0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA0
               else if DBSSPstarClass='cA1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA1
               else if DBSSPstarClass='cA2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA2
               else if DBSSPstarClass='cA3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA3
               else if DBSSPstarClass='cA4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA4
               else if DBSSPstarClass='cA5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA5
               else if DBSSPstarClass='cA6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA6
               else if DBSSPstarClass='cA7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA7
               else if DBSSPstarClass='cA8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA8
               else if DBSSPstarClass='cA9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cA9
               else if DBSSPstarClass='cK0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK0
               else if DBSSPstarClass='cK1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK1
               else if DBSSPstarClass='cK2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK2
               else if DBSSPstarClass='cK3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK3
               else if DBSSPstarClass='cK4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK4
               else if DBSSPstarClass='cK5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK5
               else if DBSSPstarClass='cK6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK6
               else if DBSSPstarClass='cK7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK7
               else if DBSSPstarClass='cK8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK8
               else if DBSSPstarClass='cK9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cK9
               else if DBSSPstarClass='cM0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM0
               else if DBSSPstarClass='cM1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM1
               else if DBSSPstarClass='cM2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM2
               else if DBSSPstarClass='cM3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM3
               else if DBSSPstarClass='cM4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM4
               else if DBSSPstarClass='cM5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=cM5
               else if DBSSPstarClass='gF0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF0
               else if DBSSPstarClass='gF1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF1
               else if DBSSPstarClass='gF2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF2
               else if DBSSPstarClass='gF3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF3
               else if DBSSPstarClass='gF4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF4
               else if DBSSPstarClass='gF5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF5
               else if DBSSPstarClass='gF6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF6
               else if DBSSPstarClass='gF7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF7
               else if DBSSPstarClass='gF8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF8
               else if DBSSPstarClass='gF9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gF9
               else if DBSSPstarClass='gG0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG0
               else if DBSSPstarClass='gG1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG1
               else if DBSSPstarClass='gG2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG2
               else if DBSSPstarClass='gG3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG3
               else if DBSSPstarClass='gG4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG4
               else if DBSSPstarClass='gG5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG5
               else if DBSSPstarClass='gG6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG6
               else if DBSSPstarClass='gG7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG7
               else if DBSSPstarClass='gG8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG8
               else if DBSSPstarClass='gG9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gG9
               else if DBSSPstarClass='gK0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK0
               else if DBSSPstarClass='gK1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK1
               else if DBSSPstarClass='gK2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK2
               else if DBSSPstarClass='gK3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK3
               else if DBSSPstarClass='gK4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK4
               else if DBSSPstarClass='gK5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK5
               else if DBSSPstarClass='gK6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK6
               else if DBSSPstarClass='gK7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK7
               else if DBSSPstarClass='gK8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK8
               else if DBSSPstarClass='gK9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gK9
               else if DBSSPstarClass='gM0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM0
               else if DBSSPstarClass='gM1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM1
               else if DBSSPstarClass='gM2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM2
               else if DBSSPstarClass='gM3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM3
               else if DBSSPstarClass='gM4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM4
               else if DBSSPstarClass='gM5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=gM5
               else if DBSSPstarClass='O5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=O5
               else if DBSSPstarClass='O6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=O6
               else if DBSSPstarClass='O7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=O7
               else if DBSSPstarClass='O8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=O8
               else if DBSSPstarClass='O9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=O9
               else if DBSSPstarClass='B0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B0
               else if DBSSPstarClass='B1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B1
               else if DBSSPstarClass='B2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B2
               else if DBSSPstarClass='B3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B3
               else if DBSSPstarClass='B4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B4
               else if DBSSPstarClass='B5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B5
               else if DBSSPstarClass='B6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B6
               else if DBSSPstarClass='B7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B7
               else if DBSSPstarClass='B8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B8
               else if DBSSPstarClass='B9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=B9
               else if DBSSPstarClass='A0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A0
               else if DBSSPstarClass='A1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A1
               else if DBSSPstarClass='A2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A2
               else if DBSSPstarClass='A3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A3
               else if DBSSPstarClass='A4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A4
               else if DBSSPstarClass='A5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A5
               else if DBSSPstarClass='A6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A6
               else if DBSSPstarClass='A7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A7
               else if DBSSPstarClass='A8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A8
               else if DBSSPstarClass='A9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=A9
               else if DBSSPstarClass='F0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F0
               else if DBSSPstarClass='F1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F1
               else if DBSSPstarClass='F2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F2
               else if DBSSPstarClass='F3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F3
               else if DBSSPstarClass='F4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F4
               else if DBSSPstarClass='F5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F5
               else if DBSSPstarClass='F6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F6
               else if DBSSPstarClass='F7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F7
               else if DBSSPstarClass='F8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F8
               else if DBSSPstarClass='F9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=F9
               else if DBSSPstarClass='G0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G0
               else if DBSSPstarClass='G1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G1
               else if DBSSPstarClass='G2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G2
               else if DBSSPstarClass='G3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G3
               else if DBSSPstarClass='G4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G4
               else if DBSSPstarClass='G5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G5
               else if DBSSPstarClass='G6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G6
               else if DBSSPstarClass='G7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G7
               else if DBSSPstarClass='G8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G8
               else if DBSSPstarClass='G9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=G9
               else if DBSSPstarClass='K0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K0
               else if DBSSPstarClass='K1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K1
               else if DBSSPstarClass='K2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K2
               else if DBSSPstarClass='K3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K3
               else if DBSSPstarClass='K4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K4
               else if DBSSPstarClass='K5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K5
               else if DBSSPstarClass='K6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K6
               else if DBSSPstarClass='K7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K7
               else if DBSSPstarClass='K8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K8
               else if DBSSPstarClass='K9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=K9
               else if DBSSPstarClass='M0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M0
               else if DBSSPstarClass='M1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M1
               else if DBSSPstarClass='M2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M2
               else if DBSSPstarClass='M3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M3
               else if DBSSPstarClass='M4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M4
               else if DBSSPstarClass='M5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M5
               else if DBSSPstarClass='M6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M6
               else if DBSSPstarClass='M7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M7
               else if DBSSPstarClass='M8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M8
               else if DBSSPstarClass='M9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=M9
               else if DBSSPstarClass='WD0'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD0
               else if DBSSPstarClass='WD1'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD1
               else if DBSSPstarClass='WD2'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD2
               else if DBSSPstarClass='WD3'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD3
               else if DBSSPstarClass='WD4'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD4
               else if DBSSPstarClass='WD5'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD5
               else if DBSSPstarClass='WD6'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD6
               else if DBSSPstarClass='WD7'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD7
               else if DBSSPstarClass='WD8'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD8
               else if DBSSPstarClass='WD9'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=WD9
               else if DBSSPstarClass='PSR'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=PSR
               else if DBSSPstarClass='BH'
               then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_class:=BH;
               {.star subdata processing loop}
               DBSSPstarSubNode:= DBSSPstarNode.ChildNodes.First;
               while DBSSPstarSubNode<>nil do
               begin
                  {.star's physical data}
                  if DBSSPstarSubNode.NodeName='starphysdata'
                  then
                  begin
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_temp:=DBSSPstarSubNode.Attributes['startemp'];
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_mass:=DBSSPstarSubNode.Attributes['starmass'];
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_diam:=DBSSPstarSubNode.Attributes['stardiam'];
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_lum:=DBSSPstarSubNode.Attributes['starlum'];
                  end
                  {.companion star's data}
                  else if DBSSPstarSubNode.NodeName='starcompdata'
                  then
                  begin
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_meanSep:=DBSSPstarSubNode.Attributes['compmsep'];
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_minApD:=DBSSPstarSubNode.Attributes['compminapd'];
                     FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_ecc:=DBSSPstarSubNode.Attributes['compecc'];
                     if DBSSPstarCnt=3
                     then
                     begin
                        DBSSPcompOrb:=DBSSPstarSubNode.Attributes['comporb'];
                        if DBSSPcompOrb='coAroundCenter'
                        then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_comp2Orb:=coAroundCenter
                        else if DBSSPcompOrb='coAroundComp'
                        then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_comp2Orb:=coAroundComp
                        else if DBSSPcompOrb='coAroundGravC'
                        then FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_comp2Orb:=coAroundGravC;
                     end;
                  end
                  else if DBSSPstarSubNode.NodeName='orbobj'
                  then
                  begin
                     inc(DBSSPorbObjCnt);
                     if DBSSPorbObjCnt>= Length(FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj)
                     then SetLength(
                        FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj
                        ,Length(FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj)+DBSSblocCnt
                        );
                     with FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj[DBSSPorbObjCnt] do
                     begin
                        {.initialize satellite data}
                        SetLength(OO_satList, 1);
                        DBSSPsatCnt:=0;
                        {orbital object's id db token}
                        OO_token:=DBSSPstarSubNode.Attributes['ootoken'];
                        DBSSPorbObjNode:= DBSSPstarSubNode.ChildNodes.First;
                        while DBSSPorbObjNode<>nil do
                        begin
                           if DBSSPorbObjNode.NodeName='orbobjorbdata'
                           then
                           begin
                              {.distance from star}
                              OO_distFrmStar:=DBSSPorbObjNode.Attributes['oodist'];
                              {.eccentricity}
                              OO_ecc:=DBSSPorbObjNode.Attributes['ooecc'];
                              {.orbital zone type}
                              DBSSPorbObjdmp:=DBSSPorbObjNode.Attributes['ooorbzne'];
                              if DBSSPorbObjdmp='zoneInner'
                              then OO_orbZone:=zoneInner
                              else if DBSSPorbObjdmp='zoneInterm'
                              then OO_orbZone:=zoneInterm
                              else if DBSSPorbObjdmp='zoneOuter'
                              then OO_orbZone:=zoneOuter;
                              {.revolution period}
                              OO_revol:=DBSSPorbObjNode.Attributes['oorevol'];
                              {.revolution period init day}
                              OO_revolInit:=DBSSPorbObjNode.Attributes['oorevevinit'];
                              OO_angle1stDay:=roundto(OO_revolInit*360/OO_revol, -2);
                              {.gravity sphere of influence radius}
                              OO_gravSphRad:=DBSSPorbObjNode.Attributes['oogravsphrad'];
                           end //==END== if DBSSPorbObjNode.NodeName='orbobjorbdata' ==//
                           else if DBSSPorbObjNode.NodeName='orbperlist'
                           then
                           begin
                              DBSSPperOrbCnt:=0;
                              DBSSPperOrbNode:=DBSSPorbObjNode.ChildNodes.First;
                              while DBSSPperOrbNode<>nil do
                              begin
                                 inc(DBSSPperOrbCnt);
                                 DBSSPperOrbDmp:=DBSSPperOrbNode.Attributes['optype'];
                                 if DBSSPperOrbDmp='optClosest'
                                 then OO_orbPeriod[DBSSPperOrbCnt].OP_type:=optClosest
                                 else if DBSSPperOrbDmp='optInterm'
                                 then OO_orbPeriod[DBSSPperOrbCnt].OP_type:=optInterm
                                 else if DBSSPperOrbDmp='optFarest'
                                 then OO_orbPeriod[DBSSPperOrbCnt].OP_type:=optFarest;
                                 OO_orbPeriod[DBSSPperOrbCnt].OP_dayStart:=DBSSPperOrbNode.Attributes['opstrt'];
                                 OO_orbPeriod[DBSSPperOrbCnt].OP_dayEnd:=DBSSPperOrbNode.Attributes['opend'];
                                 OO_orbPeriod[DBSSPperOrbCnt].OP_meanTemp:=DBSSPperOrbNode.Attributes['opmtemp'];
                                 DBSSPperOrbNode:= DBSSPperOrbNode.NextSibling;
                              end;
                           end //==END== else if DBSSPorbObjNode.NodeName='orbperlist' ==//
                           else if DBSSPorbObjNode.NodeName='orbobjgeophysdata'
                           then
                           begin
                              {.orbital object type}
                              DBSSPorbObjdmp:=DBSSPorbObjNode.Attributes['ootype'];
                              if DBSSPorbObjdmp='oobtpProtoDisk' then OO_type:=oobtpProtoDisk
                              else if DBSSPorbObjdmp='oobtpAsterBelt_Metall'
                              then OO_type:=oobtpAsterBelt_Metall
                              else if DBSSPorbObjdmp='oobtpAsterBelt_Sili'
                              then OO_type:=oobtpAsterBelt_Sili
                              else if DBSSPorbObjdmp='oobtpAsterBelt_Carbo'
                              then OO_type:=oobtpAsterBelt_Carbo
                              else if DBSSPorbObjdmp='oobtpAsterBelt_Icy'
                              then OO_type:=oobtpAsterBelt_Icy
                              else if DBSSPorbObjdmp='oobtpAster_Metall'
                              then OO_type:=oobtpAster_Metall
                              else if DBSSPorbObjdmp='oobtpAster_Sili'
                              then OO_type:=oobtpAster_Sili
                              else if DBSSPorbObjdmp='oobtpAster_Carbo'
                              then OO_type:=oobtpAster_Carbo
                              else if DBSSPorbObjdmp='oobtpAster_Icy'
                              then OO_type:=oobtpAster_Icy
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_EarthH0H1'
                              then OO_type:=oobtpPlan_Tellu_EarthH0H1
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_EarthH2'
                              then OO_type:=oobtpPlan_Tellu_EarthH2
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_EarthH3'
                              then OO_type:=oobtpPlan_Tellu_EarthH3
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_EarthH4'
                              then OO_type:=oobtpPlan_Tellu_EarthH4
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MarsH0H1'
                              then OO_type:=oobtpPlan_Tellu_MarsH0H1
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MarsH2'
                              then OO_type:=oobtpPlan_Tellu_MarsH2
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MarsH3'
                              then OO_type:=oobtpPlan_Tellu_MarsH3
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MarsH4'
                              then OO_type:=oobtpPlan_Tellu_MarsH4
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_VenusH0H1'
                              then OO_type:=oobtpPlan_Tellu_VenusH0H1
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_VenusH2'
                              then OO_type:=oobtpPlan_Tellu_VenusH2
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_VenusH3'
                              then OO_type:=oobtpPlan_Tellu_VenusH3
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_VenusH4'
                              then OO_type:=oobtpPlan_Tellu_VenusH4
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MercuH0'
                              then OO_type:=oobtpPlan_Tellu_MercuH0
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MercuH3'
                              then OO_type:=oobtpPlan_Tellu_MercuH3
                              else if DBSSPorbObjdmp='oobtpPlan_Tellu_MercuH4'
                              then OO_type:=oobtpPlan_Tellu_MercuH4
                              else if DBSSPorbObjdmp='oobtpPlan_Icy_PlutoH3'
                              then OO_type:=oobtpPlan_Icy_PlutoH3
                              else if DBSSPorbObjdmp='oobtpPlan_Icy_EuropeH4'
                              then OO_type:=oobtpPlan_Icy_EuropeH4
                              else if DBSSPorbObjdmp='oobtpPlan_Icy_CallistoH3H4Atm0'
                              then OO_type:=oobtpPlan_Icy_CallistoH3H4Atm0
                              else if DBSSPorbObjdmp='oobtpPlan_Gas_Uranus'
                              then OO_type:=oobtpPlan_Gas_Uranus
                              else if DBSSPorbObjdmp='oobtpPlan_Gas_Neptun'
                              then OO_type:=oobtpPlan_Gas_Neptun
                              else if DBSSPorbObjdmp='oobtpPlan_Gas_Saturn'
                              then OO_type:=oobtpPlan_Gas_Saturn
                              else if DBSSPorbObjdmp='oobtpPlan_Jovian_Jupiter'
                              then OO_type:=oobtpPlan_Jovian_Jupiter
                              else if DBSSPorbObjdmp='oobtpPlan_Supergiant1'
                              then OO_type:=oobtpPlan_Supergiant1;
                              {.diameter}
                              OO_diam:=DBSSPorbObjNode.Attributes['oodiam'];
                              {.density}
                              OO_dens:=DBSSPorbObjNode.Attributes['oodens'];
                              {.mass}
                              OO_mass:=DBSSPorbObjNode.Attributes['oomass'];
                              {.gravity}
                              OO_grav:=DBSSPorbObjNode.Attributes['oograv'];
                              {.escape velocity}
                              OO_escVel:=DBSSPorbObjNode.Attributes['ooescvel'];
                              {.rotation period}
                              OO_rotPer:=DBSSPorbObjNode.Attributes['oorotper'];
                              {.inclination axis}
                              OO_inclAx:=DBSSPorbObjNode.Attributes['ooinclax'];
                              {.magnetic field}
                              OO_magFld:=DBSSPorbObjNode.Attributes['oomagfld'];
                              {.albedo}
                              OO_albedo:=DBSSPorbObjNode.Attributes['ooalbe'];
                           end {.else if DBSSPorbObjNode.NodeName='orbobjgeophysdata'}
                           else if DBSSPorbObjNode.NodeName='orbobjecosdata'
                           then
                           begin
                              {.environment}
                              DBSSPorbObjdmp:=DBSSPorbObjNode.Attributes['ooenvtype'];
                              if DBSSPorbObjdmp='freeLiving'
                              then OO_envTp:=freeLiving
                              else if DBSSPorbObjdmp='restrict'
                              then OO_envTp:=restrict
                              else if DBSSPorbObjdmp='space'
                              then OO_envTp:=space
                              else OO_envTp:=gaseous;
                              {.atmosphere pressure}
                              OO_atmPress:=DBSSPorbObjNode.Attributes['ooatmpres'];
                              {.clouds cover}
                              OO_cloudsCov:=DBSSPorbObjNode.Attributes['oocloudscov'];
                              {.atmospheric composition}
                              OO_atmosph.agasH2:=DBSSPorbObjNode.Attributes['atmH2'];
                              OO_atmosph.agasHe:=DBSSPorbObjNode.Attributes['atmHe'];
                              OO_atmosph.agasCH4:=DBSSPorbObjNode.Attributes['atmCH4'];
                              OO_atmosph.agasNH3:=DBSSPorbObjNode.Attributes['atmNH3'];
                              OO_atmosph.agasH2O:=DBSSPorbObjNode.Attributes['atmH2O'];
                              OO_atmosph.agasNe:=DBSSPorbObjNode.Attributes['atmNe'];
                              OO_atmosph.agasN2:=DBSSPorbObjNode.Attributes['atmN2'];
                              OO_atmosph.agasCO:=DBSSPorbObjNode.Attributes['atmCO'];
                              OO_atmosph.agasNO:=DBSSPorbObjNode.Attributes['atmNO'];
                              OO_atmosph.agasO2:=DBSSPorbObjNode.Attributes['atmO2'];
                              OO_atmosph.agasH2S:=DBSSPorbObjNode.Attributes['atmH2S'];
                              OO_atmosph.agasAr:=DBSSPorbObjNode.Attributes['atmAr'];
                              OO_atmosph.agasCO2:=DBSSPorbObjNode.Attributes['atmCO2'];
                              OO_atmosph.agasNO2:=DBSSPorbObjNode.Attributes['atmNO2'];
                              OO_atmosph.agasO3:=DBSSPorbObjNode.Attributes['atmO3'];
                              OO_atmosph.agasSO2:=DBSSPorbObjNode.Attributes['atmSO2'];
                              {.hydrosphere}
                              DBSSPhydroTp:=DBSSPorbObjNode.Attributes['hydroTp'];
                              if DBSSPhydroTp='htNone'
                              then OO_hydrotp:=htNone
                              else if DBSSPhydroTp='htVapor'
                              then OO_hydrotp:=htVapor
                              else if DBSSPhydroTp='htLiquid'
                              then OO_hydrotp:=htLiquid
                              else if DBSSPhydroTp='htIceSheet'
                              then OO_hydrotp:=htIceSheet
                              else if DBSSPhydroTp='htCrystal'
                              then OO_hydrotp:=htCrystal
                              else if DBSSPhydroTp='htLiqNH3'
                              then OO_hydrotp:=htLiqNH3
                              else if DBSSPhydroTp='htLiqCH4'
                              then OO_hydrotp:=htLiqCH4;
                              OO_hydroArea:=DBSSPorbObjNode.Attributes['hydroArea'];
                           end {.else if DBSSPorbObjNode.NodeName='orbobjecosdata'}
                           else if DBSSPorbObjNode.NodeName='orbobjregions'
                           then
                           begin
                              SetLength(OO_regions, 31);
                              DBSSPregCnt:=1;
                              DBSSPregNode:=DBSSPorbObjNode.ChildNodes.First;
                              while DBSSPregNode<>nil do
                              begin
                                 {.region - soil type}
                                 DBSSPregDmp:=DBSSPregNode.Attributes['soiltp'];
                                 if DBSSPregDmp='rst01rockDes'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst01rockDes
                                 else if DBSSPregDmp='rst02sandDes'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst02sandDes
                                 else if DBSSPregDmp='rst03volcanic'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst03volcanic
                                 else if DBSSPregDmp='rst04polar'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst04polar
                                 else if DBSSPregDmp='rst05arid'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst05arid
                                 else if DBSSPregDmp='rst06fertile'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst06fertile
                                 else if DBSSPregDmp='rst07oceanic'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst07oceanic
                                 else if DBSSPregDmp='rst08coastRockDes'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst08coastRockDes
                                 else if DBSSPregDmp='rst09coastSandDes'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst09coastSandDes
                                 else if DBSSPregDmp='rst10coastVolcanic'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst10coastVolcanic
                                 else if DBSSPregDmp='rst11coastPolar'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst11coastPolar
                                 else if DBSSPregDmp='rst12coastArid'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst12coastArid
                                 else if DBSSPregDmp='rst13coastFertile'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst13coastFertile
                                 else if DBSSPregDmp='rst14barren'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst14barren
                                 else if DBSSPregDmp='rst15icyBarren'
                                 then OO_regions[DBSSPregCnt].OOR_soilTp:=rst15icyBarren;
                                 {.region - relief}
                                 DBSSPregDmp:=DBSSPregNode.Attributes['relief'];
                                 if DBSSPregDmp='rr1plain'
                                 then OO_regions[DBSSPregCnt].OOR_relief:=rr1plain
                                 else if DBSSPregDmp='rr4broken'
                                 then OO_regions[DBSSPregCnt].OOR_relief:=rr4broken
                                 else if DBSSPregDmp='rr9mountain'
                                 then OO_regions[DBSSPregCnt].OOR_relief:=rr9mountain;
                                 {.region - climate}
                                 DBSSPregDmp:=DBSSPregNode.Attributes['climate'];
                                 if DBSSPregDmp='rc00void'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc00void
                                 else if DBSSPregDmp='rc01vhotHumid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc01vhotHumid
                                 else if DBSSPregDmp='rc02vhotSemiHumid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc02vhotSemiHumid
                                 else if DBSSPregDmp='rc03hotSemiArid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc03hotSemiArid
                                 else if DBSSPregDmp='rc04hotArid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc04hotArid
                                 else if DBSSPregDmp='rc05modHumid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc05modHumid
                                 else if DBSSPregDmp='rc06modDry'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc06modDry
                                 else if DBSSPregDmp='rc07coldArid'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc07coldArid
                                 else if DBSSPregDmp='rc08periarctic'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc08periarctic
                                 else if DBSSPregDmp='rc09arctic'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc09arctic
                                 else if DBSSPregDmp='rc10extreme'
                                 then OO_regions[DBSSPregCnt].OOR_climate:=rc10extreme;
                                 {.region - mean temperature at min distance}
                                 OO_regions[DBSSPregCnt].OOR_meanTdMin:=DBSSPregNode.Attributes['mtdmin'];
                                 {.region - mean temperature at intermediate distance}
                                 OO_regions[DBSSPregCnt].OOR_meanTdInt:=DBSSPregNode.Attributes['mtdint'];
                                 {.region - mean temperature at max distance}
                                 OO_regions[DBSSPregCnt].OOR_meanTdMax:=DBSSPregNode.Attributes['mtdmax'];
                                 {.region - mean windspeed}
                                 OO_regions[DBSSPregCnt].OOR_windSpd:=DBSSPregNode.Attributes['wndspd'];
                                 {.region - yearly precipitations}
                                 OO_regions[DBSSPregCnt].OOR_precip:=DBSSPregNode.Attributes['precip'];
                                 {.reset settlements data}
                                 OO_regions[DBSSPregCnt].OOR_setEnt:=0;
                                 OO_regions[DBSSPregCnt].OOR_setCol:=0;
                                 OO_regions[DBSSPregCnt].OOR_setSet:=0;
                                 {.environment modifier}
                                 OO_regions[DBSSPregCnt].OOR_emo:=DBSSPregNode.Attributes['emo'];
                                 inc(DBSSPregCnt);
                                 DBSSPregNode:= DBSSPregNode.NextSibling;
                              end; //==END== while DBSSPregNode<>nil ==//
                              {.set the right number of regions}
                              SetLength(OO_regions, DBSSPregCnt);
                           end //==END== else if NodeName='orbobjregions' ==//
                           else if DBSSPorbObjNode.NodeName='satobj'
                           then
                           begin
                              {.initialize satellite data}
                              SetLength(OO_satList, length(OO_satList)+1);
                              inc(DBSSPsatCnt);
                              {satellite id db token}
                              OO_satList[DBSSPsatCnt].OOS_token:=DBSSPorbObjNode.Attributes['sattoken'];
                              DBSSPsatNode:= DBSSPorbObjNode.ChildNodes.First;
                              while DBSSPsatNode<>nil do
                              begin
                                 if DBSSPsatNode.NodeName='satorbdata' then
                                 begin
                                    {.distance from central planet}
                                    OO_satList[DBSSPsatCnt].OOS_distFrmOOb:=DBSSPsatNode.Attributes['satdist'];
                                    {.revolution period}
                                    OO_satList[DBSSPsatCnt].OOS_revol:=DBSSPsatNode.Attributes['satrevol'];
                                    {.revolution period init day}
                                    OO_satList[DBSSPsatCnt].OOS_revolInit:=DBSSPsatNode.Attributes['satrevinit'];
                                    OO_satList[DBSSPsatCnt].OOS_angle1stDay
                                       :=roundto
                                          (
                                             OO_satList[DBSSPsatCnt].OOS_revolInit
                                                *360
                                                /OO_satList[DBSSPsatCnt].OOS_revol
                                             , -2
                                          );
                                    {.gravity sphere of influence radius}
                                    OO_satList[DBSSPsatCnt].OOS_gravSphRad
                                       :=DBSSPsatNode.Attributes['satgravsphrad'];
                                 end
                                 else if DBSSPsatNode.NodeName='orbperlist'
                                 then
                                 begin
                                    DBSSPperOrbCnt:=0;
                                    DBSSPperOrbNode:=DBSSPsatNode.ChildNodes.First;
                                    while DBSSPperOrbNode<>nil do
                                    begin
                                       inc(DBSSPperOrbCnt);
                                       DBSSPperOrbDmp:=DBSSPperOrbNode.Attributes['optype'];
                                       if DBSSPperOrbDmp='optClosest'
                                       then OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_type
                                          :=optClosest
                                       else if DBSSPperOrbDmp='optInterm'
                                       then OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_type
                                          :=optInterm
                                       else if DBSSPperOrbDmp='optFarest'
                                       then OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_type
                                          :=optFarest;
                                       OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_dayStart
                                          :=DBSSPperOrbNode.Attributes['opstrt'];
                                       OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_dayEnd
                                          :=DBSSPperOrbNode.Attributes['opend'];
                                       OO_satList[DBSSPsatCnt].OOS_orbPeriod[DBSSPperOrbCnt].OP_meanTemp
                                          :=DBSSPperOrbNode.Attributes['opmtemp'];
                                       DBSSPperOrbNode:= DBSSPperOrbNode.NextSibling;
                                    end;
                                 end //==END== else if DBSSPsatNode.NodeName='orbperlist' ==//
                                 else if DBSSPsatNode.NodeName='satgeophysdata'
                                 then
                                 begin
                                    {.orbital object type}
                                    DBSSPorbObjdmp:=DBSSPsatNode.Attributes['sattype'];
                                    if DBSSPorbObjdmp='oobtpSat_Aster_Metall'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Aster_Metall
                                    else if DBSSPorbObjdmp='oobtpSat_Aster_Sili'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Aster_Sili
                                    else if DBSSPorbObjdmp='oobtpSat_Aster_Carbo'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Aster_Carbo
                                    else if DBSSPorbObjdmp='oobtpSat_Aster_Icy'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Aster_Icy
                                    else if DBSSPorbObjdmp='oobtpSat_Tellu_Lunar'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Tellu_Lunar
                                    else if DBSSPorbObjdmp='oobtpSat_Tellu_Io'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Tellu_Io
                                    else if DBSSPorbObjdmp='oobtpSat_Tellu_Titan'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Tellu_Titan
                                    else if DBSSPorbObjdmp='oobtpSat_Tellu_Earth'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Tellu_Earth
                                    else if DBSSPorbObjdmp='oobtpSat_Icy_Pluto'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Icy_Pluto
                                    else if DBSSPorbObjdmp='oobtpSat_Icy_Europe'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Icy_Europe
                                    else if DBSSPorbObjdmp='oobtpSat_Icy_Callisto'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpSat_Icy_Callisto
                                    else if DBSSPorbObjdmp='oobtpRing_Metall'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpRing_Metall
                                    else if DBSSPorbObjdmp='oobtpRing_Sili'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpRing_Sili
                                    else if DBSSPorbObjdmp='oobtpRing_Carbo'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpRing_Carbo
                                    else if DBSSPorbObjdmp='oobtpRing_Icy'
                                    then OO_satList[DBSSPsatCnt].OOS_type:=oobtpRing_Icy;
                                    {.diameter}
                                    OO_satList[DBSSPsatCnt].OOS_diam:=DBSSPsatNode.Attributes['satdiam'];
                                    {.density}
                                    OO_satList[DBSSPsatCnt].OOS_dens:=DBSSPsatNode.Attributes['satdens'];
                                    {.mass}
                                    OO_satList[DBSSPsatCnt].OOS_mass:=DBSSPsatNode.Attributes['satmass'];
                                    {.gravity}
                                    OO_satList[DBSSPsatCnt].OOS_grav:=DBSSPsatNode.Attributes['satgrav'];
                                    {.escape velocity}
                                    OO_satList[DBSSPsatCnt].OOS_escVel:=DBSSPsatNode.Attributes['satescvel'];
                                    {.inclination axis}
                                    OO_satList[DBSSPsatCnt].OOS_inclAx:=DBSSPsatNode.Attributes['satinclax'];
                                    {.magnetic field}
                                    OO_satList[DBSSPsatCnt].OOS_magFld:=DBSSPsatNode.Attributes['satmagfld'];
                                    {.albedo}
                                    OO_satList[DBSSPsatCnt].OOS_albedo:=DBSSPsatNode.Attributes['satalbe'];
                                 end {.else if DBSSPsatNode.NodeName='satgeophysdata'}
                                 else if DBSSPsatNode.NodeName='satecosdata' then
                                 begin
                                    {.environment}
                                    DBSSPorbObjdmp:=DBSSPsatNode.Attributes['satenvtype'];
                                    if DBSSPorbObjdmp='freeLiving'
                                    then OO_satList[DBSSPsatCnt].OOS_envTp:=freeLiving
                                    else if DBSSPorbObjdmp='restrict'
                                    then OO_satList[DBSSPsatCnt].OOS_envTp:=restrict
                                    else if DBSSPorbObjdmp='space'
                                    then OO_satList[DBSSPsatCnt].OOS_envTp:=space
                                    else OO_satList[DBSSPsatCnt].OOS_envTp:=gaseous;
                                    {.atmosphere pressure}
                                    OO_satList[DBSSPsatCnt].OOS_atmPress:=DBSSPsatNode.Attributes['satatmpres'];
                                    {.clouds cover}
                                    OO_satList[DBSSPsatCnt].OOS_cloudsCov:=DBSSPsatNode.Attributes['satcloudscov'];
                                    {.atmospheric composition}
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasH2:=DBSSPsatNode.Attributes['atmH2'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasHe:=DBSSPsatNode.Attributes['atmHe'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasCH4:=DBSSPsatNode.Attributes['atmCH4'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasNH3:=DBSSPsatNode.Attributes['atmNH3'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasH2O:=DBSSPsatNode.Attributes['atmH2O'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasNe:=DBSSPsatNode.Attributes['atmNe'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasN2:=DBSSPsatNode.Attributes['atmN2'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasCO:=DBSSPsatNode.Attributes['atmCO'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasNO:=DBSSPsatNode.Attributes['atmNO'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasO2:=DBSSPsatNode.Attributes['atmO2'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasH2S:=DBSSPsatNode.Attributes['atmH2S'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasAr:=DBSSPsatNode.Attributes['atmAr'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasCO2:=DBSSPsatNode.Attributes['atmCO2'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasNO2:=DBSSPsatNode.Attributes['atmNO2'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasO3:=DBSSPsatNode.Attributes['atmO3'];
                                    OO_satList[DBSSPsatCnt].OOS_atmosph.agasSO2:=DBSSPsatNode.Attributes['atmSO2'];
                                    {.hydrosphere}
                                    DBSSPhydroTp:=DBSSPsatNode.Attributes['hydroTp'];
                                    if DBSSPhydroTp='htNone'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htNone
                                    else if DBSSPhydroTp='htVapor'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htVapor
                                    else if DBSSPhydroTp='htLiquid'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htLiquid
                                    else if DBSSPhydroTp='htIceSheet'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htIceSheet
                                    else if DBSSPhydroTp='htCrystal'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htCrystal
                                    else if DBSSPhydroTp='htLiqNH3'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htLiqNH3
                                    else if DBSSPhydroTp='htLiqCH4'
                                    then OO_satList[DBSSPsatCnt].OOS_hydrotp:=htLiqCH4;
                                    OO_satList[DBSSPsatCnt].OOS_hydroArea:=DBSSPsatNode.Attributes['hydroArea'];
                                 end {.else if DBSSPsatNode.NodeName='satecosdata'}
                                 else if DBSSPsatNode.NodeName='satregions'
                                 then
                                 begin
                                    SetLength(OO_satList[DBSSPsatCnt].OOS_regions, 31);
                                    DBSSPregCnt:=1;
                                    DBSSPregNode:=DBSSPsatNode.ChildNodes.First;
                                    while DBSSPregNode<>nil do
                                    begin
                                       {.region - soil type}
                                       DBSSPregDmp:=DBSSPregNode.Attributes['soiltp'];
                                       if DBSSPregDmp='rst01rockDes'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst01rockDes
                                       else if DBSSPregDmp='rst02sandDes'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst02sandDes
                                       else if DBSSPregDmp='rst03volcanic'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst03volcanic
                                       else if DBSSPregDmp='rst04polar'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst04polar
                                       else if DBSSPregDmp='rst05arid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst05arid
                                       else if DBSSPregDmp='rst06fertile'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst06fertile
                                       else if DBSSPregDmp='rst07oceanic'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst07oceanic
                                       else if DBSSPregDmp='rst08coastRockDes'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst08coastRockDes
                                       else if DBSSPregDmp='rst09coastSandDes'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst09coastSandDes
                                       else if DBSSPregDmp='rst10coastVolcanic'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst10coastVolcanic
                                       else if DBSSPregDmp='rst11coastPolar'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst11coastPolar
                                       else if DBSSPregDmp='rst12coastArid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst12coastArid
                                       else if DBSSPregDmp='rst13coastFertile'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst13coastFertile
                                       else if DBSSPregDmp='rst14barren'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst14barren
                                       else if DBSSPregDmp='rst15icyBarren'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_soilTp:=rst15icyBarren;
                                       {.region - relief}
                                       DBSSPregDmp:=DBSSPregNode.Attributes['relief'];
                                       if DBSSPregDmp='rr1plain'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_relief:=rr1plain
                                       else if DBSSPregDmp='rr4broken'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_relief:=rr4broken
                                       else if DBSSPregDmp='rr9mountain'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_relief:=rr9mountain;
                                       {.region - climate}
                                       DBSSPregDmp:=DBSSPregNode.Attributes['climate'];
                                       if DBSSPregDmp='rc00void'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc00void
                                       else if DBSSPregDmp='rc01vhotHumid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc01vhotHumid
                                       else if DBSSPregDmp='rc02vhotSemiHumid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc02vhotSemiHumid
                                       else if DBSSPregDmp='rc03hotSemiArid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc03hotSemiArid
                                       else if DBSSPregDmp='rc04hotArid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc04hotArid
                                       else if DBSSPregDmp='rc05modHumid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc05modHumid
                                       else if DBSSPregDmp='rc06modDry'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc06modDry
                                       else if DBSSPregDmp='rc07coldArid'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc07coldArid
                                       else if DBSSPregDmp='rc08periarctic'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc08periarctic
                                       else if DBSSPregDmp='rc09arctic'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc09arctic
                                       else if DBSSPregDmp='rc10extreme'
                                       then OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_climate:=rc10extreme;
                                       {.region - mean temperature at min distance}
                                       OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_meanTdMin
                                          :=DBSSPregNode.Attributes['mtdmin'];
                                       {.region - mean temperature at intermediate distance}
                                       OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_meanTdInt
                                          :=DBSSPregNode.Attributes['mtdint'];
                                       {.region - mean temperature at max distance}
                                       OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_meanTdMax
                                          :=DBSSPregNode.Attributes['mtdmax'];
                                       {.region - mean windspeed}
                                       OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_windSpd
                                          :=DBSSPregNode.Attributes['wndspd'];
                                       {.region - yearly precipitations}
                                       OO_satList[DBSSPsatCnt].OOS_regions[DBSSPregCnt].OOR_precip
                                          :=DBSSPregNode.Attributes['precip'];
                                       inc(DBSSPregCnt);
                                       DBSSPregNode:= DBSSPregNode.NextSibling;
                                    end; //==END== while DBSSPregNode<>nil ==//
                                    {.set the right number of regions}
                                    SetLength(OO_satList[DBSSPsatCnt].OOS_regions, DBSSPregCnt);
                                 end; //==END== else if DBSSPorbObjNode.NodeName='satregions' ==//
                                 DBSSPsatNode:= DBSSPsatNode.NextSibling;
                              end; {.while DBSSPsatNode<>nil}
                           end; {.else if DBSSPorbObjNode.NodeName='satobj'}
                           DBSSPorbObjNode:= DBSSPorbObjNode.NextSibling;
                        end; {.while DBSSPorbObjNode<>nil}
                     end; {.with FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj[DBSSPorbObjCnt]}
                  end; {.else if DBSSPstarSubNode.NodeName='orbobj'}
                  DBSSPstarSubNode:=DBSSPstarSubNode.NextSibling;
               end; {.while DBSSPstarSubNode<>nil}
               {.resize to real table size for orbital objects}
               SetLength(FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj, DBSSPorbObjCnt+1);
               inc(DBSSPstarCnt);
               DBSSPstarNode:= DBSSPstarNode.NextSibling;
            end; {.while DBSSPstarNode<>nil}
            inc(DBSSPstarSysCnt);
         end; {.if DBSSPstarSysNode.NodeName<>'#comment'}
         DBSSPstarSysNode := DBSSPstarSysNode.NextSibling;
      end; {.while DBSSPstarSys<>nil}
      {.resize to real table size}
      SetLength(FCDBsSys, DBSSPstarSysCnt);
   end; {.if DBSSPaction=sspStarSys}
   {.disable}
	FCWinMain.FCXMLdbUniv.Active:=false;
end;

procedure FCMdF_Game_Load;
{:Purpose: load the current game.
   Additions:
      -2011Jul31- *add: infrastructure status istDisabledByEE.
      -2011Jul19- *add: CSM Energy module - storage data.
      -2011Jul13- *add: infrastructure consumed power.
      -2011Jul12- *add: CSM - Energy data.
      -2011Jul07- *add: colonies' production matrix.
      -2011May25- *rem: infrastructure - converted housing, useless state.
      -2011May15- *add: colony's infrastructure - CAB worked hours.
      -2011May05- *mod: complete change of colony's storage loading.
      -2011Apr26- *add: colonies' assigned population data.
                  *add: colonies' construction workforce.
      -2011Apr24- *add: energy output for Energy class infrastructures.
      -2011Apr20- *add: CPS - isEnabled.
      -2011Mar16-	*add: colonies' storages + reserves.
      -2011Mar09- *add: infrastructure's CAB duration.
                  *add: colonies' CAB queue.
      -2011Mar07- *add: converted housing infrastructures.
      -2011Feb14- *add: initialize region's settlement data.
      -2011Feb12- *add: extra task's data.
                  *add: settlements.
      -2011Feb08- *add: full status token loading, independent of the index.
      -2011Feb01- *add: economic & industrial output.
      -2010Dec29- *add: SPM cost storage data.
      -2010Dec19- *add: entities higher hq level present in the faction.
      -2010Nov08- *add: entities UC reserve.
      -2010Nov03- *add: SPMi duration.
      -2010Oct24- *add: HQ presence data for each colony.
      -2010Oct11- *add: player's faction status of the 3 categories.
      -2010Oct07- *add: memes values + policy status.
      -2010Sep29- *add: entity's bureaucracy and corruption modifiers.
      -2010Sep23- *fix: entity's bureaucracy and corruption load.
      -2010Sep22- *add: bureaucracy and corruption entities data.
                  *add: SPMi isSet data.
      -2010Sep21- *add: spm settings for entities.
      -2010Sep16- *add: entities code.
      -2010Sep07- *add: loading in specific file now, including date/time: name-yr-mth-day-h-mn.
      -2010Aug30- *add: CSM Phase list.
      -2010Aug19- *add: population type: militia.
      -2010Aug16- *add: population type: rebels.
      -2010Aug09- *add: CSM event duration.
      -2010Aug02- *add: CSM event health modifier.
      -2010Jul27- *add: CSM event level + economic & industrial output modifier.
      -2010Jul21- *add: csmTime data.
      -2010Jul02- *add: tasklisk string data.
      -2010Jun08- *add: space unit: include the docked sub data structure.
                  *fix: for each existing colony, the related orbital object data structure is updated.
      -2010Jun07- *add: display cps panel if cps is used and there's one colony.
      -2010May30- *add: colony's population sub-datastructure.
      -2010May27- *add: csm data pcap, spl, qol and heal.
      -2010May19- *add: colony infrastructures: status.
      -2010May18- *add: colony infrastructures.
      -2010May12- *add: in process task data phase.
      -2010May10- *add: the two time2xfert data.
      -2010May05- *add: TITP_regIdx.
      -2010May04- *add: TITP_timeOrg, TITP_orgType, TITP_timeDecel, TITP_accelbyTick.
                  *mod: threads loading is disabled.
      -2010Mar31- *add: colony level.
      -2010Mar27- *add space unit docked data.
      -2010Mar22- *add: cps time left.
      -2010Mar13- *add: cps data.
      -2010Mar03- *add: owned colonies.
      -2009Dec19- *add: player's sat location.
      -2009Dec18- *add: sat location for owned space unit.
      -2009Nov28- *add messages queue.
      -2009Nov27- *add TITP_usedRMassV.
      -2009Nov12- *add threads.
      -2009Nov10- *add tasklist in process.
      -2009Nov08- *add owned space units.
}
var
   GLxmlCAB
   ,GLxmlCol
   ,GLxmlColsub
   ,GLxmlDock
   ,GLxmlEntRoot
   ,GLxmlEntSubRoot
   ,GLxmlEnt
   ,GLxmlInfra
   ,GLxmlItm
   ,GLxmlMsg
   ,GLxmlCSMpL
   ,GLxmlCSMpLsub
   ,GLxmlProdMatrix
   ,GLxmlSPMset
   ,GLxmlSpOwn
   ,GLxmlStorage
   ,GLxmlTskInPr
   ,GLxmlViaObj: IXMLNode;

   GLcabCnt
   ,GLcabValue
   ,GLcolMax
   ,GLentCnt
   ,GLspuMax
   ,GLspuCnt
   ,GLcount
   ,GLcrLineM
   ,GLcvs
   ,GLdock
   ,GLevCnt
   ,GLinfCnt
   ,GLphItm
   ,GLphFac
   ,GLphFacOld
   ,GLprodMatrixCnt
   ,GLregionIdx
   ,GLsettleCnt
   ,GLsettleMax
   ,GLstorageCnt
   ,GLsubCnt
   ,GLtLft: integer;

   GLcrInt
   ,GLcrLineU: double;

   GLisCPSenabled: boolean;

   GLcurrDir
   ,GLcurrG
   ,GLinfStatus
   ,GLsettleType: string;

   GLvObjList: array of TFCRcpsObj;

   GLoobjRow: TFCRufStelObj;
begin
   FCMdF_ConfigFile_Read(true);
   GLcurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
   GLcurrG:=IntToStr(FCRplayer.P_timeYr)
      +'-'+IntToStr(FCRplayer.P_timeMth)
      +'-'+IntToStr(FCRplayer.P_timeday)
      +'-'+IntToStr(FCRplayer.P_timeHr)
      +'-'+IntToStr(FCRplayer.P_timeMin)
      +'.xml';
   if (DirectoryExists(GLcurrDir))
      and (FileExists(GLcurrDir+'\'+GLcurrG))
   then
   begin
      {.read the document}
      FCWinMain.FCXMLsave.FileName:=GLcurrDir+'\'+GLcurrG;
      FCWinMain.FCXMLsave.Active:=true;
      {.read the main section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMain');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_facAlleg:=GLxmlItm.Attributes['facAlleg'];
         FCRplayer.P_starSysLoc:=GLxmlItm.Attributes['plyrsSSLoc'];
         FCRplayer.P_starLoc:=GLxmlItm.Attributes['plyrsStLoc'];
         FCRplayer.P_oObjLoc:=GLxmlItm.Attributes['plyrsOObjLoc'];
         FCRplayer.P_satLoc:=GLxmlItm.Attributes['plyrsatLoc'];
      end;
      {.read the "timeframe" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfTimeFr');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_timeTick:=GLxmlItm.Attributes['tfTick'];
         FCRplayer.P_timeMin:=GLxmlItm.Attributes['tfMin'];
         FCRplayer.P_timeHr:=GLxmlItm.Attributes['tfHr'];
         FCRplayer.P_timeday:=GLxmlItm.Attributes['tfDay'];
         FCRplayer.P_timeMth:=GLxmlItm.Attributes['tfMth'];
         FCRplayer.P_timeYr:=GLxmlItm.Attributes['tfYr'];
      end;
      {.read the "status" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfStatus');
      if GLxmlItm<>nil
      then
      begin
         FCRplayer.P_ecoStat:=GLxmlItm.Attributes['statEco'];
         FCRplayer.P_socStat:=GLxmlItm.Attributes['statSoc'];
         FCRplayer.P_milStat:=GLxmlItm.Attributes['statMil'];
      end;
      {.read "cps" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfCPS');
      if GLxmlItm<>nil
      then
      begin
         GLisCPSenabled:=GLxmlItm.Attributes['cpsEnabled'];
         GLcvs:=GLxmlItm.Attributes['cpsCVS'];
         GLtLft:=GLxmlItm.Attributes['cpsTlft'];
         GLcrInt:=GLxmlItm.Attributes['cpsInt'];
         GLcrLineU:=GLxmlItm.Attributes['cpsCredU'];
         GLcrLineM:=GLxmlItm.Attributes['cpsCredM'];
         GLcount:=0;
         GLxmlViaObj:=GLxmlItm.ChildNodes.First;
         SetLength(GLvObjList, 1);
         while GLxmlViaObj<>nil do
         begin
            SetLength(GLvObjList, length(GLvObjList)+1);
            inc(GLcount);
            GLvObjList[GLcount].CPSO_type:=GLxmlViaObj.Attributes['objTp'];
            GLvObjList[GLcount].CPSO_score:=GLxmlViaObj.Attributes['score'];
            GLxmlViaObj:=GLxmlViaObj.NextSibling;
         end; //==END== GLxmlViaObj<>nil ==//
         FCcps:=TFCcps.Create(
            GLcvs
            ,GLtLft
            ,GLcrLineM
            ,GLcrInt
            ,GLcrLineU
            ,GLvObjList
            ,GLisCPSenabled
            );
      end; //==END== if GLxmlItm<>nil for CPS ==//
      {.read "taskinprocess" saved game item}
      SetLength(FCGtskListInProc, 1);
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfTskLstinProc');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlTskInPr:=GLxmlItm.ChildNodes.First;
         while GLxmlTskInPr<>nil do
         begin
            SetLength(FCGtskListInProc, length(FCGtskListInProc)+1);
            inc(GLcount);
            FCGtskListInProc[GLCount].TITP_enabled:=GLxmlTskInPr.Attributes['tipEna'];
            FCGtskListInProc[GLCount].TITP_actionTp:=GLxmlTskInPr.Attributes['tipActTp'];
            FCGtskListInProc[GLCount].TITP_phaseTp:=GLxmlTskInPr.Attributes['tipPhase'];
            FCGtskListInProc[GLCount].TITP_ctldType:=GLxmlTskInPr.Attributes['tipTgtTp'];
            FCGtskListInProc[GLCount].TITP_ctldFac:=GLxmlTskInPr.Attributes['tipTgtFac'];
            FCGtskListInProc[GLCount].TITP_ctldIdx:=GLxmlTskInPr.Attributes['tipTgtIdx'];
            FCGtskListInProc[GLcount].TITP_timeOrg:=GLxmlTskInPr.Attributes['tipTimeOrg'];
            FCGtskListInProc[GLCount].TITP_duration:=GLxmlTskInPr.Attributes['tipDura'];
            FCGtskListInProc[GLCount].TITP_interval:=GLxmlTskInPr.Attributes['tipInterv'];
            FCGtskListInProc[GLCount].TITP_orgType:=GLxmlTskInPr.Attributes['tipOrgTp'];
            FCGtskListInProc[GLCount].TITP_orgIdx:=GLxmlTskInPr.Attributes['tipOrgIdx'];
            FCGtskListInProc[GLCount].TITP_destType:=GLxmlTskInPr.Attributes['tipDestTp'];
            FCGtskListInProc[GLCount].TITP_destIdx:=GLxmlTskInPr.Attributes['tipDestIdx'];
            FCGtskListInProc[GLCount].TITP_regIdx:=GLxmlTskInPr.Attributes['tipRegIdx'];
            FCGtskListInProc[GLCount].TITP_velCruise:=GLxmlTskInPr.Attributes['tipVelCr'];
            FCGtskListInProc[GLCount].TITP_timeToCruise:=GLxmlTskInPr.Attributes['tipTimeTcr'];
            FCGtskListInProc[GLCount].TITP_timeDecel:=GLxmlTskInPr.Attributes['tipTimeTdec'];
            FCGtskListInProc[GLCount].TITP_time2xfert:=GLxmlTskInPr.Attributes['tipTime2Xfrt'];
            FCGtskListInProc[GLCount].TITP_time2xfert2decel:=GLxmlTskInPr.Attributes['tipTime2XfrtDec'];
            FCGtskListInProc[GLCount].TITP_velFinal:=GLxmlTskInPr.Attributes['tipVelFin'];
            FCGtskListInProc[GLCount].TITP_timeToFinal:=GLxmlTskInPr.Attributes['tipTimeTfin'];
            FCGtskListInProc[GLCount].TITP_accelbyTick:=GLxmlTskInPr.Attributes['tipAccelBtick'];
            FCGtskListInProc[GLcount].TITP_usedRMassV:=GLxmlTskInPr.Attributes['tipUsedRM'];
            FCGtskListInProc[GLcount].TITP_str1:=GLxmlTskInPr.Attributes['tipStr1'];
            FCGtskListInProc[GLcount].TITP_str2:=GLxmlTskInPr.Attributes['tipStr2'];
            FCGtskListInProc[GLcount].TITP_int1:=GLxmlTskInPr.Attributes['tipInt1'];
            GLxmlTskInPr:=GLxmlTskInPr.NextSibling;
         end; {.while GLxmlGamItmTskInPr<>nil}
      end; {.if GLxmlGamItmTskInPr<>nil}
      {.read "CSM" section}
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfCSM');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlCSMpL:=GLxmlItm.ChildNodes.First;
         SetLength(FCGcsmPhList, 1);
         while GLxmlCSMpL<>nil do
         begin
            SetLength(FCGcsmPhList, length(FCGcsmPhList)+1);
            inc(GLcount);
            FCGcsmPhList[GLcount].CSMT_tick:=GLxmlCSMpL.Attributes['csmTick'];
            GLphFac:=0;
            GLphFacOld:=-1;
            GLxmlCSMpLsub:=GLxmlCSMpL.ChildNodes.First;
            while GLxmlCSMpLsub<>nil do
            begin
               GLphFac:=GLxmlCSMpLsub.Attributes['fac'];
               if GLphFac<>GLphFacOld
               then
               begin
                  GLphFacOld:=GLphFac;
                  SetLength(FCGcsmPhList[GLcount].CSMT_col[GLphFac], 1);
                  GLphItm:=0;
               end;
               SetLength(FCGcsmPhList[GLcount].CSMT_col[GLphFac], length(FCGcsmPhList[GLcount].CSMT_col[GLphFac])+1);
               inc(GLphItm);
               FCGcsmPhList[GLcount].CSMT_col[GLphFac, GLphItm]:=GLxmlCSMpLsub.Attributes['colony'];
               GLxmlCSMpLsub:=GLxmlCSMpLsub.NextSibling;
            end;
            GLxmlCSMpL:=GLxmlCSMpL.NextSibling;
         end; //==END== GLxmlCSMpL<>nil ==//
      end; //==END== if GLxmlItm<>nil for CSM ==//
      {.entities section}
      FCMdG_Entities_Clear;
      GLxmlEntRoot:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfEntities');
      if GLxmlEntRoot<>nil
      then
      begin
         GLentCnt:=0;
         GLxmlEnt:=GLxmlEntRoot.ChildNodes.First;
         while GLxmlEnt<>nil do
         begin
            FCentities[GLentCnt].E_token:=GLxmlEnt.Attributes['token'];
            FCentities[GLentCnt].E_facLvl:=GLxmlEnt.Attributes['lvl'];
            FCentities[GLentCnt].E_bureau:=GLxmlEnt.Attributes['bur'];
            FCentities[GLentCnt].E_corrupt:=GLxmlEnt.Attributes['corr'];
            FCentities[GLentCnt].E_hqHigherLvl:=GLxmlEnt.Attributes['hqHlvl'];
            FCentities[GLentCnt].E_uc:=GLxmlEnt.Attributes['UCrve'];
            GLxmlEntSubRoot:=GLxmlEnt.ChildNodes.First;
            SetLength(FCentities[GLentCnt].E_spU, 1);
            SetLength(FCentities[GLentCnt].E_col,1);
            SetLength(FCentities[GLentCnt].E_spm,1);
            while GLxmlEntSubRoot<>nil do
            begin
               if GLxmlEntSubRoot.NodeName='entOwnSpU'
               then
               begin
                  GLcount:=0;
                  GLxmlSpOwn:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlSpOwn<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_spU, length(FCentities[GLentCnt].E_spU)+1);
                     inc(GLcount);
                     FCentities[GLentCnt].E_spU[GLcount].SUO_spUnToken:=GLxmlSpOwn.Attributes['tokenId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_nameToken:=GLxmlSpOwn.Attributes['tokenName'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_designId:=GLxmlSpOwn.Attributes['desgnId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_starSysLoc:=GLxmlSpOwn.Attributes['ssLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_starLoc:=GLxmlSpOwn.Attributes['stLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_oobjLoc:=GLxmlSpOwn.Attributes['oobjLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_satLoc:=GLxmlSpOwn.Attributes['satLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_3dObjIdx:=GLxmlSpOwn.Attributes['TdObjIdx'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_locStarX:=GLxmlSpOwn.Attributes['xLoc'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_locStarZ:=GLxmlSpOwn.Attributes['zLoc'];
                     GLdock:=GLxmlSpOwn.Attributes['docked'];
                     if GLdock>0
                     then
                     begin
                        SetLength(FCentities[GLentCnt].E_spU[GLcount].SUO_dockedSU, GLdock+1);
                        GLsubCnt:=1;
                        GLxmlDock:=GLxmlSpOwn.ChildNodes.First;
                        while GLsubCnt<=GLdock do
                        begin
                           FCentities[GLentCnt].E_spU[GLcount].SUO_dockedSU[GLsubCnt].SUD_dckdToken:=GLxmlDock.Attributes['token'];
                           inc(GLsubCnt);
                           GLxmlDock:=GLxmlDock.NextSibling;
                        end;
                     end;
                     FCentities[GLentCnt].E_spU[GLcount].SUO_taskIdx:=GLxmlSpOwn.Attributes['taskId'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_status:=GLxmlSpOwn.Attributes['status'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_deltaV:=GLxmlSpOwn.Attributes['dV'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_3dmove:=GLxmlSpOwn.Attributes['TdMov'];
                     FCentities[GLentCnt].E_spU[GLcount].SUO_availRMass:=GLxmlSpOwn.Attributes['availRMass'];
                     GLxmlSpOwn:=GLxmlSpOwn.NextSibling;
                  end;
               end //==END== if GLxmlEntSubRoot.NodeName='entOwnSpU' ==//
               else if GLxmlEntSubRoot.NodeName='entColonies'
               then
               begin
                  GLcount:=0;
                  if assigned(FCcps)
                  then FCcps.FCM_ViabObj_Init(false);
                  GLxmlCol:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlCol<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_col, length(FCentities[GLentCnt].E_col)+1);
                     inc(GLcount);
                     SetLength(FCentities[GLentCnt].E_col[GLcount].COL_evList, 1);
                     SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements, 1);
                     GLevCnt:=0;
                     GLsettleCnt:=0;
                     FCentities[GLentCnt].E_col[GLcount].COL_name:=GLxmlCol.Attributes['prname'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndYr:=GLxmlCol.Attributes['fndyr'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndMth:=GLxmlCol.Attributes['fndmth'];
                     FCentities[GLentCnt].E_col[GLcount].COL_fndDy:=GLxmlCol.Attributes['fnddy'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmtime:=GLxmlCol.Attributes['csmtime'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locSSys:=GLxmlCol.Attributes['locssys'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locStar:=GLxmlCol.Attributes['locstar'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locOObj:=GLxmlCol.Attributes['locoobj'];
                     FCentities[GLentCnt].E_col[GLcount].COL_locSat:=GLxmlCol.Attributes['locsat'];
                     GLoobjRow[1]:=GLoobjRow[0];
                     GLoobjRow[2]:=GLoobjRow[0];
                     GLoobjRow[3]:=GLoobjRow[0];
                     GLoobjRow[4]:=GLoobjRow[0];
                     GLoobjRow:=FCFuF_StelObj_GetFullRow(
                        FCentities[GLentCnt].E_col[GLcount].COL_locSSys
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locStar
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locOObj
                        ,FCentities[GLentCnt].E_col[GLcount].COL_locOObj
                        );
                     if GLoobjRow[4]=0
                     then FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_colonies[0]:=GLcount
                     else if GLoobjRow[4]>0
                     then FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_colonies[0]:=GLcount;
                     FCentities[GLentCnt].E_col[GLcount].COL_level:=GLxmlCol.Attributes['collvl'];
                     FCentities[GLentCnt].E_col[GLcount].COL_hqPres:=GLxmlCol.Attributes['hqpresence'];
                     FCentities[GLentCnt].E_col[GLcount].COL_cohes:=GLxmlCol.Attributes['dcohes'];
                     FCentities[GLentCnt].E_col[GLcount].COL_secu:=GLxmlCol.Attributes['dsecu'];
                     FCentities[GLentCnt].E_col[GLcount].COL_tens:=GLxmlCol.Attributes['dtens'];
                     FCentities[GLentCnt].E_col[GLcount].COL_edu:=GLxmlCol.Attributes['dedu'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOpcap:=GLxmlCol.Attributes['csmPCAP'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOspl:=GLxmlCol.Attributes['csmSPL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHOqol:=GLxmlCol.Attributes['csmQOL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmHEheal:=GLxmlCol.Attributes['csmHEAL'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENcons:=GLxmlCol.Attributes['csmEnCons'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENgen:=GLxmlCol.Attributes['csmEnGen'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENstorCurr:=GLxmlCol.Attributes['csmEnStorCurr'];
                     FCentities[GLentCnt].E_col[GLcount].COL_csmENstorMax:=GLxmlCol.Attributes['csmEnStorMax'];
                     FCentities[GLentCnt].E_col[GLcount].COL_eiOut:=GLxmlCol.Attributes['eiOut'];
                     GLxmlColsub:=GLxmlCol.ChildNodes.First;
                     while GLxmlColsub<>nil do
                     begin
                        {.colony population}
                        if GLxmlColsub.NodeName='colPopulation'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_total:=GLxmlColsub.Attributes['popTtl'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_meanA:=GLxmlColsub.Attributes['popMeanAge'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_dRate:=GLxmlColsub.Attributes['popDRate'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_dStack:=GLxmlColsub.Attributes['popDStack'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_bRate:=GLxmlColsub.Attributes['popBRate'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_bStack:=GLxmlColsub.Attributes['popBStack'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpColon:=GLxmlColsub.Attributes['popColon'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpColonAssigned:=GLxmlColsub.Attributes['popColonAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASoff:=GLxmlColsub.Attributes['popOff'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASoffAssigned:=GLxmlColsub.Attributes['popOffAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASmiSp:=GLxmlColsub.Attributes['popMisSpe'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpASmiSpAssigned:=GLxmlColsub.Attributes['popMisSpeAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSbio:=GLxmlColsub.Attributes['popBiol'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSbioAssigned:=GLxmlColsub.Attributes['popBiolAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSdoc:=GLxmlColsub.Attributes['popDoc'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpBSdocAssigned:=GLxmlColsub.Attributes['popDocAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpIStech:=GLxmlColsub.Attributes['popTech'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpIStechAssigned:=GLxmlColsub.Attributes['popTechAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpISeng:=GLxmlColsub.Attributes['popEng'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpISengAssigned:=GLxmlColsub.Attributes['popEngAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMSsold:=GLxmlColsub.Attributes['popSold'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMSsoldAssigned:=GLxmlColsub.Attributes['popSoldAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMScomm:=GLxmlColsub.Attributes['popComm'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMScommAssigned:=GLxmlColsub.Attributes['popCommAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSphys:=GLxmlColsub.Attributes['popPhys'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSphysAssigned:=GLxmlColsub.Attributes['popPhysAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSastr:=GLxmlColsub.Attributes['popAstro'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpPSastrAssigned:=GLxmlColsub.Attributes['popAstroAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecol:=GLxmlColsub.Attributes['popEcol'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecolAssigned:=GLxmlColsub.Attributes['popEcolAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecof:=GLxmlColsub.Attributes['popEcof'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpESecofAssigned:=GLxmlColsub.Attributes['popEcofAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpAmedian:=GLxmlColsub.Attributes['popMedian'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpAmedianAssigned:=GLxmlColsub.Attributes['popMedianAssign'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpRebels:=GLxmlColsub.Attributes['popRebels'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_tpMilitia:=GLxmlColsub.Attributes['popMilitia'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_wcpTotal:=GLxmlColsub.Attributes['wcpTotal'];
                           FCentities[GLentCnt].E_col[GLcount].COL_population.POP_wcpAssignedPeople:=GLxmlColsub.Attributes['wcpAssignPpl'];
                        end
                        {.colony events}
                        else if GLxmlColsub.NodeName='colEvent'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_evList, length(FCentities[GLentCnt].E_col[GLcount].COL_evList)+1);
                           inc(GLevCnt);
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_token:=GLxmlColsub.Attributes['token'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_isRes:=GLxmlColsub.Attributes['isres'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_duration:=GLxmlColsub.Attributes['duration'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_lvl:=GLxmlColsub.Attributes['level'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_cohMod:=GLxmlColsub.Attributes['modcoh'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_tensMod:=GLxmlColsub.Attributes['modtens'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_secMod:=GLxmlColsub.Attributes['modsec'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_eduMod:=GLxmlColsub.Attributes['modedu'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_iecoMod:=GLxmlColsub.Attributes['modieco'];
                           FCentities[GLentCnt].E_col[GLcount].COL_evList[GLevCnt].CSMEV_healMod:=GLxmlColsub.Attributes['modheal'];
                        end
                        {.colony settlements}
                        else if GLxmlColsub.NodeName='colSettlement'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements, length(FCentities[GLentCnt].E_col[GLcount].COL_settlements)+1);
                           inc(GLsettleCnt);
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra, 1);
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_name:=GLxmlColsub.Attributes['name'];
                           GLsettleType:=GLxmlColsub.Attributes['type'];
                           if GLsettleType='stSurface'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSurface
                           else if GLsettleType='stSpaceSurf'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSpaceSurf
                           else if GLsettleType='stSubterranean'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSubterranean
                           else if GLsettleType='stSpaceBased'
                           then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_type:=stSpaceBased;
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_level:=GLxmlColsub.Attributes['level'];
                           FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_region:=GLxmlColsub.Attributes['region'];
                           GLregionIdx:=FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_region;
                           if GLoobjRow[4]=0
                           then
                           begin
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setEnt:=GLentCnt;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setCol:=GLcount;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_regions[GLregionIdx].OOR_setSet:=GLsettleCnt;
                           end
                           else if GLoobjRow[4]>0
                           then
                           begin
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setEnt:=GLentCnt;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setCol:=GLcount;
                              FCDBSsys[GLoobjRow[1]].SS_star[GLoobjRow[2]].SDB_obobj[GLoobjRow[3]].OO_satList[GLoobjRow[4]].OOS_regions[GLregionIdx].OOR_setSet:=GLsettleCnt;
                           end;
                           GLinfCnt:=0;
                           GLxmlInfra:=GLxmlColsub.ChildNodes.First;
                           while GLxmlInfra<>nil do
                           begin
                              SetLength(
                                 FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra
                                 ,length(FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra
                                 )+1);
                              inc(GLinfCnt);
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_dbToken:=GLxmlInfra.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_level:=GLxmlInfra.Attributes['level'];
                              GLinfStatus:=GLxmlInfra.Attributes['status'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_cabDuration:=GLxmlInfra.Attributes['CABduration'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_cabWorked:=GLxmlInfra.Attributes['CABworked'];
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_powerCons:=GLxmlInfra.Attributes['powerCons'];
                              if GLinfStatus='istInKit'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInKit
                              else if GLinfStatus='istInConversion'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInConversion
                              else if GLinfStatus='istInAssembling'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInAssembling
                              else if GLinfStatus='istInBldSite'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInBldSite
                              else if GLinfStatus='istDisabled'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDisabled
                              else if GLinfStatus='istDisabledByEE'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDisabledByEE
                              else if GLinfStatus='istInTransition'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istInTransition
                              else if GLinfStatus='istOperational'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istOperational
                              else if GLinfStatus='istDestroyed'
                              then FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_status:=istDestroyed;
                              FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_function:=GLxmlInfra.Attributes['Func'];
                              case FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_function of
                                 fEnergy: FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fEnergOut:=GLxmlInfra.Attributes['energyOut'];
                                 fHousing:
                                 begin
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousPCAP:=GLxmlInfra.Attributes['PCAP'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousQOL:=GLxmlInfra.Attributes['QOL'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousVol:=GLxmlInfra.Attributes['vol'];
                                    FCentities[GLentCnt].E_col[GLcount].COL_settlements[GLsettleCnt].CS_infra[GLinfCnt].CI_fhousSurf:=GLxmlInfra.Attributes['surf'];
                                 end;
                              end;
                              GLxmlInfra:=GLxmlInfra.NextSibling;
                           end; //==END== while GLxmlInfra<>nil do ==//
                        end //==END== else if GLxmlColsub.NodeName='colSettlement' ==//
                        {.colony's CAB queue}
                        else if GLxmlColsub.NodeName='colCAB'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue, GLsettleCnt+1);
                           GLsettleMax:=GLsettleCnt;
                           GLsettleCnt:=1;
                           while GLsettleCnt<=GLsettleMax do
                           begin
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt], 1);
                              inc(GLsettleCnt);
                           end;
                           GLxmlCAB:=GLxmlColsub.ChildNodes.First;
                           while GLxmlCAB<>nil do
                           begin
                              GLsettleCnt:=GLxmlCAB.Attributes['settlement'];
                              GLcabValue:=GLxmlCAB.Attributes['infraIdx'];
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt], length(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt])+1);
                              GLcabCnt:=length(FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt])-1;
                              FCentities[GLentCnt].E_col[GLcount].COL_cabQueue[GLsettleCnt, GLcabCnt]:=GLcabValue;
                              GLxmlCAB:=GLxmlCAB.NextSibling;
                           end;
                        end
                        {.colony's production matrix}
                        else if GLxmlColsub.NodeName='colProdMatrix'
                        then
                        begin
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix, 1);
                           GLprodMatrixCnt:=0;
                           GLxmlProdMatrix:=GLxmlColsub.ChildNodes.First;
                           while GLxmlProdMatrix<>nil do
                           begin
                              inc(GLprodMatrixCnt);
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix, GLprodMatrixCnt+1);
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_token:=GLxmlProdMatrix.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_unit:=GLxmlProdMatrix.Attributes['unit'];
                              FCentities[GLentCnt].E_col[GLcount].COL_productionMatrix[GLprodMatrixCnt].CPMI_StorageIndex:=GLxmlProdMatrix.Attributes['storIdx'];
                              GLxmlProdMatrix:=GLxmlProdMatrix.NextSibling;
                           end;
                        end
                        {.colony's storage}
                        else if GLxmlColsub.NodeName='colStorage'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacitySolidCurr:=GLxmlColsub.Attributes['capSolidCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacitySolidMax:=GLxmlColsub.Attributes['capSolidMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityLiquidCurr:=GLxmlColsub.Attributes['capLiquidCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityLiquidMax:=GLxmlColsub.Attributes['capLiquidMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityGasCurr:=GLxmlColsub.Attributes['capGasCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityGasMax:=GLxmlColsub.Attributes['capGasMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityBioCurr:=GLxmlColsub.Attributes['capBioCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_storCapacityBioMax:=GLxmlColsub.Attributes['capBioMax'];
                           SetLength(FCentities[GLentCnt].E_col[GLcount].COL_storageList, 1);
                           GLstorageCnt:=0;
                           GLxmlStorage:=GLxmlColsub.ChildNodes.First;
                           while GLxmlStorage<>nil do
                           begin
                              inc(GLstorageCnt);
                              SetLength(FCentities[GLentCnt].E_col[GLcount].COL_storageList, GLstorageCnt+1);
                              FCentities[GLentCnt].E_col[GLcount].COL_storageList[GLstorageCnt].CPR_token:=GLxmlStorage.Attributes['token'];
                              FCentities[GLentCnt].E_col[GLcount].COL_storageList[GLstorageCnt].CPR_unit:=GLxmlStorage.Attributes['unit'];
                              GLxmlStorage:=GLxmlStorage.NextSibling;
                           end;
                        end
                        else if GLxmlColsub.NodeName='colReserves'
                        then
                        begin
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveFoodCur:=GLxmlColsub.Attributes['foodCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveFoodMax:=GLxmlColsub.Attributes['foodMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveOxygenCur:=GLxmlColsub.Attributes['oxygenCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveOxygenMax:=GLxmlColsub.Attributes['oxygenMax'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveWaterCur:=GLxmlColsub.Attributes['waterCur'];
                           FCentities[GLentCnt].E_col[GLcount].COL_reserveWaterMax:=GLxmlColsub.Attributes['waterMax'];
								end;
                        GLxmlColsub:=GLxmlColsub.NextSibling;
                     end; //==END== while GLxmlColsub<>nil do ==//
                     GLxmlCol:=GLxmlCol.NextSibling;
                  end; //==END== while GLxmlCol<>nil do ==//
               end //==END== else if GLxmlEntSubRoot.NodeName='entColonies' ==//
               else if GLxmlEntSubRoot.NodeName='entSPMset'
               then
               begin
                  FCentities[GLentCnt].E_spmMcohes:=GLxmlEntSubRoot.Attributes['modCoh'];
                  FCentities[GLentCnt].E_spmMtens:=GLxmlEntSubRoot.Attributes['modTens'];
                  FCentities[GLentCnt].E_spmMsec:=GLxmlEntSubRoot.Attributes['modSec'];
                  FCentities[GLentCnt].E_spmMedu:=GLxmlEntSubRoot.Attributes['modEdu'];
                  FCentities[GLentCnt].E_spmMnat:=GLxmlEntSubRoot.Attributes['modNat'];
                  FCentities[GLentCnt].E_spmMhealth:=GLxmlEntSubRoot.Attributes['modHeal'];
                  FCentities[GLentCnt].E_spmMBur:=GLxmlEntSubRoot.Attributes['modBur'];
                  FCentities[GLentCnt].E_spmMCorr:=GLxmlEntSubRoot.Attributes['modCorr'];
                  GLcount:=0;
                  GLxmlSPMset:=GLxmlEntSubRoot.ChildNodes.First;
                  while GLxmlSPMset<>nil do
                  begin
                     SetLength(FCentities[GLentCnt].E_spm, length(FCentities[GLentCnt].E_spm)+1);
                     inc(GLcount);
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_token:=GLxmlSPMset.Attributes['token'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_duration:=GLxmlSPMset.Attributes['duration'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_ucCost:=GLxmlSPMset.Attributes['ucCost'];
                     FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy:=GLxmlSPMset.Attributes['ispolicy'];
                     if FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy
                     then
                     begin
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_isSet:=GLxmlSPMset.Attributes['isSet'];
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_aprob:=GLxmlSPMset.Attributes['aprob'];
                     end
                     else if not FCentities[GLentCnt].E_spm[GLcount].SPMS_isPolicy
                     then
                     begin
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_bLvl:=GLxmlSPMset.Attributes['belieflvl'];
                        FCentities[GLentCnt].E_spm[GLcount].SPMS_sprdVal:=GLxmlSPMset.Attributes['spreadval'];
                     end;
                     GLxmlSPMset:=GLxmlSPMset.NextSibling;
                  end;
               end; //==END== if GLxmlEntSubRoot.NodeName='entSPMset' ==//
               GLxmlEntSubRoot:=GLxmlEntSubRoot.NextSibling;
            end; //==END== while GLxmlEntSubRoot<>nil do ==//
            inc(GLentCnt);
            GLxmlEnt:=GLxmlEnt.NextSibling;
         end; //==END== while GLxmlEnt<>nil do ==//
      end; //==END== if GLxmlEntRoot<>nil FOR COLONIES==//
      {.read "msgqueue" saved game item}
      setlength(FCVmsgStoTtl,1);
      setlength(FCVmsgStoMsg,1);
      GLxmlItm:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMsgQueue');
      if GLxmlItm<>nil
      then
      begin
         GLcount:=0;
         GLxmlMsg:=GLxmlItm.ChildNodes.First;
         while GLxmlMsg<>nil do
         begin
            SetLength(FCVmsgStoTtl, length(FCVmsgStoTtl)+1);
            SetLength(FCVmsgStoMsg, length(FCVmsgStoMsg)+1);
            inc(GLcount);
            FCVmsgStoTtl[GLcount]:=GLxmlMsg.Attributes['msgTitle'];
            FCVmsgStoMsg[GLcount]:=GLxmlMsg.Attributes['msgMain'];
            GLxmlMsg:=GLxmlMsg.NextSibling;
         end;
      end; {.if GLxmlGamItm<>nil}
   end //==END== if (DirectoryExists(GLcurrDir)) and (FileExists(GLcurrDir+'\'+GLcurrG)) ==//
   else FCRplayer.P_starSysLoc:='';
   {.free the memory}
   FCWinMain.FCXMLsave.Active:=false;
   FCWinMain.FCXMLsave.FileName:='';
end;

procedure FCMdF_Game_Save;
{:Purpose: save the current game.
    Additions:
      -2011Jul31- *add: infrastructure status istDisabledByEE.
      -2011Jul19- *add: CSM Energy module - storage data.
      -2011Jul13- *add: infrastructure consumed power.
      -2011Jul12- *add: CSM - Energy data.
      -2011Jul07- *add: colonies' production matrix.
      -2011May25- *rem: infrastructure - converted housing, useless state.
      -2011May15-	*add: colony's infrastructure - CAB worked hours.
      -2011May05- *mod: complete change of colony's storage loading/saving.
      -2011Apr26- *add: colonies' assigned population data.
                  *add: colonies' construction workforce.
      -2011Apr24- *add: energy output for Energy class infrastructures.
      -2011Apr20- *add: CPS - isEnabled.
      -2011Mar16-	*add: colonies' storages + reserves.
      -2011Mar09- *add: infrastructure's CAB duration.
                  *add: colonies' CAB queue.
      -2011Mar07- *add: converted housing infrastructures.
      -2011Feb12- *add: extra task's data.
                  *add: settlements.
      -2011Feb08- *add: full status token saving, independent of the index.
      -2011Feb01- *add: economic & industrial output.
      -2010Dec29- *add: SPM cost storage data.
      -2010Dec19- *add: entities higher hq level present in the faction.
      -2010Nov08- *add: entities UC reserve.
      -2010Nov03- *add: SPMi duration.
      -2010Oct24- *add: HQ presence data for each colony.
      -2010Oct11- *add: player's faction status of the 3 categories.
      -2010Oct07- *add: memes values + policy status.
      -2010Sep29- *add: entity's bureaucracy and corruption modifiers.
      -2010Sep22- *add: bureaucracy and corruption entities data.
                  *add: SPMi isSet data.
      -2010Sep21- *add: spm settings for entities.
      -2010Sep16- *add: entities code.
      -2010Sep07- *add: saving in specific file now, including date/time: name-yr-mth-day-h-mn.
                  *add: save current file time frame in configuration file.
      -2010Aug30- *add: CSM Phase list.
      -2010Aug19- *add: population type: militia.
      -2010Aug16- *add: population type: rebels.
      -2010Aug09- *add: CSM event duration.
      -2010Aug02- *add: CSM event health modifier.
      -2010Jul27- *add: CSM event level + economic & industrial output modifier.
      -2010Jul21- *add: csmTime data.
      -2010Jul02- *add: tasklisk string data.
      -2010Jun08- *add: space unit: include the docked sub data structure.
      -2010May30- *add: colony's population sub-datastructure.
      -2010May27- *add: csm data pcap, spl, qol and heal.
      -2010May19- *add: colony infrastructures: status.
      -2010May18- *add: colony infrastructures.
      -2010May12- *add: in process task phase data.
      -2010May10- *add: the two time2xfert data.
      -2010May05- *add: TITP_regIdx.
      -2010May04- *add: TITP_timeOrg, TITP_orgType, TITP_timeDecel, TITP_accelbyTick.
                  *mod: threads saving is disabled.
      -2010Mar31- *add: colony level.
      -2010Mar27- *add: space unit docked data.
      -2010Mar22- *add: cps time left
      -2010Mar11- *add: cps data.
      -2010Mar03- *add: owned colonies.
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
      -2009Dec19- *add: player's sat location.
      -2009Dec18- *add: satellite location for owned space unit.
      -2009Nov28- *add messages queue.
      -2009Nov27- *add TITP_usedRMassV.
      -2009Nov12- *add threads.
      -2009Nov10- *add tasklist in process.
      -2009Nov09- *pause the game if FAR Colony is not in closing process, and release it
                  after.
      -2009Nov08- *add owned space units.
}
var
   GSxmlCAB
   ,GSxmlCABroot
   ,GSxmlCol
   ,GSxmlColEv
   ,GSxmlColInf
   ,GSxmlCPS
   ,GSxmlCSMpL
   ,GSxmlCSMpLsub
   ,GSxmlDock
   ,GSxmlEntRoot
   ,GSxmlEnt
   ,GSxmlItm
   ,GSxmlMsg
   ,GSxmlPop
   ,GSxmlProdMatrix
   ,GSxmlProdMatrixRoot
   ,GSxmlReserves
   ,GSxmlRoot
   ,GSxmlSettle
   ,GSxmlSPM
   ,GSxmlSpOwn
   ,GSxmlstorage
	,GSxmlstorageRoot
   ,GSxmlTskInPr: IXMLNode;

   GScabCount
   ,GScabMax
   ,GScount
   ,GSdock
   ,GSlength
   ,GSphFac
   ,GSphItm
   ,GSspuMax
   ,GSspuCnt
   ,GScolMax
   ,GScolCnt
   ,GSprodMatrixCnt
   ,GSprodMatrixMax
   ,GSsettleCnt
   ,GSsettleMax
   ,GSstorageCnt
	,GSstorageMax
   ,GSspmMax
   ,GSspmCnt
   ,GSsubL
   ,GSsubC: integer;

   GScurrDir
   ,GScurrG
   ,GSinfStatus
   ,GSsettleTp: string;
begin
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set(tphPAUSE);
   GScurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
   GScurrG:=IntToStr(FCRplayer.P_timeYr)
      +'-'+IntToStr(FCRplayer.P_timeMth)
      +'-'+IntToStr(FCRplayer.P_timeday)
      +'-'+IntToStr(FCRplayer.P_timeHr)
      +'-'+IntToStr(FCRplayer.P_timeMin)
      +'.xml';
   {.create the save directory if needed}
   if not DirectoryExists(GScurrDir)
   then MkDir(GScurrDir);
   {.clear the old file if it exists}
   if FileExists(GScurrDir+'\'+GScurrG)
   then DeleteFile(pchar(GScurrDir+'\'+GScurrG));
   FCMdF_ConfigFile_Write(true);
   {.link and activate TXMLDocument}
   FCWinMain.FCXMLsave.Active:=true;
   {.create the root node of the saved game file}
   GSxmlRoot:=FCWinMain.FCXMLsave.AddChild('savedgfile');
   {.create "main" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfMain');
   GSxmlItm.Attributes['gName']:= FCRplayer.P_gameName;
   GSxmlItm.Attributes['facAlleg']:= FCRplayer.P_facAlleg;
   GSxmlItm.Attributes['plyrsSSLoc']:= FCRplayer.P_starSysLoc;
   GSxmlItm.Attributes['plyrsStLoc']:= FCRplayer.P_starLoc;
   GSxmlItm.Attributes['plyrsOObjLoc']:= FCRplayer.P_oObjLoc;
   GSxmlItm.Attributes['plyrsatLoc']:=FCRplayer.P_satLoc;
   {.create "timeframe" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfTimeFr');
   GSxmlItm.Attributes['tfTick']:= FCRplayer.P_timeTick;
   GSxmlItm.Attributes['tfMin']:= FCRplayer.P_timeMin;
   GSxmlItm.Attributes['tfHr']:= FCRplayer.P_timeHr;
   GSxmlItm.Attributes['tfDay']:= FCRplayer.P_timeday;
   GSxmlItm.Attributes['tfMth']:= FCRplayer.P_timeMth;
   GSxmlItm.Attributes['tfYr']:= FCRplayer.P_timeYr;
   {.create "status" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfStatus');
   GSxmlItm.Attributes['statEco']:=FCRplayer.P_ecoStat;
   GSxmlItm.Attributes['statSoc']:=FCRplayer.P_socStat;
   GSxmlItm.Attributes['statMil']:=FCRplayer.P_milStat;
   {.create "cps" saved game item}
   if FCcps<>nil
   then
   begin
      GSlength:=length(FCcps.CPSviabObj);
      GSxmlItm:=GSxmlRoot.AddChild('gfCPS');
      GSxmlItm.Attributes['cpsEnabled']:=FCcps.CPSisEnabled;
      GSxmlItm.Attributes['cpsCVS']:=FCcps.FCF_CVS_Get;
      GSxmlItm.Attributes['cpsTlft']:=FCcps.FCF_TimeLeft_Get(true);
      GSxmlItm.Attributes['cpsInt']:=FCcps.FCF_CredInt_Get;
      GSxmlItm.Attributes['cpsCredU']:=FCcps.FCF_CredLine_Get(true, true);
      GSxmlItm.Attributes['cpsCredM']:=FCcps.FCF_CredLine_Get(false, true);
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCPS:=GSxmlItm.AddChild('gfViabObj');
         GSxmlCPS.Attributes['objTp']:=FCcps.CPSviabObj[GScount].CPSO_type;
         GSxmlCPS.Attributes['score']:=FCcps.CPSviabObj[GScount].CPSO_score;
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; //==END== if FCcps<>nil ==//
   {.create "taskinprocess" saved game item}
   GSlength:=length(FCGtskListInProc);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfTskLstinProc');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlTskInPr:=GSxmlItm.AddChild('gfTskInProc');
         GSxmlTskInPr.Attributes['tipEna']:=FCGtskListInProc[GScount].TITP_enabled;
         GSxmlTskInPr.Attributes['tipActTp']:=FCGtskListInProc[GScount].TITP_actionTp;
         GSxmlTskInPr.Attributes['tipPhase']:=FCGtskListInProc[GScount].TITP_phaseTp;
         GSxmlTskInPr.Attributes['tipTgtTp']:=FCGtskListInProc[GScount].TITP_ctldType;
         GSxmlTskInPr.Attributes['tipTgtFac']:=FCGtskListInProc[GScount].TITP_ctldFac;
         GSxmlTskInPr.Attributes['tipTgtIdx']:=FCGtskListInProc[GScount].TITP_ctldIdx;
         GSxmlTskInPr.Attributes['tipTimeOrg']:=FCGtskListInProc[GScount].TITP_timeOrg;
         GSxmlTskInPr.Attributes['tipDura']:=FCGtskListInProc[GScount].TITP_duration;
         GSxmlTskInPr.Attributes['tipInterv']:=FCGtskListInProc[GScount].TITP_interval;
         GSxmlTskInPr.Attributes['tipOrgTp']:=FCGtskListInProc[GScount].TITP_orgType;
         GSxmlTskInPr.Attributes['tipOrgIdx']:=FCGtskListInProc[GScount].TITP_orgIdx;
         GSxmlTskInPr.Attributes['tipDestTp']:=FCGtskListInProc[GScount].TITP_destType;
         GSxmlTskInPr.Attributes['tipDestIdx']:=FCGtskListInProc[GScount].TITP_destIdx;
         GSxmlTskInPr.Attributes['tipRegIdx']:=FCGtskListInProc[GScount].TITP_regIdx;
         GSxmlTskInPr.Attributes['tipVelCr']:=FCGtskListInProc[GScount].TITP_velCruise;
         GSxmlTskInPr.Attributes['tipTimeTcr']:=FCGtskListInProc[GScount].TITP_timeToCruise;
         GSxmlTskInPr.Attributes['tipTimeTdec']:=FCGtskListInProc[GScount].TITP_timeDecel;
         GSxmlTskInPr.Attributes['tipTime2Xfrt']:=FCGtskListInProc[GScount].TITP_time2xfert;
         GSxmlTskInPr.Attributes['tipTime2XfrtDec']:=FCGtskListInProc[GScount].TITP_time2xfert2decel;
         GSxmlTskInPr.Attributes['tipVelFin']:=FCGtskListInProc[GScount].TITP_velFinal;
         GSxmlTskInPr.Attributes['tipTimeTfin']:=FCGtskListInProc[GScount].TITP_timeToFinal;
         GSxmlTskInPr.Attributes['tipAccelBtick']:=FCGtskListInProc[GScount].TITP_accelbyTick;
         GSxmlTskInPr.Attributes['tipUsedRM']:=FCGtskListInProc[GScount].TITP_usedRMassV;
         GSxmlTskInPr.Attributes['tipStr1']:=FCGtskListInProc[GScount].TITP_str1;
         GSxmlTskInPr.Attributes['tipStr2']:=FCGtskListInProc[GScount].TITP_str1;
         GSxmlTskInPr.Attributes['tipInt1']:=FCGtskListInProc[GScount].TITP_int1;
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then}
   {.create "CSM" saved game item}
   GSlength:=length(FCGcsmPhList);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfCSM');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCSMpL:=GSxmlItm.AddChild('csmPhList');
         GSxmlCSMpL.Attributes['csmTick']:=FCGcsmPhList[GScount].CSMT_tick;
         GSphFac:=0;
         while GSphFac<=1 do
         begin
            GSsubL:=length(FCGcsmPhList[GScount].CSMT_col[GSphFac])-1;
            GSsubC:=1;
            if GSsubL>0
            then
            begin
               while GSsubC<=GSsubL do
               begin
                  GSxmlCSMpLsub:=GSxmlCSMpL.AddChild('csmPhase');
                  GSxmlCSMpLsub.Attributes['fac']:=GSphFac;
                  GSxmlCSMpLsub.Attributes['colony']:=FCGcsmPhList[GScount].CSMT_col[GSphFac, GSsubL];
                  inc(GSsubC);
               end;
            end;
            inc(GSphFac);
         end;
         inc(GScount);
      end; //==END== while GScount<=GSlength-1 ==//
   end; //==END== if GSlength>1 for CSM ==//
   {.create entities section}
   GSxmlEntRoot:=GSxmlRoot.AddChild('gfEntities');
   GScount:=0;
   while GScount<=FCCfacMax do
   begin
      GSxmlEnt:=GSxmlEntRoot.AddChild('entity');
      GSxmlEnt.Attributes['token']:=FCentities[GScount].E_token;
      GSxmlEnt.Attributes['lvl']:=FCentities[GScount].E_facLvl;
      GSxmlEnt.Attributes['bur']:=FCentities[GScount].E_bureau;
      GSxmlEnt.Attributes['corr']:=FCentities[GScount].E_corrupt;
      GSxmlEnt.Attributes['hqHlvl']:=FCentities[GScount].E_hqHigherLvl;
      GSxmlEnt.Attributes['UCrve']:=FCentities[GScount].E_uc;
      GSspuMax:=Length(FCentities[GScount].E_spU)-1;
      if GSspuMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entOwnSpU');
         GSspuCnt:=1;
         while GSspuCnt<=GSspuMax do
         begin
            GSdock:=length(FCentities[GScount].E_spU[GSspuCnt].SUO_dockedSU)-1;
            GSxmlSpOwn:=GSxmlItm.AddChild('entSpU');
            GSxmlSpOwn.Attributes['tokenId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_spUnToken;
            GSxmlSpOwn.Attributes['tokenName']:=FCentities[GScount].E_spU[GSspuCnt].SUO_nameToken;
            GSxmlSpOwn.Attributes['desgnId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_designId;
            GSxmlSpOwn.Attributes['ssLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_starSysLoc;
            GSxmlSpOwn.Attributes['stLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_starLoc;
            GSxmlSpOwn.Attributes['oobjLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_oobjLoc;
            GSxmlSpOwn.Attributes['satLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_satLoc;
            GSxmlSpOwn.Attributes['TdObjIdx']:=FCentities[GScount].E_spU[GSspuCnt].SUO_3dObjIdx;
            GSxmlSpOwn.Attributes['xLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_locStarX;
            GSxmlSpOwn.Attributes['zLoc']:=FCentities[GScount].E_spU[GSspuCnt].SUO_locStarZ;
            GSxmlSpOwn.Attributes['docked']:=GSdock;
            GSsubC:=1;
            while GSsubC<=GSdock do
            begin
               GSxmlDock:=GSxmlSpOwn.AddChild('entSpUdckd');
               GSxmlDock.Attributes['token']:=FCentities[GScount].E_spU[GSspuCnt].SUO_dockedSU[GSsubC].SUD_dckdToken;
               inc(GSsubC);
            end;
            GSxmlSpOwn.Attributes['taskId']:=FCentities[GScount].E_spU[GSspuCnt].SUO_taskIdx;
            GSxmlSpOwn.Attributes['status']:=FCentities[GScount].E_spU[GSspuCnt].SUO_status;
            GSxmlSpOwn.Attributes['dV']:=FCentities[GScount].E_spU[GSspuCnt].SUO_deltaV;
            GSxmlSpOwn.Attributes['TdMov']:=FCentities[GScount].E_spU[GSspuCnt].SUO_3dmove;
            GSxmlSpOwn.Attributes['availRMass']:=FCentities[GScount].E_spU[GSspuCnt].SUO_availRMass;
            inc(GSspuCnt);
         end; {.while GSspuCnt<=GSspuMax}
      end; //==END== if GSspuMax>0 ==//
      GScolMax:=Length(FCentities[GScount].E_col)-1;
      if GScolMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entColonies');
         GScolCnt:=1;
         while GScolCnt<=GScolMax do
         begin
            GSxmlCol:=GSxmlItm.AddChild('entColony');
            GSxmlCol.Attributes['prname']:=FCentities[GScount].E_col[GScolCnt].COL_name;
            GSxmlCol.Attributes['fndyr']:=FCentities[GScount].E_col[GScolCnt].COL_fndYr;
            GSxmlCol.Attributes['fndmth']:=FCentities[GScount].E_col[GScolCnt].COL_fndMth;
            GSxmlCol.Attributes['fnddy']:=FCentities[GScount].E_col[GScolCnt].COL_fndDy;
            GSxmlCol.Attributes['csmtime']:=FCentities[GScount].E_col[GScolCnt].COL_csmtime;
            GSxmlCol.Attributes['locssys']:=FCentities[GScount].E_col[GScolCnt].COL_locSSys;
            GSxmlCol.Attributes['locstar']:=FCentities[GScount].E_col[GScolCnt].COL_locStar;
            GSxmlCol.Attributes['locoobj']:=FCentities[GScount].E_col[GScolCnt].COL_locOObj;
            GSxmlCol.Attributes['locsat']:=FCentities[GScount].E_col[GScolCnt].COL_locSat;
            GSxmlCol.Attributes['collvl']:=FCentities[GScount].E_col[GScolCnt].COL_level;
            GSxmlCol.Attributes['hqpresence']:=FCentities[GScount].E_col[GScolCnt].COL_hqPres;
            GSxmlCol.Attributes['dcohes']:=FCentities[GScount].E_col[GScolCnt].COL_cohes;
            GSxmlCol.Attributes['dsecu']:=FCentities[GScount].E_col[GScolCnt].COL_secu;
            GSxmlCol.Attributes['dtens']:=FCentities[GScount].E_col[GScolCnt].COL_tens;
            GSxmlCol.Attributes['dedu']:=FCentities[GScount].E_col[GScolCnt].COL_edu;
            GSxmlCol.Attributes['csmPCAP']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOpcap;
            GSxmlCol.Attributes['csmSPL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOspl;
            GSxmlCol.Attributes['csmQOL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHOqol;
            GSxmlCol.Attributes['csmHEAL']:=FCentities[GScount].E_col[GScolCnt].COL_csmHEheal;
            GSxmlCol.Attributes['csmEnCons']:=FCentities[GScount].E_col[GScolCnt].COL_csmENcons;
            GSxmlCol.Attributes['csmEnGen']:=FCentities[GScount].E_col[GScolCnt].COL_csmENgen;
            GSxmlCol.Attributes['csmEnStorCurr']:=FCentities[GScount].E_col[GScolCnt].COL_csmENstorCurr;
            GSxmlCol.Attributes['csmEnStorMax']:=FCentities[GScount].E_col[GScolCnt].COL_csmENstorMax;
            GSxmlCol.Attributes['eiOut']:=FCentities[GScount].E_col[GScolCnt].COL_eiOut;
            {.colony population}
            GSxmlPop:=GSxmlCol.AddChild('colPopulation');
            GSxmlPop.Attributes['popTtl']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_total;
            GSxmlPop.Attributes['popMeanAge']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_meanA;
            GSxmlPop.Attributes['popDRate']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_dRate;
            GSxmlPop.Attributes['popDStack']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_dStack;
            GSxmlPop.Attributes['popBRate']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_bRate;
            GSxmlPop.Attributes['popBStack']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_bStack;
            GSxmlPop.Attributes['popColon']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpColon;
            GSxmlPop.Attributes['popColonAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpColonAssigned;
            GSxmlPop.Attributes['popOff']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASoff;
            GSxmlPop.Attributes['popOffAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASoffAssigned;
            GSxmlPop.Attributes['popMisSpe']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASmiSp;
            GSxmlPop.Attributes['popMisSpeAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpASmiSpAssigned;
            GSxmlPop.Attributes['popBiol']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSbio;
            GSxmlPop.Attributes['popBiolAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSbioAssigned;
            GSxmlPop.Attributes['popDoc']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSdoc;
            GSxmlPop.Attributes['popDocAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpBSdocAssigned;
            GSxmlPop.Attributes['popTech']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpIStech;
            GSxmlPop.Attributes['popTechAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpIStechAssigned;
            GSxmlPop.Attributes['popEng']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpISeng;
            GSxmlPop.Attributes['popEngAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpISengAssigned;
            GSxmlPop.Attributes['popSold']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMSsold;
            GSxmlPop.Attributes['popSoldAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMSsoldAssigned;
            GSxmlPop.Attributes['popComm']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMScomm;
            GSxmlPop.Attributes['popCommAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMScommAssigned;
            GSxmlPop.Attributes['popPhys']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSphys;
            GSxmlPop.Attributes['popPhysAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSphysAssigned;
            GSxmlPop.Attributes['popAstro']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSastr;
            GSxmlPop.Attributes['popAstroAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpPSastrAssigned;
            GSxmlPop.Attributes['popEcol']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecol;
            GSxmlPop.Attributes['popEcolAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecolAssigned;
            GSxmlPop.Attributes['popEcof']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecof;
            GSxmlPop.Attributes['popEcofAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpESecofAssigned;
            GSxmlPop.Attributes['popMedian']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpAmedian;
            GSxmlPop.Attributes['popMedianAssign']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpAmedianAssigned;
            GSxmlPop.Attributes['popRebels']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpRebels;
            GSxmlPop.Attributes['popMilitia']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_tpMilitia;
            GSxmlPop.Attributes['wcpTotal']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_wcpTotal;
            GSxmlPop.Attributes['wcpAssignPpl']:=FCentities[GScount].E_col[GScolCnt].COL_population.POP_wcpAssignedPeople;
            {.colony events}
            GSsubL:=length(FCentities[GScount].E_col[GScolCnt].COL_evList);
            if GSsubL>1
            then
            begin
               GSsubC:=1;
               while GSsubC<=GSsubL-1 do
               begin
                  GSxmlColEv:=GSxmlCol.AddChild('colEvent');
                  GSxmlColEv.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_token;
                  GSxmlColEv.Attributes['isres']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_isRes;
                  GSxmlColEv.Attributes['duration']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_duration;
                  GSxmlColEv.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_lvl;
                  GSxmlColEv.Attributes['modcoh']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_cohMod;
                  GSxmlColEv.Attributes['modtens']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_tensMod;
                  GSxmlColEv.Attributes['modsec']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_secMod;
                  GSxmlColEv.Attributes['modedu']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_eduMod;
                  GSxmlColEv.Attributes['modieco']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_iecoMod;
                  GSxmlColEv.Attributes['modheal']:=FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_healMod;
                  inc(GSsubC);
               end;
            end; //==END== if GSsubL>1 ==//
            {.colony settlements}
            GSsettleMax:=length(FCentities[GScount].E_col[GScolCnt].COL_settlements)-1;
            if GSsettleMax>0
            then
            begin
               GSxmlCABroot:=nil;
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GSxmlSettle:=GSxmlCol.AddChild('colSettlement');
                  GSxmlSettle.Attributes['name']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_name;
                  case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_type of
                     stSurface: GSsettleTp:='stSurface';
                     stSpaceSurf: GSsettleTp:='stSpaceSurf';
                     stSubterranean: GSsettleTp:='stSubterranean';
                     stSpaceBased: GSsettleTp:='stSpaceBased';
                  end;
                  GSxmlSettle.Attributes['type']:=GSsettleTp;
                  GSxmlSettle.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_level;
                  GSxmlSettle.Attributes['region']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_region;
                  GSsubL:=length(FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra)-1;
                  GSsubC:=1;
                  while GSsubC<=GSsubL do
                  begin
                     GSxmlColInf:=GSxmlSettle.AddChild('setInfra');
                     GSxmlColInf.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_dbToken;
                     GSxmlColInf.Attributes['level']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_level;
                     case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_status of
                        istInKit: GSinfStatus:='istInKit';
                        istInConversion: GSinfStatus:='istInConversion';
                        istInAssembling: GSinfStatus:='istInAssembling';
                        istInBldSite: GSinfStatus:='istInBldSite';
                        istDisabled: GSinfStatus:='istDisabled';
                        istDisabledByEE: GSinfStatus:='istDisabledByEE';
                        istInTransition: GSinfStatus:='istInTransition';
                        istOperational: GSinfStatus:='istOperational';
                        istDestroyed: GSinfStatus:='istDestroyed';
                     end;
                     GSxmlColInf.Attributes['status']:=GSinfStatus;
                     GSxmlColInf.Attributes['CABduration']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_cabDuration;
                     GSxmlColInf.Attributes['CABworked']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_cabWorked;
                     GSxmlColInf.Attributes['powerCons']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_powerCons;
                     GSxmlColInf.Attributes['Func']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_function;
                     case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_function of
                        fEnergy: GSxmlColInf.Attributes['energyOut']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fEnergOut;
                        fHousing:
                        begin
                           GSxmlColInf.Attributes['PCAP']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousPCAP;
                           GSxmlColInf.Attributes['QOL']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousQOL;
                           GSxmlColInf.Attributes['vol']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousVol;
                           GSxmlColInf.Attributes['surf']:=FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_fhousSurf;
                        end;
                     end;
                     inc(GSsubC);
                  end;
                  inc(GSsettleCnt);
               end; //==END== while GSsettleCnt<=GSsettleMax do ==//
               {.CAB queue}
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GScabMax:=length(FCentities[GScount].E_col[GScolCnt].COL_cabQueue[GSsettleCnt])-1;
                  if GScabMax>0
                  then
                  begin
                     if GSxmlCABroot=nil
                     then GSxmlCABroot:=GSxmlCol.AddChild('colCAB');
                     GScabCount:=1;
                     while GScabCount<=GScabMax do
                     begin
                        GSxmlCAB:=GSxmlCABroot.AddChild('cabItem');
                        GSxmlCAB.Attributes['settlement']:=GSsettleCnt;
                        GSxmlCAB.Attributes['infraIdx']:=FCentities[GScount].E_col[GScolCnt].COL_cabQueue[GSsettleCnt, GScabCount];
                        inc(GScabCount);
                     end;
                  end; //==END== if GScabMax>0 ==//
                  inc(GSsettleCnt);
               end;
               {.production matrix}
               GSprodMatrixMax:=Length(FCentities[GScount].E_col[GScolCnt].COL_productionMatrix)-1;
               if GSprodMatrixMax>0
               then
               begin
                  GSxmlProdMatrixRoot:=GSxmlCol.AddChild('colProdMatrix');
                  GSprodMatrixCnt:=1;
                  while GSprodMatrixCnt<=GSprodMatrixMax do
                  begin
                     GSxmlProdMatrix:=GSxmlProdMatrixRoot.AddChild('matrixItem');
                     GSxmlProdMatrix.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_token;
                     GSxmlProdMatrix.Attributes['unit']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_unit;
                     GSxmlProdMatrix.Attributes['storIdx']:=FCentities[GScount].E_col[GScolCnt].COL_productionMatrix[GSprodMatrixCnt].CPMI_StorageIndex;
                     inc(GSprodMatrixCnt);
                  end;
               end;
               {.storage}
               GSxmlstorageRoot:=GSxmlCol.AddChild('colStorage');
               GSxmlstorageRoot.Attributes['capSolidCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacitySolidCurr;
               GSxmlstorageRoot.Attributes['capSolidMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacitySolidMax;
               GSxmlstorageRoot.Attributes['capLiquidCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityLiquidCurr;
               GSxmlstorageRoot.Attributes['capLiquidMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityLiquidMax;
               GSxmlstorageRoot.Attributes['capGasCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityGasCurr;
               GSxmlstorageRoot.Attributes['capGasMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityGasMax;
               GSxmlstorageRoot.Attributes['capBioCur']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityBioCurr;
               GSxmlstorageRoot.Attributes['capBioMax']:=FCentities[GScount].E_col[GScolCnt].COL_storCapacityBioMax;
					GSstorageMax:=length(FCentities[GScount].E_col[GScolCnt].COL_storageList)-1;
               if GSstorageMax>0
               then
               begin
                  GSstorageCnt:=1;
                  while GSstorageCnt<=GSstorageMax do
                  begin
                     GSxmlstorage:=GSxmlstorageRoot.AddChild('storItem'+IntToStr(GSstorageCnt));
                     GSxmlstorage.Attributes['token']:=FCentities[GScount].E_col[GScolCnt].COL_storageList[GSstorageCnt].CPR_token;
                     GSxmlstorage.Attributes['unit']:=FCentities[GScount].E_col[GScolCnt].COL_storageList[GSstorageCnt].CPR_unit;
                     inc(GSstorageCnt);
                  end;
               end;
               {.reserves}
               GSxmlReserves:=GSxmlCol.AddChild('colReserves');
               GSxmlReserves.Attributes['foodCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveFoodCur;
               GSxmlReserves.Attributes['foodMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveFoodMax;
               GSxmlReserves.Attributes['oxygenCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveOxygenCur;
               GSxmlReserves.Attributes['oxygenMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveOxygenMax;
               GSxmlReserves.Attributes['waterCur']:=FCentities[GScount].E_col[GScolCnt].COL_reserveWaterCur;
               GSxmlReserves.Attributes['waterMax']:=FCentities[GScount].E_col[GScolCnt].COL_reserveWaterMax;
            end; //==END== if GSsettleMax>0 ==//
            inc(GScolCnt);
         end; //==END== while GScolCnt<=GScolMax do ==//
      end; //==END== if GScolMax>0 ==//
      GSspmMax:=Length(FCentities[GScount].E_spm)-1;
      if GSspmMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entSPMset');
         GSxmlItm.Attributes['modCoh']:=FCentities[GScount].E_spmMcohes;
         GSxmlItm.Attributes['modTens']:=FCentities[GScount].E_spmMtens;
         GSxmlItm.Attributes['modSec']:=FCentities[GScount].E_spmMsec;
         GSxmlItm.Attributes['modEdu']:=FCentities[GScount].E_spmMedu;
         GSxmlItm.Attributes['modNat']:=FCentities[GScount].E_spmMnat;
         GSxmlItm.Attributes['modHeal']:=FCentities[GScount].E_spmMhealth;
         GSxmlItm.Attributes['modBur']:=FCentities[GScount].E_spmMBur;
         GSxmlItm.Attributes['modCorr']:=FCentities[GScount].E_spmMCorr;
         GSspmCnt:=1;
         while GSspmCnt<=GSspmMax do
         begin
            GSxmlSPM:=GSxmlItm.AddChild('entSPM');
            GSxmlSPM.Attributes['token']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_token;
            GSxmlSPM.Attributes['duration']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_duration;
            GSxmlSPM.Attributes['ucCost']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_ucCost;
            GSxmlSPM.Attributes['ispolicy']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy;
            if FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['isSet']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_isSet;
               GSxmlSPM.Attributes['aprob']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_aprob;
            end
            else if not FCentities[GScount].E_spm[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['belieflvl']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_bLvl;
               GSxmlSPM.Attributes['spreadval']:=FCentities[GScount].E_spm[GSspmCnt].SPMS_aprob;
            end;
            inc(GSspmCnt);
         end;
      end;
      inc(GScount);
   end; //==END== while GScount<=FCCfacMax do ==//
   {.create "msgqueue" saved game item}
   GSlength:=length(FCVmsgStoMsg);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfMsgQueue');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlMsg:=GSxmlItm.AddChild('gfMsg');
         GSxmlMsg.Attributes['msgTitle']:=FCVmsgStoTtl[GScount];
         GSxmlMsg.Attributes['msgMain']:=FCVmsgStoMsg[GScount];
         inc(GScount);
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then}
   FCWinMain.FCGLSHUDgameTime.Text:='Game Saved';
   {.write the file and free the memory}
   FCWinMain.FCXMLsave.SaveToFile(GScurrDir+'\'+GScurrG);
   FCWinMain.FCXMLsave.Active:=false;
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set(tphTac);
end;

procedure FCMdF_Savegame_FlushOthr;
{:Purpose: save the current game and flush all other save game files than the current one.
    Additions:
}
var
   SFOtimeDay
   ,SFOtimeHr
   ,SFOtimeMin
   ,SFOtimeMth
   ,SFOtimeTick
   ,SFOtimeYr: integer;

   SFOcurrDir
   ,SFOcurrG: string;

   SFOxmlCurrGame: IXMLNode;
begin
   try
      FCMdF_Game_Save;
   finally
      {.read the document}
      FCWinMain.FCXMLcfg.FileName:=FCVpathCfg;
      FCWinMain.FCXMLcfg.Active:=true;
      SFOxmlCurrGame:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
      if SFOxmlCurrGame<>nil
      then
      begin
         SFOtimeTick:=SFOxmlCurrGame.Attributes['tfTick'];
         SFOtimeMin:=SFOxmlCurrGame.Attributes['tfMin'];
         SFOtimeHr:=SFOxmlCurrGame.Attributes['tfHr'];
         SFOtimeDay:=SFOxmlCurrGame.Attributes['tfDay'];
         SFOtimeMth:=SFOxmlCurrGame.Attributes['tfMth'];
         SFOtimeYr:=SFOxmlCurrGame.Attributes['tfYr'];
      end;
      {.free the memory}
      FCWinMain.FCXMLcfg.Active:=false;
      FCWinMain.FCXMLcfg.FileName:='';
      SFOcurrDir:=FCVcfgDir+'SavedGames\'+FCRplayer.P_gameName;
      SFOcurrG:=IntToStr(SFOtimeYr)
         +'-'+IntToStr(SFOtimeMth)
         +'-'+IntToStr(SFOtimeDay)
         +'-'+IntToStr(SFOtimeHr)
         +'-'+IntToStr(SFOtimeMin)
         +'.xml';
      if FileExists(SFOcurrDir+'\'+SFOcurrG)
      then
      begin
         CopyFile(pchar(SFOcurrDir+'\'+SFOcurrG),pchar(FCVcfgDir+SFOcurrG),false);
         FCMcF_Files_Del(SFOcurrDir+'\','*.*');
         CopyFile(pchar(FCVcfgDir+SFOcurrG),pchar(SFOcurrDir+'\'+SFOcurrG),false);
         DeleteFile(pchar(FCVcfgDir+SFOcurrG));
      end;
   end;
end;

procedure FCMdF_HelpTDef_Load;
{:Purpose: load the topics-definitions.
   Additions:
      -2010Sep05- *add: hintlists are separated by language for proper sorting.
}
var
   HTDLcnt: integer;

   HTDLitm
   ,HTDLlang
   ,HTDLroot: IXMLNode;
begin
   HTDLroot:=FCWinMain.FCXMLtxtEncy.DocumentElement.ChildNodes.FindNode('hintlist'+FCVlang);
   if HTDLroot<>nil
   then
   begin
      setlength(FCDBhelpTdef, 500);
      HTDLcnt:=0;
      HTDLitm:=HTDLroot.ChildNodes.First;
      while HTDLitm<>nil do
      begin
         inc(HTDLcnt);
         FCDBhelpTdef[HTDLcnt].TD_link:=HTDLitm.Attributes['link'];
         FCDBhelpTdef[HTDLcnt].TD_str:=HTDLitm.Attributes['title'];
         HTDLitm:=HTDLitm.NextSibling;
      end;
   end;
   setlength(FCDBhelpTdef, HTDLcnt+1);
end;

end.

