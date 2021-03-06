{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: colony's reserves management

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
unit farc_game_colonyrves;

interface

uses
   SysUtils

   ,farc_data_infrprod;


///<summary>
///   calculate the percent of people not supported for the food Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_FoodOverload_Calc( const Entity, Colony: integer ): integer;

///<summary>
///   convert a density and volume of food in food reserve's points
///</summary>
///   <param name="FoodVolume">food volume, in cubic meters, to convert</param>
///   <param name="FoodDensity">food density, in t / units, to convert</param>
///   <returns>the converted oxygen reserve's points</returns>
function FCFgCR_FoodToReserve_Convert( const FoodVolume, FoodDensity: extended ): integer;

///<summary>
///   calculate the percent of people not supported for the Oxygen Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_OxygenOverload_Calc( const Entity, Colony: integer ): integer;

///<summary>
///   convert a volume of oxygen into oxygen reserve's points
///</summary>
///   <param name="OxygenVolume">oxygen volume, in cubic meters, to convert</param>
///   <returns>the converted oxygen reserve's points</returns>
function FCFgCR_OxygenToReserve_Convert( const OxygenVolume: extended ): integer;

///<summary>
///   convert food reserve's points into a volume of food
///</summary>
///   <param name="FoodPoints">food points to convert</param>
///   <param name="FoodDensity">food density</param>
///   <returns>the converted and formatted(x.xxx) food volume, in cubic meters</returns>
function FCFgCR_ReserveToFood_Convert( const FoodPoints: integer; FoodDensity: extended ): extended;

///<summary>
///   convert oxygen reserve's points into a volume of oxygen
///</summary>
///   <param name="OxygenPoints">oxygen points to convert</param>
///   <returns>the converted and formatted(x.xxx) oxygen volume, in cubic meters</returns>
function FCFgCR_ReserveToOxygen_Convert( const OxygenPoints: integer ): extended;

///<summary>
///   convert water reserve's points into a volume of water
///</summary>
///   <param name="WaterPoints">water points to convert</param>
///   <returns>the converted and formatted(x.xxx) water volume, in cubic meters</returns>
function FCFgCR_ReserveToWater_Convert( const WaterPoints: integer ): extended;

///<summary>
///   calculate the percent of people not supported for the Water Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_WaterOverload_Calc( const Entity, Colony: integer ): integer;

///<summary>
///   convert a volume of water in water reserve's points
///</summary>
///   <param name="WaterVolume">oxygen volume, in cubic meters, to convert</param>
///   <returns>the converted water reserve's points</returns>
function FCFgCR_WaterToReserve_Convert( const WaterVolume: extended ): integer;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   process the calculations for the Food Shortage event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Event">event index # to process</param>
///   <param name="NewPPS">new Percent of Population not Supported to apply</param>
procedure FCMgCR_FoodShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );

///<summary>
///   apply and process the direct death calculations for the Food Shortage event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Event">event index # to process</param>
///   <param name="AgeCoef">[optional] age coefficient</param>
procedure FCMgCR_FoodShortage_DirectDeath(
   const Entity
         ,Colony
         ,Event: integer;
   const AgeCoef: extended
   );

///<summary>
///   process the calculations for the Oxygen Shortage event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Event">event index # to process</param>
///   <param name="NewPPS">new Percent of Population not Supported to apply</param>
procedure FCMgCR_OxygenShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );

///<summary>
///   update a specified reserve with a +/- value. The value is in reserve points
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="TypeOfReserve">type of reserve to update, must be prfuFood, prfuOxygen or prfuWater. The rest is ignored</param>
///   <param name="ValueModifier">modifier in +/- to apply to the reserve amount</param>
procedure FCMgCR_Reserve_Update(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ReservePointsToXfer: integer;
   const updateStorage: boolean
   );

///<summary>
///   update a specified reserve with a +/- value. The value is in units or more specifically in cubic meters
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="TypeOfReserve">type of reserve to update, must be prfuFood, prfuOxygen or prfuWater. The rest is ignored</param>
///   <param name="ValueModifier">modifier in +/- to apply to the reserve amount</param>
///   <param name="FoodDensity">for food reserve only: food density (REQUIRED PARAMETER)</param>
procedure FCMgCR_Reserve_UpdateByUnits(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier
         ,FoodDensity: extended
   );

