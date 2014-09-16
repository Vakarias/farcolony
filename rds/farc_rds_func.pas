{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research & development system (RDS) - common functions unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

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
unit farc_rds_func;

interface

uses
   farc_data_game
   ,farc_data_rds;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   return the number of research fields for a particular domain. These hardcoded number are located only into this function for the entire FARC code
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
function FCFrdsF_Domain_GetNumberOfResearchFields( const ResearchDomain: TFCEdrdsResearchDomains ): integer;

{:DEV NOTES: this function below is just a skeleton for now, remove it if it is of no use.}
///<summary>
///   calculate the influence value
///</summary>
/// <param name=""></param>
/// <param name=""></param>
/// <param name=""></param>
/// <returns></returns>
/// <remarks></remarks>
function FCFrdsF_RelatedTechnoscienceInfluence_Calc(
   const RawInfluence: integer;
   const CurrentDevLevel: TFCEdgTechnoscienceMasteringStages
   ): integer;

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

function FCFrdsF_Domain_GetNumberOfResearchFields( const ResearchDomain: TFCEdrdsResearchDomains ): integer;
{:Purpose: return the number of research fields for a particular domain. These hardcoded number are located only into this function for the entire FARC code.
    Additions:
      -2014Sep15- *fix: put the correct number of research fields for the Culture research domain.
}
begin
   Result:=0;
   case ResearchDomain of
      rdAerospaceengineering: Result:=3;

      rdAstroEngineering: Result:=2;

      rdBiosciences: Result:=3;

      rdCulture: Result:=4;

      rdEcosciences: Result:=2;

      rdIndustrialTechnologies: Result:=4;

      rdNanotechnology: Result:=3;

      rdPhysics: Result:=3;
   end;
end;


function FCFrdsF_RelatedTechnoscienceInfluence_Calc(
   const RawInfluence: integer;
   const CurrentDevLevel: TFCEdgTechnoscienceMasteringStages
   ): integer;
{:Purpose: calculate the influence value.
   Additions:
}
begin

end;

//===========================END FUNCTIONS SECTION==========================================

end.
