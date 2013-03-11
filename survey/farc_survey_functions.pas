{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: planetary survey - common functions unit

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
unit farc_survey_functions;

interface

uses
   SysUtils;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   generate a listing of available survey vehicles into a colony's storage
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="GetFirstTestOnly">[true]=stop at first positive test, doesn't generate the detailed list, [false]=generate the detailed list in FCDsfSurveyVehicles</param>
///   <returns>the # of different products that are survey vehicles</returns>
///   <remarks>FCDsfSurveyVehicles is reseted whatever the value of FCDsfSurveyVehicles</remarks>
function FCFsF_SurveyVehicles_Get(
   const Entity, Colony: integer;
   const GetFirstTestOnly: boolean
   ): integer;

///<summary>
///   process the travel duration, if it's required, and the distance of survey
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="RegionOfDestination">region of destination where the survey will occur</param>
///   <param name="VehiclesGroupIndex">vehicles group index # in FCDsfSurveyVehicles</param>
///   <param name="useSameOrbitalObject">false= don't retrieve the orbital object location</param>
///   <param name="onlyUpdateDistanceSurvey">false= full calculations, true= only update the distance of survey</param>
///   <returns>true= the group has enough autonomy to go on site and process</returns>
///   <remarks>FCFsF_SurveyVehicles_Get must be called on time before to be able to use this function (the vehicles groups list must be generated) because some data are updated.</remarks>
function FCFsF_ResourcesSurvey_ProcessTravelSurveyDistance(
   const Entity
         ,Colony
         ,RegionOfDestination
         ,VehiclesGroupIndex: integer;
   const useSameOrbitalObject
         ,onlyUpdateDistanceSurvey: boolean
   ): boolean;


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   determine the EMO, according to the vehicles group function, and load it into the data structure
///</summary>
///   <param name="VehiclesGroupIndex">vehicles group index # in FCDsfSurveyVehicles</param>
///   <param name="Region">region index # where the EMO must be taken of</param>
///   <remarks>SFworkingOrbObject must be loaded with the correct data prior the call of this procedure</remarks>
procedure FCMsF_SurveyVehicles_EMOLoad( const VehiclesGroupIndex, Region: integer );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_planetarysurvey
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_prod
   ,farc_univ_func
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
var
   SFworkingOrbObject: TFCRufStelObj;
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFsF_SurveyVehicles_Get(
   const Entity, Colony: integer;
   const GetFirstTestOnly: boolean
   ): integer;
{:Purpose: generate a listing of available survey vehicles into a colony's storage.
    Additions:
      -2013Mar03- *add: new data - EMO, one way travel, time of mission and percent of surface surveyed by day.
      -2013Feb20- *add: SV_unitThreshold initialization.
      -2013Feb12- *mod: the 3rd parameter to GetFirstTestOnly is changed and its code too.
}
   var
      Count
      ,Max
      ,VehiclesProducts: integer;

      ClonedProduct: TFCRdipProduct;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts )-1;
   VehiclesProducts:=0;
   if not GetFirstTestOnly then
   begin
      SetLength( FCDsfSurveyVehicles, 0 );
      FCDsfSurveyVehicles:=nil;
   end;
   while Count<=Max do
   begin
      ClonedProduct:=FCDdipProducts[FCFgP_Product_GetIndex( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_token )];
      if ( ClonedProduct.P_function in [pfSurveyAir..pfSurveySwarmAntigrav] )
         and ( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_unit>0 )
         and ( GetFirstTestOnly ) then
      begin
         inc( VehiclesProducts );
         break;
      end
      else if ( ClonedProduct.P_function in [pfSurveyAir..pfSurveySwarmAntigrav] )
         and ( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_unit>0 )
         and ( not GetFirstTestOnly ) then
      begin
         inc( VehiclesProducts );
         SetLength( FCDsfSurveyVehicles, VehiclesProducts+1 );
         FCDsfSurveyVehicles[VehiclesProducts].SV_storageIndex:=Count;
         FCDsfSurveyVehicles[VehiclesProducts].SV_storageUnits:=Trunc( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_unit );
         FCDsfSurveyVehicles[VehiclesProducts].SV_choosenUnits:=0;
         FCDsfSurveyVehicles[VehiclesProducts].SV_unitThreshold:=0;
         FCDsfSurveyVehicles[VehiclesProducts].SV_token:=FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_token;
         FCDsfSurveyVehicles[VehiclesProducts].SV_function:=ClonedProduct.P_function;
         FCDsfSurveyVehicles[VehiclesProducts].SV_speed:=ClonedProduct.P_fSspeed;
         FCDsfSurveyVehicles[VehiclesProducts].SV_missionTime:=ClonedProduct.P_fSmissionTime;
         FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityResources:=ClonedProduct.P_fScapabilityResources;
         FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityBiosphere:=ClonedProduct.P_fScapabilityBiosphere;
         FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityFeaturesArtifacts:=ClonedProduct.P_fScapabilityFeaturesArtifacts;
         FCDsfSurveyVehicles[VehiclesProducts].SV_crew:=ClonedProduct.P_fScrew;
         FCDsfSurveyVehicles[VehiclesProducts].SV_numberOfVehicles:=ClonedProduct.P_fSvehicles;
         FCDsfSurveyVehicles[VehiclesProducts].SV_emo:=0;
         FCDsfSurveyVehicles[VehiclesProducts].SV_oneWayTravel:=0;
         FCDsfSurveyVehicles[VehiclesProducts].SV_timeOfMission:=0;
         FCDsfSurveyVehicles[VehiclesProducts].SV_distanceOfSurvey:=0;
      end;
      inc( Count );
   end;
   Result:=VehiclesProducts;
