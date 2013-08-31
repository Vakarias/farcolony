{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: planetary survey - core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

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
unit farc_survey_core;

interface

uses
   SysUtils

   ,farc_data_game
   ,farc_data_univ;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   setup an entire expedition in the final stage post-mission
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="SurveyToApply">planetary survey index #</param>
procedure FCMsC_Expedition_BackToBaseFinal( const Entity, SurveyToApply: integer );

///<summary>
///   setup an expedition data structure
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Region">surveyed region index #</param>
///   <param name="TypeOfSurvey">type of survey</param>
///   <param name="MissionExtension">mission extension configuration</param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMsC_Expedition_Setup(
   const Entity
         ,Colony
         ,Region: integer;
   const TypeOfSurvey:TFCEdgPlanetarySurveys;
   const MissionExtension: TFCEdgPlanetarySurveyExtensions
   );

///<summary>
///   process the release list
///</summary>
procedure FCMsC_ReleaseList_Process;

///<summary>
///   core process of the resources survey subsystem
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMsC_ResourceSurvey_Core;

///<summary>
///   process the possible result and outcomes of a resource survey
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="PlanetarySurvey">planetary survey index #</param>
///   <param name="SurveyProbability">survey probability</param>
///   <param name="SpotType">type of resource spot</param>
///   <param name="SpotRarity">rarity of the resource</param>
///   <param name="SpotRarityThreshold">rarity threshold</param>
///   <param name="SpotQuality">quality of the resource spot</param>
///   <remarks></remarks>
procedure FCMsC_ResourceSurvey_ResultProcess(
   const Entity
         ,PlanetarySurvey
         ,SurveyProbability: integer;
   const SpotType: TFCEduResourceSpotTypes;
   const SpotRarity: TFCEduResourceSpotRarity;
   const SpotRarityThreshold: integer;
   const SpotQuality: TFCEduResourceSpotQuality
   );

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_planetarysurvey
   ,farc_game_colony
   ,farc_game_prodrsrcspots
   ,farc_survey_functions
   ,farc_ui_coredatadisplay
   ,farc_univ_func
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
//   SCisReleaseListEmpty: boolean;

   SClocationUniverse: TFCRufStelObj;

//   SCreleaseList: array [0..FCCdiFactionsMax] of array of integer;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMsC_Expedition_BackToBaseFinal( const Entity, SurveyToApply: integer );
{:Purpose: setup an entire expedition in the final stage post-mission.
   Additions:
}
   var
      Count
      ,Max: integer;
begin
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups )-1;
   while Count <= Max do
   begin
      case FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhase of
         pspInTransitToSite:
         begin
            FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhase:=pspBackToBaseFinal;
            FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_timeOfOneWayTravel:=FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhaseElapsedTime;
            FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhaseElapsedTime:=0;
         end;

         pspResourcesSurveying:
         begin
            FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhase:=pspBackToBaseFinal;
            FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhaseElapsedTime:=0;
         end;

         pspBackToBase: FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhase:=pspBackToBaseFinal;

         pspReplenishment: FCDdgEntities[Entity].E_planetarySurveys[SurveyToApply].PS_vehiclesGroups[Count].VG_currentPhase:=pspMissionCompletion;
      end;
      inc( Count );
   end;
end;

procedure FCMsC_Expedition_Setup(
   const Entity
         ,Colony
         ,Region: integer;
   const TypeOfSurvey:TFCEdgPlanetarySurveys;
   const MissionExtension: TFCEdgPlanetarySurveyExtensions
   );
{:Purpose: setup an expedition data structure.
    Additions:
      -2013Mar25- *fix: remove an error in the use of indexes for SRS_currentPlanetarySurvey loading.
      -2013Mar21/24- *add: assign and update crew-related and storage data.
      -2013Mar17- *add: OOR_resourceSurveyedBy initialization.
      -2013Mar15- *add: PS_linkedSurveyedResource initialization.
      -2013Mar13- *add: PS_meanEMO initialization.
      -2013Mar12- *add: VG_timeOfReplenishment initialization.
      -2013Mar11- *add: PS_completionPercent + PSS initialization.
      -2013Mar10- *add: code completion.
}
{:DEV NOTES: don't forget to assign population if it's required + update the STORAGE!!!  vehicles are used!.}
   var
      Count
      ,CurrentPlanetarySurvey
      ,CurrentSurveyedResources
      ,Max
      ,CurrentVehiclesGroup: integer;

      LocationUniverse: TFCRufStelObj;
