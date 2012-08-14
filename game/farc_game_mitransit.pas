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

unit farc_game_mitransit;

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

///<summary>
///   calculate the distance, in AU, between a space unit and an orbital object in the same
///   local star aera.
///</summary>
///   <param name="OOILSCRooIdxOrg">origin orbital object index</param>
///   <param name="OOILSCRooIdxDest">destination orbital object index</param>
///   <param name="OOILSCRorgTp">origin type: orbital object, satellite or space unit</param>
///   <param name="OOILSCRdestTp">destination type: orbital object, satellite or space unit</param>
///   <param name="isConvToAU">tell if the distance must be in AU</param>
function FCFgMTrans_ObObjInLStar_CalcRng(
   const OOILSCRooIdxOrg
         ,OOILSCRooIdxDest: integer;
   const OOILSCRorgTp,
         OOILSCRdestTp: TFCEgmtLocTp;
   const isConvToAU: boolean
   ): extended;

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_spu
   ,farc_data_univ
   ,farc_game_missioncore
   ,farc_main
   ,farc_spu_functions;

//===================================END OF INIT============================================

procedure FCMgMiT_ITransit_Setup;
{:Purpose: calculate the core data of the interplanetary transit mission.
    Additions:
      -2010Sep16- *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2009Dec26- *complete sattelite calculations.
      -2009Dec25- *add: satellite calculations.
      -2009Oct24- *completion.
}
var
   MCCdAccelM
   ,MCCmaxBurnEndSec
   ,MCCdepOrbVel
   ,MCCarrOrbVel
   ,MCCvh: extended;

   MCCdsgn
   ,MCCfac
   ,MCCisp
   ,MCCowned
   ,MCCsatOrgIdx
   ,MCCsatOrgPlanIdx
   ,MCCsatDestIdx
   ,MCCsatDestPlanIdx: integer;

   MCCisOrgAsat
   ,MCCisDestASat: boolean;
