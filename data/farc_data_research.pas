{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research and technosciences data structures

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
unit farc_data_research;

interface

//uses

{:REFERENCES LIST
   - infrastrucdb.xml
   - productsdb.xml
   - FCMdF_DBInfra_Read
   - FCMdF_DBProducts_Read
   - FCMdF_DBTechnosciences_Load
}
///<summary>
///   research sectors
///</summary>
type TFCEdrResearchSectors=(
   rsNone
   ,rsAerospaceEngineering
   ,rsBiogenetics
   ,rsEcosciences
   ,rsIndustrialTech
   ,rsMedicine
   ,rsNanotech
   ,rsPhysics
   );

{:REFERENCES LIST
   -
}
///<summary>
///   research stages
///</summary>
type TTFCEdrResearchStages=(
   rsNotMastered
   ,rsAtTheory
   ,rsAtExperiment
   ,rsAtApplication
   );

{:REFERENCES LIST
   - FCMdF_DBTechnosciences_Load
}
///<summary>
///   research types
///</summary>
type TFCEdrResearchTypes=(
   rtBasicTech
   ,rtPureTheory
   ,rtExpResearch
   ,rtCompleteResearch
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - technosciencesdb.xml
   - FCMdF_DBTechnosciences_Load
}
///<summary>
///   technoscience data structure
///</summary>
type TFCRdrTechnoscience= record
   T_token: string[20];
   T_researchSector: TFCEdrResearchSectors;
   T_level: integer;
   T_type: TFCEdrResearchTypes;
   T_difficulty: integer;
end;
   TFCDBtechsci= array of TFCRdrTechnoscience;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
var
   ///<summary>
   ///   database technosciences
   ///</summary>
   FCDBtechsci: TFCDBtechsci;
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