begin
   Count:=1;
   CurrentPlanetarySurvey:=0;
   Max:=length( FCDsfSurveyVehicles )-1;
   CurrentVehiclesGroup:=0;
   LocationUniverse:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[Entity].E_colonies[Colony].C_locationStarSystem
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationStar
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationOrbitalObject
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationSatellite
      );
   while Count<=Max do
   begin
      if FCDsfSurveyVehicles[Count].SV_choosenUnits>0 then
      begin
         if CurrentPlanetarySurvey=0 then
         begin
            CurrentPlanetarySurvey:=length( FCDdgEntities[Entity].E_planetarySurveys );
            setlength( FCDdgEntities[Entity].E_planetarySurveys, CurrentPlanetarySurvey+1 );
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_type:=TypeOfSurvey;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationSSys:=FCDduStarSystem[LocationUniverse[1]].SS_token;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationStar:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_token;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationOobj:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_dbTokenId;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_targetRegion:=Region;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_meanEMO:=0;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_linkedColony:=Colony;
            CurrentSurveyedResources:=FCFgPRS_PresenceByLocation_Check(
               Entity
               ,LocationUniverse
               );
            if CurrentSurveyedResources=0
            then CurrentSurveyedResources:=FCFgPRS_SurveyedResourceSpots_Add(
               Entity
               ,LocationUniverse
               );
            FCDdgEntities[Entity].E_surveyedResourceSpots[CurrentSurveyedResources].SRS_surveyedRegions[Region].SRS_currentPlanetarySurvey:=CurrentPlanetarySurvey;
            if LocationUniverse[4]=0 then
            begin
               FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationSat:='';
               FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_regions[Region].OOR_resourceSurveyedBy[Entity]:=CurrentSurveyedResources;
            end
            else if LocationUniverse[4]>0 then
            begin
               FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationSat:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_satellitesList[LocationUniverse[4]].OO_dbTokenId;
               FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_satellitesList[LocationUniverse[4]].OO_regions[Region].OOR_resourceSurveyedBy[Entity]:=CurrentSurveyedResources;
            end;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_linkedSurveyedResource:=CurrentSurveyedResources;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_missionExtension:=MissionExtension;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_pss:=0;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_completionPercent:=0;
            setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, 1 );
         end;
         inc( CurrentVehiclesGroup );
         setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, CurrentVehiclesGroup+1 );
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_linkedStorage:=FCDsfSurveyVehicles[Count].SV_storageIndex;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfUnits:=FCDsfSurveyVehicles[Count].SV_choosenUnits;
         FCFgC_Storage_Update(
            FCDdgEntities[Entity].E_colonies[FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_linkedColony].C_storedProducts[FCDsfSurveyVehicles[Count].SV_storageIndex].SP_token
            ,-FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfUnits
            ,Entity
            ,FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_linkedColony
            ,false
            );
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfVehicles:=FCDsfSurveyVehicles[Count].SV_numberOfVehicles;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_vehiclesFunction:=FCDsfSurveyVehicles[Count].SV_function;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_speed:=FCDsfSurveyVehicles[Count].SV_speed;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_totalMissionTime:=FCDsfSurveyVehicles[Count].SV_missionTime;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_crew:=FCDsfSurveyVehicles[Count].SV_crew;
         if FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_crew>0
         then FCDdgEntities[Entity].E_colonies[Colony].C_population.CP_classColonistAssigned:=FCDdgEntities[Entity].E_colonies[Colony].C_population.CP_classColonistAssigned
            + FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_crew;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_regionEMO:=FCDsfSurveyVehicles[Count].SV_emo;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel:=FCDsfSurveyVehicles[Count].SV_oneWayTravel;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfMission:=FCDsfSurveyVehicles[Count].SV_timeOfMission;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfReplenishment:=0;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_distanceOfSurvey:=FCDsfSurveyVehicles[Count].SV_distanceOfSurvey;
         case TypeOfSurvey of
            psResources:
            begin
               FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityResources;
               if FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel=0
               then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhase:=pspResourcesSurveying;
            end;

            psBiosphere:
            begin
               FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityBiosphere;
               if FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel=0
               then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhase:=pspBiosphereSurveying;
            end;

            psFeaturesArtifacts:
            begin
               FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityFeaturesArtifacts;
               if FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel=0
               then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhase:=pspFeaturesArtifactsSurveying;
            end;
         end;
         if FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel>0
         then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhase:=pspInTransitToSite;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhaseElapsedTime:=0;
      end; //==END== if FCDsfSurveyVehicles[Count].SV_choosenUnits>0 ==//
      inc( Count );
   end; //==END== while Count<=Max ==//
