{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - construction system unit

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
unit farc_game_infraconsys;

interface

uses
   Math
   ,SysUtils

   ,farc_data_infrprod;

///<summary>
///   calculate the assembling time
///</summary>
///   <param name="ADCtotalVolInfra">total volume at desired level</param>
///   <param name="ADCrecursiveCoef">recursive coefficient, must be 1 by default</param>
///   <param name="ADCiCWP">iCWP value</param>
///   <returns>the assembling time in hours (int)</returns>
function FCFgICS_AssemblingDuration_Calculation(
   const ADCtotalVolInfra
         ,ADCrecursiveCoef
         ,ADCiCWP: extended
   ): integer;

///<summary>
///   calculate the building time
///</summary>
///   <param name="BDCtotalVolMaterial">total volume of material at desired level</param>
///   <param name="BDCrecursiveCoef">recursive coefficient, must be 1 by default</param>
///   <param name="BDCiCWP">iCWP value</param>
///   <param name="BDCemo">region's environment modifier where the infrastructure is</param>
///   <returns>the building time in hours (int)</returns>
function FCFgICS_BuildingDuration_Calculation(
   const BDCtotalVolMaterial
         ,BDCrecursiveCoef
         ,BDCiCWP
         ,BDCemo: extended
   ): integer;

///<summary>
///   calculate the iCWP for a given infrastructure level to assemble/build
///</summary>
///   <param name="ICWPCent">entity index #</param>
///   <param name="ICWPCcol">colony index #</param>
///   <param name="ICWPCinfraLevel">infrastructure level of the infrastructure to build/assemble</param>
///   <returns>iCWP formatted x.x</returns>
function FCFgICS_iCWP_Calculation(
	const ICWPCent
   		,ICWPCcol
   		,ICWPCinfraLevel: integer
   ): extended;

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
function FCFgICS_RecursiveCoef_Calculation(const RCCdoneTime, RCCinitTime: integer): extended;

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
///   cleanup the CAB queue of a colony, useless CAB entries are removed
///</summary>
///   <param name="CABCent"></param>
///   <param name="CABCcol"></param>
procedure FCMgICS_CAB_Cleanup(
   const CABCent
         ,CABCcol: integer
   );

///<summary>
///   conversion post-process
///</summary>
///   <param name="ICPPent">entity index #</param>
///   <param name="ICPPcol">colony index #</param>
///   <param name="ICPPsettlement">settlement index #</param>
///   <param name="ICPPinfra">infrastructure index #</param>
///   <param name="ICPPcabQueueIndex">CAB queue index #</param>
procedure FCMgICS_Conversion_PostProcess(
   const ICPPent
         ,ICPPcol
         ,ICPPsettlement
         ,ICPPinfra
         ,ICPPcabQueueIndex: integer
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
///   process the transition rule, considering that staff requirements are fufilled
///</summary>
///   <param name="TRPent">entity index #</param>
///   <param name="TRPcol">colony index #</param>
///   <param name="TRPsettlement">settlement index #</param>
///   <param name="TRPownInfra">owned infrastructure index #</param>
///   <param name="TRPcabIdx">CAB queue index #</param>
///   <param name="TRPincludeStaffTest">=true, a staff test/assignment is made</param>
procedure FCMgICS_TransitionRule_Process(
   const TRPent
         ,TRPcol
         ,TRPsettlement
         ,TRPownInfra
         ,TRPcabIdx: integer;
         TRPincludeStaffTest: boolean
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
   ,farc_game_infrafunctions
   ,farc_game_infrastaff
   ,farc_game_prod
   ,farc_game_prodrsrcspots
   ,farc_spu_functions
   ,farc_ui_coldatapanel
   ,farc_ui_coredatadisplay
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgICS_AssemblingDuration_Calculation(
   const ADCtotalVolInfra
         ,ADCrecursiveCoef
         ,ADCiCWP: extended
   ): integer;
{:Purpose: calculate the assembling time. Returns the assembling time in hours (int).
    Additions:
      -2011Sep11- *code audit:
                  (x)var formatting + refactoring     (N)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                  (x)float local variables=> extended (N)case..of reformatting   (N)local methods
      -2011Sep10- *add: increment the duration to 1 hour in all cases to prevent a real duration less than 1 hr due to the game flow.
      -2011Jun12- *add: take the case if result=0;
}
   var
      ADCcoef: extended;
begin
   Result:=0;
   ADCcoef:= ( ( power( ( ( ADCtotalVolInfra*ADCrecursiveCoef )/0.003 ), 0.333 ) ) / power( ADCiCWP,0.333 ) ) *0.5;
	Result:=round( power ( ADCcoef, 2.5 )*0.5 )+1;
   if Result=1
   then Result:=2;
end;

function FCFgICS_BuildingDuration_Calculation(
   const BDCtotalVolMaterial
         ,BDCrecursiveCoef
         ,BDCiCWP
         ,BDCemo: extended
   ): integer;
{:Purpose: calculate the building time. Returns the building time in hours (int).
    Additions:
      -2011Sep11- *code audit:
                  (x)var formatting + refactoring     (N)if..then reformatting   (x)function/procedure refactoring
                  (N)parameters refactoring           (x) ()reformatting         (N)code optimizations
                  (x)float local variables=> extended (-)case..of reformatting   (N)local methods
      -2011Sep10- *add: increment the duration to 1 hour in all cases to prevent a real duration less than 1 hr due to the game flow.
}
   var
      BDCcoef: extended;
begin
   Result:=0;
   BDCcoef:= ( power( ( ( BDCtotalVolMaterial*BDCrecursiveCoef )/0.003 ), 0.333)  + BDCemo ) / power( BDCiCWP,0.333 );
	Result:=round( power( BDCcoef, 2.5 )*0.5 )+1;
   if Result=1
   then Result:=2;
end;

function FCFgICS_iCWP_Calculation(
	const ICWPCent
   		,ICWPCcol
   		,ICWPCinfraLevel: integer
   ): extended;
{:Purpose: calculate the iCWP for a given infrastructure level to assemble/build. Returns the iCWP formatted x.x.
    Additions:
      -2011Sep11- *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (N)parameters refactoring           (x) ()reformatting         (x)code optimizations
                  (x)float local variables=> extended (N)case..of reformatting   (N)local methods
      -2011Jun07- *fix: forgot to put the case when the CAB queue is empty (throw an exception).
}
   var
      ICWPCinfraIndex
      ,ICWPCsettCnt
      ,ICWPCsettIdxCnt
      ,ICWPCsettIdxMax
      ,ICWPCsettMax
      ,ICWPCsumLvl: integer;

      ICWPCdivider
      ,ICWPCicwp: extended;
begin
	Result:=0;
   ICWPCsettMax:=length( FCentities[ICWPCent].E_col[ICWPCcol].C_cabQueue )-1;
   ICWPCsettCnt:=1;
   ICWPCsumLvl:=0;
   while ICWPCsettCnt<=ICWPCsettMax do
   begin
      ICWPCsettIdxMax:=Length( FCentities[ICWPCent].E_col[ICWPCcol].C_cabQueue[ICWPCsettCnt] )-1;
      if ICWPCsettIdxMax>0 then
      begin
         ICWPCsettIdxCnt:=1;
         while ICWPCsettIdxCnt<=ICWPCsettIdxMax do
         begin
            ICWPCinfraIndex:=FCentities[ICWPCent].E_col[ICWPCcol].C_cabQueue[ICWPCsettCnt, ICWPCsettIdxCnt];
            if FCentities[ICWPCent].E_col[ICWPCcol].C_settlements[ICWPCsettCnt].S_infrastructures[ICWPCinfraIndex].I_status<>isInConversion
            then ICWPCsumLvl:=ICWPCsumLvl+FCentities[ICWPCent].E_col[ICWPCcol].C_settlements[ICWPCsettCnt].S_infrastructures[ICWPCinfraIndex].I_level;
            inc( ICWPCsettIdxCnt );
         end;
      end;
      inc( ICWPCsettCnt );
   end;
   if ICWPCsumLvl=0
   then ICWPCicwp:=FCentities[ICWPCent].E_col[ICWPCcol].C_population.CP_CWPtotal
   else if ICWPCsumLvl>0 then
   begin
      ICWPCdivider:=ln( ICWPCsumLvl+1 ) / ln( ICWPCinfraLevel+1 );
      ICWPCicwp:=FCFcFunc_Rnd( cfrttp1dec, FCentities[ICWPCent].E_col[ICWPCcol].C_population.CP_CWPtotal/ICWPCdivider );
   end;
   Result:=ICWPCicwp;
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

function FCFgICS_RecursiveCoef_Calculation(const RCCdoneTime, RCCinitTime: integer): extended;
{:Purpose: calculate the recursive coefficient of a given assembling/building.
    Additions:
}
var
   RCCcoef: extended;
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
      -2012Jan04- *add: initialize power consumption / generation by custom effect.
      -2011Dec22- *mod: update the interface refresh by using the link to the new routine.
      -2011Dec01- *add: update the resource spot requirement if needed.
      -2011Sep21- *rem: moved function initalization to the assembling/building post-process.
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
   	APinfraIndex: integer;

      APclonedInfra: TFCRdipInfrastructure;
begin
   APinfraIndex:=length(FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures);
   SetLength(FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures, APinfraIndex+1);
   APclonedInfra:=FCFgI_DataStructure_Get(
      APent
      ,APcol
      ,APinfraToken
      );
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_token:=APclonedInfra.I_token;
	FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_level:=FCFgICS_InfraLevel_Setup(
   	APclonedInfra.I_minLevel
      ,APclonedInfra.I_maxLevel
      ,FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_level
      );
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_status:=isInAssembling;
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_function:=APclonedInfra.I_function;
	FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_cabDuration:=APduration;
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_cabWorked:=0;
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_powerConsumption:=0;
   FCentities[APent].E_col[APcol].C_settlements[APsettlement].S_infrastructures[APinfraIndex].I_powerGeneratedFromCustomEffect:=0;
   FCMgICS_CAB_Add(
      APent
      ,APcol
      ,APsettlement
      ,APinfraIndex
      );
   {.update the resource spot data if the infrastructure's requirement have one}
   if APclonedInfra.I_reqResourceSpot>rstNone
   then FCMgPRS_SurveyedRsrcSpot_AssignInfra(
      APent
      ,APcol
      ,APsettlement
      ,APinfraIndex
      ,APclonedInfra
      );
   {.remove the infrastructure kit which correspond to the infrastructure}
   FCFgC_Storage_Update(
      FCEntities[APent].E_col[APcol].C_storedProducts[APinfraKitInStorage].SP_token
      ,-1
      ,APent
      ,APcol
      ,false
      );
   if APent=0
   then FCMuiCDD_Production_Update(
      plInfrastructuresInit
      ,APcol
      ,APsettlement
      ,0
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
      -2011Jan11- *fix: correction in the calculations in the main loop.
      -2012Jan04- *add: initialize power consumption / generation by custom effect.
      -2011Dec22- *mod: update the interface refresh by using the link to the new routine.
      -2011Dec14- *add: remove the required construction materials from the colony's storage.
      -2011Dec01- *add: update the resource spot requirement if needed.
      -2011Sep21- *rem: moved function initalization to the assembling/building post-process.
      -2011Jul05- *add/fix: forgot to update the CAB queue list !
      -2011Jun26- *add: initialize the infrastructure functions in a separate method.
}
   var
      BPcount
      ,BPinfraIndex
      ,BPmax: integer;

      BPresultUnits: extended;

      BPcurrentMatVol
      ,BPtempMatVol: extended;

      BPclonedInfra: TFCRdipInfrastructure;
begin
   if Length(FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures)<2
   then setLength(FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures, 2)
   else SetLength(FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures, length(FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures)+1);
   BPinfraIndex:=length(FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures)-1;
   BPclonedInfra:=FCFgI_DataStructure_Get(
      BPent
      ,BPcol
      ,BPinfraToken
      );
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_token:=BPclonedInfra.I_token;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_level:=FCFgICS_InfraLevel_Setup(
      BPclonedInfra.I_minLevel
      ,BPclonedInfra.I_maxLevel
      ,FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_level
      );
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_status:=isInBluidingSite;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_function:=BPclonedInfra.I_function;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_cabDuration:=BPduration;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_cabWorked:=0;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_powerConsumption:=0;
   FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_powerGeneratedFromCustomEffect:=0;
   FCMgICS_CAB_Add(
      BPent
      ,BPcol
      ,BPsettlement
      ,BPinfraIndex
      );
   {.update the resource spot data if the infrastructure's requirement have one}
   if BPclonedInfra.I_reqResourceSpot>rstNone
   then FCMgPRS_SurveyedRsrcSpot_AssignInfra(
      BPent
      ,BPcol
      ,BPsettlement
      ,BPinfraIndex
      ,BPclonedInfra
      );
   {.remove the construction materials needed for the building}
   BPcurrentMatVol:=BPclonedInfra.I_materialVolume[ FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_level ];
   BPmax:=length( BPclonedInfra.I_reqConstructionMaterials )-1;
   BPcount:=1;
   while BPcount<=BPmax do
   begin
      BPtempMatVol:=BPclonedInfra.I_materialVolume[ FCentities[BPent].E_col[BPcol].C_settlements[BPsettlement].S_infrastructures[BPinfraIndex].I_level ]*( BPclonedInfra.I_reqConstructionMaterials[ BPcount ].RCM_partOfMaterialVolume*0.01 );
      BPtempMatVol:=FCFcFunc_Rnd( cfrttpVolm3, BPtempMatVol );
      BPresultUnits:=FCFgP_UnitFromVolume_Get( BPclonedInfra.I_reqConstructionMaterials[ BPcount ].RCM_token, BPtempMatVol );
      BPcurrentMatVol:=BPcurrentMatVol-BPtempMatVol;
      FCFgC_Storage_Update(
         BPclonedInfra.I_reqConstructionMaterials[ BPcount ].RCM_token
         ,-BPresultUnits
         ,BPent
         ,BPcol
         ,true
         );
      inc( BPcount );
   end;
   if BPent=0
   then FCMuiCDD_Production_Update(
      plInfrastructuresInit
      ,BPcol
      ,BPsettlement
      ,0
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
   CABAlen:=length(FCentities[CABAent].E_col[CABAcol].C_cabQueue[CABAsettlement]);
   if CABAlen<1
   then
   begin
      SetLength(FCentities[CABAent].E_col[CABAcol].C_cabQueue[CABAsettlement], 2);
      CABAlen:=1;
   end
   else if CABAlen>=1
   then SetLength(FCentities[CABAent].E_col[CABAcol].C_cabQueue[CABAsettlement], CABAlen+1);
   CABAcnt:=CABAlen;
   FCentities[CABAent].E_col[CABAcol].C_cabQueue[CABAsettlement, CABAcnt]:=CABAinfra;
end;

procedure FCMgICS_CAB_Cleanup(
   const CABCent
         ,CABCcol: integer
   );
{:Purpose: cleanup the CAB queue of a colony, useless CAB entries are removed.
    Additions:
      -2011Sep10- *fix: remove the useless copy command between the regular data structure and the clone, fix a bug.
}
   var
      CABCidxCnt
      ,CABCidxMax
      ,CABCindexClone
      ,CABCsettleCnt
      ,CABCsettleMax: integer;

      CABCcabQueueClone: TFCRdgColony;

begin
   CABCcabQueueClone.C_cabQueue:=nil;
   CABCsettleMax:=length( FCentities[CABCent].E_col[CABCcol].C_cabQueue )-1;
   setlength( CABCcabQueueClone.C_cabQueue, CABCsettleMax+1 );
   if CABCsettleMax>0 then
   begin
      CABCsettleCnt:=1;
      while CABCsettleCnt<=CABCsettleMax do
      begin
         CABCidxMax:=length( FCentities[CABCent].E_col[CABCcol].C_cabQueue[CABCsettleCnt] )-1;
         if CABCidxMax>0 then
         begin
            setlength( CABCcabQueueClone.C_cabQueue[CABCsettleCnt], 1 );
            CABCindexClone:=0;
            CABCidxCnt:=1;
            while CABCidxCnt<=CABCidxMax do
            begin
               if FCentities[CABCent].E_col[CABCcol].C_cabQueue[CABCsettleCnt, CABCidxCnt]>0 then
               begin
                  inc(CABCindexClone);
                  setlength( CABCcabQueueClone.C_cabQueue[CABCsettleCnt], CABCindexClone+1 );
                  CABCcabQueueClone.C_cabQueue[CABCsettleCnt, CABCindexClone]:=FCentities[CABCent].E_col[CABCcol].C_cabQueue[CABCsettleCnt, CABCidxCnt];
               end;
               inc( CABCidxCnt );
            end;
         end;
         inc( CABCsettleCnt );
      end;
   end;
   SetLength(FCentities[CABCent].E_col[CABCcol].C_cabQueue, 0);
   FCentities[CABCent].E_col[CABCcol].C_cabQueue:=CABCcabQueueClone.C_cabQueue;
end;

procedure FCMgICS_Conversion_PostProcess(
   const ICPPent
         ,ICPPcol
         ,ICPPsettlement
         ,ICPPinfra
         ,ICPPcabQueueIndex: integer
   );
{:Purpose: conversion post-process.
    Additions:
      -2011Sep09- *add: routine completion.
}
begin
   FCentities[ICPPent].E_col[ICPPcol].C_settlements[ICPPsettlement].S_infrastructures[ICPPinfra].I_status:=isOperational;
   FCentities[ICPPent].E_col[ICPPcol].C_cabQueue[ICPPsettlement, ICPPcabQueueIndex]:=0;
end;

procedure FCMgICS_Conversion_Process(
   const ICPent
         ,ICPspu
         ,ICPcol
         ,ICPsettlement: integer
   );
{:Purpose: convert a space unit to a corresponding infrastructure as requested.
    Additions:
      -2012Apr16- *add: new hardcoded resource added to the colony: water, oxygen and some food for reserves development and testing.
      -2012Mar13- *mod: adjust some hardcoded data.
      -2012Feb15- *mod: adjust the energy generation of the hardcoded data.
                  *add: hardcoded product, add 1 infrastructure kit: Multipurpose Depot Level 1 by colonization pod.
      -2012Jan11- *fix: raise the max storage capacity to avoid errors.
      -2012Jan04- *add: initialize power consumption / generation by custom effect.
      -2011Dec22- *mod: update the interface refresh by using the link to the new routine.
      -2011Oct30- *add: hardcoded product: Mining Machinery.
      -2011Sep10- *add: increment the duration to 1 hour in all cases to prevent a real duration less than 1 hr due to the game flow.
      -2011Jul24- *add: update the colony data panel with the infrastructures list if it's needed.
      -2011Jul17- *add: harcoded custom effects: energy generation and storage.
      -2011Jul14- *rem: remove the HQ setting to an outside method, will be set by the custom effects processing.
                  *code: some parts are reorganized.
                  *mod: storage is now initialized in custom effects application routines.
      -2011Jul13- *add: infrastructure power consumption.
      -2011Jul12- *add: initialize the energy data according to the conversion rule.
      -2011May15- *mod: change in the infrastructure level calculation, according to the rule change in the design document.
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
   ,ICPvol: integer;

   ICPx: extended;

   ICPclonedInfra: TFCRdipInfrastructure;
begin
   {:DEV NOTES: colonization equipment module will be taken in consideration in the future, for now i use hardcoded data.}
   SetLength(FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures, length(FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures)+1);
   ICPinfra:=length(FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures)-1;
   ICPclonedInfra:=FCFgI_DataStructure_Get(
      ICPent
      ,ICPcol
      ,'infrColShelt'
      );
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_token:=ICPclonedInfra.I_token;

   {:DEV NOTES: transfer the colonization equipment module volume to the prive variable infra volume.
      surface is equals to power(EMvolume; 0.333)^2
      for now, only fixed default values are given
      crew is also hardcoded but will be take from the owned current crew in the future
   }
   ICPvol:=12867;
   ICPsurf:=round(sqr(power(ICPvol,0.333)));
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_level:=1;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_status:=isInConversion;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_function:=fHousing;
   {:DEV NOTES: hardcoded value for population capacity and quality of life data, will be dynamic in the future.}
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_fHousPopulationCapacity:=30;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_fHousQualityOfLife:=1;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_fHousCalculatedVolume:=ICPvol;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_fHousCalculatedSurface:=ICPsurf;
   {:DEV NOTES: for pcap, don'T forget to update the different types according to the population of the colonization module and also the crew.}
   FCMgCSM_ColonyData_Upd(
      dPCAP
      ,ICPent
      ,ICPcol
      ,FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_fHousPopulationCapacity
      ,0
      ,gcsmptNone
      ,false
      );
   FCMgCSM_ColonyData_Upd(
      dQOL
      ,ICPent
      ,ICPcol
      ,0
      ,0
      ,gcsmptNone
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      dPopulation
      ,ICPent
      ,ICPcol
      ,20
      ,25.3
      ,gcsmptColon
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      dPopulation
      ,ICPent
      ,ICPcol
      ,8
      ,25.3
      ,gcsmptIStech
      ,true
      );
   FCMgCSM_ColonyData_Upd(
      dPopulation
      ,ICPent
      ,ICPcol
      ,2
      ,25.3
      ,gcsmptMSsold
      ,true
      );
   {.conversion calculations, the crew is hardcoded for now}
   ICPx:=sqrt( ICPvol*0.2 ) / (30+5);//x = [ SQRT(TCMV / 5) ] / PC
   ICPduration:=round(power(ICPx, 2.5)*0.5)+1;//duration (in hrs) = (x^2.5)/2 rounded
   if ICPduration=1
   then ICPduration:=2;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_cabDuration:=ICPduration;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_cabWorked:=0;
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
   setlength(ICPclonedInfra.I_customEffectStructure, length(ICPclonedInfra.I_customEffectStructure)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customEffectStructure)-1;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_customEffect:=ceProductStorage;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_cePSstorageByLevel[FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_level].SBL_solid:=200;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_cePSstorageByLevel[FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_level].SBL_liquid:=210;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_cePSstorageByLevel[FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_level].SBL_gas:=30;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_cePSstorageByLevel[FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_level].SBL_biologic:=30;
   setlength(ICPclonedInfra.I_customEffectStructure, length(ICPclonedInfra.I_customEffectStructure)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customEffectStructure)-1;
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_powerGeneratedFromCustomEffect:=0;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_customEffect:=ceEnergyGeneration;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_ceEGmode.EGM_modes:=egmPhoton;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_ceEGmode.EGM_mParea:=10;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_ceEGmode.EGM_mPefficiency:=70;
   setlength(ICPclonedInfra.I_customEffectStructure, length(ICPclonedInfra.I_customEffectStructure)+1);
   ICPeffectIdx:=length(ICPclonedInfra.I_customEffectStructure)-1;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_customEffect:=ceEnergyStorage;
   ICPclonedInfra.I_customEffectStructure[ICPeffectIdx].ICFX_ceEScapacitiesByLevel[1]:=20;
   FCMgICFX_Effects_Application(
      ICPent
      ,ICPcol
      ,ICPsettlement
      ,ICPinfra
      ,ICPclonedInfra
      );
//   FCMspuF_SpUnit_Remove(ICPent, ICPspu);
   {:DEV NOTES: energy consumption-generation-storage data will be calculated from the space unit's design.}
   {:DEV NOTES: for now it's simply hardcoded.}
   FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_powerConsumption:=5;
   FCMgCSM_Energy_Update(
      ICPent
      ,ICPcol
      ,false
      ,FCentities[ICPent].E_col[ICPcol].C_settlements[ICPsettlement].S_infrastructures[ICPinfra].I_powerConsumption
      ,0
      ,0
      ,0
      );
   if (ICPinfra=2)
      or (ICPinfra=4)
   then FCFgC_Storage_Update(
      'energNucFisReactor1'
      ,1
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'equipMultiDepot1'
      ,1
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'equipHandTools'
      ,10
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'equipPowerTools'
      ,10
      ,0
      ,ICPcol
      ,false
      );
   if (ICPinfra=2)
      or (ICPinfra=4)
   then FCFgC_Storage_Update(
      'equipPressTanksArr1'
      ,1
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'equipConstrExo'
      ,1
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'equipMiningMachinery'
      ,1
      ,0
      ,ICPcol
      ,false
      );
   FCFgC_Storage_Update(
      'resWater'
      ,200
      ,0
      ,ICPcol
      ,true
      );
   FCFgC_Storage_Update(
      'resO2'
      ,20
      ,0
      ,ICPcol
      ,true
      );
   FCFgC_Storage_Update(
      'bioFish'
      ,20
      ,0
      ,ICPcol
      ,true
      );
   FCFgC_Storage_Update(
      'bioFruitsVeg'
      ,20
      ,0
      ,ICPcol
      ,true
      );
   if ICPent=0
   then FCMuiCDD_Production_Update(
      plInfrastructuresInit
      ,ICPcol
      ,ICPsettlement
      ,0
      );
end;

procedure FCMgICS_TransitionRule_Process(
   const TRPent
         ,TRPcol
         ,TRPsettlement
         ,TRPownInfra
         ,TRPcabIdx: integer;
         TRPincludeStaffTest: boolean
   );
{:Purpose: process the transition rule, considering that staff requirements are fufilled.
   Additions:
      -2011Oct26- *add: add a condition for production infrastructure case to prevent them to be in transition in a infinite loop.
      -2011Oct03- *add: add the possibility to call the routine with the cabIdx at 0. Used for re-enabling infrastructures.
}
   var
      TRPstaff: TFCRdgColonyPopulation;

      TRPinfraData: TFCRdipInfrastructure;

   procedure TRP_ProductionDelay_Process;
   begin
      TRPinfraData:=FCFgI_DataStructure_Get(
         TRPent
         ,TRPcol
         ,FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_token
         );
      if (TRPinfraData.I_function=fProduction)
         and (FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabWorked>-1) then
      begin
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_status:=isInTransition;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabDuration:=FCCdipTransitionTime;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabWorked:=-1;
         if TRPcabIdx=0
         then FCMgICS_CAB_Add(
            TRPent
            ,TRPcol
            ,TRPsettlement
            ,TRPownInfra
            );
      end
      else
      begin
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_status:=isOperational;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabDuration:=0;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabWorked:=0;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_powerConsumption
            :=TRPinfraData.I_basePower[FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_level];
         FCMgCSM_Energy_Update(
            TRPent
            ,TRPcol
            ,false
            ,FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_powerConsumption
            ,0
            ,0
            ,0
            );
         if TRPcabIdx>0
         then FCentities[TRPent].E_col[TRPcol].C_cabQueue[TRPsettlement, TRPcabIdx]:=0;
         FCMgIF_Functions_Initialize(
            TRPent
            ,TRPcol
            ,TRPsettlement
            ,TRPownInfra
            ,TRPinfraData
            );
         FCMgIF_Functions_ApplicationRemove(
            TRPent
            ,TRPcol
            ,TRPsettlement
            ,TRPownInfra
            ,true
            );
         FCMgICFX_Effects_Application(
            TRPent
            ,TRPcol
            ,TRPsettlement
            ,TRPownInfra
            ,TRPinfraData
            );
      end;
   end;

begin
   if TRPincludeStaffTest then
   begin
      TRPstaff:=FCFgIS_RequiredStaff_Test(
         TRPent
         ,TRPcol
         ,TRPsettlement
         ,TRPownInfra
         ,true
         );
      if TRPstaff.CP_total=0
      then TRP_ProductionDelay_Process
      else if TRPstaff.CP_total>0 then
      begin
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_status:=isInTransition;
         FCentities[TRPent].E_col[TRPcol].C_settlements[TRPsettlement].S_infrastructures[TRPownInfra].I_cabDuration:=-1;
         if TRPcabIdx=0
         then FCMgICS_CAB_Add(
            TRPent
            ,TRPcol
            ,TRPsettlement
            ,TRPownInfra
            );
      end;
   end
   else if not TRPincludeStaffTest
   then TRP_ProductionDelay_Process;
end;
   
end.