end;

function FCFsF_ResourcesSurvey_ProcessTravelSurveyDistance(
   const Entity
         ,Colony
         ,RegionOfDestination
         ,VehiclesGroupIndex: integer;
   const useSameOrbitalObject
         ,onlyUpdateDistanceSurvey: boolean
   ): boolean;
{:Purpose: process the travel duration, if it's required, and the distance of survey.
    Additions:
}
   var
      DaysOfTravel
      ,NearestSettlement
      ,MaxSettlements: integer;

      DistanceCoefficient
      ,DistanceOneWay
      ,DistanceSurvey: extended;

begin
   DaysOfTravel:=0;
   NearestSettlement:=0;
   MaxSettlements:=0;
   DistanceCoefficient:=0;
   DistanceOneWay:=0;
   DistanceSurvey:=0;
   Result:=false;
   MaxSettlements:=length( FCDdgEntities[Entity].E_colonies[Colony].C_settlements )-1;
   if not useSameOrbitalObject
   then SFworkingOrbObject:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[Entity].E_colonies[Colony].C_locationStarSystem
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationStar
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationOrbitalObject
      ,FCDdgEntities[Entity].E_colonies[Colony].C_locationSatellite
      );
   NearestSettlement:=FCFgC_Region_GetNearestSettlement(
      Entity
      ,Colony
      ,RegionOfDestination
      ,SFworkingOrbObject
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_settlements[NearestSettlement].S_locationRegion=RegionOfDestination then
   begin
      Result:=true;
      FCMsF_SurveyVehicles_EMOLoad( VehiclesGroupIndex, RegionOfDestination );
      FCDsfSurveyVehicles[VehiclesGroupIndex].SV_timeOfMission:=FCDsfSurveyVehicles[VehiclesGroupIndex].SV_missionTime;
   end
   else begin
      DistanceCoefficient:=FCFuF_Regions_CalculateDistance(
         SFworkingOrbObject
         ,FCDdgEntities[Entity].E_colonies[Colony].C_settlements[NearestSettlement].S_locationRegion
         ,RegionOfDestination
         );
      if SFworkingOrbObject[4]<=0
      then DistanceOneWay:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_meanTravelDistance * DistanceCoefficient
      else DistanceOneWay:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_satellitesList[SFworkingOrbObject[4]].OO_meanTravelDistance * DistanceCoefficient;
      DaysOfTravel:=trunc( DistanceOneWay / FCDsfSurveyVehicles[VehiclesGroupIndex].SV_speed ) + 1;
      if DaysOfTravel*2<FCDsfSurveyVehicles[VehiclesGroupIndex].SV_missionTime then
      begin
         Result:=true;
         FCMsF_SurveyVehicles_EMOLoad( VehiclesGroupIndex, RegionOfDestination );
         FCDsfSurveyVehicles[VehiclesGroupIndex].SV_oneWayTravel:=DaysOfTravel;
         FCDsfSurveyVehicles[VehiclesGroupIndex].SV_timeOfMission:=FCDsfSurveyVehicles[VehiclesGroupIndex].SV_missionTime - ( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_oneWayTravel shl 1 );
      end;
   end;
   if Result=true then
   begin
      DistanceSurvey:=( FCDsfSurveyVehicles[VehiclesGroupIndex].SV_speed * FCDsfSurveyVehicles[VehiclesGroupIndex].SV_numberOfVehicles * FCDsfSurveyVehicles[VehiclesGroupIndex].SV_capabilityResources ) / FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo;
      FCDsfSurveyVehicles[VehiclesGroupIndex].SV_distanceOfSurvey:=FCFcF_Round( rttDistanceKm, DistanceSurvey );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMsF_SurveyVehicles_EMOLoad( const VehiclesGroupIndex, Region: integer );
{:Purpose: determine the EMO, according to the vehicles group function, and load it into the data structure.
    Additions:
}
begin
   case FCDsfSurveyVehicles[VehiclesGroupIndex].SV_function of
      pfSurveyAir:
      begin
         if SFworkingOrbObject[4]<=0
         then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_regions[Region].OOR_emo.EMO_planetarySurveyAir
         else FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_satellitesList[SFworkingOrbObject[4]].OO_regions[Region].OOR_emo.EMO_planetarySurveyAir;
      end;

      pfSurveyAntigrav:
      begin
         if SFworkingOrbObject[4]<=0
         then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_regions[Region].OOR_emo.EMO_planetarySurveyAntigrav
         else FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_satellitesList[SFworkingOrbObject[4]].OO_regions[Region].OOR_emo.EMO_planetarySurveyAntigrav;
      end;

      pfSurveyGround:
      begin
         if SFworkingOrbObject[4]<=0
         then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_regions[Region].OOR_emo.EMO_planetarySurveyGround
         else FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_satellitesList[SFworkingOrbObject[4]].OO_regions[Region].OOR_emo.EMO_planetarySurveyGround;
      end;

      pfSurveySpace: ;

      pfSurveySwarmAntigrav:
      begin
         if SFworkingOrbObject[4]<=0
         then FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_regions[Region].OOR_emo.EMO_planetarySurveySwarmAntigrav
         else FCDsfSurveyVehicles[VehiclesGroupIndex].SV_emo:=FCDduStarSystem[SFworkingOrbObject[1]].SS_stars[SFworkingOrbObject[2]].S_orbitalObjects[SFworkingOrbObject[3]].OO_satellitesList[SFworkingOrbObject[4]].OO_regions[Region].OOR_emo.EMO_planetarySurveySwarmAntigrav;
      end;
   end;
end;

end.
