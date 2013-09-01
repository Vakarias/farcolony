{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: contains all interplanetary mission routines and functions

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

unit farc_missions_interplanetarytransit;

interface

uses
   SysUtils;

type TFCEgmtLocTp=
   (
      gmtltOrbObj
      ,gmtltSat
      ,gmtltSpUnit
   );

///<summary>
///   calculate the core data of the interplanetary transit mission.
///</summary>
procedure FCMgMiT_ITransit_Setup;

///<summary>
///   calculate the trip data of the interplanetary transit mission, following transit
///   flight selection.
///</summary>
procedure FCMgMiT_MissionTrip_Calc(const MTCflightTp: integer; MTCcurDV: extended);

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_missionstasks
   ,farc_data_spu
   ,farc_data_univ
   ,farc_missions_core
   ,farc_main
   ,farc_ogl_functions
   ,farc_spu_functions;

//===================================END OF INIT============================================

procedure FCMgMiT_ITransit_Setup;
{:Purpose: calculate the core data of the interplanetary transit mission.
    Additions:
      -2012Nov12- *code: begin of rewriting.
      -2010Sep16- *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2009Dec26- *complete sattelite calculations.
      -2009Dec25- *add: satellite calculations.
      -2009Oct24- *completion.
}
//var
//   MCCdAccelM
//   ,MCCmaxBurnEndSec
//   ,MCCdepOrbVel
//   ,MCCarrOrbVel
//   ,MCCvh: extended;
//
//   MCCdsgn
//   ,MCCisp: integer;
//

   var
      Design
      ,Destination
      ,Entity //MCCfac
      ,Origin
      ,SpaceUnit: integer; //MCCowned

      AccelerationInMbySec
      ,BurnEnduranceMaxInSec
      ,DistanceAccelMeters
      ,EscapeVelocity
      ,OrbitalVelocityArrival
      ,OrbitalVelocityDeparture: extended;
begin
   Destination:=0;
   Origin:=0;
   AccelerationInMbySec:=0;
   BurnEnduranceMaxInSec:=0;
   DistanceAccelMeters:=0;
   EscapeVelocity:=0;
   OrbitalVelocityArrival:=0;
   OrbitalVelocityDeparture:=0;
   Entity:=FCRmcCurrentMissionCalculations.CMC_entity;
   SpaceUnit:=FCDmcCurrentMission[Entity].T_controllerIndex;
   Design:=FCFspuF_Design_getDB(FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_designToken);
   if Entity=0 then
   begin
      if FCDmcCurrentMission[Entity].T_tMITorigin=ttOrbitalObject then
      begin
         Origin:=FCDmcCurrentMission[Entity].T_tMIToriginIndex;
         EscapeVelocity:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[Origin].OO_escapeVelocity;
         OrbitalVelocityDeparture:=(
            FCCdiPiDouble*FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[Origin].OO_isNotSat_distanceFromStar*FCCdiKm_In_1AU
               /FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[Origin].OO_revolutionPeriod
            )/86400;
      end
      else if FCDmcCurrentMission[Entity].T_tMITorigin=ttSatellite then
      begin
         Origin:=FCFoglF_Satellite_SearchObject( FCDmcCurrentMission[Entity].T_tMIToriginIndex, FCDmcCurrentMission[Entity].T_tMIToriginSatIndex );
         EscapeVelocity:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCDmcCurrentMission[Entity].T_tMIToriginIndex]
                  .OO_satellitesList[FCDmcCurrentMission[Entity].T_tMIToriginSatIndex].OO_escapeVelocity;
         OrbitalVelocityDeparture:=(
            FCCdiPiDouble
               *FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCDmcCurrentMission[Entity].T_tMIToriginIndex]
                  .OO_satellitesList[FCDmcCurrentMission[Entity].T_tMIToriginSatIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000
               /FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCDmcCurrentMission[Entity].T_tMIToriginIndex]
                  .OO_satellitesList[FCDmcCurrentMission[Entity].T_tMIToriginSatIndex].OO_revolutionPeriod
            )/86400;
      end;

      if FCDmcCurrentMission[Entity].T_tMITdestination=ttOrbitalObject then
      begin
         Destination:=FCDmcCurrentMission[Entity].T_tMITdestinationIndex;
         OrbitalVelocityArrival:=(
            FCCdiPiDouble*FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[Destination].OO_isNotSat_distanceFromStar*FCCdiKm_In_1AU
               /FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[Destination].OO_revolutionPeriod
            )/86400;
      end
      else if FCDmcCurrentMission[Entity].T_tMITdestination=ttSatellite then
      begin
         Destination:=FCFoglF_Satellite_SearchObject( FCDmcCurrentMission[Entity].T_tMITdestinationIndex, FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex );
         OrbitalVelocityArrival:=(
            FCCdiPiDouble*FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCDmcCurrentMission[Entity].T_tMITdestinationIndex]
               .OO_satellitesList[FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000
            /FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCDmcCurrentMission[Entity].T_tMITdestinationIndex]
               .OO_satellitesList[FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex].OO_revolutionPeriod
            )/86400;
      end;
      FCRmcCurrentMissionCalculations.CMC_baseDistance:=FCFoglF_DistanceBetweenTwoObjects_CalculateInAU(
         FCDmcCurrentMission[Entity].T_tMITorigin
         ,Origin
         ,FCDmcCurrentMission[Entity].T_tMITdestination
         ,Destination
         );
      {.distance conversion in m}
      DistanceAccelMeters:=FCRmcCurrentMissionCalculations.CMC_baseDistance*FCCdiKm_In_1AU*500;  //MCCdAccelM
      {.calculate final acceleration in gees relative to loaded mass}
      FCRmcCurrentMissionCalculations.CMC_accelerationInG:=(MRMCDVCthrbyvol*MRMCDVCvolOfDrive)/MRMCDVCloadedMassInTons;
      AccelerationInMbySec:=FCRmcCurrentMissionCalculations.CMC_accelerationInG*FCCdiMetersBySec_In_1G;
      {.calculate minimum minimum required deltaV}
      FCRmcCurrentMissionCalculations.CMC_requiredDeltaV:=sqrt( sqr( OrbitalVelocityArrival-OrbitalVelocityDeparture )+sqr( EscapeVelocity ) );
      {.calculate max burn endurance}
      BurnEnduranceMaxInSec:=sqrt( ( DistanceAccelMeters )/( AccelerationInMbySec ) );
      {.calculate maximum allowed deltaV}
      FCRmcCurrentMissionCalculations.CMC_maxDeltaV:=( AccelerationInMbySec*0.001 )*( BurnEnduranceMaxInSec );
      {.calculate maximum reaction mass volume which can be used}
      FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol:=BurnEnduranceMaxInSec*( GMCCthrN/( FCDdsuSpaceUnitDesigns[Design].SUD_spaceDriveISP*FCCdiMetersBySec_In_1G ) )/( MRMCDVCrmMass*1000 );
      if FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol>(FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_reactionMass*0.5)
      then
      begin
         FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol:=( FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_reactionMass*0.5 );
         BurnEnduranceMaxInSec:=FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol/(GMCCthrN/( FCDdsuSpaceUnitDesigns[Design].SUD_spaceDriveISP*FCCdiMetersBySec_In_1G ) )*( MRMCDVCrmMass*1000 );
         FCRmcCurrentMissionCalculations.CMC_maxDeltaV:=( AccelerationInMbySec*0.001 )*( BurnEnduranceMaxInSec );
      end;
      {.required deltaV}
      FCRmcCurrentMissionCalculations.CMC_requiredDeltaV:=FCFcF_Round( rttDistanceKm, FCRmcCurrentMissionCalculations.CMC_requiredDeltaV );
      {.max reaction mass volume}
      FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol:=FCFcF_Round( rttVolume, FCRmcCurrentMissionCalculations.CMC_reactionMassMaxVol );
      {.calculate final deltaV}
      FCRmcCurrentMissionCalculations.CMC_finalDeltaV:=FCFspuF_DeltaV_GetFromOrbit(
         FCRmcCurrentMissionCalculations.CMC_originLocation[1]
         ,FCRmcCurrentMissionCalculations.CMC_originLocation[2]
         ,FCDmcCurrentMission[Entity].T_tMITdestinationIndex
         ,FCDmcCurrentMission[Entity].T_tMITdestinationSatIndex
         );
   end //==END== if Entity=0 then ==//
   else if Entity>0 then
   begin
      {:DEV NOTES: implement only during the development of the 0.7.5 w/ FADE/AI.}
   end;
