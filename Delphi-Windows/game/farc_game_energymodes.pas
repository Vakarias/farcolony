{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: energy generation modes management

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
unit farc_game_energymodes;

interface

uses
   SysUtils

   ,farc_data_infrprod;

///<summary>
///   calculate the energy output for the Nuclear Fission generation
///</summary>
///   <param name="NFOCfixedOutput">fixed output value@level</param>
///   <param name="NFOCfixedOutputByDL">fixed output value@level by Development Level</param>
///   <returns>energy output in kW formatted according from the convention (x.xx)</returns>
function FCFgEM_NuclearFission_OutputCalculation(
   const NFOCfixedOutput
         ,NFOCfixedOutputByDL: double
   ): double;

///<summary>
///   calculate the energy output for the Photon Energy generation
///</summary>
///   <param name="PEOCent">entity index #</param>
///   <param name="PEOCcol">colony index #</param>
///   <param name="PEOCphotonarea">photon area</param>
///   <param name="PEOCefficiency">photo efficiency</param>
///   <returns>energy output in kW formatted according from the convention (x.xx)</returns>
function FCFgEM_PhotonEnergy_OutputCalculation(
   const PEOCent
         ,PEOCcol
         ,PEOCphotonarea
         ,PEOCefficiency: integer
   ): double;

///<summary>
///   retrieve the energy output of an infrastructure from custom effect. It's separated from EN function since they aren't initialized in the same way
///</summary>
///   <param name="OFCFGVent">entity index #</param>
///   <param name="OFCFGVcol">colony index #</param>
///   <param name="OFCFGVcustomFxIndex">index of the concerned custom effect</param>
///   <param name="OFCFGVcurrentLevel">current level of the owned infrastructure</param>
///   <param name="OFCFGVinfraData">database data structure the owned infrastructure belongs to</param>
///   <returns>energy output in kW formatted according from the convention (x.xx)</returns>
function FCFgEM_OutputFromCustomFx_GetValue(
   const OFCFGVent
         ,OFCFGVcol
         ,OFCFGVcustomFxIndex
         ,OFCFGVcurrentLevel: integer;
   const OFCFGVinfraData: TFCRdipInfrastructure
   ): double;

///<summary>
///   retrieve the energy output of an infrastructure from it's function (must be EN). It's separated from custom effects since they aren't initialized in the same way
///</summary>
///   <param name="OFFGVent">entity index #</param>
///   <param name="OFFGVcol">colony index #</param>
///   <param name="OFFGVcurrentLevel">current level of the owned infrastructure</param>
///   <param name="OFFGVinfraData">database data structure the owned infrastructure belongs to</param>
///   <returns>energy output in kW formatted according from the convention (x.xx)</returns>
function FCFgEM_OutputFromFunction_GetValue(
   const OFFGVent
         ,OFFGVcol
         ,OFFGVcurrentLevel: integer;
   const OFFGVinfraData: TFCRdipInfrastructure
   ): double;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_univ
   ,farc_univ_func
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgEM_NuclearFission_OutputCalculation(
   const NFOCfixedOutput
         ,NFOCfixedOutputByDL: double
   ): double;
{:Purpose: calculate the energy output for the Nuclear Fission generation.
    Additions:
      -2011Jul17- *code: the code is moved in it's proper unit + complete rewrite.
}
begin
	Result:=0;
   if NFOCfixedOutput>0
   then
   begin
//   	{:DEV NOTES: don't forget to add the NFOCfixedOutputByDL w/ technosciences in the calculation.}
   	Result:=NFOCfixedOutput;
   end
   else
   begin
//   	{:DEV NOTES: implement energy output calculations.}
   end;
end;

function FCFgEM_PhotonEnergy_OutputCalculation(
   const PEOCent
         ,PEOCcol
         ,PEOCphotonarea
         ,PEOCefficiency: integer
   ): double;
{:Purpose: calculate the energy output for the Photon Energy generation.
    Additions:
      -2011Jul24- *fix: put the local float variables in extended, it's fix an out of range and calculation errors.
}
   var
      PEOCalbedo
      ,PEOCcloudsCover
      ,PEOCspacePower
      ,PEOCsurfPower
      ,PEOCresult: extended;

      PEOCstarLoc: TFCRufStelObj;
begin
   Result:=0;
   PEOCstarLoc:=FCFuF_StelObj_GetFullRow(
      FCentities[PEOCent].E_col[PEOCcol].COL_locSSys
      ,FCentities[PEOCent].E_col[PEOCcol].COL_locStar
      ,FCentities[PEOCent].E_col[PEOCcol].COL_locOObj
      ,FCentities[PEOCent].E_col[PEOCcol].COL_locSat
      );
   if PEOCstarLoc[4]=0
   then
   begin
      PEOCalbedo:=FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_obobj[PEOCstarLoc[3]].OO_albedo;
      PEOCcloudsCover:=FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_obobj[PEOCstarLoc[3]].OO_cloudsCov;
   end
   else if PEOCstarLoc[4]>0
   then
   begin
      PEOCalbedo:=FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_obobj[PEOCstarLoc[3]].OO_satList[PEOCstarLoc[4]].OOS_albedo;
      PEOCcloudsCover:=FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_obobj[PEOCstarLoc[3]].OO_satList[PEOCstarLoc[4]].OOS_cloudsCov;
   end;
   PEOCspacePower:=FCFuF_StarLight_CalcPower(FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_lum, FCDBsSys[PEOCstarLoc[1]].SS_star[PEOCstarLoc[2]].SDB_obobj[PEOCstarLoc[3]].OO_distFrmStar);
   PEOCsurfPower:=( 1-(( PEOCalbedo+( PEOCcloudsCover*0.005 ))/1.721)) * PEOCspacePower;
   PEOCresult:=( PEOCsurfPower*PEOCphotonarea*(PEOCefficiency*0.01))*0.001;
   Result:=FCFcFunc_Rnd(rttPowerKw, PEOCresult);
end;

function FCFgEM_OutputFromCustomFx_GetValue(
   const OFCFGVent
         ,OFCFGVcol
         ,OFCFGVcustomFxIndex
         ,OFCFGVcurrentLevel: integer;
   const OFCFGVinfraData: TFCRdipInfrastructure
   ): double;
{:Purpose: retrieve the energy output of an infrastructure from custom effect. It's separated from EN function since they aren't initialized in the same way.
    Additions:
      -2011Jul18- *add: complete the photon energy case.
}
{:DEV NOTES: when an update is made in this function, don't forget to also update FCFgEM_OutputFromFunction_GetValue.}
begin
   Result:=0;
   case OFCFGVinfraData.I_customFx[OFCFGVcustomFxIndex].ICFX_enGenMode.FEPM_productionModes of
      egmAntimatter: ;

      egmFission: Result:=FCFgEM_NuclearFission_OutputCalculation(
         OFCFGVinfraData.I_customFx[OFCFGVcustomFxIndex].ICFX_enGenMode.FEPM_fissionFPlvl[OFCFGVcurrentLevel]
         ,OFCFGVinfraData.I_customFx[OFCFGVcustomFxIndex].ICFX_enGenMode.FEPM_fissionFPlvlByDL[OFCFGVcurrentLevel]
         );

      egmFusionDT:;

      egmFusionH2:;

      egmFusionHe3:;

      egmPhoton: Result:=FCFgEM_PhotonEnergy_OutputCalculation(
         OFCFGVent
         ,OFCFGVcol
         ,OFCFGVinfraData.I_customFx[OFCFGVcustomFxIndex].ICFX_enGenMode.FEPM_photonArea
         ,OFCFGVinfraData.I_customFx[OFCFGVcustomFxIndex].ICFX_enGenMode.FEPM_photonEfficiency
         );
   end;
end;

function FCFgEM_OutputFromFunction_GetValue(
   const OFFGVent
         ,OFFGVcol
         ,OFFGVcurrentLevel: integer;
   const OFFGVinfraData: TFCRdipInfrastructure
   ): double;
{:Purpose: retrieve the energy output of an infrastructure from it's function (must be EN). It's separated from custom effects since they aren't initialized in the same way.
    Additions:
      -2011Nov14- *rem: remove a useless test.
      -2011Jul18- *add: complete the photon energy case.
}
{:DEV NOTES: when an update is made in this function, don't forget to also update FCFgEM_OutputFromCustomFx_GetValue.}
begin
   Result:=0;
   case OFFGVinfraData.I_fEnergyPmode.FEPM_productionModes of
      egmAntimatter: ;

      egmFission: Result:=FCFgEM_NuclearFission_OutputCalculation(
         OFFGVinfraData.I_fEnergyPmode.FEPM_fissionFPlvl[OFFGVcurrentLevel], OFFGVinfraData.I_fEnergyPmode.FEPM_fissionFPlvlByDL[OFFGVcurrentLevel]
         );

      egmFusionDT:;

      egmFusionH2:;

      egmFusionHe3:;

      egmPhoton: Result:=FCFgEM_PhotonEnergy_OutputCalculation(
         OFFGVent
         ,OFFGVcol
         ,OFFGVinfraData.I_fEnergyPmode.FEPM_photonArea
         ,OFFGVinfraData.I_fEnergyPmode.FEPM_photonEfficiency
         );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
