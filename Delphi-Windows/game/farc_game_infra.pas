{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - core unit

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
///   <param name="IFGStype">infrastructure type string</param>
function FCFgInf_Function_GetToken(const IFGStype: TFCEdipFunction): string;

///<summary>
///   get the requested infrastructure
///</summary>
///   <param name="IGDinfToken">token id of the requested infrastructure</param>
function FCFgInf_DataStructure_Get(
   const IGDent
         ,IGDcol: integer;
   const IGDinfToken: string
   ): TFCRdipInfrastructure;

///<summary>
///   initialize a new settlement for a colony, return the new settlement index.
///</summary>
///   <param name=""></param>
///   <param name=""></param>
function FCFgInf_Settlement_Add(
   const SAent
         ,SAcol
         ,SAreg
         ,SAsettleType: integer;
   const SAsettleName: string
   ): integer;

///<summary>
///   get the settlement index# of a given colony's region #
///</summary>
///   <param name=""></param>
///   <param name=""></param>
function FCFgInf_Settlement_GetFromRegion(
   const SGFRent
         ,SGFRcol
         ,SGFRreg: integer
   ): integer;

///<summary>
///   return the token of a given infrastructure status
///</summary>
///   <param name="SGTstatus">infrastructure status</param>
function FCFgInf_Status_GetToken(const SGTstatus: TFCEdgInfStatTp): string;

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
   ,farc_game_infraconsys
   ,farc_game_infracustomfx
   ,farc_game_infrafunctions
   ,farc_game_infrapower
   ,farc_game_infrastaff
   ,farc_univ_func
   {:DEV NOTES: debug, to remove.}
   ,farc_main
   ,farc_win_debug;

//===================================END OF INIT============================================

function FCFgInf_Function_GetToken(const IFGStype: TFCEdipFunction): string;
{:Purpose: get the infrastructure function token string.
   Additions:
      -2011Mar07- *add: converted housing.
}
begin
   case IFGStype of
      fHousing: Result:='infrahousingicn';
      fProduction: Result:='infraprodicn';
   end;
end;

function FCFgInf_DataStructure_Get(
   const IGDent
         ,IGDcol: integer;
   const IGDinfToken: string
   ): TFCRdipInfrastructure;
{:Purpose: get the requested infrastructure.
    Additions:
      -2011Sep11- *add: the environment is now directly processed inside this function, not outside. Allow to remove many duplicated code.
                  *add: entity/colony parameters.
      -2011May06- *fix: take in account the ANY environment.
      -2011Mar07- *add: environment type parameter for getting the right infrastructure.
      -2011Feb21- *mod: initialize the infrastructure token with 'ERROR!' by default to put an error message in case of problem.
      -2010May30- *fix: when the right data structure is found the function doesn't exit, instead the flow is broke.
}
var
   IGDcnt
   ,IGDmax: integer;

   IGDenv: TFCRgcEnvironment;
begin
   IGDenv:=FCFgC_ColEnv_GetTp(IGDent, IGDcol);
   IGDcnt:=1;
   IGDmax:=high(FCDBinfra);
   Result.I_token:='ERROR';
   while IGDcnt<=IGDmax do
   begin
      if (FCDBinfra[IGDcnt].I_token=IGDinfToken)
         and ( (FCDBinfra[IGDcnt].I_environment=envAny) or (FCDBinfra[IGDcnt].I_environment=IGDenv.ENV_envType) )
      then
      begin
         Result:=FCDBinfra[IGDcnt];
         break;
      end;
      inc(IGDcnt);
   end;
end;

function FCFgInf_Settlement_Add(
   const SAent
         ,SAcol
         ,SAreg
         ,SAsettleType: integer;
   const SAsettleName: string
   ): integer;
{:Purpose: initialize a new settlement for a colony.
    Additions:
      -2011Mar09- *add: initialize the corresponding CAB queue range.
      -2011Feb14- *add: set region's settlement data.
}
var
   SAcnt
   ,SAnbSetstart: integer;

   SAret: TFCRufStelObj;
begin
   Result:=0;
   SAcnt:=0;
   SAret[1]:=SAret[0];
   SAret[2]:=SAret[0];
   SAret[3]:=SAret[0];
   SAret[4]:=SAret[0];
   SAret:=FCFuF_StelObj_GetFullRow(
      FCentities[SAent].E_col[SAcol].COL_locSSys
      ,FCentities[SAent].E_col[SAcol].COL_locStar
      ,FCentities[SAent].E_col[SAcol].COL_locOObj
      ,FCentities[SAent].E_col[SAcol].COL_locSat
      );
   SAnbSetstart:=length(FCentities[SAent].E_col[SAcol].COL_settlements);
   if SAnbSetstart<1
   then
   begin
      setlength(FCentities[SAent].E_col[SAcol].COL_settlements, 2);
      SAcnt:=1;
   end
   else if SAnbSetstart>=1
   then
   begin
      setlength(FCentities[SAent].E_col[SAcol].COL_settlements, SAnbSetstart+1);
      SAcnt:=SAnbSetstart;
   end;
   FCentities[SAent].E_col[SAcol].COL_settlements[SAcnt].CS_name:=SAsettleName;
   FCentities[SAent].E_col[SAcol].COL_settlements[SAcnt].CS_type:=TFCEdgSettleType(SAsettleType);
   FCentities[SAent].E_col[SAcol].COL_settlements[SAcnt].CS_level:=1;
   FCentities[SAent].E_col[SAcol].COL_settlements[SAcnt].CS_region:=SAreg;
   setlength(FCentities[SAent].E_col[SAcol].COL_settlements[SAcnt].CS_infra, 1);
        if SAret[4]>0
   then
   begin
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_satList[SAret[4]].OOS_regions[SAreg].OOR_setEnt:=SAent;
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_satList[SAret[4]].OOS_regions[SAreg].OOR_setCol:=SAcol;
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_satList[SAret[4]].OOS_regions[SAreg].OOR_setSet:=SAcnt;
   end
   else
   begin
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_regions[SAreg].OOR_setEnt:=SAent;
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_regions[SAreg].OOR_setCol:=SAcol;
      FCDBsSys[SAret[1]].SS_star[SAret[2]].SDB_obobj[SAret[3]].OO_regions[SAreg].OOR_setSet:=SAcnt;
   end;
   {.update the colony's CAB queue}
   if length(FCentities[SAent].E_col[SAcol].COL_cabQueue)<2
   then SetLength(FCentities[SAent].E_col[SAcol].COL_cabQueue, 2)
   else SetLength(FCentities[SAent].E_col[SAcol].COL_cabQueue, length(FCentities[SAent].E_col[SAcol].COL_cabQueue)+1);
   Result:=SAcnt;
end;

function FCFgInf_Settlement_GetFromRegion(
   const SGFRent
         ,SGFRcol
         ,SGFRreg: integer
   ): integer;
{:Purpose: get the settlement index# of a given colony's region #.
    Additions:
}
var
   SGFRcnt
   ,SGFRmax: integer;
begin
   Result:=0;
   SGFRmax:=length(FCentities[SGFRent].E_col[SGFRcol].COL_settlements)-1;
   if SGFRmax>0
   then
   begin
      SGFRcnt:=1;
      while SGFRcnt<=SGFRmax do
      begin
         if FCentities[SGFRent].E_col[SGFRcol].COL_settlements[SGFRcnt].CS_region=SGFRreg
         then
         begin
            Result:=SGFRcnt;
            break;
         end;
         inc(SGFRcnt);
      end;
   end;
end;

function FCFgInf_Status_GetToken(const SGTstatus: TFCEdgInfStatTp): string;
{:Purpose: return the token of a given infrastructure status.
    Additions:
      -2011Jul31- *add: istDisabledByEE.
      -2011Apr13- *mod: split CAB tokens and icons.
}
begin
   Result:='';
   case SGTstatus of
      istInKit: Result:='infrastatus_inKit';
      istInConversion: Result:='infrastatus_inConversion';
      istInAssembling: Result:='infrastatus_inAssembling';
      istInBldSite: Result:='infrastatus_inBuilding';
      istDisabled: Result:='infrastatus_disabled';
      istDisabledByEE: Result:='infrastatus_disabledbyee';
      istInTransition: Result:='infrastatus_inTransition';
      istOperational: Result:='infrastatus_operational';
      istDestroyed: Result:='infrastatus_destroyed';
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
   DPinfraData:=FCFgInf_DataStructure_Get(
      DPent
      ,DPcol
      ,FCentities[DPent].E_col[DPcol].COL_settlements[DPset].CS_infra[DPinf].CI_dbToken
      );
   FCMgIP_CSMEnergy_Update(
      DPent
      ,DPcol
      ,false
      ,-DPinfraData.I_basePwr[ FCentities[DPent].E_col[DPcol].COL_settlements[DPset].CS_infra[DPinf].CI_level ]
      ,0
      ,0
      ,0
      );
   FCMgICFX_Effects_Removing(
      DPent
      ,DPcol
      ,FCentities[DPent].E_col[DPcol].COL_settlements[DPset].CS_infra[DPinf].CI_level
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
      FCentities[DPent].E_col[DPcol].COL_settlements[DPset].CS_infra[DPinf].CI_status:=istDisabled;
      FCMgIS_RequiredStaff_Recover(
         DPent
         ,DPcol
         ,DPset
         ,DPinf
         );
   end
   else FCentities[DPent].E_col[DPcol].COL_settlements[DPset].CS_infra[DPinf].CI_status:=istDisabledByEE;
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
   if FCentities[EPent].E_col[EPcol].COL_settlements[EPset].CS_infra[EPinf].CI_status=istDisabled
   then FCMgICS_TransitionRule_Process(
      EPent
      ,EPcol
      ,EPset
      ,EPinf
      ,0
      ,true
      )
   else if FCentities[EPent].E_col[EPcol].COL_settlements[EPset].CS_infra[EPinf].CI_status=istDisabledByEE
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
