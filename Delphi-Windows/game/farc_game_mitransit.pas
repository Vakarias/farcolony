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
   MCCfac:=FC3DobjSpUnit[FCV3DselSpU].Tag;
   MCCowned:=round(FC3DobjSpUnit[FCV3DselSpU].TagFloat);
   MCCdsgn:=FCFspuF_Design_getDB(FCentities[MCCfac].E_spU[MCCowned].SUO_designId);
   if GMCrootSatObjIdx>0
   then
   begin
      MCCisOrgAsat:=true;
      MCCsatOrgIdx:=FC3DobjSatGrp[GMCrootSatObjIdx].Tag;
      MCCsatOrgPlanIdx:=round(FC3DobjSatGrp[GMCrootSatObjIdx].TagFloat);
   end;
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat]
   then
   begin
      MCCisDestASat:=true;
      MCCsatDestIdx:=FC3DobjSatGrp[FCV3DselSat].Tag;
      MCCsatDestPlanIdx:=round(FC3DobjSatGrp[FCV3DselSat].TagFloat);
   end;
   {.calculate base distance in AU}
   if not MCCisDestASat
   then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(FCV3DselSpU, FCV3DselOobj, gmtltSpUnit, gmtltOrbObj, true)
   else if MCCisDestASat
   then GMCbaseDist:=FCFgMTrans_ObObjInLStar_CalcRng(FCV3DselSpU, FCV3DselSat, gmtltSpUnit, gmtltSat, true);
   {.distance conversion in m}
   MCCdAccelM:=GMCbaseDist*FCCdiKm_In_1AU*500;
   {.calculate final acceleration in gees relative to loaded mass}
   GMCAccelG:=(MRMCDVCthrbyvol*MRMCDVCvolOfDrive)/MRMCDVCloadedMassInTons;
   {.get the space unit's ISP}
   MCCisp:=FCDBscDesigns[MCCdsgn].SCD_spDriveISP;
   //================calculate minimal required deltaV=====================
   {.minreqDV.departure orbital velocity}
   if not MCCisOrgAsat
   then MCCdepOrbVel:=(
      2*pi*FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[GMCrootOObIdx].OO_distFrmStar*FCCdiKm_In_1AU
      /FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[GMCrootOObIdx].OO_revolutionPeriod
      )
      /86400
   else if MCCisOrgAsat
   then MCCdepOrbVel:=(
      2*pi*FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OOS_distFrmOOb*1000
      /FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OO_revolutionPeriod
      )
      /86400;
   {.minreqDV.arrival orbital velocity}
   if not MCCisDestASat
   then MCCarrOrbVel:=(
      2*pi*FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[FCV3DselOobj].OO_distFrmStar*FCCdiKm_In_1AU
      /FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[FCV3DselOobj].OO_revolutionPeriod
      )
      /86400
   else if MCCisDestASat
   then MCCarrOrbVel:=(
      2*pi*FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[MCCsatDestPlanIdx].OO_satellitesList[MCCsatDestIdx].OOS_distFrmOOb
      *1000
      /FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[MCCsatDestPlanIdx].OO_satellitesList[MCCsatDestIdx].OO_revolutionPeriod
      )
      /86400;
   {.minreqDV.orbital velocities differences}
   MCCvh:=MCCarrOrbVel-MCCdepOrbVel;
   {.minreqDV.required deltav}
   if not MCCisOrgAsat
   then GMCreqDV:=sqrt(sqr(MCCvh)+sqr(FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[GMCrootOObIdx].OO_escapeVelocity))
   else if MCCisOrgAsat
   then GMCreqDV:=sqrt(
      sqr(MCCvh)+sqr(FCDBsSys[GMCrootSsys].SS_star[GMCrootStar].SDB_obobj[MCCsatOrgPlanIdx].OO_satellitesList[MCCsatOrgIdx].OO_escapeVelocity)
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
      ,FCV3DselOobj
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
         if (FCV3DselOobj<>GMCrootOObIdx)
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
         if (FCV3DselOobj<>GMCrootOObIdx)
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
         if (FCV3DselOobj<>GMCrootOObIdx)
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
      MTCfac:=FC3DobjSpUnit[FCV3DselSpU].Tag;
      MTCowned:=round(FC3DobjSpUnit[FCV3DselSpU].TagFloat);
      MTCdesgn:=FCFspuF_Design_getDB(FCentities[MTCfac].E_spU[MTCowned].SUO_designId);
      {.calculate the burn endurance for acceleration}
      MTCburnEndAtAccel:=(GMCcruiseDV-MTCcurDV)/(GMCAccelG*MTCgeesInKmS);
      {.caculate used reaction mass volume for acceleration}
      MTCusedRMvolAtAccel:=
         (MTCburnEndAtAccel)
         *(GMCCthrN/(FCDBscDesigns[MTCdesgn].SCD_spDriveISP*FCCdiMbySec_In_1G))
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
         *(GMCCthrN/(FCDBscDesigns[MTCdesgn].SCD_spDriveISP*FCCdiMbySec_In_1G))
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
         OOILSCRxOrg:=FC3DobjGrp[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3DobjGrp[OOILSCRooIdxOrg].Position.Z;
         OOILSCRgravSphOrg:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OOILSCRooIdxOrg].OO_gravitationalSphereRadius
            );
      end;
      gmtltSat:
      begin
         OOILSCRxOrg:=FC3DobjSatGrp[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3DobjSatGrp[OOILSCRooIdxOrg].Position.Z;
         OOILSCRsatIdxOrg:=FC3DobjSatGrp[OOILSCRooIdxOrg].Tag;
         OOILSCRsatPlanIdxOrg:=round(FC3DobjSatGrp[OOILSCRooIdxOrg].TagFloat);
         OOILSCRgravSphOrg:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OOILSCRsatPlanIdxOrg].OO_satellitesList[OOILSCRsatIdxOrg].OO_gravitationalSphereRadius
            );
      end;
      gmtltSpUnit:
      begin
         OOILSCRxOrg:=FC3DobjSpUnit[OOILSCRooIdxOrg].Position.X;
         OOILSCRzOrg:=FC3DobjSpUnit[OOILSCRooIdxOrg].Position.Z;
         OOILSCRgravSphOrg:=0;
      end;
   end; //==END== case OOILSCRorgTp of ==//
   {.destination calculations}
   case OOILSCRdestTp of
      gmtltOrbObj:
      begin
         OOILSCRxDest:=FC3DobjGrp[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3DobjGrp[OOILSCRooIdxDest].Position.Z;
         OOILSCRgravSphDes
            :=FCFcFunc_ScaleConverter(
               cf3dctKmTo3dViewUnit
               ,FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OOILSCRooIdxDest].OO_gravitationalSphereRadius
               );
      end;
      gmtltSat:
      begin
         OOILSCRxDest:=FC3DobjSatGrp[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3DobjSatGrp[OOILSCRooIdxDest].Position.Z;
         OOILSCRsatIdxDest:=FC3DobjSatGrp[OOILSCRooIdxDest].Tag;
         OOILSCRsatPlanIdxDest:=round(FC3DobjSatGrp[OOILSCRooIdxDest].TagFloat);
         OOILSCRgravSphDes
            :=FCFcFunc_ScaleConverter(
               cf3dctKmTo3dViewUnit
               ,FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OOILSCRsatPlanIdxDest].OO_satellitesList[OOILSCRsatIdxDest].OO_gravitationalSphereRadius
               );
      end;
      gmtltSpUnit:
      begin
         OOILSCRxDest:=FC3DobjSpUnit[OOILSCRooIdxDest].Position.X;
         OOILSCRzDest:=FC3DobjSpUnit[OOILSCRooIdxDest].Position.Z;
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
