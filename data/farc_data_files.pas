{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: XML databases - processing unit

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
   SysUtils
   ,XMLIntf
   ,TypInfo;

{list of switch for DBstarSys_Process}
type TFCEdfstSysProc=(
   {process all star systems w/o orbital objects and satellites}
   dfsspStarSys
   {process orbital objects and satellites of a designed star}
   ,dfsspOrbObj
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   load the configuration data in the XML configuration file
///</summary>
///   <param name="mustLoadCurrentGameTime">true= load the current game time</param>
procedure FCMdF_ConfigurationFile_Load(const mustLoadCurrentGameTime: boolean);

///<summary>
///   save the configuration data in the XML configuration file
///</summary>
///   <param name="mustSaveCurrentGameTime">true= save the current game time</param>
procedure FCMdF_ConfigurationFile_Save(const mustSaveCurrentGameTime:boolean);

///<summary>
///   load the factions database XML file
///</summary>
procedure FCMdF_DBFactions_Load;

///<summary>
///   load the infrastructure database XML file
///</summary>
procedure FCMdF_DBInfrastructures_Load;

///<summary>
///   load the products database XML file
///</summary>
procedure FCMdF_DBProducts_Load;

///<summary>
///   load the databases XML files concerning space units (internal structures and designs)
///</summary>
procedure FCMdF_DBSpaceUnits_Load;

///<summary>
///   load SPM items database XML file
///</summary>
procedure FCMdF_DBSPMitems_Load;

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
   ,farc_main
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMdF_ConfigurationFile_Load( const mustLoadCurrentGameTime: boolean );
{:Purpose: load the configuration data in the XML configuration file.
   Additions:
      -2012Jul29- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
      XMLConfiguration: IXMLNode;
begin
	{.read the document}
	FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
	FCWinMain.FCXMLcfg.Active:=true;
	{.read the locale setting}
   XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode( 'locale' );
   if XMLConfiguration<>nil
   then FCVdiLanguage:=XMLConfiguration.Attributes['lang'];
   {.read the main window data}
	XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode( 'mainwin' );
	if XMLConfiguration<>nil then
	begin
		FCVdiWinMainWidth:=XMLConfiguration.Attributes['mwwidth'];
		FCVdiWinMainHeight:=XMLConfiguration.Attributes['mwheight'];
		FCVdiWinMainLeft:=XMLConfiguration.Attributes['mwlft'];
		FCVdiWinMainTop:=XMLConfiguration.Attributes['mwtop'];
	end;
   {.read the panels data}
	XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode( 'panels' );
	if XMLConfiguration<>nil then
	begin
      FCVdiLocStoreColonyPanel:=XMLConfiguration.Attributes['colfacStore'];
      if FCVdiLocStoreColonyPanel then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=XMLConfiguration.Attributes['cfacX'];
         FCWinMain.FCWM_ColDPanel.Top:=XMLConfiguration.Attributes['cfacY'];
      end
      else if not FCVdiLocStoreColonyPanel then
      begin
         FCWinMain.FCWM_ColDPanel.Left:=20;
         FCWinMain.FCWM_ColDPanel.Top:=80;
      end;
      FCVdiLocStoreCPSobjPanel:=XMLConfiguration.Attributes['cpsStore'];
      if assigned( FCcps )
         and ( FCVdiLocStoreCPSobjPanel ) then
      begin
         FCcps.CPSpX:=XMLConfiguration.Attributes['cpsX'];
         FCcps.CPSpY:=XMLConfiguration.Attributes['cpsY'];
      end
      else if not assigned( FCcps )
         and ( FCVdiLocStoreCPSobjPanel ) then
      begin
         FCWinMain.FCGLSHUDcpsCredL.Tag:=XMLConfiguration.Attributes['cpsX'];
         FCWinMain.FCGLSHUDcpsTlft.Tag:=XMLConfiguration.Attributes['cpsY'];
      end;
		FCVdiLocStoreHelpPanel:=XMLConfiguration.Attributes['helpStore'];
      if FCVdiLocStoreHelpPanel then
      begin
         FCWinMain.FCWM_HelpPanel.Left:=XMLConfiguration.Attributes['helpX'];
         FCWinMain.FCWM_HelpPanel.Top:=XMLConfiguration.Attributes['helpY'];
      end;
	end;
   {.read the graphic setting}
   XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('gfx');
   if XMLConfiguration<>nil then
   begin
      FCVdiWinMainWideScreen:=XMLConfiguration.Attributes['wide'];
      FC3doglHRstandardTextures:=XMLConfiguration.Attributes['hrstdt'];
   end;
   {.read the current game data}
	XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
	if XMLConfiguration<>nil then
   begin
      FCRplayer.P_gameName:=XMLConfiguration.Attributes['gname'];
      if mustLoadCurrentGameTime then
      begin
         FCRplayer.P_timeTick:=XMLConfiguration.Attributes['tfTick'];
         FCRplayer.P_timeMin:=XMLConfiguration.Attributes['tfMin'];
         FCRplayer.P_timeHr:=XMLConfiguration.Attributes['tfHr'];
         FCRplayer.P_timeday:=XMLConfiguration.Attributes['tfDay'];
         FCRplayer.P_timeMth:=XMLConfiguration.Attributes['tfMth'];
         FCRplayer.P_timeYr:=XMLConfiguration.Attributes['tfYr'];
      end;
   end;
   {.read the debug info}
	XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('debug');
	if XMLConfiguration<>nil
   then FCVdiDebugMode:=XMLConfiguration.Attributes['dswitch'];
	FCWinMain.FCXMLcfg.Active:=false;
	FCWinMain.FCXMLcfg.FileName:='';
end;

procedure FCMdF_ConfigurationFile_Save(const mustSaveCurrentGameTime:boolean);
{:Purpose: save the configuration data in the XML configuration file.
   Additions:
      -2012Jul29- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (-)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
      OldTimeDay
      ,OldTimeHour
      ,OldTimeMinute
      ,OldTimeMonth
      ,OldTimeTick
      ,OldTimeYear: integer;

      XMLConfiguration
      ,XMLConfigurationItem: IXMLNode;
begin
   {.clear the old file if it exists}
   if FileExists( FCVdiPathConfigFile ) then
   begin
      if FCRplayer.P_gameName<>'' then
      begin
         FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
         FCWinMain.FCXMLcfg.Active:=true;
         XMLConfigurationItem:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode( 'currGame' );
         if XMLConfigurationItem<>nil then
         begin
            OldTimeTick:=XMLConfigurationItem.Attributes['tfTick'];
            OldTimeMinute:=XMLConfigurationItem.Attributes['tfMin'];
            OldTimeHour:=XMLConfigurationItem.Attributes['tfHr'];
            OldTimeDay:=XMLConfigurationItem.Attributes['tfDay'];
            OldTimeMonth:=XMLConfigurationItem.Attributes['tfMth'];
            OldTimeYear:=XMLConfigurationItem.Attributes['tfYr'];
         end;
         FCWinMain.FCXMLcfg.Active:=false;
         FCWinMain.FCXMLcfg.FileName:='';
      end;
      DeleteFile( pchar( FCVdiPathConfigFile ) );
   end;
   FCWinMain.FCXMLcfg.Active:=true;
   XMLConfiguration:=FCWinMain.FCXMLcfg.AddChild( 'configfile' );
   XMLConfigurationItem:= XMLConfiguration.AddChild( 'locale' );
   XMLConfigurationItem.Attributes['lang']:= FCVdiLanguage;
   XMLConfigurationItem:= XMLConfiguration.AddChild( 'mainwin' );
   XMLConfigurationItem.Attributes['mwwidth']:= FCVdiWinMainWidth;
   XMLConfigurationItem.Attributes['mwheight']:= FCVdiWinMainHeight;
   XMLConfigurationItem.Attributes['mwlft']:= FCVdiWinMainLeft;
   XMLConfigurationItem.Attributes['mwtop']:= FCVdiWinMainTop;
	XMLConfigurationItem:=XMLConfiguration.AddChild( 'panels' );
   XMLConfigurationItem.Attributes['colfacStore']:=FCVdiLocStoreColonyPanel;
   if FCVdiLocStoreColonyPanel then
   begin
      XMLConfigurationItem.Attributes['cfacX']:=FCWinMain.FCWM_ColDPanel.Left;
      XMLConfigurationItem.Attributes['cfacY']:=FCWinMain.FCWM_ColDPanel.Top;
   end
   else
   begin
      XMLConfigurationItem.Attributes['cfacX']:=20;
      XMLConfigurationItem.Attributes['cfacY']:=80;
   end;
   XMLConfigurationItem.Attributes['cpsStore']:=FCVdiLocStoreCPSobjPanel;
   if not FCVdiLocStoreCPSobjPanel then
   begin
      XMLConfigurationItem.Attributes['cpsX']:=0;
      XMLConfigurationItem.Attributes['cpsY']:=0;
   end
   else if assigned( FCcps )
      and ( FCVdiLocStoreCPSobjPanel ) then
   begin
      XMLConfigurationItem.Attributes['cpsX']:=FCcps.CPSobjPanel.Left;
      XMLConfigurationItem.Attributes['cpsY']:=FCcps.CPSobjPanel.Top;
   end
   else if not assigned( FCcps )
      and (FCVdiLocStoreCPSobjPanel ) then
   begin
      XMLConfigurationItem.Attributes['cpsX']:=2;
      XMLConfigurationItem.Attributes['cpsY']:=40;
   end;
   XMLConfigurationItem.Attributes['helpStore']:=FCVdiLocStoreHelpPanel;
   if FCVdiLocStoreHelpPanel then
   begin
      XMLConfigurationItem.Attributes['helpX']:=FCWinMain.FCWM_HelpPanel.Left;
      XMLConfigurationItem.Attributes['helpY']:=FCWinMain.FCWM_HelpPanel.Top;
   end
   else
   begin
      XMLConfigurationItem.Attributes['helpX']:=0;
      XMLConfigurationItem.Attributes['helpY']:=0;
   end;
   XMLConfigurationItem:=XMLConfiguration.AddChild( 'gfx' );
   XMLConfigurationItem.Attributes['wide']:=FCVdiWinMainWideScreen;
   XMLConfigurationItem.Attributes['hrstdt']:=FC3doglHRstandardTextures;
	XMLConfigurationItem:=XMLConfiguration.AddChild( 'currGame' );
	XMLConfigurationItem.Attributes['gname']:=FCRplayer.P_gameName;
   if ( mustSaveCurrentGameTime )
      and ( FCRplayer.P_gameName<>'' ) then
   begin
      XMLConfigurationItem.Attributes['tfTick']:= FCRplayer.P_timeTick;
      XMLConfigurationItem.Attributes['tfMin']:= FCRplayer.P_timeMin;
      XMLConfigurationItem.Attributes['tfHr']:= FCRplayer.P_timeHr;
      XMLConfigurationItem.Attributes['tfDay']:= FCRplayer.P_timeday;
      XMLConfigurationItem.Attributes['tfMth']:= FCRplayer.P_timeMth;
      XMLConfigurationItem.Attributes['tfYr']:= FCRplayer.P_timeYr;
   end
   else if ( mustSaveCurrentGameTime )
      and ( FCRplayer.P_gameName='' ) then
   begin
      XMLConfigurationItem.Attributes['tfTick']:=0;
      XMLConfigurationItem.Attributes['tfMin']:=0;
      XMLConfigurationItem.Attributes['tfHr']:=0;
      XMLConfigurationItem.Attributes['tfDay']:=0;
      XMLConfigurationItem.Attributes['tfMth']:=0;
      XMLConfigurationItem.Attributes['tfYr']:=0;
   end
   else if not mustSaveCurrentGameTime then
   begin
      XMLConfigurationItem.Attributes['tfTick']:=OldTimeTick;
      XMLConfigurationItem.Attributes['tfMin']:=OldTimeMinute;
      XMLConfigurationItem.Attributes['tfHr']:=OldTimeHour;
      XMLConfigurationItem.Attributes['tfDay']:=OldTimeDay;
      XMLConfigurationItem.Attributes['tfMth']:=OldTimeMonth;
      XMLConfigurationItem.Attributes['tfYr']:=OldTimeYear;
   end;
	XMLConfigurationItem:=XMLConfiguration.AddChild( 'debug' );
	XMLConfigurationItem.Attributes['dswitch']:=FCVdiDebugMode;
   FCWinMain.FCXMLcfg.SaveToFile( FCVdiPathConfigFile );
   FCWinMain.FCXMLcfg.Active:=false;
end;

procedure FCMdF_DBFactions_Load;
{:Purpose: load the factions database XML file.
   Additions:
      -2012Jul29- *code audit = COMPLETION.
      -2012Jul23- *code audit (begin):
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result
                     (_)put [format x.xx ] dans returns of summary, if required and if the function do formatting
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
                  *fix: apply code format to get rid of the decimal format bug.
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
   var
      ColonizationModeCount
      ,Count1
      ,Count2
      ,EnumIndex
      ,FactionCount
      ,StartingLocations: Integer;

      XMLFaction
      ,XMLFactionItem
      ,XMLFactionSubItem: IXMLNode;
begin
	{.clear the data structure}
	FactionCount:=1;
	while FactionCount<=Length( FCDBfactions )-1 do
	begin
		FCDBfactions[FactionCount]:=FCDBfactions[0];
      setlength( FCDBfactions[FactionCount].F_facCmode, 0 );
      setlength( FCDBfactions[FactionCount].F_facStartLocList, 0 );
      setlength( FCDBfactions[FactionCount].F_spm, 0 );
		inc( FactionCount );
	end;
	FactionCount:=1;
	{.read the document}
	FCWinMain.FCXMLdbFac.FileName:=FCVdiPathXML+'\env\factionsdb.xml';
	FCWinMain.FCXMLdbFac.Active:=true;
	XMLFaction:= FCWinMain.FCXMLdbFac.DocumentElement.ChildNodes.First;
	while XMLFaction<>nil do
	begin
      if XMLFaction.NodeName<>'#comment' then
      begin
         ColonizationModeCount:=0;
         StartingLocations:=0;
         setlength( FCDBfactions[FactionCount].F_facCmode, 1 );
         setlength( FCDBfactions[FactionCount].F_facStartLocList, 1 );
         setlength( FCDBfactions[FactionCount].F_spm, 1 );
         FCDBfactions[FactionCount].F_token:=XMLFaction.Attributes[ 'token' ];
         FCDBfactions[FactionCount].F_lvl:=XMLFaction.Attributes[ 'level' ];
         {.faction items processing loop}
         XMLFactionItem:= XMLFaction.ChildNodes.First;
         while XMLFactionItem<>nil do
         begin
            {.colonization mode}
            if XMLFactionItem.NodeName='facColMode' then
            begin
               {.equipment items count}
               Count1:=0;
               {.viability objectives count}
               Count2:=0;
               inc( ColonizationModeCount );
               SetLength( FCDBfactions[FactionCount].F_facCmode, ColonizationModeCount+1 );
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_token:=XMLFactionItem.Attributes['token'];
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsVthEconomic:=XMLFactionItem.Attributes['viabThrEco'];
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsVthSocial:=XMLFactionItem.Attributes['viabThrSoc'];
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsVthSpaceMilitary:=XMLFactionItem.Attributes['viabThrSpMil'];
               EnumIndex:=GetEnumValue( TypeInfo( TFCEcrIntRg ), XMLFactionItem.Attributes['creditrng'] );
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsCrRg:=TFCEcrIntRg( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad faction XML loading w/ colonization mode credit range: '+XMLFactionItem.Attributes['creditrng'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEcrIntRg ), XMLFactionItem.Attributes['intrng'] );
               FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsIntRg:=TFCEcrIntRg( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad faction XML loading w/ colonization mode interest range: '+XMLFactionItem.Attributes['intrng'] );
               {.equipment list items}
               XMLFactionSubItem:=XMLFactionItem.ChildNodes.First;
               while XMLFactionSubItem<>nil do
               begin
                  {.viability objectives}
                  if XMLFactionSubItem.NodeName='facViabObj' then
                  begin
                     inc(Count2);
                     SetLength( FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsViabObj, Count2+1 );
                     {.viability type}
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEcpsoObjectiveTypes ), XMLFactionSubItem.Attributes['objTp'] );
                     FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsViabObj[Count2].FVO_objTp:=TFCEcpsoObjectiveTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad faction viability objective: '+XMLFactionSubItem.Attributes['objTp'] );
                     if FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsViabObj[Count2].FVO_objTp=otEcoIndustrialForce then
                     begin
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsViabObj[Count2].FVO_ifProduct:=XMLFactionSubItem.Attributes['product'];
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_cpsViabObj[Count2].FVO_ifThreshold:=StrToFloat( XMLFactionSubItem.Attributes['threshold'], FCVdiFormat );
                     end;
                  end
                  {.equipment items list}
                  else if XMLFactionSubItem.NodeName='facEqupItm' then
                  begin
                     inc(Count1);
                     SetLength( FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList, Count1+1 );
                     if XMLFactionSubItem.Attributes['itemTp']='feitProduct' then
                     begin
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_itemType:=feitProduct;
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_prodToken:=XMLFactionSubItem.Attributes['prodToken'];
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_prodUnit:=XMLFactionSubItem.Attributes['unit'];
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_prodCarriedBy:=XMLFactionSubItem.Attributes['carriedBy'];
                     end
                     {.space unit}
                     else if XMLFactionSubItem.Attributes['itemTp']='feitSpaceCraft' then
                     begin
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_itemType:=feitSpaceUnit;
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_spuProperNameToken:=XMLFactionSubItem.Attributes['properName'];
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_spuDesignToken:=XMLFactionSubItem.Attributes['designToken'];
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEspUnStatus ), XMLFactionSubItem.Attributes['status'] );
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_spuStatus:=TFCEspUnStatus( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad faction equipment item loading w/ space unit status: '+XMLFactionSubItem.Attributes['status'] );
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_spuDockInfo:=XMLFactionSubItem.Attributes['spuDock'];
                        FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList[Count1].FCMEI_spuAvailEnRM:=StrToFloat( XMLFactionSubItem.Attributes['availEnRM'], FCVdiFormat );
                     end;
                  end;
                  XMLFactionSubItem:=XMLFactionSubItem.NextSibling;
               end; //==END== while DBFRfacDotItm<>nil ==//
               SetLength( FCDBfactions[FactionCount].F_facCmode[ColonizationModeCount].FCM_dotList, Count1+1 );
            end //==END== else if DBFRfacSubItem.NodeName='facColMode' ==//
            {.starting location}
            else if XMLFactionItem.NodeName='facStartLoc' then
            begin
               inc( StartingLocations );
               SetLength( FCDBfactions[FactionCount].F_facStartLocList, StartingLocations+1 );
               FCDBfactions[FactionCount].F_facStartLocList[StartingLocations].FSL_locSSys:=XMLFactionItem.Attributes['locSSys'];
               FCDBfactions[FactionCount].F_facStartLocList[StartingLocations].FSL_locStar:=XMLFactionItem.Attributes['locStar'];
               FCDBfactions[FactionCount].F_facStartLocList[StartingLocations].FSL_locObObj:=XMLFactionItem.Attributes['locObObj'];
            end
            {.SPM settings}
            else if XMLFactionItem.NodeName='facSPM' then
            begin
               {.SPM items count}
               Count1:=0;
               XMLFactionSubItem:=XMLFactionItem.ChildNodes.First;
               while XMLFactionSubItem<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDBfactions[FactionCount].F_spm, Count1+1 );
                  FCDBfactions[FactionCount].F_spm[Count1].SPMS_token:=XMLFactionSubItem.Attributes['token'];
                  FCDBfactions[FactionCount].F_spm[Count1].SPMS_duration:=XMLFactionSubItem.Attributes['duration'];
                  FCDBfactions[FactionCount].F_spm[Count1].SPMS_isPolicy:=true;
                  FCDBfactions[FactionCount].F_spm[Count1].SPMS_isSet:=XMLFactionSubItem.Attributes['isSet'];
                  FCDBfactions[FactionCount].F_spm[Count1].SPMS_aprob:=XMLFactionSubItem.Attributes['aprob'];
                  if FCDBfactions[FactionCount].F_spm[Count1].SPMS_aprob=-2 then
                  begin
                     FCDBfactions[FactionCount].F_spm[Count1].SPMS_isPolicy:=false;
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdgBelLvl ), XMLFactionSubItem.Attributes['belieflev'] );
                     FCDBfactions[FactionCount].F_spm[Count1].SPMS_bLvl:=TFCEdgBelLvl( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad faction XML loading w/ meme belief level: '+XMLFactionSubItem.Attributes['belieflev'] );
                     FCDBfactions[FactionCount].F_spm[Count1].SPMS_sprdVal:=XMLFactionSubItem.Attributes['spreadval'];
                  end;
                  XMLFactionSubItem:=XMLFactionSubItem.NextSibling;
               end; //==END== while DBFRspmItm<>nil ==//
            end;
            XMLFactionItem:= XMLFactionItem.NextSibling;
         end; //==END== while DBFRfacSubItem<>nil ==//
         {.resize to real table size}
         SetLength( FCDBfactions[FactionCount].F_facCmode, ColonizationModeCount+1 );
         SetLength( FCDBfactions[FactionCount].F_facStartLocList, StartingLocations+1 ) ;
         inc( FactionCount );
      end; //==END== if DBFRfacItem.NodeName<>'#comment' ==//
      XMLFaction:= XMLFaction.NextSibling;
	end; //==END== while XMLFaction<>nil do ==//
	FCWinMain.FCXMLdbFac.Active:=false;
end;

procedure FCMdF_DBInfrastructures_Load;
{:Purpose: load the infrastructure database XML file.
    Additions:
      -2012Aug01- *completion of code audit.
      -2012Jul29- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (o)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result
                     (x)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
      Count
      ,Count1
      ,Count2
      ,EnumIndex: integer;

      XMLInfrastructure
      ,XMLInfrastructureItem
      ,XMLInfrastructureItemSub
      ,XMLInfrastructureItemSubSub: IXMLnode;
begin
   {.clear the data structure}
   FCDdipInfrastructures:=nil;
   SetLength( FCDdipInfrastructures, 1 );
   Count:=1;
   {.read the document}
	FCWinMain.FCXMLdbInfra.FileName:=FCVdiPathXML+'\env\infrastrucdb.xml';
	FCWinMain.FCXMLdbInfra.Active:=true;
	XMLInfrastructure:=FCWinMain.FCXMLdbInfra.DocumentElement.ChildNodes.First;
	while XMLInfrastructure<>nil do
	begin
      if XMLInfrastructure.NodeName<>'#comment' then
      begin
         SetLength( FCDdipInfrastructures, Count+1 );
         FCDdipInfrastructures[Count].I_token:=XMLInfrastructure.Attributes['token'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEduEnvironmentTypes ), XMLInfrastructure.Attributes['environment'] );
         FCDdipInfrastructures[Count].I_environment:=TFCEduEnvironmentTypes( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad environment loading w/ infrastructure: '+XMLInfrastructure.Attributes['environment'] );
         XMLInfrastructureItem:=XMLInfrastructure.ChildNodes.First;
         while XMLInfrastructureItem<>nil do
         begin
            if XMLInfrastructureItem.NodeName='infBuild' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdipConstructs ), XMLInfrastructureItem.Attributes['construct'] );
               FCDdipInfrastructures[Count].I_construct:=TFCEdipConstructs( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad construct loading w/ infrastructure: '+XMLInfrastructureItem.Attributes['construct'] );
               FCDdipInfrastructures[Count].I_isSurfaceOnly:=XMLInfrastructureItem.Attributes['isSurfOnly'];
               FCDdipInfrastructures[Count].I_minLevel:=XMLInfrastructureItem.Attributes['minlevel'];
               FCDdipInfrastructures[Count].I_maxLevel:=XMLInfrastructureItem.Attributes['maxlevel'];
               XMLInfrastructureItemSub:=XMLInfrastructureItem.ChildNodes.First;
               while XMLInfrastructureItemSub<>nil do
               begin
                  Count1:=FCDdipInfrastructures[Count].I_minLevel;
                  if XMLInfrastructureItemSub.NodeName='ibSurf' then
                  begin
                     while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                     begin
                        FCDdipInfrastructures[Count].I_surface[Count1]:=StrToFloat( XMLInfrastructureItemSub.Attributes['surflv'+IntToStr( Count1 )], FCVdiFormat );
                        inc( Count1 );
                     end;
                  end
                  else if XMLInfrastructureItemSub.NodeName='ibVol' then
                  begin
                     while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                     begin
                        FCDdipInfrastructures[Count].I_volume[Count1]:=StrToFloat( XMLInfrastructureItemSub.Attributes['vollv'+IntToStr( Count1 )], FCVdiFormat );
                        inc( Count1 );
                     end;
                  end
                  else if XMLInfrastructureItemSub.NodeName='ibBasePwr' then
                  begin
                     while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                     begin
                        FCDdipInfrastructures[Count].I_basePower[Count1]:=StrToFloat( XMLInfrastructureItemSub.Attributes['pwrlv'+IntToStr( Count1 )], FCVdiFormat );
                        inc( Count1 );
                     end;
                  end
                  else if XMLInfrastructureItemSub.NodeName='ibVolMat' then
                  begin
                     while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                     begin
                        FCDdipInfrastructures[Count].I_materialVolume[Count1]:=StrToFloat( XMLInfrastructureItemSub.Attributes['volmatlv'+IntToStr( Count1 )], FCVdiFormat );
                        inc( Count1 );
                     end;
                  end;
                  XMLInfrastructureItemSub:=XMLInfrastructureItemSub.NextSibling;
               end; //==END== while DBIRsizeN<>nil do ==//
            end //==END== if DBIRsubN.NodeName='infBuild' ==//
            else if XMLInfrastructureItem.NodeName='infReq' then
            begin
               XMLInfrastructureItemSub:=XMLInfrastructureItem.ChildNodes.First;
               while XMLInfrastructureItemSub<>nil do
               begin
                  if XMLInfrastructureItemSub.NodeName='irGravity' then
                  begin
                     FCDdipInfrastructures[Count].I_reqGravityMin:=StrToFloat( XMLInfrastructureItemSub.Attributes['min'], FCVdiFormat );
                     FCDdipInfrastructures[Count].I_reqGravityMax:=StrToFloat( XMLInfrastructureItemSub.Attributes['max'], FCVdiFormat );
                  end
                  else if XMLInfrastructureItemSub.NodeName='irHydro' then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipHydrosphereRequirements ), XMLInfrastructureItemSub.Attributes['hydrotype'] );
                     FCDdipInfrastructures[Count].I_reqHydrosphere:=TFCEdipHydrosphereRequirements( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad hydrosphere requirement loading w/ infrastructure: '+XMLInfrastructureItemSub.Attributes['hydrotype'] );
                  end
                  else if XMLInfrastructureItemSub.NodeName='irConstrMat' then
                  begin
                     SetLength( FCDdipInfrastructures[Count].I_reqConstructionMaterials, 1 );
                     Count1:=0;
                     XMLInfrastructureItemSubSub:=XMLInfrastructureItemSub.ChildNodes.First;
                     while XMLInfrastructureItemSubSub<>nil do
                     begin
                        inc( Count1 );
                        SetLength( FCDdipInfrastructures[Count].I_reqConstructionMaterials, Count1+1 );
                        FCDdipInfrastructures[Count].I_reqConstructionMaterials[Count1].RCM_token:=XMLInfrastructureItemSubSub.Attributes['token'];
                        FCDdipInfrastructures[Count].I_reqConstructionMaterials[Count1].RCM_partOfMaterialVolume:=XMLInfrastructureItemSubSub.Attributes['percent'];
                        XMLInfrastructureItemSubSub:=XMLInfrastructureItemSubSub.NextSibling;
                     end;
                  end
                  else if XMLInfrastructureItemSub.NodeName='irRegionSoil' then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipRegionSoilRequirements ), XMLInfrastructureItemSub.Attributes['allowtype'] );
                     FCDdipInfrastructures[Count].I_reqRegionSoil:=TFCEdipRegionSoilRequirements( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad region soil requirement loading w/ infrastructure: '+XMLInfrastructureItemSub.Attributes['allowtype'] );
                  end
                  else if XMLInfrastructureItemSub.NodeName='irRsrcSpot' then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotTypes ), XMLInfrastructureItemSub.Attributes['spottype'] );
                     FCDdipInfrastructures[Count].I_reqResourceSpot:=TFCEduResourceSpotTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad resource spot requirement w/ infrastructure: '+XMLInfrastructureItemSub.Attributes['spottype'] );
                  end;
                  XMLInfrastructureItemSub:=XMLInfrastructureItemSub.NextSibling;
               end; //==END== while DBIRreqsub<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infReq' ==//
            else if XMLInfrastructureItem.NodeName='infReqStaff' then
            begin
               SetLength( FCDdipInfrastructures[Count].I_reqStaff, 1 );
               Count1:=0;
               XMLInfrastructureItemSub:=XMLInfrastructureItem.ChildNodes.First;
               while XMLInfrastructureItemSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDdipInfrastructures[Count].I_reqStaff, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEdpgsPopulationTypes ), XMLInfrastructureItemSub.Attributes['type'] );
                  FCDdipInfrastructures[Count].I_reqStaff[Count1].RS_type:=TFCEdpgsPopulationTypes( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad staff requirement loading w/ infrastructure: '+XMLInfrastructureItemSub.Attributes['type'] );
                  Count2:=FCDdipInfrastructures[Count].I_minLevel;
                  while Count2<=FCDdipInfrastructures[Count].I_maxLevel do
                  begin
                     FCDdipInfrastructures[Count].I_reqStaff[Count1].RS_requiredByLv[Count2]:=XMLInfrastructureItemSub.Attributes['requiredNumLv'+IntToStr( Count2 )];
                     inc( Count2 );
                  end;
                  XMLInfrastructureItemSub:=XMLInfrastructureItemSub.NextSibling;
               end; //==END== while DBIRreqStaff<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infReqStaff' ==//
            else if XMLInfrastructureItem.NodeName='infCustFX' then
            begin
               SetLength( FCDdipInfrastructures[Count].I_customEffectStructure, 1 );
               Count1:=0;
               XMLInfrastructureItemSub:=XMLInfrastructureItem.ChildNodes.First;
               while XMLInfrastructureItemSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDdipInfrastructures[Count].I_customEffectStructure, Count1+1 );
                  if XMLInfrastructureItemSub.NodeName='icfxEnergyGen' then
                  begin
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceEnergyGeneration;
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipEnergyGenerationModes ), XMLInfrastructureItem.Attributes['genMode'] );
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_modes:=TFCEdipEnergyGenerationModes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad energy generation mode loading w/ infrastructure: '+XMLInfrastructureItem.Attributes['genMode'] );
                     case FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_modes of
                        egmAntimatter:;

                        egmFission:
                        begin
                           Count1:=FCDdipInfrastructures[Count].I_minLevel;
                           while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                           begin
                              FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_mFfixedValues[Count1].FV_baseGeneration:=
                                 StrToFloat( XMLInfrastructureItem.Attributes['fixedprodlv'+IntToStr( Count1 )], FCVdiFormat );
                              FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_mFfixedValues[Count1].FV_generationByDevLevel:=
                                 StrToFloat( XMLInfrastructureItem.Attributes['fixedprodlv'+IntToStr( Count1 )+'byDL'], FCVdiFormat );
                              inc( Count1 );
                           end;
                        end;

                        egmPhoton:
                        begin
                           FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_mParea:=XMLInfrastructureItem.Attributes['area'];
                           FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEGmode.EGM_mPefficiency:=XMLInfrastructureItem.Attributes['efficiency'];
                        end;
                     end;
                  end
                  else if XMLInfrastructureItemSub.NodeName='cfxEnergyStor' then
                  begin
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceEnergyStorage;
                     Count2:=XMLInfrastructureItemSub.Attributes['storlevel'];
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_ceEScapacitiesByLevel[Count2]:=StrToFloat( XMLInfrastructureItemSub.Attributes['storCapacity'], FCVdiFormat );
                  end
                  else if XMLInfrastructureItemSub.NodeName='icfxHQbasic'
                  then FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceHeadQuarterPrimary
                  else if XMLInfrastructureItemSub.NodeName='icfxHQSecondary'
                  then FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceHeadQuarterBasic
                  else if XMLInfrastructureItemSub.NodeName='icfxHQPrimary'
                  then FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceHeadQuarterSecondary
                  else if XMLInfrastructureItemSub.NodeName='cfxProductStorage' then
                  begin
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_customEffect:=ceProductStorage;
                     Count2:=XMLInfrastructureItemSub.Attributes['storlevel'];
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_cePSstorageByLevel[Count2].SBL_solid:=StrToFloat( XMLInfrastructureItemSub.Attributes['storSolid'], FCVdiFormat );
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_cePSstorageByLevel[Count2].SBL_liquid:=StrToFloat( XMLInfrastructureItemSub.Attributes['storLiquid'], FCVdiFormat );
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_cePSstorageByLevel[Count2].SBL_gas:=StrToFloat( XMLInfrastructureItemSub.Attributes['storGas'], FCVdiFormat );
                     FCDdipInfrastructures[Count].I_customEffectStructure[Count1].ICFX_cePSstorageByLevel[Count2].SBL_biologic:=StrToFloat( XMLInfrastructureItemSub.Attributes['storBio'], FCVdiFormat );
                  end;
                  XMLInfrastructureItemSub:=XMLInfrastructureItemSub.NextSibling;
               end; //==END== while DBIRcustFX<>nil do ==//
            end //==END== else if DBIRsubN.NodeName='infCustFX' ==//
            else if XMLInfrastructureItem.NodeName='infFunc' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdipFunctions ), XMLInfrastructureItem.Attributes['infFunc'] );
               FCDdipInfrastructures[Count].I_function:=TFCEdipFunctions( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad function loading w/ infrastructure: '+XMLInfrastructureItem.Attributes['infFunc'] );
               case FCDdipInfrastructures[Count].I_function of
                  fEnergy:
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipEnergyGenerationModes ), XMLInfrastructureItem.Attributes['emode'] );
                     FCDdipInfrastructures[Count].I_fEmode.EGM_modes:=TFCEdipEnergyGenerationModes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad energy generation mode loading w/ infrastructure: '+XMLInfrastructureItem.Attributes['emode'] );
                     case FCDdipInfrastructures[Count].I_fEmode.EGM_modes of
                        egmFission:
                        begin
                           Count1:=FCDdipInfrastructures[Count].I_minLevel;
                           while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                           begin
                              FCDdipInfrastructures[Count].I_fEmode.EGM_mFfixedValues[Count1].FV_baseGeneration:=StrToFloat( XMLInfrastructureItem.Attributes['fixedprodlv'+IntToStr( Count1 )], FCVdiFormat );
                              FCDdipInfrastructures[Count].I_fEmode.EGM_mFfixedValues[Count1].FV_generationByDevLevel:=StrToFloat( XMLInfrastructureItem.Attributes['fixedprodlv'+IntToStr( Count1 )+'byDL'], FCVdiFormat );
                              inc( Count1 );
                           end;
                        end;

                        egmPhoton:
                        begin
                           FCDdipInfrastructures[Count].I_fEmode.EGM_mParea:=XMLInfrastructureItem.Attributes['area'];
                           FCDdipInfrastructures[Count].I_fEmode.EGM_mPefficiency:=XMLInfrastructureItem.Attributes['efficiency'];
                        end;
                     end;
                  end;

                  fHousing:
                  begin
                     if FCDdipInfrastructures[Count].I_construct<cConverted then
                     begin
                        Count1:=FCDdipInfrastructures[Count].I_minLevel;
                        while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                        begin
                           FCDdipInfrastructures[Count].I_fHpopulationCapacity[Count1]:=XMLInfrastructureItem.Attributes['pcaplv'+IntToStr( Count1 )];
                           inc( Count1 );
                        end;
                     end;
                     FCDdipInfrastructures[Count].I_fHqualityOfLife:=XMLInfrastructureItem.Attributes['qol'];
                  end;

                  fProduction:
                  begin
                     Count1:=0;
                     XMLInfrastructureItemSub:=XMLInfrastructureItem.ChildNodes.First;
                     while XMLInfrastructureItemSub<>nil do
                     begin
                        inc( Count1 );
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdipProductionModes ), XMLInfrastructureItemSub.Attributes['pmode'] );
                        FCDdipInfrastructures[Count].I_fPmodeStructure[ Count1 ].MS_mode:=TFCEdipProductionModes(EnumIndex);
                        if EnumIndex=-1
                        then raise Exception.Create('bad production mode: '+XMLInfrastructureItemSub.Attributes['pmode'] );
                        FCDdipInfrastructures[Count].I_fPmodeStructure[Count1].MS_occupancy:=XMLInfrastructureItemSub.Attributes['occupancy'];
                        if FCDdipInfrastructures[Count].I_fPmodeStructure[ Count1 ].MS_mode=pmWaterRecovery then
                        begin
                           FCDdipInfrastructures[Count].I_fPmodeStructure[Count1].MS_mode:=pmWaterRecovery;
                           Count1:=FCDdipInfrastructures[Count].I_minLevel;
                           while Count1<=FCDdipInfrastructures[Count].I_maxLevel do
                           begin
                              FCDdipInfrastructures[Count].I_fPmodeStructure[Count1].MS_mWRroofArea:=StrToFloat( XMLInfrastructureItemSub.Attributes['roofArealv'+IntToStr( Count1 )], FCVdiFormat );
                              FCDdipInfrastructures[Count].I_fPmodeStructure[Count1].MS_mWRtrapArea:=StrToFloat( XMLInfrastructureItemSub.Attributes['trapArealv'+IntToStr( Count1 )], FCVdiFormat );
                              inc( Count1 );
                           end;
                        end;
                        XMLInfrastructureItemSub:=XMLInfrastructureItemSub.NextSibling;
                     end; //==END== while DBIRpmode<>nil do ==//
                     if Count1+1<=FCCdipProductionModesMax
                     then FCDdipInfrastructures[Count].I_fPmodeStructure[ Count1+1 ].MS_mode:=pmNone;
                  end;
               end; //==END== case FCDdipInfrastructures[DBIRcnt].I_function of ==//
            end; //==END== else if DBIRsubN.NodeName='infFunc' ==//
            XMLInfrastructureItem:=XMLInfrastructureItem.NextSibling;
         end; //==END== while DBIRsubN<>nil do ==//
         inc( Count );
      end; //==END== if DBIRnode.NodeName<>'#comment' ==//
      XMLInfrastructure:=XMLInfrastructure.NextSibling;
   end; //==END== while DBIRnode<>nil ==//
	FCWinMain.FCXMLdbInfra.Active:=false;
