{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Regions - functions unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

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
unit farc_fug_regionfunctions;

interface

//uses

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   retrieve the index # of the reference region, given the total of regions
///</summary>
///   <param name="TotalRegions">total # of regions</param>
///   <returns>the index # of the reference region</returns>
///   <remarks></remarks>
function FCFfrF_ReferenceRegion_GetIndex( const TotalRegions: integer ): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfrF_ReferenceRegion_GetIndex( const TotalRegions: integer ): integer;
{:Purpose: retrieve the index # of the reference region, given the total of regions.
    Additions:
}
begin
   Result:=0;
   case TotalRegions of
      4, 6, 8: Result:=3;

      10: Result:=4;

      14, 18: Result:=8;

      22: Result:=9;

      26: Result:=11;

      30: Result:=12;
   end; //==END== case Max of ==//
end;

//===========================END FUNCTIONS SECTION==========================================

end.