end;

procedure FCMsC_ReleaseList_Process;
{:Purpose: process the release list.
    Additions:
      -2013Mar30- *add: E_cleanupSurveys.
}
   var
      CountSurvey
      ,CountEntity
      ,CountVeh
      ,MaxSurvey
      ,MaxVeh
      ,NewMax: integer;

      NewArray: array of TFCRdgPlanetarySurvey;
begin
   CountEntity:=1;
   while CountEntity<=FCCdiFactionsMax do
   begin
      if FCDdgEntities[CountEntity].E_cleanupSurveys then
      begin
         MaxSurvey:=length( FCDdgEntities[CountEntity].E_planetarySurveys )-1;
         NewMax:=0;
         SetLength( NewArray, NewMax + 1 );
         CountSurvey:=1;
         while CountSurvey<=MaxSurvey do
         begin
            if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion=-1 then
            begin
               MaxVeh:=length( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups ) - 1;
               CountVeh:=1;
               while CountVeh<=MaxVeh do
               begin
                  FCFgC_Storage_Update(
                     FCDdgEntities[CountEntity].E_colonies[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedColony].C_storedProducts[FCDsfSurveyVehicles[CountSurvey].SV_storageIndex].SP_token
                     ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVeh].VG_numberOfUnits
                     ,CountEntity
                     ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedColony
                     ,false
                     );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVeh].VG_crew>0
                  then FCDdgEntities[CountEntity].E_colonies[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedColony].C_population.CP_classColonistAssigned:=
                     FCDdgEntities[CountEntity].E_colonies[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedColony].C_population.CP_classColonistAssigned
                     - FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVeh].VG_crew;
                  inc( CountVeh );
               end;
            end
            else if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion>-1 then
            begin
               inc( NewMax );
               SetLength( NewArray, NewMax + 1 );
               NewArray[NewMax]:=FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey];
            end;
            inc( CountSurvey );
         end;
         SetLength( FCDdgEntities[CountEntity].E_planetarySurveys, NewMax + 1 );
         CountSurvey:=1;
         while CountSurvey<=NewMax do
         begin
            FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey]:=NewArray[CountSurvey];
            inc( CountSurvey );
         end;
      end;
      inc( CountEntity );
   end;
end;

procedure FCMsC_ResourceSurvey_Core;
{:Purpose: core process of the resources survey subsystem.
    Additions:
      -2013Aug31- *add/mod: separate each ore field, according to the completed FUG.
      -2013Mar30- *add: E_cleanupSurveys.
      -2013Mar26- *fix: remove a bug that prevented the player's faction to be processed.
                  *add: pspResourcesSurveying - only switch to BackToBase if oneWayTravel>0.
                  *add: pspReplenishment - only switch to pspInTransitToSite if oneWayTravel>0.
                  *add: creation of the inline procedures _SetReplenishment and _SetResourcesSurveying.
      -2013Mar25- *add: if the survey is 100% completed, the SRS_currentPlanetarySurvey isu pdated in accordance.
}
   var
      CompletionVehiclesGroups
      ,CountEntity
      ,CountSurvey
      ,CountMisc1
      ,MaxEntity
      ,MaxSurvey
      ,MaxMisc1
      ,RarityThreshold
      ,SurveyProbabilityBySpot: integer;

      SurveyProbability
      ,TotalCapabilityVehiclesOnSite: extended;

      mustProcessPSS: boolean;

      SpotQualityGasField
      ,SpotQualityHydroWell
      ,SpotQualityIcyOreField
      ,SpotQualityOreFieldCarbo
      ,SpotQualityOreFieldMetal
      ,SpotQualityOreFieldRare
      ,SpotQualityOreFieldUran
      ,SpotQualityUnderWater: TFCEduResourceSpotQuality;

      SpotRarityGasField
      ,SpotRarityHydroWell
      ,SpotRarityIcyOreField
      ,SpotRarityOreFieldCarbo
      ,SpotRarityOreFieldMetal
      ,SpotRarityOreFieldRare
      ,SpotRarityOreFieldUran
      ,SpotRarityUnderWater: TFCEduResourceSpotRarity;

      procedure _SetReplenishment;
      begin
         FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase:=pspReplenishment;
         if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfReplenishment=0
         then FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfReplenishment:=FCFsF_SurveyVehicles_ReplenishmentCalc(
            FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_numberOfVehicles * FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_numberOfUnits
            );
         FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime:=1;
      end;

      procedure _SetResourcesSurveying;
      begin
         FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase:=pspResourcesSurveying;
         FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime:=1;
         mustProcessPSS:=true;
         {:DEV NOTES: if entity=0, trigger a message to the player to inform him/her that a group is arrived on site.}
      end;

