{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructure staff management

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
unit farc_game_infrastaff;

interface

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_data_init
   ,farc_data_pgs;

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
   ): TFCRdgColonyPopulation;

///<summary>
///   retrieve the index # of a specified staff in a given infrastructure's data structure
///</summary>
///   <param name="IBDRstaff">specified staff to find</param>
///   <param name="IBDRinfraData">infrastructure data</param>
///   <returns>staff index #, 0 if not found</returns>
function FCFgIS_IndexByData_Retrieve( const IBDRstaff: TFCEdpgsPopulationTypes; const IBDRinfraData: TFCRdipInfrastructure): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   free the staff and give it back to the colony's available population slots
///</summary>
///   <param name="RSRent">entity index #</param>
///   <param name="RSRcol">colony index #</param>
///   <param name="RSRsett">settlement index #</param>
///   <param name="RSRownInfra">owned infrastructure index #</param>
procedure FCMgIS_RequiredStaff_Recover(
   const RSRent
         ,RSRcol
         ,RSRsett
         ,RSRownInfra: integer
   );

implementation

uses
   farc_game_infra;

//===================================================END OF INIT============================

function FCFgIS_RequiredStaff_Test(
   const RSTent
         ,RSTcol
         ,RSTsett
         ,RSTinfra: integer;
   const RTSapplyAssignment: boolean
   ): TFCRdgColonyPopulation;
{:Purpose: test if a colony can support the required staff of a given owned infrastructure.
    Additions:
      -2011Oct26- *add: apply staff requirement by level.
      -2011Sep20- *add: complete the routine, by adding the code when the test/assignment fail.
}
   var
      RSTownInfraLvl
      ,RSTstaffCnt
      ,RSTstaffMax: integer;

      RSTinfraData: TFCRdipInfrastructure;
