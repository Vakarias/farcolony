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
///   applies (enable) or remove (disable) the function's data. WARNING: the owned infrastructure must had FCMgIF_Functions_Initialize applied previously for applies
///</summary>
///   <param name="FARent">entity index #</param>
///   <param name="FARcol">colony index #</param>
///   <param name="FARsett">settlement index #</param>
///   <param name="FARinfra">owned infrastructure index #</param>
///   <param name="FARisRemove">true= remove the function's data, false= applies</param>
procedure FCMgIF_Functions_ApplicationRemove(
   const FARent
         ,FARcol
         ,FARsett
         ,FARinfra: integer;
   const FARisRemove: boolean
         );

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
   ,farc_game_infrapower
   ,farc_game_prodmodes;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgIF_Functions_ApplicationRemove(
   const FARent
         ,FARcol
         ,FARsett
         ,FARinfra: integer;
   const FARisRemove: boolean
         );
{:Purpose: applies (enable) the function's data. WARNING: the owned infrastructure must had FCMgIF_Functions_Initialize applied previously.
    Additions:
      -2011Oct03- *add: new parameter for indicate if the function data are removed or not + modify changes for each case.
}
   var
      FARint: integer;

      FARfloat: double;
begin
   case FCentities[FARent].E_col[FARcol].COL_settlements[FARsett].CS_infra[FARinfra].CI_function of
      fEnergy:
      begin
         if FARisRemove
         then FARfloat:=-FCentities[FARent].E_col[FARcol].COL_settlements[FARsett].CS_infra[FARinfra].CI_fEnergOut
         else FARfloat:=FCentities[FARent].E_col[FARcol].COL_settlements[FARsett].CS_infra[FARinfra].CI_fEnergOut;
         FCMgIP_CSMEnergy_Update(
            FARent
            ,FARcol
            ,false
            ,0
            ,FARfloat
            ,0
            ,0
            );
      end;

      fHousing:
      begin
         if FARisRemove
         then FARint:=-FCentities[FARent].E_col[FARcol].COL_settlements[FARsett].CS_infra[FARinfra].CI_fhousPCAP
         else FARint:=FCentities[FARent].E_col[FARcol].COL_settlements[FARsett].CS_infra[FARinfra].CI_fhousPCAP;
         FCMgCSM_ColonyData_Upd(
            gcsmdPCAP
            ,FARent
            ,FARcol
            ,FARint
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            gcsmdQOL
            ,FARent
            ,FARcol
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
      -2011Nov14- *add: enable the FCMgPM_ProductionModeDataFromFunction_Generate link of the fProduction case.
      -2011Nov08- *add: enable the fProduction case.
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
         FCMgPM_ProductionModeDataFromFunction_Generate(
            FIent
            ,FIcol
            ,FIsett
            ,FIinfra
            ,FCentities[FIent].E_col[FIcol].COL_settlements[FIsett].CS_infra[FIinfra].CI_level
            ,FIinfraData
            );
      end;
   end;
end;

end.