///<summary>
///   process the calculations for the Water Shortage event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="Event">event index # to process</param>
///   <param name="NewPPS">new Percent of Population not Supported to apply</param>
procedure FCMgCR_WaterShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_univ
   ,farc_game_colony
   ,farc_game_csm
   ,farc_game_prod
   ,farc_game_prodSeg2
   ,farc_ui_coredatadisplay
   ,farc_win_debug;

//===================================================END OF INIT============================

function FCFgCR_FoodOverload_Calc( const Entity, Colony: integer ): integer;
{:Purpose: calculate the percent of people not supported for the food Production Overload CSM event.
    Additions:
      -2012May15- *fix: forgot an element of calculation for the PPS.
}
   var
      FoodPointCalculated
      ,PPS
      ,ProdMatrixItemCount
      ,ProdMatrixItemMax
      ,ProductIndex
      ,TotalProductionRvePoints: integer;

      ProdMatrixItemProduct: string;
begin
   Result:=0;
   FoodPointCalculated:=0;
   ProdMatrixItemProduct:='';
   ProductIndex:=0;
   TotalProductionRvePoints:=0;
   ProdMatrixItemCount:=1;
   ProdMatrixItemMax:=length( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_productionMatrix )-1;
   while ProdMatrixItemCount<=ProdMatrixItemMax do
   begin
      ProdMatrixItemProduct:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_productionMatrix[ ProdMatrixItemCount ].PM_productToken;
      ProductIndex:=FCFgP_Product_GetIndex( ProdMatrixItemProduct );
      if FCDdipProducts[ ProductIndex ].P_function=pfFood then
      begin
         FoodPointCalculated:=FCFgCR_FoodToReserve_Convert( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_productionMatrix[ ProdMatrixItemCount ].PM_globalProductionFlow, FCDdipProducts[ ProductIndex ].P_massByUnit );
         TotalProductionRvePoints:=TotalProductionRvePoints+FoodPointCalculated;
      end;
      inc( ProdMatrixItemCount );
   end;
   PPS:=round( 100- ( TotalProductionRvePoints / FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total *100 ) );
   Result:=PPS;
end;

