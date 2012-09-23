{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: saved game file - management unit

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
unit farc_data_filesavegame;

interface

uses
   SysUtils
   ,TypInfo
   ,Windows
   ,XMLIntf;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   load the current game
///</summary>
procedure FCMdFSG_Game_Load;

///<summary>
///   save the current game
///</summary>
procedure FCMdFSG_Game_Save;

///<summary>
///   save the current game and flush all other save game files than the current one
///</summary>
procedure FCMdFSG_Game_SaveAndFlushOther;

implementation

uses
   farc_common_func
   ,farc_data_files
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_messages
   ,farc_data_missionstasks
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_cpsobjectives
   ,farc_game_gameflow
   ,farc_univ_func
   ,farc_main;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMdFSG_Game_Load;
{:Purpose: load the current game.
   Additions:
      -2012Aug15- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (_)local methods
                     (_)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (x)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012May24- *add: CPS - Viability thresholds.
      -2012May13- *add: CSM event: etRveFoodShortage, addition of the direct death period + death fractional value.
      -2012May12- *add: CSM event: etRveOxygenShortage, etRveWaterOverload, etRveWaterShortage, etRveFoodOverload and etRveFoodShortage.
      -2012May06- *add: CSM event: etRveOxygenOverload.
      -2012Apr29- *mod: CSM event token are loaded by their full names now.
                  *mod: CSM event modifiers and data are loaded according to the new changes in the data structure.
      -2012Apr15- *add: completion of colony's reserves.
                  *fix: correctly load the colony level.
      -2012Mar14- *fix: colony's production matrix - correct a data mismatch error in the production matrix item loading.
                  *fix: owned infrastructures - forgot to include MISC and INTELLIGENCE function for saving them and their possible specific data.
      -2012Mar13- *add: selective loading for otEcoIndustrialForce data.
      -2012Mar11- *add: viability objective: otEcoIndustrialForce.
      -2012Feb09- *add: load directly the CPS objective type.
      -2012Jan11- *add: production matrix / CPMI_storageType.
      -2012Jan04- *add: owned infrastructures / power generated by custom effect.
      -2011Dec11- *mod: transfert the disable state for production mode of the production matrix into the owned infrastructure data structure.
      -2011Dec08- *add: owned infrastructures / production function / PM_matrixItemMax.
      -2011Nov30- *add: complete surveyed resource spot data for infrastructures.
      -2011Nov22- *fix: initialize correctly the CAB queue of all loaded settlement (even before the CAB queue itself is loaded.
                        prevent: crash during the commit of the setup of an assembling/building + crash during the loading of the CAB queue.
      -2011Nov18- *add: update hardcoded resource data w/ updated data structure.
      -2011Nov07- *add: complete production mode data for owned infrastructures.
                  *add: put full function name for owned infrastuctures.
                  *code: optimize owned infrastructure status and funtion loading.
      -2011Nov01- *add: complete the production matrix.
      -2011Oct19- *add: add, in list of surveyed resources, the specificity concerning the Ore field type.
      -2011Oct17- *add: complete the production matrix loading.
      -2011Oct11- *fix: forgot to set the size of the region dynamic array.
                  *fix: correction on spotSizCurr attribute loading.
      -2011Oct10- *add: list for surveyed resources.
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
      XMLSavedGame
      ,XMLSavedGameItem
      ,XMLSavedGameItemSub
      ,XMLSavedGameItemSub1
      ,XMLSavedGameItemSub2
      ,XMLSavedGameItemSub3
      ,XMLSavedGameItemSub4
      ,XMLSavedGameItemSub5
      ,XMLSavedGameItemSub6: IXMLNode;

      Count
      ,Count1
      ,Count2
      ,Count3
      ,Count4
      ,Count5
      ,EnumIndex
      ,Max: integer;

      CurrentDirectory
      ,CurrentSavedGameFile: string;

      ViabilityObjectives: array of TFCRcpsObj;

      StellarMatrix: TFCRufStelObj;
begin
   FCMdF_ConfigurationFile_Load( true );
   CurrentDirectory:=FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName;
   CurrentSavedGameFile:=IntToStr( FCVdgPlayer.P_currentTimeYear )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeMonth )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeDay )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeHour )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeMinut )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeTick )
      +'.xml';
   if ( DirectoryExists( CurrentDirectory ) )
      and ( FileExists( CurrentDirectory+'\'+CurrentSavedGameFile ) ) then
   begin
      {.read the document}
      FCWinMain.FCXMLsave.FileName:=CurrentDirectory+'\'+CurrentSavedGameFile;
      FCWinMain.FCXMLsave.Active:=true;
      {.read the main section}
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfMain' );
      if XMLSavedGame<>nil then
      begin
         FCVdgPlayer.P_allegianceFaction:=XMLSavedGame.Attributes['facAlleg'];
         FCVdgPlayer.P_viewStarSystem:=XMLSavedGame.Attributes['plyrsSSLoc'];
         FCVdgPlayer.P_viewStar:=XMLSavedGame.Attributes['plyrsStLoc'];
         FCVdgPlayer.P_viewOrbitalObject:=XMLSavedGame.Attributes['plyrsOObjLoc'];
         FCVdgPlayer.P_viewSatellite:=XMLSavedGame.Attributes['plyrsatLoc'];
         FCMdF_DBStarOrbitalObjects_Load( FCVdgPlayer.P_viewStarSystem, FCVdgPlayer.P_viewStar );
      end;
      {.read the "timeframe" section}
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfTimeFr' );
      if XMLSavedGame<>nil then
      begin
         FCVdgPlayer.P_currentTimeTick:=XMLSavedGame.Attributes['tfTick'];
         FCVdgPlayer.P_currentTimeMinut:=XMLSavedGame.Attributes['tfMin'];
         FCVdgPlayer.P_currentTimeHour:=XMLSavedGame.Attributes['tfHr'];
         FCVdgPlayer.P_currentTimeDay:=XMLSavedGame.Attributes['tfDay'];
         FCVdgPlayer.P_currentTimeMonth:=XMLSavedGame.Attributes['tfMth'];
         FCVdgPlayer.P_currentTimeYear:=XMLSavedGame.Attributes['tfYr'];
      end;
      {.read the "status" section}
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfStatus' );
      if XMLSavedGame<>nil then
      begin
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdgPlayerFactionStatus ), XMLSavedGame.Attributes['statEco'] );
         FCVdgPlayer.P_economicStatus:=TFCEdgPlayerFactionStatus( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad gamesave loading w/ economic status: '+XMLSavedGame.Attributes['statEco'] );
         FCVdgPlayer.P_economicViabilityThreshold:=XMLSavedGame.Attributes['statEcoThr'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdgPlayerFactionStatus ), XMLSavedGame.Attributes['statSoc'] );
         FCVdgPlayer.P_socialStatus:=TFCEdgPlayerFactionStatus( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad gamesave loading w/ social status: '+XMLSavedGame.Attributes['statSoc'] );
         FCVdgPlayer.P_socialViabilityThreshold:=XMLSavedGame.Attributes['statSocThr'];
         EnumIndex:=GetEnumValue( TypeInfo( TFCEdgPlayerFactionStatus ), XMLSavedGame.Attributes['statSpMil'] );
         FCVdgPlayer.P_militaryStatus:=TFCEdgPlayerFactionStatus( EnumIndex );
         if EnumIndex=-1
         then raise Exception.Create( 'bad gamesave loading w/ military status: '+XMLSavedGame.Attributes['statSpMil'] );
         FCVdgPlayer.P_militaryViabilityThreshold:=XMLSavedGame.Attributes['statSpMilThr'];
      end;
      {.read "cps" section}
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfCPS' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         SetLength( ViabilityObjectives, 1 );
         while XMLSavedGameItem<>nil do
         begin
            inc( Count );
            SetLength( ViabilityObjectives, Count+1 );
            EnumIndex:=GetEnumValue( TypeInfo( TFCEcpsoObjectiveTypes ), XMLSavedGameItem.Attributes['objTp'] );
            ViabilityObjectives[Count].CPSO_type:=TFCEcpsoObjectiveTypes( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/CPS objective: '+XMLSavedGameItem.Attributes['objTp'] );
            ViabilityObjectives[Count].CPSO_score:=XMLSavedGameItem.Attributes['score'];
            if ViabilityObjectives[Count].CPSO_type=otEcoIndustrialForce then
            begin
               ViabilityObjectives[Count].CPSO_ifProduct:=XMLSavedGameItem.Attributes['product'];
               ViabilityObjectives[Count].CPSO_ifThreshold:=StrToFloat( XMLSavedGameItem.Attributes['threshold'], FCVdiFormat );
            end;
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; //==END== XMLSavedGameItem<>nil ==//
         FCcps:=TFCcps.Create(
            XMLSavedGame.Attributes['cpsCVS']
            ,XMLSavedGame.Attributes['cpsTlft']
            ,XMLSavedGame.Attributes['cpsCredM']
            ,XMLSavedGame.Attributes['cpsInt']
            ,XMLSavedGame.Attributes['cpsCredU']
            ,ViabilityObjectives
            ,XMLSavedGame.Attributes['cpsEnabled']
            );
      end; //==END== if XMLSavedGame<>nil for CPS ==//
      {.read "taskinprocess" saved game item}
      SetLength(FCGtskListInProc, 1);
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfTskLstinProc' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            inc( Count );
            SetLength( FCGtskListInProc, Count+1 );
            EnumIndex:=GetEnumValue( TypeInfo( TFCEdmtTasks ), XMLSavedGameItem.Attributes['tipActTp'] );
            FCGtskListInProc[Count].T_type:=TFCEdmtTasks( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/task type: '+XMLSavedGameItem.Attributes['tipActTp'] );
            FCGtskListInProc[Count].T_tMColCurrentPhase:=XMLSavedGameItem.Attributes['tipPhase'];
            EnumIndex:=GetEnumValue( TypeInfo( TFCEdmtTaskTargets ), XMLSavedGameItem.Attributes['tipTgtTp'] );
//            FCGtskListInProc[Count].TITP_ctldType:=TFCEdmtTaskTargets( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/ task target type: '+XMLSavedGameItem.Attributes['tipTgtTp'] );
            FCGtskListInProc[Count].T_entity:=XMLSavedGameItem.Attributes['tipTgtFac'];
            FCGtskListInProc[Count].TITP_ctldIdx:=XMLSavedGameItem.Attributes['tipTgtIdx'];
            FCGtskListInProc[Count].TITP_timeOrg:=XMLSavedGameItem.Attributes['tipTimeOrg'];
            FCGtskListInProc[Count].TITP_duration:=XMLSavedGameItem.Attributes['tipDura'];
            FCGtskListInProc[Count].TITP_interval:=XMLSavedGameItem.Attributes['tipInterv'];
            EnumIndex:=GetEnumValue( TypeInfo( TFCEdmtTaskTargets ), XMLSavedGameItem.Attributes['tipOrgTp'] );
            FCGtskListInProc[Count].TITP_orgType:=TFCEdmtTaskTargets( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/ origin type: '+XMLSavedGameItem.Attributes['tipOrgTp'] );
            FCGtskListInProc[Count].TITP_orgIdx:=XMLSavedGameItem.Attributes['tipOrgIdx'];
            EnumIndex:=GetEnumValue( TypeInfo( TFCEdmtTaskTargets ), XMLSavedGameItem.Attributes['tipDestTp'] );
            FCGtskListInProc[Count].TITP_destType:=TFCEdmtTaskTargets( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/ destination type: '+XMLSavedGameItem.Attributes['tipDestTp'] );
            FCGtskListInProc[Count].TITP_destIdx:=XMLSavedGameItem.Attributes['tipDestIdx'];
            FCGtskListInProc[Count].TITP_regIdx:=XMLSavedGameItem.Attributes['tipRegIdx'];
            FCGtskListInProc[Count].TITP_velCruise:=StrToFloat( XMLSavedGameItem.Attributes['tipVelCr'], FCVdiFormat );
            FCGtskListInProc[Count].TITP_timeToCruise:=XMLSavedGameItem.Attributes['tipTimeTcr'];
            FCGtskListInProc[Count].TITP_timeDecel:=XMLSavedGameItem.Attributes['tipTimeTdec'];
            FCGtskListInProc[Count].TITP_time2xfert:=XMLSavedGameItem.Attributes['tipTime2Xfrt'];
            FCGtskListInProc[Count].TITP_time2xfert2decel:=XMLSavedGameItem.Attributes['tipTime2XfrtDec'];
            FCGtskListInProc[Count].TITP_velFinal:=StrToFloat( XMLSavedGameItem.Attributes['tipVelFin'], FCVdiFormat );
            FCGtskListInProc[Count].TITP_timeToFinal:=XMLSavedGameItem.Attributes['tipTimeTfin'];
            FCGtskListInProc[Count].TITP_accelbyTick:=StrToFloat( XMLSavedGameItem.Attributes['tipAccelBtick'], FCVdiFormat );
            FCGtskListInProc[Count].TITP_usedRMassV:=StrToFloat( XMLSavedGameItem.Attributes['tipUsedRM'], FCVdiFormat );
            FCGtskListInProc[Count].TITP_str1:=XMLSavedGameItem.Attributes['tipStr1'];
            FCGtskListInProc[Count].TITP_str2:=XMLSavedGameItem.Attributes['tipStr2'];
            FCGtskListInProc[Count].TITP_int1:=XMLSavedGameItem.Attributes['tipInt1'];
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; {.while XMLSavedGameItem<>nil}
      end; {.if XMLSavedGame<>nil}
      {.read all surveyed resources}
      setlength( FCVdgPlayer.P_surveyedResourceSpots, 1 );
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfSurveyedResourceSpots' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            inc( Count );
            SetLength( FCVdgPlayer.P_surveyedResourceSpots, Count+1 );
            FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken:=XMLSavedGameItem.Attributes['oobj'];
            FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem:=XMLSavedGameItem.Attributes['ssysIdx'];
            FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star:=XMLSavedGameItem.Attributes['starIdx'];
            FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject:=XMLSavedGameItem.Attributes['oobjIdx'];
            FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite:=XMLSavedGameItem.Attributes['satIdx'];
            if ( ( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken<>'' ) and ( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite=0 )
               and ( FCDduStarSystem[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem].SS_stars[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star].
                  S_orbitalObjects[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject].OO_dbTokenId=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken
                  )
               )
               or ( ( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken<>'' ) and ( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite>0 )
                  and ( FCDduStarSystem[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem].SS_stars[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star].S_orbitalObjects[FCVdgPlayer.P_surveyedResourceSpots[Count].
                     SRS_orbitalObject].OO_satellitesList[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite].OO_dbTokenId=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken
                     )
               ) then
            begin
               if FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite=0
               then SetLength(
                  FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions
                  ,length(
                     FCDduStarSystem[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem].SS_stars[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star].
                        S_orbitalObjects[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject].OO_regions
                     )+1
                  )
               else if FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite>0
               then SetLength(
                  FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions
                  ,length(
                     FCDduStarSystem[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem].
                        SS_stars[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star].S_orbitalObjects[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject].
                           OO_satellitesList[FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite].OO_regions
                     )+1
                  );
               XMLSavedGameItemSub:=XMLSavedGameItem.ChildNodes.First;
               while XMLSavedGameItemSub<>nil do
               begin
                  Count1:=XMLSavedGameItemSub.Attributes['regionIdx'];
                  Count2:=0;
                  XMLSavedGameItemSub1:=XMLSavedGameItemSub.ChildNodes.First;
                  while XMLSavedGameItemSub1<>nil do
                  begin
                     inc( Count2 );
                     SetLength( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots, Count2+1 );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEduResourceSpotTypes ), XMLSavedGameItemSub1.Attributes['spotType'] );
                     FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_type:=TFCEduResourceSpotTypes( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad gamesave loading w/rsrc spot type: '+XMLSavedGameItemSub1.Attributes['spotType'] )
                     else if EnumIndex>0 then
                     begin
                        FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_meanQualityCoefficient:=StrToFloat( XMLSavedGameItemSub1.Attributes['meanQualCoef'], FCVdiFormat );
                        FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_spotSizeCurrent:=XMLSavedGameItemSub1.Attributes['spotSizCurr'];
                        FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_spotSizeMax:=XMLSavedGameItemSub1.Attributes['spotSizeMax'];
                        if FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_type=rstOreField then
                        begin
                           FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiCarbonaceous:=XMLSavedGameItemSub1.Attributes['oreCarbo'];
                           FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiMetallic:=XMLSavedGameItemSub1.Attributes['oreMetal'];
                           FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiRare:=XMLSavedGameItemSub1.Attributes['oreRare'];
                           FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiUranium:=XMLSavedGameItemSub1.Attributes['oreUra'];
                        end;
                     end;
                     XMLSavedGameItemSub1:=XMLSavedGameItemSub1.NextSibling;
                  end;
                  XMLSavedGameItemSub:=XMLSavedGameItemSub.NextSibling;
               end;
            end
            else raise Exception.Create('universe database is not compatible with the current save game file');
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; //==END== while XMLSavedGameItem<>nil ==//
      end; //==END== if XMLSavedGame<>nil then... for surveyed resources ==//
      {.read "CSM" section}
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfCSM' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         SetLength( FCDdgCSMPhaseSchedule, 1 );
         while XMLSavedGameItem<>nil do
         begin
            inc( Count );
            SetLength( FCDdgCSMPhaseSchedule, Count+1 );
            FCDdgCSMPhaseSchedule[Count].CSMPS_ProcessAtTick:=XMLSavedGameItem.Attributes['csmTick'];
            Count1:=0;
            Count2:=-1;
            XMLSavedGameItemSub:=XMLSavedGameItem.ChildNodes.First;
            while XMLSavedGameItemSub<>nil do
            begin
               Count1:=XMLSavedGameItemSub.Attributes['fac'];
               if Count1<>Count2 then
               begin
                  Count2:=Count1;
                  SetLength( FCDdgCSMPhaseSchedule[Count].CSMPS_colonies[Count1], 1 );
                  Count3:=0;
               end;
               inc( Count3 );
               SetLength( FCDdgCSMPhaseSchedule[Count].CSMPS_colonies[Count1], Count3+1 );
               FCDdgCSMPhaseSchedule[Count].CSMPS_colonies[Count1, Count3]:=XMLSavedGameItemSub.Attributes['colony'];
               XMLSavedGameItemSub:=XMLSavedGameItemSub.NextSibling;
            end;
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; //==END== GLxmlCSMpL<>nil ==//
      end; //==END== if GLxmlItm<>nil for CSM ==//
      {.entities section}
      FCMdG_Entities_Clear;
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfEntities' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            FCDdgEntities[Count].E_token:=XMLSavedGameItem.Attributes['token'];
            FCDdgEntities[Count].E_factionLevel:=XMLSavedGameItem.Attributes['lvl'];
            FCDdgEntities[Count].E_bureaucracy:=XMLSavedGameItem.Attributes['bur'];
            FCDdgEntities[Count].E_corruption:=XMLSavedGameItem.Attributes['corr'];
            EnumIndex:=GetEnumValue( TypeInfo( TFCEdgHeadQuarterStatus ), XMLSavedGameItem.Attributes['hqHlvl'] );
            FCDdgEntities[Count].E_hqHigherLevel:=TFCEdgHeadQuarterStatus( EnumIndex );
            if EnumIndex=-1
            then raise Exception.Create( 'bad gamesave loading w/HQ higher level: '+XMLSavedGameItem.Attributes['hqHlvl'] );
            FCDdgEntities[Count].E_ucInAccount:=StrToFloat( XMLSavedGameItem.Attributes['UCrve'], FCVdiFormat );
            XMLSavedGameItemSub:=XMLSavedGameItem.ChildNodes.First;
            SetLength( FCDdgEntities[Count].E_spaceUnits, 1 );
            SetLength( FCDdgEntities[Count].E_colonies, 1 );
            SetLength( FCDdgEntities[Count].E_spmSettings, 1 );
            while XMLSavedGameItemSub<>nil do
            begin
               if XMLSavedGameItemSub.NodeName='entOwnSpU' then
               begin
                  Count1:=0;
                  XMLSavedGameItemSub1:=XMLSavedGameItemSub.ChildNodes.First;
                  while XMLSavedGameItemSub1<>nil do
                  begin
                     inc(Count1);
                     SetLength( FCDdgEntities[Count].E_spaceUnits, Count1+1 );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_token:=XMLSavedGameItemSub1.Attributes['tokenId'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_name:=XMLSavedGameItemSub1.Attributes['tokenName'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_designToken:=XMLSavedGameItemSub1.Attributes['desgnId'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationStarSystem:=XMLSavedGameItemSub1.Attributes['ssLoc'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationStar:=XMLSavedGameItemSub1.Attributes['stLoc'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationOrbitalObject:=XMLSavedGameItemSub1.Attributes['oobjLoc'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationSatellite:=XMLSavedGameItemSub1.Attributes['satLoc'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_linked3dObject:=XMLSavedGameItemSub1.Attributes['TdObjIdx'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewX:=StrToFloat( XMLSavedGameItemSub1.Attributes['xLoc'], FCVdiFormat );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewZ:=StrToFloat( XMLSavedGameItemSub1.Attributes['zLoc'], FCVdiFormat );
                     Max:=XMLSavedGameItemSub1.Attributes['docked'];
                     if Max>0 then
                     begin
                        SetLength( FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits, Max+1 );
                        Count2:=1;
                        XMLSavedGameItemSub2:=XMLSavedGameItemSub1.ChildNodes.First;
                        while Count2<=Max do
                        begin
                           FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits[Count2].SUDL_index:=XMLSavedGameItemSub2.Attributes['index'];
                           inc( Count2 );
                           XMLSavedGameItemSub2:=XMLSavedGameItemSub2.NextSibling;
                        end;
                     end;
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_assignedTask:=XMLSavedGameItemSub1.Attributes['taskId'];
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSpaceUnitStatus ), XMLSavedGameItemSub1.Attributes['status'] );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_status:=TFCEdgSpaceUnitStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad gamesave loading w/ space unit status: '+XMLSavedGameItemSub1.Attributes['status'] );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_deltaV:=StrToFloat( XMLSavedGameItemSub1.Attributes['dV'], FCVdiFormat );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_3dVelocity:=StrToFloat( XMLSavedGameItemSub1.Attributes['TdMov'], FCVdiFormat );
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_reactionMass:=StrToFloat( XMLSavedGameItemSub1.Attributes['availRMass'], FCVdiFormat );
                     XMLSavedGameItemSub1:=XMLSavedGameItemSub1.NextSibling;
                  end;
               end //==END== if GLxmlEntSubRoot.NodeName='entOwnSpU' ==//
               else if XMLSavedGameItemSub.NodeName='entColonies' then
               begin
                  Count1:=0;
                  if assigned(FCcps)
                  then FCcps.FCM_ViabObj_Init(false);
                  XMLSavedGameItemSub1:=XMLSavedGameItemSub.ChildNodes.First;
                  while XMLSavedGameItemSub1<>nil do
                  begin
                     inc( Count1 );
                     SetLength( FCDdgEntities[Count].E_colonies, Count1+1 );
                     SetLength( FCDdgEntities[Count].E_colonies[Count1].C_events, 1 );
                     SetLength( FCDdgEntities[Count].E_colonies[Count1].C_settlements, 1 );
                     SetLength( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue, 1 );
                     FCDdgEntities[Count].E_colonies[Count1].C_name:=XMLSavedGameItemSub1.Attributes['prname'];
                     FCDdgEntities[Count].E_colonies[Count1].C_foundationDateYear:=XMLSavedGameItemSub1.Attributes['fndyr'];
                     FCDdgEntities[Count].E_colonies[Count1].C_foundationDateMonth:=XMLSavedGameItemSub1.Attributes['fndmth'];
                     FCDdgEntities[Count].E_colonies[Count1].C_foundationDateDay:=XMLSavedGameItemSub1.Attributes['fnddy'];
                     FCDdgEntities[Count].E_colonies[Count1].C_nextCSMsessionInTick:=XMLSavedGameItemSub1.Attributes['csmtime'];
                     FCDdgEntities[Count].E_colonies[Count1].C_locationStarSystem:=XMLSavedGameItemSub1.Attributes['locssys'];
                     FCDdgEntities[Count].E_colonies[Count1].C_locationStar:=XMLSavedGameItemSub1.Attributes['locstar'];
                     FCDdgEntities[Count].E_colonies[Count1].C_locationOrbitalObject:=XMLSavedGameItemSub1.Attributes['locoobj'];
                     FCDdgEntities[Count].E_colonies[Count1].C_locationSatellite:=XMLSavedGameItemSub1.Attributes['locsat'];
                     StellarMatrix:=FCFuF_StelObj_GetFullRow(
                        FCDdgEntities[Count].E_colonies[Count1].C_locationStarSystem
                        ,FCDdgEntities[Count].E_colonies[Count1].C_locationStar
                        ,FCDdgEntities[Count].E_colonies[Count1].C_locationOrbitalObject
                        ,FCDdgEntities[Count].E_colonies[Count1].C_locationOrbitalObject
                        );
                     if StellarMatrix[4]=0
                     then FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_colonies[0]:=Count1
                     else if StellarMatrix[4]>0
                     then FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_satellitesList[StellarMatrix[4]].OO_colonies[0]:=Count1;
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdgColonyLevels ), XMLSavedGameItemSub1.Attributes['collvl'] );
                     FCDdgEntities[Count].E_colonies[Count1].C_level:=TFCEdgColonyLevels( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad gamesave loading w/colony level: '+XMLSavedGameItemSub1.Attributes['collvl'] );
                     EnumIndex:=GetEnumValue( TypeInfo( TFCEdgHeadQuarterStatus ), XMLSavedGameItemSub1.Attributes['hqpresence'] );
                     FCDdgEntities[Count].E_colonies[Count1].C_hqPresence:=TFCEdgHeadQuarterStatus( EnumIndex );
                     if EnumIndex=-1
                     then raise Exception.Create( 'bad gamesave loading w/HQ presence: '+XMLSavedGameItemSub1.Attributes['hqpresence'] );
                     FCDdgEntities[Count].E_colonies[Count1].C_cohesion:=XMLSavedGameItemSub1.Attributes['dcohes'];
                     FCDdgEntities[Count].E_colonies[Count1].C_security:=XMLSavedGameItemSub1.Attributes['dsecu'];
                     FCDdgEntities[Count].E_colonies[Count1].C_tension:=XMLSavedGameItemSub1.Attributes['dtens'];
                     FCDdgEntities[Count].E_colonies[Count1].C_instruction:=XMLSavedGameItemSub1.Attributes['dedu'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_PopulationCapacity:=XMLSavedGameItemSub1.Attributes['csmPCAP'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_SpaceLevel:=StrToFloat( XMLSavedGameItemSub1.Attributes['csmSPL'], FCVdiFormat );
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_QualityOfLife:=XMLSavedGameItemSub1.Attributes['csmQOL'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHealth_HealthLevel:=XMLSavedGameItemSub1.Attributes['csmHEAL'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Consumption:= StrToFloat( XMLSavedGameItemSub1.Attributes['csmEnCons'], FCVdiFormat );
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Generation:=StrToFloat( XMLSavedGameItemSub1.Attributes['csmEnGen'], FCVdiFormat );
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageCurrent:=StrToFloat( XMLSavedGameItemSub1.Attributes['csmEnStorCurr'], FCVdiFormat );
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageMax:=StrToFloat( XMLSavedGameItemSub1.Attributes['csmEnStorMax'], FCVdiFormat );
                     FCDdgEntities[Count].E_colonies[Count1].C_economicIndustrialOutput:=XMLSavedGameItemSub1.Attributes['eiOut'];
                     XMLSavedGameItemSub2:=XMLSavedGameItemSub1.ChildNodes.First;
                     while XMLSavedGameItemSub2<>nil do
                     begin
                        {.colony population}
                        if XMLSavedGameItemSub2.NodeName='colPopulation' then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_total:=XMLSavedGameItemSub2.Attributes['popTtl'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_meanAge:=StrToFloat( XMLSavedGameItemSub2.Attributes['popMeanAge'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathRate:=StrToFloat( XMLSavedGameItemSub2.Attributes['popDRate'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathStack:=StrToFloat( XMLSavedGameItemSub2.Attributes['popDStack'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthRate:=StrToFloat( XMLSavedGameItemSub2.Attributes['popBRate'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthStack:=StrToFloat( XMLSavedGameItemSub2.Attributes['popBStack'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classColonist:=XMLSavedGameItemSub2.Attributes['popColon'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classColonistAssigned:=XMLSavedGameItemSub2.Attributes['popColonAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerOfficer:=XMLSavedGameItemSub2.Attributes['popOff'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerOfficerAssigned:=XMLSavedGameItemSub2.Attributes['popOffAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerMissionSpecialist:=XMLSavedGameItemSub2.Attributes['popMisSpe'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerMissionSpecialistAssigned:=XMLSavedGameItemSub2.Attributes['popMisSpeAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioBiologist:=XMLSavedGameItemSub2.Attributes['popBiol'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioBiologistAssigned:=XMLSavedGameItemSub2.Attributes['popBiolAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioDoctor:=XMLSavedGameItemSub2.Attributes['popDoc'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioDoctorAssigned:=XMLSavedGameItemSub2.Attributes['popDocAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndTechnician:=XMLSavedGameItemSub2.Attributes['popTech'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndTechnicianAssigned:=XMLSavedGameItemSub2.Attributes['popTechAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndEngineer:=XMLSavedGameItemSub2.Attributes['popEng'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndEngineerAssigned:=XMLSavedGameItemSub2.Attributes['popEngAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilSoldier:=XMLSavedGameItemSub2.Attributes['popSold'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilSoldierAssigned:=XMLSavedGameItemSub2.Attributes['popSoldAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilCommando:=XMLSavedGameItemSub2.Attributes['popComm'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilCommandoAssigned:=XMLSavedGameItemSub2.Attributes['popCommAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyPhysicist:=XMLSavedGameItemSub2.Attributes['popPhys'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyPhysicistAssigned:=XMLSavedGameItemSub2.Attributes['popPhysAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyAstrophysicist:=XMLSavedGameItemSub2.Attributes['popAstro'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyAstrophysicistAssigned:=XMLSavedGameItemSub2.Attributes['popAstroAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcologist:=XMLSavedGameItemSub2.Attributes['popEcol'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcologistAssigned:=XMLSavedGameItemSub2.Attributes['popEcolAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcoformer:=XMLSavedGameItemSub2.Attributes['popEcof'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcoformerAssigned:=XMLSavedGameItemSub2.Attributes['popEcofAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAdmMedian:=XMLSavedGameItemSub2.Attributes['popMedian'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAdmMedianAssigned:=XMLSavedGameItemSub2.Attributes['popMedianAssign'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classRebels:=XMLSavedGameItemSub2.Attributes['popRebels'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilitia:=XMLSavedGameItemSub2.Attributes['popMilitia'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPtotal:=StrToFloat( XMLSavedGameItemSub2.Attributes['wcpTotal'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPassignedPeople:=XMLSavedGameItemSub2.Attributes['wcpAssignPpl'];
                        end //==END== if XMLSavedGameItemSub2.NodeName='colPopulation' ==//
                        {.colony events}
                        else if XMLSavedGameItemSub2.NodeName='colEvents' then
                        begin
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count2 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_events, Count2+1 );
                              EnumIndex:=GetEnumValue( TypeInfo(TFCEdgColonyEvents), XMLSavedGameItemSub3.Attributes['token'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_type:=TFCEdgColonyEvents( EnumIndex );
                              if EnumIndex=-1
                              then raise Exception.Create( 'bad gamesave loading w/CSM event type: '+XMLSavedGameItemSub3.Attributes['token'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_isResident:=XMLSavedGameItemSub3.Attributes['isres'];
                              FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_durationWeeks:=XMLSavedGameItemSub3.Attributes['duration'];
                              FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_level:=XMLSavedGameItemSub3.Attributes['level'];
                              case FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_type of
                                 ceColonyEstablished:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCEstTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCEstSecurityMod:=XMLSavedGameItemSub3.Attributes['modSecurity'];
                                 end;

                                 ceUnrest, ceUnrest_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCUnEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCUnTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                 end;

                                 ceSocialDisorder, ceSocialDisorder_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tSDisEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tSDisTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                 end;

                                 ceUprising, ceUprising_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tUpEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tUpTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                 end;

                                 ceDissidentColony: ;

                                 ceHealthEducationRelation: FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tHERelEducationMod:=XMLSavedGameItemSub3.Attributes['modInstruction'];

                                 ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering: FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tGDestCohesionMod:=XMLSavedGameItemSub3.Attributes['modCohesion'];

                                 ceOxygenProductionOverload: FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOPOvPercentPopulationNotSupported:=XMLSavedGameItemSub3.Attributes['percPopNotSupported'];

                                 ceOxygenShortage, ceOxygenShortage_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShPercentPopulationNotSupportedAtCalculation:=XMLSavedGameItemSub3.Attributes['percPopNotSupAtCalc'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShHealthMod:=XMLSavedGameItemSub3.Attributes['modHealth'];
                                 end;

                                 ceWaterProductionOverload: FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWPOvPercentPopulationNotSupported:=XMLSavedGameItemSub3.Attributes['percPopNotSupported'];

                                 ceWaterShortage, ceWaterShortage_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShPercentPopulationNotSupportedAtCalculation:=XMLSavedGameItemSub3.Attributes['percPopNotSupAtCalc'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShHealthMod:=XMLSavedGameItemSub3.Attributes['modHealth'];
                                 end;

                                 ceFoodProductionOverload: FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFPOvPercentPopulationNotSupported:=XMLSavedGameItemSub3.Attributes['percPopNotSupported'];

                                 ceFoodShortage, ceFoodShortage_Recovering:
                                 begin
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShPercentPopulationNotSupportedAtCalculation:=XMLSavedGameItemSub3.Attributes['percPopNotSupAtCalc'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShEconomicIndustrialOutputMod:=XMLSavedGameItemSub3.Attributes['modEcoInd'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShTensionMod:=XMLSavedGameItemSub3.Attributes['modTension'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShHealthMod:=XMLSavedGameItemSub3.Attributes['modHealth'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShDirectDeathPeriod:=XMLSavedGameItemSub3.Attributes['directDeathPeriod'];
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShDeathFractionalValue:=StrToFloat( XMLSavedGameItemSub3.Attributes['deathFracValue'], FCVdiFormat );
                                 end;
                              end; //==END== case FCentities[GLentCnt].E_col[GLcount].COL_evList[Count2].CSMEV_token of ==//
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end; //==END== while XMLSavedGameItemSub3<>nil ==//
                        end //==END== else if XMLSavedGameItemSub2.NodeName='colEvent' ==//
                        {.colony settlements}
                        else if XMLSavedGameItemSub2.NodeName='colSettlement' then
                        begin
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count2 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_settlements, Count2+1 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures, 1 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue, Count2+1 );
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_name:=XMLSavedGameItemSub3.Attributes['name'];
                              EnumIndex:=GetEnumValue( TypeInfo( TFCEdgSettlements ), XMLSavedGameItemSub3.Attributes['type'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_settlement:=TFCEdgSettlements( EnumIndex );
                              if EnumIndex=-1
                              then raise Exception.Create( 'bad gamesave loading w/settlement type: '+XMLSavedGameItemSub3.Attributes['type'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_level:=XMLSavedGameItemSub3.Attributes['level'];
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_locationRegion:=XMLSavedGameItemSub3.Attributes['region'];
                              Count3:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_locationRegion;
                              if StellarMatrix[4]=0 then
                              begin
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_regions[Count3].OOR_settlementEntity:=Count;
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_regions[Count3].OOR_settlementColony:=Count1;
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_regions[Count3].OOR_settlementIndex:=Count2;
                              end
                              else if StellarMatrix[4]>0 then
                              begin
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_satellitesList[StellarMatrix[4]].OO_regions[Count3].OOR_settlementEntity:=Count;
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_satellitesList[StellarMatrix[4]].OO_regions[Count3].OOR_settlementColony:=Count1;
                                 FCDduStarSystem[StellarMatrix[1]].SS_stars[StellarMatrix[2]].S_orbitalObjects[StellarMatrix[3]].OO_satellitesList[StellarMatrix[4]].OO_regions[Count3].OOR_settlementIndex:=Count2;
                              end;
                              Count3:=0;
                              XMLSavedGameItemSub4:=XMLSavedGameItemSub3.ChildNodes.First;
                              while XMLSavedGameItemSub4<>nil do
                              begin
                                 inc( Count3 );
                                 SetLength( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures, Count3+1 );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_token:=XMLSavedGameItemSub4.Attributes['token'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_level:=XMLSavedGameItemSub4.Attributes['level'];
                                 EnumIndex:=GetEnumValue( TypeInfo( TFCEdgInfrastructureStatus ), XMLSavedGameItemSub4.Attributes['status'] );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_status:=TFCEdgInfrastructureStatus( EnumIndex );
                                 if EnumIndex=-1
                                 then raise Exception.Create( 'bad gamesave loading w/infra status: '+XMLSavedGameItemSub4.Attributes['status'] );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabDuration:=XMLSavedGameItemSub4.Attributes['CABduration'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabWorked:=XMLSavedGameItemSub4.Attributes['CABworked'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerConsumption:=StrToFloat( XMLSavedGameItemSub4.Attributes['powerCons'], FCVdiFormat );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerGeneratedFromCustomEffect:=
                                    StrToFloat( XMLSavedGameItemSub4.Attributes['powerGencFx'], FCVdiFormat );
                                 EnumIndex:=GetEnumValue(TypeInfo(TFCEdipFunctions), XMLSavedGameItemSub4.Attributes['Func'] );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function:=TFCEdipFunctions(EnumIndex);
                                 if EnumIndex=-1
                                 then raise Exception.Create( 'bad gamesave loading w/infra function: '+XMLSavedGameItemSub4.Attributes['Func'] );
                                 case FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function of
                                    fEnergy: FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fEnOutput:=StrToFloat( XMLSavedGameItemSub4.Attributes['energyOut'], FCVdiFormat );

                                    fHousing:
                                    begin
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousPopulationCapacity:=XMLSavedGameItemSub4.Attributes['PCAP'];
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousQualityOfLife:=XMLSavedGameItemSub4.Attributes['QOL'];
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousCalculatedVolume:=XMLSavedGameItemSub4.Attributes['vol'];
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousCalculatedSurface:=XMLSavedGameItemSub4.Attributes['surf'];
                                    end;

                                    fIntelligence:;

                                    fMiscellaneous:;

                                    fProduction:
                                    begin
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdSurveyedSpot:=XMLSavedGameItemSub4.Attributes['surveyedSpot'];
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdSurveyedRegion:=XMLSavedGameItemSub4.Attributes['surveyedRegion'];
                                       FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdResourceSpot:=XMLSavedGameItemSub4.Attributes['resourceSpot'];
                                       Count4:=0;
                                       XMLSavedGameItemSub5:=XMLSavedGameItemSub4.ChildNodes.First;
                                       while XMLSavedGameItemSub5<>nil do
                                       begin
                                          inc( Count4 );
                                          EnumIndex:=GetEnumValue( TypeInfo( TFCEdipProductionModes ), XMLSavedGameItemSub5.Attributes['prodModeType'] );
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_type:=TFCEdipProductionModes( EnumIndex );
                                          if EnumIndex=-1
                                          then raise Exception.Create( 'bad gamesave loading w/infra prod mode type: '+XMLSavedGameItemSub5.Attributes['prodModeType'] );
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_isDisabled:=XMLSavedGameItemSub5.Attributes['isDisabled'];
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_energyConsumption:=StrToFloat( XMLSavedGameItemSub5.Attributes['energyCons'], FCVdiFormat );
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_matrixItemMax:=XMLSavedGameItemSub5.Attributes['matrixItemMax'];
                                          Count5:=0;
                                          XMLSavedGameItemSub6:=XMLSavedGameItemSub5.ChildNodes.First;
                                          while XMLSavedGameItemSub6<>nil do
                                          begin
                                             inc( Count5 );
                                             FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_linkedColonyMatrixItems[Count5].LMII_matrixItemIndex
                                                :=XMLSavedGameItemSub6.Attributes['pmitmIndex'];
                                             FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_linkedColonyMatrixItems[Count5].LMII_matrixItem_ProductionModeIndex
                                                :=XMLSavedGameItemSub6.Attributes['pmIndex'];
                                             XMLSavedGameItemSub6:=XMLSavedGameItemSub6.NextSibling;
                                          end;
                                          XMLSavedGameItemSub5:=XMLSavedGameItemSub5.NextSibling;
                                       end;
                                    end;
                                 end; //==END== case FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function ==//
                                 XMLSavedGameItemSub4:=XMLSavedGameItemSub4.NextSibling;
                              end; //==END== while XMLSavedGameItemSub4<>nil do ==//
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end; //==END== while XMLSavedGameItemSub3<>nil ==//
                        end //==END== else if XMLSavedGameItemSub2.NodeName='colSettlement' ==//
                        {.colony's CAB queue}
                        else if XMLSavedGameItemSub2.NodeName='colCAB' then
                        begin
                           Count2:=1;
                           Count3:=Length( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue )-1;
                           while Count2<=Count3 do
                           begin
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2], 1 );
                              inc( Count2 );
                           end;
                           Count2:=0;
                           Count3:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count3 );
                              Count2:=XMLSavedGameItemSub3.Attributes['settlement'];
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2], Count3+1 );
                              Count4:=XMLSavedGameItemSub3.Attributes['infraIdx'];
                              FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2, Count3]:=Count4;
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        {.colony's production matrix}
                        else if XMLSavedGameItemSub2.NodeName='colProdMatrix' then
                        begin
                           SetLength(FCDdgEntities[Count].E_colonies[Count].C_productionMatrix, 1);
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count2 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix, Count2+1 );
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productToken:=XMLSavedGameItemSub3.Attributes['token'];
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storageIndex:=XMLSavedGameItemSub3.Attributes['storIdx'];
                              EnumIndex:=GetEnumValue( TypeInfo( TFCEdipStorageTypes ), XMLSavedGameItemSub3.Attributes['storageType'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storage:=TFCEdipStorageTypes(EnumIndex);
                              if EnumIndex=-1
                              then raise Exception.Create( 'bad gamesave loading w/production matrix item storage type: '+XMLSavedGameItemSub3.Attributes['storageType'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_globalProductionFlow:=StrToFloat( XMLSavedGameItemSub3.Attributes['globalProdFlow'], FCVdiFormat );
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes, 1);
                              Count3:=0;
                              XMLSavedGameItemSub4:=XMLSavedGameItemSub3.ChildNodes.First;
                              while XMLSavedGameItemSub4<>nil do
                              begin
                                 inc( Count3 );
                                 SetLength( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes, Count3+1 );
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationSettlement:=XMLSavedGameItemSub4.Attributes['locSettle'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationInfrastructure:=XMLSavedGameItemSub4.Attributes['locInfra'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationProductionModeIndex:=XMLSavedGameItemSub4.Attributes['locPModeIndex'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_isDisabledByProductionSegment:=XMLSavedGameItemSub4.Attributes['isDisabledPS'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_productionFlow:=StrToFloat( XMLSavedGameItemSub4.Attributes['prodFlow'], FCVdiFormat );
                                 XMLSavedGameItemSub4:=XMLSavedGameItemSub4.NextSibling;
                              end;
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        {.colony's storage}
                        else if XMLSavedGameItemSub2.NodeName='colStorage'
                        then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidCurrent:=StrToFloat( XMLSavedGameItemSub2.Attributes['capSolidCur'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidMax:=StrToFloat( XMLSavedGameItemSub2.Attributes['capSolidMax'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidCurrent:=StrToFloat( XMLSavedGameItemSub2.Attributes['capLiquidCur'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidMax:=StrToFloat( XMLSavedGameItemSub2.Attributes['capLiquidMax'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasCurrent:=StrToFloat( XMLSavedGameItemSub2.Attributes['capGasCur'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasMax:=StrToFloat( XMLSavedGameItemSub2.Attributes['capGasMax'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioCurrent:=StrToFloat( XMLSavedGameItemSub2.Attributes['capBioCur'], FCVdiFormat );
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioMax:=StrToFloat( XMLSavedGameItemSub2.Attributes['capBioMax'], FCVdiFormat );
                           SetLength(FCDdgEntities[Count].E_colonies[Count1].C_storedProducts, 1);
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count2 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_storedProducts, Count2+1 );
                              FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_token:=XMLSavedGameItemSub3.Attributes['token'];
                              FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_unit:=StrToFloat( XMLSavedGameItemSub3.Attributes['unit'], FCVdiFormat );
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        else if XMLSavedGameItemSub2.NodeName='colReserves' then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_reserveOxygen:=XMLSavedGameItemSub2.Attributes['oxygen'];
                           FCDdgEntities[Count].E_colonies[Count1].C_reserveFood:=XMLSavedGameItemSub2.Attributes['food'];
                           SetLength( FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex, 1 );
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc( Count2 );
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex, Count2+1 );
                              FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex[Count2]:=XMLSavedGameItemSub3.Attributes['index'];
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                           FCDdgEntities[Count].E_colonies[Count1].C_reserveWater:=XMLSavedGameItemSub2.Attributes['water'];
                        end;
                        XMLSavedGameItemSub2:=XMLSavedGameItemSub2.NextSibling;
                     end; //==END== while XMLSavedGameItemSub2<>nil do ==//
                     XMLSavedGameItemSub1:=XMLSavedGameItemSub1.NextSibling;
                  end; //==END== while GLxmlCol<>nil do ==//
               end //==END== else if GLxmlEntSubRoot.NodeName='entColonies' ==//
               else if XMLSavedGameItemSub.NodeName='entSPMset' then
               begin
                  FCDdgEntities[Count].E_spmMod_Cohesion:=XMLSavedGameItemSub.Attributes['modCoh'];
                  FCDdgEntities[Count].E_spmMod_Tension:=XMLSavedGameItemSub.Attributes['modTens'];
                  FCDdgEntities[Count].E_spmMod_Security:=XMLSavedGameItemSub.Attributes['modSec'];
                  FCDdgEntities[Count].E_spmMod_Education:=XMLSavedGameItemSub.Attributes['modEdu'];
                  FCDdgEntities[Count].E_spmMod_Natality:=XMLSavedGameItemSub.Attributes['modNat'];
                  FCDdgEntities[Count].E_spmMod_Health:=XMLSavedGameItemSub.Attributes['modHeal'];
                  FCDdgEntities[Count].E_spmMod_Bureaucracy:=XMLSavedGameItemSub.Attributes['modBur'];
                  FCDdgEntities[Count].E_spmMod_Corruption:=XMLSavedGameItemSub.Attributes['modCorr'];
                  Count1:=0;
                  XMLSavedGameItemSub1:=XMLSavedGameItemSub.ChildNodes.First;
                  while XMLSavedGameItemSub1<>nil do
                  begin
                     inc( Count1 );
                     SetLength( FCDdgEntities[Count].E_spmSettings, Count1+1 );
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_token:=XMLSavedGameItemSub1.Attributes['token'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_duration:=XMLSavedGameItemSub1.Attributes['duration'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_ucCost:=XMLSavedGameItemSub1.Attributes['ucCost'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy:=XMLSavedGameItemSub1.Attributes['ispolicy'];
                     if FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy then
                     begin
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtIsSet:=XMLSavedGameItemSub1.Attributes['isSet'];
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtAcceptanceProbability:=XMLSavedGameItemSub1.Attributes['aprob'];
                     end
                     else if not FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy then
                     begin
                        EnumIndex:=GetEnumValue( TypeInfo( TFCEdgBeliefLevels ), XMLSavedGameItemSub1.Attributes['belieflvl'] );
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPfBeliefLevel:=TFCEdgBeliefLevels( EnumIndex );
                        if EnumIndex=-1
                        then raise Exception.Create( 'bad gamesave loading w/meme belief level: '+XMLSavedGameItemSub1.Attributes['belieflvl'] );
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPfSpreadValue:=XMLSavedGameItemSub1.Attributes['spreadval'];
                     end;
                     XMLSavedGameItemSub1:=XMLSavedGameItemSub1.NextSibling;
                  end;
               end; //==END== if GLxmlEntSubRoot.NodeName='entSPMset' ==//
               XMLSavedGameItemSub:=XMLSavedGameItemSub.NextSibling;
            end; //==END== while GLxmlEntSubRoot<>nil do ==//
            inc( Count );
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; //==END== while GLxmlEnt<>nil do ==//
      end; //==END== if GLxmlEntRoot<>nil FOR COLONIES==//
      {.read "msgqueue" saved game item}
      setlength( FCVmsgStoTtl, 1 );
      setlength( FCVmsgStoMsg, 1 );
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMsgQueue');
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            inc(Count);
            SetLength( FCVmsgStoTtl, Count+1 );
            SetLength( FCVmsgStoMsg, Count+1 );
            FCVmsgStoTtl[Count]:=XMLSavedGameItem.Attributes['msgTitle'];
            FCVmsgStoMsg[Count]:=XMLSavedGameItem.Attributes['msgMain'];
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end;
      end; {.if GLxmlGamItm<>nil}
   end //==END== if (DirectoryExists(GLcurrDir)) and (FileExists(GLcurrDir+'\'+GLcurrG)) ==//
   else FCVdgPlayer.P_viewStarSystem:='';
   {.free the memory}
   FCWinMain.FCXMLsave.Active:=false;
   FCWinMain.FCXMLsave.FileName:='';
end;

procedure FCMdFSG_Game_Save;
{:Purpose: save the current game.
    Additions:
      -2012Aug19- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (o)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (_)local methods
                     (_)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (x)use of enumindex                 (o)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012May24- *add: CPS - Viability thresholds.
      -2012May13- *add: CSM event: etRveFoodShortage, addition of the direct death period + death fractional value.
      -2012May12- *add: CSM event: etRveOxygenShortage, etRveWaterOverload, etRveWaterShortage, etRveFoodOverload and etRveFoodShortage.
      -2012May06- *add: CSM event: etRveOxygenOverload.
      -2012Apr29- *mod: CSM event token are saved in their full names now.
                  *mod: CSM event modifiers and data are saved according to the new changes in the data structure.
      -2012Apr15- *add: completion of colony's reserves.
      -2012Mar14- *fix: owned infrastructures - forgot to include MISC and INTELLIGENCE function for saving them and their possible specific data.
      -2012Mar13- *add: selective saving for otEcoIndustrialForce data.
      -2012Mar11- *add: viability objective: otEcoIndustrialForce.
      -2012Feb09- *add: save directly the CPS objective type.
      -2012Jan11- *add: production matrix / CPMI_storageType.
      -2012Jan04- *add: owned infrastructures / power generated by custom effect.
      -2011Dec12- *mod: owned infrastructures / production function / optimize the saving if no production mode is initialized yet (in the case when the infrastructure is in assembling/building.
      -2011Dec11- *mod: transfert the disable state for production mode of the production matrix into the owned infrastructure data structure.
      -2011Dec08- *add: owned infrastructures / production function / PM_matrixItemMax.
      -2011Nov30- *add: complete surveyed resource spot data for infrastructures.
      -2011Nov18- *add: update hardcoded resource data w/ updated data structure.
      -2011Nov07- *add: complete production mode data for owned infrastructures.
                  *add: put full function name for owned infrastuctures.
      -2011Nov01- *add: complete the production matrix.
      -2011Oct19- *add: add, in list of surveyed resources, the specificity concerning the Ore field type.
      -2011Oct17- *add: complete the production matrix saving.
      -2011Oct10- *add: list for surveyed resources.
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
      XMLSavedGame
      ,XMLSavedGameItem
      ,XMLSavedGameItemSub
      ,XMLSavedGameItemSub1
      ,XMLSavedGameItemSub2
      ,XMLSavedGameItemSub3
      ,XMLSavedGameItemSub4
      ,XMLSavedGameItemSub5
      ,XMLSavedGameItemSub6
      ,XMLSavedGameItemSub7: IXMLNode;

      Count
      ,Count1
      ,Count2
      ,Count3
      ,Count4
      ,Count5
      ,Max
      ,Max1
      ,Max2
      ,Max3: integer;

      CurrentDirectory
      ,CurrentSavedGameFile: string;
begin
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set( tphPAUSE );
   CurrentDirectory:=FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName;
   CurrentSavedGameFile:=IntToStr( FCVdgPlayer.P_currentTimeYear )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeMonth )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeDay )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeHour )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeMinut )
      +'-'+IntToStr( FCVdgPlayer.P_currentTimeTick )
      +'.xml';
   {.create the save directory if needed}
   if not DirectoryExists( CurrentDirectory )
   then MkDir( CurrentDirectory );
   {.clear the old file if it exists}
   if FileExists( CurrentDirectory+'\'+CurrentSavedGameFile )
   then DeleteFile( pchar( CurrentDirectory+'\'+CurrentSavedGameFile ) );
   FCMdF_ConfigurationFile_Save(true);
   {.link and activate TXMLDocument}
   FCWinMain.FCXMLsave.Active:=true;
   {.create the root node of the saved game file}
   XMLSavedGame:=FCWinMain.FCXMLsave.AddChild('savedgfile');
   {.create "main" item}
   XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfMain' );
   XMLSavedGameItem.Attributes['gName']:= FCVdgPlayer.P_gameName;
   XMLSavedGameItem.Attributes['facAlleg']:= FCVdgPlayer.P_allegianceFaction;
   XMLSavedGameItem.Attributes['plyrsSSLoc']:= FCVdgPlayer.P_viewStarSystem;
   XMLSavedGameItem.Attributes['plyrsStLoc']:= FCVdgPlayer.P_viewStar;
   XMLSavedGameItem.Attributes['plyrsOObjLoc']:= FCVdgPlayer.P_viewOrbitalObject;
   XMLSavedGameItem.Attributes['plyrsatLoc']:=FCVdgPlayer.P_viewSatellite;
   {.create "timeframe" item}
   XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfTimeFr' );
   XMLSavedGameItem.Attributes['tfTick']:= FCVdgPlayer.P_currentTimeTick;
   XMLSavedGameItem.Attributes['tfMin']:= FCVdgPlayer.P_currentTimeMinut;
   XMLSavedGameItem.Attributes['tfHr']:= FCVdgPlayer.P_currentTimeHour;
   XMLSavedGameItem.Attributes['tfDay']:= FCVdgPlayer.P_currentTimeDay;
   XMLSavedGameItem.Attributes['tfMth']:= FCVdgPlayer.P_currentTimeMonth;
   XMLSavedGameItem.Attributes['tfYr']:= FCVdgPlayer.P_currentTimeYear;
   {.create "status" item}
   XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfStatus' );
   XMLSavedGameItem.Attributes['statEco']:=GetEnumName( TypeInfo( TFCEdgPlayerFactionStatus ), Integer( FCVdgPlayer.P_economicStatus ) );
   XMLSavedGameItem.Attributes['statEcoThr']:=FCVdgPlayer.P_economicViabilityThreshold;
   XMLSavedGameItem.Attributes['statSoc']:=GetEnumName( TypeInfo( TFCEdgPlayerFactionStatus ), Integer( FCVdgPlayer.P_socialStatus ) );
   XMLSavedGameItem.Attributes['statSocThr']:=FCVdgPlayer.P_socialViabilityThreshold;
   XMLSavedGameItem.Attributes['statSpMil']:=GetEnumName( TypeInfo( TFCEdgPlayerFactionStatus ), Integer( FCVdgPlayer.P_militaryStatus ) );
   XMLSavedGameItem.Attributes['statSpMilThr']:=FCVdgPlayer.P_militaryViabilityThreshold;
   {.create "cps" saved game item}
   if FCcps<>nil then
   begin
      Max:=length( FCcps.CPSviabObj );
      XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfCPS' );
      XMLSavedGameItem.Attributes['cpsEnabled']:=FCcps.CPSisEnabled;
      XMLSavedGameItem.Attributes['cpsCVS']:=FCcps.FCF_CVS_Get;
      XMLSavedGameItem.Attributes['cpsTlft']:=FCcps.FCF_TimeLeft_Get( true );
      XMLSavedGameItem.Attributes['cpsInt']:=FCcps.FCF_CredLineInterest_Get;
      XMLSavedGameItem.Attributes['cpsCredU']:=FCcps.FCF_CredLine_Get( true, true );
      XMLSavedGameItem.Attributes['cpsCredM']:=FCcps.FCF_CredLine_Get( false, true );
      Count:=1;
      while Count<=Max-1 do
      begin
         XMLSavedGameItemSub:=XMLSavedGameItem.AddChild( 'gfViabObj' );
         XMLSavedGameItemSub.Attributes['objTp']:=GetEnumName( TypeInfo( TFCEcpsoObjectiveTypes ), Integer( FCcps.CPSviabObj[Count].CPSO_type ) );
         XMLSavedGameItemSub.Attributes['score']:=FCcps.CPSviabObj[Count].CPSO_score;
         if FCcps.CPSviabObj[Count].CPSO_type=otEcoIndustrialForce then
         begin
            XMLSavedGameItemSub.Attributes['product']:=FCcps.CPSviabObj[Count].CPSO_ifProduct;
            XMLSavedGameItemSub.Attributes['threshold']:=FloatToStr( FCcps.CPSviabObj[Count].CPSO_ifThreshold, FCVdiFormat );
         end;
         inc( Count );
      end;
   end; //==END== if FCcps<>nil ==//
   {.create "taskinprocess" saved game item}
   Max:=length( FCGtskListInProc );
   if Max>1 then
   begin
      XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfTskLstinProc' );
      Count:=1;
      while Count<=Max-1 do
      begin
         XMLSavedGameItemSub:=XMLSavedGameItem.AddChild('gfTskInProc');
         XMLSavedGameItemSub.Attributes['tipActTp']:=GetEnumName( TypeInfo( TFCEdmtTasks ), Integer( FCGtskListInProc[Count].T_type ) );
         XMLSavedGameItemSub.Attributes['tipPhase']:=FCGtskListInProc[Count].T_tMColCurrentPhase;
//         XMLSavedGameItemSub.Attributes['tipTgtTp']:=GetEnumName( TypeInfo( TFCEdmtTaskTargets ), Integer( FCGtskListInProc[Count].TITP_ctldType ) );
         XMLSavedGameItemSub.Attributes['tipTgtFac']:=FCGtskListInProc[Count].T_entity;
         XMLSavedGameItemSub.Attributes['tipTgtIdx']:=FCGtskListInProc[Count].TITP_ctldIdx;
         XMLSavedGameItemSub.Attributes['tipTimeOrg']:=FCGtskListInProc[Count].TITP_timeOrg;
         XMLSavedGameItemSub.Attributes['tipDura']:=FCGtskListInProc[Count].TITP_duration;
         XMLSavedGameItemSub.Attributes['tipInterv']:=FCGtskListInProc[Count].TITP_interval;
         XMLSavedGameItemSub.Attributes['tipOrgTp']:=GetEnumName( TypeInfo( TFCEdmtTaskTargets ), Integer( FCGtskListInProc[Count].TITP_orgType ) );
         XMLSavedGameItemSub.Attributes['tipOrgIdx']:=FCGtskListInProc[Count].TITP_orgIdx;
         XMLSavedGameItemSub.Attributes['tipDestTp']:=GetEnumName( TypeInfo( TFCEdmtTaskTargets ), Integer( FCGtskListInProc[Count].TITP_destType ) );
         XMLSavedGameItemSub.Attributes['tipDestIdx']:=FCGtskListInProc[Count].TITP_destIdx;
         XMLSavedGameItemSub.Attributes['tipRegIdx']:=FCGtskListInProc[Count].TITP_regIdx;
         XMLSavedGameItemSub.Attributes['tipVelCr']:=FloatToStr( FCGtskListInProc[Count].TITP_velCruise, FCVdiFormat );
         XMLSavedGameItemSub.Attributes['tipTimeTcr']:=FCGtskListInProc[Count].TITP_timeToCruise;
         XMLSavedGameItemSub.Attributes['tipTimeTdec']:=FCGtskListInProc[Count].TITP_timeDecel;
         XMLSavedGameItemSub.Attributes['tipTime2Xfrt']:=FCGtskListInProc[Count].TITP_time2xfert;
         XMLSavedGameItemSub.Attributes['tipTime2XfrtDec']:=FCGtskListInProc[Count].TITP_time2xfert2decel;
         XMLSavedGameItemSub.Attributes['tipVelFin']:=FloatToStr( FCGtskListInProc[Count].TITP_velFinal, FCVdiFormat );
         XMLSavedGameItemSub.Attributes['tipTimeTfin']:=FCGtskListInProc[Count].TITP_timeToFinal;
         XMLSavedGameItemSub.Attributes['tipAccelBtick']:=FloatToStr( FCGtskListInProc[Count].TITP_accelbyTick, FCVdiFormat );
         XMLSavedGameItemSub.Attributes['tipUsedRM']:=FloatToStr( FCGtskListInProc[Count].TITP_usedRMassV, FCVdiFormat );
         XMLSavedGameItemSub.Attributes['tipStr1']:=FCGtskListInProc[Count].TITP_str1;
         XMLSavedGameItemSub.Attributes['tipStr2']:=FCGtskListInProc[Count].TITP_str1;
         XMLSavedGameItemSub.Attributes['tipInt1']:=FCGtskListInProc[Count].TITP_int1;
         inc(Count);
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then... for taskinprocess}
   {.all surveyed resources}
   Max:=length( FCVdgPlayer.P_surveyedResourceSpots );
   if Max>1 then
   begin
      XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfSurveyedResourceSpots' );
      Count:=1;
      while Count<=Max-1 do
      begin
         XMLSavedGameItemSub:=XMLSavedGameItem.AddChild( 'gfSpotLocation' );
         XMLSavedGameItemSub.Attributes['oobj']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken;
         XMLSavedGameItemSub.Attributes['ssysIdx']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_starSystem;
         XMLSavedGameItemSub.Attributes['starIdx']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_star;
         XMLSavedGameItemSub.Attributes['oobjIdx']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_orbitalObject;
         XMLSavedGameItemSub.Attributes['satIdx']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_satellite;
         Max1:=length( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions )-1;
         Count1:=1;
         while Count1<=Max1 do
         begin
            Max2:=length( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots )-1;
            if Max2>0 then
            begin
               XMLSavedGameItemSub1:=XMLSavedGameItemSub.AddChild( 'gfSpotRegion' );
               XMLSavedGameItemSub1.Attributes['regionIdx']:=Count1;
               Count2:=1;
               while Count2<=Max2 do
               begin
                  XMLSavedGameItemSub2:=XMLSavedGameItemSub1.AddChild( 'gfRsrcSpot' );
                  XMLSavedGameItemSub2.Attributes['spotType']:=GetEnumName(TypeInfo(TFCEduResourceSpotTypes), Integer(FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_type));
                  XMLSavedGameItemSub2.Attributes['meanQualCoef']:=FloatToStr( FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_meanQualityCoefficient, FCVdiFormat );
                  XMLSavedGameItemSub2.Attributes['spotSizCurr']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_spotSizeCurrent;
                  XMLSavedGameItemSub2.Attributes['spotSizeMax']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_spotSizeMax;
                  if FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_type=rstOreField then
                  begin
                     XMLSavedGameItemSub2.Attributes['oreCarbo']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiCarbonaceous;
                     XMLSavedGameItemSub2.Attributes['oreMetal']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiMetallic;
                     XMLSavedGameItemSub2.Attributes['oreRare']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiRare;
                     XMLSavedGameItemSub2.Attributes['oreUra']:=FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_tOFiUranium;
                  end;
                  inc(Count2);
               end;
            end;
            inc( Count1 );
         end;
         inc( Count );
      end; //==END== while Count<=Count1-1 do ==//
   end; //==END== if Count1>1 then... for surveyed resource spots ==//
   {.create "CSM" saved game item}
   Max:=length( FCDdgCSMPhaseSchedule );
   if Max>1 then
   begin
      XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfCSM' );
      Count:=1;
      while Count<=Max-1 do
      begin
         XMLSavedGameItemSub:=XMLSavedGameItem.AddChild( 'csmPhList' );
         XMLSavedGameItemSub.Attributes['csmTick']:=FCDdgCSMPhaseSchedule[Count].CSMPS_ProcessAtTick;
         Count1:=0;
         while Count1<=FCCdiFactionsMax do
         begin
            Max2:=length( FCDdgCSMPhaseSchedule[Count].CSMPS_colonies[Count1] )-1;
            Count2:=1;
            if Max2>0 then
            begin
               while Count2<=Max2 do
               begin
                  XMLSavedGameItemSub1:=XMLSavedGameItemSub.AddChild( 'csmPhase' );
                  XMLSavedGameItemSub1.Attributes['fac']:=Count1;
                  XMLSavedGameItemSub1.Attributes['colony']:=FCDdgCSMPhaseSchedule[Count].CSMPS_colonies[Count1, Count2];
                  inc( Count2 );
               end;
            end;
            inc( Count1 );
         end;
         inc( Count );
      end; //==END== while GScount<=GSlength-1 ==//
   end; //==END== if GSlength>1 for CSM ==//
   {.create entities section}
   XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfEntities' );
   Count:=0;
   while Count<=FCCdiFactionsMax do
   begin
      XMLSavedGameItemSub:=XMLSavedGameItem.AddChild( 'entity' );
      XMLSavedGameItemSub.Attributes['token']:=FCDdgEntities[Count].E_token;
      XMLSavedGameItemSub.Attributes['lvl']:=FCDdgEntities[Count].E_factionLevel;
      XMLSavedGameItemSub.Attributes['bur']:=FCDdgEntities[Count].E_bureaucracy;
      XMLSavedGameItemSub.Attributes['corr']:=FCDdgEntities[Count].E_corruption;
      XMLSavedGameItemSub.Attributes['hqHlvl']:=GetEnumName( TypeInfo( TFCEdgHeadQuarterStatus ), Integer( FCDdgEntities[Count].E_hqHigherLevel ) );
      XMLSavedGameItemSub.Attributes['UCrve']:=FloatToStr( FCDdgEntities[Count].E_ucInAccount, FCVdiFormat );
      Max1:=Length( FCDdgEntities[Count].E_spaceUnits )-1;
      if Max1>0 then
      begin
         XMLSavedGameItemSub1:=XMLSavedGameItemSub.AddChild( 'entOwnSpU' );
         Count1:=1;
         while Count1<=Max1 do
         begin
            XMLSavedGameItemSub2:=XMLSavedGameItemSub1.AddChild( 'entSpU' );
            XMLSavedGameItemSub2.Attributes['tokenId']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_token;
            XMLSavedGameItemSub2.Attributes['tokenName']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_name;
            XMLSavedGameItemSub2.Attributes['desgnId']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_designToken;
            XMLSavedGameItemSub2.Attributes['ssLoc']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationStarSystem;
            XMLSavedGameItemSub2.Attributes['stLoc']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationStar;
            XMLSavedGameItemSub2.Attributes['oobjLoc']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationOrbitalObject;
            XMLSavedGameItemSub2.Attributes['satLoc']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationSatellite;
            XMLSavedGameItemSub2.Attributes['TdObjIdx']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_linked3dObject;
            XMLSavedGameItemSub2.Attributes['xLoc']:=FloatToStr( FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewX, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['zLoc']:=FloatToStr( FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewZ, FCVdiFormat );
            Max2:=length( FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits )-1;
            XMLSavedGameItemSub2.Attributes['docked']:=Max2;
            Count2:=1;
            while Count2<=Max2 do
            begin
               XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'entSpUdckd' );
               XMLSavedGameItemSub3.Attributes['index']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits[Count2].SUDL_index;
               inc( Count2 );
            end;
            XMLSavedGameItemSub2.Attributes['taskId']:=FCDdgEntities[Count].E_spaceUnits[Count1].SU_assignedTask;
            XMLSavedGameItemSub2.Attributes['status']:=GetEnumName( TypeInfo( TFCEdgSpaceUnitStatus ), Integer( FCDdgEntities[Count].E_spaceUnits[Count1].SU_status ) );
            XMLSavedGameItemSub2.Attributes['dV']:=FloatToStr( FCDdgEntities[Count].E_spaceUnits[Count1].SU_deltaV, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['TdMov']:=FloatToStr( FCDdgEntities[Count].E_spaceUnits[Count1].SU_3dVelocity, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['availRMass']:=FloatToStr( FCDdgEntities[Count].E_spaceUnits[Count1].SU_reactionMass, FCVdiFormat );
            inc( Count1 );
         end; {.while Count1<=GSspuMax}
      end; //==END== if GSspuMax>0 ==//
      Max1:=Length( FCDdgEntities[Count].E_colonies )-1;
      if Max1>0 then
      begin
         XMLSavedGameItemSub1:=XMLSavedGameItemSub.AddChild( 'entColonies' );
         Count1:=1;
         while Count1<=Max1 do
         begin
            XMLSavedGameItemSub2:=XMLSavedGameItemSub1.AddChild( 'entColony' );
            XMLSavedGameItemSub2.Attributes['prname']:=FCDdgEntities[Count].E_colonies[Count1].C_name;
            XMLSavedGameItemSub2.Attributes['fndyr']:=FCDdgEntities[Count].E_colonies[Count1].C_foundationDateYear;
            XMLSavedGameItemSub2.Attributes['fndmth']:=FCDdgEntities[Count].E_colonies[Count1].C_foundationDateMonth;
            XMLSavedGameItemSub2.Attributes['fnddy']:=FCDdgEntities[Count].E_colonies[Count1].C_foundationDateDay;
            XMLSavedGameItemSub2.Attributes['csmtime']:=FCDdgEntities[Count].E_colonies[Count1].C_nextCSMsessionInTick;
            XMLSavedGameItemSub2.Attributes['locssys']:=FCDdgEntities[Count].E_colonies[Count1].C_locationStarSystem;
            XMLSavedGameItemSub2.Attributes['locstar']:=FCDdgEntities[Count].E_colonies[Count1].C_locationStar;
            XMLSavedGameItemSub2.Attributes['locoobj']:=FCDdgEntities[Count].E_colonies[Count1].C_locationOrbitalObject;
            XMLSavedGameItemSub2.Attributes['locsat']:=FCDdgEntities[Count].E_colonies[Count1].C_locationSatellite;
            XMLSavedGameItemSub2.Attributes['collvl']:=GetEnumName( TypeInfo( TFCEdgColonyLevels ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_level ) );
            XMLSavedGameItemSub2.Attributes['hqpresence']:=GetEnumName( TypeInfo( TFCEdgHeadQuarterStatus ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_hqPresence ) );
            XMLSavedGameItemSub2.Attributes['dcohes']:=FCDdgEntities[Count].E_colonies[Count1].C_cohesion;
            XMLSavedGameItemSub2.Attributes['dsecu']:=FCDdgEntities[Count].E_colonies[Count1].C_security;
            XMLSavedGameItemSub2.Attributes['dtens']:=FCDdgEntities[Count].E_colonies[Count1].C_tension;
            XMLSavedGameItemSub2.Attributes['dedu']:=FCDdgEntities[Count].E_colonies[Count1].C_instruction;
            XMLSavedGameItemSub2.Attributes['csmPCAP']:=FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_PopulationCapacity;
            XMLSavedGameItemSub2.Attributes['csmSPL']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_SpaceLevel, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['csmQOL']:=FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_QualityOfLife;
            XMLSavedGameItemSub2.Attributes['csmHEAL']:=FCDdgEntities[Count].E_colonies[Count1].C_csmHealth_HealthLevel;
            XMLSavedGameItemSub2.Attributes['csmEnCons']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Consumption, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['csmEnGen']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Generation, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['csmEnStorCurr']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageCurrent, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['csmEnStorMax']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageMax, FCVdiFormat );
            XMLSavedGameItemSub2.Attributes['eiOut']:=FCDdgEntities[Count].E_colonies[Count1].C_economicIndustrialOutput;
            {.colony population}
            XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colPopulation' );
            XMLSavedGameItemSub3.Attributes['popTtl']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_total;
            XMLSavedGameItemSub3.Attributes['popMeanAge']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_meanAge, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['popDRate']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathRate, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['popDStack']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathStack, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['popBRate']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthRate, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['popBStack']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthStack, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['popColon']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classColonist;
            XMLSavedGameItemSub3.Attributes['popColonAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classColonistAssigned;
            XMLSavedGameItemSub3.Attributes['popOff']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerOfficer;
            XMLSavedGameItemSub3.Attributes['popOffAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerOfficerAssigned;
            XMLSavedGameItemSub3.Attributes['popMisSpe']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerMissionSpecialist;
            XMLSavedGameItemSub3.Attributes['popMisSpeAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAerMissionSpecialistAssigned;
            XMLSavedGameItemSub3.Attributes['popBiol']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioBiologist;
            XMLSavedGameItemSub3.Attributes['popBiolAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioBiologistAssigned;
            XMLSavedGameItemSub3.Attributes['popDoc']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioDoctor;
            XMLSavedGameItemSub3.Attributes['popDocAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classBioDoctorAssigned;
            XMLSavedGameItemSub3.Attributes['popTech']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndTechnician;
            XMLSavedGameItemSub3.Attributes['popTechAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndTechnicianAssigned;
            XMLSavedGameItemSub3.Attributes['popEng']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndEngineer;
            XMLSavedGameItemSub3.Attributes['popEngAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classIndEngineerAssigned;
            XMLSavedGameItemSub3.Attributes['popSold']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilSoldier;
            XMLSavedGameItemSub3.Attributes['popSoldAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilSoldierAssigned;
            XMLSavedGameItemSub3.Attributes['popComm']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilCommando;
            XMLSavedGameItemSub3.Attributes['popCommAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilCommandoAssigned;
            XMLSavedGameItemSub3.Attributes['popPhys']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyPhysicist;
            XMLSavedGameItemSub3.Attributes['popPhysAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyPhysicistAssigned;
            XMLSavedGameItemSub3.Attributes['popAstro']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyAstrophysicist;
            XMLSavedGameItemSub3.Attributes['popAstroAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classPhyAstrophysicistAssigned;
            XMLSavedGameItemSub3.Attributes['popEcol']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcologist;
            XMLSavedGameItemSub3.Attributes['popEcolAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcologistAssigned;
            XMLSavedGameItemSub3.Attributes['popEcof']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcoformer;
            XMLSavedGameItemSub3.Attributes['popEcofAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classEcoEcoformerAssigned;
            XMLSavedGameItemSub3.Attributes['popMedian']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAdmMedian;
            XMLSavedGameItemSub3.Attributes['popMedianAssign']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classAdmMedianAssigned;
            XMLSavedGameItemSub3.Attributes['popRebels']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classRebels;
            XMLSavedGameItemSub3.Attributes['popMilitia']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_classMilitia;
            XMLSavedGameItemSub3.Attributes['wcpTotal']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPtotal, FCVdiFormat );
            XMLSavedGameItemSub3.Attributes['wcpAssignPpl']:=FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPassignedPeople;
            {.colony events}
            Max2:=length( FCDdgEntities[Count].E_colonies[Count1].C_events );
            if Max2>1 then
            begin
               XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colEvents' );
               Count2:=1;
               while Count2<=Max2-1 do
               begin
                  XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'Event' );
                  XMLSavedGameItemSub4.Attributes['token']:=GetEnumName( TypeInfo( TFCEdgColonyEvents ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_type ) );
                  case FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_type of
                     ceColonyEstablished:
                     begin
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCEstTensionMod;
                        XMLSavedGameItemSub4.Attributes['modSecurity']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCEstSecurityMod;
                     end;

                     ceUnrest, ceUnrest_Recovering:
                     begin
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCUnEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tCUnTensionMod;
                     end;

                     ceSocialDisorder, ceSocialDisorder_Recovering:
                     begin
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tSDisEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tSDisTensionMod;
                     end;

                     ceUprising, ceUprising_Recovering:
                     begin
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tUpEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tUpTensionMod;
                     end;

                     ceDissidentColony: ;

                     ceHealthEducationRelation:
                     begin
                        XMLSavedGameItemSub4.Attributes['modInstruction']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tHERelEducationMod;
                     end;

                     ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering:
                     begin
                        XMLSavedGameItemSub4.Attributes['modCohesion']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tGDestCohesionMod;
                     end;

                     ceOxygenProductionOverload:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupported']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOPOvPercentPopulationNotSupported;
                     end;

                     ceOxygenShortage, ceWaterShortage_Recovering:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShPercentPopulationNotSupportedAtCalculation;
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShTensionMod;
                        XMLSavedGameItemSub4.Attributes['modHealth']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tOShHealthMod;
                     end;

                     ceWaterProductionOverload:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupported']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWPOvPercentPopulationNotSupported;
                     end;

                     ceWaterShortage:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShPercentPopulationNotSupportedAtCalculation;
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShTensionMod;
                        XMLSavedGameItemSub4.Attributes['modHealth']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tWShHealthMod;
                     end;

                     ceFoodProductionOverload:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupported']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFPOvPercentPopulationNotSupported;
                     end;

                     ceFoodShortage:
                     begin
                        XMLSavedGameItemSub4.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShPercentPopulationNotSupportedAtCalculation;
                        XMLSavedGameItemSub4.Attributes['modEcoInd']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShEconomicIndustrialOutputMod;
                        XMLSavedGameItemSub4.Attributes['modTension']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShTensionMod;
                        XMLSavedGameItemSub4.Attributes['modHealth']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShHealthMod;
                        XMLSavedGameItemSub4.Attributes['directDeathPeriod']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShDirectDeathPeriod;
                        XMLSavedGameItemSub4.Attributes['deathFracValue']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShDeathFractionalValue, FCVdiFormat );
                     end;
                  end; //==END== case FCentities[GScount].E_col[Count1].COL_evList[Count2].CSMEV_token of ==//
                  XMLSavedGameItemSub4.Attributes['isres']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_isResident;
                  XMLSavedGameItemSub4.Attributes['duration']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_durationWeeks;
                  XMLSavedGameItemSub4.Attributes['level']:=FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_level;
                  inc( Count2 );
               end; //==END== while Count2<=GSsubL-1 do ==//
            end; //==END== if GSsubL>1 ==//
            {.colony settlements}
            Max2:=length( FCDdgEntities[Count].E_colonies[Count1].C_settlements )-1;
            if Max2>0 then
            begin
               XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colSettlement' );
               Count2:=1;
               while Count2<=Max2 do
               begin
                  XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'Settlement' );
                  XMLSavedGameItemSub4.Attributes['name']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_name;
                  XMLSavedGameItemSub4.Attributes['type']:=GetEnumName( TypeInfo( TFCEdgSettlements ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_settlement ) );
                  XMLSavedGameItemSub4.Attributes['level']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_level;
                  XMLSavedGameItemSub4.Attributes['region']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_locationRegion;
                  Max3:=length( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures )-1;
                  Count3:=1;
                  while Count3<=Max3 do
                  begin
                     XMLSavedGameItemSub5:=XMLSavedGameItemSub4.AddChild( 'setInfra' );
                     XMLSavedGameItemSub5.Attributes['token']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_token;
                     XMLSavedGameItemSub5.Attributes['level']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_level;
                     XMLSavedGameItemSub5.Attributes['status']:=
                        GetEnumName( TypeInfo( TFCEdgInfrastructureStatus ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_status ) );
                     XMLSavedGameItemSub5.Attributes['CABduration']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabDuration;
                     XMLSavedGameItemSub5.Attributes['CABworked']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabWorked;
                     XMLSavedGameItemSub5.Attributes['powerCons']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerConsumption, FCVdiFormat );
                     XMLSavedGameItemSub5.Attributes['powerGencFx']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerGeneratedFromCustomEffect, FCVdiFormat );
                     XMLSavedGameItemSub5.Attributes['Func']:= GetEnumName( TypeInfo( TFCEdipFunctions ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function ) );
                     case FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function of
                        fEnergy:
                        begin
                           XMLSavedGameItemSub5.Attributes['energyOut']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fEnOutput, FCVdiFormat );
                        end;

                        fHousing:
                        begin
                           XMLSavedGameItemSub5.Attributes['PCAP']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousPopulationCapacity;
                           XMLSavedGameItemSub5.Attributes['QOL']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousQualityOfLife;
                           XMLSavedGameItemSub5.Attributes['vol']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousCalculatedVolume;
                           XMLSavedGameItemSub5.Attributes['surf']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fHousCalculatedSurface;
                        end;

                        fIntelligence: ;

                        fMiscellaneous: ;

                        fProduction:
                        begin
                           XMLSavedGameItemSub5.Attributes['surveyedSpot']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdSurveyedSpot;
                           XMLSavedGameItemSub5.Attributes['surveyedRegion']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdSurveyedRegion;
                           XMLSavedGameItemSub5.Attributes['resourceSpot']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdResourceSpot;
                           Count4:=1;
                           while Count4<=FCCdipProductionModesMax do
                           begin
                              if FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_type>pmNone then
                              begin
                                 XMLSavedGameItemSub6:=XMLSavedGameItemSub5.AddChild('prodmode');
                                 XMLSavedGameItemSub6.Attributes['prodModeType']:=GetEnumName( TypeInfo( TFCEdipProductionModes ), Integer(
                                    FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_type
                                    ) );
                                 XMLSavedGameItemSub6.Attributes['isDisabled']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_isDisabled;
                                 XMLSavedGameItemSub6.Attributes['energyCons']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_energyConsumption, FCVdiFormat );
                                 XMLSavedGameItemSub6.Attributes['matrixItemMax']:=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_matrixItemMax;
                                 Count5:=1;
                                 while Count5<=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_matrixItemMax do
                                 begin
                                    XMLSavedGameItemSub7:=XMLSavedGameItemSub6.AddChild('linkedMatrixItem');
                                    XMLSavedGameItemSub7.Attributes['pmitmIndex']
                                       :=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_linkedColonyMatrixItems[Count5].LMII_matrixItemIndex;
                                    XMLSavedGameItemSub7.Attributes['pmIndex']
                                       :=FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_linkedColonyMatrixItems[Count5].LMII_matrixItem_ProductionModeIndex;
                                    inc( Count5 );
                                 end;
                              end
                              else Break;
                              inc( Count4 );
                           end;
                        end;
                     end; //==END== case FCentities[GScount].E_col[Count1].COL_settlements[Count2].CS_infra[Count3].CI_function of ==//
                     inc( Count3 );
                  end; //==END== while Count3<=Max3 do ==//
                  inc( Count2 );
               end; //==END== while Count2<=Max2 do ==//
               {.CAB queue}
               Count2:=1;
               while Count2<=Max2 do
               begin
                  Max3:=length( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2] )-1;
                  if Max3>0 then
                  begin
                     XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colCAB' );
                     Count3:=1;
                     while Count3<=Max3 do
                     begin
                        XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'cabItem' );
                        XMLSavedGameItemSub4.Attributes['settlement']:=Count2;
                        XMLSavedGameItemSub4.Attributes['infraIdx']:=FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2, Count3];
                        inc( Count3 );
                     end;
                  end; //==END== if GScabMax>0 ==//
                  inc( Count2 );
               end;
               {.production matrix}
               Max2:=Length( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix )-1;
               if Max2>0 then
               begin
                  XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colProdMatrix' );
                  Count2:=1;
                  while Count2<=Max2 do
                  begin
                     XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'prodItem' );
                     XMLSavedGameItemSub4.Attributes['token']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productToken;
                     XMLSavedGameItemSub4.Attributes['storIdx']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storageIndex;
                     XMLSavedGameItemSub4.Attributes['storageType']:=GetEnumName( TypeInfo( TFCEdipStorageTypes ), Integer( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storage ) );
                     XMLSavedGameItemSub4.Attributes['globalProdFlow']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_globalProductionFlow, FCVdiFormat );
                     Max3:=length(FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes)-1;
                     if Max3>0 then
                     begin
                        Count3:=1;
                        while Count1<=Max3 do
                        begin
                           XMLSavedGameItemSub5:=XMLSavedGameItemSub4.AddChild( 'prodMode' );
                           XMLSavedGameItemSub5.Attributes['locSettle']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationSettlement;
                           XMLSavedGameItemSub5.Attributes['locInfra']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationInfrastructure;
                           XMLSavedGameItemSub5.Attributes['locPModeIndex']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationProductionModeIndex;
                           XMLSavedGameItemSub5.Attributes['isDisabledPS']:=FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_isDisabledByProductionSegment;
                           XMLSavedGameItemSub5.Attributes['prodFlow']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_productionFlow, FCVdiFormat );
                           inc( Count3 );
                        end;
                     end;
                     inc( Count2 );
                  end;
               end;
               {.storage}
               XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colStorage' );
               XMLSavedGameItemSub3.Attributes['capSolidCur']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidCurrent, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capSolidMax']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidMax, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capLiquidCur']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidCurrent, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capLiquidMax']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidMax, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capGasCur']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasCurrent, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capGasMax']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasMax, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capBioCur']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioCurrent, FCVdiFormat );
               XMLSavedGameItemSub3.Attributes['capBioMax']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioMax, FCVdiFormat );
               Max2:=length( FCDdgEntities[Count].E_colonies[Count1].C_storedProducts )-1;
               if Max2>0 then
               begin
                  Count2:=1;
                  while Count2<=Max2 do
                  begin
                     XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'storItem'+IntToStr( Count2 ) );
                     XMLSavedGameItemSub4.Attributes['token']:=FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_token;
                     XMLSavedGameItemSub4.Attributes['unit']:=FloatToStr( FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_unit, FCVdiFormat );
                     inc( Count2 );
                  end;
               end;
               {.reserves}
               XMLSavedGameItemSub3:=XMLSavedGameItemSub2.AddChild( 'colReserves' );
               XMLSavedGameItemSub3.Attributes['oxygen']:=FCDdgEntities[Count].E_colonies[Count1].C_reserveOxygen;
               XMLSavedGameItemSub3.Attributes['food']:=FCDdgEntities[Count].E_colonies[Count1].C_reserveFood;
               Max2:=length( FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex )-1;
               Count2:=1;
               while Count2<=Max2 do
               begin
                  XMLSavedGameItemSub4:=XMLSavedGameItemSub3.AddChild( 'foodRve'+IntToStr( Count2 ) );
                  XMLSavedGameItemSub4.Attributes['index']:=FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex[Count2];
                  inc(Count2);
               end;
               XMLSavedGameItemSub3.Attributes['water']:=FCDdgEntities[Count].E_colonies[Count1].C_reserveWater;
            end; //==END== if Max2>0 ==//
            inc(Count1);
         end; //==END== while Count1<=GScolMax do ==//
      end; //==END== if Max1>0 ==//
      Max1:=Length( FCDdgEntities[Count].E_spmSettings )-1;
      if Max1>0 then
      begin
         XMLSavedGameItemSub1:=XMLSavedGameItemSub.AddChild( 'entSPMset' );
         XMLSavedGameItemSub1.Attributes['modCoh']:=FCDdgEntities[Count].E_spmMod_Cohesion;
         XMLSavedGameItemSub1.Attributes['modTens']:=FCDdgEntities[Count].E_spmMod_Tension;
         XMLSavedGameItemSub1.Attributes['modSec']:=FCDdgEntities[Count].E_spmMod_Security;
         XMLSavedGameItemSub1.Attributes['modEdu']:=FCDdgEntities[Count].E_spmMod_Education;
         XMLSavedGameItemSub1.Attributes['modNat']:=FCDdgEntities[Count].E_spmMod_Natality;
         XMLSavedGameItemSub1.Attributes['modHeal']:=FCDdgEntities[Count].E_spmMod_Health;
         XMLSavedGameItemSub1.Attributes['modBur']:=FCDdgEntities[Count].E_spmMod_Bureaucracy;
         XMLSavedGameItemSub1.Attributes['modCorr']:=FCDdgEntities[Count].E_spmMod_Corruption;
         Count1:=1;
         while Count1<=Max1 do
         begin
            XMLSavedGameItemSub2:=XMLSavedGameItemSub1.AddChild( 'entSPM' );
            XMLSavedGameItemSub2.Attributes['token']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_token;
            XMLSavedGameItemSub2.Attributes['duration']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_duration;
            XMLSavedGameItemSub2.Attributes['ucCost']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_ucCost;
            XMLSavedGameItemSub2.Attributes['ispolicy']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy;
            if FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy then
            begin
               XMLSavedGameItemSub2.Attributes['isSet']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtIsSet;
               XMLSavedGameItemSub2.Attributes['aprob']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtAcceptanceProbability;
            end
            else if not FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy then
            begin
               XMLSavedGameItemSub2.Attributes['belieflvl']:=GetEnumName( TypeInfo( TFCEdgBeliefLevels ), Integer( FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPfBeliefLevel ) );
               XMLSavedGameItemSub2.Attributes['spreadval']:=FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtAcceptanceProbability;
            end;
            inc( Count1 );
         end;
      end;
      inc( Count );
   end; //==END== while GScount<=FCCfacMax do ==//
   {.create "msgqueue" saved game item}
   Max:=length( FCVmsgStoMsg );
   if Max>1 then
   begin
      XMLSavedGameItem:=XMLSavedGame.AddChild( 'gfMsgQueue' );
      Count:=1;
      while Count<=Max-1 do
      begin
         XMLSavedGameItemSub:=XMLSavedGameItem.AddChild( 'gfMsg' );
         XMLSavedGameItemSub.Attributes['msgTitle']:=FCVmsgStoTtl[Count];
         XMLSavedGameItemSub.Attributes['msgMain']:=FCVmsgStoMsg[Count];
         inc( Count );
      end; {.while GScount<=GSlength-1}
   end; {.if GSlength>1 then}
   FCWinMain.FCGLSHUDgameTime.Text:='Game Saved';
   {.write the file and free the memory}
   FCWinMain.FCXMLsave.SaveToFile( CurrentDirectory+'\'+CurrentSavedGameFile );
   FCWinMain.FCXMLsave.Active:=false;
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set( tphTac );
end;

procedure FCMdFSG_Game_SaveAndFlushOther;
{:Purpose: save the current game and flush all other save game files than the current one.
    Additions:
      -2012Aug19- *code audit:
                     (x)var formatting + refactoring     (x)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (_)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                     ///   <remarks>the procedure/function reset the /data/</remarks>
}
   var
      CurrentDirectory
      ,CurrentGameFile: string;

      XMLCurrentGame: IXMLNode;
begin
   try
      FCMdFSG_Game_Save;
   finally
      {.read the document}
      FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
      FCWinMain.FCXMLcfg.Active:=true;
      CurrentGameFile:='';
      XMLCurrentGame:=FCWinMain.FCXMLcfg.DocumentElement.ChildNodes.FindNode('currGame');
      if XMLCurrentGame<>nil then
      begin
         CurrentGameFile:=IntToStr( XMLCurrentGame.Attributes['tfYr'] )
            +'-'+IntToStr( XMLCurrentGame.Attributes['tfMth'] )
            +'-'+IntToStr( XMLCurrentGame.Attributes['tfDay'] )
            +'-'+IntToStr( XMLCurrentGame.Attributes['tfHr'] )
            +'-'+IntToStr( XMLCurrentGame.Attributes['tfMin'] )
            +'-'+IntToStr( XMLCurrentGame.Attributes['tfTick'] )
            +'.xml';
      end;
      {.free the memory}
      FCWinMain.FCXMLcfg.Active:=false;
      FCWinMain.FCXMLcfg.FileName:='';
      CurrentDirectory:=FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName;
      if FileExists( CurrentDirectory+'\'+CurrentGameFile ) then
      begin
         CopyFile(
            pchar( CurrentDirectory+'\'+CurrentGameFile )
            ,pchar( FCVdiPathConfigDir+CurrentGameFile )
            ,false
            );
         FCMcF_Files_Del( CurrentDirectory+'\', '*.*' );
         CopyFile(
            pchar( FCVdiPathConfigDir+CurrentGameFile )
            ,pchar( CurrentDirectory+'\'+CurrentGameFile )
            ,false
            );
         DeleteFile( pchar( FCVdiPathConfigDir+CurrentGameFile ) );
      end;
   end;
end;

end.
