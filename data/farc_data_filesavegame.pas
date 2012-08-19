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
                     (x)var formatting + refactoring     (o)if..then reformatting   (-)function/procedure refactoring
                     (_)parameters refactoring           (o) ()reformatting         (o)code optimizations
                     (_)float local variables=> extended (o)case..of reformatting   (-)local methods
                     (_)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (x)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (-)if the procedure reset the same record's data or external data put:
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
      ,EnumIndex: integer;

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
         FCVdgPlayer.P_economicStatus:=XMLSavedGame.Attributes['statEco'];
         FCVdgPlayer.P_economicViabilityThreshold:=XMLSavedGame.Attributes['statEcoThr'];
         FCVdgPlayer.P_socialStatus:=XMLSavedGame.Attributes['statSoc'];
         FCVdgPlayer.P_socialViabilityThreshold:=XMLSavedGame.Attributes['statSocThr'];
         FCVdgPlayer.P_militaryStatus:=XMLSavedGame.Attributes['statSpMil'];
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
               ViabilityObjectives[Count].CPSO_ifThreshold:=XMLSavedGameItem.Attributes['threshold'];
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
      SetLength( FCGtskListInProc, 1 );
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode( 'gfTskLstinProc' );
      if XMLSavedGame<>nil then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            inc( Count );
            SetLength( FCGtskListInProc, Count+1 );
            FCGtskListInProc[Count].T_type:=XMLSavedGameItem.Attributes['tipActTp'];
            FCGtskListInProc[Count].T_tMColCurrentPhase:=XMLSavedGameItem.Attributes['tipPhase'];
            FCGtskListInProc[Count].TITP_ctldType:=XMLSavedGameItem.Attributes['tipTgtTp'];
            FCGtskListInProc[Count].TITP_ctldFac:=XMLSavedGameItem.Attributes['tipTgtFac'];
            FCGtskListInProc[Count].TITP_ctldIdx:=XMLSavedGameItem.Attributes['tipTgtIdx'];
            FCGtskListInProc[Count].TITP_timeOrg:=XMLSavedGameItem.Attributes['tipTimeOrg'];
            FCGtskListInProc[Count].TITP_duration:=XMLSavedGameItem.Attributes['tipDura'];
            FCGtskListInProc[Count].TITP_interval:=XMLSavedGameItem.Attributes['tipInterv'];
            FCGtskListInProc[Count].TITP_orgType:=XMLSavedGameItem.Attributes['tipOrgTp'];
            FCGtskListInProc[Count].TITP_orgIdx:=XMLSavedGameItem.Attributes['tipOrgIdx'];
            FCGtskListInProc[Count].TITP_destType:=XMLSavedGameItem.Attributes['tipDestTp'];
            FCGtskListInProc[Count].TITP_destIdx:=XMLSavedGameItem.Attributes['tipDestIdx'];
            FCGtskListInProc[Count].TITP_regIdx:=XMLSavedGameItem.Attributes['tipRegIdx'];
            FCGtskListInProc[Count].TITP_velCruise:=XMLSavedGameItem.Attributes['tipVelCr'];
            FCGtskListInProc[Count].TITP_timeToCruise:=XMLSavedGameItem.Attributes['tipTimeTcr'];
            FCGtskListInProc[Count].TITP_timeDecel:=XMLSavedGameItem.Attributes['tipTimeTdec'];
            FCGtskListInProc[Count].TITP_time2xfert:=XMLSavedGameItem.Attributes['tipTime2Xfrt'];
            FCGtskListInProc[Count].TITP_time2xfert2decel:=XMLSavedGameItem.Attributes['tipTime2XfrtDec'];
            FCGtskListInProc[Count].TITP_velFinal:=XMLSavedGameItem.Attributes['tipVelFin'];
            FCGtskListInProc[Count].TITP_timeToFinal:=XMLSavedGameItem.Attributes['tipTimeTfin'];
            FCGtskListInProc[Count].TITP_accelbyTick:=XMLSavedGameItem.Attributes['tipAccelBtick'];
            FCGtskListInProc[Count].TITP_usedRMassV:=XMLSavedGameItem.Attributes['tipUsedRM'];
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
                        FCVdgPlayer.P_surveyedResourceSpots[Count].SRS_surveyedRegions[Count1].SR_ResourceSpots[Count2].RS_meanQualityCoefficient:=XMLSavedGameItemSub1.Attributes['meanQualCoef'];
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
            FCDdgEntities[Count].E_hqHigherLevel:=XMLSavedGameItem.Attributes['hqHlvl'];
            FCDdgEntities[Count].E_ucInAccount:=XMLSavedGameItem.Attributes['UCrve'];
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
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewX:=XMLSavedGameItemSub1.Attributes['xLoc'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_locationViewZ:=XMLSavedGameItemSub1.Attributes['zLoc'];
                     Count3:=XMLSavedGameItemSub1.Attributes['docked'];
                     if Count3>0 then
                     begin
                        SetLength( FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits, Count3+1 );
                        Count2:=1;
                        XMLSavedGameItemSub2:=XMLSavedGameItemSub1.ChildNodes.First;
                        while Count2<=Count3 do
                        begin
                           FCDdgEntities[Count].E_spaceUnits[Count1].SU_dockedSpaceUnits[Count2].SUDL_index:=XMLSavedGameItemSub2.Attributes['index'];
                           inc( Count2 );
                           XMLSavedGameItemSub2:=XMLSavedGameItemSub2.NextSibling;
                        end;
                     end;
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_assignedTask:=XMLSavedGameItemSub1.Attributes['taskId'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_status:=XMLSavedGameItemSub1.Attributes['status'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_deltaV:=XMLSavedGameItemSub1.Attributes['dV'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_3dVelocity:=XMLSavedGameItemSub1.Attributes['TdMov'];
                     FCDdgEntities[Count].E_spaceUnits[Count1].SU_reactionMass:=XMLSavedGameItemSub1.Attributes['availRMass'];
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
                     FCDdgEntities[Count].E_colonies[Count1].C_level:=TFCEdgColonyLevels( XMLSavedGameItemSub1.Attributes['collvl']-1 );
                     FCDdgEntities[Count].E_colonies[Count1].C_hqPresence:=XMLSavedGameItemSub1.Attributes['hqpresence'];
                     FCDdgEntities[Count].E_colonies[Count1].C_cohesion:=XMLSavedGameItemSub1.Attributes['dcohes'];
                     FCDdgEntities[Count].E_colonies[Count1].C_security:=XMLSavedGameItemSub1.Attributes['dsecu'];
                     FCDdgEntities[Count].E_colonies[Count1].C_tension:=XMLSavedGameItemSub1.Attributes['dtens'];
                     FCDdgEntities[Count].E_colonies[Count1].C_instruction:=XMLSavedGameItemSub1.Attributes['dedu'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_PopulationCapacity:=XMLSavedGameItemSub1.Attributes['csmPCAP'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_SpaceLevel:=XMLSavedGameItemSub1.Attributes['csmSPL'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHousing_QualityOfLife:=XMLSavedGameItemSub1.Attributes['csmQOL'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmHealth_HealthLevel:=XMLSavedGameItemSub1.Attributes['csmHEAL'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Consumption:=XMLSavedGameItemSub1.Attributes['csmEnCons'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_Generation:=XMLSavedGameItemSub1.Attributes['csmEnGen'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageCurrent:=XMLSavedGameItemSub1.Attributes['csmEnStorCurr'];
                     FCDdgEntities[Count].E_colonies[Count1].C_csmEnergy_StorageMax:=XMLSavedGameItemSub1.Attributes['csmEnStorMax'];
                     FCDdgEntities[Count].E_colonies[Count1].C_economicIndustrialOutput:=XMLSavedGameItemSub1.Attributes['eiOut'];
                     XMLSavedGameItemSub2:=XMLSavedGameItemSub1.ChildNodes.First;
                     while XMLSavedGameItemSub2<>nil do
                     begin
                        {.colony population}
                        if XMLSavedGameItemSub2.NodeName='colPopulation' then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_total:=XMLSavedGameItemSub2.Attributes['popTtl'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_meanAge:=XMLSavedGameItemSub2.Attributes['popMeanAge'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathRate:=XMLSavedGameItemSub2.Attributes['popDRate'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_deathStack:=XMLSavedGameItemSub2.Attributes['popDStack'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthRate:=XMLSavedGameItemSub2.Attributes['popBRate'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_birthStack:=XMLSavedGameItemSub2.Attributes['popBStack'];
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
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPtotal:=XMLSavedGameItemSub2.Attributes['wcpTotal'];
                           FCDdgEntities[Count].E_colonies[Count1].C_population.CP_CWPassignedPeople:=XMLSavedGameItemSub2.Attributes['wcpAssignPpl'];
                        end //==END== if XMLSavedGameItemSub2.NodeName='colPopulation' ==//
                        {.colony events}
                        else if XMLSavedGameItemSub2.NodeName='colEvent' then
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
                                    FCDdgEntities[Count].E_colonies[Count1].C_events[Count2].CCSME_tFShDeathFractionalValue:=XMLSavedGameItemSub3.Attributes['deathFracValue'];
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
                              inc(Count2);
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_settlements, Count2+1);
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures, 1);
                              SetLength( FCDdgEntities[Count].E_colonies[Count1].C_cabQueue, Count2+1 );
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_name:=XMLSavedGameItemSub3.Attributes['name'];
                              EnumIndex:=GetEnumValue(TypeInfo(TFCEdgSettlements), XMLSavedGameItemSub3.Attributes['type'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_settlement:=TFCEdgSettlements(EnumIndex);
                              if EnumIndex=-1
                              then raise Exception.Create('bad gamesave loading w/settlement type: '+XMLSavedGameItemSub3.Attributes['type']) ;
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
                                 inc(Count3);
                                 SetLength( FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures, Count3+1 );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_token:=XMLSavedGameItemSub4.Attributes['token'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_level:=XMLSavedGameItemSub4.Attributes['level'];
                                 EnumIndex:=GetEnumValue(TypeInfo(TFCEdgInfrastructureStatus), XMLSavedGameItemSub4.Attributes['status'] );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_status:=TFCEdgInfrastructureStatus(EnumIndex);
                                 if EnumIndex=-1
                                 then raise Exception.Create('bad gamesave loading w/infra status: '+XMLSavedGameItemSub4.Attributes['status']);
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabDuration:=XMLSavedGameItemSub4.Attributes['CABduration'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_cabWorked:=XMLSavedGameItemSub4.Attributes['CABworked'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerConsumption:=XMLSavedGameItemSub4.Attributes['powerCons'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_powerGeneratedFromCustomEffect:=XMLSavedGameItemSub4.Attributes['powerGencFx'];
                                 EnumIndex:=GetEnumValue(TypeInfo(TFCEdipFunctions), XMLSavedGameItemSub4.Attributes['Func'] );
                                 FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function:=TFCEdipFunctions(EnumIndex);
                                 if EnumIndex=-1
                                 then raise Exception.Create('bad gamesave loading w/infra function: '+XMLSavedGameItemSub4.Attributes['Func']);
                                 case FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_function of
                                    fEnergy: FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fEnOutput:=XMLSavedGameItemSub4.Attributes['energyOut'];

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
                                          inc(Count4);
                                          EnumIndex:=GetEnumValue(TypeInfo(TFCEdipProductionModes), XMLSavedGameItemSub5.Attributes['prodModeType'] );
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_type:=TFCEdipProductionModes(EnumIndex);
                                          if EnumIndex=-1
                                          then raise Exception.Create('bad gamesave loading w/infra prod mode type: '+XMLSavedGameItemSub5.Attributes['prodModeType']);
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_isDisabled:=XMLSavedGameItemSub5.Attributes['isDisabled'];
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_energyConsumption:=XMLSavedGameItemSub5.Attributes['energyCons'];
                                          FCDdgEntities[Count].E_colonies[Count1].C_settlements[Count2].S_infrastructures[Count3].I_fProdProductionMode[Count4].PM_matrixItemMax:=XMLSavedGameItemSub5.Attributes['matrixItemMax'];
                                          Count5:=0;
                                          XMLSavedGameItemSub6:=XMLSavedGameItemSub5.ChildNodes.First;
                                          while XMLSavedGameItemSub6<>nil do
                                          begin
                                             inc(Count5);
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
                              end; //==END== while GLxmlInfra<>nil do ==//
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end; //==END== while XMLSavedGameItemSub3<>nil ==//
                        end //==END== else if XMLSavedGameItemSub2.NodeName='colSettlement' ==//
                        {.colony's CAB queue}
                        else if XMLSavedGameItemSub2.NodeName='colCAB'
                        then
                        begin
                           Count2:=1;
                           Count3:=Length(FCDdgEntities[Count].E_colonies[Count1].C_cabQueue)-1;
                           while Count2<=Count3 do
                           begin
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2], 1);
                              inc(Count2);
                           end;
                           Count2:=0;
                           Count3:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc(Count3);
                              Count2:=XMLSavedGameItemSub3.Attributes['settlement'];
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2], Count3+1);
                              Count4:=XMLSavedGameItemSub3.Attributes['infraIdx'];
                              FCDdgEntities[Count].E_colonies[Count1].C_cabQueue[Count2, Count3]:=Count4;
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        {.colony's production matrix}
                        else if XMLSavedGameItemSub2.NodeName='colProdMatrix'
                        then
                        begin
                           SetLength(FCDdgEntities[Count].E_colonies[Count].C_productionMatrix, 1);
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc(Count2);
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix, Count2+1);
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productToken:=XMLSavedGameItemSub3.Attributes['token'];
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storageIndex:=XMLSavedGameItemSub3.Attributes['storIdx'];
                              EnumIndex:=GetEnumValue(TypeInfo(TFCEdipStorageTypes), XMLSavedGameItemSub3.Attributes['storageType'] );
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_storage:=TFCEdipStorageTypes(EnumIndex);
                              if EnumIndex=-1
                              then raise Exception.Create('bad gamesave loading w/production matrix item storage type: '+XMLSavedGameItemSub3.Attributes['storageType']);
                              FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_globalProductionFlow:=XMLSavedGameItemSub3.Attributes['globalProdFlow'];
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes, 1);
                              Count3:=0;
                              XMLSavedGameItemSub4:=XMLSavedGameItemSub3.ChildNodes.First;
                              while XMLSavedGameItemSub4<>nil do
                              begin
                                 inc(Count3);
                                 SetLength(FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes, Count3+1);
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationSettlement:=XMLSavedGameItemSub4.Attributes['locSettle'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationInfrastructure:=XMLSavedGameItemSub4.Attributes['locInfra'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_locationProductionModeIndex:=XMLSavedGameItemSub4.Attributes['locPModeIndex'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_isDisabledByProductionSegment:=XMLSavedGameItemSub4.Attributes['isDisabledPS'];
                                 FCDdgEntities[Count].E_colonies[Count1].C_productionMatrix[Count2].PM_productionModes[Count3].PM_productionFlow:=XMLSavedGameItemSub4.Attributes['prodFlow'];
                                 XMLSavedGameItemSub4:=XMLSavedGameItemSub4.NextSibling;
                              end;
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        {.colony's storage}
                        else if XMLSavedGameItemSub2.NodeName='colStorage'
                        then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidCurrent:=XMLSavedGameItemSub2.Attributes['capSolidCur'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacitySolidMax:=XMLSavedGameItemSub2.Attributes['capSolidMax'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidCurrent:=XMLSavedGameItemSub2.Attributes['capLiquidCur'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityLiquidMax:=XMLSavedGameItemSub2.Attributes['capLiquidMax'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasCurrent:=XMLSavedGameItemSub2.Attributes['capGasCur'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityGasMax:=XMLSavedGameItemSub2.Attributes['capGasMax'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioCurrent:=XMLSavedGameItemSub2.Attributes['capBioCur'];
                           FCDdgEntities[Count].E_colonies[Count1].C_storageCapacityBioMax:=XMLSavedGameItemSub2.Attributes['capBioMax'];
                           SetLength(FCDdgEntities[Count].E_colonies[Count1].C_storedProducts, 1);
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc(Count2);
                              SetLength(FCDdgEntities[Count].E_colonies[Count1].C_storedProducts, Count2+1);
                              FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_token:=XMLSavedGameItemSub3.Attributes['token'];
                              FCDdgEntities[Count].E_colonies[Count1].C_storedProducts[Count2].SP_unit:=XMLSavedGameItemSub3.Attributes['unit'];
                              XMLSavedGameItemSub3:=XMLSavedGameItemSub3.NextSibling;
                           end;
                        end
                        else if XMLSavedGameItemSub2.NodeName='colReserves'
                        then
                        begin
                           FCDdgEntities[Count].E_colonies[Count1].C_reserveOxygen:=XMLSavedGameItemSub2.Attributes['oxygen'];
                           FCDdgEntities[Count].E_colonies[Count1].C_reserveFood:=XMLSavedGameItemSub2.Attributes['food'];
                           SetLength( FCDdgEntities[Count].E_colonies[Count1].C_reserveFoodProductsIndex, 1 );
                           Count2:=0;
                           XMLSavedGameItemSub3:=XMLSavedGameItemSub2.ChildNodes.First;
                           while XMLSavedGameItemSub3<>nil do
                           begin
                              inc(Count2);
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
               else if XMLSavedGameItemSub.NodeName='entSPMset'
               then
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
                     inc(Count1);
                     SetLength(FCDdgEntities[Count].E_spmSettings, Count1+1);
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_token:=XMLSavedGameItemSub1.Attributes['token'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_duration:=XMLSavedGameItemSub1.Attributes['duration'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_ucCost:=XMLSavedGameItemSub1.Attributes['ucCost'];
                     FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy:=XMLSavedGameItemSub1.Attributes['ispolicy'];
                     if FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy
                     then
                     begin
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtIsSet:=XMLSavedGameItemSub1.Attributes['isSet'];
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtAcceptanceProbability:=XMLSavedGameItemSub1.Attributes['aprob'];
                     end
                     else if not FCDdgEntities[Count].E_spmSettings[Count1].SPMS_isPolicy
                     then
                     begin
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtBeliefLevel:=XMLSavedGameItemSub1.Attributes['belieflvl'];
                        FCDdgEntities[Count].E_spmSettings[Count1].SPMS_iPtSpreadValue:=XMLSavedGameItemSub1.Attributes['spreadval'];
                     end;
                     XMLSavedGameItemSub1:=XMLSavedGameItemSub1.NextSibling;
                  end;
               end; //==END== if GLxmlEntSubRoot.NodeName='entSPMset' ==//
               XMLSavedGameItemSub:=XMLSavedGameItemSub.NextSibling;
            end; //==END== while GLxmlEntSubRoot<>nil do ==//
            inc(Count);
            XMLSavedGameItem:=XMLSavedGameItem.NextSibling;
         end; //==END== while GLxmlEnt<>nil do ==//
      end; //==END== if GLxmlEntRoot<>nil FOR COLONIES==//
      {.read "msgqueue" saved game item}
      setlength(FCVmsgStoTtl,1);
      setlength(FCVmsgStoMsg,1);
      XMLSavedGame:=FCWinMain.FCXMLsave.DocumentElement.ChildNodes.FindNode('gfMsgQueue');
      if XMLSavedGame<>nil
      then
      begin
         Count:=0;
         XMLSavedGameItem:=XMLSavedGame.ChildNodes.First;
         while XMLSavedGameItem<>nil do
         begin
            SetLength(FCVmsgStoTtl, length(FCVmsgStoTtl)+1);
            SetLength(FCVmsgStoMsg, length(FCVmsgStoMsg)+1);
            inc(Count);
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
   ,GSxmlProdMode
   ,GSxmlMatrixItem
   ,GSxmlMsg
   ,GSxmlPop
   ,GSxmlProdMatrix
   ,GSxmlProdMatrixRoot
   ,GSxmlProdMatrixSource
   ,GSxmlReserves
   ,GSxmlReservesRoot
   ,GSxmlRoot
   ,GSxmlSettle
   ,GSxmlSPM
   ,GSxmlSpOwn
   ,GSxmlstorage
	,GSxmlstorageRoot
   ,GSxmlTskInPr
   ,GSxmlSurveyRsrc
   ,GSxmlSurveyRegion
   ,GSxmlSurveyRSpot: IXMLNode;

   GScabCount
   ,GScabMax
   ,GScount
   ,GSsubCount
   ,GSsubMax
   ,GSsubMax1
   ,GSsubCount1
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
   ,GSstringStore
   ,GSenumString: string;
begin
   if not FCWinMain.CloseQuery
   then FCMgTFlow_FlowState_Set(tphPAUSE);
   GScurrDir:=FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName;
   GScurrG:=IntToStr(FCVdgPlayer.P_currentTimeYear)
      +'-'+IntToStr(FCVdgPlayer.P_currentTimeMonth)
      +'-'+IntToStr(FCVdgPlayer.P_currentTimeDay)
      +'-'+IntToStr(FCVdgPlayer.P_currentTimeHour)
      +'-'+IntToStr(FCVdgPlayer.P_currentTimeMinut)
      +'.xml';
   {.create the save directory if needed}
   if not DirectoryExists(GScurrDir)
   then MkDir(GScurrDir);
   {.clear the old file if it exists}
   if FileExists(GScurrDir+'\'+GScurrG)
   then DeleteFile(pchar(GScurrDir+'\'+GScurrG));
   FCMdF_ConfigurationFile_Save(true);
   {.link and activate TXMLDocument}
   FCWinMain.FCXMLsave.Active:=true;
   {.create the root node of the saved game file}
   GSxmlRoot:=FCWinMain.FCXMLsave.AddChild('savedgfile');
   {.create "main" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfMain');
   GSxmlItm.Attributes['gName']:= FCVdgPlayer.P_gameName;
   GSxmlItm.Attributes['facAlleg']:= FCVdgPlayer.P_allegianceFaction;
   GSxmlItm.Attributes['plyrsSSLoc']:= FCVdgPlayer.P_viewStarSystem;
   GSxmlItm.Attributes['plyrsStLoc']:= FCVdgPlayer.P_viewStar;
   GSxmlItm.Attributes['plyrsOObjLoc']:= FCVdgPlayer.P_viewOrbitalObject;
   GSxmlItm.Attributes['plyrsatLoc']:=FCVdgPlayer.P_viewSatellite;
   {.create "timeframe" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfTimeFr');
   GSxmlItm.Attributes['tfTick']:= FCVdgPlayer.P_currentTimeTick;
   GSxmlItm.Attributes['tfMin']:= FCVdgPlayer.P_currentTimeMinut;
   GSxmlItm.Attributes['tfHr']:= FCVdgPlayer.P_currentTimeHour;
   GSxmlItm.Attributes['tfDay']:= FCVdgPlayer.P_currentTimeDay;
   GSxmlItm.Attributes['tfMth']:= FCVdgPlayer.P_currentTimeMonth;
   GSxmlItm.Attributes['tfYr']:= FCVdgPlayer.P_currentTimeYear;
   {.create "status" item}
   GSxmlItm:=GSxmlRoot.AddChild('gfStatus');
   GSxmlItm.Attributes['statEco']:=FCVdgPlayer.P_economicStatus;
   GSxmlItm.Attributes['statEcoThr']:=FCVdgPlayer.P_economicViabilityThreshold;
   GSxmlItm.Attributes['statSoc']:=FCVdgPlayer.P_socialStatus;
   GSxmlItm.Attributes['statSocThr']:=FCVdgPlayer.P_socialViabilityThreshold;
   GSxmlItm.Attributes['statSpMil']:=FCVdgPlayer.P_militaryStatus;
   GSxmlItm.Attributes['statSpMilThr']:=FCVdgPlayer.P_militaryViabilityThreshold;
   {.create "cps" saved game item}
   if FCcps<>nil
   then
   begin
      GSlength:=length(FCcps.CPSviabObj);
      GSxmlItm:=GSxmlRoot.AddChild('gfCPS');
      GSxmlItm.Attributes['cpsEnabled']:=FCcps.CPSisEnabled;
      GSxmlItm.Attributes['cpsCVS']:=FCcps.FCF_CVS_Get;
      GSxmlItm.Attributes['cpsTlft']:=FCcps.FCF_TimeLeft_Get(true);
      GSxmlItm.Attributes['cpsInt']:=FCcps.FCF_CredLineInterest_Get;
      GSxmlItm.Attributes['cpsCredU']:=FCcps.FCF_CredLine_Get(true, true);
      GSxmlItm.Attributes['cpsCredM']:=FCcps.FCF_CredLine_Get(false, true);
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCPS:=GSxmlItm.AddChild('gfViabObj');
         GSxmlCPS.Attributes['objTp']:=GetEnumName( TypeInfo( TFCEcpsoObjectiveTypes ), Integer( FCcps.CPSviabObj[GScount].CPSO_type ) );
         GSxmlCPS.Attributes['score']:=FCcps.CPSviabObj[GScount].CPSO_score;
         if FCcps.CPSviabObj[GScount].CPSO_type=otEcoIndustrialForce then
         begin
            GSxmlCPS.Attributes['product']:=FCcps.CPSviabObj[GScount].CPSO_ifProduct;
            GSxmlCPS.Attributes['threshold']:=FCcps.CPSviabObj[GScount].CPSO_ifThreshold;
         end;
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
//         GSxmlTskInPr.Attributes['tipEna']:=FCGtskListInProc[GScount].T_enabled;
         GSxmlTskInPr.Attributes['tipActTp']:=FCGtskListInProc[GScount].T_type;
         GSxmlTskInPr.Attributes['tipPhase']:=FCGtskListInProc[GScount].T_tMColCurrentPhase;
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
   end; {.if GSlength>1 then... for taskinprocess}
   {.all surveyed resources}
   GSlength:=length(FCVdgPlayer.P_surveyedResourceSpots);
   if GSlength>1 then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfSurveyedResourceSpots');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlSurveyRsrc:=GSxmlItm.AddChild('gfSpotLocation');
         GSxmlSurveyRsrc.Attributes['oobj']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_orbitalObject_SatelliteToken;
         GSxmlSurveyRsrc.Attributes['ssysIdx']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_starSystem;
         GSxmlSurveyRsrc.Attributes['starIdx']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_star;
         GSxmlSurveyRsrc.Attributes['oobjIdx']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_orbitalObject;
         GSxmlSurveyRsrc.Attributes['satIdx']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_satellite;
         GSsubMax:=length(FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions)-1;
         GSsubCount:=1;
         while GSsubCount<=GSsubMax do
         begin
            GSsubMax1:=length(FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots)-1;
            if GSsubMax1>0 then
            begin
               GSxmlSurveyRegion:=GSxmlSurveyRsrc.AddChild('gfSpotRegion');
               GSxmlSurveyRegion.Attributes['regionIdx']:=GSsubCount;
               GSsubCount1:=1;
               while GSsubCount1<=GSsubMax1 do
               begin
                  GSxmlSurveyRSpot:=GSxmlSurveyRegion.AddChild('gfRsrcSpot');
                  GSxmlSurveyRSpot.Attributes['spotType']
                     :=GetEnumName(TypeInfo(TFCEduResourceSpotTypes), Integer(FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_type));
                  GSxmlSurveyRSpot.Attributes['meanQualCoef']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_meanQualityCoefficient;
                  GSxmlSurveyRSpot.Attributes['spotSizCurr']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_spotSizeCurrent;
                  GSxmlSurveyRSpot.Attributes['spotSizeMax']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_spotSizeMax;
                  if FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_type=rstOreField then
                  begin
                     GSxmlSurveyRSpot.Attributes['oreCarbo']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_tOFiCarbonaceous;
                     GSxmlSurveyRSpot.Attributes['oreMetal']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_tOFiMetallic;
                     GSxmlSurveyRSpot.Attributes['oreRare']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_tOFiRare;
                     GSxmlSurveyRSpot.Attributes['oreUra']:=FCVdgPlayer.P_surveyedResourceSpots[GScount].SRS_surveyedRegions[GSsubCount].SR_ResourceSpots[GSsubCount1].RS_tOFiUranium;
                  end;
                  inc(GSsubCount1);
               end;
            end;
            inc(GSsubCount);
         end;
         inc(GScount);
      end; //==END== while GScount<=GSlength-1 do ==//
   end; //==END== if GSlength>1 then... for surveyed resource spots ==//
   {.create "CSM" saved game item}
   GSlength:=length(FCDdgCSMPhaseSchedule);
   if GSlength>1
   then
   begin
      GSxmlItm:=GSxmlRoot.AddChild('gfCSM');
      GScount:=1;
      while GScount<=GSlength-1 do
      begin
         GSxmlCSMpL:=GSxmlItm.AddChild('csmPhList');
         GSxmlCSMpL.Attributes['csmTick']:=FCDdgCSMPhaseSchedule[GScount].CSMPS_ProcessAtTick;
         GSphFac:=0;
         while GSphFac<=1 do
         begin
            GSsubL:=length(FCDdgCSMPhaseSchedule[GScount].CSMPS_colonies[GSphFac])-1;
            GSsubC:=1;
            if GSsubL>0
            then
            begin
               while GSsubC<=GSsubL do
               begin
                  GSxmlCSMpLsub:=GSxmlCSMpL.AddChild('csmPhase');
                  GSxmlCSMpLsub.Attributes['fac']:=GSphFac;
                  GSxmlCSMpLsub.Attributes['colony']:=FCDdgCSMPhaseSchedule[GScount].CSMPS_colonies[GSphFac, GSsubL];
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
   while GScount<=FCCdiFactionsMax do
   begin
      GSxmlEnt:=GSxmlEntRoot.AddChild('entity');
      GSxmlEnt.Attributes['token']:=FCDdgEntities[GScount].E_token;
      GSxmlEnt.Attributes['lvl']:=FCDdgEntities[GScount].E_factionLevel;
      GSxmlEnt.Attributes['bur']:=FCDdgEntities[GScount].E_bureaucracy;
      GSxmlEnt.Attributes['corr']:=FCDdgEntities[GScount].E_corruption;
      GSxmlEnt.Attributes['hqHlvl']:=FCDdgEntities[GScount].E_hqHigherLevel;
      GSxmlEnt.Attributes['UCrve']:=FCDdgEntities[GScount].E_ucInAccount;
      GSspuMax:=Length(FCDdgEntities[GScount].E_spaceUnits)-1;
      if GSspuMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entOwnSpU');
         GSspuCnt:=1;
         while GSspuCnt<=GSspuMax do
         begin
            GSdock:=length(FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_dockedSpaceUnits)-1;
            GSxmlSpOwn:=GSxmlItm.AddChild('entSpU');
            GSxmlSpOwn.Attributes['tokenId']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_token;
            GSxmlSpOwn.Attributes['tokenName']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_name;
            GSxmlSpOwn.Attributes['desgnId']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_designToken;
            GSxmlSpOwn.Attributes['ssLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationStarSystem;
            GSxmlSpOwn.Attributes['stLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationStar;
            GSxmlSpOwn.Attributes['oobjLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationOrbitalObject;
            GSxmlSpOwn.Attributes['satLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationSatellite;
            GSxmlSpOwn.Attributes['TdObjIdx']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_linked3dObject;
            GSxmlSpOwn.Attributes['xLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationViewX;
            GSxmlSpOwn.Attributes['zLoc']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_locationViewZ;
            GSxmlSpOwn.Attributes['docked']:=GSdock;
            GSsubC:=1;
            while GSsubC<=GSdock do
            begin
               GSxmlDock:=GSxmlSpOwn.AddChild('entSpUdckd');
               GSxmlDock.Attributes['index']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_dockedSpaceUnits[GSsubC].SUDL_index;
               inc(GSsubC);
            end;
            GSxmlSpOwn.Attributes['taskId']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_assignedTask;
            GSxmlSpOwn.Attributes['status']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_status;
            GSxmlSpOwn.Attributes['dV']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_deltaV;
            GSxmlSpOwn.Attributes['TdMov']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_3dVelocity;
            GSxmlSpOwn.Attributes['availRMass']:=FCDdgEntities[GScount].E_spaceUnits[GSspuCnt].SU_reactionMass;
            inc(GSspuCnt);
         end; {.while GSspuCnt<=GSspuMax}
      end; //==END== if GSspuMax>0 ==//
      GScolMax:=Length(FCDdgEntities[GScount].E_colonies)-1;
      if GScolMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entColonies');
         GScolCnt:=1;
         while GScolCnt<=GScolMax do
         begin
            GSxmlCol:=GSxmlItm.AddChild('entColony');
            GSxmlCol.Attributes['prname']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_name;
            GSxmlCol.Attributes['fndyr']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_foundationDateYear;
            GSxmlCol.Attributes['fndmth']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_foundationDateMonth;
            GSxmlCol.Attributes['fnddy']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_foundationDateDay;
            GSxmlCol.Attributes['csmtime']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_nextCSMsessionInTick;
            GSxmlCol.Attributes['locssys']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_locationStarSystem;
            GSxmlCol.Attributes['locstar']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_locationStar;
            GSxmlCol.Attributes['locoobj']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_locationOrbitalObject;
            GSxmlCol.Attributes['locsat']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_locationSatellite;
            GSxmlCol.Attributes['collvl']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_level;
            GSxmlCol.Attributes['hqpresence']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_hqPresence;
            GSxmlCol.Attributes['dcohes']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_cohesion;
            GSxmlCol.Attributes['dsecu']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_security;
            GSxmlCol.Attributes['dtens']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_tension;
            GSxmlCol.Attributes['dedu']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_instruction;
            GSxmlCol.Attributes['csmPCAP']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmHousing_PopulationCapacity;
            GSxmlCol.Attributes['csmSPL']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmHousing_SpaceLevel;
            GSxmlCol.Attributes['csmQOL']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmHousing_QualityOfLife;
            GSxmlCol.Attributes['csmHEAL']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmHealth_HealthLevel;
            GSxmlCol.Attributes['csmEnCons']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmEnergy_Consumption;
            GSxmlCol.Attributes['csmEnGen']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmEnergy_Generation;
            GSxmlCol.Attributes['csmEnStorCurr']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmEnergy_StorageCurrent;
            GSxmlCol.Attributes['csmEnStorMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_csmEnergy_StorageMax;
            GSxmlCol.Attributes['eiOut']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_economicIndustrialOutput;
            {.colony population}
            GSxmlPop:=GSxmlCol.AddChild('colPopulation');
            GSxmlPop.Attributes['popTtl']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_total;
            GSxmlPop.Attributes['popMeanAge']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_meanAge;
            GSxmlPop.Attributes['popDRate']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_deathRate;
            GSxmlPop.Attributes['popDStack']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_deathStack;
            GSxmlPop.Attributes['popBRate']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_birthRate;
            GSxmlPop.Attributes['popBStack']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_birthStack;
            GSxmlPop.Attributes['popColon']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classColonist;
            GSxmlPop.Attributes['popColonAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classColonistAssigned;
            GSxmlPop.Attributes['popOff']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAerOfficer;
            GSxmlPop.Attributes['popOffAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAerOfficerAssigned;
            GSxmlPop.Attributes['popMisSpe']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAerMissionSpecialist;
            GSxmlPop.Attributes['popMisSpeAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAerMissionSpecialistAssigned;
            GSxmlPop.Attributes['popBiol']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classBioBiologist;
            GSxmlPop.Attributes['popBiolAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classBioBiologistAssigned;
            GSxmlPop.Attributes['popDoc']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classBioDoctor;
            GSxmlPop.Attributes['popDocAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classBioDoctorAssigned;
            GSxmlPop.Attributes['popTech']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classIndTechnician;
            GSxmlPop.Attributes['popTechAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classIndTechnicianAssigned;
            GSxmlPop.Attributes['popEng']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classIndEngineer;
            GSxmlPop.Attributes['popEngAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classIndEngineerAssigned;
            GSxmlPop.Attributes['popSold']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classMilSoldier;
            GSxmlPop.Attributes['popSoldAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classMilSoldierAssigned;
            GSxmlPop.Attributes['popComm']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classMilCommando;
            GSxmlPop.Attributes['popCommAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classMilCommandoAssigned;
            GSxmlPop.Attributes['popPhys']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classPhyPhysicist;
            GSxmlPop.Attributes['popPhysAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classPhyPhysicistAssigned;
            GSxmlPop.Attributes['popAstro']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classPhyAstrophysicist;
            GSxmlPop.Attributes['popAstroAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classPhyAstrophysicistAssigned;
            GSxmlPop.Attributes['popEcol']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classEcoEcologist;
            GSxmlPop.Attributes['popEcolAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classEcoEcologistAssigned;
            GSxmlPop.Attributes['popEcof']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classEcoEcoformer;
            GSxmlPop.Attributes['popEcofAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classEcoEcoformerAssigned;
            GSxmlPop.Attributes['popMedian']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAdmMedian;
            GSxmlPop.Attributes['popMedianAssign']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classAdmMedianAssigned;
            GSxmlPop.Attributes['popRebels']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classRebels;
            GSxmlPop.Attributes['popMilitia']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_classMilitia;
            GSxmlPop.Attributes['wcpTotal']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_CWPtotal;
            GSxmlPop.Attributes['wcpAssignPpl']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_population.CP_CWPassignedPeople;
            {.colony events}
            GSsubL:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_events);
            if GSsubL>1 then
            begin
               {:DEV NOTES:
                  put colony event in
                   <colEvent>
                     <Event>
                   </colEvent>

                   Loading already modified for

                   GSxmlColEv:=GSxmlCol.AddChild('colEvent');
                   while
                     GSxmlColEvSUB:=GSxmlColEv.AddChild('Event');
                     + change the to the corresponding XML link

               .}
               GSsubC:=1;
               while GSsubC<=GSsubL-1 do
               begin
                  GSxmlColEv:=GSxmlCol.AddChild('colEvent');
                  case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                     ceColonyEstablished:
                     begin
                        GSxmlColEv.Attributes['token']:='etColEstab';
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tCEstTensionMod;
                        GSxmlColEv.Attributes['modSecurity']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tCEstSecurityMod;
                     end;

                     ceUnrest, ceUnrest_Recovering:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceUnrest: GSxmlColEv.Attributes['token']:='etUnrest';

                           ceUnrest_Recovering: GSxmlColEv.Attributes['token']:='etUnrestRec';
                        end;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tCUnEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tCUnTensionMod;
                     end;

                     ceSocialDisorder, ceSocialDisorder_Recovering:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceSocialDisorder: GSxmlColEv.Attributes['token']:='etSocdis';

                           ceSocialDisorder_Recovering: GSxmlColEv.Attributes['token']:='etSocdisRec';
                        end;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tSDisEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tSDisTensionMod;
                     end;

                     ceUprising, ceUprising_Recovering:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceUprising: GSxmlColEv.Attributes['token']:='etUprising';

                           ceUprising_Recovering: GSxmlColEv.Attributes['token']:='etUprisingRec';
                        end;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tUpEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tUpTensionMod;
                     end;

                     ceDissidentColony: GSxmlColEv.Attributes['token']:='etColDissident';

                     ceHealthEducationRelation:
                     begin
                        GSxmlColEv.Attributes['token']:='etHealthEduRel';
                        GSxmlColEv.Attributes['modInstruction']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tHERelEducationMod;
                     end;

                     ceGovernmentDestabilization, ceGovernmentDestabilization_Recovering:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceGovernmentDestabilization: GSxmlColEv.Attributes['token']:='etGovDestab';
                           ceGovernmentDestabilization_Recovering: GSxmlColEv.Attributes['token']:='etGovDestabRec';
                        end;
                        GSxmlColEv.Attributes['modCohesion']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tGDestCohesionMod;
                     end;

                     ceOxygenProductionOverload:
                     begin
                        GSxmlColEv.Attributes['token']:='etRveOxygenOverload';
                        GSxmlColEv.Attributes['percPopNotSupported']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tOPOvPercentPopulationNotSupported;
                     end;

                     ceOxygenShortage, ceWaterShortage_Recovering:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceOxygenShortage: GSxmlColEv.Attributes['token']:='etRveOxygenShortage';

                           ceWaterShortage_Recovering: GSxmlColEv.Attributes['token']:='etRveOxygenShortageRec';
                        end;
                        GSxmlColEv.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tOShPercentPopulationNotSupportedAtCalculation;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tOShEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tOShTensionMod;
                        GSxmlColEv.Attributes['modHealth']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tOShHealthMod;
                     end;

                     ceWaterProductionOverload:
                     begin
                        GSxmlColEv.Attributes['token']:='etRveWaterOverload';
                        GSxmlColEv.Attributes['percPopNotSupported']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tWPOvPercentPopulationNotSupported;
                     end;

                     ceWaterShortage:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceWaterShortage: GSxmlColEv.Attributes['token']:='etRveWaterShortage';

                           ceWaterShortage_Recovering: GSxmlColEv.Attributes['token']:='etRveWaterShortageRec';
                        end;
                        GSxmlColEv.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tWShPercentPopulationNotSupportedAtCalculation;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tWShEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tWShTensionMod;
                        GSxmlColEv.Attributes['modHealth']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tWShHealthMod;
                     end;

                     ceFoodProductionOverload:
                     begin
                        GSxmlColEv.Attributes['token']:='etRveFoodOverload';
                        GSxmlColEv.Attributes['percPopNotSupported']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFPOvPercentPopulationNotSupported;
                     end;

                     ceFoodShortage:
                     begin
                        case FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_type of
                           ceFoodShortage: GSxmlColEv.Attributes['token']:='etRveFoodShortage';

                           ceFoodShortage_Recovering: GSxmlColEv.Attributes['token']:='etRveFoodShortageRec';
                        end;
                        GSxmlColEv.Attributes['percPopNotSupAtCalc']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShPercentPopulationNotSupportedAtCalculation;
                        GSxmlColEv.Attributes['modEcoInd']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShEconomicIndustrialOutputMod;
                        GSxmlColEv.Attributes['modTension']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShTensionMod;
                        GSxmlColEv.Attributes['modHealth']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShHealthMod;
                        GSxmlColEv.Attributes['directDeathPeriod']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShDirectDeathPeriod;
                        GSxmlColEv.Attributes['deathFracValue']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_tFShDeathFractionalValue;
                     end;
                  end; //==END== case FCentities[GScount].E_col[GScolCnt].COL_evList[GSsubC].CSMEV_token of ==//
                  GSxmlColEv.Attributes['isres']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_isResident;
                  GSxmlColEv.Attributes['duration']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_durationWeeks;
                  GSxmlColEv.Attributes['level']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_events[GSsubC].CCSME_level;
                  inc(GSsubC);
               end; //==END== while GSsubC<=GSsubL-1 do ==//
            end; //==END== if GSsubL>1 ==//
            {.colony settlements}
            GSsettleMax:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements)-1;
            if GSsettleMax>0 then
            begin

               {:DEV NOTES:
                  put settlements in
                   <colSettlement>
                     <Settlement>
                        <setInfra/>
                     </Settlement>
                   </colSettlement>

                   Loading already modified for

                   GSxmlSettle:=GSxmlCol.AddChild('colSettlement');
                   while
                     GSxmlSettle1:=GSxmlSettle.AddChild('Settlement');
                     + change the to the corresponding XML link

               .}


               GSxmlCABroot:=nil;
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GSxmlSettle:=GSxmlCol.AddChild('colSettlement');
                  GSxmlSettle.Attributes['name']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_name;
                  case FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_settlement of
                     sSurface: GSenumString:='stSurface';
                     sSpaceSurface: GSenumString:='stSpaceSurf';
                     sSubterranean: GSenumString:='stSubterranean';
                     sSpaceBased: GSenumString:='stSpaceBased';
                  end;
                  GSxmlSettle.Attributes['type']:=GSenumString;
                  GSxmlSettle.Attributes['level']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_level;
                  GSxmlSettle.Attributes['region']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_locationRegion;
                  GSsubL:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures)-1;
                  GSsubC:=1;
                  while GSsubC<=GSsubL do
                  begin
                     GSxmlColInf:=GSxmlSettle.AddChild('setInfra');
                     GSxmlColInf.Attributes['token']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_token;
                     GSxmlColInf.Attributes['level']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_level;
                     case FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_status of
                        isInKit: GSstringStore:='istInKit';
                        isInConversion: GSstringStore:='istInConversion';
                        isInAssembling: GSstringStore:='istInAssembling';
                        isInBluidingSite: GSstringStore:='istInBldSite';
                        isDisabled: GSstringStore:='istDisabled';
                        isDisabledByEnergyEquilibrium: GSstringStore:='istDisabledByEE';
                        isInTransition: GSstringStore:='istInTransition';
                        isOperational: GSstringStore:='istOperational';
                     end;
                     GSxmlColInf.Attributes['status']:=GSstringStore;
                     GSxmlColInf.Attributes['CABduration']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_cabDuration;
                     GSxmlColInf.Attributes['CABworked']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_cabWorked;
                     GSxmlColInf.Attributes['powerCons']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_powerConsumption;
                     GSxmlColInf.Attributes['powerGencFx']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_powerGeneratedFromCustomEffect;
                     case FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_function of
                        fEnergy:
                        begin
                           GSxmlColInf.Attributes['Func']:='fEnergy';
                           GSxmlColInf.Attributes['energyOut']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fEnOutput;
                        end;

                        fHousing:
                        begin
                           GSxmlColInf.Attributes['Func']:='fHousing';
                           GSxmlColInf.Attributes['PCAP']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fHousPopulationCapacity;
                           GSxmlColInf.Attributes['QOL']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fHousQualityOfLife;
                           GSxmlColInf.Attributes['vol']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fHousCalculatedVolume;
                           GSxmlColInf.Attributes['surf']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fHousCalculatedSurface;
                        end;

                        fIntelligence: GSxmlColInf.Attributes['Func']:='fIntelligence';

                        fMiscellaneous: GSxmlColInf.Attributes['Func']:='fMiscellaneous';

                        fProduction:
                        begin
                           GSxmlColInf.Attributes['Func']:='fProduction';
                           GSxmlColInf.Attributes['surveyedSpot']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdSurveyedSpot;
                           GSxmlColInf.Attributes['surveyedRegion']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdSurveyedRegion;
                           GSxmlColInf.Attributes['resourceSpot']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdResourceSpot;
                           GSsubCount:=1;
                           while GSsubCount<=FCCdipProductionModesMax do
                           begin
                              if FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_type>pmNone then
                              begin
                                 GSxmlProdMode:=GSxmlColInf.AddChild('prodmode');
                                 case FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_type of
                                    pmResourceMining: GSstringStore:='pmResourceMining';
                                 end;
                                 GSxmlProdMode.Attributes['prodModeType']:=GSstringStore;
                                 GSxmlProdMode.Attributes['isDisabled']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_isDisabled;
                                 GSxmlProdMode.Attributes['energyCons']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_energyConsumption;
                                 GSxmlProdMode.Attributes['matrixItemMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_matrixItemMax;
                                 GSsubCount1:=1;
                                 while GSsubCount1<=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_matrixItemMax do
                                 begin
                                    GSxmlMatrixItem:=GSxmlProdMode.AddChild('linkedMatrixItem');
                                    GSxmlMatrixItem.Attributes['pmitmIndex']
                                       :=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_linkedColonyMatrixItems[GSsubCount1].LMII_matrixItemIndex;
                                    GSxmlMatrixItem.Attributes['pmIndex']
                                       :=FCDdgEntities[GScount].E_colonies[GScolCnt].C_settlements[GSsettleCnt].S_infrastructures[GSsubC].I_fProdProductionMode[GSsubCount].PM_linkedColonyMatrixItems[GSsubCount1].LMII_matrixItem_ProductionModeIndex;
                                    inc(GSsubCount1);
                                 end;
                              end
                              else Break;
                              inc(GSsubCount);
                           end;
                        end;
                     end; //==END== case FCentities[GScount].E_col[GScolCnt].COL_settlements[GSsettleCnt].CS_infra[GSsubC].CI_function of ==//
                     inc(GSsubC);
                  end; //==END== while GSsubC<=GSsubL do ==//
                  inc(GSsettleCnt);
               end; //==END== while GSsettleCnt<=GSsettleMax do ==//
               {.CAB queue}
               GSsettleCnt:=1;
               while GSsettleCnt<=GSsettleMax do
               begin
                  GScabMax:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_cabQueue[GSsettleCnt])-1;
                  if GScabMax>0 then
                  begin
                     if GSxmlCABroot=nil
                     then GSxmlCABroot:=GSxmlCol.AddChild('colCAB');
                     GScabCount:=1;
                     while GScabCount<=GScabMax do
                     begin
                        GSxmlCAB:=GSxmlCABroot.AddChild('cabItem');
                        GSxmlCAB.Attributes['settlement']:=GSsettleCnt;
                        GSxmlCAB.Attributes['infraIdx']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_cabQueue[GSsettleCnt, GScabCount];
                        inc(GScabCount);
                     end;
                  end; //==END== if GScabMax>0 ==//
                  inc(GSsettleCnt);
               end;
               {.production matrix}
               GSprodMatrixMax:=Length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix)-1;
               if GSprodMatrixMax>0 then
               begin
                  GSxmlProdMatrixRoot:=GSxmlCol.AddChild('colProdMatrix');
                  GSprodMatrixCnt:=1;
                  while GSprodMatrixCnt<=GSprodMatrixMax do
                  begin
                     GSxmlProdMatrix:=GSxmlProdMatrixRoot.AddChild('prodItem');
                     GSxmlProdMatrix.Attributes['token']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productToken;
                     GSxmlProdMatrix.Attributes['storIdx']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_storageIndex;
                     case FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_storage of
                        stSolid: GSstringStore:='stSolid';
                        stLiquid: GSstringStore:='stLiquid';
                        stGas: GSstringStore:='stGas';
                        stBiologic: GSstringStore:='stBiologic';
                     end;
                     GSxmlProdMatrix.Attributes['storageType']:=GSstringStore;
                     GSxmlProdMatrix.Attributes['globalProdFlow']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_globalProductionFlow;
                     GSsubMax:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes)-1;
                     if GSsubMax>0 then
                     begin
                        GSsubCount:=1;
                        while GSsubCount<=GSsubMax do
                        begin
                           GSxmlProdMatrixSource:=GSxmlProdMatrix.AddChild('prodMode');
                           GSxmlProdMatrixSource.Attributes['locSettle']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes[GSsubCount].PM_locationSettlement;
                           GSxmlProdMatrixSource.Attributes['locInfra']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes[GSsubCount].PM_locationInfrastructure;
                           GSxmlProdMatrixSource.Attributes['locPModeIndex']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes[GSsubCount].PM_locationProductionModeIndex;
                           GSxmlProdMatrixSource.Attributes['isDisabledPS']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes[GSsubCount].PM_isDisabledByProductionSegment;
                           GSxmlProdMatrixSource.Attributes['prodFlow']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_productionMatrix[GSprodMatrixCnt].PM_productionModes[GSsubCount].PM_productionFlow;
                           inc(GSsubCount);
                        end;
                     end;
                     inc(GSprodMatrixCnt);
                  end;
               end;
               {.storage}
               GSxmlstorageRoot:=GSxmlCol.AddChild('colStorage');
               GSxmlstorageRoot.Attributes['capSolidCur']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacitySolidCurrent;
               GSxmlstorageRoot.Attributes['capSolidMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacitySolidMax;
               GSxmlstorageRoot.Attributes['capLiquidCur']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityLiquidCurrent;
               GSxmlstorageRoot.Attributes['capLiquidMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityLiquidMax;
               GSxmlstorageRoot.Attributes['capGasCur']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityGasCurrent;
               GSxmlstorageRoot.Attributes['capGasMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityGasMax;
               GSxmlstorageRoot.Attributes['capBioCur']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityBioCurrent;
               GSxmlstorageRoot.Attributes['capBioMax']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storageCapacityBioMax;
					GSstorageMax:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_storedProducts)-1;
               if GSstorageMax>0 then
               begin
                  GSstorageCnt:=1;
                  while GSstorageCnt<=GSstorageMax do
                  begin
                     GSxmlstorage:=GSxmlstorageRoot.AddChild('storItem'+IntToStr(GSstorageCnt));
                     GSxmlstorage.Attributes['token']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storedProducts[GSstorageCnt].SP_token;
                     GSxmlstorage.Attributes['unit']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_storedProducts[GSstorageCnt].SP_unit;
                     inc(GSstorageCnt);
                  end;
               end;
               {.reserves}
               GSxmlReservesRoot:=GSxmlCol.AddChild('colReserves');
               GSxmlReservesRoot.Attributes['oxygen']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_reserveOxygen;
               GSxmlReservesRoot.Attributes['food']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_reserveFood;
               GSstorageMax:=length(FCDdgEntities[GScount].E_colonies[GScolCnt].C_reserveFoodProductsIndex)-1;
               GSstorageCnt:=1;
               while GSstorageCnt<=GSstorageMax do
               begin
                  GSxmlReserves:=GSxmlReservesRoot.AddChild( 'foodRve'+IntToStr( GSstorageCnt ) );
                  GSxmlReserves.Attributes['index']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_reserveFoodProductsIndex[ GSstorageCnt ];
                  inc(GSstorageCnt);
               end;
               GSxmlReservesRoot.Attributes['water']:=FCDdgEntities[GScount].E_colonies[GScolCnt].C_reserveWater;
            end; //==END== if GSsettleMax>0 ==//
            inc(GScolCnt);
         end; //==END== while GScolCnt<=GScolMax do ==//
      end; //==END== if GScolMax>0 ==//
      GSspmMax:=Length(FCDdgEntities[GScount].E_spmSettings)-1;
      if GSspmMax>0
      then
      begin
         GSxmlItm:=GSxmlEnt.AddChild('entSPMset');
         GSxmlItm.Attributes['modCoh']:=FCDdgEntities[GScount].E_spmMod_Cohesion;
         GSxmlItm.Attributes['modTens']:=FCDdgEntities[GScount].E_spmMod_Tension;
         GSxmlItm.Attributes['modSec']:=FCDdgEntities[GScount].E_spmMod_Security;
         GSxmlItm.Attributes['modEdu']:=FCDdgEntities[GScount].E_spmMod_Education;
         GSxmlItm.Attributes['modNat']:=FCDdgEntities[GScount].E_spmMod_Natality;
         GSxmlItm.Attributes['modHeal']:=FCDdgEntities[GScount].E_spmMod_Health;
         GSxmlItm.Attributes['modBur']:=FCDdgEntities[GScount].E_spmMod_Bureaucracy;
         GSxmlItm.Attributes['modCorr']:=FCDdgEntities[GScount].E_spmMod_Corruption;
         GSspmCnt:=1;
         while GSspmCnt<=GSspmMax do
         begin
            GSxmlSPM:=GSxmlItm.AddChild('entSPM');
            GSxmlSPM.Attributes['token']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_token;
            GSxmlSPM.Attributes['duration']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_duration;
            GSxmlSPM.Attributes['ucCost']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_ucCost;
            GSxmlSPM.Attributes['ispolicy']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_isPolicy;
            if FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['isSet']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_iPtIsSet;
               GSxmlSPM.Attributes['aprob']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_iPtAcceptanceProbability;
            end
            else if not FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_isPolicy
            then
            begin
               GSxmlSPM.Attributes['belieflvl']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_iPtBeliefLevel;
               GSxmlSPM.Attributes['spreadval']:=FCDdgEntities[GScount].E_spmSettings[GSspmCnt].SPMS_iPtAcceptanceProbability;
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

procedure FCMdFSG_Game_SaveAndFlushOther;
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
      FCMdFSG_Game_Save;
   finally
      {.read the document}
      FCWinMain.FCXMLcfg.FileName:=FCVdiPathConfigFile;
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
      SFOcurrDir:=FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName;
      SFOcurrG:=IntToStr(SFOtimeYr)
         +'-'+IntToStr(SFOtimeMth)
         +'-'+IntToStr(SFOtimeDay)
         +'-'+IntToStr(SFOtimeHr)
         +'-'+IntToStr(SFOtimeMin)
         +'.xml';
      if FileExists(SFOcurrDir+'\'+SFOcurrG)
      then
      begin
         CopyFile(pchar(SFOcurrDir+'\'+SFOcurrG),pchar(FCVdiPathConfigDir+SFOcurrG),false);
         FCMcF_Files_Del(SFOcurrDir+'\','*.*');
         CopyFile(pchar(FCVdiPathConfigDir+SFOcurrG),pchar(SFOcurrDir+'\'+SFOcurrG),false);
         DeleteFile(pchar(FCVdiPathConfigDir+SFOcurrG));
      end;
   end;
end;

end.
