{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: data file (XML) process routines

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

unit farc_data_files;

interface

uses
   Math
   ,SysUtils
   ,Windows
   ,XMLIntf

   ,TypInfo;

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
///   load the technosciences database
///</summary>
procedure FCMdF_DBTechnosciences_Load;

///<summary>
///   load the topics-definitions
///</summary>
procedure FCMdF_HelpTDef_Load;

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_html
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_pgs
   ,farc_data_research
   ,farc_data_spu
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_cpsobjectives
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
	FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
	FCWinMain.FCXMLcfg.Active:=true;
	{.read the locale setting}
   CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('locale');
   if CFRxmlCfgItm<>nil
   then FCVdiLanguage:=CFRxmlCfgItm.Attributes['lang'];
   {.read the main window data}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('mainwin');
	if CFRxmlCfgItm<>nil
   then
	begin
		FCVdiWinMainWidth:=CFRxmlCfgItm.Attributes['mwwidth'];
		FCVdiWinMainHeight:=CFRxmlCfgItm.Attributes['mwheight'];
		FCVdiWinMainLeft:=CFRxmlCfgItm.Attributes['mwlft'];
		FCVdiWinMainTop:=CFRxmlCfgItm.Attributes['mwtop'];
	end;
   {.read the panels data}
	CFRxmlCfgItm:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('panels');
	if CFRxmlCfgItm<>nil
   then
	begin
      FCVdiLocStoreColonyPanel:=CFRxmlCfgItm.Attributes['colfacStore'];
      if FCVdiLocStoreColonyPanel
      then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=CFRxmlCfgItm.Attributes['cfacX'];
         FCWinMain.FCWM_ColDPanel.Top:=CFRxmlCfgItm.Attributes['cfacY'];
      end
      else if not FCVdiLocStoreColonyPanel
      then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=20;
         FCWinMain.FCWM_ColDPanel.Top:=80;
      end;
      FCVdiLocStoreCPSobjPanel:=CFRxmlCfgItm.Attributes['cpsStore'];
      if assigned(FCcps)
         and (FCVdiLocStoreCPSobjPanel)
      then
      begin
         FCcps.CPSpX:=CFRxmlCfgItm.Attributes['cpsX'];
         FCcps.CPSpY:=CFRxmlCfgItm.Attributes['cpsY'];
      end
      else if not assigned(FCcps)
         and (FCVdiLocStoreCPSobjPanel)
      then
      begin
         FCWinMain.FCGLSHUDcpsCredL.Tag:=CFRxmlCfgItm.Attributes['cpsX'];
         FCWinMain.FCGLSHUDcpsTlft.Tag:=CFRxmlCfgItm.Attributes['cpsY'];
      end;
		FCVdiLocStoreHelpPanel:=CFRxmlCfgItm.Attributes['helpStore'];
      if FCVdiLocStoreHelpPanel
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
      FCVdiWinMainWideScreen:=CFRxmlCfgItm.Attributes['wide'];
      FC3doglHRstandardTextures:=CFRxmlCfgItm.Attributes['hrstdt'];
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
   then FCVdiDebugMode:=CFRxmlCfgItm.Attributes['dswitch'];
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
   if FileExists(FCVdiPathConfigFile)
   then
   begin
      if FCRplayer.P_gameName<>''
      then
      begin
         {.read the document}
         FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
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
      DeleteFile(pchar(FCVdiPathConfigFile));
   end;
   {.create the document}
   FCWinMain.FCXMLcfg.Active:=true;
   {.create the root node of the configuration file}
   CFWxmlRoot:=FCWinMain.FCXMLcfg.AddChild('configfile');
   {.create the config item "locale"}
   CFWxmlCfgItm:= CFWxmlRoot.AddChild('locale');
   CFWxmlCfgItm.Attributes['lang']:= FCVdiLanguage;
   {.create the config item "mainwin"}
   CFWxmlCfgItm:= CFWxmlRoot.AddChild('mainwin');
   CFWxmlCfgItm.Attributes['mwwidth']:= FCVdiWinMainWidth;
   CFWxmlCfgItm.Attributes['mwheight']:= FCVdiWinMainHeight;
   CFWxmlCfgItm.Attributes['mwlft']:= FCVdiWinMainLeft;
   CFWxmlCfgItm.Attributes['mwtop']:= FCVdiWinMainTop;
   {.create the config item "panels"}
	CFWxmlCfgItm:=CFWxmlRoot.AddChild('panels');
   CFWxmlCfgItm.Attributes['colfacStore']:=FCVdiLocStoreColonyPanel;
   if FCVdiLocStoreColonyPanel
   then begin
      CFWxmlCfgItm.Attributes['cfacX']:=FCWinMain.FCWM_ColDPanel.Left;
      CFWxmlCfgItm.Attributes['cfacY']:=FCWinMain.FCWM_ColDPanel.Top;
   end
   else
   begin
      CFWxmlCfgItm.Attributes['cfacX']:=20;
      CFWxmlCfgItm.Attributes['cfacY']:=80;
   end;
   CFWxmlCfgItm.Attributes['cpsStore']:=FCVdiLocStoreCPSobjPanel;
   if not FCVdiLocStoreCPSobjPanel
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=0;
      CFWxmlCfgItm.Attributes['cpsY']:=0;
   end
   else if assigned(FCcps)
      and (FCVdiLocStoreCPSobjPanel)
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=FCcps.CPSobjPanel.Left;
      CFWxmlCfgItm.Attributes['cpsY']:=FCcps.CPSobjPanel.Top;
   end
   else if not assigned(FCcps)
      and (FCVdiLocStoreCPSobjPanel)
   then
   begin
      CFWxmlCfgItm.Attributes['cpsX']:=2;
      CFWxmlCfgItm.Attributes['cpsY']:=40;
   end;
   CFWxmlCfgItm.Attributes['helpStore']:=FCVdiLocStoreHelpPanel;
   if FCVdiLocStoreHelpPanel
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
   CFWxmlCfgItm.Attributes['wide']:=FCVdiWinMainWideScreen;
   CFWxmlCfgItm.Attributes['hrstdt']:=FC3doglHRstandardTextures;
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
	CFWxmlCfgItm.Attributes['dswitch']:=FCVdiDebugMode;
   {.write the file and free the memory}
   FCWinMain.FCXMLcfg.SaveToFile(FCVdiPathConfigFile);
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
      -2012May22- *rem: colonization mode - min/max status levels.
                  *add: colonization mode - economic, social and military viability thresholds.
      -2012Mar11- *mod: optimize the loading of the viability objectives.
                  *add: otEcoIndustrialForce viability objective.
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

   DBFRenumIndex
   ,DBFRitmCnt
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
	FCWinMain.FCXMLdbFac.FileName:=FCVdiPathXML+'\env\factionsdb.xml';
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
            {.colonization mode}
            if DBFRfacSubItem.NodeName='facColMode'
            then
            begin
               DBFRdockRoot:=0;
               DBFRviabObjCnt:=0;
               DBFRequItmCnt:=0;
               inc(DBFRcolMdCnt);
               SetLength(FCDBfactions[DBFRitmCnt].F_facCmode, DBFRcolMdCnt+1);
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_token:=DBFRfacSubItem.Attributes['token'];
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsVthEconomic:=DBFRfacSubItem.Attributes['viabThrEco'];
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsVthSocial:=DBFRfacSubItem.Attributes['viabThrSoc'];
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsVthSpaceMilitary:=DBFRfacSubItem.Attributes['viabThrSpMil'];
               FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsCrRg:=FCFdF_DBFactCred_FStr(DBFRfacSubItem.Attributes['creditrng']);
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
                     DBFRenumIndex:=GetEnumValue( TypeInfo( TFCEcpsoObjectiveTypes ), DBFRfacEquipItm.Attributes['objTp'] );
                     FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp:=TFCEcpsoObjectiveTypes(DBFRenumIndex);
                     if DBFRenumIndex=-1
                     then raise Exception.Create('bad faction viability objective: '+DBFRfacEquipItm.Attributes['objTp'] );
                     if FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_objTp=otEcoIndustrialForce then
                     begin
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_ifProduct:=DBFRfacEquipItm.Attributes['product'];
                        FCDBfactions[DBFRitmCnt].F_facCmode[DBFRcolMdCnt].FCM_cpsViabObj[DBFRviabObjCnt].FVO_ifThreshold:=DBFRfacEquipItm.Attributes['threshold'];
                     end;
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
      -2012Jun27- *add: hydro requirement - hrLiquid_Vapour_Ice Sheet.
                  *mod: production mode - water recovery: roofarea and traparea are now by level.
      -2012May30- *add: production mode - water recovery.
      -2012Feb14- *fix: ibVolMat - the correct data is loaded, it was loaded in I_surface.
      -2011Dec12- *fix: load correctly the production modes of the fProduction function.
      -2011Oct26- *add: required staff by infrastructure level.
                  *fix: bad data assignment for gravity requirements.
      -2011Oct23- *add: new requirement: gravity min/max.
      -2011Oct17- *add: complete and optimize resource spot requirement.
      -2011Oct16- *add: production mode occupancy data.
      -2011Sep05- *add: required staff.
      -2011Sep01- *mod: change some region soil requirement items.
      -2011Aug31- *mod: function Housing: put the population capacity by infrastructure level (because it depends on the size).
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
   ,DBIRenumIndex
   ,DBIRlevel
   ,DBIRpmodeCnt
   ,DBIRreqCMatCnt
   ,DBIRreqStaffCnt
   ,DBIRsizeCnt: integer;

   DBIRstr: string;

   DBIRnode
   ,DBIRconstMat
   ,DBIRcustFX
   ,DBIRpmode
   ,DBIRreqStaff
   ,DBIRreqsub
   ,DBIRsizeN
   ,DBIRsubN: IXMLnode;
begin
   {.clear the data structure}
   FCDBinfra:=nil;
   SetLength(FCDBinfra, 1);
   DBIRcnt:=1;
   {.read the document}
	FCWinMain.FCXMLdbInfra.FileName:=FCVdiPathXML+'\env\infrastrucdb.xml';
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
         then FCDBinfra[DBIRcnt].I_environment:=etAny
         else if DBIRstr='FE'
         then FCDBinfra[DBIRcnt].I_environment:=etFreeLiving
         else if DBIRstr='RE'
         then FCDBinfra[DBIRcnt].I_environment:=etRestricted
         else if DBIRstr='SE'
         then FCDBinfra[DBIRcnt].I_environment:=etSpace;
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
               then FCDBinfra[DBIRcnt].I_constr:=cConverted;
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
                        FCDBinfra[DBIRcnt].I_matVolume[DBIRsizeCnt]:=DBIRsizeN.Attributes['volmatlv'+IntToStr(DBIRsizeCnt)];
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
                  if DBIRreqsub.NodeName='irGravity' then
                  begin
                     FCDBinfra[DBIRcnt].I_reqGravMin:=DBIRreqsub.Attributes['min'];
                     FCDBinfra[DBIRcnt].I_reqGravMax:=DBIRreqsub.Attributes['max'];
                  end
                  else if DBIRreqsub.NodeName='irHydro'
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
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrCH4
                     else if DBIRstr='hrLiquid_Vapour_Ice Sheet'
                     then FCDBinfra[DBIRcnt].I_reqHydro:=hrLiquid_Vapour_Ice_Sheet;
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
                     else if DBIRstr='rsrAnyNonVolcanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyNonVolcanic
                     else if DBIRstr='rsrAnyCoastal'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyCoastal
                     else if DBIRstr='rsrAnyCoastalNonVolcanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyCoastalNonVolcanic
                     else if DBIRstr='rsrAnySterile'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnySterile
                     else if DBIRstr='rsrAnyFertile'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsrAnyFertile
                     else if DBIRstr='rsOceanic'
                     then FCDBinfra[DBIRcnt].I_reqRegionSoil:=rsOceanic;
                  end
                  else if DBIRreqsub.NodeName='irRsrcSpot'
                  then
                  begin
                     DBIRenumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotTypes ), DBIRreqsub.Attributes['spottype'] );
                     FCDBinfra[DBIRcnt].I_reqRsrcSpot:=TFCEduResourceSpotTypes(DBIRenumIndex);
                     if DBIRenumIndex=-1
                     then raise Exception.Create('bad resource spot req: '+DBIRreqsub.Attributes['spottype'] );
                  end
                  else if DBIRreqsub.NodeName='irTechSci'
                  then
                  begin
                     DBIRstr:=DBIRreqsub.Attributes['sector'];
                     if DBIRstr='rsNone'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsNone
                     else if DBIRstr='rsAerospaceEng'
                     then FCDBinfra[DBIRcnt].I_reqTechSci.RTS_sector:=rsAerospaceEngineering
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
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceEnergyGeneration;
                     DBIRstr:=DBIRsubN.Attributes['genMode'];
                     if DBIRstr='egmAntimatter'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmAntimatter
                     else if DBIRstr='egmFission'
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmFission;
                        DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                        while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                        begin
                           FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_mFfixedValues[DBIRsizeCnt].FV_baseGeneration:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)];
                           FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_mFfixedValues[DBIRsizeCnt].FV_generationByDevelopmentLevel:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)+'byDL'];
                           inc(DBIRsizeCnt);
                        end;
                     end
                     else if DBIRstr='egmFusionDT'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmFusionDT
                     else if DBIRstr='egmFusionH2'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmFusionH2
                     else if DBIRstr='egmFusionHe3'
                     then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmFusionHe3
                     else if DBIRstr='egmPhoton'
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.EGM_modes:=egmPhoton;
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_photonArea:=DBIRsubN.Attributes['area'];
                        FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enGenMode.FEPM_photonEfficiency:=DBIRsubN.Attributes['efficiency'];
                     end;
                  end
                  else if DBIRcustFX.NodeName='cfxEnergyStor'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceEnergyStorage;
                     DBIRlevel:=DBIRcustFX.Attributes['storlevel'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_enStorLvl[DBIRlevel]:=DBIRcustFX.Attributes['storCapacity'];
                  end
                  else if DBIRcustFX.NodeName='icfxHQbasic'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceHeadQuarterPrimary
                  else if DBIRcustFX.NodeName='icfxHQSecondary'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceHeadQuarterBasic
                  else if DBIRcustFX.NodeName='icfxHQPrimary'
                  then FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceHeadQuarterSecondary
                  else if DBIRcustFX.NodeName='cfxProductStorage'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_customEffect:=ceProductStorage;
                     DBIRlevel:=DBIRcustFX.Attributes['storlevel'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_solid:=DBIRcustFX.Attributes['storSolid'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_liquid:=DBIRcustFX.Attributes['storLiquid'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_gas:=DBIRcustFX.Attributes['storGas'];
                     FCDBinfra[DBIRcnt].I_customFx[DBIRcustFXcnt].ICFX_prodStorageLvl[DBIRlevel].IPS_biologic:=DBIRcustFX.Attributes['storBio'];
                  end;
                  DBIRcustFX:=DBIRcustFX.NextSibling;
               end; //==END== while DBIRcustFX<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infCustFX' ==//
            else if DBIRsubN.NodeName='infReqStaff'
            then
            begin
               SetLength(FCDBinfra[DBIRcnt].I_reqStaff, 1);
               DBIRreqStaffCnt:=0;
               DBIRreqStaff:=DBIRsubN.ChildNodes.First;
               while DBIRreqStaff<>nil do
               begin
                  inc(DBIRreqStaffCnt);
                  SetLength(FCDBinfra[DBIRcnt].I_reqStaff, DBIRreqStaffCnt+1);
                  DBIRstr:=DBIRreqStaff.Attributes['type'];
                  if DBIRstr='ptColonist'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptColonist
                  else if DBIRstr='ptOfficer'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptOfficer
                  else if DBIRstr='ptMissSpe'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptMissionSpecialist
                  else if DBIRstr='ptBiolog'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptBiologist
                  else if DBIRstr='ptDoctor'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptDoctor
                  else if DBIRstr='ptTechnic'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptTechnician
                  else if DBIRstr='ptEngineer'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptEngineer
                  else if DBIRstr='ptSoldier'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptSoldier
                  else if DBIRstr='ptCommando'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptCommando
                  else if DBIRstr='ptPhysic'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptPhysicist
                  else if DBIRstr='ptAstroph'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptAstrophysicist
                  else if DBIRstr='ptEcolog'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptEcologist
                  else if DBIRstr='ptEcoform'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptEcoformer
                  else if DBIRstr='ptMedian'
                  then FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_type:=ptMedian;
                  DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                  while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                  begin
                     FCDBinfra[DBIRcnt].I_reqStaff[DBIRreqStaffCnt].RS_requiredByLv[DBIRsizeCnt]:=DBIRreqStaff.Attributes['requiredNumLv'+IntToStr(DBIRsizeCnt)];
                     inc(DBIRsizeCnt);
                  end;
                  DBIRreqStaff:=DBIRreqStaff.NextSibling;
               end; //==END== while DBIRreqStaff<>nil do ==//
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
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmAntimatter
						else if DBIRstr='egmFission'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmFission;
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_mFfixedValues[DBIRsizeCnt].FV_baseGeneration:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)];
                        FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_mFfixedValues[DBIRsizeCnt].FV_generationByDevelopmentLevel:=DBIRsubN.Attributes['fixedprodlv'+IntToStr(DBIRsizeCnt)+'byDL'];
                        inc(DBIRsizeCnt);
                     end;
                  end
						else if DBIRstr='egmFusionDT'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmFusionDT
						else if DBIRstr='egmFusionH2'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmFusionH2
						else if DBIRstr='egmFusionHe3'
                  then FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmFusionHe3
                  else if DBIRstr='egmPhoton'
                  then
                  begin
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.EGM_modes:=egmPhoton;
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_photonArea:=DBIRsubN.Attributes['area'];
                     FCDBinfra[DBIRcnt].I_fEnergyPmode.FEPM_photonEfficiency:=DBIRsubN.Attributes['efficiency'];
                  end;
               end
               else if DBIRstr='fHousing'
               then
               begin
                  FCDBinfra[DBIRcnt].I_function:=fHousing;
                  if FCDBinfra[DBIRcnt].I_constr<cConverted then
                  begin
                     DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                     while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                     begin
                        FCDBinfra[DBIRcnt].I_fHousPopulationCap[DBIRsizeCnt]:=DBIRsubN.Attributes['pcaplv'+IntToStr(DBIRsizeCnt)];
                        inc(DBIRsizeCnt);
                     end;
                  end;
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
                  DBIRpmodeCnt:=0;
                  DBIRpmode:=DBIRsubN.ChildNodes.First;
                  while DBIRpmode<>nil do
                  begin
                     inc( DBIRpmodeCnt );
                     DBIRenumIndex:=GetEnumValue( TypeInfo( TFCEdipProductionModes ), DBIRpmode.Attributes['pmode'] );
                     FCDBinfra[DBIRcnt].I_fProductionMode[ DBIRpmodeCnt ].IPM_productionModes:=TFCEdipProductionModes(DBIRenumIndex);
                     if DBIRenumIndex=-1
                     then raise Exception.Create('bad production mode: '+DBIRpmode.Attributes['pmode'] );
                     FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_occupancy:=DBIRpmode.Attributes['occupancy'];
                     if FCDBinfra[DBIRcnt].I_fProductionMode[ DBIRpmodeCnt ].IPM_productionModes=pmWaterRecovery
                     then
                     begin
                        FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].IPM_productionModes:=pmWaterRecovery;
                        DBIRsizeCnt:=FCDBinfra[DBIRcnt].I_minLevel;
                        while DBIRsizeCnt<=FCDBinfra[DBIRcnt].I_maxLevel do
                        begin
                           FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].WR_roofarea:=DBIRpmode.Attributes['roofArealv'+IntToStr(DBIRsizeCnt)];
                           FCDBinfra[DBIRcnt].I_fProductionMode[DBIRpmodeCnt].WR_traparea:=DBIRpmode.Attributes['trapArealv'+IntToStr(DBIRsizeCnt)];
                           inc(DBIRsizeCnt);
                        end;
                     end;
                     DBIRpmode:=DBIRpmode.NextSibling;
                  end; //==END== while DBIRpmode<>nil do ==//
                  if DBIRpmodeCnt+1<=FCCdipProductionModesMax
                  then FCDBinfra[DBIRcnt].I_fProductionMode[ DBIRpmodeCnt+1 ].IPM_productionModes:=pmNone;
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
      -2011Oct25  *add: new function: Building Support Equipment.
                  *mod: class + storage + function + corrosive class + research sector loading.
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
	DBPRcnt
   ,DBPRenumIndex: integer;

	DBPRnode
	,DBPRsub
	,DBPRtag: IXMLNode;
