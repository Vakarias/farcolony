{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: production system & products - core unit

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
unit farc_game_prod;

interface

///<summary>
///   return the index #, in the database, of a given product
///</summary>
///   <param name="PGIproduct">product token</param>
function FCFgP_Product_GetIndex(const PGIproduct: string): integer;

///<summary>
///   get a formatted text of the unit/volume of a product
///</summary>
///   <param name="Product">product's token</param>
///   <param name="ProdUnits">the unit value to display</param>
///   <param name="RelatedString">the string to add in the format</param>
///   <param name="isValueinHTMLbold">if true, the value is displayed in bold HTML format</param>
///   <param name="isIncludeSign">if true, the value's sign is added</param>
///   <returns>if the vol/m3 is = 1, then a "x,xxx.xxx m3" format is returned, if it's>1, then a "xn,nnn" format is returned</returns>
function FCFgP_StringFromUnit_Get(
   const Product: string;
   const ProdUnits: extended;
   const RelatedString: string;
   const isValueinHTMLbold
         ,isIncludeSign: boolean
   ): string;

///<summary>
///   returns the number of units, of a specified product, by giving a volume value. This function is useful because when a product has a volume by unit <> 1, it doesn't convert directly
///</summary>
///   <param name="UFVGdbproductIndex">DB product index #</param>
///   <param name="UFVGvolume">volume in cubic meters</param>
///   <returns>a formatted (x.xxx) float</returns>
function FCFgP_UnitFromVolume_Get( const UFVGdbproductIndex: integer; UFVGvolume: extended ): extended; overload;

///<summary>
///   returns the number of units, of a specified product, by giving a volume value. This function is useful because when a product has a volume by unit <> 1, it doesn't convert directly
///</summary>
///   <param name="UFVGdbproductToken">DB product token</param>
///   <param name="UFVGvolume">volume in cubic meters</param>
///   <returns>a formatted (x.xxx) float</returns>
function FCFgP_UnitFromVolume_Get( const UFVGdbproductToken: string; UFVGvolume: extended ): extended; overload;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   production phase, core routine
///</summary>
procedure FCMgP_PhaseCore_Process;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_infrprod
   ,farc_game_prodSeg1
   ,farc_game_prodSeg2
   ,farc_game_prodSeg5;

var
   GPmaxProducts: integer;

//===================================================END OF INIT============================

function FCFgP_Product_GetIndex(const PGIproduct: string): integer;
{:Purpose: return the index #, in the database, of a given product.
    Additions:
}
var
   PGIcnt: integer;
begin
   Result:=-1;
   if GPmaxProducts=0
   then GPmaxProducts:=length(FCDBProducts)-1;
   PGIcnt:=1;
   while PGIcnt<=GPmaxProducts do
   begin
      if FCDBProducts[PGIcnt].PROD_token=PGIproduct
      then
      begin
         Result:=PGIcnt;
         break;
      end;
      inc(PGIcnt);
   end;
end;

function FCFgP_StringFromUnit_Get(
   const Product: string;
   const ProdUnits: extended;
   const RelatedString: string;
   const isValueinHTMLbold
         ,isIncludeSign: boolean
   ): string;
{:Purpose: get a formatted text of the unit/volume of a product.
    Additions:
      -2012Feb05- *add: isIncludeSign parameter to include the sign '+' or '-' if required.
}
   var
      ProdIndex: integer;

      BoldHTML
      ,BoldHTMLend
      ,SignString: string;
begin
   ProdIndex:=0;
   Result:='';
   SignString:='';
   if not isValueinHTMLbold then
   begin
      BoldHTML:='';
      BoldHTMLend:='';
   end
   else begin
      BoldHTML:='<b>';
      BoldHTMLend:='</b>';
   end;
   if ( isIncludeSign )
      and ( ProdUnits<0 )
   then SignString:='-'
   else if ( isIncludeSign )
      and ( ProdUnits>0 )
   then SignString:='+';
   ProdIndex:=FCFgP_Product_GetIndex( Product );
   if FCDBProducts[ ProdIndex ].PROD_volByUnit=1
   then Result:=RelatedString+' '+SignString+BoldHTML+FCFcFunc_ThSep( ProdUnits, ',' )+BoldHTMLend+' m3'
   else if FCDBProducts[ ProdIndex ].PROD_volByUnit<>1
   then Result:=RelatedString+' '+SignString+BoldHTML+FCFcFunc_ThSep( ProdUnits, ',' )+BoldHTMLend;
end;

function FCFgP_UnitFromVolume_Get( const UFVGdbproductIndex: integer; UFVGvolume: extended ): extended; overload;
{:Purpose: returns the number of units, of a specified product, by giving a volume value. This function is useful because when a product has a volume by unit <> 1, it doesn't convert directly.
    Additions:
      -2012Jan09- *fix: take in account when volbyunit<1 too.
}
   var
      UFVGworkingData: extended;
begin
   Result:=0;
   if FCDBProducts[ UFVGdbproductIndex ].PROD_volByUnit=1
   then Result:=FCFcFunc_Rnd( cfrttpVolm3, UFVGvolume )
   else if FCDBProducts[ UFVGdbproductIndex ].PROD_volByUnit<>1 then
   begin
      UFVGworkingData:=UFVGvolume / FCDBProducts[ UFVGdbproductIndex ].PROD_volByUnit;
      Result:=int( UFVGworkingData )+1;
   end;
end;

function FCFgP_UnitFromVolume_Get( const UFVGdbproductToken: string; UFVGvolume: extended ): extended; overload;
{:Purpose: returns the number of units, of a specified product, by giving a volume value. This function is useful because when a product has a volume by unit <> 1, it doesn't convert directly.
      Additions:
}
   var
      UFVGindex: integer;
begin
   Result:=0;
   UFVGindex:=FCFgP_Product_GetIndex( UFVGdbproductToken );
   Result:=FCFgP_UnitFromVolume_Get( UFVGindex, UFVGvolume );
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMgP_PhaseCore_Process;
{:Purpose: production phase, core routine.
    Additions:
      -2011Sep06- *add: CAB/Transition segment link.
      -2011Jul25- *add: production segment 2 link.
      -2011Jul14- *fix: apply correction in the second while loop by increasing the correct data.
}
   var
      PCPfacCount
      ,PCPcolCount
      ,PCPcolMax: integer;
begin
   PCPfacCount:=0;
   while PCPfacCount<=FCCfacMax do
   begin
      PCPcolMax:=length(FCentities[PCPfacCount].E_col)-1;
      if PCPcolMax>0
      then
      begin
         PCPcolCount:=1;
         while PCPcolCount<=PCPcolMax do
         begin
            {.1st segment: energy.}
            FCMgPS1_EnergySegment_Process(PCPfacCount, PCPcolCount);
            {.2nd segment, items production, test the production matrix here.}
            FCMgPS2_ProductionSegment_Process(PCPfacCount, PCPcolCount);
            {:DEV NOTES: 3rd segment, reserves testing each 24hours.}
            {:DEV NOTES: post 1st alpha: 4th segment, space unit manufacturing.}
            {.5th segment, CAB queue processing.}
            FCMgPS5_CABTransitionSegment_Process(PCPfacCount, PCPcolCount);
            inc(PCPcolCount);
         end;
      end;
      inc(PCPfacCount);
   end;
end;

end.
