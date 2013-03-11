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
      -2013Mar10- *add: code completion.
}
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

end.