begin
   CompletionVehiclesGroups:=0;
   CountEntity:=0;
   CountSurvey:=0;
   CountMisc1:=0;
   FCMsC_ReleaseList_Process;
   MaxEntity:=length( FCDdgEntities )-1;
   while CountEntity<=MaxEntity do
   begin
      CountSurvey:=1;
      MaxSurvey:=length( FCDdgEntities[CountEntity].E_planetarySurveys )-1;
      while CountSurvey<=MaxSurvey do
      begin
         if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_pss=0
         then mustProcessPSS:=true
         else mustProcessPSS:=false;
         TotalCapabilityVehiclesOnSite:=0;
         MaxMisc1:=length( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups )-1;
         {.CountMisc1= CountVehiclesGroup}
         CountMisc1:=1;
         while CountMisc1<=MaxMisc1 do
         begin
            case FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase of
               pspInTransitToSite:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel
                  then _SetResourcesSurveying;
               end;

               pspResourcesSurveying:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime );
                  if ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfMission )
                     and ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel=0 )
                  then _SetReplenishment
                  else if ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfMission )
                     and ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel>0 )
                  then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase:=pspBackToBase;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime:=1;
                     mustProcessPSS:=true;
                     {:DEV NOTES: if entity=0, trigger a message to the player to inform him/her that a group has finished its survey mission and is back to base.}
                  end
                  else TotalCapabilityVehiclesOnSite:=TotalCapabilityVehiclesOnSite+(
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_usedCapability
                        * sqrt( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_numberOfVehicles * FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_numberOfUnits )
                        * 5
                     );
               end;

               pspBackToBase:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel
                  then _SetReplenishment;
               end;

               pspReplenishment:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime );
                  if ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfReplenishment )
                     and ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel=0 )
                  then _SetResourcesSurveying
                  else if ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfReplenishment )
                     and ( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel>0 )
                  then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase:=pspInTransitToSite;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime:=1;
                  end;
               end;

               pspBackToBaseFINAL:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_timeOfOneWayTravel then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountMisc1].VG_currentPhase:=pspMissionCompletion;
                     inc( CompletionVehiclesGroups );
                  end;
               end;

               pspMissionCompletion: inc( CompletionVehiclesGroups );
            end; //==END== case FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase ==//
            inc( CountMisc1 );
         end; //==END== while CountMisc1<=MaxMisc1 ==//
         if CompletionVehiclesGroups=0 then
         begin
            if mustProcessPSS
            then  FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_pss:=FCFsF_ResourcesSurvey_PSSEMOCalculations( CountEntity, CountSurvey );
            FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_completionPercent:=FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_completionPercent+FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_pss;
            SClocationUniverse:=FCFuF_StelObj_GetFullRow(
               FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_locationSSys
               ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_locationStar
               ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_locationOobj
               ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_locationSat
               );
            CountMisc1:=1;
            if SClocationUniverse[4]=0 then
            begin
               MaxMisc1:=length( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot )-1;
               while CountMisc1<=MaxMisc1 do
               begin
                  case FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_type of
                     rstGasField:
                     begin
                        SpotQualityGasField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityGasField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstHydroWell:
                     begin
                        SpotQualityHydroWell:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityHydroWell:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstIcyOreField:
                     begin
                        SpotQualityIcyOreField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityIcyOreField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldCarbo:
                     begin
                        SpotQualityOreFieldCarbo:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldCarbo:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldMetal:
                     begin
                        SpotQualityOreFieldMetal:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldMetal:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldRareMetal:
                     begin
                        SpotQualityOreFieldRare:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldRare:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldUran:
                     begin
                        SpotQualityOreFieldUran:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldUran:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstUnderWater:
                     begin
                        SpotQualityUnderWater:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityUnderWater:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;
                  end;
                  inc( CountMisc1 );
               end;
            end
            else if SClocationUniverse[4]>0 then
            begin
               MaxMisc1:=length( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot )-1;
               while CountMisc1<=MaxMisc1 do
               begin
                  case FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_type of
                     rstGasField:
                     begin
                        SpotQualityGasField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityGasField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstHydroWell:
                     begin
                        SpotQualityHydroWell:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityHydroWell:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstIcyOreField:
                     begin
                        SpotQualityIcyOreField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityIcyOreField:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldCarbo:
                     begin
                        SpotQualityOreFieldCarbo:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldCarbo:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldMetal:
                     begin
                        SpotQualityOreFieldMetal:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldMetal:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldRareMetal:
                     begin
                        SpotQualityOreFieldRare:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldRare:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstOreFieldUran:
                     begin
                        SpotQualityOreFieldUran:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityOreFieldUran:=FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;

                     rstUnderWater:
                     begin
                        SpotQualityUnderWater:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_quality;
                        SpotRarityUnderWater:=
                           FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].OOR_resourceSpot[CountMisc1].RRS_rarity;
                     end;
                  end;
                  inc( CountMisc1 );
               end;
            end;
            SurveyProbability:=TotalCapabilityVehiclesOnSite - ( ( 1 - FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_meanEMO ) * 100 );
            if SpotRarityGasField<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityGasField );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstGasField
                  ,SpotRarityGasField
                  ,RarityThreshold
                  ,SpotQualityGasField
                  );
            end;
            if SpotRarityHydroWell<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityHydroWell );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstHydroWell
                  ,SpotRarityHydroWell
                  ,RarityThreshold
                  ,SpotQualityHydroWell
                  );
            end;
            if SpotRarityIcyOreField<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityIcyOreField );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstIcyOreField
                  ,SpotRarityIcyOreField
                  ,RarityThreshold
                  ,SpotQualityIcyOreField
                  );
            end;
            if SpotRarityOreFieldCarbo<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityOreFieldCarbo );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstOreFieldCarbo
                  ,SpotRarityOreFieldCarbo
                  ,RarityThreshold
                  ,SpotQualityOreFieldCarbo
                  );
            end;
            if SpotRarityOreFieldMetal<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityOreFieldMetal );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstOreFieldMetal
                  ,SpotRarityOreFieldMetal
                  ,RarityThreshold
                  ,SpotQualityOreFieldMetal
                  );
            end;
            if SpotRarityOreFieldRare<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityOreFieldRare );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstOreFieldRareMetal
                  ,SpotRarityOreFieldRare
                  ,RarityThreshold
                  ,SpotQualityOreFieldRare
                  );
            end;
            if SpotRarityOreFieldUran<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityOreFieldUran );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstOreFieldUran
                  ,SpotRarityOreFieldUran
                  ,RarityThreshold
                  ,SpotQualityOreFieldUran
                  );
            end;
            if SpotRarityUnderWater<rsrAbsent then
            begin
               SurveyProbabilityBySpot:=round( ( FCFcF_Random_DoInteger( 99 ) + 1 ) + SurveyProbability );
               RarityThreshold:=FCFsF_ResourcesSurvey_SpotRarityThreshold( SpotRarityUnderWater );
               FCMsC_ResourceSurvey_ResultProcess(
                  CountEntity
                  ,CountSurvey
                  ,SurveyProbabilityBySpot
                  ,rstUnderWater
                  ,SpotRarityUnderWater
                  ,RarityThreshold
                  ,SpotQualityUnderWater
                  );
            end;
            if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_completionPercent>=100 then
            begin
               case FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_missionExtension of
                  pseSelectedRegionOnly, pseAllAdjacentRegions, pseAllControlledNeutralRegions:
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_completionPercent:=100;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion:=0;
                     FCMsC_Expedition_BackToBaseFinal( CountEntity, CountSurvey );
                     {:DEV NOTES: if entity=0, trigger a message to the player to inform him/her that the survey mission is complete.}
                  end;

