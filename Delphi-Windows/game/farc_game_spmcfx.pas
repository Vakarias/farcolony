{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: SPM items - custom effects

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
unit farc_game_spmcfx;

interface

//uses
  // farc_data_game;



//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   Set the custom effects of a given SPMi
///</summary>
///   <param name="CSent">entity index #</param>
///   <param name="CSspmiIndex">SPM item index</param>
procedure FCMgSPMCFX_Core_Setup( const CSent, CSspmiIndex: integer );

///<summary>
///   Apply the Economic & Industrial Output custom effect
///</summary>
///   <param name="EIOUTAent">entity index #</param>
///   <param name="EIOUTAindex">SPM item index</param>
///   <param name="EIOUTAcfxIndex">SPM custom effect index</param>
///   <param name="EIOUTAisReversalEffect">true= reverse the effects (for a removal)</param>
procedure FCMgSPMCFX_EIOUT_Apply(
   const EIOUTAent
         ,EIOUTAindex
         ,EIOUTAcfxIndex : integer;
         EIOUTAisReversalEffect: boolean 
   );
   
///<summary>
///   Apply the Revenues & Taxes custom effect
///</summary>
///   <param name="REVTXAent">entity index #</param>
///   <param name="REVTXAindex">SPM item index</param>
///   <param name="REVTXAcfxIndex">SPM custom effect index</param>
///   <param name="REVTXAisReversalEffect">true= reverse the effects (for a removal)</param>
procedure FCMgSPMCFX_REVTX_Apply(
   const REVTXAent
         ,REVTXAindex
         ,REVTXAcfxIndex : integer;
         REVTXAisReversalEffect: boolean 
   );

implementation

uses
   farc_data_game
   ,farc_game_spm
   ,farc_game_spmdata;

//===================================================END OF INIT============================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgSPMCFX_Core_Setup( const CSent, CSspmiIndex: integer );
{:Purpose: Set the custom effects of a given SPMi.
}
   var
      CScount
      ,CSmax: integer;
begin
   CSmax:=length( FCDBdgSPMi[CSspmiIndex].SPMI_customFxList )-1;
   if CSmax>0 then
   begin
      CScount:=1;
      while CScount<=CSmax do
      begin
         case FCDBdgSPMi[CSspmiIndex].SPMI_customFxList[CScount].CFX_code of
            cfxEIOUT: FCMgSPMCFX_EIOUT_Apply(
               CSent
               ,CSspmiIndex
               ,CScount
               ,false
               );

            cfxREVTX: FCMgSPMCFX_REVTX_Apply(
               CSent
               ,CSspmiIndex
               ,CScount
               ,false
               );
         end;
         inc( CScount );
      end;
   end;
end;

procedure FCMgSPMCFX_EIOUT_Apply(
   const EIOUTAent
         ,EIOUTAindex
         ,EIOUTAcfxIndex : integer;
         EIOUTAisReversalEffect: boolean
   );
{:Purpose: Apply the Economic & Industrial Output custom effect.
}
{DEV: WARNING reversal is incomplete}
   var
      EIOUTAburMod
      ,EIOUTAcount
      ,EIOUTAmax
      ,EIOUTAmod: integer;
begin
   EIOUTAmod:=FCDBdgSPMi[EIOUTAindex].SPMI_customFxList[EIOUTAcfxIndex].CFX_eioutMod;
   if FCDBdgSPMi[EIOUTAindex].SPMI_customFxList[EIOUTAcfxIndex].CFX_eioutIsBurMod then
   begin
      if FCentities[EIOUTAent].E_spmMBur<=30
      then EIOUTAburMod:=-20
      else if ( FCentities[EIOUTAent].E_spmMBur>30 )
         and ( FCentities[EIOUTAent].E_spmMBur<61 )
      then EIOUTAburMod:=-10
      else if ( FCentities[EIOUTAent].E_spmMBur>60 )
         and ( FCentities[EIOUTAent].E_spmMBur<91 )
      then EIOUTAburMod:=0
      else if FCentities[EIOUTAent].E_spmMBur>90
      then EIOUTAburMod:=5;
      EIOUTAmod:=EIOUTAmod+EIOUTAburMod;
   end; 
   EIOUTAmax:=length( FCentities[EIOUTAent].E_col )-1;
   EIOUTAcount:=1;
   while EIOUTAcount<=EIOUTAmax do
   begin
      FCentities[EIOUTAent].E_col[EIOUTAcount].COL_eiOut:=FCentities[EIOUTAent].E_col[EIOUTAcount].COL_eiOut+EIOUTAmod;
      inc( EIOUTAcount );
   end;
end;

procedure FCMgSPMCFX_REVTX_Apply(
   const REVTXAent
         ,REVTXAindex
         ,REVTXAcfxIndex : integer;
         REVTXAisReversalEffect: boolean 
   );
{:Purpose: Apply the Revenues & Taxes custom effect.
}
   var
      REVTXAfactionEIO
      ,REVTXAfactionPopulation
      ,REVTXAgenUC: integer;
      
      REVTXAgenUCfloat: extended;
begin
   if not REVTXAisReversalEffect then
   begin
      REVTXAfactionEIO:=FCFgSPMD_GlobalData_Get( gspmdEconIndusOutput, REVTXAent );
      REVTXAfactionPopulation:=FCFgSPMD_GlobalData_Get( gmspmdPopulation, REVTXAent );
      REVTXAgenUCfloat:=sqrt( REVTXAfactionPopulation )*REVTXAfactionEIO*FCDBdgSPMi[REVTXAindex].SPMI_customFxList[REVTXAcfxIndex].CFX_revtxCoef;
      REVTXAgenUC:=round( REVTXAgenUCfloat );
//      FCentities[REVTXAent].E_ucGen:=FCentities[EIOUTAent].E_ucGen+REVTXAgenUC;
      //FCentities[EIOUTAent].spmdata.storedUCgen:=FCentities[EIOUTAent].spmdata.storedUCgen+REVTXAgenUC;
   end
   else
   begin
      
   end;
end;
   
end.
