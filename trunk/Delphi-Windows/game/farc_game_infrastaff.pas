{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructure staff management

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
unit farc_game_infrastaff;

interface

uses
   farc_data_game;

///<summary>
///   test if a colony can support the required staff of a given owned infrastructure
///</summary>
///   <param name="RSTent">entity index #</param>
///   <param name="RSTcol">colony index #</param>
///   <param name="RSTsett">settlement index #</param>
///   <param name="RSTinfra">owned infrastructure index #</param>
///   <param name="RTSapplyAssignment">if true, and that the requirement is fulfilled, the population is assigned</param>
///   <returns>w/ TFCRdgColonPopulation: POP_total= number of people the colony lack to fulfill the infrastructure's requirement.  POP_tp-type-: store the remaining number of person the colony must have to fulfill the infrastructure's requirement.</returns>
function FCFgIS_RequiredStaff_Test(
   const RSTent
         ,RSTcol
         ,RSTsett
         ,RSTinfra: integer;
   const RTSapplyAssignment: boolean
   ): TFCRdgColonPopulation;

//===========================END FUNCTIONS SECTION==========================================

implementation

//===================================================END OF INIT============================

function FCFgIS_RequiredStaff_Test(
   const RSTent
         ,RSTcol
         ,RSTsett
         ,RSTinfra: integer;
   const RTSapplyAssignment: boolean
   ): TFCRdgColonPopulation;
{:Purpose: test if a colony can support the required staff of a given owned infrastructure.
    Additions:
}
begin
   Result.POP_total:=0;
   Result.POP_tpColon:=0;
   Result.POP_tpASoff:=0;
   Result.POP_tpASmiSp:=0;
   Result.POP_tpBSbio:=0;
   Result.POP_tpBSdoc:=0;
   Result.POP_tpIStech:=0;
   Result.POP_tpISeng:=0;
   Result.POP_tpMSsold:=0;
   Result.POP_tpMScomm:=0;
   Result.POP_tpPSphys:=0;
   Result.POP_tpPSastr:=0;
   Result.POP_tpESecol:=0;
   Result.POP_tpESecof:=0;
   Result.POP_tpAmedian:=0;
   {:DEV NOTES: test infra staff req here.}
   if Result.POP_total=0 then
   begin
      //apply pop assignment here
      //link to production delay w/ boolean returns. if false, no production delay=> data finalization in assembling_finalize
   end
   else if Result.POP_total>0 then
   begin
      FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_status:=istInTransition;
      FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_cabDuration:=-1;
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