//                  pseAllAdjacentRegions:
//                  begin
//                     {:DEV NOTES: put regions to survey into a secondary array + avoid oceanic}
//                  end;
//
//                  pseAllControlledNeutralRegions:
//                  begin
//                  {:DEV NOTES: put regions to survey into a secondary array + avoid oceanic}
//                  end;
               end

            end;
         end //==END== if CompletionVehiclesGroups=0 ==//
         else if CompletionVehiclesGroups=MaxMisc1 then
         begin
            {.the expedition will be removed the next day}
            FCDdgEntities[CountEntity].E_surveyedResourceSpots[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedSurveyedResource].SRS_surveyedRegions[FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion].SRS_currentPlanetarySurvey:=0;
            FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion:=-1;
            if not FCDdgEntities[CountEntity].E_cleanupSurveys
            then FCDdgEntities[CountEntity].E_cleanupSurveys:=true;
         end;
         if CountEntity=0
         then FCMuiCDD_Colony_Update(
            cdlPlanetarySurvey
            ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_linkedColony
            ,0
            ,FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion
            ,true
            ,false
            ,false
            );
         inc( CountSurvey );
      end; //==END== while CountSurvey<=MaxSurvey ==//
      inc( CountEntity );
   end; //==END== while CountEntity<=MaxEntity ==//
