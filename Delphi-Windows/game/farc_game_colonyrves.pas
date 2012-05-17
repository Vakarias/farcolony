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
   farc_data_infrprod;


///<summary>
///   convert a density and volume of food in food reserve's points
///</summary>
///   <param name="FoodVolume">food volume, in cubic meters, to convert</param>
///   <param name="FoodDensity">food density, in t / units, to convert</param>
///   <returns>the converted oxygen reserve's points</returns>
function FCFgCR_Food_Convert( const FoodVolume, FoodDensity: extended ): integer;

///<summary>
///   calculate the percent of people not supported for the food Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_FoodOverload_Calc( const Entity, Colony: integer ): integer;

///<summary>
///   convert a volume of oxygen in oxygen reserve's points
///</summary>
///   <param name="OxygenVolume">oxygen volume, in cubic meters, to convert</param>
///   <returns>the converted oxygen reserve's points</returns>
function FCFgCR_Oxygen_Convert( const OxygenVolume: extended ): integer;

///<summary>
///   calculate the percent of people not supported for the Oxygen Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_OxygenOverload_Calc( const Entity, Colony: integer ): integer;

///<summary>
///   convert a volume of water in water reserve's points
///</summary>
///   <param name="WaterVolume">oxygen volume, in cubic meters, to convert</param>
///   <returns>the converted water reserve's points</returns>
function FCFgCR_Water_Convert( const WaterVolume: extended ): integer;

///<summary>
///   calculate the percent of people not supported for the Water Production Overload CSM event
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <returns>the percent of people not supported</returns>
function FCFgCR_WaterOverload_Calc( const Entity, Colony: integer ): integer;

//===========================END FUNCTIONS SECTION==========================================

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
   const ValueModifier: integer
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

implementation

uses
   farc_data_game
   ,farc_game_prod
   ,farc_game_prodSeg2
   ,farc_ui_coredatadisplay;

//===================================================END OF INIT============================

function FCFgCR_Food_Convert( const FoodVolume, FoodDensity: extended ): integer;
{:Purpose: convert a density and volume of food in food reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( ( FoodDensity*FoodVolume ) / 0.000618 );
end;

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
   ProdMatrixItemMax:=length( FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix )-1;
   while ProdMatrixItemCount<=ProdMatrixItemMax do
   begin
      ProdMatrixItemProduct:=FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix[ ProdMatrixItemCount ].CPMI_productToken;
      ProductIndex:=FCFgP_Product_GetIndex( ProdMatrixItemProduct );
      if FCDBProducts[ ProductIndex ].PROD_function=prfuFood then
      begin
         FoodPointCalculated:=FCFgCR_Food_Convert( FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix[ ProdMatrixItemCount ].CPMI_globalProdFlow, FCDBProducts[ ProductIndex ].PROD_massByUnit );
         TotalProductionRvePoints:=TotalProductionRvePoints+FoodPointCalculated;
      end;
      inc( ProdMatrixItemCount );
   end;
   PPS:=round( 100- ( TotalProductionRvePoints / FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total *100 ) );
   Result:=PPS;
end;

function FCFgCR_Oxygen_Convert( const OxygenVolume: extended ): integer;
{:Purpose: convert a volume of oxygen in oxygen reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( OxygenVolume / 0.000736 );
end;

function FCFgCR_OxygenOverload_Calc( const Entity, Colony: integer ): integer;
{:Purpose: calculate the percent of people not supported for the Oxygen Production Overload CSM event.
    Additions:
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
      ,'resO2'
      );
   if IntCalc1=0
   then IntCalc3:=0
   else begin
      IntCalc2:=FCFgCR_Oxygen_Convert( FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix[ IntCalc1 ].CPMI_globalProdFlow );
      IntCalc3:=round( 100-( IntCalc2 / FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total *100 ) );
   end;
   Result:=IntCalc3;
end;

function FCFgCR_Water_Convert( const WaterVolume: extended ): integer;
{:Purpose: convert a volume of water in water reserve's points.
    Additions:
}
begin
   Result:=0;
   Result:=trunc( WaterVolume / 0.018077 );
end;

function FCFgCR_WaterOverload_Calc( const Entity, Colony: integer ): integer;
{:Purpose: calculate the percent of people not supported for the Water Production Overload CSM event.
    Additions:
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
   then IntCalc3:=0
   else begin
      IntCalc2:=FCFgCR_Water_Convert( FCentities[ Entity ].E_col[ Colony ].COL_productionMatrix[ IntCalc1 ].CPMI_globalProdFlow );
      IntCalc3:=round( 100- (IntCalc2 / FCentities[ Entity ].E_col[ Colony ].COL_population.POP_total *100 ) );
   end;
   Result:=IntCalc3;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCR_OxygenShortage_Calc(
   const Entity
         ,Colony
         ,Event
         ,NewPPS: integer
   );
{:Purpose: process the calculations for the Oxygen Shortage event.
    Additions:
}
begin

end;

procedure FCMgCR_Reserve_Update(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier: integer
   );
{:Purpose: update a specified reserve with a +/- value. The value is in reserve points.
    Additions:
      -2012Apr16- *add: completion.
}
begin
   case TypeOfReserve of
      prfuFood:
      begin
         FCentities[ Entity ].E_col[ Colony ].COL_reserveFood:=FCentities[ Entity ].E_col[ Colony ].COL_reserveFood+ValueModifier;
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
      end;

      prfuOxygen:
      begin
         FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen:=FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen+ValueModifier;
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
      end;

      prfuWater:
      begin
         FCentities[ Entity ].E_col[ Colony ].COL_reserveWater:=FCentities[ Entity ].E_col[ Colony ].COL_reserveWater+ValueModifier;
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
      end;
   end;
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
      prfuFood: ConvertedModifier:=FCFgCR_Food_Convert( ValueModifier, FoodDensity );

      prfuOxygen: ConvertedModifier:=FCFgCR_Oxygen_Convert( ValueModifier );

      prfuWater: ConvertedModifier:=FCFgCR_Water_Convert( ValueModifier );
   end;
   if ConvertedModifier<>0
   then FCMgCR_Reserve_Update(
      Entity
      ,Colony
      ,TypeOfReserve
      ,ConvertedModifier
      );
end;

end.
