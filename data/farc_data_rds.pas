{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research & development system (RDS) - data unit

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
unit farc_data_rds;

interface

uses
   farc_data_init;

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCEdrdsInfluenceProjectionTypes=(
   iptProduct
   ,iptInfrastructure
   ,iptSpaceUnitArchitecture
   ,iptEquipmentModule
   ,iptSPMItem
   );

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCEdrdsResearchDomains=(
   rdAerospaceengineering
   ,rdAstroEngineering
   ,rdBiosciences
   ,rdCulture
   ,rdEcosciences
   ,rdIndustrialTechnologies
   ,rdNanotechnology
   ,rdPhysics
   );

type TFCEdrdsResearchFields=(
   rf1AerospaceTechnics
   ,rf1SpaceArchitecture
   ,rf1SpaceDrives
   ,rf2Astrophysics
   ,rf2SpaceEngineering
   ,rf3Biotechnologies
   ,rf3Medicine
   ,rf3Neuroscience
   ,rf4Communication
   ,rf4Entertainment
   ,rf4MemeticEngineering
   ,rf5Ecology
   ,rf5Planetology
   ,rf6Automation
   ,rf6Computing
   ,rf6IndustrialTechnics
   ,rt6Materials
   ,rt7MechanicalNanotechnology
   ,rt7MolecularNanotechnology
   ,rt7Nanomaterials
   ,rt8Energy
   ,rt8NuclearPhysics
   ,rt8ParticlesPhysics
   );

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCEdrdsTechnologyLevels=(
   tl01IndustrialAge
   ,tl02RoboticAge
   ,tl03InformationAge
   ,tl04CyberAge
   ,tl05InterplanetaryAge
   ,tl06TranshumanismAge
   ,tl07SingularityAge
   ,tl08InterstellarAge
   ,tl09NanoAge
   ,tl10UnificationAge
   ,tl11EnlightementAge
   ,tl12MegatechAge
   ,tl13TranscendenceAge
   ,tl14KardashevAge
   ,tl15GalacticAge
   ,tl16AIgodsAge
   ,tl17DimensionalAge
   ,tl18InfinityAge
   );

//==END PUBLIC ENUM=========================================================================

type TFCRdrdsInfluenceProjection= record
   IP_token: string[20];
   IP_type: TFCEdrdsInfluenceProjectionTypes;
end;

type TFCRdrdsRelatedTechnoscience=  record
   RTS_domain: TFCEdrdsResearchDomains;
   RTS_token: string[20];
   RTS_isKeyTech: boolean;
   RTS_rawInfluence: integer;
end;

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCRdrdsTechnoscience = record
   TS_token: string[20];
   TS_techLevel: TFCEdrdsTechnologyLevels;
   TS_difficulty: integer;
   TS_discoveryThreshold: integer;
   TS_relatedTechnosciences: array of TFCRdrdsRelatedTechnoscience;
   TS_influenceProjections: array of TFCRdrdsInfluenceProjection;
end;

{:REFERENCES LIST
   -
}
///<summary>
///
///</summary>
type TFCRdrdsResearchDomain = record
   RD_type: TFCEdrdsResearchDomains;
   RD_researchFields: array of record
      RF_type: TFCEdrdsResearchFields;
      RF_technoscience: array of TFCRdrdsTechnoscience;
   end;
end;

   TFCDdrdsResearchDatabase = array[0..FCCdiRDSdomainsMax] of TFCRdrdsResearchDomain;

//==END PUBLIC RECORDS======================================================================


var
   //==========databases and other data structures pre-init=================================
   FCDdrdsResearchDatabase: TFCDdrdsResearchDatabase;


//==END PUBLIC VAR==========================================================================

//const
  // FCCdgWeekInTicks=1008;

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