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
   ,TypInfo
   ,XMLIntf;

///<summary>
///   list of switch for FCMdF_DBStarSystems_Load
///</summary>
type TFCEdfStarSystemLoadingModes=(
   sslmLoadAllWithoutOrbitalObjects
   ,sslmLoadOrbitalObjectOfAStar
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
///   split the load of planetary system, from FCMdF_DBStarSystems_Load, into this routine
///</summary>
///   <param name="StarSystemToken">token of the corresponding star system</param>
///   <param name="StarToken">token of the corresponding star</param>
///   <remarks></remarks>
procedure FCMdF_DBStarOrbitalObjects_Load( const StarSystemToken, StarToken: string );

///<summary>
///   load the universe database XML file
///</summary>
procedure FCMdF_DBStarSystems_Load;

/////<summary>
/////   load the technosciences database
/////</summary>
//procedure FCMdF_DBTechnosciences_Load;

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
   ,farc_data_spm
   ,farc_data_spu
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_cpsobjectives
   ,farc_main
   ,farc_univ_func
   ,farc_win_debug;

type
      Enumeration=( diNotDocked, diMotherVessel, diDockedVessel );

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
      -2012Sep18- *add: override rules state.
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
      FCVdgPlayer.P_gameName:=XMLConfiguration.Attributes['gname'];
      if mustLoadCurrentGameTime then
      begin
         FCVdgPlayer.P_currentTimeTick:=XMLConfiguration.Attributes['tfTick'];
         FCVdgPlayer.P_currentTimeMinut:=XMLConfiguration.Attributes['tfMin'];
         FCVdgPlayer.P_currentTimeHour:=XMLConfiguration.Attributes['tfHr'];
         FCVdgPlayer.P_currentTimeDay:=XMLConfiguration.Attributes['tfDay'];
         FCVdgPlayer.P_currentTimeMonth:=XMLConfiguration.Attributes['tfMth'];
         FCVdgPlayer.P_currentTimeYear:=XMLConfiguration.Attributes['tfYr'];
      end;
   end;
   {.read the debug info}
	XMLConfiguration:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('debug');
	if XMLConfiguration<>nil then
   begin
      FCVdiDebugMode:=XMLConfiguration.Attributes['dswitch'];
      FCVdiOverrideRules:=XMLConfiguration.Attributes['overriderules'];
   end;
	FCWinMain.FCXMLcfg.Active:=false;
	FCWinMain.FCXMLcfg.FileName:='';
end;

procedure FCMdF_ConfigurationFile_Save(const mustSaveCurrentGameTime:boolean);
{:Purpose: save the configuration data in the XML configuration file.
   Additions:
      -2012Sep18- *add: override rules state.
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
      if FCVdgPlayer.P_gameName<>'' then
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
      XMLConfigurationItem.Attributes['cfacX']:=0;
      XMLConfigurationItem.Attributes['cfacY']:=0;
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
	XMLConfigurationItem.Attributes['gname']:=FCVdgPlayer.P_gameName;
   if ( mustSaveCurrentGameTime )
      and ( FCVdgPlayer.P_gameName<>'' ) then
   begin
      XMLConfigurationItem.Attributes['tfTick']:= FCVdgPlayer.P_currentTimeTick;
      XMLConfigurationItem.Attributes['tfMin']:= FCVdgPlayer.P_currentTimeMinut;
      XMLConfigurationItem.Attributes['tfHr']:= FCVdgPlayer.P_currentTimeHour;
      XMLConfigurationItem.Attributes['tfDay']:= FCVdgPlayer.P_currentTimeDay;
      XMLConfigurationItem.Attributes['tfMth']:= FCVdgPlayer.P_currentTimeMonth;
      XMLConfigurationItem.Attributes['tfYr']:= FCVdgPlayer.P_currentTimeYear;
   end
   else if ( mustSaveCurrentGameTime )
      and ( FCVdgPlayer.P_gameName='' ) then
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
   XMLConfigurationItem.Attributes['overriderules']:=FCVdiOverrideRules;
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
	while FactionCount<=Length( FCDdgFactions )-1 do
	begin
		FCDdgFactions[FactionCount]:=FCDdgFactions[0];
      setlength( FCDdgFactions[FactionCount].F_colonizationModes, 0 );
      setlength( FCDdgFactions[FactionCount].F_startingLocations, 0 );
      setlength( FCDdgFactions[FactionCount].F_spm, 0 );
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
         setlength( FCDdgFactions[FactionCount].F_colonizationModes, 1 );
         setlength( FCDdgFactions[FactionCount].F_startingLocations, 1 );
         setlength( FCDdgFactions[FactionCount].F_spm, 1 );
         FCDdgFactions[FactionCount].F_token:=XMLFaction.Attributes[ 'token' ];
         FCDdgFactions[FactionCount].F_level:=XMLFaction.Attributes[ 'level' ];
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
               SetLength( FCDdgFactions[FactionCount].F_colonizationModes, ColonizationModeCount+1 );
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_token:=XMLFactionItem.Attributes['token'];
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityThreshold_Economic:=XMLFactionItem.Attributes['viabThrEco'];
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityThreshold_Social:=XMLFactionItem.Attributes['viabThrSoc'];
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityThreshold_SpaceMilitary:=XMLFactionItem.Attributes['viabThrSpMil'];
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdgCreditInterestRanges ), XMLFactionItem.Attributes['creditrng'] );
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsCreditRange:=TFCEdgCreditInterestRanges( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad faction XML loading w/ colonization mode credit range: '+XMLFactionItem.Attributes['creditrng'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdgCreditInterestRanges ), XMLFactionItem.Attributes['intrng'] );
               FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsInterestRange:=TFCEdgCreditInterestRanges( EnumIndex );
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
                     SetLength( FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityObjectives, Count2+1 );
                     {.viability type}
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEcpsoObjectiveTypes ), XMLFactionSubItem.Attributes['objTp'] );
                     FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityObjectives[Count2].FVO_objTp:=TFCEcpsoObjectiveTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad faction viability objective: '+XMLFactionSubItem.Attributes['objTp'] );
                     if FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityObjectives[Count2].FVO_objTp=otEcoIndustrialForce then
                     begin
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityObjectives[Count2].FVO_ifProduct:=XMLFactionSubItem.Attributes['product'];
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_cpsViabilityObjectives[Count2].FVO_ifThreshold:=StrToFloat( XMLFactionSubItem.Attributes['threshold'], FCVdiFormat );
                     end;
                  end
                  {.equipment items list}
                  else if XMLFactionSubItem.NodeName='facEqupItm' then
                  begin
                     inc(Count1);
                     SetLength( FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList, Count1+1 );
                     if XMLFactionSubItem.Attributes['itemTp']='feitProduct' then
                     begin
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_equipmentItem:=feitProduct;
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiProdToken:=XMLFactionSubItem.Attributes['prodToken'];
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiProdUnit:=XMLFactionSubItem.Attributes['unit'];
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiProdCarriedBy:=XMLFactionSubItem.Attributes['carriedBy'];
                     end
                     {.space unit}
                     else if XMLFactionSubItem.Attributes['itemTp']='feitSpaceCraft' then
                     begin
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_equipmentItem:=feitSpaceUnit;
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiSUnNameToken:=XMLFactionSubItem.Attributes['properName'];
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiSUnDesignToken:=XMLFactionSubItem.Attributes['designToken'];
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSpaceUnitStatus ), XMLFactionSubItem.Attributes['status'] );
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiSUnStatus:=TFCEdgSpaceUnitStatus( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad faction equipment item loading w/ space unit status: '+XMLFactionSubItem.Attributes['status'] );
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiSUnDockStatus:=XMLFactionSubItem.Attributes['spuDock'];
                        FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList[Count1].EL_eiSUnReactionMass:=StrToFloat( XMLFactionSubItem.Attributes['availEnRM'], FCVdiFormat );
                     end;
                  end;
                  XMLFactionSubItem:=XMLFactionSubItem.NextSibling;
               end; //==END== while DBFRfacDotItm<>nil ==//
               SetLength( FCDdgFactions[FactionCount].F_colonizationModes[ColonizationModeCount].CM_equipmentList, Count1+1 );
            end //==END== else if DBFRfacSubItem.NodeName='facColMode' ==//
            {.starting location}
            else if XMLFactionItem.NodeName='facStartLoc' then
            begin
               inc( StartingLocations );
               SetLength( FCDdgFactions[FactionCount].F_startingLocations, StartingLocations+1 );
               FCDdgFactions[FactionCount].F_startingLocations[StartingLocations].SL_stellarSystem:=XMLFactionItem.Attributes['locSSys'];
               FCDdgFactions[FactionCount].F_startingLocations[StartingLocations].SL_star:=XMLFactionItem.Attributes['locStar'];
               FCDdgFactions[FactionCount].F_startingLocations[StartingLocations].SL_orbitalObject:=XMLFactionItem.Attributes['locObObj'];
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
                  SetLength( FCDdgFactions[FactionCount].F_spm, Count1+1 );
                  FCDdgFactions[FactionCount].F_spm[Count1].SPMS_token:=XMLFactionSubItem.Attributes['token'];
                  FCDdgFactions[FactionCount].F_spm[Count1].SPMS_duration:=XMLFactionSubItem.Attributes['duration'];
                  FCDdgFactions[FactionCount].F_spm[Count1].SPMS_isPolicy:=true;
                  FCDdgFactions[FactionCount].F_spm[Count1].SPMS_iPtIsSet:=XMLFactionSubItem.Attributes['isSet'];
                  FCDdgFactions[FactionCount].F_spm[Count1].SPMS_iPtAcceptanceProbability:=XMLFactionSubItem.Attributes['aprob'];
                  if FCDdgFactions[FactionCount].F_spm[Count1].SPMS_iPtAcceptanceProbability=-2 then
                  begin
                     FCDdgFactions[FactionCount].F_spm[Count1].SPMS_isPolicy:=false;
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdgBeliefLevels ), XMLFactionSubItem.Attributes['belieflev'] );
                     FCDdgFactions[FactionCount].F_spm[Count1].SPMS_iPfBeliefLevel:=TFCEdgBeliefLevels( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad faction XML loading w/ meme belief level: '+XMLFactionSubItem.Attributes['belieflev'] );
                     FCDdgFactions[FactionCount].F_spm[Count1].SPMS_iPfSpreadValue:=XMLFactionSubItem.Attributes['spreadval'];
                  end;
                  XMLFactionSubItem:=XMLFactionSubItem.NextSibling;
               end; //==END== while DBFRspmItm<>nil ==//
            end;
            XMLFactionItem:= XMLFactionItem.NextSibling;
         end; //==END== while DBFRfacSubItem<>nil ==//
         {.resize to real table size}
         SetLength( FCDdgFactions[FactionCount].F_colonizationModes, ColonizationModeCount+1 );
         SetLength( FCDdgFactions[FactionCount].F_startingLocations, StartingLocations+1 ) ;
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
      -2013Jan13- *add: new functions: Survey-Air, Survey-Antigrav, Survey-Ground, Survey-Space and Survey-Swarm Antigrav.
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

                  pfManpowerConstruction: FCDdipProducts[Count].P_fManCwcpCoef:=StrToFloat( XMLProductItem.Attributes['wcpcoef'], FCVdiFormat );

                  pfMechanizedConstruction:
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

                  pfSurveyAir, pfSurveyAntigrav, pfSurveyGround, pfSurveySpace, pfSurveySwarmAntigrav:
                  begin
                     FCDdipProducts[Count].P_fSspeed:=XMLProductItem.Attributes['speed'];
                     FCDdipProducts[Count].P_fSmissionTime:=XMLProductItem.Attributes['missionTime'];
                     FCDdipProducts[Count].P_fScapabilityResources:=XMLProductItem.Attributes['capabResources'];
                     FCDdipProducts[Count].P_fScapabilityBiosphere:=XMLProductItem.Attributes['capabBiosphere'];
                     FCDdipProducts[Count].P_fScapabilityFeaturesArtifacts:=XMLProductItem.Attributes['capabFeaturesArtifacts'];
                     FCDdipProducts[Count].P_fScrew:=XMLProductItem.Attributes['crew'];
                     FCDdipProducts[Count].P_fSvehicles:=XMLProductItem.Attributes['vehicles'];
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
   SetLength( FCDdgSPMi, 1 );
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
         SetLength( FCDdgSPMi, Count+1 );
         SetLength( FCDdgSPMi[Count].SPMI_req, 1 );
         SetLength( FCDdgSPMi[Count].SPMI_infl, 1 );
         SetLength( FCDdgSPMi[Count].SPMI_customFxList, 1 );
         FCDdgSPMi[Count].SPMI_token:=XMLSPMitem.Attributes['token'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMarea ), XMLSPMitem.Attributes['area'] );
         FCDdgSPMi[Count].SPMI_area:=TFCEdgSPMarea( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad spm item area: '+XMLSPMitem.Attributes['area'] );
         FCDdgSPMi[Count].SPMI_isUnique2set:=XMLSPMitem.Attributes['isunique'];
         FCDdgSPMi[Count].SPMI_isPolicy:=XMLSPMitem.Attributes['ispolicy'];
         {.SPMi sub data}
         XMLSPMitemSub:=XMLSPMitem.ChildNodes.First;
         while XMLSPMitemSub<>nil do
         begin
            {.SPMi modifiers}
            if XMLSPMitemSub.NodeName='spmmod' then
            begin
               FCDdgSPMi[Count].SPMI_modCohes:=XMLSPMitemSub.Attributes['mcohes'];
               FCDdgSPMi[Count].SPMI_modTens:=XMLSPMitemSub.Attributes['mtens'];
               FCDdgSPMi[Count].SPMI_modSec:=XMLSPMitemSub.Attributes['msec'];
               FCDdgSPMi[Count].SPMI_modEdu:=XMLSPMitemSub.Attributes['medu'];
               FCDdgSPMi[Count].SPMI_modNat:=XMLSPMitemSub.Attributes['mnat'];
               FCDdgSPMi[Count].SPMI_modHeal:=XMLSPMitemSub.Attributes['mhealth'];
               FCDdgSPMi[Count].SPMI_modBur:=XMLSPMitemSub.Attributes['mbur'];
               FCDdgSPMi[Count].SPMI_modCorr:=XMLSPMitemSub.Attributes['mcorr'];
            end
            {.SPMI requirements}
            else if XMLSPMitemSub.NodeName='spmreq' then
            begin
               XMLSPMitemSubSub:=XMLSPMitemSub.ChildNodes.First;
               Count1:=0;
               while XMLSPMitemSubSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDdgSPMi[Count].SPMI_req, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReq ), XMLSPMitemSubSub.Attributes['token'] );
                  FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_type:=TFCEdgSPMiReq( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad spm item requirement type: '+XMLSPMitemSubSub.Attributes['token'] );
                  case FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_type of
                     dgBuilding:
                     begin
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_infToken:=XMLSPMitemSubSub.Attributes['buildtoken'];
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_percCol:=XMLSPMitemSubSub.Attributes['buildperc'];
                     end;

                     dgFacData:
                     begin
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReqFDat ), XMLSPMitemSubSub.Attributes['fdatType'] );
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_datTp:=TFCEdgSPMiReqFDat( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad spm item requirement-faction data: '+XMLSPMitemSubSub.Attributes['fdatType'] );
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_datValue:=XMLSPMitemSubSub.Attributes['fdatValue'];
                     end;

                     dgTechSci:
                     begin
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_tsToken:=XMLSPMitemSubSub.Attributes['tstoken'];
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_masterLvl:=XMLSPMitemSubSub.Attributes['tsmastlvl'];
                     end;

                     dgUC:
                     begin
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiReqUC ), XMLSPMitemSubSub.Attributes['ucmethod'] );
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_ucMethod:=TFCEdgSPMiReqUC( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad spm item requirement-UC method: '+XMLSPMitemSubSub.Attributes['ucmethod'] );
                        FCDdgSPMi[Count].SPMI_req[Count1].SPMIR_ucVal:=StrToFloat( XMLSPMitemSubSub.Attributes['ucval'], FCVdiFormat );
                     end;
                  end;
                  XMLSPMitemSubSub:=XMLSPMitemSubSub.NextSibling;
               end; //==END== while DBSPMIreq<>nil do ==//
            end //==END== else if DBSPMIitmSub.NodeName='spmreq' ==//
            {.HeadQuarter data}
            else if XMLSPMitemSub.NodeName='spmHQ' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMhqStr ), XMLSPMitemSub.Attributes['hqstruc'] );
               FCDdgSPMi[Count].SPMI_hqStruc:=TFCEdgSPMhqStr( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad spm item HQ: '+XMLSPMitemSub.Attributes['hqstruc'] );
               FCDdgSPMi[Count].SPMI_hqRTM:=XMLSPMitemSub.Attributes['hqrtm'];
            end
            {.custom effects}
            else if XMLSPMitemSub.NodeName='spmfx' then
            begin
               XMLSPMitemSubSub:=XMLSPMitemSub.ChildNodes.First;
               Count1:=0;
               while XMLSPMitemSubSub<>nil do
               begin
                  inc( Count1 );
                  SetLength( FCDdgSPMi[Count].SPMI_customFxList, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSPMiCustomEffects ), XMLSPMitemSubSub.Attributes['code'] );
                  FCDdgSPMi[Count].SPMI_customFxList[Count1].CFX_code:=TFCEdgSPMiCustomEffects( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad spm item custom effect: '+XMLSPMitemSubSub.Attributes['code'] );
                  case FCDdgSPMi[Count].SPMI_customFxList[Count1].CFX_code of
                     sceEIOUT:
                     begin
                        FCDdgSPMi[Count].SPMI_customFxList[Count1].CFX_eioutMod:=XMLSPMitemSubSub.Attributes['modifier'];
                        FCDdgSPMi[Count].SPMI_customFxList[Count1].CFX_eioutIsBurMod:=XMLSPMitemSubSub.Attributes['isburmod'];
                     end;

                     sceREVTX: FCDdgSPMi[Count].SPMI_customFxList[Count1].CFX_revtxCoef:=StrToFloat( XMLSPMitemSubSub.Attributes['coef'], FCVdiFormat );
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
                  SetLength( FCDdgSPMi[Count].SPMI_infl, Count1+1 );
                  FCDdgSPMi[Count].SPMI_infl[Count1].SPMII_token:=XMLSPMitemSubSub.Attributes['vstoken'];
                  FCDdgSPMi[Count].SPMI_infl[Count1].SPMII_influence:=XMLSPMitemSubSub.Attributes['vsmod'];
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

procedure FCMdF_DBStarOrbitalObjects_Load( const StarSystemToken, StarToken: string );
{:Purpose: load the orbital objects, if there's any, of a specified star in the universe database XML file.
   Additions:
      -2013May05- *add: geosynchronous and low orbit.
      -2013May01- *add: tectonic activity.
      -2013Apr30- *mod: albedo is moved into the ecosphere data.
      -2013Mar04- *add: OO_regionSurface + OO_meanTravelDistance.
      -2013Jan13- *add/mod: expansion of the region's EMO modifiers.
      -2012Aug05- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (_)summary completion               (x)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012Aug05- *add: split the load of planetary system, from FCMdF_DBStarSystems_Load, into this routine.
}
   var
      XMLOObjSub1
      ,XMLOObjSub2
      ,XMLOrbitalObject
      ,XMSatellite
      ,XMLStar
      ,XMLStarSub
      ,XMLStarSystem: IXMLNode;

      Count1
      ,Count2
      ,EnumIndex
      ,OrbitalObjectCount
      ,SatelliteCount
      ,StarCount
      ,StarSystemCount: Integer;

      isStarFound: boolean;

      StarMatrix: TFCRufStelObj;
begin
   isStarFound:=false;
   StarMatrix:=FCFuF_StelObj_GetStarSystemStar( StarSystemToken, StarToken );
   StarSystemCount:=StarMatrix[1];
   StarCount:=StarMatrix[2];
   {.read the document}
   FCWinMain.FCXMLdbUniv.FileName:=FCVdiPathXML+'\univ\universe.xml';
   FCWinMain.FCXMLdbUniv.Active:=true;
   XMLStarSystem:= FCWinMain.FCXMLdbUniv.DocumentElement.ChildNodes.First;
   while not isStarFound do
   begin
      XMLStar:= XMLStarSystem.ChildNodes.First;
      while XMLStar<>nil do
      begin
         if XMLStar.Attributes['startoken']=StarToken then
         begin
            isStarFound:=true;
            break;
         end;
         XMLStar:=XMLStar.NextSibling;
      end;
      XMLStarSystem:=XMLStarSystem.NextSibling;
   end;
   OrbitalObjectCount:=0;
   XMLStarSub:= XMLStar.ChildNodes.First;
   while XMLStarSub<>nil do
   begin
      if XMLStarSub.NodeName='orbobj' then
      begin
         inc( OrbitalObjectCount );
         SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects, OrbitalObjectCount+1 );
         SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList, 1 );
         SatelliteCount:=0;
         FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_dbTokenId:=XMLStarSub.Attributes['ootoken'];
         FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isSatellite:=false;
         XMLOrbitalObject:= XMLStarSub.ChildNodes.First;
         while XMLOrbitalObject<>nil do
         begin
            if XMLOrbitalObject.NodeName='orbobjorbdata' then
            begin
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isNotSat_distanceFromStar:=StrToFloat( XMLOrbitalObject.Attributes['oodist'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isNotSat_eccentricity:=StrToFloat( XMLOrbitalObject.Attributes['ooecc'], FCVdiFormat );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduHabitableZones ), XMLOrbitalObject.Attributes['ooorbzne'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isNotSat_orbitalZone:=TFCEduHabitableZones(EnumIndex);
               if EnumIndex=-1
               then raise Exception.Create( 'bad orbital zone: '+XMLOrbitalObject.Attributes['ooorbzne'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_revolutionPeriod:=XMLOrbitalObject.Attributes['oorevol'];
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_revolutionPeriodInit:=XMLOrbitalObject.Attributes['oorevevinit'];
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_angle1stDay:=
                  FCFcF_Round(
                     rttCustom2Decimal
                     ,FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_revolutionPeriodInit*360
                        /FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_revolutionPeriod
                     );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_gravitationalSphereRadius:=StrToFloat( XMLOrbitalObject.Attributes['oogravsphrad'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_geosynchOrbit:=StrToFloat( XMLOrbitalObject.Attributes['orbitGeosync'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_lowOrbit:=StrToFloat( XMLOrbitalObject.Attributes['orbitLow'], FCVdiFormat );
            end //==END== if DBSSPorbObjNode.NodeName='orbobjorbdata' ==//
            else if XMLOrbitalObject.NodeName='orbperlist' then
            begin
               Count1:=0;
               XMLOObjSub1:=XMLOrbitalObject.ChildNodes.First;
               while XMLOObjSub1<>nil do
               begin
                  inc( Count1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalPeriodTypes ), XMLOObjSub1.Attributes['optype'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_orbitalPeriods[Count1].OOS_orbitalPeriodType:=TFCEduOrbitalPeriodTypes( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad universe orbital period type: '+XMLOObjSub1.Attributes['optype'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_orbitalPeriods[Count1].OOS_dayStart:=XMLOObjSub1.Attributes['opstrt'];
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_orbitalPeriods[Count1].OOS_dayEnd:=XMLOObjSub1.Attributes['opend'];
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_orbitalPeriods[Count1].OOS_meanTemperature:=StrToFloat( XMLOObjSub1.Attributes['opmtemp'], FCVdiFormat );
                  XMLOObjSub1:= XMLOObjSub1.NextSibling;
               end;
            end //==END== else if DBSSPorbObjNode.NodeName='orbperlist' ==//
            else if XMLOrbitalObject.NodeName='orbobjgeophysdata' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalObjectTypes ), XMLOrbitalObject.Attributes['ootype'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_type:=TFCEduOrbitalObjectTypes( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad orbital object type: '+XMLOrbitalObject.Attributes['ootype'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_diameter:=StrToFloat( XMLOrbitalObject.Attributes['oodiam'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_density:=XMLOrbitalObject.Attributes['oodens'];
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_mass:=StrToFloat( XMLOrbitalObject.Attributes['oomass'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_gravity:=StrToFloat( XMLOrbitalObject.Attributes['oograv'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_escapeVelocity:=StrToFloat( XMLOrbitalObject.Attributes['ooescvel'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isNotSat_rotationPeriod:=StrToFloat( XMLOrbitalObject.Attributes['oorotper'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_isNotSat_inclinationAxis:=StrToFloat( XMLOrbitalObject.Attributes['ooinclax'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_magneticField:=StrToFloat( XMLOrbitalObject.Attributes['oomagfld'], FCVdiFormat );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduTectonicActivity ), XMLOrbitalObject.Attributes['ootectonicactivity'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_tectonicActivity:=TFCEduTectonicActivity( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad orbital object tectonic activity: '+XMLOrbitalObject.Attributes['ootectonicactivity'] );
            end {.else if DBSSPorbObjNode.NodeName='orbobjgeophysdata'}
            else if XMLOrbitalObject.NodeName='orbobjecosdata' then
            begin
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduEnvironmentTypes ), XMLOrbitalObject.Attributes['ooenvtype'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_environment:=TFCEduEnvironmentTypes(EnumIndex);
               if EnumIndex=-1
               then raise Exception.Create( 'bad environment type: '+XMLOrbitalObject.Attributes['ooenvtype'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphericPressure:=StrToFloat( XMLOrbitalObject.Attributes['ooatmpres'], FCVdiFormat );;
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_cloudsCover:=StrToFloat( XMLOrbitalObject.Attributes['oocloudscov'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_primaryGasVolumePerc:=XMLOrbitalObject.Attributes['atmprimgasvol'];
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmH2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric H2 gas status: '+XMLOrbitalObject.Attributes['atmH2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmHe'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric He gas status: '+XMLOrbitalObject.Attributes['atmHe'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmCH4'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric CH4 gas status: '+XMLOrbitalObject.Attributes['atmCH4'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmNH3'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric NH3 gas status: '+XMLOrbitalObject.Attributes['atmNH3'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmH2O'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric H2O gas status: '+XMLOrbitalObject.Attributes['atmH2O'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmNe'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric Ne gas status: '+XMLOrbitalObject.Attributes['atmNe'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmN2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric N2 gas status: '+XMLOrbitalObject.Attributes['atmN2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmCO'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric CO gas status: '+XMLOrbitalObject.Attributes['atmCO'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmNO'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric NO gas status: '+XMLOrbitalObject.Attributes['atmNO'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmO2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric O2 gas status: '+XMLOrbitalObject.Attributes['atmO2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmH2S'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric H2S gas status: '+XMLOrbitalObject.Attributes['atmH2S'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmAr'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric Ar gas status: '+XMLOrbitalObject.Attributes['atmAr'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmCO2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric CO2 gas status: '+XMLOrbitalObject.Attributes['atmCO2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmNO2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric NO2 gas status: '+XMLOrbitalObject.Attributes['atmNO2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmO3'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric O3 gas status: '+XMLOrbitalObject.Attributes['atmO3'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMLOrbitalObject.Attributes['atmSO2'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object atmospheric SO2 gas status: '+XMLOrbitalObject.Attributes['atmSO2'] );
               EnumIndex:=GetEnumValue( TypeInfo( TFCEduHydrospheres ), XMLOrbitalObject.Attributes['hydroTp'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_hydrosphere:=TFCEduHydrospheres( EnumIndex );
               if EnumIndex=-1
               then raise Exception.Create( 'bad universe orbital object hydrosphere type: '+XMLOrbitalObject.Attributes['hydroTp'] );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_hydrosphereArea:=StrToFloat( XMLOrbitalObject.Attributes['hydroArea'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_albedo:=StrToFloat( XMLOrbitalObject.Attributes['ooalbe'], FCVdiFormat );
            end {.else if DBSSPorbObjNode.NodeName='orbobjecosdata'}
            else if XMLOrbitalObject.NodeName='orbobjregions' then
            begin
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regionSurface:=StrToFloat( XMLOrbitalObject.Attributes['surface'], FCVdiFormat );
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_meanTravelDistance:=XMLOrbitalObject.Attributes['mtd'];
               Count1:=1;
               XMLOObjSub1:=XMLOrbitalObject.ChildNodes.First;
               while XMLOObjSub1<>nil do
               begin
                  SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions, Count1+1 );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionSoilTypes ), XMLOObjSub1.Attributes['soiltp'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_soilType:=TFCEduRegionSoilTypes( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad universe region soil type: '+XMLOObjSub1.Attributes['soiltp'] );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionReliefs ), XMLOObjSub1.Attributes['relief'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_relief:=TFCEduRegionReliefs( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad universe region relief: '+XMLOObjSub1.Attributes['relief'] );
                  EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionClimates ), XMLOObjSub1.Attributes['climate'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_climate:=TFCEduRegionClimates( EnumIndex );
                  if EnumIndex=-1
                  then raise Exception.Create( 'bad universe region climate: '+XMLOObjSub1.Attributes['climate'] );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_meanTdMin:=StrToFloat( XMLOObjSub1.Attributes['mtdmin'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_meanTdInt:=StrToFloat( XMLOObjSub1.Attributes['mtdint'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_meanTdMax:=StrToFloat( XMLOObjSub1.Attributes['mtdmax'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_windSpeed:=StrToFloat( XMLOObjSub1.Attributes['wndspd'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_precipitation:=XMLOObjSub1.Attributes['precip'];
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_settlementEntity:=0;
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_settlementColony:=0;
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_settlementIndex:=0;
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyGround:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyG'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyAir:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyA'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyAntigrav:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyAG'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveySwarmAntigrav:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveySAG'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_cab:=StrToFloat( XMLOObjSub1.Attributes['emoCAB'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_iwc:=StrToFloat( XMLOObjSub1.Attributes['emoIWC'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_emo.EMO_groundCombat:=StrToFloat( XMLOObjSub1.Attributes['emoGroundCombat'], FCVdiFormat );
                  SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_resourceSpot, 1 );
                  Count2:=1;
                  XMLOObjSub2:=XMLOObjSub1.ChildNodes.First;
                  while XMLOObjSub2<>nil do
                  begin
                     SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_resourceSpot, Count2+1 );
                     EnumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotTypes), XMLOObjSub2.Attributes['type'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_type:=TFCEduResourceSpotTypes(EnumIndex);
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad resource spot type: '+XMLOObjSub2.Attributes['type'] );
                     EnumIndex:=GetEnumValue(TypeInfo(TFCEduResourceSpotQuality), XMLOObjSub2.Attributes['quality'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_quality:=TFCEduResourceSpotQuality(EnumIndex);
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad resource spot quality: '+XMLOObjSub2.Attributes['quality'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotRarity ), XMLOObjSub2.Attributes['rarity'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_rarity:=TFCEduResourceSpotRarity(EnumIndex);
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad resource spot rarity: '+XMLOObjSub2.Attributes['rarity'] );
                     inc(Count2);
                     XMLOObjSub2:=XMLOObjSub2.NextSibling;
                  end;
                  inc(Count1);
                  XMLOObjSub1:= XMLOObjSub1.NextSibling;
               end; //==END== while DBSSPregNode<>nil ==//
            end //==END== else if NodeName='orbobjregions' ==//
            else if XMLOrbitalObject.NodeName='satobj' then
            begin
               {.initialize satellite data}
               inc( SatelliteCount );
               SetLength(FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList, SatelliteCount+1);
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_dbTokenId:=XMLOrbitalObject.Attributes['sattoken'];
               FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_isSatellite:=true;
               XMSatellite:= XMLOrbitalObject.ChildNodes.First;
               while XMSatellite<>nil do
               begin
                  if XMSatellite.NodeName='satorbdata' then
                  begin
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_isSat_distanceFromPlanet:=StrToFloat( XMSatellite.Attributes['satdist'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_revolutionPeriod:=XMSatellite.Attributes['satrevol'];
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_revolutionPeriodInit:=XMSatellite.Attributes['satrevinit'];
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_angle1stDay:=
                        FCFcF_Round(
                           rttCustom2Decimal
                           ,FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_revolutionPeriodInit*360
                              /FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_revolutionPeriod
                           );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_gravitationalSphereRadius:=StrToFloat( XMSatellite.Attributes['satgravsphrad'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_geosynchOrbit:=StrToFloat( XMSatellite.Attributes['orbitGeosync'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_lowOrbit:=StrToFloat( XMSatellite.Attributes['orbitLow'], FCVdiFormat );
                  end
                  else if XMSatellite.NodeName='orbperlist' then
                  begin
                     Count1:=0;
                     XMLOObjSub1:=XMSatellite.ChildNodes.First;
                     while XMLOObjSub1<>nil do
                     begin
                        inc( Count1 );
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalPeriodTypes ), XMLOObjSub1.Attributes['optype'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_orbitalPeriods[Count1].OOS_orbitalPeriodType:=TFCEduOrbitalPeriodTypes( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad universe satellite orbital period: '+XMLOObjSub1.Attributes['optype'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_orbitalPeriods[Count1].OOS_dayStart:=XMLOObjSub1.Attributes['opstrt'];
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_orbitalPeriods[Count1].OOS_dayEnd:=XMLOObjSub1.Attributes['opend'];
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_orbitalPeriods[Count1].OOS_meanTemperature:=StrToFloat( XMLOObjSub1.Attributes['opmtemp'], FCVdiFormat );
                        XMLOObjSub1:= XMLOObjSub1.NextSibling;
                     end;
                  end //==END== else if DBSSPsatNode.NodeName='orbperlist' ==//
                  else if XMSatellite.NodeName='satgeophysdata' then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduOrbitalObjectTypes ), XMSatellite.Attributes['sattype'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_type:=TFCEduOrbitalObjectTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad (sat) orbital object type: '+XMSatellite.Attributes['sattype'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_diameter:=StrToFloat( XMSatellite.Attributes['satdiam'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_density:=XMSatellite.Attributes['satdens'];
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_mass:=StrToFloat( XMSatellite.Attributes['satmass'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_gravity:=StrToFloat( XMSatellite.Attributes['satgrav'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_escapeVelocity:=StrToFloat( XMSatellite.Attributes['satescvel'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_magneticField:=StrToFloat( XMSatellite.Attributes['satmagfld'], FCVdiFormat );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduTectonicActivity ), XMSatellite.Attributes['sattectonicactivity'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_tectonicActivity:=TFCEduTectonicActivity( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad (sat) orbital object type: '+XMSatellite.Attributes['sattectonicactivity'] );
                  end {.else if DBSSPsatNode.NodeName='satgeophysdata'}
                  else if XMSatellite.NodeName='satecosdata' then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduEnvironmentTypes ), XMSatellite.Attributes['satenvtype'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_environment:=TFCEduEnvironmentTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad (sat) environment type: '+XMSatellite.Attributes['satenvtype'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphericPressure:=StrToFloat( XMSatellite.Attributes['satatmpres'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_cloudsCover:=StrToFloat( XMSatellite.Attributes['satcloudscov'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_primaryGasVolumePerc:=XMSatellite.Attributes['atmprimgasvol'];
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmH2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric H2 gas status: '+XMSatellite.Attributes['atmH2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmHe'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric He gas status: '+XMSatellite.Attributes['atmHe'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmCH4'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric CH4 gas status: '+XMSatellite.Attributes['atmCH4'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmNH3'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric NH3 gas status: '+XMSatellite.Attributes['atmNH3'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmH2O'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric H2O gas status: '+XMSatellite.Attributes['atmH2O'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmNe'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric Ne gas status: '+XMSatellite.Attributes['atmNe'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmN2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric N2 gas status: '+XMSatellite.Attributes['atmN2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmCO'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric CO gas status: '+XMSatellite.Attributes['atmCO'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmNO'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric NO gas status: '+XMSatellite.Attributes['atmNO'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmO2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric O2 gas status: '+XMSatellite.Attributes['atmO2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmH2S'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric H2S gas status: '+XMSatellite.Attributes['atmH2S'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmAr'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric Ar gas status: '+XMSatellite.Attributes['atmAr'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmCO2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric CO2 gas status: '+XMSatellite.Attributes['atmCO2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmNO2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric NO2 gas status: '+XMSatellite.Attributes['atmNO2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmO3'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric O3 gas status: '+XMSatellite.Attributes['atmO3'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduAtmosphericGasStatus ), XMSatellite.Attributes['atmSO2'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe orbital object atmospheric SO2 gas status: '+XMSatellite.Attributes['atmSO2'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduHydrospheres ), XMSatellite.Attributes['hydroTp'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_hydrosphere:=TFCEduHydrospheres( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad universe satellite hydrosphere: '+XMSatellite.Attributes['hydroTp'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_hydrosphereArea:=StrToFloat( XMSatellite.Attributes['hydroArea'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_albedo:=StrToFloat( XMSatellite.Attributes['satalbe'], FCVdiFormat );
                  end {.else if DBSSPsatNode.NodeName='satecosdata'}
                  else if XMSatellite.NodeName='satregions' then
                  begin
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regionSurface:=StrToFloat( XMSatellite.Attributes['surface'], FCVdiFormat );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_meanTravelDistance:=XMSatellite.Attributes['mtd'];
                     Count1:=1;
                     XMLOObjSub1:=XMSatellite.ChildNodes.First;
                     while XMLOObjSub1<>nil do
                     begin
                        SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions, Count1+1 );
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionSoilTypes ), XMLOObjSub1.Attributes['soiltp'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_soilType:=TFCEduRegionSoilTypes( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad universe satellite region soil: '+XMLOObjSub1.Attributes['soiltp'] );
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionReliefs ), XMLOObjSub1.Attributes['relief'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_relief:=TFCEduRegionReliefs( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad universe satellite region relief: '+XMLOObjSub1.Attributes['relief'] );
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEduRegionClimates ), XMLOObjSub1.Attributes['climate'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_climate:=TFCEduRegionClimates( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad universe satellite region climate: '+XMLOObjSub1.Attributes['climate'] );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_meanTdMin:=StrToFloat( XMLOObjSub1.Attributes['mtdmin'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_meanTdInt:=StrToFloat( XMLOObjSub1.Attributes['mtdint'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_meanTdMax:=StrToFloat( XMLOObjSub1.Attributes['mtdmax'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_windSpeed:=StrToFloat( XMLOObjSub1.Attributes['wndspd'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_precipitation:=XMLOObjSub1.Attributes['precip'];
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_settlementEntity:=0;
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_settlementColony:=0;
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_settlementIndex:=0;
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyGround:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyG'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyAir:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyA'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveyAntigrav:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveyAG'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_planetarySurveySwarmAntigrav:=StrToFloat( XMLOObjSub1.Attributes['emoPlanSurveySAG'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_cab:=StrToFloat( XMLOObjSub1.Attributes['emoCAB'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_iwc:=StrToFloat( XMLOObjSub1.Attributes['emoIWC'], FCVdiFormat );
                        FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_emo.EMO_groundCombat:=StrToFloat( XMLOObjSub1.Attributes['emoGroundCombat'], FCVdiFormat );
                        SetLength(FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_resourceSpot, 1);
                        Count2:=1;
                        XMLOObjSub2:=XMLOObjSub1.ChildNodes.First;
                        while XMLOObjSub2<>nil do
                        begin
                           SetLength( FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_resourceSpot, Count2+1 );
                           EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotTypes ), XMLOObjSub2.Attributes['type'] );
                           FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_type:=TFCEduResourceSpotTypes(EnumIndex);
                           if EnumIndex=-1
                           then raise Exception.Create( 'bad resource spot type: '+XMLOObjSub2.Attributes['type'] );
                           EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotQuality ), XMLOObjSub2.Attributes['quality'] );
                           FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_quality:=TFCEduResourceSpotQuality(EnumIndex);
                           if EnumIndex=-1
                           then raise Exception.Create( 'bad resource spot quality: '+XMLOObjSub2.Attributes['quality'] );
                           EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotRarity ), XMLOObjSub2.Attributes['rarity'] );
                           FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_orbitalObjects[OrbitalObjectCount].OO_satellitesList[SatelliteCount].OO_regions[Count1].OOR_resourceSpot[Count2].RS_rarity:=TFCEduResourceSpotRarity(EnumIndex);
                           if EnumIndex=-1
                           then raise Exception.Create( 'bad resource spot rarity: '+XMLOObjSub2.Attributes['rarity'] );
                           inc( Count2 );
                           XMLOObjSub2:=XMLOObjSub2.NextSibling;
                        end;
                        inc( Count1 );
                        XMLOObjSub1:= XMLOObjSub1.NextSibling;
                     end; //==END== while DBSSPregNode<>nil ==//
                  end; //==END== else if DBSSPorbObjNode.NodeName='satregions' ==//
                  XMSatellite:= XMSatellite.NextSibling;
               end; {.while DBSSPsatNode<>nil}
            end; {.else if DBSSPorbObjNode.NodeName='satobj'}
            XMLOrbitalObject:= XMLOrbitalObject.NextSibling;
         end; {.while DBSSPorbObjNode<>nil}
      end; {.else if DBSSPstarSubNode.NodeName='orbobj'}
      XMLStarSub:=XMLStarSub.NextSibling;
   end;
   FCWinMain.FCXMLdbUniv.Active:=false;
end;

procedure FCMdF_DBStarSystems_Load;
{:DEV NOTES: .}
{:Purpose: load the universe database XML file.
   Additions:
      -2012Aug05- *code audit (COMPLETION).
      -2012Aug02- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (x)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
   var
      XMLStar
      ,XMLStarSub
      ,XMLStarSystem: IXMLNode;

      EnumIndex
      ,StarCount
      ,StarSystemCount: Integer;
begin
   {.clear the data structure}
   SetLength( FCDduStarSystem, 1 );
   StarSystemCount:=1;
   {.read the document}
   FCWinMain.FCXMLdbUniv.FileName:=FCVdiPathXML+'\univ\universe.xml';
   FCWinMain.FCXMLdbUniv.Active:=true;
   XMLStarSystem:= FCWinMain.FCXMLdbUniv.DocumentElement.ChildNodes.First;
   while XMLStarSystem<>nil do
   begin
      SetLength( FCDduStarSystem, StarSystemCount+1 );
      if XMLStarSystem.NodeName<>'#comment' then
      begin
         {.star system token + nb of stars it contains}
         FCDduStarSystem[StarSystemCount].SS_token:=XMLStarSystem.Attributes['sstoken'];
         {.star system location}
         FCDduStarSystem[StarSystemCount].SS_locationX:=StrToFloat( XMLStarSystem.Attributes['steslocx'], FCVdiFormat );
         FCDduStarSystem[StarSystemCount].SS_locationY:=StrToFloat( XMLStarSystem.Attributes['steslocy'], FCVdiFormat );
         FCDduStarSystem[StarSystemCount].SS_locationZ:=StrToFloat( XMLStarSystem.Attributes['steslocz'], FCVdiFormat );
         {.stars data processing loop}
         StarCount:=1;
         XMLStar:=XMLStarSystem.ChildNodes.First;
         while XMLStar<>nil do
         begin
            {.star token id and class}
            FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_token:=XMLStar.Attributes['startoken'] ;
            EnumIndex:=GetEnumValue( TypeInfo( TFCEduStarClasses ), XMLStar.Attributes['starclass'] );
            FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_class:=TFCEduStarClasses( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad universe star class: '+XMLStar.Attributes['starclass'] );
            FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompanion:=false;
            {.star subdata processing loop}
            XMLStarSub:=XMLStar.ChildNodes.First;
            while XMLStarSub<>nil do
            begin
               {.star's physical data}
               if XMLStarSub.NodeName='starphysdata' then
               begin
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_temperature:=XMLStarSub.Attributes['startemp'];
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_mass:=StrToFloat( XMLStarSub.Attributes['starmass'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_diameter:=StrToFloat( XMLStarSub.Attributes['stardiam'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_luminosity:=StrToFloat( XMLStarSub.Attributes['starlum'], FCVdiFormat );
               end
               {.companion star's data}
               else if XMLStarSub.NodeName='starcompdata' then
               begin
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompanion:=true;
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompMeanSeparation:=StrToFloat( XMLStarSub.Attributes['compmsep'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompMinApproachDistance:=StrToFloat( XMLStarSub.Attributes['compminapd'], FCVdiFormat );
                  FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompEccentricity:=StrToFloat( XMLStarSub.Attributes['compecc'], FCVdiFormat );
                  if StarCount=3 then
                  begin
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduCompanion2OrbitTypes ), XMLStarSub.Attributes['comporb'] );
                     FCDduStarSystem[StarSystemCount].SS_stars[StarCount].S_isCompStar2OrbitType:=TFCEduCompanion2OrbitTypes(EnumIndex);
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad companion star orbit type: '+XMLStarSub.Attributes['comporb'] );
                  end;
               end;
               XMLStarSub:=XMLStarSub.NextSibling;
            end; //==END== while XMLStarSub<>nil do ==//
            inc(StarCount);
            XMLStar:= XMLStar.NextSibling;
         end; //==END== while XMLStar<>nil do ==//
         inc( StarSystemCount );
      end; //==END== if XMLStarSystem.NodeName<>'#comment' then ==//
      XMLStarSystem := XMLStarSystem.NextSibling;
   end; //==END== while XMLStarSystem<>nil do ==//
   FCWinMain.FCXMLdbUniv.Active:=false;
end;

{:DEV NOTES: re-enable for 0.6.0.}
//procedure FCMdF_DBTechnosciences_Load;
//{:DEV NOTES: WARNING NOT USED IN ANY PART OF THE CODE, PUT IT IN FARC_DATA_INIT.}
//{:Purpose: load the technosciences database.
//    Additions:
//}
//   var
//      DBTLcnt: integer;
//
//      DBTLstr: string;
//
//      DBTLnode: IXMLnode;
//begin
//   {.clear the data structure}
//   FCDBtechsci:=nil;
//   SetLength(FCDBtechsci, 1);
//   DBTLcnt:=0;
//   {.read the document}
//   FCWinMain.FCXMLdbTechnosciences.FileName:=FCVdiPathXML+'\env\technosciencesdb.xml';
//   FCWinMain.FCXMLdbTechnosciences.Active:=true;
//   DBTLnode:=FCWinMain.FCXMLdbTechnosciences.DocumentElement.ChildNodes.First;
//   while DBTLnode<>nil do
//   begin
//      if DBTLnode.NodeName<>'#comment'
//      then
//      begin
//         inc(DBTLcnt);
//         SetLength(FCDBtechsci, DBTLcnt+1);
//         FCDBtechsci[DBTLcnt].T_token:=DBTLnode.Attributes['token'];
//         DBTLstr:=DBTLnode.Attributes['rsector'];
//         if DBTLstr='rsNone'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsNone
//         else if DBTLstr='rsAerospaceEng'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsAerospaceEngineering
//         else if DBTLstr='rsBiogenetics'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsBiogenetics
//         else if DBTLstr='rsEcosciences'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsEcosciences
//         else if DBTLstr='rsIndustrialTech'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsIndustrialTech
//         else if DBTLstr='rsMedicine'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsMedicine
//         else if DBTLstr='rsNanotech'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsNanotech
//         else if DBTLstr='rsPhysics'
//         then FCDBtechsci[DBTLcnt].T_researchSector:=rsPhysics;
//         FCDBtechsci[DBTLcnt].T_level:=DBTLnode.Attributes['level'];
//         DBTLstr:=DBTLnode.Attributes['type'];
//         if DBTLstr='rtBasicTech'
//         then FCDBtechsci[DBTLcnt].T_type:=rtBasicTech
//         else if DBTLstr='rtPureTheory'
//         then FCDBtechsci[DBTLcnt].T_type:=rtPureTheory
//         else if DBTLstr='rtExpResearch'
//         then FCDBtechsci[DBTLcnt].T_type:=rtExpResearch
//         else if DBTLstr='rtCompleteResearch'
//         then FCDBtechsci[DBTLcnt].T_type:=rtCompleteResearch;
//         FCDBtechsci[DBTLcnt].T_difficulty:=DBTLnode.Attributes['difficulty'];
//      end; //== END == if DBTLnode.NodeName<>'#comment' ==//
//      DBTLnode:=DBTLnode.NextSibling;
//   end; //== END == while DBTLnode<>nil do ==//
//end;

procedure FCMdF_HelpTDef_Load;
{:Purpose: load the topics-definitions.
   Additions:
      -2012Aug05- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2010Sep05- *add: hintlists are separated by language for proper sorting.
}
   var
      Count: integer;

      XMLHelpItem
      ,XMLHelpRoot: IXMLNode;
begin
   XMLHelpRoot:=FCWinMain.FCXMLtxtEncy.DocumentElement.ChildNodes.FindNode( 'hintlist'+FCVdiLanguage );
   if XMLHelpRoot<>nil then
   begin
      Count:=0;
      XMLHelpItem:=XMLHelpRoot.ChildNodes.First;
      while XMLHelpItem<>nil do
      begin
         if XMLHelpItem.NodeName<>'#comment' then
         begin
            inc( Count );
            setlength( FCDBhelpTdef, Count+1 );
            FCDBhelpTdef[Count].TD_link:=XMLHelpItem.Attributes['link'];
            FCDBhelpTdef[Count].TD_str:=XMLHelpItem.Attributes['title'];
            {add 'section' and in the XML separate by section w/ <!-- --> between them, it's the fastest way to upgrade the encyclopedia w/multiple sections
               the section is an enum:  Principles / Game Systems / CSM Events / SPM Policies / SPM Memes / Products / Infrastructures
               Principles:
                  -Intro (hard sci if + phases + scales + CPS/EP + Goals...)
                  -Colonization Phase
                  -Expansion Phase
                  -Player vs AIs (describe the player's status vs AIs and how the player doesn't start any game like the AIs)
               Game Systems:
                  -CPS
                     -Objectives
                        -...
                  -Colony Simulation Model (CSM)
                     -Data
                     -Population Growth System (PGS)
                        -Population Types
                           -...
                        -Aging and Population Transfert Subsystems
                        -Births
                        -Deaths
                     -Events
                        -...
                  -SPM
                     -Memes
                     -Policies
                     -Political Systems
                     -Economical Systems
                     -Healthcare Systems
                     -Spiritual Systems
                  -Realtime & Turn-Based Game Flow
                  -Tasks System
                  -Planetary Survey
                     -Biosphere Survey
                     -Features & Artifacts Survey
                     -Resources Survey
                     -Settlement Survey
                  -Space Units Missions
                     -Missions
                        -Colonization
                        -Interplanetary Transit
                  -Production
                     -Energy Segment
                     -Products Segment
                        -Resources
                           -...
                        -Energy-Related
                           -...
                        -Materials
                           -...
                        -Bioproducts
                           -...
                        -Equipment
                           -...
                     -Reserves Segment
                     -Space Units Manufacturing Segment
                     -Conversion/Assembling/Building (CAB) Segment
                        -Infrastructures
                           -...
               replace the list w/ a tree!

            }
         end;
         XMLHelpItem:=XMLHelpItem.NextSibling;
      end;
   end;
end;

end.
