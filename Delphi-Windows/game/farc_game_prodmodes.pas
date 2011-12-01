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
   farc_data_game;

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
      -2011Nov14- *add: code framewrok inclusion + Resource Mining (WIP).
}
   var
      PMDFFGcnt
      ,PMDFFGrscSpot: integer;

      PMDFFGrmp: extended;
begin
   PMDFFGcnt:=1;
   while PMDFFGcnt<=FCCpModeMax do
   begin
      if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy=0
      then break
      else if PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_occupancy>0 then
      begin
         case PMDFFGinfraData.I_fProductionMode[PMDFFGcnt].IPM_productionModes of
            pmNone: break;

            pmResourceMining:
            begin
               PMDFFGrscSpot:=FCentities[PMDFFGent].E_col[PMDFFGcol].COL_settlements[PMDFFGsett].CS_infra[PMDFFGinfra].CI_fprodSurveyedSpot;
//               PMDFFGrmp:=( ( power( PMDFFGinfraData.I_surface[PMDFFGinfraLevel], 0.333 ) + power( PMDFFGinfraData.I_volume[PMDFFGinfraLevel], 0.111 ) )*0.5 )*
               {:DEV NOTES: look and implement resource spot data.}
            end;
         end;
      end;
      inc(PMDFFGcnt);
   end;
end;

end.