end;

procedure FCMdF_DBProducts_Load;
{:Purpose: load the products database XML file.
   Additions:
      -2012Aug01- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
{:DEV NOTES: WARNING: when updating one material function data, update all the other ones too with the same data if required.}
   var
      Count
      ,EnumIndex: integer;

      XMLProduct
      ,XMLProductItem
      ,XMLProductItemSub: IXMLNode;
begin
   FCDdipProducts:=nil;
   SetLength( FCDdipProducts, 1 );
   Count:=0;
   {.read the document}
   FCWinMain.FCXMLdbProducts.FileName:=FCVdiPathXML+'\env\productsdb.xml';
   FCWinMain.FCXMLdbProducts.Active:=true;
   XMLProduct:= FCWinMain.FCXMLdbProducts.DocumentElement.ChildNodes.First;
   while XMLProduct<>nil do
   begin
      if XMLProduct.NodeName<>'#comment' then
      begin
         inc( Count );
         SetLength( FCDdipProducts, Count+1 );
         FCDdipProducts[Count].P_token:=XMLProduct.Attributes['token'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdipProductClasses ), XMLProduct.Attributes['class'] );
         FCDdipProducts[Count].P_class:=TFCEdipProductClasses( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad product class: '+XMLProduct.Attributes['class'] );
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdipStorageTypes ), XMLProduct.Attributes['storage'] );
         FCDdipProducts[Count].P_storage:=TFCEdipStorageTypes( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad product storage: '+XMLProduct.Attributes['storage'] );
         {:DEV NOTE: complete cargo type loading here}
//         DBPRdumpStr:=DBPRnode.Attributes['cargo'];
         FCDdipProducts[Count].P_volumeByUnit:=StrToFloat( XMLProduct.Attributes['volbyunit'], FCVdiFormat );
         FCDdipProducts[Count].P_massByUnit:=StrToFloat( XMLProduct.Attributes['massbyunit'], FCVdiFormat );
         XMLProductItem:=XMLProduct.ChildNodes.First;
         while XMLProductItem<>nil do
         begin
            if XMLProductItem.NodeName='function' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdipProductFunctions ), XMLProductItem.Attributes['token'] );
               FCDdipProducts[Count].P_function:=TFCEdipProductFunctions( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad product function: '+XMLProductItem.Attributes['token'] );
               case FCDdipProducts[Count].P_function of
                  pfBuildingMaterial:
                  begin
                     FCDdipProducts[Count].P_fBMtensileStrength:=StrToFloat( XMLProductItem.Attributes['tensilestr'], FCVdiFormat );
                     FCDdipProducts[Count].P_fBMtensileStrengthByDevLevel:=StrToFloat( XMLProductItem.Attributes['tsbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fBMyoungModulus:=StrToFloat( XMLProductItem.Attributes['youngmodulus'], FCVdiFormat );
                     FCDdipProducts[Count].P_fBMyoungModulusByDevLevel:=StrToFloat( XMLProductItem.Attributes['ymbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fBMthermalProtection:=StrToFloat( XMLProductItem.Attributes['thermalprot'], FCVdiFormat );
                     FCDdipProducts[Count].P_fBMreflectivity:=StrToFloat( XMLProductItem.Attributes['reflectivity'], FCVdiFormat );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), XMLProductItem.Attributes['corrosiveclass'] );
                     FCDdipProducts[Count].P_fBMcorrosiveClass:=TFCEdipCorrosiveClasses( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+XMLProductItem.Attributes['corrosiveclass'] );
                  end;

                  pfFood: FCDdipProducts[Count].P_fFpoints:=XMLProductItem.Attributes['foodpoint'];

                  pfInfrastructureKit:
                  begin
                     FCDdipProducts[Count].P_fIKtoken:=XMLProductItem.Attributes['infratoken'];
                     FCDdipProducts[Count].P_fIKlevel:=XMLProductItem.Attributes['infralevel'];
                  end;

                  pfManualConstruction: FCDdipProducts[Count].P_fManCwcpCoef:=StrToFloat( XMLProductItem.Attributes['wcpcoef'], FCVdiFormat );

                  pfMechanicalConstruction:
                  begin
                     FCDdipProducts[Count].P_fMechCwcpCoef:=StrToFloat( XMLProductItem.Attributes['wcp'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMechCcrew:=XMLProductItem.Attributes['crew'];
                  end;

                  pfMultipurposeMaterial:
                  begin
                     FCDdipProducts[Count].P_fMMtensileStrength:=StrToFloat( XMLProductItem.Attributes['tensilestr'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMMtensileStrengthByDevLevel:=StrToFloat( XMLProductItem.Attributes['tsbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMMyoungModulus:=StrToFloat( XMLProductItem.Attributes['youngmodulus'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMMyoungModulusByDevLevel:=StrToFloat( XMLProductItem.Attributes['ymbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMMthermalProtection:=StrToFloat( XMLProductItem.Attributes['thermalprot'], FCVdiFormat );
                     FCDdipProducts[Count].P_fMMreflectivity:=StrToFloat( XMLProductItem.Attributes['reflectivity'], FCVdiFormat );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), XMLProductItem.Attributes['corrosiveclass'] );
                     FCDdipProducts[Count].P_fMMcorrosiveClass:=TFCEdipCorrosiveClasses( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+XMLProductItem.Attributes['corrosiveclass'] );
                  end;

                  pfOxygen: FCDdipProducts[Count].P_fOpoints:=XMLProductItem.Attributes['oxypoint'];

                  pfSpaceMaterial:
                  begin
                     FCDdipProducts[Count].P_function:=pfSpaceMaterial;
                     FCDdipProducts[Count].P_fSMtensileStrength:=StrToFloat( XMLProductItem.Attributes['tensilestr'], FCVdiFormat );
                     FCDdipProducts[Count].P_fSMtensileStrengthByDevLevel:=StrToFloat( XMLProductItem.Attributes['tsbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fSMyoungModulus:=StrToFloat( XMLProductItem.Attributes['youngmodulus'], FCVdiFormat );
                     FCDdipProducts[Count].P_fSMyoungModulusByDevLevel:=StrToFloat( XMLProductItem.Attributes['ymbylevel'], FCVdiFormat );
                     FCDdipProducts[Count].P_fSMthermalProtection:=StrToFloat( XMLProductItem.Attributes['thermalprot'], FCVdiFormat );
                     FCDdipProducts[Count].P_fSMreflectivity:=StrToFloat( XMLProductItem.Attributes['reflectivity'], FCVdiFormat );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdipCorrosiveClasses ), XMLProductItem.Attributes['corrosiveclass'] );
                     FCDdipProducts[Count].P_fSMcorrosiveClass:=TFCEdipCorrosiveClasses( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad corrosive class: '+XMLProductItem.Attributes['corrosiveclass'] );
                  end;

                  pfWater: FCDdipProducts[Count].P_fWpoints:=XMLProductItem.Attributes['waterpoint'];
               end; //==END== case FCDBProducts[DBPRcnt].PROD_function of ==//
            end //==END== if DBPRsub.NodeName='function' ==//
            else if XMLProductItem.NodeName='tags' then
            begin
               XMLProductItemSub:=XMLProductItem.ChildNodes.First;
               while XMLProductItemSub<>nil do
               begin
                  FCDdipProducts[Count].P_tagEnvironmentalHazard:=false;
                  FCDdipProducts[Count].P_tagFireHazard:=false;
                  FCDdipProducts[Count].P_tagRadiationsHazard:=false;
                  FCDdipProducts[Count].P_tagToxicHazard:=false;
                  if XMLProductItemSub.NodeName='hazEnv'
                  then FCDdipProducts[Count].P_tagEnvironmentalHazard:=true
                  else if XMLProductItemSub.NodeName='hazFire'
                  then FCDdipProducts[Count].P_tagFireHazard:=true
                  else if XMLProductItemSub.NodeName='hazRad'
                  then FCDdipProducts[Count].P_tagRadiationsHazard:=true
                  else if XMLProductItemSub.NodeName='hazToxic'
                  then FCDdipProducts[Count].P_tagToxicHazard:=true;
                  XMLProductItemSub:=XMLProductItemSub.NextSibling;
               end; {.while DBPRtag<>nil}
            end; //==END== if DBPRsub.NodeName='tags' ==//
            XMLProductItem:= XMLProductItem.NextSibling;
         end; //==END== while DBPRsub<>nil ==//
      end; //==END== if DBPRnode.NodeName<>'#comment' ==//
		XMLProduct:=XMLProduct.NextSibling;
	end; //==END== while (DBPRnode<>nil) and (DBPRnode.NodeName<>'#comment') do ==//
end;

procedure FCMdF_DBSpaceUnits_Load;
{:Purpose: load the databases XML files concerning space units (internal structures and designs).
    Additions:
      -2012Aug01- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (x)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2010Apr10- *add: design capabilities.
      -2009Sep13- *fix final setlength.
}
   var
      Count
      ,Count1
      ,EnumIndex: integer;

      XMLSpaceUnit: IXMLNode;
begin
   {.clear the data structures}
   FCDdsuInternalStructures:=nil;
   FCDdsuSpaceUnitDesigns:=nil;
   SetLength( FCDdsuInternalStructures, 1 );
   SetLength( FCDdsuSpaceUnitDesigns, 1 );
   Count:=1;
   {.INTERNAL STRUCTURES}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVdiPathXML+'\env\scintstrucdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   XMLSpaceUnit:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while XMLSpaceUnit<>nil do
   begin
      SetLength( FCDdsuInternalStructures, Count+1 );
      if XMLSpaceUnit.NodeName<>'#comment' then
      begin
         FCDdsuInternalStructures[Count].IS_token:=XMLSpaceUnit.Attributes['token'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdsuInternalStructureShapes ), XMLSpaceUnit.Attributes['shape'] );
         FCDdsuInternalStructures[Count].IS_shape:=TFCEdsuInternalStructureShapes( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad scintstrucdb loading w/ shape: '+XMLSpaceUnit.Attributes['shape'] );
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdsuArchitectures ), XMLSpaceUnit.Attributes['archtp'] );
         FCDdsuInternalStructures[Count].IS_architecture:=TFCEdsuArchitectures( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad scintstrucdb loading w/ architecture type: '+XMLSpaceUnit.Attributes['archtp'] );
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdsuControlModules ), XMLSpaceUnit.Attributes['ctlmdl'] );
         FCDdsuInternalStructures[Count].IS_controlModuleAllowed:=TFCEdsuControlModules( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad internal structure allowed control module: '+XMLSpaceUnit.Attributes['ctlmdl'] );
         FCDdsuInternalStructures[Count].IS_length:=StrToFloat( XMLSpaceUnit.Attributes['length'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_wingspan:=StrToFloat( XMLSpaceUnit.Attributes['wgspan'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_height:=StrToFloat( XMLSpaceUnit.Attributes['height'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_availableVolume:=StrToFloat( XMLSpaceUnit.Attributes['availvol'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_availableSurface:=StrToFloat( XMLSpaceUnit.Attributes['availsur'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_spaceDriveMaxVolume:=StrToFloat( XMLSpaceUnit.Attributes['spdrvmaxvol'], FCVdiFormat );
         FCDdsuInternalStructures[Count].IS_spaceDriveMaxSurface:=StrToFloat( XMLSpaceUnit.Attributes['spdrvmaxsur'], FCVdiFormat );
         inc(Count);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      XMLSpaceUnit:= XMLSpaceUnit.NextSibling;
   end; {.while DBSCRnode<>nil}
   FCWinMain.FCXMLdbSCraft.Active:=false;
   Count:=1;
   {.DESIGNS}
   {.read the document}
   FCWinMain.FCXMLdbSCraft.FileName:=FCVdiPathXML+'\env\scdesignsdb.xml';
   FCWinMain.FCXMLdbSCraft.Active:=true;
   XMLSpaceUnit:= FCWinMain.FCXMLdbSCraft.DocumentElement.ChildNodes.First;
   while XMLSpaceUnit<>nil do
   begin
      SetLength( FCDdsuSpaceUnitDesigns, Count+1 );
      if XMLSpaceUnit.NodeName<>'#comment' then
      begin
         FCDdsuSpaceUnitDesigns[Count].SUD_token:=XMLSpaceUnit.Attributes['token'];
         Count1:=1;
         while Count1<=Length( FCDdsuInternalStructures )-1 do
         begin
            if FCDdsuInternalStructures[Count1].IS_token=XMLSpaceUnit.Attributes['intstrtoken'] then
            begin
               FCDdsuSpaceUnitDesigns[Count].SUD_internalStructureClone:=FCDdsuInternalStructures[Count1];
               Break;
            end;
            inc(Count1);
         end;
         FCDdsuSpaceUnitDesigns[Count].SUD_usedVolume:=StrToFloat( XMLSpaceUnit.Attributes['usedvol'], FCVdiFormat );
         FCDdsuSpaceUnitDesigns[Count].SUD_usedSurface:=StrToFloat( XMLSpaceUnit.Attributes['usedsurf'], FCVdiFormat );
         FCDdsuSpaceUnitDesigns[Count].SUD_massEmpty:=StrToFloat( XMLSpaceUnit.Attributes['massempty'], FCVdiFormat );
         FCDdsuSpaceUnitDesigns[Count].SUD_spaceDriveISP:=XMLSpaceUnit.Attributes['spdrvISP'];
         FCDdsuSpaceUnitDesigns[Count].SUD_spaceDriveReactionMassMaxVolume:=StrToFloat( XMLSpaceUnit.Attributes['spdrvRMmax'], FCVdiFormat );
         FCDdsuSpaceUnitDesigns[Count].SUD_capabilityInterstellarTransit:=XMLSpaceUnit.Attributes['capInter'];
         FCDdsuSpaceUnitDesigns[Count].SUD_capabilityColonization:=XMLSpaceUnit.Attributes['capColon'];
         FCDdsuSpaceUnitDesigns[Count].SUD_capabilityPassengers:=XMLSpaceUnit.Attributes['capPassgr'];
         FCDdsuSpaceUnitDesigns[Count].SUD_capabilityCombat:=XMLSpaceUnit.Attributes['capCombt'];
         inc(Count);
      end; {.if DBSCRnode.NodeName<>'#comment'}
      XMLSpaceUnit := XMLSpaceUnit.NextSibling;
   end; {.while DBSCRnode<>nil}
   FCWinMain.FCXMLdbSCraft.Active:=false;
end;

procedure FCMdF_DBSPMitems_Load;
{:Purpose: load SPM items database XML file.
    Additions:
      -2012Aug02- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
   var
      Count
      ,EnumIndex
      ,Count1: Integer;

      XMLSPMitem
      ,XMLSPMitemSub
      ,XMLSPMitemSubSub: IXMLNode;
begin
   SetLength( FCDBdgSPMi, 1 );
   Count:=0;
	{.read the document}
	FCWinMain.FCXMLdbSPMi.FileName:=FCVdiPathXML+'\env\spmdb.xml';
	FCWinMain.FCXMLdbSPMi.Active:=true;
	XMLSPMitem:= FCWinMain.FCXMLdbSPMi.DocumentElement.ChildNodes.First;
	while XMLSPMitem<>nil do
	begin
      if XMLSPMitem.NodeName<>'#comment' then
      begin
         inc( Count );
         SetLength( FCDBdgSPMi, Count+1 );
         SetLength( FCDBdgSPMi[Count].SPMI_req, 1 );
         SetLength( FCDBdgSPMi[Count].SPMI_infl, 1 );
         SetLength( FCDBdgSPMi[Count].SPMI_customFxList, 1 );
         FCDBdgSPMi[Count].SPMI_token:=XMLSPMitem.Attributes['token'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMarea ), XMLSPMitem.Attributes['area'] );
         FCDBdgSPMi[Count].SPMI_area:=TFCEdgSPMarea( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad spm item area: '+XMLSPMitem.Attributes['area'] );
         FCDBdgSPMi[Count].SPMI_isUnique2set:=XMLSPMitem.Attributes['isunique'];
         FCDBdgSPMi[Count].SPMI_isPolicy:=XMLSPMitem.Attributes['ispolicy'];
         {.SPMi sub data}
         XMLSPMitemSub:=XMLSPMitem.ChildNodes.First;
         while XMLSPMitemSub<>nil do
         begin
            {.SPMi modifiers}
            if XMLSPMitemSub.NodeName='spmmod' then
            begin
               FCDBdgSPMi[Count].SPMI_modCohes:=XMLSPMitemSub.Attributes['mcohes'];
               FCDBdgSPMi[Count].SPMI_modTens:=XMLSPMitemSub.Attributes['mtens'];
               FCDBdgSPMi[Count].SPMI_modSec:=XMLSPMitemSub.Attributes['msec'];
               FCDBdgSPMi[Count].SPMI_modEdu:=XMLSPMitemSub.Attributes['medu'];
               FCDBdgSPMi[Count].SPMI_modNat:=XMLSPMitemSub.Attributes['mnat'];
               FCDBdgSPMi[Count].SPMI_modHeal:=XMLSPMitemSub.Attributes['mhealth'];
               FCDBdgSPMi[Count].SPMI_modBur:=XMLSPMitemSub.Attributes['mbur'];
               FCDBdgSPMi[Count].SPMI_modCorr:=XMLSPMitemSub.Attributes['mcorr'];
            end
            {.SPMI requirements}
            else if XMLSPMitemSub.NodeName='spmreq' then
            begin
               XMLSPMitemSubSub:=XMLSPMitemSub.ChildNodes.First;
               Count1:=0;
               while XMLSPMitemSubSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDBdgSPMi[Count].SPMI_req, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReq ), XMLSPMitemSubSub.Attributes['token'] );
                  FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_type:=TFCEdgSPMiReq( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad spm item requirement type: '+XMLSPMitemSubSub.Attributes['token'] );
                  case FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_type of
                     dgBuilding:
                     begin
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_infToken:=XMLSPMitemSubSub.Attributes['buildtoken'];
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_percCol:=XMLSPMitemSubSub.Attributes['buildperc'];
                     end;

                     dgFacData:
                     begin
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReqFDat ), XMLSPMitemSubSub.Attributes['fdatType'] );
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_datTp:=TFCEdgSPMiReqFDat( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad spm item requirement-faction data: '+XMLSPMitemSubSub.Attributes['fdatType'] );
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_datValue:=XMLSPMitemSubSub.Attributes['fdatValue'];
                     end;

                     dgTechSci:
                     begin
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_tsToken:=XMLSPMitemSubSub.Attributes['tstoken'];
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_masterLvl:=XMLSPMitemSubSub.Attributes['tsmastlvl'];
                     end;

                     dgUC:
                     begin
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReqUC ), XMLSPMitemSubSub.Attributes['ucmethod'] );
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_ucMethod:=TFCEdgSPMiReqUC( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad spm item requirement-UC method: '+XMLSPMitemSubSub.Attributes['ucmethod'] );
                        FCDBdgSPMi[Count].SPMI_req[Count1].SPMIR_ucVal:=StrToFloat( XMLSPMitemSubSub.Attributes['ucval'], FCVdiFormat );
                     end;
                  end;
                  XMLSPMitemSubSub:=XMLSPMitemSubSub.NextSibling;
               end; //==END== while DBSPMIreq<>nil do ==//
            end //==END== else if DBSPMIitmSub.NodeName='spmreq' ==//
            {.HeadQuarter data}
            else if XMLSPMitemSub.NodeName='spmHQ' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMhqStr ), XMLSPMitemSub.Attributes['hqstruc'] );
               FCDBdgSPMi[Count].SPMI_hqStruc:=TFCEdgSPMhqStr( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad spm item HQ: '+XMLSPMitemSub.Attributes['hqstruc'] );
               FCDBdgSPMi[Count].SPMI_hqRTM:=XMLSPMitemSub.Attributes['hqrtm'];
            end
            {.custom effects}
            else if XMLSPMitemSub.NodeName='spmfx' then
            begin
               XMLSPMitemSubSub:=XMLSPMitemSub.ChildNodes.First;
               Count1:=0;
               while XMLSPMitemSubSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDBdgSPMi[Count].SPMI_customFxList, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEdgCustomFX ), XMLSPMitemSubSub.Attributes['code'] );
                  FCDBdgSPMi[Count].SPMI_customFxList[Count1].CFX_code:=TFCEdgCustomFX( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad spm item custom effect: '+XMLSPMitemSubSub.Attributes['code'] );
                  case FCDBdgSPMi[Count].SPMI_customFxList[Count1].CFX_code of
                     cfxEIOUT:
                     begin
                        FCDBdgSPMi[Count].SPMI_customFxList[Count1].CFX_eioutMod:=XMLSPMitemSubSub.Attributes['modifier'];
                        FCDBdgSPMi[Count].SPMI_customFxList[Count1].CFX_eioutIsBurMod:=XMLSPMitemSubSub.Attributes['isburmod'];
                     end;

                     cfxREVTX: FCDBdgSPMi[Count].SPMI_customFxList[Count1].CFX_revtxCoef:=StrToFloat( XMLSPMitemSubSub.Attributes['coef'], FCVdiFormat );
                  end;
                  XMLSPMitemSubSub:=XMLSPMitemSubSub.NextSibling;
               end;
            end
            {.influence matrix}
            else if XMLSPMitemSub.NodeName='spminfluences' then
            begin
               XMLSPMitemSubSub:=XMLSPMitemSub.ChildNodes.First;
               Count1:=0;
               while XMLSPMitemSubSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDBdgSPMi[Count].SPMI_infl, Count1+1 );
                  FCDBdgSPMi[Count].SPMI_infl[Count1].SPMII_token:=XMLSPMitemSubSub.Attributes['vstoken'];
                  FCDBdgSPMi[Count].SPMI_infl[Count1].SPMII_influence:=XMLSPMitemSubSub.Attributes['vsmod'];
                  XMLSPMitemSubSub:=XMLSPMitemSubSub.NextSibling;
               end; //==END== while DBSPMIinfl<>nil do ==//
            end;
            XMLSPMitemSub:=XMLSPMitemSub.NextSibling;
         end; //==END== while DBSPMIitmSub<>nil do ==//
      end; //==END== if DBSPMIitm.NodeName<>'#comment' ==//
      XMLSPMitem:= XMLSPMitem.NextSibling;
	end;{.while DBSPMIitm<>nil}
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
                           FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_angle1stDay:=FCFcFunc_Rnd(
                              cfrttp2dec
                              ,FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriodInit*360/FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_revolutionPeriod
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
                                 FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_angle1stDay:=FCFcFunc_Rnd(
                                    cfrttp2dec
                                    ,FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriodInit*360/FCDduStarSystem[DBSSPstarSysCnt].SS_stars[DBSSPstarCnt].S_orbitalObjects[DBSSPorbObjCnt].OO_satellitesList[DBSSPsatCnt].OO_revolutionPeriod);
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
