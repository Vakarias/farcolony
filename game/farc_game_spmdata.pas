{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: SocioPolitical Matrix (SPM) - faction data management unit

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

unit farc_game_spmdata;

interface

uses
   SysUtils

   ,farc_data_game;

type TFCEgspmdDatTp=(
   gspmdStability
   ,gspmdInstruction
   ,gspmdLifeQual
   ,gspmdEconIndusOutput
   ,gspmdEquilibrium
   ,gmspmdPopulation
   );

type TFCEgspmdRules=(
   gmspmdCanChangeEcoSys
   ,gmspmdCanChangeGvt
   ,gmspmdCanChangeHealth
   ,gmspmdCanChangeRelig
   ,gmspmdCanEnfPolicies
   );

///<summary>
///   initialize the bureaucracy data
///</summary>
///   <param name="BIent">entity index #</param>
function FCFgSPMD_Bureaucracy_Init(const BIent: integer): integer;

///<summary>
///   initialize the corruption data
///</summary>
///   <param name="CIent">entity index #</param>
function FCFgSPMD_Corruption_Init(const CIent: integer): integer;

///<summary>
///   retrieve a selected faction data
///</summary>
///   <param name="GDGdType">data type to gather</param>
///   <param name="GDGfacIdx">faction index #</param>
function FCFgSPMD_GlobalData_Get(
   const GDGdType: TFCEgspmdDatTp;
   const GDGfacIdx: integer
   ): integer;

///<summary>
///   retrieve the status level token
///</summary>
///   <param name="LGTlevel">status level</param>
function FCFgSPMD_Level_GetToken(const LGTlevel: TFCEdgPlayerFactionStatus): string;

///<summary>
///   centralize all player's faction status rules, return true/false in response of a rule
///</summary>
///   <param name="PSARaskIf">gmspmdCanChangeGvt: if the player can change gvt, gmspmdCanEnfPolicies: if the player can enforce policies</param>
function FCFgSPMD_PlyrStatus_ApplyRules(const PSARaskIf: TFCEgspmdRules): boolean;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update the faction level determination of a chosen entity
///</summary>
///   <param name="LUent">entity #</param>
procedure FCMgSPMD_Level_Upd(const LUent: integer);

implementation

uses
   farc_game_csm
   ,farc_ui_umi;

//===================================================END OF INIT============================

function FCFgSPMD_Bureaucracy_Init(const BIent: integer): integer;
{:Purpose: initialize the bureaucracy data.
    Additions:
}
begin
   Result:=50+FCentities[BIent].E_spmMBur;
end;

function FCFgSPMD_Corruption_Init(const CIent: integer): integer;
{:Purpose: initialize the corruption data.
    Additions:
}
begin
   Result:=FCentities[CIent].E_spmMCorr;
end;

function FCFgSPMD_GlobalData_Get(
   const GDGdType: TFCEgspmdDatTp;
   const GDGfacIdx: integer
   ): integer;
{:Purpose: retrieve a selected faction data.
    Additions:
      -2011Aug11- *add: faction's economic & industrial ouput.
      -2010nov09- *add: total population, w/ gmspmdPopulation switch.
      -2010Nov02- *add: life quality and equilibrium calculations.
                  *mod: optimize the code for apply only one 'case of'.
      -2010Nov01- *code moved in spmdata.
      -2010Oct14- *code cleanup.
                  *add: the case w/ 0 colony (doesn't trigger the loop).
      -2010Sep14- *add: entities code.
      -2010Aug02- *add: instruction.
                  *add: multiple types case + faction.
}
var
   GDGcnt
   ,GDGdmpRes
   ,GDGmax
   ,GDGsec
   ,GDGtens: integer;
begin
   Result:=0;
   GDGdmpRes:=0;
   GDGsec:=0;
   GDGtens:=0;
   GDGmax:=length(FCentities[GDGfacIdx].E_col)-1;
   if GDGmax>0
   then
   begin
      GDGcnt:=1;
      case GDGdType of
         gspmdStability:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGdmpRes:=GDGdmpRes+FCentities[GDGfacIdx].E_col[GDGcnt].COL_cohes;
               inc(GDGcnt);
            end;
         end;

         gspmdInstruction:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGdmpRes:=GDGdmpRes+FCentities[GDGfacIdx].E_col[GDGcnt].COL_edu;
               inc(GDGcnt);
            end;
         end;

         gspmdLifeQual:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGdmpRes:=GDGdmpRes+round(FCentities[GDGfacIdx].E_col[GDGcnt].COL_csmHOqol*FCentities[GDGfacIdx].E_col[GDGcnt].COL_csmHOspl);
               inc(GDGcnt);
            end;
         end;

         gspmdEconIndusOutput:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGdmpRes:=GDGdmpRes+FCentities[GDGfacIdx].E_col[GDGcnt].COL_eiOut;
               inc( GDGcnt );
            end;
         end;

         gspmdEquilibrium:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGtens:=StrToInt(FCFgCSM_Tension_GetIdx(GDGfacIdx, GDGcnt, true));
               GDGsec:=StrToInt(FCFgCSM_Security_GetIdxStr(GDGfacIdx, GDGcnt, true));
               GDGdmpRes:=GDGdmpRes+(GDGsec-GDGtens);
               inc(GDGcnt);
            end;
         end;

         gmspmdPopulation:
         begin
            while GDGcnt<=GDGmax do
            begin
               GDGdmpRes:=GDGdmpRes+FCentities[GDGfacIdx].E_col[GDGcnt].COL_population.POP_total;
               inc(GDGcnt);
            end;
         end;
      end; //==END== case GDGdType of ==//
      Result:=round(GDGdmpRes/GDGmax);
   end; //==END== if GDGmax>0 ==//
end;

function FCFgSPMD_Level_GetToken(const LGTlevel: TFCEdgPlayerFactionStatus): string;
{:Purpose: retrieve the status level token.
    Additions:
}
begin
   Result:='';
   case LGTlevel of
      pfs0_NotViable: Result:='cpsStatNV';
      pfs1_FullyDependent: Result:='cpsStatFD';
      pfs2_SemiDependent: Result:='cpsStatSD';
      pfs3_Independent: Result:='cpsStatFI';
   end;
end;

function FCFgSPMD_PlyrStatus_ApplyRules(const PSARaskIf: TFCEgspmdRules): boolean;
{:Purpose: centralize all player's faction status rules, return true/false in response of a rule.
    Additions:
      -2011Jan10- *add: CanChangeEcoSys, CanChangeGvt, CanChangeHealth, CanChangeRelig, CanEnfPolicies rules.
}
var
   PSARres: boolean;
begin
   PSARres:=false;
   case PSARaskIf of
      gmspmdCanChangeEcoSys:
      begin
         if FCRplayer.P_ecoStat=pfs3_Independent
         then PSARres:=true;
      end;
      gmspmdCanChangeGvt, gmspmdCanChangeHealth, gmspmdCanChangeRelig:
      begin
         if FCRplayer.P_socStat=pfs3_Independent
         then PSARres:=true;
      end;
      gmspmdCanEnfPolicies:
      begin
         if FCRplayer.P_socStat>=pfs2_SemiDependent
         then PSARres:=true;
      end;
   end;
   Result:=PSARres;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgSPMD_Level_Upd(const LUent: integer);
{:Purpose: update the faction level determination of a chosen entity.
    Additions:
      -2010Dec21- *add: update the UMI/Faction if needed.
}
var
   LUcnt
   ,LUlevel
   ,LUmax: integer;

   LUrootSS: string;

   LUisScattered: boolean;
begin
   LUlevel:=0;
   LUisScattered:=false;
   LUrootSS:='';
   {:DEV NOTES: here will be implemented the control test subroutine for know how much star system are controlled, if there's any.}
   {.no star system control}
   LUmax:=length(FCentities[LUent].E_col)-1;
   if LUmax>0
   then
   begin
      if LUmax=1
      then LUlevel:=1
      else
      begin
         LUcnt:=1;
         while LUcnt<LUmax do
         begin
            if LUcnt=1
            then LUrootSS:=FCentities[LUent].E_col[LUcnt].COL_locStar
            else
            begin
               if (not LUisScattered)
                  and (FCentities[LUent].E_col[LUcnt].COL_locStar<>LUrootSS)
               then
               begin
                  LUisScattered:=true;
                  break;
               end;
            end;
            inc(LUcnt);
         end;
         if LUisScattered
         then LUlevel:=3
         else LUlevel:=2;
      end;
   end;
   FCentities[LUent].E_facLvl:=LUlevel;
   FCMumi_Main_Upd;
end;

end.
