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

//===========================END FUNCTIONS SECTION==========================================

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
procedure FCMgCR_Reserve_UpdateByUnits(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier: extended
   );

implementation

uses
   farc_data_game
   ,farc_ui_coredatadisplay;

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgCR_Reserve_Update(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier: integer
   );
{:Purpose: update a specified reserve with a +/- value. The value is in reserve points.
    Additions:
}
begin
   case TypeOfReserve of
      prfuFood: FCentities[ Entity ].E_col[ Colony ].COL_reserveFood:=FCentities[ Entity ].E_col[ Colony ].COL_reserveFood+ValueModifier;

      prfuOxygen: FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen:=FCentities[ Entity ].E_col[ Colony ].COL_reserveOxygen+ValueModifier;


      prfuWater: FCentities[ Entity ].E_col[ Colony ].COL_reserveWater:=FCentities[ Entity ].E_col[ Colony ].COL_reserveWater+ValueModifier;
   end;
   FCMuiCDD_Colony_Update(
      );
end;

procedure FCMgCR_Reserve_UpdateByUnits(
   const Entity
         ,Colony: integer;
   const TypeOfReserve: TFCEdipProductFunctions;
   const ValueModifier: extended
   );
{:Purpose: update a specified reserve with a +/- value. The value is in units or more specifically in cubic meters.
    Additions:
}
begin

end;

end.