begin
   FCDBProducts:=nil;
   SetLength(FCDBProducts, 1);
   DBPRcnt:=0;
   {.read the document}
   FCWinMain.FCXMLdbProducts.FileName:=FCVdiPathXML+'\env\productsdb.xml';
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
         DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipProductClasses ), DBPRnode.Attributes['class'] );
         FCDBProducts[DBPRcnt].PROD_class:=TFCEdipProductClasses( DBPRenumIndex );
         if DBPRenumIndex=-1
         then raise Exception.Create( 'bad product class: '+DBPRnode.Attributes['class'] );
         DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipStorageTypes ), DBPRnode.Attributes['storage'] );
         FCDBProducts[DBPRcnt].PROD_storage:=TFCEdipStorageTypes( DBPRenumIndex );
         if DBPRenumIndex=-1
         then raise Exception.Create( 'bad storage: '+DBPRnode.Attributes['storage'] );
         {:DEV NOTE: complete cargo type loading here}
//         DBPRdumpStr:=DBPRnode.Attributes['cargo'];
         FCDBProducts[DBPRcnt].PROD_volByUnit:=DBPRnode.Attributes['volbyunit'];
         FCDBProducts[DBPRcnt].PROD_massByUnit:=DBPRnode.Attributes['massbyunit'];
         DBPRsub:=DBPRnode.ChildNodes.First;
         while DBPRsub<>nil do
         begin
            if DBPRsub.NodeName='function' then
            begin
               DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipProductFunctions ), DBPRsub.Attributes['token'] );
               FCDBProducts[DBPRcnt].PROD_function:=TFCEdipProductFunctions( DBPRenumIndex );
               if DBPRenumIndex=-1
               then raise Exception.Create( 'bad product function: '+DBPRsub.Attributes['token'] );
               case FCDBProducts[DBPRcnt].PROD_function of
                  pfBuildingMaterial:
                  begin
                     FCDBProducts[DBPRcnt].PROD_fBmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                     FCDBProducts[DBPRcnt].PROD_fBmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fBmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                     FCDBProducts[DBPRcnt].PROD_fBmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fBmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                     FCDBProducts[DBPRcnt].PROD_fBmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                     DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), DBPRsub.Attributes['corrosiveclass'] );
                     FCDBProducts[DBPRcnt].PROD_fBmatCorrosiveClass:=TFCEdipCorrosiveClasses( DBPRenumIndex );
                     if DBPRenumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+DBPRsub.Attributes['corrosiveclass'] );
                  end;

                  pfFood: FCDBProducts[DBPRcnt].PROD_fFoodPoint:=DBPRsub.Attributes['foodpoint'];

                  pfInfrastructureKit:
                  begin
                     FCDBProducts[DBPRcnt].PROD_fInfKitToken:=DBPRsub.Attributes['infratoken'];
                     FCDBProducts[DBPRcnt].PROD_fInfKitLevel:=DBPRsub.Attributes['infralevel'];
                  end;

                  pfManualConstruction: FCDBProducts[DBPRcnt].PROD_fManConstWCPcoef:=DBPRsub.Attributes['wcpcoef'];

                  pfMechanicalConstruction:
                  begin
                     FCDBProducts[DBPRcnt].PROD_fMechConstWCP:=DBPRsub.Attributes['wcp'];
                     FCDBProducts[DBPRcnt].PROD_fMechConstCrew:=DBPRsub.Attributes['crew'];
                  end;

                  pfMultipurposeMaterial:
                  begin
                     FCDBProducts[DBPRcnt].PROD_fMmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                     FCDBProducts[DBPRcnt].PROD_fMmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fMmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                     FCDBProducts[DBPRcnt].PROD_fMmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fMmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                     FCDBProducts[DBPRcnt].PROD_fMmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                     DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), DBPRsub.Attributes['corrosiveclass'] );
                     FCDBProducts[DBPRcnt].PROD_fMmatCorrosiveClass:=TFCEdipCorrosiveClasses( DBPRenumIndex );
                     if DBPRenumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+DBPRsub.Attributes['corrosiveclass'] );
                  end;

                  pfOxygen: FCDBProducts[DBPRcnt].PROD_fOxyPoint:=DBPRsub.Attributes['oxypoint'];

                  pfSpaceMaterial:
                  begin
                     FCDBProducts[DBPRcnt].PROD_function:=pfSpaceMaterial;
                     FCDBProducts[DBPRcnt].PROD_fSmatTensileStr:=DBPRsub.Attributes['tensilestr'];
                     FCDBProducts[DBPRcnt].PROD_fSmatTSbyLevel:=DBPRsub.Attributes['tsbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fSmatYoungModulus:=DBPRsub.Attributes['youngmodulus'];
                     FCDBProducts[DBPRcnt].PROD_fSmatYMbyLevel:=DBPRsub.Attributes['ymbylevel'];
                     FCDBProducts[DBPRcnt].PROD_fSmatThermalProt:=DBPRsub.Attributes['thermalprot'];
                     FCDBProducts[DBPRcnt].PROD_fSmatReflectivity:=DBPRsub.Attributes['reflectivity'];
                     DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), DBPRsub.Attributes['corrosiveclass'] );
                     FCDBProducts[DBPRcnt].PROD_fSmatCorrosiveClass:=TFCEdipCorrosiveClasses( DBPRenumIndex );
                     if DBPRenumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+DBPRsub.Attributes['corrosiveclass'] );
                  end;

                  pfWater: FCDBProducts[DBPRcnt].PROD_fWaterPoint:=DBPRsub.Attributes['waterpoint'];
               end; //==END== case FCDBProducts[DBPRcnt].PROD_function of ==//
            end //==END== if DBPRsub.NodeName='function' ==//
            else if DBPRsub.NodeName='techsci' then
            begin
               DBPRenumIndex:=GetEnumValue( TypeInfo( TFCEdrResearchSectors ), DBPRsub.Attributes['sector'] );
               FCDBProducts[DBPRcnt].PROD_tsSector:=TFCEdrResearchSectors( DBPRenumIndex );
               if DBPRenumIndex=-1
               then raise Exception.Create( 'bad research sector: '+DBPRsub.Attributes['sector'] );
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
   FCDdsuInternalStructures:=nil;
   FCDdsuSpaceUnitDesigns:=nil;
   SetLength(FCDdsuInternalStructures, 1);
   SetLength(FCDdsuSpaceUnitDesigns, 1);
   DBSCRcount:=1;
   {.INTERNAL STRUCTURES}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVdiPathXML+'\env\scintstrucdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   DBSCRnode:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while DBSCRnode<>nil do
   begin
      if DBSCRcount >= Length(FCDdsuInternalStructures)
      then SetLength(FCDdsuInternalStructures, Length(FCDdsuInternalStructures)+DBSCRblocCnt);
      if DBSCRnode.NodeName<>'#comment' then
      begin
         {.internal structure token}
         FCDdsuInternalStructures[DBSCRcount].IS_token:=DBSCRnode.Attributes['token'];
         {.internal structure shape}
         DBSCRdmpStr:=DBSCRnode.Attributes['shape'];
         if DBSCRdmpStr='stAssem' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issAssembled
         else if DBSCRdmpStr='stModul' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issModular
         else if DBSCRdmpStr='stSpher' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issSpherical
         else if DBSCRdmpStr='stCylin' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issCylindrical
         else if DBSCRdmpStr='stCylSt' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issStreamlinedCylindrical
         else if DBSCRdmpStr='stDelta' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issStreamlinedDelta
         else if DBSCRdmpStr='stBox' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issBox
         else if DBSCRdmpStr='stTorus' then FCDdsuInternalStructures[DBSCRcount].IS_shape:=issToroidal;
         {.internal structure architecture type}
         DBSCRdmpStr:=DBSCRnode.Attributes['archtp'];
         if DBSCRdmpStr='scarchtpDSV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aDSV
         else if DBSCRdmpStr='scarchtpHLV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aHLV
         else if DBSCRdmpStr='scarchtpLV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aLV
         else if DBSCRdmpStr='scarchtpLAV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aLAV
         else if DBSCRdmpStr='scarchtpOMV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aOMV
         else if DBSCRdmpStr='scarchtpSSI'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aSSI
         else if DBSCRdmpStr='scarchtpTAV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aTAV
         else if DBSCRdmpStr='scarchtpBSV'
         then FCDdsuInternalStructures[DBSCRcount].IS_architecture:=aBSV;
         {.internal structure allowed control module}
         if DBSCRdmpStr='cmtCockpit'
         then FCDdsuInternalStructures[DBSCRcount].IS_controlModuleAllowed:=cmCockpit
         else if DBSCRdmpStr='cmtBridge'
         then FCDdsuInternalStructures[DBSCRcount].IS_controlModuleAllowed:=cmBridge
         else if DBSCRdmpStr='cmtUnna'
         then FCDdsuInternalStructures[DBSCRcount].IS_controlModuleAllowed:=cmUnmanned;
         {.internal structure length}
         FCDdsuInternalStructures[DBSCRcount].IS_length:=DBSCRnode.Attributes['length'];
         {.internal structure wingspans}
         FCDdsuInternalStructures[DBSCRcount].IS_wingspan:=DBSCRnode.Attributes['wgspan'];
         {.internal structure height}
         FCDdsuInternalStructures[DBSCRcount].IS_height:=DBSCRnode.Attributes['height'];
         {.internal structure available volume}
         FCDdsuInternalStructures[DBSCRcount].IS_availableVolume:=DBSCRnode.Attributes['availvol'];
         {.internal structure available surface}
         FCDdsuInternalStructures[DBSCRcount].IS_availableSurface:=DBSCRnode.Attributes['availsur'];
         {.internal structure available spacedrive usable volume}
         FCDdsuInternalStructures[DBSCRcount].IS_spaceDriveMaxVolume:=DBSCRnode.Attributes['spdrvmaxvol'];
         {.internal structure available spacedrive usable surface}
         FCDdsuInternalStructures[DBSCRcount].IS_spaceDriveMaxSurface:=DBSCRnode.Attributes['spdrvmaxsur'];
         inc(DBSCRcount);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      DBSCRnode:= DBSCRnode.NextSibling;
   end; {.while DBSCRnode<>nil}
   {.resize to real table size}
   SetLength(FCDdsuInternalStructures, DBSCRcount);
   FCWinMain.FCXMLdbSCraft.Active:=false;
   DBSCRcount:=1;
   {.DESIGNS}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVdiPathXML+'\env\scdesignsdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   DBSCRnode:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while DBSCRnode<>nil do
   begin
      if DBSCRcount >= Length(FCDdsuSpaceUnitDesigns)
      then SetLength(FCDdsuSpaceUnitDesigns, Length(FCDdsuSpaceUnitDesigns)+DBSCRblocCnt);
      if DBSCRnode.NodeName<>'#comment' then
      begin
         {.design token}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_token:=DBSCRnode.Attributes['token'];
         {.internal structure token linked to the current design (datastructure is cloned)}
         DBSCRdmpStr:=DBSCRnode.Attributes['intstrtoken'];
         {.retrieve internal structure db}
         DBSCRiStrcnt:=1;
         DBSCRiStrIdx:=0;
         while DBSCRiStrcnt<=Length(FCDdsuInternalStructures)-1 do
         begin
            if FCDdsuInternalStructures[DBSCRiStrcnt].IS_token=DBSCRdmpStr
            then
            begin
               DBSCRiStrIdx:=DBSCRiStrcnt;
               Break;
            end;
            inc(DBSCRiStrcnt);
         end;
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_internalStructureClone:=FCDdsuInternalStructures[DBSCRiStrIdx];
         {.design used volume}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_usedVolume:=DBSCRnode.Attributes['usedvol'];
         {.design used surface}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_usedSurface:=DBSCRnode.Attributes['usedsurf'];
         {.design empty mass}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_massEmpty:=DBSCRnode.Attributes['massempty'];
         {.design spacedrive isp}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_spaceDriveISP:=DBSCRnode.Attributes['spdrvISP'];
         {.design maximum reaction mass volume}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_spaceDriveReactionMassMaxVolume:=DBSCRnode.Attributes['spdrvRMmax'];
         {.design capabilities}
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_capabilityInterstellarTransit:=DBSCRnode.Attributes['capInter'];
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_capabilityColonization:=DBSCRnode.Attributes['capColon'];
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_capabilityPassengers:=DBSCRnode.Attributes['capPassgr'];
         FCDdsuSpaceUnitDesigns[DBSCRcount].SUD_capabilityCombat:=DBSCRnode.Attributes['capCombt'];
         inc(DBSCRcount);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      DBSCRnode := DBSCRnode.NextSibling;
   end; {.while DBSCRnode<>nil}
   {.resize to real table size}
   SetLength(FCDdsuSpaceUnitDesigns, DBSCRcount);
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
	FCWinMain.FCXMLdbSPMi.FileName:=FCVdiPathXML+'\env\spmdb.xml';
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
{:DEV NOTES: init: TFCRduSpaceUnitInOrbit for security, put that in a separate method (will be used for new game / load game=> put a dev note in these respective methods.}
{:Purpose: read the universe database xml file.
   Additions:
      -2012Jun02- *add: primary gas volume.
      -2011Oct09- *mod: optimize how the star class is loaded, many lines of code removed.
                  *mod: optimize how the companion star's orbit type is loaded, some lines of code removed.
                  *mod: optimize how the orbital object type is loaded, many lines of code removed.
                  *mod: optimize how the orbital zone is loaded, many lines of code removed.
                  *mod: optimize how the environment is loaded, many lines of code removed.
                  *mod: a useless with structure is removed.
                  *add: region's resources data.
                  *add: settlement + environment modifier data for satelites, they was missed.
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
      -2009Aug29- *add FCDBsSys[DBSSPstarSysCnt].SS_star[DBSSPstarCnt].SDB_obobj[DBSSPorbObjCnt].OO_angle1stDay calculation.
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
   ,DBSSPregNode
   ,DBSSPresourceNode: IXMLNode;

   DBSSPenumIndex
   ,DBSSPstarSysCnt
   ,DBSSPstarCnt
   ,DBSSPorbObjCnt
   ,DBSSPsatCnt
   ,DBSSPperOrbCnt
   ,DBSSPregCnt
   ,DBSSPresourceCnt: Integer;

   DBSSPperOrbDmp
   ,DBSSPhydroTp
   ,DBSSPregDmp: string;
begin
   if DBSSPaction=dfsspStarSys then
   begin
      {.clear the data structure}
      SetLength(FCDduStarSystem,1);
      DBSSPstarSysCnt:=1;
      {.read the document}
      FCWinMain.FCXMLdbUniv.FileName:=FCVdiPathXML+'\univ\universe.xml';
      FCWinMain.FCXMLdbUniv.Active:=true;
      DBSSPstarSysNode:= FCWinMain.FCXMLdbUniv.DocumentElement.ChildNodes.First;
      while DBSSPstarSysNode<>nil do
      begin
         if DBSSPstarSysCnt >= Length(FCDduStarSystem)
         then SetLength(FCDduStarSystem, Length(FCDduStarSystem)+DBSSblocCnt);
         if DBSSPstarSysNode.NodeName<>'#comment'
         then
         begin
            {.star system token + nb of stars it contains}
            FCDduStarSystem[DBSSPstarSysCnt].SS_token:=DBSSPstarSysNode.Attributes['sstoken'];
            {.star system location}
            FCDduStarSystem[DBSSPstarSysCnt].SS_locationX:= DBSSPstarSysNode.Attributes['steslocx'];
            FCDduStarSystem[DBSSPstarSysCnt].SS_locationY:= DBSSPstarSysNode.Attributes['steslocy'];
            FCDduStarSystem[DBSSPstarSysCnt].SS_locationZ:= DBSSPstarSysNode.Attributes['steslocz'];
            {.stars data processing loop}
            DBSSPstarCnt:=1;
            DBSSPstarNode:= DBSSPstarSysNode.ChildNodes.First;
            while DBSSPstarNode<>nil do
            begin
               DBSSPorbObjCnt:=0;
               {.star token id and class}
               FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_token:=DBSSPstarNode.Attributes['startoken'] ;
               DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduStarClasses),DBSSPstarNode.Attributes['starclass']);
               FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_class:=TFCEduStarClasses(DBSSPenumIndex) ;
               FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompanion:=false;
               if DBSSPenumIndex=-1
               then raise Exception.Create('bad star class: '+DBSSPstarNode.Attributes['starclass']);
               {.star subdata processing loop}
               DBSSPstarSubNode:= DBSSPstarNode.ChildNodes.First;
               while DBSSPstarSubNode<>nil do
               begin
                  {.star's physical data}
                  if DBSSPstarSubNode.NodeName='starphysdata'
                  then
                  begin
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_temperature:=DBSSPstarSubNode.Attributes['startemp'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_mass:=DBSSPstarSubNode.Attributes['starmass'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_diameter:=DBSSPstarSubNode.Attributes['stardiam'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_luminosity:=DBSSPstarSubNode.Attributes['starlum'];
                  end
                  {.companion star's data}
                  else if DBSSPstarSubNode.NodeName='starcompdata' then
                  begin
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompanion:=true;
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompMeanSeparation:=DBSSPstarSubNode.Attributes['compmsep'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompMinApproachDistance:=DBSSPstarSubNode.Attributes['compminapd'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompEccentricity:=DBSSPstarSubNode.Attributes['compecc'];
                     if DBSSPstarCnt=3 then
                     begin
                        DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduCompanion2OrbitTypes), DBSSPstarSubNode.Attributes['comporb'] );
                        FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_isCompStar2OrbitType:=TFCEduCompanion2OrbitTypes(DBSSPenumIndex);
                        if DBSSPenumIndex=-1
                        then raise Exception.Create('bad companion star orbit type: '+DBSSPstarSubNode.Attributes['comporb']);
                     end;
                  end
                  else if DBSSPstarSubNode.NodeName='orbobj' then
                  begin
                     inc(DBSSPorbObjCnt);
                     if DBSSPorbObjCnt>= Length(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects)
                     then SetLength(
                        FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects
                        ,Length(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects)+DBSSblocCnt
                        );
                     {.initialize satellite data}
                     SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList, 1);
                     DBSSPsatCnt:=0;
                     {orbital object's id db token}
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_dbTokenId:=DBSSPstarSubNode.Attributes['ootoken'];
                     FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_isSatellite:=false;
                     DBSSPorbObjNode:= DBSSPstarSubNode.ChildNodes.First;
                     while DBSSPorbObjNode<>nil do
                     begin
                        if DBSSPorbObjNode.NodeName='orbobjorbdata'
                        then
                        begin
                           {.distance from star}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_isSatFdistanceFromStar:=DBSSPorbObjNode.Attributes['oodist'];
                           {.eccentricity}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_isSatFeccentricity:=DBSSPorbObjNode.Attributes['ooecc'];
                           {.orbital zone type}
                           DBSSPenumIndex:=GetEnumValue( TypeInfo( TFCEduHabitableZones ), DBSSPorbObjNode.Attributes['ooorbzne'] );
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_isSatForbitalZone:=TFCEduHabitableZones(DBSSPenumIndex);
                           if DBSSPenumIndex=-1
                           then raise Exception.Create( 'bad orbital zone: '+DBSSPorbObjNode.Attributes['ooorbzne'] );
                           {.revolution period}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriod:=DBSSPorbObjNode.Attributes['oorevol'];
                           {.revolution period init day}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriodInit:=DBSSPorbObjNode.Attributes['oorevevinit'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_angle1stDay:=roundto(
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriodInit*360/FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriod, -2
                              );
                           {.gravity sphere of influence radius}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_gravitationalSphereRadius:=DBSSPorbObjNode.Attributes['oogravsphrad'];
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
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optClosest
                              else if DBSSPperOrbDmp='optInterm'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optIntermediary
                              else if DBSSPperOrbDmp='optFarest'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optFarest;
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_dayStart:=DBSSPperOrbNode.Attributes['opstrt'];
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_dayEnd:=DBSSPperOrbNode.Attributes['opend'];
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_meanTemperature:=DBSSPperOrbNode.Attributes['opmtemp'];
                              DBSSPperOrbNode:= DBSSPperOrbNode.NextSibling;
                           end;
                        end //==END== else if DBSSPorbObjNode.NodeName='orbperlist' ==//
                        else if DBSSPorbObjNode.NodeName='orbobjgeophysdata'
                        then
                        begin
                           {.orbital object type}
                           DBSSPenumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalObjectTypes ), DBSSPorbObjNode.Attributes['ootype'] );
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_type:=TFCEduOrbitalObjectTypes( DBSSPenumIndex );
                           if DBSSPenumIndex=-1
                           then raise Exception.Create( 'bad orbital object type: '+DBSSPorbObjNode.Attributes['ootype'] );
                           {.diameter}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_diameter:=DBSSPorbObjNode.Attributes['oodiam'];
                           {.density}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_dens:=DBSSPorbObjNode.Attributes['oodens'];
                           {.mass}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_mass:=DBSSPorbObjNode.Attributes['oomass'];
                           {.gravity}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_gravity:=DBSSPorbObjNode.Attributes['oograv'];
                           {.escape velocity}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_escapeVelocity:=DBSSPorbObjNode.Attributes['ooescvel'];
                           {.rotation period}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_rotationPeriod:=DBSSPorbObjNode.Attributes['oorotper'];
                           {.inclination axis}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_inclinationAxis:=DBSSPorbObjNode.Attributes['ooinclax'];
                           {.magnetic field}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_magneticField:=DBSSPorbObjNode.Attributes['oomagfld'];
                           {.albedo}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_albedo:=DBSSPorbObjNode.Attributes['ooalbe'];
                        end {.else if DBSSPorbObjNode.NodeName='orbobjgeophysdata'}
                        else if DBSSPorbObjNode.NodeName='orbobjecosdata'
                        then
                        begin
                           {.environment}
                           DBSSPenumIndex:=GetEnumValue( TypeInfo( TFCEduEnvironmentTypes ), DBSSPorbObjNode.Attributes['ooenvtype'] );
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_environment:=TFCEduEnvironmentTypes(DBSSPenumIndex);
                           if DBSSPenumIndex=-1
                           then raise Exception.Create( 'bad environment type: '+DBSSPorbObjNode.Attributes['ooenvtype'] );
                           {.atmosphere pressure}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphericPressure:=DBSSPorbObjNode.Attributes['ooatmpres'];
                           {.clouds cover}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_cloudsCover:=DBSSPorbObjNode.Attributes['oocloudscov'];
                           {.primary gas volume}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_primaryGasVolumePerc:=DBSSPorbObjNode.Attributes['atmprimgasvol'];
                           {.atmospheric composition}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceH2:=DBSSPorbObjNode.Attributes['atmH2'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceHe:=DBSSPorbObjNode.Attributes['atmHe'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceCH4:=DBSSPorbObjNode.Attributes['atmCH4'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceNH3:=DBSSPorbObjNode.Attributes['atmNH3'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceH2O:=DBSSPorbObjNode.Attributes['atmH2O'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceNe:=DBSSPorbObjNode.Attributes['atmNe'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceN2:=DBSSPorbObjNode.Attributes['atmN2'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceCO:=DBSSPorbObjNode.Attributes['atmCO'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceNO:=DBSSPorbObjNode.Attributes['atmNO'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceO2:=DBSSPorbObjNode.Attributes['atmO2'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceH2S:=DBSSPorbObjNode.Attributes['atmH2S'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceAr:=DBSSPorbObjNode.Attributes['atmAr'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceCO2:=DBSSPorbObjNode.Attributes['atmCO2'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceNO2:=DBSSPorbObjNode.Attributes['atmNO2'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceO3:=DBSSPorbObjNode.Attributes['atmO3'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_atmosphere.AC_gasPresenceSO2:=DBSSPorbObjNode.Attributes['atmSO2'];
                           {.hydrosphere}
                           DBSSPhydroTp:=DBSSPorbObjNode.Attributes['hydroTp'];
                           if DBSSPhydroTp='htNone'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hNoH2O
                           else if DBSSPhydroTp='htVapor'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hVaporH2O
                           else if DBSSPhydroTp='htLiquid'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hLiquidH2O
                           else if DBSSPhydroTp='htIceSheet'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hIceSheet
                           else if DBSSPhydroTp='htCrystal'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hCrystalIce
                           else if DBSSPhydroTp='htLiqNH3'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hLiquidH2O_blend_NH3
                           else if DBSSPhydroTp='htLiqCH4'
                           then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphere:=hLiquidCH4;
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_hydrosphereArea:=DBSSPorbObjNode.Attributes['hydroArea'];
                        end {.else if DBSSPorbObjNode.NodeName='orbobjecosdata'}
                        else if DBSSPorbObjNode.NodeName='orbobjregions'
                        then
                        begin
                           SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions, 31);
                           DBSSPregCnt:=1;
                           DBSSPregNode:=DBSSPorbObjNode.ChildNodes.First;
                           while DBSSPregNode<>nil do
                           begin
                              {.region - soil type}
                              DBSSPregDmp:=DBSSPregNode.Attributes['soiltp'];
                              if DBSSPregDmp='rst01rockDes'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst01RockyDesert
                              else if DBSSPregDmp='rst02sandDes'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst02SandyDesert
                              else if DBSSPregDmp='rst03volcanic'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst03Volcanic
                              else if DBSSPregDmp='rst04polar'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst04Polar
                              else if DBSSPregDmp='rst05arid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst05Arid
                              else if DBSSPregDmp='rst06fertile'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst06Fertile
                              else if DBSSPregDmp='rst07oceanic'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst07Oceanic
                              else if DBSSPregDmp='rst08coastRockDes'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst08CoastalRockyDesert
                              else if DBSSPregDmp='rst09coastSandDes'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst09CoastalSandyDesert
                              else if DBSSPregDmp='rst10coastVolcanic'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst10CoastalVolcanic
                              else if DBSSPregDmp='rst11coastPolar'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst11CoastalPolar
                              else if DBSSPregDmp='rst12coastArid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst12CoastalArid
                              else if DBSSPregDmp='rst13coastFertile'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst13CoastalFertile
                              else if DBSSPregDmp='rst14barren'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst14Sterile
                              else if DBSSPregDmp='rst15icyBarren'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst15icySterile;
                              {.region - relief}
                              DBSSPregDmp:=DBSSPregNode.Attributes['relief'];
                              if DBSSPregDmp='rr1plain'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr1Plain
                              else if DBSSPregDmp='rr4broken'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr4Broken
                              else if DBSSPregDmp='rr9mountain'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr9Mountain;
                              {.region - climate}
                              DBSSPregDmp:=DBSSPregNode.Attributes['climate'];
                              if DBSSPregDmp='rc00void'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc00VoidNoUse
                              else if DBSSPregDmp='rc01vhotHumid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc01VeryHotHumid
                              else if DBSSPregDmp='rc02vhotSemiHumid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc02VeryHotSemiHumid
                              else if DBSSPregDmp='rc03hotSemiArid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc03HotSemiArid
                              else if DBSSPregDmp='rc04hotArid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc04HotArid
                              else if DBSSPregDmp='rc05modHumid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc05ModerateHumid
                              else if DBSSPregDmp='rc06modDry'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc06ModerateDry
                              else if DBSSPregDmp='rc07coldArid'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc07ColdArid
                              else if DBSSPregDmp='rc08periarctic'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc08Periarctic
                              else if DBSSPregDmp='rc09arctic'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc09Arctic
                              else if DBSSPregDmp='rc10extreme'
                              then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc10Extreme;
                              {.region - mean temperature at min distance}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_meanTdMin:=DBSSPregNode.Attributes['mtdmin'];
                              {.region - mean temperature at intermediate distance}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_meanTdInt:=DBSSPregNode.Attributes['mtdint'];
                              {.region - mean temperature at max distance}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_meanTdMax:=DBSSPregNode.Attributes['mtdmax'];
                              {.region - mean windspeed}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_windSpeed:=DBSSPregNode.Attributes['wndspd'];
                              {.region - yearly precipitations}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_precipitation:=DBSSPregNode.Attributes['precip'];
                              {.reset settlements data}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_settlementEntity:=0;
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_settlementColony:=0;
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_settlementIndex:=0;
                              {.environment modifier}
                              FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_emo:=DBSSPregNode.Attributes['emo'];
                              {.resources data}
                              SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot, 1);
                              DBSSPresourceCnt:=1;
                              DBSSPresourceNode:=DBSSPregNode.ChildNodes.First;
                              while DBSSPresourceNode<>nil do
                              begin
                                 SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot, DBSSPresourceCnt+1);
                                 DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotTypes), DBSSPresourceNode.Attributes['type'] );
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_type:=TFCEduResourceSpotTypes(DBSSPenumIndex);
                                 if DBSSPenumIndex=-1
                                 then raise Exception.Create('bad resource spot type: '+DBSSPresourceNode.Attributes['type']);
                                 DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotQuality), DBSSPresourceNode.Attributes['quality'] );
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_quality:=TFCEduResourceSpotQuality(DBSSPenumIndex);
                                 if DBSSPenumIndex=-1
                                 then raise Exception.Create('bad resource spot quality: '+DBSSPresourceNode.Attributes['quality']);
                                 DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotRarity), DBSSPresourceNode.Attributes['rarity'] );
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_rarity:=TFCEduResourceSpotRarity(DBSSPenumIndex);
                                 if DBSSPenumIndex=-1
                                 then raise Exception.Create('bad resource spot rarity: '+DBSSPresourceNode.Attributes['rarity']);
                                 inc(DBSSPresourceCnt);
                                 DBSSPresourceNode:=DBSSPresourceNode.NextSibling;
                              end;
                              inc(DBSSPregCnt);
                              DBSSPregNode:= DBSSPregNode.NextSibling;
                           end; //==END== while DBSSPregNode<>nil ==//
                           {.set the right number of regions}
                           SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_regions, DBSSPregCnt);
                        end //==END== else if NodeName='orbobjregions' ==//
                        else if DBSSPorbObjNode.NodeName='satobj'
                        then
                        begin
                           {.initialize satellite data}
                           SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList, length(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList)+1);
                           inc(DBSSPsatCnt);
                           {satellite id db token}
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_dbTokenId:=DBSSPorbObjNode.Attributes['sattoken'];
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_isSatellite:=true;
                           DBSSPsatNode:= DBSSPorbObjNode.ChildNodes.First;
                           while DBSSPsatNode<>nil do
                           begin
                              if DBSSPsatNode.NodeName='satorbdata' then
                              begin
                                 {.distance from central planet}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_isSatTdistFrmOOb:=DBSSPsatNode.Attributes['satdist'];
                                 {.revolution period}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriod:=DBSSPsatNode.Attributes['satrevol'];
                                 {.revolution period init day}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriodInit:=DBSSPsatNode.Attributes['satrevinit'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_angle1stDay:=roundto(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriodInit*360/FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriod, -2);
                                 {.gravity sphere of influence radius}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_gravitationalSphereRadius:=DBSSPsatNode.Attributes['satgravsphrad'];
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
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optClosest
                                    else if DBSSPperOrbDmp='optInterm'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optIntermediary
                                    else if DBSSPperOrbDmp='optFarest'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_orbitalPeriodType:=optFarest;
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_dayStart:=DBSSPperOrbNode.Attributes['opstrt'];
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_dayEnd:=DBSSPperOrbNode.Attributes['opend'];
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_orbitalPeriods[DBSSPperOrbCnt].OOS_meanTemperature:=DBSSPperOrbNode.Attributes['opmtemp'];
                                    DBSSPperOrbNode:= DBSSPperOrbNode.NextSibling;
                                 end;
                              end //==END== else if DBSSPsatNode.NodeName='orbperlist' ==//
                              else if DBSSPsatNode.NodeName='satgeophysdata'
                              then
                              begin
                                 DBSSPenumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalObjectTypes ), DBSSPsatNode.Attributes['sattype'] );
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_type:=TFCEduOrbitalObjectTypes( DBSSPenumIndex );
                                 if DBSSPenumIndex=-1
                                 then raise Exception.Create( 'bad (sat) orbital object type: '+DBSSPsatNode.Attributes['sattype'] );
                                 {.diameter}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_diameter:=DBSSPsatNode.Attributes['satdiam'];
                                 {.density}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_dens:=DBSSPsatNode.Attributes['satdens'];
                                 {.mass}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_mass:=DBSSPsatNode.Attributes['satmass'];
                                 {.gravity}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_gravity:=DBSSPsatNode.Attributes['satgrav'];
                                 {.escape velocity}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_escapeVelocity:=DBSSPsatNode.Attributes['satescvel'];
                                 {.inclination axis}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_inclinationAxis:=DBSSPsatNode.Attributes['satinclax'];
                                 {.magnetic field}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_magneticField:=DBSSPsatNode.Attributes['satmagfld'];
                                 {.albedo}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_albedo:=DBSSPsatNode.Attributes['satalbe'];
                              end {.else if DBSSPsatNode.NodeName='satgeophysdata'}
                              else if DBSSPsatNode.NodeName='satecosdata' then
                              begin
                                 {.environment}
                                 DBSSPenumIndex:=GetEnumValue( TypeInfo( TFCEduEnvironmentTypes ), DBSSPsatNode.Attributes['satenvtype'] );
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_environment:=TFCEduEnvironmentTypes( DBSSPenumIndex );
                                 if DBSSPenumIndex=-1
                                 then raise Exception.Create( 'bad (sat) environment type: '+DBSSPsatNode.Attributes['satenvtype'] );
                                 {.atmosphere pressure}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphericPressure:=DBSSPsatNode.Attributes['satatmpres'];
                                 {.clouds cover}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_cloudsCover:=DBSSPsatNode.Attributes['satcloudscov'];
                                 {.primary gas volume}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_primaryGasVolumePerc:=DBSSPsatNode.Attributes['atmprimgasvol'];
                                 {.atmospheric composition}
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceH2:=DBSSPsatNode.Attributes['atmH2'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceHe:=DBSSPsatNode.Attributes['atmHe'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceCH4:=DBSSPsatNode.Attributes['atmCH4'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceNH3:=DBSSPsatNode.Attributes['atmNH3'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceH2O:=DBSSPsatNode.Attributes['atmH2O'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceNe:=DBSSPsatNode.Attributes['atmNe'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceN2:=DBSSPsatNode.Attributes['atmN2'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceCO:=DBSSPsatNode.Attributes['atmCO'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceNO:=DBSSPsatNode.Attributes['atmNO'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceO2:=DBSSPsatNode.Attributes['atmO2'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceH2S:=DBSSPsatNode.Attributes['atmH2S'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceAr:=DBSSPsatNode.Attributes['atmAr'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceCO2:=DBSSPsatNode.Attributes['atmCO2'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceNO2:=DBSSPsatNode.Attributes['atmNO2'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceO3:=DBSSPsatNode.Attributes['atmO3'];
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_atmosphere.AC_gasPresenceSO2:=DBSSPsatNode.Attributes['atmSO2'];
                                 {.hydrosphere}
                                 DBSSPhydroTp:=DBSSPsatNode.Attributes['hydroTp'];
                                 if DBSSPhydroTp='htNone'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hNoH2O
                                 else if DBSSPhydroTp='htVapor'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hVaporH2O
                                 else if DBSSPhydroTp='htLiquid'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hLiquidH2O
                                 else if DBSSPhydroTp='htIceSheet'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hIceSheet
                                 else if DBSSPhydroTp='htCrystal'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hCrystalIce
                                 else if DBSSPhydroTp='htLiqNH3'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hLiquidH2O_blend_NH3
                                 else if DBSSPhydroTp='htLiqCH4'
                                 then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphere:=hLiquidCH4;
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_hydrosphereArea:=DBSSPsatNode.Attributes['hydroArea'];
                              end {.else if DBSSPsatNode.NodeName='satecosdata'}
                              else if DBSSPsatNode.NodeName='satregions'
                              then
                              begin
                                 SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions, 31);
                                 DBSSPregCnt:=1;
                                 DBSSPregNode:=DBSSPsatNode.ChildNodes.First;
                                 while DBSSPregNode<>nil do
                                 begin
                                    {.region - soil type}
                                    DBSSPregDmp:=DBSSPregNode.Attributes['soiltp'];
                                    if DBSSPregDmp='rst01rockDes'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst01RockyDesert
                                    else if DBSSPregDmp='rst02sandDes'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst02SandyDesert
                                    else if DBSSPregDmp='rst03volcanic'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst03Volcanic
                                    else if DBSSPregDmp='rst04polar'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst04Polar
                                    else if DBSSPregDmp='rst05arid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst05Arid
                                    else if DBSSPregDmp='rst06fertile'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst06Fertile
                                    else if DBSSPregDmp='rst07oceanic'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst07Oceanic
                                    else if DBSSPregDmp='rst08coastRockDes'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst08CoastalRockyDesert
                                    else if DBSSPregDmp='rst09coastSandDes'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst09CoastalSandyDesert
                                    else if DBSSPregDmp='rst10coastVolcanic'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst10CoastalVolcanic
                                    else if DBSSPregDmp='rst11coastPolar'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst11CoastalPolar
                                    else if DBSSPregDmp='rst12coastArid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst12CoastalArid
                                    else if DBSSPregDmp='rst13coastFertile'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst13CoastalFertile
                                    else if DBSSPregDmp='rst14barren'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst14Sterile
                                    else if DBSSPregDmp='rst15icyBarren'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_soilType:=rst15icySterile;
                                    {.region - relief}
                                    DBSSPregDmp:=DBSSPregNode.Attributes['relief'];
                                    if DBSSPregDmp='rr1plain'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr1Plain
                                    else if DBSSPregDmp='rr4broken'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr4Broken
                                    else if DBSSPregDmp='rr9mountain'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_relief:=rr9Mountain;
                                    {.region - climate}
                                    DBSSPregDmp:=DBSSPregNode.Attributes['climate'];
                                    if DBSSPregDmp='rc00void'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc00VoidNoUse
                                    else if DBSSPregDmp='rc01vhotHumid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc01VeryHotHumid
                                    else if DBSSPregDmp='rc02vhotSemiHumid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc02VeryHotSemiHumid
                                    else if DBSSPregDmp='rc03hotSemiArid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc03HotSemiArid
                                    else if DBSSPregDmp='rc04hotArid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc04HotArid
                                    else if DBSSPregDmp='rc05modHumid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc05ModerateHumid
                                    else if DBSSPregDmp='rc06modDry'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc06ModerateDry
                                    else if DBSSPregDmp='rc07coldArid'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc07ColdArid
                                    else if DBSSPregDmp='rc08periarctic'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc08Periarctic
                                    else if DBSSPregDmp='rc09arctic'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc09Arctic
                                    else if DBSSPregDmp='rc10extreme'
                                    then FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_climate:=rc10Extreme;
                                    {.region - mean temperature at min distance}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_meanTdMin:=DBSSPregNode.Attributes['mtdmin'];
                                    {.region - mean temperature at intermediate distance}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_meanTdInt:=DBSSPregNode.Attributes['mtdint'];
                                    {.region - mean temperature at max distance}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_meanTdMax:=DBSSPregNode.Attributes['mtdmax'];
                                    {.region - mean windspeed}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_windSpeed:=DBSSPregNode.Attributes['wndspd'];
                                    {.region - yearly precipitations}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_precipitation:=DBSSPregNode.Attributes['precip'];
                                    {.reset settlements data}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_settlementEntity:=0;
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_settlementColony:=0;
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_settlementIndex:=0;
                                    {.environment modifier}
                                    FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_emo:=DBSSPregNode.Attributes['emo'];
                                    {.resources data}
                                    SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot, 1);
                                    DBSSPresourceCnt:=1;
                                    DBSSPresourceNode:=DBSSPregNode.ChildNodes.First;
                                    while DBSSPresourceNode<>nil do
                                    begin
                                       SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot, DBSSPresourceCnt+1);
                                       DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotTypes), DBSSPresourceNode.Attributes['type'] );
                                       FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_type:=TFCEduResourceSpotTypes(DBSSPenumIndex);
                                       if DBSSPenumIndex=-1
                                       then raise Exception.Create('bad resource spot type: '+DBSSPresourceNode.Attributes['type']);
                                       DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotQuality), DBSSPresourceNode.Attributes['quality'] );
                                       FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_quality:=TFCEduResourceSpotQuality(DBSSPenumIndex);
                                       if DBSSPenumIndex=-1
                                       then raise Exception.Create('bad resource spot quality: '+DBSSPresourceNode.Attributes['quality']);
                                       DBSSPenumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotRarity), DBSSPresourceNode.Attributes['rarity'] );
                                       FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions[DBSSPregCnt].OOR_resourceSpot[DBSSPresourceCnt].RS_rarity:=TFCEduResourceSpotRarity(DBSSPenumIndex);
                                       if DBSSPenumIndex=-1
                                       then raise Exception.Create('bad resource spot rarity: '+DBSSPresourceNode.Attributes['rarity']);
                                       inc(DBSSPresourceCnt);
                                       DBSSPresourceNode:=DBSSPresourceNode.NextSibling;
                                    end;
                                    inc(DBSSPregCnt);
                                    DBSSPregNode:= DBSSPregNode.NextSibling;
                                 end; //==END== while DBSSPregNode<>nil ==//
                                 {.set the right number of regions}
                                 SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_regions, DBSSPregCnt);
                              end; //==END== else if DBSSPorbObjNode.NodeName='satregions' ==//
                              DBSSPsatNode:= DBSSPsatNode.NextSibling;
                           end; {.while DBSSPsatNode<>nil}
                        end; {.else if DBSSPorbObjNode.NodeName='satobj'}
                        DBSSPorbObjNode:= DBSSPorbObjNode.NextSibling;
                     end; {.while DBSSPorbObjNode<>nil}
                  end; {.else if DBSSPstarSubNode.NodeName='orbobj'}
                  DBSSPstarSubNode:=DBSSPstarSubNode.NextSibling;
               end; {.while DBSSPstarSubNode<>nil}
               {.resize to real table size for orbital objects}
               SetLength(FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects, DBSSPorbObjCnt+1);
               inc(DBSSPstarCnt);
               DBSSPstarNode:= DBSSPstarNode.NextSibling;
            end; {.while DBSSPstarNode<>nil}
            inc(DBSSPstarSysCnt);
         end; {.if DBSSPstarSysNode.NodeName<>'#comment'}
         DBSSPstarSysNode := DBSSPstarSysNode.NextSibling;
      end; {.while DBSSPstarSys<>nil}
      {.resize to real table size}
      SetLength(FCDduStarSystem, DBSSPstarSysCnt);
   end; {.if DBSSPaction=sspStarSys}
   {.disable}
   FCWinMain.FCXMLdbUniv.Active:=false;
end;

procedure FCMdF_DBTechnosciences_Load;
{:DEV NOTES: WARNING NOT USED IN ANY PART OF THE CODE, PUT IT IN FARC_DATA_INIT.}
{:Purpose: load the technosciences database.
    Additions:
}
   var
      DBTLcnt: integer;
      
      DBTLstr: string;
   
      DBTLnode: IXMLnode;
begin
   {.clear the data structure}
   FCDBtechsci:=nil;
   SetLength(FCDBtechsci, 1);
   DBTLcnt:=0;
   {.read the document}
   FCWinMain.FCXMLdbTechnosciences.FileName:=FCVdiPathXML+'\env\technosciencesdb.xml';
   FCWinMain.FCXMLdbTechnosciences.Active:=true;
   DBTLnode:=FCWinMain.FCXMLdbTechnosciences.DocumentElement.ChildNodes.First;
   while DBTLnode<>nil do
   begin
      if DBTLnode.NodeName<>'#comment'
      then
      begin
         inc(DBTLcnt);
         SetLength(FCDBtechsci, DBTLcnt+1);
         FCDBtechsci[DBTLcnt].T_token:=DBTLnode.Attributes['token'];
         DBTLstr:=DBTLnode.Attributes['rsector'];
         if DBTLstr='rsNone'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsNone
         else if DBTLstr='rsAerospaceEng'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsAerospaceEngineering
         else if DBTLstr='rsBiogenetics'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsBiogenetics
         else if DBTLstr='rsEcosciences'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsEcosciences
         else if DBTLstr='rsIndustrialTech'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsIndustrialTech
         else if DBTLstr='rsMedicine'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsMedicine
         else if DBTLstr='rsNanotech'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsNanotech
         else if DBTLstr='rsPhysics'
         then FCDBtechsci[DBTLcnt].T_researchSector:=rsPhysics;
         FCDBtechsci[DBTLcnt].T_level:=DBTLnode.Attributes['level'];
         DBTLstr:=DBTLnode.Attributes['type'];
         if DBTLstr='rtBasicTech'
         then FCDBtechsci[DBTLcnt].T_type:=rtBasicTech
         else if DBTLstr='rtPureTheory'
         then FCDBtechsci[DBTLcnt].T_type:=rtPureTheory
         else if DBTLstr='rtExpResearch'
         then FCDBtechsci[DBTLcnt].T_type:=rtExpResearch
         else if DBTLstr='rtCompleteResearch'
         then FCDBtechsci[DBTLcnt].T_type:=rtCompleteResearch;
         FCDBtechsci[DBTLcnt].T_difficulty:=DBTLnode.Attributes['difficulty'];
      end; //== END == if DBTLnode.NodeName<>'#comment' ==//
      DBTLnode:=DBTLnode.NextSibling;
   end; //== END == while DBTLnode<>nil do ==//
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
   HTDLroot:=FCWinMain.FCXMLtxtEncy.DocumentElement.ChildNodes.FindNode('hintlist'+FCVdiLanguage);
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

