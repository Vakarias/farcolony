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

   ,farc_data_game;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================


//===========================END FUNCTIONS SECTION==========================================

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
///   core process of the resources survey subsystem
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMsC_ResourceSurvey_Core;

implementation

uses
   farc_data_planetarysurvey
   ,farc_data_univ
   ,farc_survey_functions
   ,farc_univ_func
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

procedure FCMsC_Expedition_Setup(
   const Entity
         ,Colony
         ,Region: integer;
   const TypeOfSurvey:TFCEdgPlanetarySurveys;
   const MissionExtension: TFCEdgPlanetarySurveyExtensions
   );
{:Purpose: setup an expedition data structure.
    Additions:
      -2013Mar12- *add: VG_timeOfReplenishment initialization.
      -2013Mar11- *add: PS_completionPercent + PSS initialization.
      -2013Mar10- *add: code completion.
}
{:DEV NOTES: don't forget to assign population if it's required + update the STORAGE!!!  vehicles are used!.}
   var
      Count
      ,CurrentPlanetarySurvey
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
            if LocationUniverse[4]=0
            then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationSat:=''
            else if LocationUniverse[4]>0
            then FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_locationSat:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_satellitesList[LocationUniverse[4]].OO_dbTokenId;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_targetRegion:=Region;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_linkedColony:=Colony;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_missionExtension:=MissionExtension;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_pss:=0;
            FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_completionPercent:=0;
            setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, 1 );
         end;
         inc( CurrentVehiclesGroup );
         setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, CurrentVehiclesGroup+1 );
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_linkedStorage:=FCDsfSurveyVehicles[Count].SV_storageIndex;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfUnits:=FCDsfSurveyVehicles[Count].SV_choosenUnits;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfVehicles:=FCDsfSurveyVehicles[Count].SV_numberOfVehicles;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_vehiclesFunction:=FCDsfSurveyVehicles[Count].SV_function;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_speed:=FCDsfSurveyVehicles[Count].SV_speed;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_totalMissionTime:=FCDsfSurveyVehicles[Count].SV_missionTime;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_crew:=FCDsfSurveyVehicles[Count].SV_crew;
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
      end;
      inc( Count );
   end;
end;

procedure FCMsC_ResourceSurvey_Core;
{:Purpose: core process of the resources survey subsystem.
    Additions:
}
   var
      CompletionVehiclesGroups
      ,CountEntity
      ,CountSurvey
      ,CountVehiclesGroup
      ,MaxEntity
      ,MaxSurvey
      ,MaxVehiclesGroup: integer;

      mustProcessPSS: boolean;

begin
   CompletionVehiclesGroups:=0;
   CountEntity:=1;
   CountSurvey:=0;
   CountVehiclesGroup:=0;
   {:DEV NOTES: test here if there are any completed survey, if its the case=> PostProcess: update entity's surveyed resources in the array and finalize the data + remove after that the completed survey.}
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
         MaxVehiclesGroup:=length( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups )-1;
         CountVehiclesGroup:=1;
         while CountVehiclesGroup<=MaxVehiclesGroup do
         begin
            case FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase of
               pspInTransitToSite:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfOneWayTravel then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase:=pspResourcesSurveying;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime:=1;
                     mustProcessPSS:=true;
                     {:DEV NOTES: if entity=0, trigger a message to the player to inform him/her that a group is arrived on site.}
                  end;
               end;

               pspResourcesSurveying:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfMission then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase:=pspBackToBase;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime:=1;
                     mustProcessPSS:=true;
                     {:DEV NOTES: if entity=0, trigger a message to the player to inform him/her that a group has finished its survey mission and is back to base.}
                  end;
               end;

               pspBackToBase:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfOneWayTravel then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase:=pspReplenishment;
                     if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfReplenishment=0
                     then FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfReplenishment:=FCFsF_SurveyVehicles_ReplenishmentCalc(
                        FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_numberOfVehicles * FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_numberOfUnits
                        );
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime:=1;
                  end;
               end;

               pspReplenishment:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfReplenishment then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase:=pspInTransitToSite;
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime:=1;
                  end;
               end;

               pspBackToBaseFINAL:
               begin
                  inc( FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime );
                  if FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhaseElapsedTime>FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_timeOfOneWayTravel then
                  begin
                     FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase:=pspMissionCompletion;
                     inc( CompletionVehiclesGroups );
                  end;
               end;

               pspMissionCompletion: inc( CompletionVehiclesGroups );
            end; //==END== case FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_vehiclesGroups[CountVehiclesGroup].VG_currentPhase ==//
            inc( CountVehiclesGroup );
         end; //==END== while CountVehiclesGroup<=MaxVehiclesGroup ==//
         if CompletionVehiclesGroups=0 then
         begin


            {:DEV NOTES: if 100% => endOfProcess => OOR_resourceSurveyedBy is updated, a message is triggered and all the vehicles groups are back to baseFINAL + target region=0
               FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion:=0;

               OR DEPENDS of mission extension setup!

               the back to base FINAL depends on the current phase a group has
                pspInTransitToSite=> btbF w/ days travel = current elapsed time

                pspResourcesSurveying=> btbF normally w/ one way travel duration

                pspBackToBase=> only switch btbF

                pspReplenishment=> stop it and switch on  pspMissionCompletion
            .}
         end
         else if CompletionVehiclesGroups=MaxVehiclesGroup then
         begin
            {.the expedition will be removed the next day}
            FCDdgEntities[CountEntity].E_planetarySurveys[CountSurvey].PS_targetRegion:=-1;
         end;
         inc( CountSurvey );
      end; //==END== while CountSurvey<=MaxSurvey ==//
      inc( CountEntity );
   end; //==END== while CountEntity<=MaxEntity ==//
end;

end.
