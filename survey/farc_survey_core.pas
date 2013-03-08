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
//   SysUtils;

   farc_data_game
   ,farc_univ_func;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMsC_Expedition_Setup(
   const Entity
         ,Colony
         ,Region: integer;
   const LocationUniverse: TFCRufStelObj ;
   const TypeOfSurvey:TFCEdgPlanetarySurveys;
   const MissionExtension: TFCEdgPlanetarySurveyExtensions
   );

implementation

uses
   farc_data_planetarysurvey
   ,farc_data_univ
   ,farc_survey_functions;
//   farc_data_game
//   ,farc_data_infrprod
//   ,farc_data_init
//   ,farc_data_planetarysurvey
//   ,farc_game_prod
//   ,farc_win_debug;

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
   const LocationUniverse: TFCRufStelObj ;
   const TypeOfSurvey:TFCEdgPlanetarySurveys;
   const MissionExtension: TFCEdgPlanetarySurveyExtensions
   );
var
   Count
   ,CurrentPlanetarySurvey
   ,Max
   ,CurrentVehiclesGroup: integer;
begin
   Count:=1;
   CurrentPlanetarySurvey:=0;
   Max:=length( FCDsfSurveyVehicles )-1;
   CurrentVehiclesGroup:=0;
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
            setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, CurrentVehiclesGroup+1 );
            //FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].:=;
            //put EMO into VGroup sub data structure
         end;
         inc( CurrentVehiclesGroup );
         setlength( FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups, CurrentVehiclesGroup+1 );
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_linkedStorage:=FCDsfSurveyVehicles[Count].SV_storageIndex;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfUnits:=FCDsfSurveyVehicles[Count].SV_choosenUnits;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_numberOfVehicles:=FCDsfSurveyVehicles[Count].SV_numberOfVehicles;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_vehiclesFunction:=FCDsfSurveyVehicles[Count].SV_function;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_speed:=FCDsfSurveyVehicles[Count].SV_speed;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_totalMissionTime:=FCDsfSurveyVehicles[Count].SV_missionTime;
         case TypeOfSurvey of
            psResources: FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityResources;

            psBiosphere: FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityBiosphere;

            psFeaturesArtifacts: FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_usedCapability:=FCDsfSurveyVehicles[Count].SV_capabilityFeaturesArtifacts;
         end;
         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_crew:=FCDsfSurveyVehicles[Count].SV_crew;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfOneWayTravel:=;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_timeOfMission:=;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_percentofSurfaceSurveyedByDay:=;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhase:=;
//         FCDdgEntities[Entity].E_planetarySurveys[CurrentPlanetarySurvey].PS_vehiclesGroups[CurrentVehiclesGroup].VG_currentPhaseElapsedTime:=;
      end;
      inc( Count );
   end;
end;

end.
