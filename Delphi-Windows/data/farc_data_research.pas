{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: research and technosciences data structures

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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

   //=======================================================================================
   {.infrastructures data}
   //=======================================================================================
   {.research sectors}
   {:DEV NOTES: update infrastrucdb.xml + productsdb.xml + FCMdF_DBInfra_Read + FCMdF_DBProducts_Read + FCMdF_DBTechnosciences_Load.}
   type TFCEdresResearchSectors=(
      rsNone
      ,rsAerospaceEng
      ,rsBiogenetics
      ,rsEcosciences
      ,rsIndustrialTech
      ,rsMedicine
      ,rsNanotech
      ,rsPhysics
      );
   {.research stages}
   {:DEV NOTES: update .}
   type TFCEdresResearchStages=(
      rstNotMastered
      ,rstAtTheory
      ,rstAtExperiment
      ,rstAtApplication
      );
   {.research types}
   {:DEV NOTES: update FCMdF_DBTechnosciences_Load.}
   type TFCEdresResearchTypes=(
      rtBasicTech
      ,rtPureTheory
      ,rtExpResearch
      ,rtCompleteResearch
      );
   //==END ENUM=============================================================================
   
   {.technoscience data structure}
   {:DEV NOTES: update technosciencesdb.xml + FCMdF_DBTechnosciences_Load.}
   type TFCRdresTechnoscience= record
      T_token: string[20];
      T_researchSector: TFCEdresResearchSectors;
      T_level: integer;
      T_type: TFCEdresResearchTypes;
      T_difficulty: integer;
   end;
   TFCDBtechsci= array of TFCRdresTechnoscience;
   //=======================================================================================
   {.global variables}
   //=======================================================================================

   var
      FCDBtechsci: TFCDBtechsci;

implementation

//=============================================END OF INIT==================================

end.