function FCFgCR_FoodToReserve_Convert( const FoodVolume, FoodDensity: extended ): integer;
{:Purpose: convert a density and volume of food in food reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( ( FoodDensity*FoodVolume ) / 0.000618 );
end;

function FCFgCR_OxygenOverload_Calc( const Entity, Colony: integer ): integer;
{:Purpose: calculate the percent of people not supported for the Oxygen Production Overload CSM event.
    Additions:
      -2012May21- *fix: miscalculation when there's no existing production matrix item.
      -2012May15- *fix: forgot an element of calculation for the PPS.
}
   var
      ProdMatrixIdx
      ,IntCalc2
      ,IntCalc3: integer;
begin
   ProdMatrixIdx:=0;
   IntCalc2:=0;
   IntCalc3:=0;
   Result:=0;
   ProdMatrixIdx:=FCFgPS2_ProductionMatrixItem_Search(
      Entity
      ,Colony
      ,'resO2'
      );
   if ProdMatrixIdx=0
   then IntCalc3:=100
   else begin
      IntCalc2:=FCFgCR_OxygenToReserve_Convert( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_productionMatrix[ ProdMatrixIdx ].PM_globalProductionFlow );
      IntCalc3:=round( 100-( IntCalc2 / FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total *100 ) );
   end;
   Result:=IntCalc3;
end;

function FCFgCR_OxygenToReserve_Convert( const OxygenVolume: extended ): integer;
{:Purpose: convert a volume of oxygen in oxygen reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( OxygenVolume / 0.000736 );
end;

function FCFgCR_ReserveToFood_Convert( const FoodPoints: integer; FoodDensity: extended ): extended;
{:Purpose: convert food reserve's points into a volume of food.
    Additions:
}
begin
   Result:=0;
   Result:=FCFcF_Round( rttVolume, ( FoodPoints / FoodDensity ) * 0.000618 );
end;


function FCFgCR_ReserveToOxygen_Convert( const OxygenPoints: integer ): extended;
{:Purpose: convert oxygen reserve's points into a volume of oxygen.
    Additions:
}
begin
   Result:=0;
   Result:=FCFcF_Round( rttVolume, OxygenPoints * 0.000736 );
end;

function FCFgCR_ReserveToWater_Convert( const WaterPoints: integer ): extended;
{:Purpose: convert water reserve's points into a volume of water.
    Additions:
}
   var
      WaterCalc: extended;
begin
   Result:=0;
   WaterCalc:=WaterPoints * 0.018077;
   Result:=FCFcF_Round( rttVolume, WaterCalc );
end;

function FCFgCR_WaterOverload_Calc( const Entity, Colony: integer ): integer;
{:Purpose: calculate the percent of people not supported for the Water Production Overload CSM event.
    Additions:
      -2012May21- *fix: miscalculation when there's no existing production matrix item.
      -2012May15- *fix: forgot an element of calculation for the PPS.
}
   var
      IntCalc1
      ,IntCalc2
      ,IntCalc3: integer;
begin
   IntCalc1:=0;
   IntCalc2:=0;
   IntCalc3:=0;
   Result:=0;
   IntCalc1:=FCFgPS2_ProductionMatrixItem_Search(
      Entity
      ,Colony
      ,'resWater'
      );
   if IntCalc1=0
   then IntCalc3:=100
   else begin
      IntCalc2:=FCFgCR_WaterToReserve_Convert( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_productionMatrix[ IntCalc1 ].PM_globalProductionFlow );
      IntCalc3:=round( 100- (IntCalc2 / FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total *100 ) );
   end;
   Result:=IntCalc3;
end;

function FCFgCR_WaterToReserve_Convert( const WaterVolume: extended ): integer;
{:Purpose: convert a volume of water in water reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( WaterVolume / 0.018077 );
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCR_FoodShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );
{:Purpose: process the calculations for the Food Shortage event.
    Additions:
}
   var
      AgeCoefficient
      ,EnvCoefFracValue
      ,ModifierCalc
      ,PPScalc: extended;

      ColonyEnvironment: TFCRgcEnvironment;
begin
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShPercentPopulationNotSupportedAtCalculation:=NewPPS;
   {.reset the modifiers in the colony's data, if required}
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod<0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod>0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod<0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod>0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod<0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod>0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod
      ,0
      ,gcsmptNone
      ,false
      );
   AgeCoefficient:=FCFgCSM_AgeCoefficient_Retrieve( Entity, Colony );
   if NewPPS<=40 then
   begin
      if NewPPS>10 then
      begin
         ModifierCalc:=SQR( NewPPS ) * ( 0.05 * AgeCoefficient );
         FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod:=- round( ModifierCalc );
         ColonyEnvironment:=FCFgC_ColEnv_GetTp( Entity, Colony );
         case ColonyEnvironment.ENV_envType of
            etFreeLiving: EnvCoefFracValue:=1;

            etRestricted: EnvCoefFracValue:=1.3;

            etSpace: EnvCoefFracValue:=1.7;
         end;
         ModifierCalc:=SQRT( NewPPS ) * ( 5 * EnvCoefFracValue );
         FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod:=round( ModifierCalc );
         if Event>0 then
         begin
            FCMgCSM_ColonyData_Upd(
               dEcoIndusOut
               ,Entity
               ,Colony
               ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod
               ,0
               ,gcsmptNone
               ,false
               );
            FCMgCSM_ColonyData_Upd(
               dTension
               ,Entity
               ,Colony
               ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShTensionMod
               ,0
               ,gcsmptNone
               ,false
               );
         end;
      end;
   end
   else if NewPPS>40 then
   begin
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod:=-100;
      if Event>0
      then FCMgCSM_ColonyData_Upd(
         dEcoIndusOut
         ,Entity
         ,Colony
         ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShEconomicIndustrialOutputMod
         ,0
         ,gcsmptNone
         ,false
         );
   end;
   if NewPPS=100
   then else FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_durationWeeks:=-3;
   ModifierCalc:=SQRT( NewPPS ) * ( 10 * AgeCoefficient );
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod:=- round( ModifierCalc );
   if Event>0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShHealthMod
      ,0
      ,gcsmptNone
      ,false
      );
   {.direct death}
   if (NewPPS>10)
      and ( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShDirectDeathPeriod=0)
   then FCMgCR_FoodShortage_DirectDeath(
      Entity
      ,Colony
      ,Event
      ,AgeCoefficient
      );
end;

procedure FCMgCR_FoodShortage_DirectDeath(
   const Entity
         ,Colony
         ,Event: integer;
   const AgeCoef: extended
   );
{:Purpose: apply and process the direct death calculations for the Food Shortage event.
    Additions:
}
   var
      AgeCoefficient
      ,FracValue
      ,ModifierCalc: extended;

      DeadToApply: integer;
begin
   if AgeCoef=0
   then AgeCoefficient:=FCFgCSM_AgeCoefficient_Retrieve( Entity, Colony )
   else AgeCoefficient:=AgeCoef;
   ModifierCalc:=( SQRT( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShPercentPopulationNotSupportedAtCalculation - 10 ) * ( 4 * AgeCoefficient ) )+FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShDeathFractionalValue;
   ModifierCalc:=FCFcF_Round( rttCustom2Decimal, ModifierCalc );
   DeadToApply:=trunc( ModifierCalc );
   {:DEV NOTES: apply the direct death here, create a method in farc_game_pgs.}
   FracValue:=frac( ModifierCalc );
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShDirectDeathPeriod:=4;
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tFShDeathFractionalValue:=FracValue;
end;

procedure FCMgCR_OxygenShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );
{:Purpose: process the calculations for the Oxygen Shortage event.
    Additions:
}
   var
      SubSFcalc: integer;

      AgeCoefficient
      ,ModifierCalc
      ,SFcalc
      ,PPScalc: extended;
