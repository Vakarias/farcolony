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

///<summary>
///   calculate the percent of surface surveyed by day (or PSS) and the mean of the EMOs
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="PlanetarySurvey">planetary survey index #</param>
///   <returns>PSS value</returns>
///   <remarks>the PSS value is rounded at 2 decimals</remarks>
function FCFsF_ResourcesSurvey_PSSEMOCalculations( const Entity, PlanetarySurvey: integer ): extended;

///<summary>
///   give the mean quality (MQ) in accordance of the resource spot's quality
///</summary>
///   <param name="Quality">quality enum</param>
///   <returns>mean quality (MQ)</returns>
///   <remarks>the MQ value is in x.xx format (1/100 of percent)</remarks>
function FCFsF_ResourcesSurvey_SpotMeanQuality( const Quality: TFCEduResourceSpotQuality ): extended;

///<summary>
///   give the rarity threshold (RT) in accordance of the resource spot's rarity
///</summary>
///   <param name="Rarity">rarity enum</param>
///   <returns>rarity threshold (RT)</returns>
function FCFsF_ResourcesSurvey_SpotRarityThreshold( const Rarity: TFCEduResourceSpotRarity ): integer;

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
///   get the phase string of a vehicles group inside a planetary survey
///</summary>
///   <param name="PhaseToExtract">phase to extract</param>
///   <returns>the string of the planetary survey phase</returns>
///   <remarks></remarks>
function FCFsF_SurveyVehicles_GetPhase( const PhaseToExtract: TFCEdgPlanetarySurveyPhases ): string;

///<summary>
///   determine the duration of the current phase for a vehicles group
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="PlanetarySurvey">planetary survey index #</param>
///   <param name="VehcilesGroup">vehicles group index #</param>
///   <returns>the duration of the current phase in standard days</returns>
///   <remarks></remarks>
function FCFsF_SurveyVehicles_GetPhaseDuration(
   const Entity
         ,PlanetarySurvey
         ,VehiclesGroup: integer
   ): integer;

///<summary>
///   calculate the replenishment duration
///</summary>
///   <param name="NumberOfVehicles"># of vehicles in total in the concerned group</param>
///   <returns>the replenishment duration in standard days</returns>
///   <remarks></remarks>
function FCFsF_SurveyVehicles_ReplenishmentCalc( const NumberOfVehicles: integer ): integer;

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
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_planetarysurvey
   ,farc_data_textfiles
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

function FCFsF_ResourcesSurvey_PSSEMOCalculations( const Entity, PlanetarySurvey: integer ): extended;
{:Purpose: calculate the percent of surface surveyed by day (or PSS) and the mean of the EMOs.
    Additions:
      -2013Mar13- *add: integrate the calculations of the mean EMO.
}
   var
      Count
      ,Max
      ,VehiclesCount: integer;

      PSS
      ,RegionSurface
      ,SumDV
      ,sumEMOs: extended;

      LocationUniverse: TFCRufStelObj;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups )-1;
   PSS:=0;
   RegionSurface:=0;
   SumDV:=0;
   LocationUniverse:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_locationSSys
      ,FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_locationStar
      ,FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_locationOobj
      ,FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_locationSat
      );
   if LocationUniverse[4]=0 then
   begin
      RegionSurface:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_regionSurface;
      if FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_landType
         in [rst08CoastalRockyDesert..rst13CoastalFertile]
      then RegionSurface:=RegionSurface * 0.60;
   end
   else if LocationUniverse[4]>0 then
   begin
      RegionSurface:=FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_satellitesList[LocationUniverse[4]].OO_regionSurface;
      if FCDduStarSystem[LocationUniverse[1]].SS_stars[LocationUniverse[2]].S_orbitalObjects[LocationUniverse[3]].OO_satellitesList[LocationUniverse[4]].OO_regions[FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_targetRegion].OOR_landType
         in [rst08CoastalRockyDesert..rst13CoastalFertile]
      then RegionSurface:=RegionSurface * 0.60;
   end;
   while Count <= Max do
   begin
      if FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[Count].VG_currentPhase = pspResourcesSurveying then
      begin
         SumDV:=SumDV + FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[Count].VG_distanceOfSurvey;
         inc( VehiclesCount );
         sumEMOs:=sumEMOs + FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[Count].VG_regionEMO;
      end;
      inc( Count );
   end;
   PSS:=( SumDV / RegionSurface ) * 100;
   FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_meanEMO:=FCFcF_Round( rttCustom2Decimal, sumEMOs / VehiclesCount );
   Result:=FCFcF_Round( rttCustom2Decimal, PSS );
