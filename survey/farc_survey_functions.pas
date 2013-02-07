{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: planetary survey - common functions unit

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
unit farc_survey_functions;

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
///   generate a listing of available survey vehicles into a colony's storage
///</summary>
///   <param name="Entity">entity index #</param>
///   <param name="Colony">colony index #</param>
///   <param name="GenerateDetailedList">[true]=generate the detailed list in FCDsfSurveyVehicles</param>
///   <returns>the # of different products that are survey vehicles</returns>
///   <remarks>FCDsfSurveyVehicles is reseted whatever the value of FCDsfSurveyVehicles</remarks>
function FCFsF_SurveyVehicles_Get(
   const Entity, Colony: integer;
   const GenerateDetailedList: boolean
   ): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_game
   ,farc_data_infrprod
   ,farc_data_planetarysurvey
   ,farc_game_prod;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFsF_SurveyVehicles_Get(
   const Entity, Colony: integer;
   const GenerateDetailedList: boolean
   ): integer;
{:Purpose: generate a listing of available survey vehicles into a colony's storage.
    Additions:
}
   var
      Count
      ,Max
      ,VehiclesProducts: integer;

      ClonedProduct: TFCRdipProduct;
begin
   Result:=0;
   VehiclesProducts:=0;
   SetLength( FCDsfSurveyVehicles, 0 );
   Max:=length( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts )-1;
   SetLength( FCDsfSurveyVehicles, Max+1 );
   Count:=1;
   while Count<=Max do
   begin
      ClonedProduct:=FCDdipProducts[FCFgP_Product_GetIndex( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_token )];
      if ( ClonedProduct.P_function in [pfSurveyAir..pfSurveySwarmAntigrav] )
         and ( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_unit>0 ) then
      begin
         inc( VehiclesProducts );
         if GenerateDetailedList then
         begin
            FCDsfSurveyVehicles[VehiclesProducts].SV_storageIndex:=Count;
            FCDsfSurveyVehicles[VehiclesProducts].SV_storageUnits:=Trunc( FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_unit );
            FCDsfSurveyVehicles[VehiclesProducts].SV_token:=FCDdgEntities[Entity].E_colonies[Colony].C_storedProducts[Count].SP_token;
            FCDsfSurveyVehicles[VehiclesProducts].SV_function:=ClonedProduct.P_function;
            FCDsfSurveyVehicles[VehiclesProducts].SV_speed:=ClonedProduct.P_fSspeed;
            FCDsfSurveyVehicles[VehiclesProducts].SV_missionTime:=ClonedProduct.P_fSmissionTime;
            FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityResources:=ClonedProduct.P_fScapabilityResources;
            FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityBiosphere:=ClonedProduct.P_fScapabilityBiosphere;
            FCDsfSurveyVehicles[VehiclesProducts].SV_capabilityFeaturesArtifacts:=ClonedProduct.P_fScapabilityFeaturesArtifacts;
            FCDsfSurveyVehicles[VehiclesProducts].SV_crew:=ClonedProduct.P_fScrew;
            FCDsfSurveyVehicles[VehiclesProducts].SV_numberOfVehicles:=ClonedProduct.P_fSvehicles;
         end;
      end;
      inc( Count );
   end;
   Result:=VehiclesProducts;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