end;

procedure FCMsC_ResourceSurvey_ResultProcess(
   const Entity
         ,PlanetarySurvey
         ,SurveyProbability: integer;
   const SpotType: TFCEduResourceSpotTypes;
   const SpotRarity: TFCEduResourceSpotRarity;
   const SpotRarityThreshold: integer;
   const SpotQuality: TFCEduResourceSpotQuality
   );
   var
      MeanQuality
      ,NewSpotSize
      ,RegionSurface: extended;

      RarityCoef
      ,SpotIndex
      ,SurveyedIndex: integer;
begin
   MeanQuality:=0;
   NewSpotSize:=0;
   RegionSurface:=1;
   RarityCoef:=0;
   SpotIndex:=0;
   SurveyedIndex:=0;
   if SurveyProbability >= SpotRarityThreshold then
   begin
      SurveyedIndex:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_linkedSurveyedResource;
      SpotIndex:=FCFgPRS_ResourceSpots_SearchGenerate(
         Entity
         ,SurveyedIndex
         ,FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion
         ,SpotType
         ,SClocationUniverse
         );
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedIndex].SRS_surveyedRegions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].SR_ResourceSpots[SpotIndex].RS_meanQualityCoefficient=0 then
      begin
         MeanQuality:=FCFsF_ResourcesSurvey_SpotMeanQuality( SpotQuality );
         FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedIndex].SRS_surveyedRegions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].SR_ResourceSpots[SpotIndex].RS_meanQualityCoefficient:=MeanQuality;
      end;
      if SClocationUniverse[4]=0 then
      begin
         if FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_landType
            in [rst08CoastalRockyDesert..rst13CoastalFertile]
         then RegionSurface:=0.60;
         if ( SpotType=rstHydroWell )
            and ( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_relief = rr4Broken )
         then RegionSurface:=0.48
         else if ( SpotType=rstHydroWell )
            and ( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_relief = rr9Mountain )
         then RegionSurface:=0.3;
         RegionSurface:=RegionSurface * FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_regionSurface;
      end
      else if SClocationUniverse[4]>0 then
      begin
         if FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_landType
            in [rst08CoastalRockyDesert..rst13CoastalFertile]
         then RegionSurface:=0.60;
         if ( SpotType=rstHydroWell )
            and ( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_relief = rr4Broken )
         then RegionSurface:=0.48
         else if ( SpotType=rstHydroWell )
            and ( FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_relief = rr9Mountain )
         then RegionSurface:=0.3;
         RegionSurface:=RegionSurface * FCDduStarSystem[SClocationUniverse[1]].SS_stars[SClocationUniverse[2]].S_orbitalObjects[SClocationUniverse[3]].OO_satellitesList[SClocationUniverse[4]].OO_regionSurface;
      end;
      case SpotRarity of
         rsrRich: RarityCoef:=5;

         rsrAbundant: RarityCoef:=7;

         rsrCommon: RarityCoef:=10;

         rsrPresent: RarityCoef:=12;

         rsrUncommon: RarityCoef:=15;

         rsrRare: RarityCoef:=17;
      end;
      NewSpotSize:=FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedIndex].SRS_surveyedRegions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].SR_ResourceSpots[SpotIndex].RS_spotSizeMax + sqrt( RegionSurface / RarityCoef );
      FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedIndex].SRS_surveyedRegions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].SR_ResourceSpots[SpotIndex].RS_spotSizeMax:=round( NewSpotSize );
   end; //==END== if SurveyProbability >= SpotRarityThreshold ==//
end;

end.
