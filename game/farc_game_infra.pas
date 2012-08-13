{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - core unit

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

unit farc_game_infra;

interface

uses
   Math
   ,SysUtils

   ,farc_data_game
   ,farc_data_init
   ,farc_data_infrprod
   ,farc_data_univ;

///<summary>
///   get the infrastructure function token string
///</summary>
///   <param name="functionType">infrastructure type</param>
///   <returns>infrastructure function token string</returns>
function FCFgI_Function_GetToken( const FunctionType: TFCEdipFunctions ): string;

///<summary>
///   retrieve the index in a function list for an owned infrastructure
///</summary>
///   <param name="entity">entity index #</param>
///   <param name="colony">colony index #</param>
///   <param name="Settlement">settlement index #</param>
///   <param name="OwnedInfra">owned infrastructure owned index #</param>
///   <returns>return the index in the category, for ex. the infrastructure #12 (function= Energy) is the #3 in the function's index</returns>
function FCFgI_IndexInFunction_Retrieve(
   const Entity
         ,Colony
         ,Settlement
         ,OwnedInfra: integer
   ): integer;

///<summary>
///   get the requested infrastructure data
///</summary>
///   <param name="entity">entity index #</param>
///   <param name="colony">colony index #</param>
///   <param name="infraToken">token id of the requested infrastructure</param>
///   <returns>the requested infrastructure data (taken in the database)</returns>
function FCFgI_DataStructure_Get(
   const Entity
         ,Colony: integer;
   const InfraToken: string
   ): TFCRdipInfrastructure;

///<summary>
///   return the token of a given infrastructure status
///</summary>
///   <param name="SGTstatus">infrastructure status</param>
function FCFgInf_Status_GetToken(const SGTstatus: TFCEdgInfrastructureStatus): string;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   infrastructure disabling rule
///</summary>
///   <param name="DPent">entity index #</param>
///   <param name="DPcol">colony index #</param>
///   <param name="DPset">settlement index #</param>
///   <param name="DPinf">infrastructure index #</param>
///   <param name="DPisByEnergyEq">true= the infrastructure is disabled according to energy equilibrium/infrastructure disabling rules</param>
procedure FCMgInf_Disabling_Process(
   const DPent
         ,DPcol
         ,DPset
         ,DPinf: integer;
   const DPisByEnergyEq: boolean
   );

///<summary>
///   infrastructure enabling rule
///</summary>
///   <param name="EPent">entity index #</param>
///   <param name="EPcol">colony index #</param>
///   <param name="EPset">settlement index #</param>
///   <param name="EPinf">infrastructure index #</param>
procedure FCMgInf_Enabling_Process(
   const EPent
         ,EPcol
         ,EPset
         ,EPinf: integer
   );

implementation

uses
   farc_game_colony
   ,farc_game_csm
   ,farc_game_infraconsys
   ,farc_game_infracustomfx
   ,farc_game_infrafunctions
   ,farc_game_infrastaff
   ,farc_univ_func;

//===================================END OF INIT============================================

function FCFgI_Function_GetToken( const FunctionType: TFCEdipFunctions ): string;
{:Purpose: get the infrastructure function token string.
   Additions:
      -2011Dec20- *code audit:
                  (_)var formatting + refactoring     (_)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (_)code optimizations
                  (_)float local variables=> extended (x)case..of reformatting   (_)local methods
                  (x)summary completion
      -2011Mar07- *add: converted housing.
}
begin
   case FunctionType of
      fHousing: Result:='infrahousingicn';

      fProduction: Result:='infraprodicn';
   end;
end;

function FCFgI_IndexInFunction_Retrieve(
   const Entity
         ,Colony
         ,Settlement
         ,OwnedInfra: integer
   ): integer;
{:Purpose: retrieve the index in a function list for an owned infrastructure.
    Additions:
}
   var
      Count
      ,Max
      ,SubIndex: integer;

      FunctionToSearch: TFCEdipFunctions;
begin
   Result:=0;
   Max:=length( FCEntities[ Entity ].E_col[ Colony ].C_settlements[ Settlement ].S_infrastructures )-1;
   SubIndex:=0;
   FunctionToSearch:=FCEntities[ Entity ].E_col[ Colony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfra ].I_function;
   Count:=1;
   while Count<=Max do
   begin
      if FCEntities[ Entity ].E_col[ Colony ].C_settlements[ Settlement ].S_infrastructures[ Count ].I_function=FunctionToSearch then
      begin
         inc( SubIndex );
         if Count=OwnedInfra then
         begin
            Result:=SubIndex;
            break;
         end;
      end;
      inc( Count );
   end;
end;

function FCFgI_DataStructure_Get(
   const Entity
         ,Colony: integer;
   const InfraToken: string
   ): TFCRdipInfrastructure;
{:Purpose: get the requested infrastructure data.
    Additions:
      -2011Dec20- *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (_)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                  (x)summary completion
      -2011Sep11- *add: the environment is now directly processed inside this function, not outside. Allow to remove many duplicated code.
                  *add: entity/colony parameters.
      -2011May06- *fix: take in account the ANY environment.
      -2011Mar07- *add: environment type parameter for getting the right infrastructure.
      -2011Feb21- *mod: initialize the infrastructure token with 'ERROR!' by default to put an error message in case of problem.
      -2010May30- *fix: when the right data structure is found the function doesn't exit, instead the flow is broke.
}
   var
      Count
      ,Max: integer;

      Environment: TFCRgcEnvironment;
begin
   Environment:=FCFgC_ColEnv_GetTp( Entity, Colony );
   Count:=1;
   Max:=high( FCDdipInfrastructures );
   Result.I_token:='ERROR';
   while Count<=Max do
   begin
      if (FCDdipInfrastructures[ Count ].I_token=InfraToken )
         and ( ( FCDdipInfrastructures[ Count ].I_environment=etAny ) or ( FCDdipInfrastructures[ Count ].I_environment=Environment.ENV_envType ) ) then
      begin
         Result:=FCDdipInfrastructures[ Count ];
         break;
      end;
      inc( Count );
   end;
end;

function FCFgInf_Status_GetToken(const SGTstatus: TFCEdgInfrastructureStatus): string;
{:Purpose: return the token of a given infrastructure status.
    Additions:
      -2011Jul31- *add: istDisabledByEE.
      -2011Apr13- *mod: split CAB tokens and icons.
}
begin
   Result:='';
   case SGTstatus of
      isInKit: Result:='infrastatus_inKit';
      isInConversion: Result:='infrastatus_inConversion';
      isInAssembling: Result:='infrastatus_inAssembling';
      isInBluidingSite: Result:='infrastatus_inBuilding';
      isDisabled: Result:='infrastatus_disabled';
      isDisabledByEnergyEquilibrium: Result:='infrastatus_disabledbyee';
      isInTransition: Result:='infrastatus_inTransition';
      isOperational: Result:='infrastatus_operational';
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgInf_Disabling_Process(
   const DPent
         ,DPcol
         ,DPset
         ,DPinf: integer;
   const DPisByEnergyEq: boolean
   );
{:Purpose: infrastructure disabling rule.
   Additions:
      -2010Oct03- *add: complete the routine by adding function's data remove and staff recover rule.
}
   var
      DPinfraData: TFCRdipInfrastructure;
begin
   DPinfraData:=FCFgI_DataStructure_Get(
      DPent
      ,DPcol
      ,FCentities[DPent].E_col[DPcol].C_settlements[DPset].S_infrastructures[DPinf].I_token
      );
   FCMgCSM_Energy_Update(
      DPent
      ,DPcol
      ,false
      ,-DPinfraData.I_basePower[ FCentities[DPent].E_col[DPcol].C_settlements[DPset].S_infrastructures[DPinf].I_level ]
      ,0
      ,0
      ,0
      );
   FCMgICFX_Effects_Removing(
      DPent
      ,DPcol
      ,DPset
      ,DPinf
      ,DPinfraData
      );
   FCMgIF_Functions_ApplicationRemove(
      DPent
      ,DPcol
      ,DPset
      ,DPinf
      ,false
      );
   if not DPisByEnergyEq then
   begin
      FCentities[DPent].E_col[DPcol].C_settlements[DPset].S_infrastructures[DPinf].I_status:=isDisabled;
      FCMgIS_RequiredStaff_Recover(
         DPent
         ,DPcol
         ,DPset
         ,DPinf
         );
   end
   else FCentities[DPent].E_col[DPcol].C_settlements[DPset].S_infrastructures[DPinf].I_status:=isDisabledByEnergyEquilibrium;
end;

procedure FCMgInf_Enabling_Process(
   const EPent
         ,EPcol
         ,EPset
         ,EPinf: integer
   );
{:Purpose: infrastructure enabling rule.
   Additions:
      -2011Oct03- *add: complete the enabling process by adding the transition rule, and remove useless duplicate code.
      -2011Sep12- *add: infrastructure function data are applied in case of a istDisabledByEE.
}
begin
   if FCentities[EPent].E_col[EPcol].C_settlements[EPset].S_infrastructures[EPinf].I_status=isDisabled
   then FCMgICS_TransitionRule_Process(
      EPent
      ,EPcol
      ,EPset
      ,EPinf
      ,0
      ,true
      )
   else if FCentities[EPent].E_col[EPcol].C_settlements[EPset].S_infrastructures[EPinf].I_status=isDisabledByEnergyEquilibrium
   then FCMgICS_TransitionRule_Process(
      EPent
      ,EPcol
      ,EPset
      ,EPinf
      ,0
      ,false
      );
end;

end.