end;

function FCFsF_ResourcesSurvey_SpotMeanQuality( const Quality: TFCEduResourceSpotQuality ): extended;
{:Purpose: give the mean quality (MQ) in accordance of the resource spot's quality.
}
   var
      MaxRange
      ,MinRange: integer;
begin
   Result:=0;
   MaxRange:=0;
   MinRange:=0;
   case Quality of
      rsqF_Bad:
      begin
         MaxRange:=13;
         MinRange:=1;
      end;

      rsqE_Poor:
      begin
         MaxRange:=20;
         MinRange:=14;
      end;

      rsqD_FairAverage:
      begin
         MaxRange:=26;
         MinRange:=21;
      end;

      rsqC_Good:
      begin
         MaxRange:=34;
         MinRange:=27;
      end;

      rsqB_Excellent:
      begin
         MaxRange:=40;
         MinRange:=35;
      end;

      rsqA_Perfect:
      begin
         MaxRange:=45;
         MinRange:=41;
      end;
   end;
   Result:=( MinRange + FCFcF_Random_DoInteger( MaxRange - MinRange ) ) * 0.01;
end;

function FCFsF_ResourcesSurvey_SpotRarityThreshold( const Rarity: TFCEduResourceSpotRarity ): integer;
{:Purpose: give the rarity threshold (RT) in accordance of the resource spot's rarity.
    Additions:
}
begin
   Result:=0;
   case Rarity of
      rsrRich: Result:=40;

      rsrAbundant: Result:=55;

      rsrCommon: Result:=75;

      rsrPresent: Result:=90;

      rsrUncommon: Result:=110;

      rsrRare: Result:=125;
   end;
end;

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

function FCFsF_SurveyVehicles_GetPhase( const PhaseToExtract: TFCEdgPlanetarySurveyPhases ): string;
{:Purpose: get the phase string of a vehicles group inside a planetary survey.
    Additions:
}
begin
   Result:='';
   case PhaseToExtract of
      pspInTransitToSite: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseInTransitToSite' );

      pspResourcesSurveying: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseResourcesSurveying' );

      pspBiosphereSurveying: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseBiosphereSurveying' );

      pspFeaturesArtifactsSurveying: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseFeaturesArtifactsSurveying' );

      pspBackToBase: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseBackToBase' );

      pspReplenishment: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseReplenishment' );

      pspBackToBaseFINAL: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseBackToBaseFINAL' );

      pspMissionCompletion: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'psPhaseMissionCompletion' );
   end;
end;

function FCFsF_SurveyVehicles_GetPhaseDuration(
   const Entity
         ,PlanetarySurvey
         ,VehiclesGroup: integer
   ): integer;
{:Purpose: determine the duration of the current phase for a vehicles group.
    Additions:
}
begin
   Result:=0;
   case FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_currentPhase of
      pspInTransitToSite: Result:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_timeOfOneWayTravel;

      pspResourcesSurveying, pspBiosphereSurveying ,pspFeaturesArtifactsSurveying: Result:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_timeOfMission;

      pspBackToBase: Result:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_timeOfOneWayTravel;

      pspReplenishment: Result:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_timeOfReplenishment;

      pspBackToBaseFINAL: Result:=FCDdgEntities[Entity].E_planetarySurveys[PlanetarySurvey].PS_vehiclesGroups[VehiclesGroup].VG_timeOfOneWayTravel;

      pspMissionCompletion: Result:=0;
   end;
end;

function FCFsF_SurveyVehicles_ReplenishmentCalc( const NumberOfVehicles: integer ): integer;
{:Purpose: calculate the replenishment duration.
    Additions:
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=sqrt( NumberOfVehicles * 0.1 );
   Result:=trunc( WorkingFloat )+1;
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
