{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - custom effects

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
unit farc_game_infracustomfx;

interface

uses
   farc_data_game
   ,farc_data_infrprod;


///<summary>
///   search if a given infrastructure has an HeadQuarter custom effect and return the level if there's any
///</summary>
///   <param name="EHQSinfra">infrastructure to examine</param>
function FCFgICFX_EffectHQ_Search( const EHQSinfra: TFCRdipInfrastructure ): TFCEdgHQstatus;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   applies the effects of a given infrastructure, if there's any
///</summary>
///   <param name="EAent">entity #</param>
///   <param name="EAcolony">colony #</param>
///   <param name="EAownedLvl">owned infrastructure colony level</param>
///   <param name="EAinfraDat">concerned infrastructure cloned data</param>
procedure FCMgICFX_Effects_Application(
   const EAent
         ,EAcolony
         ,EAownedLvl: integer;
   const EAinfraDat: TFCRdipInfrastructure
   );

///<summary>
///   remove the effects of a given infrastructure, if there's any
///</summary>
///   <param name="ERent">entity #</param>
///   <param name="ERcolony">colony #</param>
///   <param name="ERownedLvl">owned infrastructure colony level</param>
///   <param name="ERinfraDat">concerned infrastructure cloned data</param>
procedure FCMgICFX_Effects_Removing(
   const ERent
         ,ERcolony
         ,ERownedLvl: integer;
   const ERinfraDat: TFCRdipInfrastructure
   );

implementation

uses
   farc_game_colony
   ,farc_game_energymodes
   ,farc_game_infrapower;

//===================================================END OF INIT============================

function FCFgICFX_EffectHQ_Search( const EHQSinfra: TFCRdipInfrastructure ): TFCEdgHQstatus;
{:Purpose: search if a given infrastructure has an HeadQuarter custom effect and return the level if there's any.
    Additions:
}
   var
      EHQScfxCnt
      ,EHQScfxMax: integer;
begin
   Result:=dgNoHQ;
   EHQScfxMax:=Length(EHQSinfra.I_customFx)-1;
   EHQScfxCnt:=1;
   while EHQScfxCnt<=EHQScfxMax do
   begin
      case EHQSinfra.I_customFx[EHQScfxCnt].ICFX_customEffect of
         cfxHQbasic:
         begin
            Result:=dgBasicHQ;
            Break;
         end;

         cfxHQSecondary:
         begin
            Result:=dgSecHQ;
            Break;
         end;

         cfxHQPrimary:
         begin
            Result:=dgPriUnHQ;
            Break;
         end;
      end;
      inc(EHQScfxCnt);
   end;
end;

//===========================END FUNCTIONS SECTION==========================================
procedure FCMgICFX_Effects_Application(
   const EAent
         ,EAcolony
         ,EAownedLvl: integer;
   const EAinfraDat: TFCRdipInfrastructure
   );
{:Purpose: applies the effects of a given infrastructure, if there's any.
    Additions:
      -2011Jul17- *add: energy generation and energy storage custom effects.
      -2011Jul14- *add: complete cfxHQbasic, cfxHQPrimary, cfxHQSecondary and cfxProductStorage.
                  *add: new parameter: level of the owned infrastructure.
      -2011May15-	*rem: the life support custom effects are removed (useless).
    	-2011May12-	*add: product storage entry.
}
{:DEV NOTES: don't forget to update FCMgICFX_Effects_Removing too.}
   var
      EAcnt
      ,EAmax: integer;

      EAnergyOutput: double;
begin
   EAmax:=length(EAinfraDat.I_customFx)-1;
   while EAcnt<=EAmax do
   begin
      case EAinfraDat.I_customFx[EAcnt].ICFX_customEffect of
         cfxEnergyGen:
         begin
            EAnergyOutput:=FCFgEM_OutputFromCustomFx_GetValue(
               EAent
               ,EAcolony
               ,EAcnt
               ,EAownedLvl
               ,EAinfraDat
               );
            FCMgIP_CSMEnergy_Update(
               EAent
               ,EAcolony
               ,false
               ,0
               ,EAnergyOutput
               ,0
               ,0
               );
         end;

         cfxEnergyStor:
         begin
            EAnergyOutput:=EAinfraDat.I_customFx[EAcnt].ICFX_enStorLvl[EAownedLvl];
            FCMgIP_CSMEnergy_Update(
               EAent
               ,EAcolony
               ,false
               ,0
               ,0
               ,0
               ,EAnergyOutput
               );
         end;

         cfxHQbasic: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,dgBasicHQ
            );

         cfxHQSecondary: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,dgSecHQ
            );

         cfxHQPrimary: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,dgPriUnHQ
            );

         cfxProductStorage:
         begin
            FCentities[EAent].E_col[EAcolony].COL_storCapacitySolidMax
               :=FCentities[EAent].E_col[EAcolony].COL_storCapacitySolidMax+EAinfraDat.I_customFx[EAcnt].ICFX_prodStorageLvl[EAownedLvl].IPS_solid;
            FCentities[EAent].E_col[EAcolony].COL_storCapacityLiquidMax
               :=FCentities[EAent].E_col[EAcolony].COL_storCapacityLiquidMax+EAinfraDat.I_customFx[EAcnt].ICFX_prodStorageLvl[EAownedLvl].IPS_liquid;
            FCentities[EAent].E_col[EAcolony].COL_storCapacityGasMax
               :=FCentities[EAent].E_col[EAcolony].COL_storCapacityGasMax+EAinfraDat.I_customFx[EAcnt].ICFX_prodStorageLvl[EAownedLvl].IPS_gas;
            FCentities[EAent].E_col[EAcolony].COL_storCapacityBioMax
               :=FCentities[EAent].E_col[EAcolony].COL_storCapacityBioMax+EAinfraDat.I_customFx[EAcnt].ICFX_prodStorageLvl[EAownedLvl].IPS_biologic;
         end;
      end; //==END== case EAinfraDat.I_customFx[EAcnt].ICFX_customEffect of ==//
      inc(EAcnt);
   end; //==END== while EAcnt<=EAmax do ==//
