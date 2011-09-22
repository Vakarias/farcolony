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

uses

   farc_data_infrprod
   ,farc_data_init
   ,farc_game_infra;

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
   var
      RSTstaffCnt
      ,RSTstaffMax: integer;

      RSTinfraData: TFCRdipInfrastructure;
begin
   {.POP_Total store the total population the infrastructure lack before to be operational, so it's >0 if the test fail}
   Result.POP_total:=0;
   {.these data store the total population, by type of population, the infrastructure lack before to be operational, so it's >0 if the test fail}
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
   {.these data store the total population, by type of population, that are assigned to the infrastructure, not used for result itself}
   Result.POP_tpColonAssigned:=0;
   Result.POP_tpASoffAssigned:=0;
   Result.POP_tpASmiSpAssigned:=0;
   Result.POP_tpBSbioAssigned:=0;
   Result.POP_tpBSdocAssigned:=0;
   Result.POP_tpIStechAssigned:=0;
   Result.POP_tpISengAssigned:=0;
   Result.POP_tpMSsoldAssigned:=0;
   Result.POP_tpMScommAssigned:=0;
   Result.POP_tpPSphysAssigned:=0;
   Result.POP_tpPSastrAssigned:=0;
   Result.POP_tpESecolAssigned:=0;
   Result.POP_tpESecofAssigned:=0;
   Result.POP_tpAmedianAssigned:=0;
   RSTinfraData:=FCFgInf_DataStructure_Get(
      RSTent
      ,RSTcol
      ,FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_dbToken
      );
   {:DEV NOTES: test infra staff req here.}
   RSTstaffMax:=length(RSTinfraData.I_reqStaff)-1;
   if RSTstaffMax>0 then
   begin
      RSTstaffCnt:=1;
      while RSTstaffCnt<=RSTstaffMax do
      begin
         case RSTinfraData.I_reqStaff[RSTstaffCnt].RS_type of
            ptColonist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColon-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColonAssigned ) then
               begin
                  Result.POP_tpColonAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColonAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColonAssigned+Result.POP_tpColonAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColon-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpColonAssigned ) then
               begin
                  Result.POP_tpColon:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpColon;
               end;
            end;

            ptOfficer:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoff-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoffAssigned ) then
               begin
                  Result.POP_tpASoffAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoffAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoffAssigned+Result.POP_tpASoffAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoff-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASoffAssigned ) then
               begin
                  Result.POP_tpASoff:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpASoff;
               end;
            end;

            ptMissSpe:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSp-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSpAssigned ) then
               begin
                  Result.POP_tpASmiSpAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSpAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSpAssigned+Result.POP_tpASmiSpAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSp-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpASmiSpAssigned ) then
               begin
                  Result.POP_tpASmiSp:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpASmiSp;
               end;
            end;

            ptBiolog:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbio-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbioAssigned ) then
               begin
                  Result.POP_tpBSbioAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbioAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbioAssigned+Result.POP_tpBSbioAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbio-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSbioAssigned ) then
               begin
                  Result.POP_tpBSbio:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpBSbio;
               end;
            end;

            ptDoctor:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdoc-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdocAssigned ) then
               begin
                  Result.POP_tpBSdocAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdocAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdocAssigned+Result.POP_tpBSdocAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdoc-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpBSdocAssigned ) then
               begin
                  Result.POP_tpBSdoc:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpBSdoc;
               end;
            end;

            ptTechnic:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStech-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStechAssigned ) then
               begin
                  Result.POP_tpIStechAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStechAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStechAssigned+Result.POP_tpIStechAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStech-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpIStechAssigned ) then
               begin
                  Result.POP_tpIStech:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpIStech;
               end;
            end;

            ptEngineer:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISeng-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISengAssigned ) then
               begin
                  Result.POP_tpISengAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISengAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISengAssigned+Result.POP_tpISengAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISeng-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpISengAssigned ) then
               begin
                  Result.POP_tpISeng:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpISeng;
               end;
            end;

            ptSoldier:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsold-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsoldAssigned ) then
               begin
                  Result.POP_tpMSsoldAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsoldAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsoldAssigned+Result.POP_tpMSsoldAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsold-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMSsoldAssigned ) then
               begin
                  Result.POP_tpMSsold:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpMSsold;
               end;
            end;

            ptCommando:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScomm-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScommAssigned ) then
               begin
                  Result.POP_tpMScommAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScommAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScommAssigned+Result.POP_tpMScommAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScomm-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpMScommAssigned ) then
               begin
                  Result.POP_tpMScomm:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpMScomm;
               end;
            end;

            ptPhysic:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphys-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphysAssigned ) then
               begin
                  Result.POP_tpPSphysAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphysAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphysAssigned+Result.POP_tpPSphysAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphys-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSphysAssigned ) then
               begin
                  Result.POP_tpPSphys:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpPSphys;
               end;
            end;

            ptAstroph:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastr-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastrAssigned ) then
               begin
                  Result.POP_tpPSastrAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastrAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastrAssigned+Result.POP_tpPSastrAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastr-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpPSastrAssigned ) then
               begin
                  Result.POP_tpPSastr:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpPSastr;
               end;
            end;

            ptEcolog:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecol-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecolAssigned ) then
               begin
                  Result.POP_tpESecolAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecolAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecolAssigned+Result.POP_tpESecolAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecol-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecolAssigned ) then
               begin
                  Result.POP_tpESecol:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpESecol;
               end;
            end;

            ptEcoform:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecof-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecofAssigned ) then
               begin
                  Result.POP_tpESecofAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecofAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecofAssigned+Result.POP_tpESecofAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecof-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpESecofAssigned ) then
               begin
                  Result.POP_tpESecof:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpESecof;
               end;
            end;

            ptMedian:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required<=( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedian-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedianAssigned ) then
               begin
                  Result.POP_tpAmedianAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedianAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedianAssigned+Result.POP_tpAmedianAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required>( FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedian-FCentities[RSTent].E_col[RSTcol].COL_population.POP_tpAmedianAssigned ) then
               begin
                  Result.POP_tpAmedian:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_required;
                  Result.POP_total:=Result.POP_total+Result.POP_tpAmedian;
               end;
            end;
         end;
         inc( RSTstaffCnt );
      end;
      if Result.POP_total=0 then
      begin
         //apply pop assignment here

      end
      else if Result.POP_total>0 then
      begin
         {:DEV NOTES: remove assigned population here, if there's any (test each Assigned.}
         FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_status:=istInTransition;
         FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_cabDuration:=-1;
      end;

   end;

end;

//===========================END FUNCTIONS SECTION==========================================

end.