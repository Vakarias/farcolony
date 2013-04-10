{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - data unit

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
unit farc_fug_data;

interface

uses
   farc_data_univ;

//==END PUBLIC ENUM=========================================================================

///<summary>
///   FUG orbits to generate
///</summary>
type TFCRfdStarOrbits= array[0..3] of integer;


///<summary>
///   FUG system type
///</summary>
type TFCRfdSystemType= array[0..3] of integer;

type TFCDfdMainStarObjectsList= array of TFCRduOrbitalObject;

type TFCDfdComp1StarObjectsList= array of TFCRduOrbitalObject;

type TFCDfdComp2StarObjectsList= array of TFCRduOrbitalObject;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   FCDfdMainStarObjectsList: TFCDfdMainStarObjectsList;

   FCDfdComp1StarObjectsList: TFCDfdComp1StarObjectsList;

   FCDfdComp2StarObjectsList: TFCDfdComp2StarObjectsList;

   ///<summary>
   ///   FUG orbits to generate - temp data
   ///</summary>
   FCRfdStarOrbits: TFCRfdStarOrbits;

   ///<summary>
   ///   FUG system type - temp data
   ///</summary>
   FCRfdSystemType: TFCRfdSystemType;
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

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
//===========================END FUNCTIONS SECTION==========================================

end.