begin
   {.POP_Total store the total population the infrastructure lack before to be operational, so it's >0 if the test fail}
   Result.CP_total:=0;
   {.these data store the total population, by type of population, the infrastructure lack before to be operational, so it's >0 if the test fail}
   Result.CP_classColonist:=0;
   Result.CP_classAerOfficer:=0;
   Result.CP_classAerMissionSpecialist:=0;
   Result.CP_classBioBiologist:=0;
   Result.CP_classBioDoctor:=0;
   Result.CP_classIndTechnician:=0;
   Result.CP_classIndEngineer:=0;
   Result.CP_classMilSoldier:=0;
   Result.CP_classMilCommando:=0;
   Result.CP_classPhyPhysicist:=0;
   Result.CP_classPhyAstrophysicist:=0;
   Result.CP_classEcoEcologist:=0;
   Result.CP_classEcoEcoformer:=0;
   Result.CP_classAdmMedian:=0;
   {.these data store the total population, by type of population, that are assigned to the infrastructure, not used for result itself}
   Result.CP_classColonistAssigned:=0;
   Result.CP_classAerOfficerAssigned:=0;
   Result.CP_classAerMissionSpecialistAssigned:=0;
   Result.CP_classBioBiologistAssigned:=0;
   Result.CP_classBioDoctorAssigned:=0;
   Result.CP_classIndTechnicianAssigned:=0;
   Result.CP_classIndEngineerAssigned:=0;
   Result.CP_classMilSoldierAssigned:=0;
   Result.CP_classMilCommandoAssigned:=0;
   Result.CP_classPhyPhysicistAssigned:=0;
   Result.CP_classPhyAstrophysicistAssigned:=0;
   Result.CP_classEcoEcologistAssigned:=0;
   Result.CP_classEcoEcoformerAssigned:=0;
   Result.CP_classAdmMedianAssigned:=0;
   RSTinfraData:=FCFgI_DataStructure_Get(
      RSTent
      ,RSTcol
      ,FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_dbToken
      );
   RSTownInfraLvl:=FCentities[RSTent].E_col[RSTcol].COL_settlements[RSTsett].CS_infra[RSTinfra].CI_level;
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
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned ) then
               begin
                  Result.CP_classColonistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned+Result.CP_classColonistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned ) then
               begin
                  Result.CP_classColonist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classColonist;
               end;
            end;

            ptOfficer:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned ) then
               begin
                  Result.CP_classAerOfficerAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned+Result.CP_classAerOfficerAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned ) then
               begin
                  Result.CP_classAerOfficer:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classAerOfficer;
               end;
            end;

            ptMissionSpecialist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned ) then
               begin
                  Result.CP_classAerMissionSpecialistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned+Result.CP_classAerMissionSpecialistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned ) then
               begin
                  Result.CP_classAerMissionSpecialist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classAerMissionSpecialist;
               end;
            end;

            ptBiologist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned ) then
               begin
                  Result.CP_classBioBiologistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned+Result.CP_classBioBiologistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned ) then
               begin
                  Result.CP_classBioBiologist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classBioBiologist;
               end;
            end;

            ptDoctor:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctor-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned ) then
               begin
                  Result.CP_classBioDoctorAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned+Result.CP_classBioDoctorAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctor-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned ) then
               begin
                  Result.CP_classBioDoctor:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classBioDoctor;
               end;
            end;

            ptTechnician:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnician-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned ) then
               begin
                  Result.CP_classIndTechnicianAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned+Result.CP_classIndTechnicianAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnician-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned ) then
               begin
                  Result.CP_classIndTechnician:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classIndTechnician;
               end;
            end;

            ptEngineer:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned ) then
               begin
                  Result.CP_classIndEngineerAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned+Result.CP_classIndEngineerAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned ) then
               begin
                  Result.CP_classIndEngineer:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classIndEngineer;
               end;
            end;

            ptSoldier:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldier-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned ) then
               begin
                  Result.CP_classMilSoldierAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned+Result.CP_classMilSoldierAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldier-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned ) then
               begin
                  Result.CP_classMilSoldier:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classMilSoldier;
               end;
            end;

            ptCommando:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommando-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned ) then
               begin
                  Result.CP_classMilCommandoAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned+Result.CP_classMilCommandoAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommando-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned ) then
               begin
                  Result.CP_classMilCommando:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classMilCommando;
               end;
            end;

            ptPhysicist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned ) then
               begin
                  Result.CP_classPhyPhysicistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned+Result.CP_classPhyPhysicistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned ) then
               begin
                  Result.CP_classPhyPhysicist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classPhyPhysicist;
               end;
            end;

            ptAstrophysicist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned ) then
               begin
                  Result.CP_classPhyAstrophysicistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned+Result.CP_classPhyAstrophysicistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned ) then
               begin
                  Result.CP_classPhyAstrophysicist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classPhyAstrophysicist;
               end;
            end;

            ptEcologist:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned ) then
               begin
                  Result.CP_classEcoEcologistAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned+Result.CP_classEcoEcologistAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologist-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned ) then
               begin
                  Result.CP_classEcoEcologist:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classEcoEcologist;
               end;
            end;

            ptEcoformer:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned ) then
               begin
                  Result.CP_classEcoEcoformerAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned+Result.CP_classEcoEcoformerAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformer-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned ) then
               begin
                  Result.CP_classEcoEcoformer:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classEcoEcoformer;
               end;
            end;

            ptMedian:
            begin
               if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]<=( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedian-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned ) then
               begin
                  Result.CP_classAdmMedianAssigned:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned+Result.CP_classAdmMedianAssigned;
               end
               else if RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl]>( FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedian-FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned ) then
               begin
                  Result.CP_classAdmMedian:=RSTinfraData.I_reqStaff[RSTstaffCnt].RS_requiredByLv[RSTownInfraLvl];
                  Result.CP_total:=Result.CP_total+Result.CP_classAdmMedian;
               end;
            end;
         end;
         inc( RSTstaffCnt );
      end;
      if Result.CP_total>0 then
      begin
         if Result.CP_classColonistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classColonistAssigned-Result.CP_classColonistAssigned;
         if Result.CP_classAerOfficerAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerOfficerAssigned-Result.CP_classAerOfficerAssigned;
         if Result.CP_classAerMissionSpecialistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAerMissionSpecialistAssigned-Result.CP_classAerMissionSpecialistAssigned;
         if Result.CP_classBioBiologistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioBiologistAssigned-Result.CP_classBioBiologistAssigned;
         if Result.CP_classBioDoctorAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classBioDoctorAssigned-Result.CP_classBioDoctorAssigned;
         if Result.CP_classIndTechnicianAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndTechnicianAssigned-Result.CP_classIndTechnicianAssigned;
         if Result.CP_classIndEngineerAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classIndEngineerAssigned-Result.CP_classIndEngineerAssigned;
         if Result.CP_classMilSoldierAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilSoldierAssigned-Result.CP_classMilSoldierAssigned;
         if Result.CP_classMilCommandoAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classMilCommandoAssigned-Result.CP_classMilCommandoAssigned;
         if Result.CP_classPhyPhysicistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyPhysicistAssigned-Result.CP_classPhyPhysicistAssigned;
         if Result.CP_classPhyAstrophysicistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classPhyAstrophysicistAssigned-Result.CP_classPhyAstrophysicistAssigned;
         if Result.CP_classEcoEcologistAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcologistAssigned-Result.CP_classEcoEcologistAssigned;
         if Result.CP_classEcoEcoformerAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classEcoEcoformerAssigned-Result.CP_classEcoEcoformerAssigned;
         if Result.CP_classAdmMedianAssigned>0
         then FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned:=FCentities[RSTent].E_col[RSTcol].COL_population.CP_classAdmMedianAssigned-Result.CP_classAdmMedianAssigned;
      end;
   end;
