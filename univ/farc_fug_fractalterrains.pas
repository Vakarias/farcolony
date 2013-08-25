{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - Fractal Terrains data linking unit

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
unit farc_fug_fractalterrains;

interface

uses
   Forms
   ,SysUtils;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   initialize the interface and pause the generation to allow to generate the surface maps into Fractal Terrains and manually adjust, if needed, the land type and relief for each region
///</summary>
/// <param name="Star">star index #</param>
/// <param name="OrbitalObject">orbital object index #</param>
/// <param name="Satellite">OPTIONAL: satellite index #</param>
/// <returns></returns>
/// <remarks></remarks>
procedure FCMfT_DataLinking_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );

implementation

uses
   farc_data_univ
   ,farc_fug_com
   ,farc_fug_data
   ,farc_fug_regionfunctions
   ,farc_univ_func
   ,farc_win_fug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMfT_DataLinking_Process(
   const Star
         ,OrbitalObject: integer;
   const Satellite: integer=0
   );
{:Purpose: initialize the interface and pause the generation to allow to generate the surface maps into Fractal Terrains and manually adjust, if needed, the land type and relief for each region.
   Additions:
}
   var
      Count
      ,Count1
      ,HydrosphereArea
      ,Max: integer;

      Albedo
      ,AxialTilt
      ,Diameter
      ,fCalc1
      ,Gravity
      ,Greenhouse
      ,Variance
      ,X
      ,Y: extended;

      Hydrosphere: TFCEduHydrospheres;
