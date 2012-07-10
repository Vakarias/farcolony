{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: population growth system (PGS) / population - data unit

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
unit farc_data_pgs;

interface

//uses


{:REFERENCES LIST
   - infrastrucdb.xml
   - FCMdF_DBInfra_Read
   - FCFgIS_RequiredStaff_Test   FCMgIS_RequiredStaff_Recover
}
///<summary>
///   population types, used for all other data structures than colony's population
///</summary>
type TFCEdpgsPopulationTypes=(
   ptColonist
   ,ptOfficer
   ,ptMissionSpecialist
   ,ptBiologist
   ,ptDoctor
   ,ptTechnician
   ,ptEngineer
   ,ptSoldier
   ,ptCommando
   ,ptPhysicist
   ,ptAstrophysicist
   ,ptEcologist
   ,ptEcoformer
   ,ptMedian
   ,ptRebels
   ,ptMilitia
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
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
