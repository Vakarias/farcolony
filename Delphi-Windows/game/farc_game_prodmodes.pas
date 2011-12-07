{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production modes management

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
unit farc_game_prodmodes;

interface

uses
   math

   ,farc_data_infrprod;


//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   generate the production modes' data from the infrastructure's function
///</summary>
///   <param name="PMDFFGent">entity index #</param>
///   <param name="PMDFFGcol">colony index #</param>
///   <param name="PMDFFGsett">settlement index #</param>
///   <param name="PMDFFGinfra">owned infrastructure index #</param>
///   <param name="PMDFFGinfraLevel">owned infrastructure level</param>
///   <param name="PMDFFGinfraData">infrastructure data</param>
procedure FCMgPM_ProductionModeDataFromFunction_Generate(
   const PMDFFGent
         ,PMDFFGcol
         ,PMDFFGsett
         ,PMDFFGinfra
         ,PMDFFGinfraLevel: integer;
   const PMDFFGinfraData: TFCRdipInfrastructure
   );

implementation

uses
   farc_data_game
   ,farc_data_univ
   ,farc_game_prodSeg2;

//===================================================END OF INIT============================


//===========================END FUNCTIONS SECTION==========================================

procedure FCMgPM_ProductionModeDataFromFunction_Generate(
   const PMDFFGent
         ,PMDFFGcol
         ,PMDFFGsett
         ,PMDFFGinfra
         ,PMDFFGinfraLevel: integer;
   const PMDFFGinfraData: TFCRdipInfrastructure
   );
{:Purpose: generate the production modes' data from the infrastructure's function.
    Additions:
      -2011Dec04- *add: Resource Mining (WIP).
      -2011Nov14- *add: code framewrok inclusion + Resource Mining (WIP).
}
   var
      PMDFFGcnt
      ,PMDFFGresourceSpot
      ,PMDFFGsurveyedRegion
      ,PMDFFGsurveyedSpot: integer;

      PMDFFGrmp: extended;
begin
   PMDFFGcnt:=1;
   while PMDFFGcnt<=FCCpModeMax do
   begin
      if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then
      begin
         case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of
            pmNone: break;

            pmResourceMining:
            begin
               FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[PMDFFGcnt].PM_type:=PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes;
               PMDFFGsurveyedSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedSpot;
               PMDFFGsurveyedRegion:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedRegion;
               PMDFFGresourceSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodResourceSpot;
               PMDFFGrmp:=( ( power( PMDFFGinfraData.I_surface[PMDFFGinfraLevel], 0.333 ) + power( PMDFFGinfraData.I_volume[PMDFFGinfraLevel], 0.111 ) )*0.5 )
                  * FCRplayer.P_surveyedSpots[PMDFFGsurveyedSpot].SS_surveyedRegions[PMDFFGsurveyedRegion].SR_ResourceSpot[PMDFFGresourceSpot].RS_MQC
                  * (PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy*0.01);
               if PMDFFGinfraData.I_reqRsrcSpot=rstIcyOreField then
               begin
                  FCMgPS2_ProductionMatrixItem_Add(
                     PMDFFGent
                     ,PMDFFGcol
                     ,PMDFFGsett
                     ,PMDFFGinfra
                     ,PMDFFGcnt
                     ,'resIcyOre'
                     ,
                     );
               else
//               energy: FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodMode[PMDFFGcnt].PM_energyCons:=;
            end;
         end; //==END== case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of ==//
      end //==END== if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then ==//
      else Break;
      inc(PMDFFGcnt);
   end; //==END== while PMDFFGcnt<=FCCpModeMax do ==//
end;

end.
