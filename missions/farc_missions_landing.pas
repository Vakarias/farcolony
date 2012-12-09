{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: contains all landing mission routines and functions

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

unit farc_missions_landing;

interface

///<summary>
///   calculate trip data from orbit to ground. Return planetary entry velocity
///</summary>
///   <param name="LCfac">faction index #</param>
///   <param name="LCownIdx">owned space unit index</param>
///   <param name="LCoobjIdx">orbital object index</param>
///   <param name="LCsatIdx">satellite index [optional]</param>
///   <param name="LCsatObjIdx">sat 3d object index [optional]</param>
///   <param name="LCsetPeVel">true= calculate the planetary entry velocity </param>
procedure FCFgMl_Land_Calc(
   const LCfac
         ,LCownIdx
//         ,LCssys
//         ,LCstar
//         ,LCoobjIdx
//         ,LCsatIdx
//         ,LCsatObjIdx
         : integer;

   const
//   LCdistDecel
//         ,
         LCentrVel: extended
//         ;

//   const LCsetPeVel: boolean
   );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_init
   ,farc_data_spu
   ,farc_data_univ
   ,farc_missions_core
   ,farc_spu_functions;

//===================================END OF INIT============================================

procedure FCFgMl_Land_Calc(
   const LCfac
         ,LCownIdx
//         ,LCssys
//         ,LCstar
//         ,LCoobjIdx
//         ,LCsatIdx
//         ,LCsatObjIdx
         : integer;

   const
//   LCdistDecel
//         ,
         LCentrVel: extended
//         ;

//   const LCsetPeVel: boolean
   );
{:Purpose: calculate trip data from orbit to ground.
    Additions:
      -2012Oct29- *add/mod: complete rewrite of the routine.
      -2010Sep16- *add: a parameter for faction #.
                  *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
}
   var
      DecelerationTime
      ,ISP
      ,SpaceUnitDesign: integer;

      AtmosphereCalc
      ,AtmosphericPressure
      ,BurnEndurance
      ,DepartureVelocity
      ,UsedReactionMass: extended;
begin
   DecelerationTime:=0;
   ISP:=0;
   SpaceUnitDesign:=0;
   AtmosphereCalc:=0;
   AtmosphericPressure:=0;
   BurnEndurance:=0;
   DepartureVelocity:=0;
   UsedReactionMass:=0;
   if FCRmcCurrentMissionCalculations.CMC_originLocation[4]=0 then
   begin
      AtmosphericPressure:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_atmosphericPressure;
   end
   else if FCRmcCurrentMissionCalculations.CMC_originLocation[4]>0 then
   begin
      AtmosphericPressure:=FCDduStarSystem[FCRmcCurrentMissionCalculations.CMC_originLocation[1]].SS_stars[FCRmcCurrentMissionCalculations.CMC_originLocation[2]].S_orbitalObjects[FCRmcCurrentMissionCalculations.CMC_originLocation[3]].OO_satellitesList[FCRmcCurrentMissionCalculations.CMC_originLocation[4]].OO_atmosphericPressure;
   end;
   SpaceUnitDesign:=FCFspuF_Design_getDB(FCDdgEntities[LCfac].E_spaceUnits[LCownIdx].SU_designToken);
   {.calculate final acceleration in gees relative to loaded mass}
   FCRmcCurrentMissionCalculations.CMC_accelerationInG:=(MRMCDVCthrbyvol*MRMCDVCvolOfDrive)/MRMCDVCloadedMassInTons;
   {.get the space unit's ISP}
   ISP:=FCDdsuSpaceUnitDesigns[SpaceUnitDesign].SUD_spaceDriveISP;
   {.velocities calculations}
   DepartureVelocity:=FCDdgEntities[LCfac].E_spaceUnits[LCownIdx].SU_deltaV;
   {.calculate the burn endurance for deceleration}
   BurnEndurance:=(DepartureVelocity-LCentrVel)/(FCRmcCurrentMissionCalculations.CMC_accelerationInG*FCCdiKmBySec_In_1G);
   {.caculate used reaction mass volume for deceleration}
   UsedReactionMass:=( BurnEndurance*(GMCCthrN/(ISP*FCCdiMetersbySec_In_1G)) )/(MRMCDVCrmMass*1000);
   {.calculate deceleration time}
   DecelerationTime:=round( BurnEndurance/600 );
   {.determine atmosphere entry time}
   AtmosphereCalc:=AtmosphericPressure/FCCdiMbars_In_1atmosphere;
   FCRmcCurrentMissionCalculations.CMC_landTime:=round(((1.84-(1-AtmosphereCalc))*70)/18.4);
   FCRmcCurrentMissionCalculations.CMC_tripTime:=DecelerationTime+FCRmcCurrentMissionCalculations.CMC_landTime;
   FCRmcCurrentMissionCalculations.CMC_usedReactionMassVol:=FCFcFunc_Rnd(rttVolume, UsedReactionMass);
end;

end.