end;

procedure FCMgICFX_Effects_Removing(
   const ERent
         ,ERcolony
         ,ERownedLvl: integer;
   const ERinfraDat: TFCRdipInfrastructure
   );
{:Purpose: remove the effects of a given infrastructure, if there's any.
   Additions:
}
{:DEV NOTES: don't forget to update FCMgICFX_Effects_Application too.}
   var
      ERcnt
      ,ERmax: integer;

      ERnergyOutput: double;
begin
   ERmax:=length(ERinfraDat.I_customFx)-1;
   while ERcnt<=ERmax do
   begin
      case ERinfraDat.I_customFx[ERcnt].ICFX_customEffect of
         cfxEnergyGen:
         begin
            ERnergyOutput:=FCFgEM_OutputFromCustomFx_GetValue(
               ERent
               ,ERcolony
               ,ERcnt
               ,ERownedLvl
               ,ERinfraDat
               );
            FCMgIP_CSMEnergy_Update(
               ERent
               ,ERcolony
               ,false
               ,0
               ,-ERnergyOutput
               ,0
               ,0
               );
         end;

         cfxEnergyStor:
         begin
            ERnergyOutput:=ERinfraDat.I_customFx[ERcnt].ICFX_enStorLvl[ERownedLvl];
            FCMgIP_CSMEnergy_Update(
               ERent
               ,ERcolony
               ,false
               ,0
               ,0
               ,0
               ,-ERnergyOutput
               );
         end;

         cfxHQbasic, cfxHQSecondary, cfxHQPrimary: FCMgC_HQ_Remove( ERent, ERcolony );

         cfxProductStorage:
         begin
            FCentities[ERent].E_col[ERcolony].COL_storCapacitySolidMax:=FCentities[ERent].E_col[ERcolony].COL_storCapacitySolidMax-ERinfraDat.I_customFx[ERcnt].ICFX_prodStorageLvl[ERownedLvl].IPS_solid;
            FCentities[ERent].E_col[ERcolony].COL_storCapacityLiquidMax:=FCentities[ERent].E_col[ERcolony].COL_storCapacityLiquidMax-ERinfraDat.I_customFx[ERcnt].ICFX_prodStorageLvl[ERownedLvl].IPS_liquid;
            FCentities[ERent].E_col[ERcolony].COL_storCapacityGasMax:=FCentities[ERent].E_col[ERcolony].COL_storCapacityGasMax-ERinfraDat.I_customFx[ERcnt].ICFX_prodStorageLvl[ERownedLvl].IPS_gas;
            FCentities[ERent].E_col[ERcolony].COL_storCapacityBioMax:=FCentities[ERent].E_col[ERcolony].COL_storCapacityBioMax-ERinfraDat.I_customFx[ERcnt].ICFX_prodStorageLvl[ERownedLvl].IPS_biologic;
         end;
      end; //==END== case ERinfraDat.I_customFx[ERcnt].ICFX_customEffect of ==//
      inc(ERcnt);
   end; //==END== while ERcnt<=ERmax do ==//
end;

end.