end;

procedure FCMgMiT_MissionTrip_Calc(const MTCflightTp: integer; MTCcurDV: extended);
{:Purpose: calculate the trip data of the interplanetary transit mission, following transit
flight selection.
    Additions:
      -2010Sep16- *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2009Oct25- *complete MTCflightTp case 2 and 3.
                  *add FCWinMissSet.FCWMS_ButProceed behavior;
}
//var
//   MTCdesgn
//   ,MTCfac
//   ,MTCowned: integer;
//
//   MTCburnEndAtAccel,
//   MTCusedRMvolAtAccel,
//   MTCdistAtAccel,
//   MTCtimeAtAccel,
//   MTCburnEndAtDecel,
//   MTCusedRMvolAtDecel,
//   MTCdistAtDecel,
//   MTCtimeAtDecel,
//   MTCdistAtCruise,
//   MTCtimeAtCruise
//   : extended;
const
   MTCgeesInKmS=FCCdiMetersBySec_In_1G*0.001;
   var
      Design
      ,Entity
      ,SpaceUnit: integer;

      BurnEnduranceAtAcceleration
      ,BurnEnduranceAtDeceleration
      ,DistanceAtAcceleration
      ,DistanceAtCruise
      ,DistanceAtDeceleration
      ,ReactionMassVolUsedAcceleration
      ,ReactionMassVolUsedDeceleration
      ,TimeAtAcceleration
      ,TimeAtCruise
      ,TimeAtDeceleration: extended;
