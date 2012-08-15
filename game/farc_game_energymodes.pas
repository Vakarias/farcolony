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
         ,NFOCfixedOutputByDL: extended
   ): extended;

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
   ): extended;

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
   ): extended;

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
   ): extended;

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
         ,NFOCfixedOutputByDL: extended
   ): extended;
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
   ): extended;
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
   PEOCstarLoc[1]:=0;
   PEOCstarLoc[2]:=0;
   PEOCstarLoc[3]:=0;
   PEOCstarLoc[4]:=0;
   PEOCstarLoc:=FCFuF_StelObj_GetFullRow(
      FCDdgEntities[PEOCent].E_colonies[PEOCcol].C_locationStarSystem
      ,FCDdgEntities[PEOCent].E_colonies[PEOCcol].C_locationStar
      ,FCDdgEntities[PEOCent].E_colonies[PEOCcol].C_locationOrbitalObject
      ,FCDdgEntities[PEOCent].E_colonies[PEOCcol].C_locationSatellite
      );
   if PEOCstarLoc[4]=0
   then
   begin
      PEOCalbedo:=FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_orbitalObjects[PEOCstarLoc[3]].OO_albedo;
      PEOCcloudsCover:=FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_orbitalObjects[PEOCstarLoc[3]].OO_cloudsCover;
   end
   else if PEOCstarLoc[4]>0
   then
   begin
      PEOCalbedo:=FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_orbitalObjects[PEOCstarLoc[3]].OO_satellitesList[PEOCstarLoc[4]].OO_albedo;
      PEOCcloudsCover:=FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_orbitalObjects[PEOCstarLoc[3]].OO_satellitesList[PEOCstarLoc[4]].OO_cloudsCover;
   end;
   PEOCspacePower:=FCFuF_StarLight_CalcPower(FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_luminosity, FCDduStarSystem[PEOCstarLoc[1]].SS_stars[PEOCstarLoc[2]].S_orbitalObjects[PEOCstarLoc[3]].OO_isSatFdistanceFromStar);
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
   ): extended;
{:Purpose: retrieve the energy output of an infrastructure from custom effect. It's separated from EN function since they aren't initialized in the same way.
    Additions:
      -2011Jul18- *add: complete the photon energy case.
}
{:DEV NOTES: when an update is made in this function, don't forget to also update FCFgEM_OutputFromFunction_GetValue.}
begin
   Result:=0;
   case OFCFGVinfraData.I_customEffectStructure[OFCFGVcustomFxIndex].ICFX_ceEGmode.EGM_modes of
      egmAntimatter: ;

      egmFission: Result:=FCFgEM_NuclearFission_OutputCalculation(
         OFCFGVinfraData.I_customEffectStructure[OFCFGVcustomFxIndex].ICFX_ceEGmode.EGM_mFfixedValues[OFCFGVcurrentLevel].FV_baseGeneration
         ,OFCFGVinfraData.I_customEffectStructure[OFCFGVcustomFxIndex].ICFX_ceEGmode.EGM_mFfixedValues[OFCFGVcurrentLevel].FV_generationByDevLevel
         );

      egmFusionDT:;

      egmFusionH2:;

      egmFusionHe3:;

      egmPhoton: Result:=FCFgEM_PhotonEnergy_OutputCalculation(
         OFCFGVent
         ,OFCFGVcol
         ,OFCFGVinfraData.I_customEffectStructure[OFCFGVcustomFxIndex].ICFX_ceEGmode.EGM_mParea
         ,OFCFGVinfraData.I_customEffectStructure[OFCFGVcustomFxIndex].ICFX_ceEGmode.EGM_mPefficiency
         );
   end;
end;

function FCFgEM_OutputFromFunction_GetValue(
   const OFFGVent
         ,OFFGVcol
         ,OFFGVcurrentLevel: integer;
   const OFFGVinfraData: TFCRdipInfrastructure
   ): extended;
{:Purpose: retrieve the energy output of an infrastructure from it's function (must be EN). It's separated from custom effects since they aren't initialized in the same way.
    Additions:
      -2011Nov14- *rem: remove a useless test.
      -2011Jul18- *add: complete the photon energy case.
}
{:DEV NOTES: when an update is made in this function, don't forget to also update FCFgEM_OutputFromCustomFx_GetValue.}
begin
   Result:=0;
   case OFFGVinfraData.I_fEmode.EGM_modes of
      egmAntimatter: ;

      egmFission: Result:=FCFgEM_NuclearFission_OutputCalculation(
         OFFGVinfraData.I_fEmode.EGM_mFfixedValues[OFFGVcurrentLevel].FV_baseGeneration, OFFGVinfraData.I_fEmode.EGM_mFfixedValues[OFFGVcurrentLevel].FV_generationByDevLevel
         );

      egmFusionDT:;

      egmFusionH2:;

      egmFusionHe3:;

      egmPhoton: Result:=FCFgEM_PhotonEnergy_OutputCalculation(
         OFFGVent
         ,OFFGVcol
         ,OFFGVinfraData.I_fEmode.EGM_mParea
         ,OFFGVinfraData.I_fEmode.EGM_mPefficiency
         );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