end;

function FCFgIS_IndexByData_Retrieve( const IBDRstaff: TFCEdpgsPopulationTypes; const IBDRinfraData: TFCRdipInfrastructure): integer;
{:Purpose: retrieve the index # of a specified staff in a given infrastructure's data structure.
    Additions:
}
   var
      IBDRcount
      ,IBDRmax: integer;
begin
   Result:=0;
   IBDRmax:=Length( IBDRinfraData.I_reqStaff )-1;
   IBDRcount:=1;
   while IBDRcount<=IBDRmax do
   begin
      if IBDRinfraData.I_reqStaff[ IBDRcount ].RS_type=IBDRstaff then
      begin
         Result:=IBDRcount;
         Break;
      end;
      inc( IBDRcount );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgIS_RequiredStaff_Recover(
   const RSRent
         ,RSRcol
         ,RSRsett
         ,RSRownInfra: integer
   );
{:Purpose: free the staff and give it back to the colony's available population slots.
    Additions:
      -2011Oct26- *add: apply staff requirement by level.
}
   var
      RSRcnt
      ,RSRmax
      ,RSRownInfraLvl: integer;

      RSRinfraData: TFCRdipInfrastructure;
begin
   RSRinfraData:=FCFgI_DataStructure_Get(
      RSRent
      ,RSRcol
      ,FCentities[RSRent].E_col[RSRcol].COL_settlements[RSRsett].CS_infra[RSRownInfra].CI_dbToken
      );
   RSRownInfraLvl:=FCentities[RSRent].E_col[RSRcol].COL_settlements[RSRsett].CS_infra[RSRownInfra].CI_level;
   RSRmax:=Length(RSRinfraData.I_reqStaff)-1;
   if RSRmax>0 then
   begin
      RSRcnt:=1;
      while RSRcnt<=RSRmax do
      begin
         case RSRinfraData.I_reqStaff[RSRcnt].RS_type of
            ptColonist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classColonistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classColonistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptOfficer: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAerOfficerAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAerOfficerAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptMissionSpecialist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAerMissionSpecialistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAerMissionSpecialistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptBiologist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classBioBiologistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classBioBiologistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptDoctor: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classBioDoctorAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classBioDoctorAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptTechnician: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classIndTechnicianAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classIndTechnicianAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptEngineer: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classIndEngineerAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classIndEngineerAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptSoldier: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classMilSoldierAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classMilSoldierAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptCommando: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classMilCommandoAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classMilCommandoAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptPhysicist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classPhyPhysicistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classPhyPhysicistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptAstrophysicist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classPhyAstrophysicistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classPhyAstrophysicistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptEcologist: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classEcoEcologistAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classEcoEcologistAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptEcoformer: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classEcoEcoformerAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classEcoEcoformerAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];

            ptMedian: FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAdmMedianAssigned:=FCentities[RSRent].E_col[RSRcol].COL_population.CP_classAdmMedianAssigned-RSRinfraData.I_reqStaff[RSRcnt].RS_requiredByLv[RSRownInfraLvl];
         end;
         inc(RSRcnt);
      end;
   end;
end;

end.
