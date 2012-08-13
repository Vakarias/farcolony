{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: infrastructures - custom effects

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
unit farc_game_infracustomfx;

interface

uses
   farc_data_game
   ,farc_data_infrprod;


///<summary>
///   search if a given infrastructure has an HeadQuarter custom effect and return the level if there's any
///</summary>
///   <param name="EHQSinfra">infrastructure to examine</param>
function FCFgICFX_EffectHQ_Search( const EHQSinfra: TFCRdipInfrastructure ): TFCEdgHeadQuarterStatus;

///<summary>
///   search if a given infrastructure has a custom effect Product Storage that contain liquid storage
///</summary>
///   <param name="InfraData">infrastructure to examine</param>
///   <param name="OwnedInfraLevel">owned infrastructure's level</param>
///   <returns>the storage's value in cubic meters, as stored in the database, relative to the given infrastructure's level. Returns 0 if not found</returns>
function FCFgICFX_EffectStorageLiquid_Search( const InfraData: TFCRdipInfrastructure; OwnedInfraLevel: integer ): double;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   applies the effects of a given infrastructure, if there's any
///</summary>
///   <param name="EAent">entity #</param>
///   <param name="EAcolony">colony #</param>
///   <param name="Settlement">settlement index #</param>
///   <param name="OwnedInfrastructure">owned infrastructure index #</param>
///   <param name="EAinfraDat">concerned infrastructure cloned data</param>
procedure FCMgICFX_Effects_Application(
   const EAent
         ,EAcolony
         ,Settlement
         ,OwnedInfrastructure: integer;
   const EAinfraDat: TFCRdipInfrastructure
   );

///<summary>
///   remove the effects of a given infrastructure, if there's any
///</summary>
///   <param name="ERent">entity #</param>
///   <param name="ERcolony">colony #</param>
///   <param name="Settlement">settlement index #</param>
///   <param name="OwnedInfra">owned infrastructure index #</param>
///   <param name="ERinfraDat">concerned infrastructure cloned data</param>
procedure FCMgICFX_Effects_Removing(
   const ERent
         ,ERcolony
         ,Settlement
         ,OwnedInfra: integer;
   const ERinfraDat: TFCRdipInfrastructure
   );

implementation

uses
   farc_game_colony
   ,farc_game_csm
   ,farc_game_energymodes;

//===================================================END OF INIT============================

function FCFgICFX_EffectHQ_Search( const EHQSinfra: TFCRdipInfrastructure ): TFCEdgHeadQuarterStatus;
{:Purpose: search if a given infrastructure has an HeadQuarter custom effect and return the level if there's any.
    Additions:
}
   var
      EHQScfxCnt
      ,EHQScfxMax: integer;
begin
   Result:=hqsNoHQPresent;
   EHQScfxMax:=Length(EHQSinfra.I_customEffectStructure)-1;
   EHQScfxCnt:=1;
   while EHQScfxCnt<=EHQScfxMax do
   begin
      case EHQSinfra.I_customEffectStructure[EHQScfxCnt].ICFX_customEffect of
         ceHeadQuarterBasic:
         begin
            Result:=hqsBasicHQ;
            Break;
         end;

         ceHeadQuarterSecondary:
         begin
            Result:=hqsSecondaryHQ;
            Break;
         end;

         ceHeadQuarterPrimary:
         begin
            Result:=hqsPrimaryUniqueHQ;
            Break;
         end;
      end;
      inc(EHQScfxCnt);
   end;
end;

function FCFgICFX_EffectStorageLiquid_Search( const InfraData: TFCRdipInfrastructure; OwnedInfraLevel: integer ): double;
{:Purpose: search if a given infrastructure has a custom effect Product Storage that contain liquid storage.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   Result:=0;
   Count:=1;
   Max:=Length( InfraData.I_customEffectStructure )-1;
   while Count<=Max do
   begin
      if ( InfraData.I_customEffectStructure[ Count ].ICFX_customEffect=ceProductStorage )
         and( InfraData.I_customEffectStructure[ Count ].ICFX_cePSstorageByLevel[ OwnedInfraLevel ].SBL_liquid>0) then
      begin
         Result:=InfraData.I_customEffectStructure[ Count ].ICFX_cePSstorageByLevel[ OwnedInfraLevel ].SBL_liquid;
         break;
      end;
      inc( Count );
   end;
end;

//===========================END FUNCTIONS SECTION==========================================
procedure FCMgICFX_Effects_Application(
   const EAent
         ,EAcolony
         ,Settlement
         ,OwnedInfrastructure: integer;
   const EAinfraDat: TFCRdipInfrastructure
   );
{:Purpose: applies the effects of a given infrastructure, if there's any.
    Additions:
      -2012Jan23- *fix: set the CfxCount with a correct starting position.
      -2012Jan04- *add: two parameters settlement/owned infrastructure.
                  *add: store the energy output in CI_powerGenFromCFx if needed.
      -2011Jul17- *add: energy generation and energy storage custom effects.
      -2011Jul14- *add: complete cfxHQbasic, cfxHQPrimary, cfxHQSecondary and cfxProductStorage.
                  *add: new parameter: level of the owned infrastructure.
      -2011May15-	*rem: the life support custom effects are removed (useless).
    	-2011May12-	*add: product storage entry.
}
{:DEV NOTES: don't forget to update FCMgICFX_Effects_Removing too.}
   var
      CfxCount
      ,LevelInfra
      ,EAmax: integer;

      EAnergyOutput: extended;
begin
   LevelInfra:=FCEntities[ EAent ].E_col[ EAcolony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfrastructure ].I_level;
   CfxCount:=1;
   EAmax:=length(EAinfraDat.I_customEffectStructure)-1;
   while CfxCount<=EAmax do
   begin
      case EAinfraDat.I_customEffectStructure[CfxCount].ICFX_customEffect of
         ceEnergyGeneration:
         begin
            EAnergyOutput:=FCFgEM_OutputFromCustomFx_GetValue(
               EAent
               ,EAcolony
               ,CfxCount
               ,LevelInfra
               ,EAinfraDat
               );
            FCEntities[ EAent ].E_col[ EAcolony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfrastructure ].I_powerGeneratedFromCustomEffect:=EAnergyOutput;
            FCMgCSM_Energy_Update(
               EAent
               ,EAcolony
               ,false
               ,0
               ,EAnergyOutput
               ,0
               ,0
               );
         end;

         ceEnergyStorage:
         begin
            FCMgCSM_Energy_Update(
               EAent
               ,EAcolony
               ,false
               ,0
               ,0
               ,0
               ,EAinfraDat.I_customEffectStructure[CfxCount].ICFX_ceEScapacitiesByLevel[ LevelInfra ]
               );
         end;

         ceHeadQuarterBasic: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,hqsBasicHQ
            );

         ceHeadQuarterSecondary: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,hqsSecondaryHQ
            );

         ceHeadQuarterPrimary: FCMgC_HQ_Set(
            EAent
            ,EAcolony
            ,hqsPrimaryUniqueHQ
            );

         ceProductStorage:
         begin
            FCentities[EAent].E_col[EAcolony].C_storageCapacitySolidMax:=FCentities[EAent].E_col[EAcolony].C_storageCapacitySolidMax+EAinfraDat.I_customEffectStructure[CfxCount].ICFX_cePSstorageByLevel[LevelInfra].SBL_solid;
            FCentities[EAent].E_col[EAcolony].C_storageCapacityLiquidMax:=FCentities[EAent].E_col[EAcolony].C_storageCapacityLiquidMax+EAinfraDat.I_customEffectStructure[CfxCount].ICFX_cePSstorageByLevel[LevelInfra].SBL_liquid;
            FCentities[EAent].E_col[EAcolony].C_storageCapacityGasMax:=FCentities[EAent].E_col[EAcolony].C_storageCapacityGasMax+EAinfraDat.I_customEffectStructure[CfxCount].ICFX_cePSstorageByLevel[LevelInfra].SBL_gas;
            FCentities[EAent].E_col[EAcolony].C_storageCapacityBioMax:=FCentities[EAent].E_col[EAcolony].C_storageCapacityBioMax+EAinfraDat.I_customEffectStructure[CfxCount].ICFX_cePSstorageByLevel[LevelInfra].SBL_biologic;
         end;
      end; //==END== case EAinfraDat.I_customFx[EAcnt].ICFX_customEffect of ==//
      inc(CfxCount);
   end; //==END== while EAcnt<=EAmax do ==//
end;

procedure FCMgICFX_Effects_Removing(
   const ERent
         ,ERcolony
         ,Settlement
         ,OwnedInfra: integer;
   const ERinfraDat: TFCRdipInfrastructure
   );
{:Purpose: remove the effects of a given infrastructure, if there's any.
   Additions:
      -2012Jan04- *add: two parameters settlement/owned infrastructure.
                  *mod: in case of cfxEnergyGen, use CI_powerGenFromCFx instead to recalculate the energy generation value.
                  *rem: removal of useless variable and code.
}
{:DEV NOTES: don't forget to update FCMgICFX_Effects_Application too.}
   var
      ERcnt
      ,LevelInfra
      ,ERmax: integer;
begin
   LevelInfra:=FCEntities[ ERent ].E_col[ ERcolony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfra ].I_level;
   ERmax:=length(ERinfraDat.I_customEffectStructure)-1;
   while ERcnt<=ERmax do
   begin
      case ERinfraDat.I_customEffectStructure[ERcnt].ICFX_customEffect of
         ceEnergyGeneration:
         begin
            FCMgCSM_Energy_Update(
               ERent
               ,ERcolony
               ,false
               ,0
               ,-FCEntities[ ERent ].E_col[ ERcolony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfra ].I_powerGeneratedFromCustomEffect
               ,0
               ,0
               );
            FCEntities[ ERent ].E_col[ ERcolony ].C_settlements[ Settlement ].S_infrastructures[ OwnedInfra ].I_powerGeneratedFromCustomEffect:=0;
         end;

         ceEnergyStorage:
         begin
            FCMgCSM_Energy_Update(
               ERent
               ,ERcolony
               ,false
               ,0
               ,0
               ,0
               ,-ERinfraDat.I_customEffectStructure[ERcnt].ICFX_ceEScapacitiesByLevel[LevelInfra]
               );
         end;

         ceHeadQuarterBasic, ceHeadQuarterSecondary, ceHeadQuarterPrimary: FCMgC_HQ_Remove( ERent, ERcolony );

         ceProductStorage:
         begin
            FCentities[ERent].E_col[ERcolony].C_storageCapacitySolidMax:=FCentities[ERent].E_col[ERcolony].C_storageCapacitySolidMax-ERinfraDat.I_customEffectStructure[ERcnt].ICFX_cePSstorageByLevel[LevelInfra].SBL_solid;
            FCentities[ERent].E_col[ERcolony].C_storageCapacityLiquidMax:=FCentities[ERent].E_col[ERcolony].C_storageCapacityLiquidMax-ERinfraDat.I_customEffectStructure[ERcnt].ICFX_cePSstorageByLevel[LevelInfra].SBL_liquid;
            FCentities[ERent].E_col[ERcolony].C_storageCapacityGasMax:=FCentities[ERent].E_col[ERcolony].C_storageCapacityGasMax-ERinfraDat.I_customEffectStructure[ERcnt].ICFX_cePSstorageByLevel[LevelInfra].SBL_gas;
            FCentities[ERent].E_col[ERcolony].C_storageCapacityBioMax:=FCentities[ERent].E_col[ERcolony].C_storageCapacityBioMax-ERinfraDat.I_customEffectStructure[ERcnt].ICFX_cePSstorageByLevel[LevelInfra].SBL_biologic;
         end;
      end; //==END== case ERinfraDat.I_customFx[ERcnt].ICFX_customEffect of ==//
      inc(ERcnt);
   end; //==END== while ERcnt<=ERmax do ==//
end;

end.
