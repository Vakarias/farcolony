{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - construction system unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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
unit farc_game_infraconsys;

interface

uses
   Math
   ,SysUtils

   ,farc_data_infrprod;

///<summary>
///   calculate the assembling time in hours
///</summary>
///   <param name="ADCtotalVolInfra">total volume at desired level</param>
///   <param name="ADCrecursiveCoef">recursive coefficient, must be 1 by default</param>
///   <param name="ADCiCWP">iCWP value</param>
function FCFgICS_AssemblingDuration_Calculation(
   const ADCtotalVolInfra
         ,ADCrecursiveCoef
         ,ADCiCWP: double
   ): integer;

///<summary>
///   calculate the building time in hours
///</summary>
///   <param name="BDCtotalVolMaterial">total volume of material at desired level</param>
///   <param name="BDCrecursiveCoef">recursive coefficient, must be 1 by default</param>
///   <param name="BDCiCWP">iCWP value</param>
///   <param name="BDCemo">region's environment modifier where the infrastructure is</param>
function FCFgICS_BuildingDuration_Calculation(
   const BDCtotalVolMaterial
         ,BDCrecursiveCoef
         ,BDCiCWP
         ,BDCemo: double
   ): integer;

///<summary>
///   calculate the iCWP for a given infrastructure level to assemble/build. Return the iCWP formatted x.x
///</summary>
///   <param name="ICWPCent">entity index #</param>
///   <param name="ICWPCcol">colony index #</param>
///   <param name="ICWPCinfraLevel">infrastructure level of the infrastructure to build/assemble</param>
function FCFgICS_iCWP_Calculation(
	const ICWPCent
   		,ICWPCcol
   		,ICWPCinfraLevel: integer
   ): double;

///<summary>
///   determine the level of a new infrastructure according to it's level range, the settlement type and level
///</summary>
///   <param name="ILSinfraLevelMin">infrastructure level range, min value</param>
///   <param name="ILSinfraLevelMax">infrastructure level range, max value</param>
///   <param name="ILSsettleLevel">settlement level, where the infrastructure will be CAB</param>
function FCFgICS_InfraLevel_Setup(
   const ILSinfraLevelMin
   		,ILSinfraLevelMax: integer;
   const ILSsettleLevel: integer
   ): integer;

///<summary>
///   calculate the recursive coefficient of a given assembling/building
///</summary>
///   <param name="RCCdoneTime">time, in hours, already done</param>
///   <param name="RCCinitTime">starting duration</param>
function FCFgICS_RecursiveCoef_Calculation(const RCCdoneTime, RCCinitTime: integer): double;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   process in the assembling of an infrastructure
///</summary>
///   <param name="APent">entity index #</param>
///   <param name="APcol">colony index #</param>
///   <param name="APsettlement">settlement index #</param>
///   <param name="APduration">assembling duration</param>
///   <param name="APinfraToken">infrastructure token to assemble</param>
///   <param name="APinfraKitInStorage">infrastructure kit index # in colony's storage</param>
procedure FCMgICS_Assembling_Process(
   const APent
         ,APcol
         ,APsettlement
         ,APduration: integer;
   const APinfraToken: string;
   const APinfraKitInStorage: integer
   );

///<summary>
///   process in the building of an infrastructure
///</summary>
///   <param name="BPent">entity index #</param>
///   <param name="BPcol">colony index #</param>
///   <param name="BPsettlement">settlement index #</param>
///   <param name="BPduration">assembling duration</param>
///   <param name="BPinfraToken">infrastructure token to assemble</param>
procedure FCMgICS_Building_Process(
   const BPent
         ,BPcol
         ,BPsettlement
         ,BPduration: integer;
   const BPinfraToken: string
   );

///<summary>
///   add an infrastructure in a CAB queue
///</summary>
///   <param name="CABAent">entity #</param>
///   <param name="CABAcol">colony #</param>
///   <param name="CABAsettlement">settlement #</param>
///   <param name="CABAinfra">infrastructure #</param>
procedure FCMgICS_CAB_Add(
   const CABAent
         ,CABAcol
         ,CABAsettlement
         ,CABAinfra: integer
   );

///<summary>
///   convert a space unit to a corresponding infrastructure as requested
///</summary>
///   <param name="ICPent">entity index #</param>
///   <param name="ICPspu">space unit index #</param>
///   <param name="ICPcol">colony index #</param>
///   <param name="ICPsettlement">settlement index #</param>
procedure FCMgICS_Conversion_Process(
   const ICPent
         ,ICPspu
         ,ICPcol
         ,ICPsettlement: integer
   );

///<summary>
///   initialize the infrastructure functions data for assembling/building modes
///</summary>
///   <param name="FIent">entity index #</param>
///   <param name="FIcol">colony index #</param>
///   <param name="FIsett">settlement index #</param>
///   <param name="FIinfra">infrastructure index number</param>
///   <param name="FIinfraData">infrastructure data</param>
procedure FCMgICS_FunctionsInit(
   const FIent
         ,FIcol
         ,FIsett
         ,FIinfra: integer;
   const FIinfraData: TFCRdipInfrastructure
   );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_energymodes
   ,farc_game_infra
   ,farc_game_infracustomfx
   ,farc_game_infrapower
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgICS_AssemblingDuration_Calculation(
   const ADCtotalVolInfra
         ,ADCrecursiveCoef
         ,ADCiCWP: double
   ): integer;
{:Purpose: calculate the assembling time in hours.
    Additions:
      -2011Jun12- *add: take the case if result=0;
}
var
   ADCcoef: double;
begin
   Result:=0;
   ADCcoef:= ( ( power(((ADCtotalVolInfra*ADCrecursiveCoef)/0.003), 0.333) ) / power(ADCiCWP,0.333) ) / 2;
	Result:=round(power(ADCcoef, 2.5)*0.5);
   if Result<1
   then Result:=1;
end;

function FCFgICS_BuildingDuration_Calculation(
   const BDCtotalVolMaterial
         ,BDCrecursiveCoef
         ,BDCiCWP
         ,BDCemo: double
   ): integer;
{:Purpose: calculate the building time in hours.
    Additions:
}
var
   BDCcoef: double;
begin
   Result:=0;
   BDCcoef:= ( power(((BDCtotalVolMaterial*BDCrecursiveCoef)/0.003), 0.333) + BDCemo) / power(BDCiCWP,0.333);
	Result:=round(power(BDCcoef, 2.5)*0.5);
   if Result<1
   then Result:=1;
end;

function FCFgICS_iCWP_Calculation(
	const ICWPCent
   		,ICWPCcol
   		,ICWPCinfraLevel: integer
   ): double;
{:Purpose: calculate the iCWP for a given infrastructure level to assemble/build. Return the iCWP formatted x.x.
    Additions:
      -2011Jun07- *fix: forgot to put the case when the CAB queue is empty (throw an exception).
}
var
   IWCPCsettleInfraCount
   ,IWCPCsettleIndexMax
   ,IWCPCinfraIndex
   ,IWCPCmax
   ,IWCPCsettlement
	,IWCPCsumLvl: integer;

   IWCPCdivider
   ,IWCPCicwp: double;
begin
	Result:=0;
   IWCPCmax:=length(FCentities[ICWPCent].E_col[ICWPCcol].COL_cabQueue)-1;
   if IWCPCmax>0
   then
   begin
      IWCPCsettlement:=1;
      IWCPCsumLvl:=0;
      while IWCPCsettlement<=IWCPCmax do
      begin
       	IWCPCsettleIndexMax:=Length(FCentities[ICWPCent].E_col[ICWPCcol].COL_cabQueue[IWCPCsettlement])-1;
         if IWCPCsettleIndexMax>0
         then
         begin
            IWCPCsettleInfraCount:=1;
				while IWCPCsettleInfraCount<=IWCPCsettleIndexMax do
            begin
         		IWCPCinfraIndex:=FCentities[ICWPCent].E_col[ICWPCcol].COL_cabQueue[IWCPCsettlement, IWCPCsettleInfraCount];
               if FCentities[ICWPCent].E_col[ICWPCcol].COL_settlements[IWCPCsettlement].CS_infra[IWCPCinfraIndex].CI_status<>istInConversion
               then IWCPCsumLvl:=IWCPCsumLvl+FCentities[ICWPCent].E_col[ICWPCcol].COL_settlements[IWCPCsettlement].CS_infra[IWCPCinfraIndex].CI_level;
               inc(IWCPCsettleInfraCount);
            end;
         end;
         inc(IWCPCsettlement);
      end;
      if IWCPCsumLvl=0
      then IWCPCicwp:=FCentities[ICWPCent].E_col[ICWPCcol].COL_population.POP_wcpTotal
      else if IWCPCsumLvl>0
      then
      begin
         IWCPCdivider:=ln(IWCPCsumLvl+1) / ln(ICWPCinfraLevel+1);
         IWCPCicwp:=FCFcFunc_Rnd(cfrttp1dec, FCentities[ICWPCent].E_col[ICWPCcol].COL_population.POP_wcpTotal/IWCPCdivider);
      end;
   end
   else if IWCPCmax=0
   then IWCPCicwp:=FCentities[ICWPCent].E_col[ICWPCcol].COL_population.POP_wcpTotal;
   Result:=IWCPCicwp;
end;

function FCFgICS_InfraLevel_Setup(
   const ILSinfraLevelMin
   		,ILSinfraLevelMax: integer;
   const ILSsettleLevel: integer
   ): integer;
{:Purpose: determine the level of a new infrastructure according to it's level range and the settlement level.
    Additions:
}
begin
	Result:=-1;
   if ILSinfraLevelMin<=ILSsettleLevel
   then
   begin
      if ILSinfraLevelMax<=ILSsettleLevel
      then Result:=ILSinfraLevelMax
      else Result:=ILSsettleLevel;
   end;
end;

function FCFgICS_RecursiveCoef_Calculation(const RCCdoneTime, RCCinitTime: integer): double;
{:Purpose: calculate the recursive coefficient of a given assembling/building.
    Additions:
}
var
   RCCcoef: double;
begin
   Result:=0;
   if RCCinitTime>0
   then
   begin
      RCCcoef:=1-( RCCdoneTime / RCCinitTime );
      Result:=FCFcFunc_Rnd(cfrttp3dec, RCCcoef);
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgICS_Assembling_Process(
   const APent
         ,APcol
         ,APsettlement
         ,APduration: integer;
   const APinfraToken: string;
   const APinfraKitInStorage: integer
   );
{:Purpose: process in the assembling of an infrastructure.
    Additions:
      -2011Jul05- *add/fix: forgot to update the CAB queue list !
      -2011Jul04- *add: add a parameter to indicate the storage index # of the used infrastructure kit.
                  *add: remove one unit of infrastructure kit that is used for the assembling.
      -2011Jun26- *add: initialize the infrastructure functions in a separate method.
      -2011Jun08- *rem: region parameter is removed (useless).
                  *rem: iCWP/Duration calculation data and code (useless).
                  *add: a duration parameter.
                  *add: update the interface if needed.
      -2011May18-	*add: assembling process, basic completion.
    	-2011May17-	*add: assembling process (WIP).
}
	var
   	APinfraIndex
      ,APxfer: integer;

      APisCDPshown: boolean;

      APclonedInfra: TFCRdipInfrastructure;

   	APenv: TFCRgcEnvironment;
begin
   APenv:=FCFgC_ColEnv_GetTp(APent, APcol);
   APinfraIndex:=length(FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra);
   SetLength(FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra, APinfraIndex+1);
   APclonedInfra:=FCFgInf_DataStructure_Get(APinfraToken, APenv.ENV_envType);
   FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_dbToken:=APclonedInfra.I_token;
	FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_level:=FCFgICS_InfraLevel_Setup(
   	APclonedInfra.I_minLevel
      ,APclonedInfra.I_maxLevel
      ,FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_level
      );
   FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_status:=istInAssembling;
   FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_function:=APclonedInfra.I_function;
	FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_cabDuration:=APduration;
   FCentities[APent].E_col[APcol].COL_settlements[APsettlement].CS_infra[APinfraIndex].CI_cabWorked:=0;
   FCMgICS_CAB_Add(
      APent
      ,APcol
      ,APsettlement
      ,APinfraIndex
      );
   FCMgICS_FunctionsInit(
      APent
      ,APcol
      ,APsettlement
      ,APinfraIndex
      ,APclonedInfra
      );
   APxfer:=FCFgC_Storage_Update(
      false
      ,FCEntities[APent].E_col[APcol].COL_storageList[APinfraKitInStorage].CPR_token
      ,1
      ,APent
      ,APcol
      );
   APisCDPshown:=FCFuiCDP_isInfrastructuresSection_Shown(APcol, APsettlement);
   if APisCDPshown
   then FCMuiCDP_Data_Update(
      dtInfra
      ,APcol
      ,APsettlement
      );
end;

procedure FCMgICS_Building_Process(
   const BPent
         ,BPcol
         ,BPsettlement
         ,BPduration: integer;
   const BPinfraToken: string
   );
{:Purpose: process in the building of an infrastructure.
    Additions:
      -2011Jul05- *add/fix: forgot to update the CAB queue list !
      -2011Jun26- *add: initialize the infrastructure functions in a separate method.
}
	var
   	BPinfraIndex: integer;

      BPisCDPshown: boolean;

      BPclonedInfra: TFCRdipInfrastructure;

   	BPenv: TFCRgcEnvironment;
begin
   BPenv:=FCFgC_ColEnv_GetTp(BPent, BPcol);
   BPinfraIndex:=length(FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra);
   SetLength(FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra, BPinfraIndex+1);
   BPclonedInfra:=FCFgInf_DataStructure_Get(BPinfraToken, BPenv.ENV_envType);
   FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_dbToken:=BPclonedInfra.I_token;
	FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_level:=FCFgICS_InfraLevel_Setup(
   	BPclonedInfra.I_minLevel
      ,BPclonedInfra.I_maxLevel
      ,FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_level
      );
   FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_status:=istInBldSite;
   FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_function:=BPclonedInfra.I_function;
	FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_cabDuration:=BPduration;
   FCentities[BPent].E_col[BPcol].COL_settlements[BPsettlement].CS_infra[BPinfraIndex].CI_cabWorked:=0;
   FCMgICS_CAB_Add(
      BPent
      ,BPcol
      ,BPsettlement
      ,BPinfraIndex
      );
   FCMgICS_FunctionsInit(
      BPent
      ,BPcol
      ,BPsettlement
      ,BPinfraIndex
      ,BPclonedInfra
      );
   BPisCDPshown:=FCFuiCDP_isInfrastructuresSection_Shown(BPcol, BPsettlement);
   if BPisCDPshown
   then FCMuiCDP_Data_Update(
      dtInfra
      ,BPcol
      ,BPsettlement
      );
end;

procedure FCMgICS_CAB_Add(
   const CABAent
         ,CABAcol
         ,CABAsettlement
         ,CABAinfra: integer
   );
{:Purpose: add an infrastructure in a CAB queue.
    Additions:
      -2011Apr26- *mod: the method is moved in it's proper unit.
}
var
   CABAcnt
   ,CABAlen: integer;
begin
   CABAlen:=length(FCentities[CABAent].E_col[CABAcol].COL_cabQueue[CABAsettlement]);
   if CABAlen<1
   then
   begin
      SetLength(FCentities[CABAent].E_col[CABAcol].COL_cabQueue[CABAsettlement], 2);
      CABAlen:=1;
   end
   else if CABAlen>=1
   then SetLength(FCentities[CABAent].E_col[CABAcol].COL_cabQueue[CABAsettlement], CABAlen+1);
   CABAcnt:=CABAlen;
   FCentities[CABAent].E_col[CABAcol].COL_cabQueue[CABAsettlement, CABAcnt]:=CABAinfra;
end;

procedure FCMgICS_Conversion_Process(
   const ICPent
         ,ICPspu
         ,ICPcol
         ,ICPsettlement: integer
   );
{:Purpose: convert a space unit to a corresponding infrastructure as requested.
    Additions:
      -2011Jul24- *add: update the colony data panel with the infrastructures list if it's needed.
      -2011Jul17- *add: harcoded custom effects: energy generation and storage.
      -2011Jul14- *rem: remove the HQ setting to an outside method, will be set by the custom effects processing.
                  *code: some parts are reorganized.
                  *mod: storage is now initialized in custom effects application routines.
      -2011Jul13- *add: infrastructure power consumption.
      -2011Jul12- *add: initialize the energy data according to the conversion rule.
      -2011May15-	*mod: change in the infrastructure level calculation, according to the rule change in the design document.
      				*add: CABworked initialization.
      -2011May06- *add: hardcoded storage data.
      -2011Apr26- *mod: the method is moved in it's proper unit.
      -2011Apr20- *add: add hardcoded technicians and soldier to the population.
      -2011Mar09- *add: update the CAB queue w/ the converting infrastructure.
      -2011Mar07- *mod: change and finalize the infrastructure environment data method.
                  *add: converted housing specified data initialization.
                  *add: conversion duration calculations.
      -2011Mar03- *add: custom effects initialization.
      -2011Feb24- *add: basic surface/volume infrastructure calculations + dev note.
                  *add: the definitive infrastructure level calculation.
      -2011Feb21- *add: retrieve and use the right colonization shelter relative to the orbital object's environment.
                  *code: parameters and private variable refactoring.
      -2010Oct24- *add: update the HQ presence if needed.
      -2010Sep16- *add: entities code.
      -2010Sep05- *add: the converted space unit is removed from the corresponding faction's owned space units list.
      -2010Jun01-	*add: hardcoded population age.
      -2010May31- *add: population addition when the space unit is converted.
}
var
   ICPduration
   ,ICPeffectIdx
   ,ICPinfra
   ,ICPprodIndex
   ,ICPsurf
   ,ICPvol
   ,ICPxfer: integer;

   ICPx: double;

   ICPisCDPshown: boolean;

   ICPenv: TFCRgcEnvironment;

   ICPclonedInfra: TFCRdipInfrastructure;
begin
   ICPenv:=FCFgC_ColEnv_GetTp(ICPent, ICPcol);
   {:DEV NOTES: colonization equipment module will be taken in consideration in the future, for now i use hardcoded data.}
   SetLength(FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra, length(FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra)+1);
   ICPinfra:=length(FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra)-1;
   ICPclonedInfra:=FCFgInf_DataStructure_Get('infrColShelt', ICPenv.ENV_envType);
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_dbToken:=ICPclonedInfra.I_token;

   {:DEV NOTES: transfer the colonization equipment module volume to the prive variable infra volume.
      surface is equals to power(EMvolume; 0.333)^2
      for now, only fixed default values are given
      crew is also hardcoded but will be take from the owned current crew in the future
   }
   ICPvol:=12867;
   ICPsurf:=round(sqr(power(ICPvol,0.333)));
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level:=1;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_status:=istInConversion;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_function:=fHousing;
   {:DEV NOTES: hardcoded value for population capacity and quality of life data, will be dynamic in the future.}
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_fhousPCAP:=30;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_fhousQOL:=1;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_fhousVol:=ICPvol;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_fhousSurf:=ICPsurf;
   {:DEV NOTES: for pcap, don'T forget to update the different types according to the population of the colonization module and also the crew.}
   FCMgCSM_ColonyData_Upd(
      gcsmdPCAP
      ,ICPent
      ,ICPcol
      ,FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_fhousPCAP
      ,0
      ,gcsmptNone
      ,false
      );
   FCMgCSM_ColonyData_Upd(
      gcsmdQOL
      ,ICPent
      ,ICPcol
      ,0
      ,0
      ,gcsmptNone
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      gcsmdPopulation
      ,ICPent
      ,ICPcol
      ,20
      ,25.3
      ,gcsmptColon
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      gcsmdPopulation
      ,ICPent
      ,ICPcol
      ,8
      ,25.3
      ,gcsmptIStech
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      gcsmdPopulation
      ,ICPent
      ,ICPcol
      ,2
      ,25.3
      ,gcsmptMSsold
      ,true
      );
   {.conversion calculations, the crew is hardcoded for now}
   ICPx:=sqrt( ICPvol*0.2 ) / (30+5);//x = [ SQRT(TCMV / 5) ] / PC
   ICPduration:=round(power(ICPx, 2.5)*0.5);//duration (in hrs) = (x^2.5)/2 rounded
   if ICPduration<1
   then ICPduration:=1;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_cabDuration:=ICPduration;
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_cabWorked:=0;
   FCMgICS_CAB_Add(
      ICPent
      ,ICPcol
      ,ICPsettlement
      ,ICPinfra
      );
   {:DEV NOTES: before apply custom fx, if the space unit/colonization EM has LSS, convert it into custom effect specific data
   hardcoded unit are used until equipment modules and designs are updated.}
   {:DEV NOTES: storage capacity, if there's any from the space unit, are loaded directly in the database item data, it's an another particularity for conversion only.}
   ICPeffectIdx:=0;
   setlength(ICPclonedInfra.I_customFx, length(ICPclonedInfra.I_customFx)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customFx)-1;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_customEffect:=cfxProductStorage;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_prodStorageLvl[FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level].IPS_solid:=70;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_prodStorageLvl[FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level].IPS_liquid:=30;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_prodStorageLvl[FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level].IPS_gas:=30;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_prodStorageLvl[FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level].IPS_biologic:=30;
   setlength(ICPclonedInfra.I_customFx, length(ICPclonedInfra.I_customFx)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customFx)-1;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_customEffect:=cfxEnergyGen;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_enGenMode.FEPM_productionModes:=egmPhoton;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_enGenMode.FEPM_photonArea:=10;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_enGenMode.FEPM_photonEfficiency:=90;
   setlength(ICPclonedInfra.I_customFx, length(ICPclonedInfra.I_customFx)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customFx)-1;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_customEffect:=cfxEnergyStor;
   ICPclonedInfra.I_customFx[ICPeffectIdx].ICFX_enStorLvl[1]:=20;
   FCMgICFX_Effects_Application(
      ICPent
      ,ICPcol
      ,FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_level
      ,ICPclonedInfra
      );
   FCMspuF_SpUnit_Remove(ICPent, ICPspu);
   {:DEV NOTES: energy consumption-generation-storage data will be calculated from the space unit's design.}
   {:DEV NOTES: for now it's simply hardcoded.}
   FCentities[ICPent].E_col[ICPcol].COL_settlements[ICPsettlement].CS_infra[ICPinfra].CI_powerCons:=5;
   FCMgIP_CSMEnergy_Update(
      ICPent
      ,ICPcol
      ,false
      ,5
      ,0
      ,0
      ,0
      );
   ICPxfer:=FCFgC_Storage_Update(
      true
      ,'energNucFisRsm'
      ,1
      ,0
      ,ICPcol
      );
   ICPxfer:=FCFgC_Storage_Update(
      true
      ,'equipHandTools'
      ,10
      ,0
      ,ICPcol
      );
   ICPxfer:=FCFgC_Storage_Update(
      true
      ,'equipPowerTools'
      ,10
      ,0
      ,ICPcol
      );
   ICPxfer:=FCFgC_Storage_Update(
      true
      ,'equipConstrExo'
      ,1
      ,0
      ,ICPcol
      );
   ICPisCDPshown:=FCFuiCDP_isInfrastructuresSection_Shown(ICPcol, ICPsettlement);
   if ICPisCDPshown
   then FCMuiCDP_Data_Update(
      dtInfra
      ,ICPcol
      ,ICPsettlement
      );
end;

procedure FCMgICS_FunctionsInit(
   const FIent
         ,FIcol
         ,FIsett
         ,FIinfra: integer;
   const FIinfraData: TFCRdipInfrastructure
   );
{:Purpose: initialize the infrastructure functions data for assembling/building modes.
    Additions:
      -2011Sep03- *add: for fHousing, add the level in determination of the population capacity.
      -2011Jul18- *add: complete the fEnergy case.
}
begin
   case FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_function of
      fEnergy: FCFgEM_OutputFromFunction_GetValue(
         FIent
         ,FIcol
         ,FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_level
         ,FIinfraData
         );

      fHousing:
      begin
         FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_fhousPCAP:=FIinfraData.I_fHousPopulationCap[FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_level];
         FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_fhousQOL:=FIinfraData.I_fHousQualityOfLife;
         FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_fhousVol:=0;
         FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_fhousSurf:=0;
      end;

      fIntelligence:
      begin

      end;

      fMiscellaneous:
      begin

      end;

      fProduction:
      begin

      end;
   end;
end;

end.
