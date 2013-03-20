{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: region's resource spots (including surveys)

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
unit farc_game_prodrsrcspots;

interface

uses
   SysUtils

   ,farc_data_infrprod
   ,farc_data_univ
   ,farc_univ_func;

///<summary>
///   check if a surveyed resource spot is present for a specified region location within a specified entity
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="RegionLocation">universe location of the specified region</param>
///   <returns>the surveyed resource spot index #. 0 if not found</returns>
///   <remarks></remarks>
function FCFgPRS_PresenceByLocation_Check(
   const Entity: integer;
   const RegionLocation: TFCRufStelObj
   ): integer;

///<summary>
///   check if a specified resource spot type is present (surveyed) by giving entity/colony and settlement #
///</summary>
///   <param name="IPIRCentity">entity index #</param>
///   <param name="IPIRCcolony">colony index#</param>
///   <param name="IPIRCsettlement">settlement index #</param>
///   <param name="IPIRCownedInfra">owned infrastructure index #, if >0 => and spot found, indexes are stored in the owned data structure. THE OWNED INFRASTRUCTURE MUST BE A PRODUCTION ONE.</param>
///   <param name="ResourceSpot">resource spot type</param>
///   <param name="IPIRCcalculateLocation">true= calculate the colony's location (retrieve the indexes)</param>
///   <returns>the resource spot index #, 0 if not found, more than 0 if found</returns>
///   <remarks>if ResourceSpot is rstNone, return the result on any spot found. OwnedInfra is not used in this particular case</remarks>
function FCFgPRS_PresenceBySettlement_Check(
   const IPIRCentity
         ,IPIRCcolony
         ,IPIRCsettlement
         ,IPIRCownedInfra: integer;
   const ResourceSpot: TFCEduResourceSpotTypes;
   const IPIRCcalculateLocation: boolean
   ): integer;
   {:DEV NOTES: ADD curr/max level TEST.}

///<summary>
///   add a resource spot in a surveyed resources spots array of an entity
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="SurveyedResourceSpot">surveyed resource spot index #</param>
///   <param name="Region">region index #</param>
///   <param name="ResourceSpotType">type of resource spot to add</param>
///   <returns>index the the resource spot inside the surveyed resource spot array</returns>
///   <remarks>the resource spot presence should be tested before, if it's necessary. This function doesn't do this automatically</remarks>
function FCFgPRS_ResourceSpots_Add(
   const Entity
         ,SurveyedResourceSpots
         ,Region: integer;
   const ResourceSpotType: TFCEduResourceSpotTypes;
   const Location: TFCRufStelObj
   ): integer;

///<summary>
///   add a surveyed resource spot
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Location">surveyed resources spots location</param>
///   <returns>resources spots index which is created</returns>
///   <remarks>the resource spot presence should be tested before, if it's necessary. This function doesn't do this automatically</remarks>
function FCFgPRS_SurveyedResourceSpots_Add(
   const Entity: integer;
   const Location: TFCRufStelObj
   ): integer;

///<summary>
///   search if a specified type of resource spot is present in the entity's surveyed resources spot
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="SurveyedResourceSpot">surveyed resource spot index #</param>
///   <param name="Region">region index #</param>
///   <param name="TypeOfResourceSpot">type of resource spot to search</param>
///   <returns>resource spot index #, 0 if not found</returns>
///   <remarks></remarks>
function FCFgPRS_ResourceSpot_Search(
   const Entity
         ,SurveyedResourceSpot
         ,Region: integer;
   const TypeOfResourceSpot: TFCEduResourceSpotTypes
   ): integer;

///<summary>
///   search if a specified type of resource spot is present in the entity's surveyed resources spot, if it's not the case it generate it
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="SurveyedResourceSpot">surveyed resource spot index #</param>
///   <param name="Region">region index #</param>
///   <param name="TypeOfResourceSpot">type of resource spot to search</param>
///   <param name="Location">universe location of the resource spot</param>
///   <returns>resource spot index #</returns>
///   <remarks></remarks>
function FCFgPRS_ResourceSpots_SearchGenerate(
   const Entity
         ,SurveyedResourceSpot
         ,Region: integer;
   const TypeOfResourceSpot: TFCEduResourceSpotTypes;
   const Location: TFCRufStelObj
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   assign an owned infrastructure to it's resource spot
///</summary>
///   <param name="SRSAIentity">entity index #</param>
///   <param name="SRSAIcolony">colony index#</param>
///   <param name="SRSAIsettlement">settlement index #</param>
///   <param name="SRSAIownedInfra">owned infrastructure index #. THE OWNED INFRASTRUCTURE MUST BE A PRODUCTION ONE.</param>
///   <param name="SRSAIinfraData">DB infrastructure data</param>
procedure FCMgPRS_SurveyedRsrcSpot_AssignInfra(
   const SRSAIentity
         ,SRSAIcolony
         ,SRSAIsettlement
         ,SRSAIownedInfra: integer;
         SRSAIinfraData: TFCRdipInfrastructure
   );

implementation

uses
   farc_data_game
   ,farc_win_debug;

var
   GPRSloc: TFCRufStelObj;

//===================================================END OF INIT============================

function FCFgPRS_PresenceByLocation_Check(
   const Entity: integer;
   const RegionLocation: TFCRufStelObj
   ): integer;
{:Purpose: check if a surveyed resource spot is present for a specified region location within a specified entity.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_surveyedResourceSpots ) - 1;
   while Count<=Max do
   begin
      if (
            ( RegionLocation[4]=0 ) and ( FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken=FCDduStarSystem[ RegionLocation[1] ].SS_stars[ RegionLocation[2] ].S_orbitalObjects[ RegionLocation[3] ].OO_dbTokenId )
         )
         or (
               ( RegionLocation[4]>0 )
                  and ( FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken=FCDduStarSystem[ RegionLocation[1] ].SS_stars[ RegionLocation[2] ].S_orbitalObjects[ RegionLocation[3] ].OO_satellitesList[ RegionLocation[4] ].OO_dbTokenId )
            ) then
      begin
         Result:=Count;
         break;
      end;
      inc( Count );
   end;
end;

function FCFgPRS_PresenceBySettlement_Check(
   const IPIRCentity
         ,IPIRCcolony
         ,IPIRCsettlement
         ,IPIRCownedInfra: integer;
   const ResourceSpot: TFCEduResourceSpotTypes;
   const IPIRCcalculateLocation: boolean
   ): integer;
{:Purpose: check if a given resource spot type is present (surveyed) by giving entity/colony and settlement #.
    Additions:
      -2013Mar16- *add: if ResourceSpot is rstNone, return the result on any spot found.
      -2011Nov30- *add: new parameter to indicate an owned infrastructure, if >0 => and spot is found, the data are stored in the owned infrastructure data structure.
      -2011Nov22- *fix: prevent a crash when the target is a satellite.
}
   var
      IPIRCregion
      ,IPIRCspotCount
      ,IPIRCspotMax
      ,IPIRCspotSubCount
      ,IPIRCspotSubMax: integer;

      IPIRCtargetOobj: string[20];
begin
   Result:=0;
   if ( IPIRCcalculateLocation )
      or ( GPRSloc[1]=0 )
   then GPRSloc:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationStarSystem
      ,FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationStar
      ,FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationOrbitalObject
      ,FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationSatellite
      );
   if FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationSatellite=''
   then IPIRCtargetOobj:=FCDduStarSystem[ GPRSloc[1] ].SS_stars[ GPRSloc[2] ].S_orbitalObjects[ GPRSloc[3] ].OO_dbTokenId
   else if FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_locationSatellite<>''
   then IPIRCtargetOobj:=FCDduStarSystem[ GPRSloc[1] ].SS_stars[ GPRSloc[2] ].S_orbitalObjects[ GPRSloc[3] ].OO_satellitesList[ GPRSloc[4] ].OO_dbTokenId;
   IPIRCregion:=FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_settlements[IPIRCsettlement].S_locationRegion;
   IPIRCspotMax:=length(FCDdgEntities[IPIRCentity].E_surveyedResourceSpots)-1;
   if IPIRCspotMax>0 then
   begin
      IPIRCspotCount:=1;
      while IPIRCspotCount<=IPIRCspotMax do
      begin
         if ( ResourceSpot=rstNone )
                  and ( FCDdgEntities[IPIRCentity].E_surveyedResourceSpots[IPIRCspotCount].SRS_orbitalObject_SatelliteToken=IPIRCtargetOobj ) then
         begin
            Result:=IPIRCspotCount;
            break;
         end
         else if FCDdgEntities[IPIRCentity].E_surveyedResourceSpots[IPIRCspotCount].SRS_orbitalObject_SatelliteToken=IPIRCtargetOobj then
         begin
            IPIRCspotSubMax:=length( FCDdgEntities[IPIRCentity].E_surveyedResourceSpots[IPIRCspotCount].SRS_surveyedRegions[IPIRCregion].SR_ResourceSpots )-1;
            IPIRCspotSubCount:=1;
            while IPIRCspotSubCount<=IPIRCspotSubMax do
            begin
               if FCDdgEntities[IPIRCentity].E_surveyedResourceSpots[IPIRCspotCount].SRS_surveyedRegions[IPIRCregion].SR_ResourceSpots[IPIRCspotSubCount].RS_type=ResourceSpot then
               begin
                  Result:=IPIRCspotCount;
                  if IPIRCownedInfra>0 then
                  begin
                     FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_settlements[IPIRCsettlement].S_infrastructures[IPIRCownedInfra].I_fProdSurveyedSpot:=IPIRCspotCount;
                     FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_settlements[IPIRCsettlement].S_infrastructures[IPIRCownedInfra].I_fProdSurveyedRegion:=IPIRCregion;
                     FCDdgEntities[IPIRCentity].E_colonies[IPIRCcolony].C_settlements[IPIRCsettlement].S_infrastructures[IPIRCownedInfra].I_fProdResourceSpot:=IPIRCspotSubCount;
                  end;
               end;
               inc( IPIRCspotSubCount );
            end;
         end;
         inc(IPIRCspotCount);
      end;
   end;
end;

function FCFgPRS_ResourceSpots_Add(
   const Entity
         ,SurveyedResourceSpots
         ,Region: integer;
   const ResourceSpotType: TFCEduResourceSpotTypes;
   const Location: TFCRufStelObj
   ): integer;
{:Purpose: add a resource spot in a surveyed resources spots array of an entity.
    Additions:
      -2013Mar18- *add: (begin) initialize special data when the spot is an Ore Field.
}
   var
      Count
      ,Max: integer;

      OObjDensity
      ,OObjDiameter
      ,PotentialCarbo
      ,PotentialMetal
      ,PotentialRare
      ,PotentialUra: extended;

      OObjRegionType: TFCEduRegionSoilTypes;
begin
   Result:=0;
   Count:=0;
   Max:=length( FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots );
   setlength( FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots, Max+1 );
   Count:=Max;
   FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_meanQualityCoefficient:=0;
   FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_spotSizeCurrent:=0;
   FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_spotSizeMax:=0;
   FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_type:=ResourceSpotType;
   OObjDensity:=0;
   OObjDiameter:=0;
   PotentialCarbo:=0;
   PotentialMetal:=0;
   PotentialRare:=0;
   PotentialUra:=0;
   OObjRegionType:=rst01RockyDesert;
   if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_type=rstOreField then
   begin
      PotentialCarbo:=0;
      PotentialMetal:=0;
      PotentialRare:=0;
      PotentialUra:=0;
      if Location[4]=0 then
      begin
         OObjDiameter:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_diameter;
         OObjDensity:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_dens;
         OObjRegionType:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_regions[Region].OOR_soilType;
      end
      else if Location[4]>0 then
      begin
         OObjDiameter:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_diameter;
         OObjDensity:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_dens;
         OObjRegionType:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_regions[Region].OOR_soilType;
      end;
      PotentialMetal:=( OObjDiameter / 500 ) + ( OObjDensity * 10 ) + ( 70 ) - 45 + sqr( 1 );//+sqr(AcTec); - hardcoded Actec for now, note in todolist for Alpha 6
      PotentialCarbo:=( OObjDiameter / 500 ) + ( OObjDensity * 10 ) + ( 35 ) - 45 + sqr( 1 );//+sqr(AcTec); - hardcoded Actec for now, note in todolist for Alpha 6
      PotentialRare:=( OObjDiameter / 500 ) + ( OObjDensity * 10 )+( 17.5 ) - 45 + sqr( 1 );//+sqr(AcTec); - hardcoded Actec for now, note in todolist for Alpha 6
      PotentialUra:=( OObjDiameter / 500 ) + ( OObjDensity * 10 )+( 40 ) - 45 + sqr( 1 );//+sqr(AcTec); - hardcoded Actec for now, note in todolist for Alpha 6
      if ( FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_class = PSR )
         or ( FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_class = PSR )
      then PotentialUra:=PotentialUra * ( 1 +( random * 0.5 ) );
      case OObjRegionType of
         rst01RockyDesert:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*1.25,3));
         end;

         rst02SandyDesert:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=0;
         end;

         rst03Volcanic:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst04Polar:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=0;
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=0;
         end;

         rst05Arid:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*1.25,3));
         end;

         rst06Fertile:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst07Oceanic:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst08CoastalRockyDesert:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst09CoastalSandyDesert:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*0.75,3));
         end;

         rst10CoastalVolcanic:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*0.75,3));
         end;

         rst11CoastalPolar:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=0;
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*0.75,3));
         end;

         rst12CoastalArid:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst13CoastalFertile:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3));
         end;

         rst14Sterile:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*1.25,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            if ((StarClone_Class='BH') or (StarClone_Class='PSR'))
                   or (StarClone_Age<=475) then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*1.25,3))
            else if (StarClone_Class<>'BH')
                   and (StarClone_Class<>'PSR')
                   and (StarClone_Age>475) then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio*0.75,3));
         end;

         rst15icySterile:
         begin
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=round(randg(pot_calc_minerais*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=round(randg(pot_calc_metnonFer*0.75,3));
            FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=round(randg(pot_calc_metPrec*0.75,3));
            if (StarClone_Class='BH')
                   or (StarClone_Class='PSR')
                   or (StarClone_Age<=475) then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=round(randg(pot_calc_minRadio,3))
            else if (StarClone_Class<>'BH')
                   and (StarClone_Class<>'PSR')
                   and (StarClone_Age>475) then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=0;
         end;
      end; //==END== case OObjRegionType ==//
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic<0
      then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiMetallic:=0;
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous<0
      then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiCarbonaceous:=0;
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare<0
      then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiRare:=0;
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium<0
      then FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_tOFiUranium:=0;
   end; //==END== if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpots].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_type=rstOreField ==//
   Result:=Count;
end;

function FCFgPRS_SurveyedResourceSpots_Add(
   const Entity: integer;
   const Location: TFCRufStelObj
   ): integer;
{:Purpose: add a surveyed resource spot.
    Additions:
      -2013Mar17- *add: initialize the SR_ResourceSpots.
}
   var
      Count
      ,CountRegion
      ,Max
      ,MaxRegions: integer;
begin
   Result:=0;
   Max:=length( FCDdgEntities[Entity].E_surveyedResourceSpots ) - 1;
   MaxRegions:=0;
   Count:=Max + 1;
   setlength( FCDdgEntities[Entity].E_surveyedResourceSpots, Count + 1 );
   if Location[4]=0 then
   begin
      FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_dbTokenId;
      MaxRegions:=length( FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_regions );
   end
   else if Location[4]>0 then
   begin
      FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_orbitalObject_SatelliteToken:=FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_dbTokenId;
      MaxRegions:=length( FCDduStarSystem[Location[1]].SS_stars[Location[2]].S_orbitalObjects[Location[3]].OO_satellitesList[Location[4]].OO_regions );
   end;
   FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_starSystem:=Location[1];
   FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_star:=Location[2];
   FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_orbitalObject:=Location[3];
   FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_satellite:=Location[4];
   setlength( FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_surveyedRegions, MaxRegions );
   CountRegion:=1;
   while CountRegion <= MaxRegions-1 do
   begin
      setlength( FCDdgEntities[Entity].E_surveyedResourceSpots[Count].SRS_surveyedRegions[CountRegion].SR_ResourceSpots, 1 );
      inc( CountRegion );
   end;
   Result:=Count;
end;

function FCFgPRS_ResourceSpot_Search(
   const Entity
         ,SurveyedResourceSpot
         ,Region: integer;
   const TypeOfResourceSpot: TFCEduResourceSpotTypes
   ): integer;
{:Purpose: search if a specified type of resource spot is present in the entity's surveyed resources spot.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Count:=1;
   Max:=length( FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpot].SRS_surveyedRegions[Region].SR_ResourceSpots ) - 1;
   while Count <= Max do
   begin
      if FCDdgEntities[Entity].E_surveyedResourceSpots[SurveyedResourceSpot].SRS_surveyedRegions[Region].SR_ResourceSpots[Count].RS_type=TypeOfResourceSpot then
      begin

      end;
      inc( Count );
   end;
end;

function FCFgPRS_ResourceSpots_SearchGenerate(
   const Entity
         ,SurveyedResourceSpot
         ,Region: integer;
   const TypeOfResourceSpot: TFCEduResourceSpotTypes;
   const Location: TFCRufStelObj
   ): integer;
{:Purpose: search if a specified type of resource spot is present in the entity's surveyed resources spot, if it's not the case it generate it.
    Additions:
}
begin
   Result:=0;
   Result:=FCFgPRS_ResourceSpot_Search(
      Entity
      ,SurveyedResourceSpot
      ,Region
      ,TypeOfResourceSpot
      );
   if Result=0
   then Result:=FCFgPRS_ResourceSpots_Add(
      Entity
      ,SurveyedResourceSpot
      ,Region
      ,TypeOfResourceSpot
      ,Location
      );
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPRS_SurveyedRsrcSpot_AssignInfra(
   const SRSAIentity
         ,SRSAIcolony
         ,SRSAIsettlement
         ,SRSAIownedInfra: integer;
         SRSAIinfraData: TFCRdipInfrastructure
   );
{:Purpose: assign an owned infrastructure to it's resource spot.
    Additions:
}
   var
      SRSAIresourceSpot
      ,SRSAIsurveyedRegion
      ,SRSAIsurveyedSpot: integer;

begin
   FCFgPRS_PresenceBySettlement_Check(
      SRSAIentity
      ,SRSAIcolony
      ,SRSAIsettlement
      ,SRSAIownedInfra
      ,SRSAIinfraData.I_reqResourceSpot
      ,true
      );
   SRSAIsurveyedSpot:=FCDdgEntities[ SRSAIentity ].E_colonies[ SRSAIcolony ].C_settlements[ SRSAIsettlement ].S_infrastructures[ SRSAIownedInfra ].I_fProdSurveyedSpot;
   SRSAIsurveyedRegion:=FCDdgEntities[ SRSAIentity ].E_colonies[ SRSAIcolony ].C_settlements[ SRSAIsettlement ].S_infrastructures[ SRSAIownedInfra ].I_fProdSurveyedRegion;
   SRSAIresourceSpot:=FCDdgEntities[ SRSAIentity ].E_colonies[ SRSAIcolony ].C_settlements[ SRSAIsettlement ].S_infrastructures[ SRSAIownedInfra ].I_fProdResourceSpot;
   FCDdgEntities[ SRSAIentity ].E_surveyedResourceSpots[ SRSAIsurveyedSpot ].SRS_surveyedRegions[ SRSAIsurveyedRegion ].SR_ResourceSpots[ SRSAIresourceSpot ].RS_spotSizeCurrent:=
      FCDdgEntities[ SRSAIentity ].E_surveyedResourceSpots[ SRSAIsurveyedSpot ].SRS_surveyedRegions[ SRSAIsurveyedRegion ].SR_ResourceSpots[ SRSAIresourceSpot ].RS_spotSizeCurrent
      +FCDdgEntities[ SRSAIentity ].E_colonies[ SRSAIcolony ].C_settlements[ SRSAIsettlement ].S_infrastructures[ SRSAIownedInfra ].I_level;
end;

end.
