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
   ,SysUtils
   ,TypInfo;

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
   farc_common_func
   ,farc_data_univ
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
      -2013Aug27- *add: forgot to restore the user's interface.
}
   var
      Count
      ,Count1
      ,HydrosphereArea
      ,Max
      ,RefRegion: integer;

      Albedo
      ,AxialTilt
      ,Clouds
      ,Diameter
      ,fCalc1
      ,Gravity
      ,Greenhouse
      ,Rainfall
      ,SurfTempMean
      ,Variance: extended;

      ObjToken: string;

      Hydrosphere: TFCEduHydrospheres;

      ObjectType: TFCEduOrbitalObjectTypes;
begin
   Count:=0;
   Count1:=0;
   HydrosphereArea:=0;
   Max:=0;
   RefRegion:=0;

   Albedo:=0;
   AxialTilt:=0;
   Diameter:=0;
   fCalc1:=0;
   Gravity:=0;
   Greenhouse:=0;
   Rainfall:=0;
   SurfTempMean:=0;
   Variance:=0;

   ObjToken:='';

   Hydrosphere:=hNoHydro;

   ObjectType:=ootNone;

   FUGpaused:=false;

   if Satellite = 0 then
   begin
      ObjToken:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_dbTokenId;
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_type;
      Greenhouse:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_fug_Greenhouse;
      Diameter:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_Diameter;
      AxialTilt:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_isNotSat_axialTilt;
      Albedo:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_albedo;
      Gravity:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_gravity;
      Clouds:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_cloudsCover;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphere;
      HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_hydrosphereArea;
      SurfTempMean:=(
         (
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[1].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[2].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[3].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_orbitalPeriods[4].OOS_surfaceTemperature
            ) / 4 );
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_regions ) - 1;
   end
   else if Satellite > 0 then
   begin
      ObjToken:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_dbTokenId;
      ObjectType:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_type;
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
      Clouds:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_cloudsCover;
      Hydrosphere:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphere;
      HydrosphereArea:=FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_hydrosphereArea;
      SurfTempMean:=(
         (
            FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[1].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[2].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[3].OOS_surfaceTemperature
               +FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_orbitalPeriods[4].OOS_surfaceTemperature
            ) / 4 );
      Max:=length( FCDduStarSystem[0].SS_stars[Star].S_orbitalObjects[OrbitalObject].OO_satellitesList[Satellite].OO_regions ) - 1;
   end;
   SurfTempMean:=FCFcF_Round( rttCustom2Decimal, SurfTempMean - 273.15 );
   FDcurrentRegionStar:=Star;
   FDcurrentRegionOrbObj:=OrbitalObject;
   FDcurrentRegionSat:=Satellite;
   FDcurrentRegion:=1;
   RefRegion:=FCFfrF_ReferenceRegion_GetIndex( Max );
   fCalc1:=( ( abs( FCDfdRegions[RefRegion].RC_surfaceTemperatureMean - FCDfdRegions[1].RC_surfaceTemperatureMean ) + abs( FCDfdRegions[RefRegion].RC_surfaceTemperatureMean - FCDfdRegions[Max].RC_surfaceTemperatureMean ) ) * 0.5 );
   Variance:=FCFcF_Round( rttCustom1Decimal, fCalc1 );
   FCWinFUG.TOO_StarPicker.Hide;
   FCWinFUG.TOO_OrbitalObjectPicker.Hide;
   FCWinFUG.TOO_SatPicker.Hide;
   FCWinFUG.TOO_CurrentOrbitalObject.Enabled:=false;
   FCWinFUG.TOO_CurrentRegion.Show;
   FCWinFUG.CR_ObjToken.Text:=ObjToken;
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
   FCWinFUG.CR_Hydrosphere.Show;
   FCWinFUG.CR_Hydrosphere.HTMLText.Clear;
   FCWinFUG.CR_Hydrosphere.HTMLText.Add( 'Hydro: '+GetEnumName( TypeInfo( TFCEduHydrospheres ), Integer( Hydrosphere ) ) );
   FCWinFUG.CR_OceanicCoastalAdjustment.Show;
   if ( Hydrosphere = hWaterLiquid )
      or ( Hydrosphere = hWaterAmmoniaLiquid )
      or ( Hydrosphere = hMethaneLiquid ) then
   begin

      FCWinFUG.CR_SeaArea.Show;
      FCWinFUG.CR_SeaArea.HTMLText.Clear;
      FCWinFUG.CR_SeaArea.HTMLText.Add( 'Sea Area: '+inttostr( HydrosphereArea )+'%' );
   end
   else begin
//      FCWinFUG.CR_OceanicCoastalAdjustment.Hide;
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
   FCWinFUG.CR_Greenhouse.HTMLText.Add( 'Greenhouse: ' + floattostr( Greenhouse ) );
   FCWinFUG.CR_Variance.HTMLText.Clear;
   FCWinFUG.CR_Variance.HTMLText.Add( 'Variance: ' + floattostr( Variance ) );
   FCWinFUG.CR_SurfTempMean.HTMLText.Clear;
   FCWinFUG.CR_SurfTempMean.HTMLText.Add( 'SurfTempMean: ' + floattostr( SurfTempMean ) );
   FCWinFUG.CR_OObjType.HTMLText.Clear;
   FCWinFUG.CR_OObjType.HTMLText.Add( 'OObj: ' + GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( ObjectType ) ) );
   FCWinFUG.CR_InputSeed.Text:='';
   FCWinFUG.CR_InputLightColorFileNumber.Text:='';
   FCWinFUG.CR_InputClimateFileNumber.Text:='';
   FCWinFUG.CR_CurrentRegion.Enabled:=false;
   FCWinFUG.CR_CurrentRegion.Items.Clear;
   Count:=1;
   while Count <= Max do
   begin
      Rainfall:=Rainfall + ( ( FCDfdRegions[Count].RC_rainfallClosest + FCDfdRegions[Count].RC_rainfallInterm + FCDfdRegions[Count].RC_rainfallFarthest ) / 3 );
      FCWinFUG.CR_CurrentRegion.Items.Add( inttostr( Count ) );
      inc( Count );
   end;
   Rainfall:=Rainfall * 0.1;
   FCWinFUG.CR_Rainfall.HTMLText.Clear;
   FCWinFUG.CR_Rainfall.HTMLText.Add( 'Rainfall: ' + floattostr( Rainfall ) +'  Clouds:'+FloatToStr( Clouds ) );
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
   FCWinFUG.TOO_StarPicker.Show;
   FCWinFUG.TOO_OrbitalObjectPicker.Show;
   FCWinFUG.TOO_SatPicker.Show;
   FCWinFUG.TOO_CurrentOrbitalObject.Enabled:=true;
   FCWinFUG.TOO_CurrentRegion.Hide;
end;

end.