begin
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShPercentPopulationNotSupportedAtCalculation:=NewPPS;
   {.reset the modifiers in the colony's data, if required}
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod<0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod>0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod<0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod>0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod<0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod>0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod
      ,0
      ,gcsmptNone
      ,false
      );
   PPScalc:=NewPPS * 0.01;
   SubSFcalc:=round( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total * PPScalc );
   SFcalc:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total / ( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_population.CP_total - SubSFcalc );
   SFcalc:=FCFcF_Round( rttCustom2Decimal, SFcalc );
   if SFcalc<2.5 then
   begin
      AgeCoefficient:=FCFgCSM_AgeCoefficient_Retrieve( Entity, Colony );
      ModifierCalc:=( 1 - ( 1 / SFcalc ) ) * ( 140 * AgeCoefficient );
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod:=-round( ModifierCalc );
      ModifierCalc:=SQR( SFcalc - 1 ) * 20;
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod:=round( ModifierCalc );
      ModifierCalc:=( SFcalc - 1 ) * ( 40 * AgeCoefficient );
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod:=-round( ModifierCalc );
      if Event>0 then
      begin
         FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShEconomicIndustrialOutputMod
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShTensionMod
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tOShHealthMod
            ,0
            ,gcsmptNone
            ,false
            );
      end;
   end
   {.case if the entire population die}
   else FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_durationWeeks:=-3;
end;

procedure FCMgCR_Reserve_Update(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ReservePointsToXfer: integer;
   const updateStorage: boolean
   );
{:Purpose: update a specified reserve with a +/- value. The value is in reserve points.
    Additions:
      -2012May21- *add: update the food storage in accordance.
      -2012May20- *mod: complete water/oxygen storage calls.
      -2012May17- *add: update the water storage in accordance.
      -2012May17- *add: update the oxygen storage in accordance.
      -2012Apr16- *add: completion.
}
   var
      Count
      ,Max
      ,ProductIdx
      ,ReservesCalc
      ,StorageIdx: integer;

      SumOfStorageUnits
      ,VolumeFromReserve: extended;

      FoodDistribution: array of extended;