begin
   Count:=0;
   Count1:=0;
   HydrosphereArea:=0;
   Max:=0;

   Albedo:=0;
   AxialTilt:=0;
   Diameter:=0;
   fCalc1:=0;
   Gravity:=0;
   Greenhouse:=0;
   Variance:=0;
   X:=0;
   Y:=0;

   Hydrosphere:=hNoHydro;

   FUGpaused:=false;

   if Satellite = 0 then
   begin
      { RotationPeriod:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_rotationPeriod;
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_atmosphericPressure;
      {.the clouds cover loaded into fCalc0 is only used for the surface temperatures subsection. It can be used afterward}
      { fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      //ObjectSurfaceTempClosest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      //optClosest
      //,0
      //,Star
      //,OrbitalObject
      //);
      //ObjectSurfaceTempInterm:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      //optIntermediary
      //,0
      //,Star
      //,OrbitalObject
      //);
      //ObjectSurfaceTempFarthest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      //optFarthest
      //,0
      //,Star
      //,OrbitalObject
      //);
                                                                                              }
      Greenhouse:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_Greenhouse;
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter;
      AxialTilt:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
//      case FCWinFUG.TOO_StarPicker.ItemIndex of
//         0: setlength( FCDfdMainStarObjectsList[OrbitalObject].OO_regions, Max + 1 );
//
//         1: setlength( FCDfdComp1StarObjectsList[OrbitalObject].OO_regions, Max + 1 );
//
//         2: setlength( FCDfdComp2StarObjectsList[OrbitalObject].OO_regions, Max + 1 );
//      end;
   end
   else if Satellite > 0 then
   begin


      { RotationPeriod:=FCFuF_Satellite_GetRotationPeriod(
      0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      AtmospherePressure:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_atmosphericPressure;
      {.the clouds cover loaded into fCalc0 is only used for the surface temperatures subsection. It can be used afterward}
      { fCalc0:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;

      ObjectSurfaceTempClosest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optClosest
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      ObjectSurfaceTempInterm:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optIntermediary
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );
      ObjectSurfaceTempFarthest:=FCFuF_OrbitalPeriodSpecified_GetSurfaceTemperature(
      optFarthest
      ,0
      ,Star
      ,OrbitalObject
      ,Satellite
      );   }
      Greenhouse:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_fug_Greenhouse;
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_Diameter;
      AxialTilt:=FCFuF_Satellite_GetAxialTilt(
         0
         ,Star
         ,OrbitalObject
         ,Satellite
         );
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_albedo;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_gravity;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
//      case FCWinFUG.TOO_StarPicker.ItemIndex of
//         0: setlength( FCDfdMainStarObjectsList[OrbitalObject].OO_satellitesList[Satellite].OO_regions, Max + 1 );
//
//         1: setlength( FCDfdComp1StarObjectsList[OrbitalObject].OO_satellitesList[Satellite].OO_regions, Max + 1 );
//
//         2: setlength( FCDfdComp2StarObjectsList[OrbitalObject].OO_satellitesList[Satellite].OO_regions, Max + 1 );
//      end;
   end;
   {.call the interface to display the land and relief data of the current orbital object in the loop}
   FCWinFUG.TOO_StarPicker.ItemIndex:=Star - 1;
   FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex:=OrbitalObject - 1;
   FCWinFUG.TOO_SatPicker.ItemIndex:=Satellite - 1;
   FCWinFUG.TOO_StarPicker.Enabled:=false;
   FCWinFUG.TOO_OrbitalObjectPicker.Enabled:=false;
   FCWinFUG.TOO_SatPicker.Enabled:=false;
   FCWinFUG.TOO_CurrentOrbitalObject.Enabled:=false;
   FCWinFUG.TOO_CurrentRegion.Show;
   FCWinFUG.CR_MaxRegionsNumber.HTMLText.Clear;
   FCWinFUG.CR_MaxRegionsNumber.HTMLText.Add( 'Max Regions: ' + inttostr( Max ) );
   {.Count1: grid index #}
   case Max of
      4: Count1:=9;

      6: Count1:=8;

      8: Count1:=7;

      10: Count1:=6;

      14: Count1:=5;

      18: Count1:=4;

      22: Count1:=3;

      26: Count1:=2;

      30: Count1:=1;
   end;
   FCWinFUG.CR_GridIndexNumber.HTMLText.Clear;
   FCWinFUG.CR_GridIndexNumber.HTMLText.Add( 'Grid Index #: ' + inttostr( Count1 ) );
   if ( Hydrosphere = hWaterLiquid )
      or ( Hydrosphere = hWaterAmmoniaLiquid )
      or ( Hydrosphere = hMethaneLiquid ) then
   begin
      FCWinFUG.CR_OceanicCoastalAdjustment.Show;
      FCWinFUG.CR_Hydrosphere.Show;
      FCWinFUG.CR_Hydrosphere.HTMLText.Clear;
      case Hydrosphere of
         hWaterLiquid: FCWinFUG.CR_Hydrosphere.HTMLText.Add( 'Hydro: LWater' );

         hWaterAmmoniaLiquid: FCWinFUG.CR_Hydrosphere.HTMLText.Add( 'Hydro: LWatAm' );

         hMethaneLiquid: FCWinFUG.CR_Hydrosphere.HTMLText.Add( 'Hydro: LMeth' );
      end;
      FCWinFUG.CR_SeaArea.Show;
      FCWinFUG.CR_SeaArea.HTMLText.Clear;
      FCWinFUG.CR_SeaArea.HTMLText.Add( 'Sea Area: '+inttostr( HydrosphereArea )+'%' );
   end
   else begin
      FCWinFUG.CR_OceanicCoastalAdjustment.Hide;
      FCWinFUG.CR_Hydrosphere.Hide;
      FCWinFUG.CR_SeaArea.Hide;
   end;
   Count1:=round( 9144 / Gravity );
   FCWinFUG.CR_HighestPeak.HTMLText.Clear;
   FCWinFUG.CR_HighestPeak.HTMLText.Add( 'Highest Peak: ' + inttostr( Count1 ) );
   FCWinFUG.CR_LowestDepth.HTMLText.Clear;
   FCWinFUG.CR_LowestDepth.HTMLText.Add( 'Lowest Depth: -' + inttostr( Count1 ) );
   FCWinFUG.CR_Diameter.HTMLText.Clear;
   FCWinFUG.CR_Diameter.HTMLText.Add( 'Diameter: ' + floattostr( Diameter ) );
   FCWinFUG.CR_AxialTilt.HTMLText.Clear;
   FCWinFUG.CR_AxialTilt.HTMLText.Add( 'Axial Tilt: ' + floattostr( AxialTilt ) );
   FCWinFUG.CR_Albedo.HTMLText.Clear;
   FCWinFUG.CR_Albedo.HTMLText.Add( 'Albedo: ' + floattostr( Albedo ) );
   FCWinFUG.CR_StarLum.HTMLText.Clear;
   FCWinFUG.CR_StarLum.HTMLText.Add( 'Star Lum: ' + floattostr( FCDduStarSystem[0].SS_stars[Star].S_luminosity ) );
   FCWinFUG.CR_Greenhouse.HTMLText.Clear;
   FCWinFUG.CR_StarLum.HTMLText.Add( 'Greenhouse: ' + floattostr( Greenhouse ) );
   FCWinFUG.CR_InputSeed.Text:='';
   FCWinFUG.CR_InputLightColorFileNumber.Text:='';
   FCWinFUG.CR_InputClimateFileNumber.Text:='';
   FCWinFUG.CR_CurrentRegion.Enabled:=false;
   FCWinFUG.CR_CurrentRegion.Items.Clear;
   Count:=1;
   while Count <= Max do
   begin

      FCWinFUG.CR_CurrentRegion.Items.Add( inttostr( Count ) );
      inc( Count );
   end;
   FCWinFUG.CR_CurrentRegion.Enabled:=true;
   FCWinFUG.CR_CurrentRegion.ItemIndex:=0;
   FCmfC_Region_Update;
   {.dev: include the display of a third button}
   FUGpaused:=true;
   FCWinFUG.WF_ContinueButton.Show;
   while FUGpaused do
   begin
      sleep(100);
      application.processmessages;
   end;
   FCWinFUG.WF_ContinueButton.Hide;
end;

end.
