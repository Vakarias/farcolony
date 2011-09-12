{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructure functions management

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
unit farc_game_infrafunctions;

interface

uses
   farc_data_infrprod;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   applies (enable) the function's data. WARNING: the owned infrastructure must had FCMgIF_Functions_Initialize applied previously
///</summary>
///   <param name="FAent">entity index #</param>
///   <param name="FAcol">colony index #</param>
///   <param name="FAsett">settlement index #</param>
///   <param name="FAinfra">owned infrastructure index #</param>
procedure FCMgIF_Functions_Application(
   const FAent
         ,FAcol
         ,FAsett
         ,FAinfra: integer);

///<summary>
///   initialize the infrastructure functions data for assembling/building modes, witout enable them into the colony
///</summary>
///   <param name="FIent">entity index #</param>
///   <param name="FIcol">colony index #</param>
///   <param name="FIsett">settlement index #</param>
///   <param name="FIinfra">owned infrastructure index #</param>
///   <param name="FIinfraData">infrastructure data</param>
procedure FCMgIF_Functions_Initialize(
   const FIent
         ,FIcol
         ,FIsett
         ,FIinfra: integer;
   const FIinfraData: TFCRdipInfrastructure
   );

implementation

uses
   farc_data_game
   ,farc_game_csm
   ,farc_game_energymodes
   ,farc_game_infrapower;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgIF_Functions_Application(
   const FAent
         ,FAcol
         ,FAsett
         ,FAinfra: integer);
{:Purpose: applies (enable) the function's data. WARNING: the owned infrastructure must had FCMgIF_Functions_Initialize applied previously.
    Additions:
}
begin
   case FCentities[FAent].E_col[FAcol].COL_settlements[FAsett].CS_infra[FAinfra].CI_function of
      fEnergy:
      begin
         FCMgIP_CSMEnergy_Update(
            FAent
            ,FAcol
            ,false
            ,0
            ,FCentities[FAent].E_col[FAcol].COL_settlements[FAsett].CS_infra[FAinfra].CI_fEnergOut
            ,0
            ,0
            );
      end;

      fHousing:
      begin
         FCMgCSM_ColonyData_Upd(
            gcsmdPCAP
            ,FAent
            ,FAcol
            ,FCentities[FAent].E_col[FAcol].COL_settlements[FAsett].CS_infra[FAinfra].CI_fhousPCAP
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            gcsmdQOL
            ,FAent
            ,FAcol
            ,0
            ,0
            ,gcsmptNone
            ,true
            );
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

procedure FCMgIF_Functions_Initialize(
   const FIent
         ,FIcol
         ,FIsett
         ,FIinfra: integer;
   const FIinfraData: TFCRdipInfrastructure
   );
{:Purpose: initialize the infrastructure functions data for assembling/building modes, witout enable them into the colony.
    Additions:
      -2011Sep11- *mod: remove the previous fix, function's data are only initialized here. Replace it by the owned infrastructure data loading.
                  *code: the procedure is moved in it's proper unit.
      -2011Sep09- *fix: for energy function: forgot to update the colony's energy production data.
      -2011Sep03- *add: for fHousing, add the level in determination of the population capacity.
      -2011Jul18- *add: complete the fEnergy case.
}
{:DEV NOTES: don't forget to update FCMgIF_Functions_Application.}
   var
      FIenergyOutput: double;
begin
   case FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_function of
      fEnergy:
      begin
         FIenergyOutput:=FCFgEM_OutputFromFunction_GetValue(
            FIent
            ,FIcol
            ,FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_level
            ,FIinfraData
            );
         FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_fEnergOut:=FIenergyOutput;
      end;

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