begin
   Count:=0;
   Max:=0;
   ProductIdx:=0;
   StorageIdx:=0;
   SumOfStorageUnits:=0;
   VolumeFromReserve:=0;
   setlength( FoodDistribution, 0 );
   case TypeOfReserve of
      pfFood:
      begin
         FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFood:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFood+ReservePointsToXfer;
         if Entity=0
         then FCMuiCDD_Colony_Update(
            cdlReserveFood
            ,Colony
            ,0
            ,0
            ,true
            ,false
            ,false
            );
         if updateStorage then
         begin
            Max:=length( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFoodProductsIndex )-1;
            if length( FoodDistribution )<>Max+1
            then SetLength( FoodDistribution, Max+1 );
            if Max=1 then
            begin
               StorageIdx:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFoodProductsIndex[ Max ];
               ProductIdx:=FCFgP_Product_GetIndex( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_token );
               VolumeFromReserve:=FCFgCR_ReserveToFood_Convert( ReservePointsToXfer, FCDdipProducts[ ProductIdx ].P_massByUnit );
               FCFgC_Storage_Update(
                  FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_token
                  ,VolumeFromReserve
                  ,Entity
                  ,Colony
                  ,false
                  );
            end
            else if Max>1 then
            begin
               count:=1;
               while Count<=Max do
               begin
                  StorageIdx:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFoodProductsIndex[ Count ];
                  SumOfStorageUnits:=SumOfStorageUnits+FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_unit;
                  inc( Count );
               end;
               Count:=1;
               while Count<=Max do
               begin
                  StorageIdx:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveFoodProductsIndex[ Count ];
                  ProductIdx:=FCFgP_Product_GetIndex( FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_token );
                  FoodDistribution[ Count ]:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_unit*100/SumOfStorageUnits;
                  FoodDistribution[ Count ]:=FCFcF_Round( rttCustom1Decimal, FoodDistribution[ Count ] );
                  ReservesCalc:=trunc( ReservePointsToXfer*( FoodDistribution[ Count ]*0.01 ) )+1;
                  VolumeFromReserve:=FCFgCR_ReserveToFood_Convert( ReservesCalc, FCDdipProducts[ ProductIdx ].P_massByUnit );
                  FCFgC_Storage_Update(
                     FCDdgEntities[ Entity ].E_colonies[ Colony ].C_storedProducts[ StorageIdx ].SP_token
                     ,VolumeFromReserve
                     ,Entity
                     ,Colony
                     ,false
                     );
                  inc( Count );
               end;
            end;
         end;
      end; //==END== case: prfuFood ==//

      pfOxygen:
      begin
         FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveOxygen:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveOxygen+ReservePointsToXfer;
         if Entity=0
         then FCMuiCDD_Colony_Update(
            cdlReserveOxy
            ,Colony
            ,0
            ,0
            ,true
            ,false
            ,false
            );
         if updateStorage then
         begin
            VolumeFromReserve:=FCFgCR_ReserveToOxygen_Convert( ReservePointsToXfer );
            FCFgC_Storage_Update(
               'resO2'
               ,VolumeFromReserve
               ,Entity
               ,Colony
               ,false
               );
         end;
      end;

      pfWater:
      begin
         FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveWater:=FCDdgEntities[ Entity ].E_colonies[ Colony ].C_reserveWater+ReservePointsToXfer;
         if Entity=0
         then FCMuiCDD_Colony_Update(
            cdlReserveWater
            ,Colony
            ,0
            ,0
            ,true
            ,false
            ,false
            );
         if updateStorage then
         begin
            VolumeFromReserve:=FCFgCR_ReserveToWater_Convert( ReservePointsToXfer );
            FCFgC_Storage_Update(
               'resWater'
               ,VolumeFromReserve
               ,Entity
               ,Colony
               ,false
               );
         end;
      end;
   end; //==END== case TypeOfReserve of ==//
end;