begin
   Design:=0;
   Entity:=0;
   SpaceUnit:=0;
   BurnEnduranceAtAcceleration:=0;
   BurnEnduranceAtDeceleration:=0;
   DistanceAtAcceleration:=0;
   DistanceAtCruise:=0;
   DistanceAtDeceleration:=0;
   ReactionMassVolUsedAcceleration:=0;
   ReactionMassVolUsedDeceleration:=0;
   TimeAtAcceleration:=0;
   TimeAtCruise:=0;
   TimeAtDeceleration:=0;
   {.decide of the cruise deltav}
   case MTCflightTp of
      1:
      begin
         FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_requiredDeltaV;
         if FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV>FCRmcCurrentMissionCalculations.CMC_maxDeltaV
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV<FCRmcCurrentMissionCalculations.CMC_finalDeltaV
         then FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
      end;
      2:
      begin
         FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_maxDeltaV-((FCRmcCurrentMissionCalculations.CMC_maxDeltaV-FCRmcCurrentMissionCalculations.CMC_requiredDeltaV)*0.5);
         if FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV>FCRmcCurrentMissionCalculations.CMC_maxDeltaV
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV<FCRmcCurrentMissionCalculations.CMC_finalDeltaV
         then FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
      end;
      3:
      begin
         FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_maxDeltaV;
         if FCRmcCurrentMissionCalculations.CMC_requiredDeltaV>FCRmcCurrentMissionCalculations.CMC_maxDeltaV
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV<FCRmcCurrentMissionCalculations.CMC_finalDeltaV
         then FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCRmcCurrentMissionCalculations.CMC_finalDeltaV;
      end;
   end;
   if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled
   then
   begin
      Entity:=FCRmcCurrentMissionCalculations.CMC_entity;
      SpaceUnit:=FCDmcCurrentMission[Entity].T_controllerIndex;
      Design:=FCFspuF_Design_getDB(FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_designToken);
      {.calculate the burn endurance for acceleration}
      BurnEnduranceAtAcceleration:=(FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV-MTCcurDV)/(FCRmcCurrentMissionCalculations.CMC_accelerationInG*MTCgeesInKmS);
      {.caculate used reaction mass volume for acceleration}
      ReactionMassVolUsedAcceleration:=
         (BurnEnduranceAtAcceleration)
         *(GMCCthrN/(FCDdsuSpaceUnitDesigns[Design].SUD_spaceDriveISP*FCCdiMetersBySec_In_1G))
         /(MRMCDVCrmMass*1000);
      {.calculate acceleration distance}
      DistanceAtAcceleration:=(FCRmcCurrentMissionCalculations.CMC_accelerationInG*MTCgeesInKmS)*sqr(BurnEnduranceAtAcceleration);
      {.calculate acceleration time}
      TimeAtAcceleration:=BurnEnduranceAtAcceleration/600;
      {.calculate the burn endurance for deceleration}
      BurnEnduranceAtDeceleration:=(FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV-FCRmcCurrentMissionCalculations.CMC_finalDeltaV)/(FCRmcCurrentMissionCalculations.CMC_accelerationInG*MTCgeesInKmS);
      {.caculate used reaction mass volume for deceleration}
      ReactionMassVolUsedDeceleration:=
         (BurnEnduranceAtDeceleration)
         *(GMCCthrN/(FCDdsuSpaceUnitDesigns[Design].SUD_spaceDriveISP*FCCdiMetersBySec_In_1G))
         /(MRMCDVCrmMass*1000);
      {.calculate deceleration distance}
      DistanceAtDeceleration:=(FCRmcCurrentMissionCalculations.CMC_accelerationInG*MTCgeesInKmS)*sqr(BurnEnduranceAtDeceleration);
      {.calculate deceleration time}
      TimeAtDeceleration:=BurnEnduranceAtDeceleration/600;
      {.calculate cruise distance}
      DistanceAtCruise:=(FCRmcCurrentMissionCalculations.CMC_baseDistance*FCCdiKm_In_1AU)-DistanceAtAcceleration-DistanceAtDeceleration;
      {.calculate cruise time}
      TimeAtCruise:=DistanceAtCruise/FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV/600;
      {.calculate trip time}
      FCRmcCurrentMissionCalculations.CMC_tripTime:=round(TimeAtAcceleration+TimeAtDeceleration+TimeAtCruise);
      {.calculate reaction mass volume used}
      FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol:=ReactionMassVolUsedAcceleration+ReactionMassVolUsedDeceleration;
      if FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol>FCDdgEntities[Entity].E_spaceUnits[SpaceUnit].SU_reactionMass
      then
      begin
         case MTCflightTp of
            1:
            begin
               FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
               FCWinMain.FCWMS_ButProceed.Enabled:=false;
            end;
            2: FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=1;
            3: FCWinMain.FCWMS_Grp_MCG_RMassTrack.Position:=2;
         end;
      end;
//      GMCAccelG:=FCFcFunc_Rnd(cfrttp3dunit, GMCAccelG);
      FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV:=FCFcF_Round(rttVelocityKmSec, FCRmcCurrentMissionCalculations.CMC_cruiseDeltaV);
      FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol:=FCFcF_Round(rttVolume, FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol);
      FCRmcCurrentMissionCalculations.CMC_timeAccel:=round(TimeAtAcceleration);
      FCRmcCurrentMissionCalculations.CMC_timeDecel:=round(TimeAtDeceleration);
   end; {.if FCWinMissSet.FCWMS_Grp_MCG_RMassTrack.Enabled}
end;

end.