begin
//====================DATA INITIALIZATION==================================
   {.determine the nature of origin and destination}
   MCCisOrgAsat:=false;
   MCCisDestASat:=false;
   MCCsatOrgIdx:=0;
   MCCfac:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag;
   MCCowned:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
   MCCdsgn:=FCFspuF_Design_getDB(FCentities[MCCfac].E_spU[MCCowned].SU_designToken);
   if GMCrootSatObjIdx>0
   then
   begin
      MCCisOrgAsat:=true;
      MCCsatOrgIdx:=FC3doglSatellitesObjectsGroups[GMCrootSatObjIdx].Tag;
      MCCsatOrgPlanIdx:=round(FC3doglSatellitesObjectsGroups[GMCrootSatObjIdx].TagFloat);
   end;
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite]
   then
   begin
      MCCisDestASat:=true;
      MCCsatDestIdx:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
      MCCsatDestPlanIdx:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
   end;
   {.calculate base distance in AU}
   if not MCCisDestASat
   then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(FC3doglSelectedSpaceUnit, FC3doglSelectedPlanetAsteroid, gmtltSpUnit, gmtltOrbObj, true)
   else if MCCisDestASat
   then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(FC3doglSelectedSpaceUnit, FC3doglSelectedSatellite, gmtltSpUnit, gmtltSat, true);
   {.distance conversion in m}
   MCCdAccelM:=GMCbaseDist*FCCdiKm_In_1AU*500;
   {.calculate final acceleration in gees relative to loaded mass}
   GMCAccelG:=(MRMCDVCthrbyvol*MRMCDVCvolOfDrive)/MRMCDVCloadedMassInTons;
   {.get the space unit's ISP}
   MCCisp:=FCDdsuSpaceUnitDesigns[MCCdsgn].SUD_spaceDriveISP;
   //================calculate minimal required deltaV=====================
   {.minreqDV.departure orbital velocity}
   if not MCCisOrgAsat
   then MCCdepOrbVel:=(
      2*pi*FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_isSatFdistanceFromStar*FCCdiKm_In_1AU
      /FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_revolutionPeriod
      )
      /86400
   else if MCCisOrgAsat
   then MCCdepOrbVel:=(
      2*pi*FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OO_isSatTdistFrmOOb*1000
      /FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OO_revolutionPeriod
      )
      /86400;
   {.minreqDV.arrival orbital velocity}
   if not MCCisDestASat
   then MCCarrOrbVel:=(
      2*pi*FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isSatFdistanceFromStar*FCCdiKm_In_1AU
      /FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_revolutionPeriod
      )
      /86400
   else if MCCisDestASat
   then MCCarrOrbVel:=(
      2*pi*FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MCCsatDestPlanIdx].OO_satellitesList[MCCsatDestIdx].OO_isSatTdistFrmOOb
      *1000
      /FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MCCsatDestPlanIdx].OO_satellitesList[MCCsatDestIdx].OO_revolutionPeriod
      )
      /86400;
   {.minreqDV.orbital velocities differences}
   MCCvh:=MCCarrOrbVel-MCCdepOrbVel;
   {.minreqDV.required deltav}
   if not MCCisOrgAsat
   then GMCreqDV:=sqrt(sqr(MCCvh)+sqr(FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[GMCrootOObIdx].OO_escapeVelocity))
   else if MCCisOrgAsat
   then GMCreqDV:=sqrt(
      sqr(MCCvh)+sqr(FCDduStarSystem[GMCrootSsys].SS_stars[GMCrootStar].S_orbitalObjects[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OO_escapeVelocity)
      );
   //================(end) calculate minimal required deltaV================
//====================(END) DATA INITIALIZATION=============================
   {.calculate max burn endurance}
   MCCmaxBurnEndSec:=sqrt((MCCdAccelM)/(GMCAccelG*FCCdiMbySec_In_1G));
   {.calculate maximum allowed deltaV}
   GMCmaxDV:=(GMCAccelG*FCCdiMbySec_In_1G*0.001)*(MCCmaxBurnEndSec);
   {.calculate maximum reaction mass volume which can be used}
   GMCrmMaxVol:=MCCmaxBurnEndSec*(GMCCthrN/(MCCisp*FCCdiMbySec_In_1G))/(MRMCDVCrmMass*1000);
   if GMCrmMaxVol>(FCentities[MCCfac].E_spU[MCCowned].SUO_availRMass*0.5)
   then
   begin
      GMCrmMaxVol:=(FCentities[MCCfac].E_spU[MCCowned].SUO_availRMass*0.5);
      MCCmaxBurnEndSec:=GMCrmMaxVol/(GMCCthrN/(MCCisp*FCCdiMbySec_In_1G))*(MRMCDVCrmMass*1000);
      GMCmaxDV:=(GMCAccelG*FCCdiMbySec_In_1G*0.001)*(MCCmaxBurnEndSec);
   end;
//====================GLOBAL DATA FORMATING=================================
   {.required deltaV}
   GMCreqDV:=FCFcFunc_Rnd(cfrttpDistkm, GMCreqDV);
   {.max reaction mass volume}
   GMCrmMaxVol:=FCFcFunc_Rnd(cfrttpVolm3, GMCrmMaxVol);
   {.calculate final deltaV}
   if not MCCisDestASat
   then GMCfinalDV:=FCFspuF_DeltaV_GetFromOrbit(
      GMCrootSsys
      ,GMCrootStar
      ,FC3doglSelectedPlanetAsteroid
      ,0
      )
   else if MCCisDestASat
   then GMCfinalDV:=FCFspuF_DeltaV_GetFromOrbit(
      GMCrootSsys
      ,GMCrootStar
      ,MCCsatDestPlanIdx
      ,MCCsatDestIdx
      );
//====================(END) GLOBAL DATA FORMATING===========================
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
var
   MTCdesgn
   ,MTCfac
   ,MTCowned: integer;

   MTCburnEndAtAccel,
   MTCusedRMvolAtAccel,
   MTCdistAtAccel,
   MTCtimeAtAccel,
   MTCburnEndAtDecel,
   MTCusedRMvolAtDecel,
   MTCdistAtDecel,
   MTCtimeAtDecel,
   MTCdistAtCruise,
   MTCtimeAtCruise
   : extended;
const
   MTCgeesInKmS=FCCdiMbySec_In_1G*0.001;
begin
   {.decide of the cruise deltav}
   case MTCflightTp of
      1:
      begin
         GMCcruiseDV:=GMCreqDV;
         if (FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx)
            and (GMCcruiseDV>GMCmaxDV)
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if GMCcruiseDV<GMCfinalDV
         then GMCcruiseDV:=GMCfinalDV;
      end;
      2:
      begin
         GMCcruiseDV:=GMCmaxDV-((GMCmaxDV-GMCreqDV)*0.5);
         if (FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx)
            and (GMCcruiseDV>GMCmaxDV)
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if GMCcruiseDV<GMCfinalDV
         then GMCcruiseDV:=GMCfinalDV;
      end;
      3:
      begin
         GMCcruiseDV:=GMCmaxDV;
         if (FC3doglSelectedPlanetAsteroid<>GMCrootOObIdx)
            and (GMCreqDV>GMCmaxDV)
         then
         begin
            FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled:=false;
            FCWinMain.FCWMS_ButProceed.Enabled:=false;
         end
         else if GMCcruiseDV<GMCfinalDV
         then GMCcruiseDV:=GMCfinalDV;
      end;
   end;
   if FCWinMain.FCWMS_Grp_MCG_RMassTrack.Enabled
   then
   begin
      MTCfac:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag;
      MTCowned:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
      MTCdesgn:=FCFspuF_Design_getDB(FCentities[MTCfac].E_spU[MTCowned].SU_designToken);
      {.calculate the burn endurance for acceleration}
      MTCburnEndAtAccel:=(GMCcruiseDV-MTCcurDV)/(GMCAccelG*MTCgeesInKmS);
      {.caculate used reaction mass volume for acceleration}
      MTCusedRMvolAtAccel:=
         (MTCburnEndAtAccel)
         *(GMCCthrN/(FCDdsuSpaceUnitDesigns[MTCdesgn].SUD_spaceDriveISP*FCCdiMbySec_In_1G))
         /(MRMCDVCrmMass*1000);
      {.calculate acceleration distance}
      MTCdistAtAccel:=(GMCAccelG*MTCgeesInKmS)*sqr(MTCburnEndAtAccel);
      {.calculate acceleration time}
      MTCtimeAtAccel:=MTCburnEndAtAccel/600;
      {.calculate the burn endurance for deceleration}
      MTCburnEndAtDecel:=(GMCcruiseDV-GMCfinalDV)/(GMCAccelG*MTCgeesInKmS);
      {.caculate used reaction mass volume for deceleration}
      MTCusedRMvolAtDecel:=
         (MTCburnEndAtDecel)
         *(GMCCthrN/(FCDdsuSpaceUnitDesigns[MTCdesgn].SUD_spaceDriveISP*FCCdiMbySec_In_1G))
         /(MRMCDVCrmMass*1000);
      {.calculate deceleration distance}
      MTCdistAtDecel:=(GMCAccelG*MTCgeesInKmS)*sqr(MTCburnEndAtDecel);
      {.calculate deceleration time}
      MTCtimeAtDecel:=MTCburnEndAtDecel/600;
      {.calculate cruise distance}
      MTCdistAtCruise:=(GMCbaseDist*FCCdiKm_In_1AU)-MTCdistAtAccel-MTCdistAtDecel;
      {.calculate cruise time}
      MTCtimeAtCruise:=MTCdistAtCruise/GMCcruiseDV/600;
      {.calculate trip time}
      GMCtripTime:=round(MTCtimeAtAccel+MTCtimeAtDecel+MTCtimeAtCruise);
      {.calculate reaction mass volume used}
      GMCusedRMvol:=MTCusedRMvolAtAccel+MTCusedRMvolAtDecel;
      if GMCusedRMvol>FCentities[MTCfac].E_spU[MTCowned].SUO_availRMass
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
//====================GLOBAL DATA FORMATING=================================
//      GMCAccelG:=FCFcFunc_Rnd(cfrttp3dunit, GMCAccelG);
      GMCcruiseDV:=FCFcFunc_Rnd(cfrttpVelkms, GMCcruiseDV);
      GMCusedRMvol:=FCFcFunc_Rnd(cfrttpVolm3, GMCusedRMvol);
      GMCtimeA:=round(MTCtimeAtAccel);
      GMCtimeD:=round(MTCtimeAtDecel);
   end; {.if FCWinMissSet.FCWMS_Grp_MCG_RMassTrack.Enabled}
//====================(END) GLOBAL DATA FORMATING===========================
end;

function FCFgMTrans_ObObjInLStar_CalcRng
   (
      const OOILSCRooIdxOrg
            ,OOILSCRooIdxDest: integer;
      const OOILSCRorgTp,
            OOILSCRdestTp: TFCEgmtLocTp;
      const isConvToAU: boolean
   ): extended;
{:Purpose: calculate the distance, in AU, between a space unit and an orbital object in the
   same local star aera.
      Additions:
         -2009Dec25- *mod: supress all boolean and put switches, origin/destination can be oob/sat
                     and space unit.
                     *mod: full method rewriting and completion.
         -2009Dec22- *add: 2 boolean switchs for indicate if Org and/or Dest is a satellite.
                     *add: calculation w/ satellites.
                     *mod: change calculation, if isFrmOOb= false then OOILSCRgravSphRLSVU is not
                     equal to 0 but equal to destination only OO_gravSphRad.
         -2009Oct26- *change origin type (orbital object) by the space unit.
                     *deduct destination gravitational sphere radius in the final distance.
}
var
   OOILSCRxOrg
   ,OOILSCRzOrg
   ,OOILSCRxDest
   ,OOILSCRzDest
   ,OOILSCRgravSphOrg
   ,OOILSCRgravSphDes: extended;

   OOILSCRsatPlanIdxOrg
   ,OOILSCRsatIdxOrg
   ,OOILSCRsatPlanIdxDest
   ,OOILSCRsatIdxDest: integer;
begin
   {.origin calculations}
   case OOILSCRorgTp of
      gmtltOrbObj:
      begin
         OOILSCRxOrg:=FC3doglObjectsGroups[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3doglObjectsGroups[OOILSCRooIdxOrg].Position.Z;
         OOILSCRgravSphOrg:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OOILSCRooIdxOrg].OO_gravitationalSphereRadius
            );
      end;
      gmtltSat:
      begin
         OOILSCRxOrg:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxOrg].Position.Z;
         OOILSCRsatIdxOrg:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxOrg].Tag;
         OOILSCRsatPlanIdxOrg:=round(FC3doglSatellitesObjectsGroups[OOILSCRooIdxOrg].TagFloat);
         OOILSCRgravSphOrg:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OOILSCRsatPlanIdxOrg].OO_satellitesList[OOILSCRsatIdxOrg].OO_gravitationalSphereRadius
            );
      end;
      gmtltSpUnit:
      begin
         OOILSCRxOrg:=FC3doglSpaceUnits[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3doglSpaceUnits[OOILSCRooIdxOrg].Position.Z;
         OOILSCRgravSphOrg:=0;
      end;
   end; //==END== case OOILSCRorgTp of ==//
   {.destination calculations}
   case OOILSCRdestTp of
      gmtltOrbObj:
      begin
         OOILSCRxDest:=FC3doglObjectsGroups[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3doglObjectsGroups[OOILSCRooIdxDest].Position.Z;
         OOILSCRgravSphDes
            :=FCFcFunc_ScaleConverter(
               cf3dctKmTo3dViewUnit
               ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OOILSCRooIdxDest].OO_gravitationalSphereRadius
               );
      end;
      gmtltSat:
      begin
         OOILSCRxDest:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxDest].Position.Z;
         OOILSCRsatIdxDest:=FC3doglSatellitesObjectsGroups[OOILSCRooIdxDest].Tag;
         OOILSCRsatPlanIdxDest:=round(FC3doglSatellitesObjectsGroups[OOILSCRooIdxDest].TagFloat);
         OOILSCRgravSphDes
            :=FCFcFunc_ScaleConverter(
               cf3dctKmTo3dViewUnit
               ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OOILSCRsatPlanIdxDest].OO_satellitesList[OOILSCRsatIdxDest].OO_gravitationalSphereRadius
               );
      end;
      gmtltSpUnit:
      begin
         OOILSCRxDest:=FC3doglSpaceUnits[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3doglSpaceUnits[OOILSCRooIdxDest].Position.Z;
         OOILSCRgravSphDes:=0;
      end;
   end; //==END== case OOILSCRdestTp of ==//
   {.distance calculation}
   if isConvToAU
   then Result
      :=FCFcFunc_ScaleConverter
         (
            cf3dct3dViewUnitToAU
            ,sqrt(sqr(OOILSCRxOrg-OOILSCRxDest)+sqr(OOILSCRzOrg-OOILSCRzDest))-(OOILSCRgravSphOrg+OOILSCRgravSphDes)
         )
   else if not isConvToAU
   then Result
      :=sqrt(sqr(OOILSCRxOrg-OOILSCRxDest)+sqr(OOILSCRzOrg-OOILSCRzDest))-(OOILSCRgravSphOrg+OOILSCRgravSphDes);
end;

end.