procedure FCMgCR_Reserve_UpdateByUnits(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier
         ,FoodDensity: extended
   );
{:Purpose: update a specified reserve with a +/- value. The value is in units or more specifically in cubic meters.
    Additions:
      -2012Apr16- *add: completion.
}
   var
      ConvertedModifier: integer;
begin
   ConvertedModifier:=0;
   case TypeOfReserve of
      pfFood: ConvertedModifier:=FCFgCR_FoodToReserve_Convert( ValueModifier, FoodDensity );

      pfOxygen: ConvertedModifier:=FCFgCR_OxygenToReserve_Convert( ValueModifier );

      pfWater: ConvertedModifier:=FCFgCR_WaterToReserve_Convert( ValueModifier );
   end;
   if ConvertedModifier<>0
   then FCMgCR_Reserve_Update(
      Entity
      ,Colony
      ,TypeOfReserve
      ,ConvertedModifier
      ,false
      );
end;

procedure FCMgCR_WaterShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );
{:Purpose: process the calculations for the Water Shortage event.
    Additions:
}
      var
         AgeCoefficient
         ,EnvCoef
         ,ModifierCalc
         ,PPScalc: extended;

         ColonyEnvironment: TFCRgcEnvironment;
begin
   FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShPercentPopulationNotSupportedAtCalculation:=NewPPS;
   {.reset the modifiers in the colony's data, if required}
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod<0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod>0
   then FCMgCSM_ColonyData_Upd(
      dEcoIndusOut
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod<0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod>0
   then FCMgCSM_ColonyData_Upd(
      dTension
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod
      ,0
      ,gcsmptNone
      ,false
      );
   if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod<0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,abs( FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod )
      ,0
      ,gcsmptNone
      ,false
      )
   else if FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod>0
   then FCMgCSM_ColonyData_Upd(
      dHealth
      ,Entity
      ,Colony
      ,-FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod
      ,0
      ,gcsmptNone
      ,false
      );
   if ( NewPPS>2 )
      and ( NewPPS<=15 ) then
   begin
      AgeCoefficient:=FCFgCSM_AgeCoefficient_Retrieve( Entity, Colony );
      if NewPPS>6 then
      begin
         ModifierCalc:=( NewPPS - 6 ) * ( 5 * AgeCoefficient );
         FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod:=-round( ModifierCalc );
         if Event>0
         then FCMgCSM_ColonyData_Upd(
            dEcoIndusOut
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShEconomicIndustrialOutputMod
            ,0
            ,gcsmptNone
            ,false
            );
      end;
      ColonyEnvironment:=FCFgC_ColEnv_GetTp( Entity, Colony );
      EnvCoef:=0;
      case ColonyEnvironment.ENV_envType of
         etFreeLiving: if ColonyEnvironment.ENV_hydroTp<>hWaterLiquid
            then EnvCoef:=1
            else EnvCoef:=0.39;

         etRestricted: if ColonyEnvironment.ENV_hydroTp<>hWaterLiquid
            then EnvCoef:=1.8
            else EnvCoef:=0.83;

         etSpace: if ColonyEnvironment.ENV_hydroTp<>hWaterLiquid
            then EnvCoef:=1.8
            else EnvCoef:=1;
      end;
      ModifierCalc:=( NewPPS * 1.7 ) * EnvCoef;
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod:=round( ModifierCalc );
      ModifierCalc:=( NewPPS - 1 ) * AgeCoefficient;
      FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod:=-round( ModifierCalc );
      if Event>0 then
      begin
         FCMgCSM_ColonyData_Upd(
            dTension
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShTensionMod
            ,0
            ,gcsmptNone
            ,false
            );
         FCMgCSM_ColonyData_Upd(
            dHealth
            ,Entity
            ,Colony
            ,FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_tWShHealthMod
            ,0
            ,gcsmptNone
            ,false
            );
      end;
   end //==END==  if ( NewPPS>2 ) and ( NewPPS<=15 ) ==//
   {.case if the entire population die}
   else if NewPPS>15
   then FCDdgEntities[Entity].E_colonies[Colony].C_events[Event].CCSME_durationWeeks:=-3;
end;

end.
