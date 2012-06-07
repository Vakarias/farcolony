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

unit farc_game_miland;

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
         ,LCssys
         ,LCstar
         ,LCoobjIdx
         ,LCsatIdx
         ,LCsatObjIdx: integer;

   const LCdistDecel
         ,LCentrVel: extended;

   const LCsetPeVel: boolean
   );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_init
   ,farc_data_spu
   ,farc_data_univ
   ,farc_game_missioncore
   ,farc_spu_functions;

//===================================END OF INIT============================================

procedure FCFgMl_Land_Calc(
   const LCfac
         ,LCownIdx
         ,LCssys
         ,LCstar
         ,LCoobjIdx
         ,LCsatIdx
         ,LCsatObjIdx: integer;

   const LCdistDecel
         ,LCentrVel: extended;

   const LCsetPeVel: boolean
   );
{:Purpose: calculate trip data from orbit to ground.
    Additions:
      -2010Sep16- *add: a parameter for faction #.
                  *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
}
var
   LCdesgn
   ,LCisp: integer;

   LCplanApress
   ,LCdepVel
   ,LCburnEnd
   ,LCusedRM
   ,LCtime
   ,LCatm: extended;
const
   LCgeesInKmS=FCCdiMbySec_In_1G*0.001;
begin
   if LCsatIdx=0
   then LCplanApress:=FCDBsSys[LCssys].SS_star[LCstar].SDB_obobj[LCoobjIdx].OO_atmPress
   else if LCsatIdx>0
   then LCplanApress:=FCDBsSys[LCssys].SS_star[LCstar].SDB_obobj[LCoobjIdx].OO_satList[LCsatIdx].OOS_atmPress;
   LCdesgn:=FCFspuF_Design_getDB(FCentities[LCfac].E_spU[LCownIdx].SUO_designId);
   {.calculate final acceleration in gees relative to loaded mass}
   GMCAccelG:=(MRMCDVCthrbyvol*MRMCDVCvolOfDrive)/MRMCDVCloadedMassInTons;
   {.get the space unit's ISP}
   LCisp:=FCDBscDesigns[LCdesgn].SCD_spDriveISP;
   {.velocities calculations}
   LCdepVel:=FCentities[LCfac].E_spU[LCownIdx].SUO_deltaV;
   {.calculate the burn endurance for deceleration}
   LCburnEnd:=(LCdepVel-LCentrVel)/(GMCAccelG*LCgeesInKmS);
   {.caculate used reaction mass volume for deceleration}
   LCusedRM:=(LCburnEnd)*(GMCCthrN/(LCisp*FCCdiMbySec_In_1G))/(MRMCDVCrmMass*1000);
   {.calculate deceleration time}
   LCtime:=LCburnEnd/600;
   {.determine atmosphere entry time}
   LCatm:=LCplanApress/FCCdiMbars_In_1atmosphere;
   GMClandTime:=round(((1.84-(1-LCatm))*70)/18.4);
   GMCtripTime:=round(LCtime)+GMClandTime;
   GMCusedRMvol:=FCFcFunc_Rnd(cfrttpVolm3, LCusedRM);
end;

end.
