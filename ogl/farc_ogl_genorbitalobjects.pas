{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: OpenGL Framework - orbital objects generation unit

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
unit farc_ogl_genorbitalobjects;

interface

uses
   SysUtils

   ,GLAtmosphere
   ,GLColor
   ,GLMaterial
   ,GLObjects

   ,DecimalRounding_JH1

   ,oxLib3dsMeshLoader;

type TFCEogooOrbital3dObjectTypes=(
   o3dotAsterBelt
   ,o3dotPlanet
   ,o3dotAsteroid
   ,o3dotAsteroidInABelt
   ,o3dotSatellitePlanet
   ,o3dotSatelliteAsteroid
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//function FCFogoO_Asteroid_Set(
//   const OrbObject
//         ,Satellite: integer
//   ): string;
//{:Purpose: return .3ds path relative to aster type and load the AsterDmp with right

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   setup of the atmosphere color according to the orbital object's main gases which compose it
///</summary>
///   <param name="OrbitalObjectIndex">orbital object index #</param>
///   <param name="SatelliteIndex">satellite index #</param>
///   <param name="Satellite3Dindex">index of the satellite 3d object</param>
///   <remarks></remarks>
procedure FCMogoO_Atmosphere_Setup(
   const OrbitalObjectIndex
         ,SatelliteIndex
         ,Satellite3Dindex: integer
   );

///<summary>
///   generate a 3d objects row of selected index
///</summary>
///   <param name="TypeToGenerate">type of object to generate</param>
///   <param name="OrbitalObject3DIndex">index of object row</param>
procedure FCMogoO_OrbitalObject_Generate(
   const TypeToGenerate: TFCEogooOrbital3dObjectTypes;
   const OrbitalObject3DIndex: integer;
   const OrbitalObjectIndex: integer = 0;
   const SatelliteIndex: integer = 0
   );

///<summary>
///   initialize a full row of objects for non satellite objects
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMogoO_OrbitalObject_Initialize( const ObjectIndex: integer );

///<summary>
///   set the central star
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks>FC3doglCurrentStarSystem and FC3doglCurrentStar requires to be set with the correct values before to call it</remarks>
procedure FCMogO_Star_Set;

///<summary>
///   assign the correct surface map texture on a designed orbital object
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMogO_SurfaceMapTexture_Assign(const MTAoobjIdx, MTAsatIdx, MTAsatObjIdx: integer);

///<summary>
///   free the temporary satellite data structure
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
//procedure FCMogoO_TemporarySat_Free;





implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ
   ,farc_fug_atmosphere
   ,farc_main
   ,farc_ogl_functions
   ,farc_univ_func;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================

var
   {.dump asteroid}
   FC3ogooTemporaryAsteroid: TDGLib3dsStaMesh;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFogoO_Asteroid_Set(
   const OrbObject
         ,Satellite: integer
   ): string;
{:Purpose: return .3ds path relative to aster type and load the AsterDmp with right
material.
    Additions:
}
var
   ASresDmp: string;
   ASobjTp: TFCEduOrbitalObjectTypes;
begin
   Result:='';
   {.test if AsterDmp is created}
   if FC3ogooTemporaryAsteroid=nil then
   begin
      FC3ogooTemporaryAsteroid:=TDGLib3dsStaMesh(FCWinMain.FCGLSStarMain.AddNewChild(TDGLib3dsStaMesh));
      FC3ogooTemporaryAsteroid.Name:='FCGLSasterDmp';
      FC3ogooTemporaryAsteroid.UseGLSceneBuildList:=False;
      FC3ogooTemporaryAsteroid.UseShininessPowerHack:=0;
   end;
   {.get the object type}
   if Satellite > 0
   then ASobjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbObject].OO_satellitesList[Satellite].OO_type
   else ASobjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbObject].OO_type;
   {.determine the type of asteroid to load}
   if ( ASobjTp = ootAsteroid_Metallic )
      or ( ASobjTp = ootSatellite_Asteroid_Metallic ) then
   begin
      {.set proper asteroid object and colors}
      Result:=FCVdiPathResourceDir+'obj-3ds-aster\aster_metall.3ds';
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Blue:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Green:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Red:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Blue:=0.9;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Green:=0.9;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Red:=0.9;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Emission.Color:=clrGray80;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Shininess:=90;
   end
   else if ( ASobjTp = ootAsteroid_Silicate )
      or ( ASobjTp = ootSatellite_Asteroid_Silicate ) then
   begin
      {.set proper asteroid object and colors}
      Result:=FCVdiPathResourceDir+'obj-3ds-aster\aster_sili.3ds';
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Blue:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Green:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Red:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Blue:=0.5;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Green:=0.5;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Red:=0.5;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Emission.Color:=clrGray90;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Shininess:=70;
   end
   else if ( ASobjTp = ootAsteroid_Carbonaceous )
      or ( ASobjTp = ootSatellite_Asteroid_Carbonaceous ) then
   begin
      {.set proper asteroid object and colors}
      Result:=FCVdiPathResourceDir+'obj-3ds-aster\aster_carbo.3ds';
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Blue:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Green:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Red:=0.2;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Blue:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Green:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Red:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Emission.Color:=clrBlack;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Shininess:=50;
   end
   else if ( ASobjTp = ootAsteroid_Icy )
      or ( ASobjTp = ootSatellite_Asteroid_Icy ) then
   begin
      {.set proper asteroid object and colors}
      Result:=FCVdiPathResourceDir+'obj-3ds-aster\aster_icy.3ds';
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Blue:=0.4;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Green:=0.4;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Ambient.Red:=0.4;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Blue:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Green:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Diffuse.Red:=0.8;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Emission.Color:=clrGray10;
      FC3ogooTemporaryAsteroid.Material.FrontProperties.Shininess:=80;
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMogoO_Atmosphere_Setup(
   const OrbitalObjectIndex
         ,SatelliteIndex
         ,Satellite3Dindex: integer
   );
{:Purpose: setup of the atmosphere color according to the orbital object's main gases which compose it.
    Additions:
      -2013Oct08- *add/mod: end of the overhaul of the colors.
      -2013Oct01- *code audit:
                  (x)var formatting + refactoring     (x)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods: put inline; + reformat _X
                  (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                  (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                  (x)any function/procedure variable pre-initialization. Init array w/ [0] array EACH PARAMETERS not direct
                  (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                  (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                  (x)conditional <>= and operators with spaces
                  (_)if the procedure reset the same record's data or external data put:
                     ///   <remarks>the procedure/function reset the /data/</remarks>
                  *add: transfer the rest of the code for a complete atmosphere setup.
                  *add/mod: start of the overhaul of the colors.
      -2010Jan31- *mod: change in ASAsizeCoef.
      -2010Jan05- *add: set also atmosphere scale.
                  *mod: refactor the method considering the new function.
}
   const
      SizeCoefficient=2;//1.948;//.892

   var
      ConvertedCloudsCover
      ,Gas1Red
      ,Gas1Green
      ,Gas1Blue
      ,HighColorRed
      ,HighColorGreen
      ,HighColorBlue
      ,LowColorRed
      ,LowColorGreen
      ,LowColorBlue
      ,MeanSurfaceTemp
      ,SQRTscale: extended;

      isDone
      ,isGaseous: boolean;

      GasCH4
      ,GasH2
      ,GasHe
      ,GasN2
      ,GasNH3
      ,GasO2
      ,GasH2S
      ,GasCO2
      ,GasSO2: TFCEduAtmosphericGasStatus;

      PrimaryFirst: TFCEfaGases;

      function _CloudsCover_Convert2AtmosphereOpacity( const CloudsCover: extended ): extended;
      {:Purpose: calculate atmosphere opacity following clouds covers given.à
         Additions:
            -2013Oct01- *code: function moved as nested code.
            -2010Mar21- *add: reinstate round of the result with a new method.
      }
         var
            fCalc: extended;
      begin
         Result:=0;
         fCalc:=0;
         if CloudsCover <= 0
         then Result:=0.7
         else begin
            fCalc:=CloudsCover / ( 10 + ( sqrt( CloudsCover ) / 8 ) );
            Result:=DecimalRound( fCalc, 1, 0.01 );
         end;
      end;
begin
   ConvertedCloudsCover:=0;
   Gas1Red:=0;
   Gas1Green:=0;
   Gas1Blue:=0;
   HighColorRed:=0;
   HighColorGreen:=0;
   HighColorBlue:=0;
   LowColorRed:=0;
   LowColorGreen:=0;
   LowColorBlue:=0;
   MeanSurfaceTemp:=0;
   SQRTscale:=0;

   isDone:=false;
   isGaseous:=false;

   GasCH4:=agsNotPresent;
   GasH2:=agsNotPresent;
   GasHe:=agsNotPresent;
   GasN2:=agsNotPresent;
   GasNH3:=agsNotPresent;
   GasO2:=agsNotPresent;
   GasH2S:=agsNotPresent;
   GasCO2:=agsNotPresent;
   GasSO2:=agsNotPresent;
   PrimaryFirst:=gNone;

   if SatelliteIndex = 0 then
   begin
      if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_type < ootPlanet_Gaseous_Uranus
      then ConvertedCloudsCover:=_CloudsCover_Convert2AtmosphereOpacity( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_cloudsCover )
      else begin
         ConvertedCloudsCover:=_CloudsCover_Convert2AtmosphereOpacity( 0 );
         isGaseous:=true;
         MeanSurfaceTemp:=FCFuF_OrbitalPeriods_GetMeanSurfaceTemperature(
            FC3doglCurrentStarSystem
            ,FC3doglCurrentStar
            ,OrbitalObjectIndex
            );
      end;
      GasCH4:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceCH4;
      GasH2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceH2;
      GasHe:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceHe;
      GasN2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceN2;
      GasNH3:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceNH3;
      GasO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceO2;
      GasH2S:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceH2S;
      GasCO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceCO2;
      GasSO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_atmosphere.AC_gasPresenceSO2;
   end
   else begin
      ConvertedCloudsCover:=_CloudsCover_Convert2AtmosphereOpacity( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_cloudsCover );
      GasCH4:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceCH4;
      GasH2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceH2;
      GasHe:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceHe;
      GasN2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceN2;
      GasNH3:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceNH3;
      GasO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceO2;
      GasH2S:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceH2S;
      GasCO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceCO2;
      GasSO2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_gasPresenceSO2;
   end;
   if isGaseous then
   begin
      if MeanSurfaceTemp < 65 then
      begin
         HighColorRed:=0.388235294;//99
         HighColorGreen:=0.431372549;//110
         HighColorBlue:=0.447058823;//114
         LowColorRed:=0.450980392;//115
         LowColorGreen:=0.654901960;//167
         LowColorBlue:=0.984313725;//251
      end
      else if ( MeanSurfaceTemp >= 65 )
         and ( MeanSurfaceTemp < 84 ) then
      begin
         HighColorRed:=0.556862745;//142
         HighColorGreen:=0.701960784;//179
         HighColorBlue:=0.725490196;//185
         LowColorRed:=0.839215686;//214
         LowColorGreen:=0.988235294;//252
         LowColorBlue:=0.992156862;//253
      end
      else if ( MeanSurfaceTemp >= 84 )
         and ( MeanSurfaceTemp < 153.15 ) then
      begin
         HighColorRed:=0.941176470;//240
         HighColorGreen:=0.874509803;//223
         HighColorBlue:=0.764705882;//195
         LowColorRed:=0.639215686;//163
         LowColorGreen:=0.545098039;//139
         LowColorBlue:=0.450980392;//115
      end
      else if ( MeanSurfaceTemp >= 153.15 )
         and ( MeanSurfaceTemp < 283 ) then
      begin
         HighColorRed:=0.823529411;//210
         HighColorGreen:=0.694117647;//177
         HighColorBlue:=0.556862745;//142
         LowColorRed:=0.780392156;//199
         LowColorGreen:=0.721568627;//184
         LowColorBlue:=0.803921568;//205
      end
      else if ( MeanSurfaceTemp >= 283 )
         and ( MeanSurfaceTemp < 349 ) then
      begin
         HighColorRed:=0.886274509;//226
         HighColorGreen:=0.901960784;//230
         HighColorBlue:=0.984313725;//251
         LowColorRed:=0.505882352;//129
         LowColorGreen:=0.572549019;//146
         LowColorBlue:=0.925490196;//236
      end
      else if ( MeanSurfaceTemp >= 349 )
         and ( MeanSurfaceTemp < 899.15 ) then
      begin
         HighColorRed:=0.921568627;//235
         HighColorGreen:=0.933333333;//238
         HighColorBlue:=0.811764705;//207
         LowColorRed:=0.098039215;//25
         LowColorGreen:=0.133333333;//34
         LowColorBlue:=0.317647058;//81
      end
      else if ( MeanSurfaceTemp >= 899.15 )
         and ( MeanSurfaceTemp < 1499.15 ) then
      begin
         HighColorRed:=0.717647058;//183
         HighColorGreen:=0.705882352;//180
         HighColorBlue:=0.698039215;//178
         LowColorRed:=0.670588235;//171
         LowColorGreen:=0.6;//153
         LowColorBlue:=0.529411764;//135
      end
      else if MeanSurfaceTemp >= 1499.15 then
      begin
         HighColorRed:=0.796078431;//203
         HighColorGreen:=0.796078431;//203
         HighColorBlue:=0.796078431;//203
         LowColorRed:=0.603921568;//154
         LowColorGreen:=0.603921568;//154
         LowColorBlue:=0.603921568;//154
      end;
   end
   else begin
      if GasN2 = agsPrimary then
      begin
         Gas1Red:=0.250980392;//64
         Gas1Green:=0.298039215;//76
         Gas1Blue:=0.392156862;//100
         PrimaryFirst:=gN2;
      end;
      if GasCO2 = agsPrimary then
      begin
         if PrimaryFirst = gN2 then
         begin
            HighColorRed:=Gas1Red;
            HighColorGreen:=Gas1Green;
            HighColorBlue:=Gas1Blue;
            LowColorRed:=1;//255
            LowColorGreen:=0.141176470;//36
            LowColorBlue:=0;//0
            isDone:=true;
         end
         else begin
            Gas1Red:=1;//255
            Gas1Green:=0.141176470;//36
            Gas1Blue:=0;//0
            PrimaryFirst:=gCO2;
         end;
      end;
      if ( not isDone )
         and ( GasCH4 = agsPrimary ) then
      begin
         if PrimaryFirst = gN2 then
         begin
            HighColorRed:=Gas1Red;
            HighColorGreen:=Gas1Green;
            HighColorBlue:=Gas1Blue;
            LowColorRed:=0.878431372;//224
            LowColorGreen:=0.760784313;//194
            LowColorBlue:=0.290196078;//74
            isDone:=true;
         end
         else if PrimaryFirst = gCO2 then
         begin
            HighColorRed:=0.250980392;//64
            HighColorGreen:=0.298039215;//76
            HighColorBlue:=0.392156862;//100
            LowColorRed:=0.658823529;//168
            LowColorGreen:=0.592156862;//151
            LowColorBlue:=0.764705882;//195
            isDone:=true;
         end
         else begin
            Gas1Red:=0.878431372;//224
            Gas1Green:=0.760784313;//194
            Gas1Blue:=0.290196078;//74
            PrimaryFirst:=gCH4;
         end;
      end;
      if ( not isDone )
         and ( PrimaryFirst > gNone ) then
      begin
         if PrimaryFirst = gN2 then
         begin
            if GasO2 >= agsSecondary then
            begin
               HighColorRed:=0.486274509;//124
               HighColorGreen:=0.674509803;//172
               HighColorBlue:=0.941176470;//240
               LowColorRed:=Gas1Red;
               LowColorGreen:=Gas1Green;
               LowColorBlue:=Gas1Blue;
               isDone:=true;
            end;
         end;
      end;
   end;
//   {.CO2 atmosphere - mars like}
//   else if ( GasCO2 = agsPrimary )
////      and ( GasN2 <= agsPrimary )
//      then
//   begin
//      HighColorRed:=0.596078431;//152..95
//      HighColorGreen:=0.650980392;//166..93
//      HighColorBlue:=0.733333333;//187..81
//      LowColorRed:=1; //255
//      LowColorGreen:=0.141176470;
//      LowColorBlue:=0;
//   end
//   {.H2S/SO2 atmosphere - io like}
//   else if ( GasH2S = agsPrimary )
//      and ( GasSO2 = agsPrimary ) then
//   begin
//      HighColorRed:=0.556862;
//      HighColorGreen:=0.549019;
//      HighColorBlue:=0.325490;
//      LowColorRed:=0.866666;
//      LowColorGreen:=0.866666;
//      LowColorBlue:=0.866666;
//   end
//   else if ( GasCH4 = agsPrimary )
//      and ( GasNH3 = agsPrimary ) then
//   begin
//      HighColorRed:=0.247058;
//      HighColorGreen:=0.392156;
//      HighColorBlue:=0.6;
//      LowColorRed:=0.196078;
//      LowColorGreen:=0.6;
//      LowColorBlue:=0.8;
//   end;
   if SatelliteIndex = 0 then
   begin
      SQRTscale:=sqrt( FC3doglPlanets[OrbitalObjectIndex].Scale.X );
      FC3doglAtmospheres[OrbitalObjectIndex].HighAtmColor.Red:=HighColorRed;
      FC3doglAtmospheres[OrbitalObjectIndex].HighAtmColor.Green:=HighColorGreen;
      FC3doglAtmospheres[OrbitalObjectIndex].HighAtmColor.Blue:=HighColorBlue;
      FC3doglAtmospheres[OrbitalObjectIndex].LowAtmColor.Red:=LowColorRed;
      FC3doglAtmospheres[OrbitalObjectIndex].LowAtmColor.Green:=LowColorGreen;
      FC3doglAtmospheres[OrbitalObjectIndex].LowAtmColor.Blue:=LowColorBlue;
      FC3doglAtmospheres[OrbitalObjectIndex].SetOptimalAtmosphere2( FC3doglPlanets[OrbitalObjectIndex].Scale.X - ( ( SQRTscale / SizeCoefficient - ( SQRTscale * 0.5 ) ) ) );
      FC3doglAtmospheres[OrbitalObjectIndex].Sun:=FCWinMain.FCGLSSM_Light;
      FC3doglAtmospheres[OrbitalObjectIndex].Opacity:=ConvertedCloudsCover;
      FC3doglAtmospheres[OrbitalObjectIndex].Visible:=true;
   end
   else begin
      SQRTscale:=sqrt( FC3doglSatellitesPlanet[Satellite3Dindex].Scale.X );
      FC3doglSatellitesAtmospheres[Satellite3Dindex].HighAtmColor.Red:=HighColorRed;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].HighAtmColor.Green:=HighColorGreen;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].HighAtmColor.Blue:=HighColorBlue;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].LowAtmColor.Red:=LowColorRed;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].LowAtmColor.Green:=LowColorGreen;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].LowAtmColor.Blue:=LowColorBlue;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].SetOptimalAtmosphere2( FC3doglSatellitesPlanet[Satellite3Dindex].Scale.X - ( ( SQRTscale / SizeCoefficient -( SQRTscale * 0.5 ) ) ) );
      FC3doglSatellitesAtmospheres[Satellite3Dindex].Sun:=FCWinMain.FCGLSSM_Light;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].Opacity:=ConvertedCloudsCover;
      FC3doglSatellitesAtmospheres[Satellite3Dindex].Visible:=true;
   end;
end;

procedure FCMogoO_OrbitalObject_Generate(
   const TypeToGenerate: TFCEogooOrbital3dObjectTypes;
   const OrbitalObject3DIndex: integer;
   const OrbitalObjectIndex: integer = 0;
   const SatelliteIndex: integer = 0
   );
{:Purpose: generate a 3d objects row of selected index.
    Additions:
      -2013Sep29- *code: transfer of creation code.
                  *code: some code cleanup
      -2013Sep22- *add: begin asteroid belt.
                  *code: some code cleanup.
      -2010Dec07- *add: intialize the material of planets, if needed.
      -2009Dec14- *add: complete satellite generation.
      -2009Dec12- *mod: delete the method's boolean and replace it by a switch.
                  *add: generate satellite.
      -2009Dec07- *update atmosphere initialization.
}
   var
      LocationInView
      ,LocationInViewRoot: TFCRoglfPosition;
begin
   LocationInView.P_x:=0;
   LocationInView.P_y:=0;
   LocationInView.P_z:=0;
   LocationInViewRoot.P_x:=0;
   LocationInViewRoot.P_y:=0;
   LocationInViewRoot.P_z:=0;

   case TypeToGenerate of
      o3dotAsterBelt:
      begin
         {.the object group}
//         FC3doglObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSObObjGroup'+IntToStr(OrbitalObject3DIndex);
//         FC3doglObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
         FC3doglObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
         FC3doglObjectsGroups[OrbitalObject3DIndex].Visible:=false;
         FC3doglObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
         {.the planet}
//         FC3doglPlanets[OrbitalObject3DIndex]:=TGLSphere(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
//         FC3doglPlanets[OrbitalObject3DIndex].Name:='FCGLSObObjPlnt'+IntToStr(OrbitalObject3DIndex);
//         FC3doglPlanets[OrbitalObject3DIndex].Radius:=1;
//         FC3doglPlanets[OrbitalObject3DIndex].Slices:=64;
//         FC3doglPlanets[OrbitalObject3DIndex].Stacks:=64;
         FC3doglPlanets[OrbitalObject3DIndex].Visible:=false;
         FC3doglPlanets[OrbitalObject3DIndex].ShowAxes:=false;
      end;

      o3dotPlanet, o3dotAsteroid:
      begin
         {.the object group}
//         FC3doglObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSObObjGroup'+IntToStr(OrbitalObject3DIndex);
//         FC3doglObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
//         FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
         FC3doglObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
         FC3doglObjectsGroups[OrbitalObject3DIndex].Visible:=false;
         FC3doglObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
         {.the planet}
//         FC3doglPlanets[OrbitalObject3DIndex]:=TGLSphere(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
//         FC3doglPlanets[OrbitalObject3DIndex].Name:='FCGLSObObjPlnt'+IntToStr(OrbitalObject3DIndex);
//         FC3doglPlanets[OrbitalObject3DIndex].Radius:=1;
//         FC3doglPlanets[OrbitalObject3DIndex].Slices:=64;
//         FC3doglPlanets[OrbitalObject3DIndex].Stacks:=64;
         FC3doglPlanets[OrbitalObject3DIndex].Visible:=false;
         FC3doglPlanets[OrbitalObject3DIndex].ShowAxes:=false;


         if TypeToGenerate = o3dotPlanet then
         begin
            FC3doglAsteroids[OrbitalObject3DIndex].Visible:=false;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Ambient.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Diffuse.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Emission.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Specular.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Emission:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
//            FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
            FC3doglPlanets[OrbitalObject3DIndex].RollAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_isNotSat_axialTilt;
            LocationInView:=FCFoglF_OrbitalObject_CalculatePosition(
                 FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_isNotSat_distanceFromStar
                 ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay
               );
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.X:=LocationInView.P_x;
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.Y:=LocationInView.P_y;
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.Z:=LocationInView.P_z;
            FC3doglPlanets[OrbitalObject3DIndex].scale.X:=FCFcF_Scale_Conversion(cKmTo3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_diameter);
            FC3doglPlanets[OrbitalObject3DIndex].scale.Y:=FC3doglPlanets[OrbitalObject3DIndex].scale.X;
            FC3doglPlanets[OrbitalObject3DIndex].scale.Z:=FC3doglPlanets[OrbitalObject3DIndex].scale.X;
            FC3doglObjectsGroups[OrbitalObject3DIndex].CubeSize:=FC3doglPlanets[OrbitalObject3DIndex].scale.X*2;
         end //==END== if OOGobjClass=oglvmootNorm ==//
         else if TypeToGenerate = o3dotAsteroid then
         begin
//            {.the asteroid}
//            FC3doglAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
//            FC3doglAsteroids[OrbitalObject3DIndex].Name:='FCGLSObObjAster'+IntToStr(OrbitalObject3DIndex);
//            FC3doglAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
//            FC3doglAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
//            FC3doglAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
//            FC3doglAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
//            FC3doglAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
//            FC3doglAsteroids[OrbitalObject3DIndex].Scale.SetVector(0.27,0.27,0.27);
            FC3doglAsteroids[OrbitalObject3DIndex].Load3DSFileFrom( FCFogoO_Asteroid_Set( OrbitalObject3DIndex, 0 ) );
            FC3doglAsteroids[OrbitalObject3DIndex].Material.FrontProperties:=FC3ogooTemporaryAsteroid.Material.FrontProperties;
            FC3doglAsteroids[OrbitalObject3DIndex].TurnAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_isNotSat_axialTilt;
            LocationInView:=FCFoglF_OrbitalObject_CalculatePosition(
                 FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_isNotSat_distanceFromStar
                 ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay
               );
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.X:=LocationInView.P_x;
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.Y:=LocationInView.P_y;
            FC3doglObjectsGroups[OrbitalObject3DIndex].Position.Z:=LocationInView.P_z;
            FC3doglAsteroids[OrbitalObject3DIndex].scale.X:=FCFcF_Scale_Conversion(cAsteroidDiameterKmTo3dViewUnits, FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_diameter);
            FC3doglAsteroids[OrbitalObject3DIndex].scale.Y:=FC3doglAsteroids[OrbitalObject3DIndex].scale.X;
            FC3doglAsteroids[OrbitalObject3DIndex].scale.Z:=FC3doglAsteroids[OrbitalObject3DIndex].scale.X;
            FC3doglObjectsGroups[OrbitalObject3DIndex].CubeSize:=FC3doglAsteroids[OrbitalObject3DIndex].scale.X*50;
         end;
//         {.the atmosphere}
//         FC3doglAtmospheres[OrbitalObject3DIndex]:=TGLAtmosphere(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLAtmosphere));
//         FC3doglAtmospheres[OrbitalObject3DIndex].Name:='FCGLSObObjAtmos'+IntToStr(OrbitalObject3DIndex);
//         FC3doglAtmospheres[OrbitalObject3DIndex].AtmosphereRadius:=3.55;//3.75;//3.55;
//         FC3doglAtmospheres[OrbitalObject3DIndex].BlendingMode:=abmOneMinusSrcAlpha;
//         FC3doglAtmospheres[OrbitalObject3DIndex].HighAtmColor.Color:=clrBlue;
//         FC3doglAtmospheres[OrbitalObject3DIndex].LowAtmColor.Color:=clrWhite;
//         FC3doglAtmospheres[OrbitalObject3DIndex].Opacity:=2.1;
//         FC3doglAtmospheres[OrbitalObject3DIndex].PlanetRadius:=3.395;
//         FC3doglAtmospheres[OrbitalObject3DIndex].Slices:=64;
         FC3doglAtmospheres[OrbitalObject3DIndex].Visible:=false;
      end; //==END== case: o3dotPlanet, o3dotAsteroid ==//

      o3dotAsteroidInABelt:
      begin

         if OrbitalObject3DIndex > FC3doglMainViewMax3DSatellitesInDataS then
         begin
            SetLength(FC3doglSatellitesObjectsGroups, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesPlanet, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesAtmospheres, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesAsteroids, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglMainViewListSatellitesGravityWells, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglMainViewListSatelliteOrbits, OrbitalObject3DIndex + 1);
            {.the object group}
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSsatGrp'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
            {.the planet}
            FC3doglSatellitesPlanet[OrbitalObject3DIndex]:=TGLSphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Name:='FCGLSsatPlnt'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Radius:=1;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Slices:=64;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Stacks:=64;
            {.the asteroid}
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Name:='FCGLSsatAster'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Material.FaceCulling:=fcCull;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Scale.SetVector(
               0.27
               ,0.27
               ,0.27
               );
            inc( FC3doglMainViewMax3DSatellitesInDataS );
         end;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Visible:=false;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
         {.the planet}
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex]:=TGLSphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Name:='FCGLSsatPlnt'+IntToStr(OrbitalObject3DIndex);
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Radius:=1;
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Slices:=64;
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Stacks:=64;
         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Visible:=false;
         FC3doglSatellitesPlanet[OrbitalObject3DIndex].ShowAxes:=false;
         {.the asteroid}
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Name:='FCGLSsatAster'+IntToStr(OrbitalObject3DIndex);
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Material.FaceCulling:=fcCull;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Scale.SetVector(
//               0.27
//               ,0.27
//               ,0.27
//               );
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Load3DSFileFrom( FCFogoO_Asteroid_Set( OrbitalObjectIndex, SatelliteIndex ) );
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Material.FrontProperties:=FC3ogooTemporaryAsteroid.Material.FrontProperties;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].TurnAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_isSat_asterInBelt_axialTilt;
            LocationInView:=FCFoglF_OrbitalObject_CalculatePosition(
                    FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
                    ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_angle1stDay
               );
               FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.X:=LocationInView.P_x;
               FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Y:=LocationInView.P_y;
               FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Z:=LocationInView.P_z;

            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.X:=FCFcF_Scale_Conversion(
            cAsteroidDiameterKmTo3dViewUnits
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_diameter
            );
         FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.Y:=FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.X;
         FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.Z:=FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.X;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].CubeSize:=FC3doglSatellitesAsteroids[OrbitalObject3DIndex].scale.X*50;
      end;

      o3dotSatellitePlanet, o3dotSatelliteAsteroid:
      begin
         if OrbitalObject3DIndex > FC3doglMainViewMax3DSatellitesInDataS then
         begin
            SetLength(FC3doglSatellitesObjectsGroups, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesPlanet, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesAtmospheres, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglSatellitesAsteroids, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglMainViewListSatellitesGravityWells, OrbitalObject3DIndex + 1 );
            SetLength(FC3doglMainViewListSatelliteOrbits, OrbitalObject3DIndex + 1);
            {.the object group}
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSsatGrp'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
            {.the planet}
            FC3doglSatellitesPlanet[OrbitalObject3DIndex]:=TGLSphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Name:='FCGLSsatPlnt'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Radius:=1;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Slices:=64;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Stacks:=64;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Ambient.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Diffuse.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Emission.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Specular.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Emission:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
            {.the asteroid}
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Name:='FCGLSsatAster'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Scale.SetVector(
               0.27
               ,0.27
               ,0.27
               );
            {.the atmosphere}
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex]:=TGLAtmosphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLAtmosphere));
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Name:='FCGLSsatAtmos'+IntToStr(OrbitalObject3DIndex);
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].AtmosphereRadius:=3.55;//3.75;//3.55;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].BlendingMode:=abmOneMinusSrcAlpha;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].HighAtmColor.Color:=clrBlue;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].LowAtmColor.Color:=clrWhite;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Opacity:=2.1;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].PlanetRadius:=3.395;
            FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Slices:=64;
            inc( FC3doglMainViewMax3DSatellitesInDataS );
         end;

         {.the object group}
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSsatGrp'+IntToStr(OrbitalObject3DIndex);
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
//         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Visible:=false;
         FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
         {.the planet}
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex]:=TGLSphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Name:='FCGLSsatPlnt'+IntToStr(OrbitalObject3DIndex);
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Radius:=1;
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Slices:=64;
//         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Stacks:=64;
         FC3doglSatellitesPlanet[OrbitalObject3DIndex].Visible:=false;
         FC3doglSatellitesPlanet[OrbitalObject3DIndex].ShowAxes:=false;
         if TypeToGenerate=o3dotSatellitePlanet then
         begin
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Visible:=false;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Ambient.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Diffuse.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Emission.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BackProperties.Specular.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Emission:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
//            FC3doglSatellitesPlanet[OrbitalObject3DIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
            FC3doglSatellitesPlanet[OrbitalObject3DIndex].RollAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_isNotSat_axialTilt;
            LocationInViewRoot.P_x:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.X;
            LocationInViewRoot.P_y:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.Y;
            LocationInViewRoot.P_z:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.Z;
            LocationInView:=FCFoglF_Satellite_CalculatePosition(
               FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
               ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_angle1stDay
               ,LocationInViewRoot
               );
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.X:=LocationInView.P_x;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Y:=LocationInView.P_y;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Z:=LocationInView.P_z;

         end //==END== if OOGobjClass=oglvmootSatNorm ==//
         else if TypeToGenerate=o3dotSatelliteAsteroid then
         begin
            {.the asteroid}
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Name:='FCGLSsatAster'+IntToStr(OrbitalObject3DIndex);
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
//            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Scale.SetVector(
//               0.27
//               ,0.27
//               ,0.27
//               );
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Load3DSFileFrom( FCFogoO_Asteroid_Set( OrbitalObjectIndex, SatelliteIndex ) );
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Material.FrontProperties:=FC3ogooTemporaryAsteroid.Material.FrontProperties;
            FC3doglSatellitesAsteroids[OrbitalObject3DIndex].TurnAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_isNotSat_axialTilt;
            LocationInViewRoot.P_x:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.X;
            LocationInViewRoot.P_y:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.Y;
            LocationInViewRoot.P_z:=FC3doglObjectsGroups[OrbitalObjectIndex].Position.Z;
            LocationInView:=FCFoglF_Satellite_CalculatePosition(
               FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_satellitesList[SatelliteIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
               ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjectIndex].OO_angle1stDay
               ,LocationInViewRoot
               );
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.X:=LocationInView.P_x;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Y:=LocationInView.P_y;
            FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Position.Z:=LocationInView.P_z;


         end;
         {.the atmosphere}
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex]:=TGLAtmosphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLAtmosphere));
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Name:='FCGLSsatAtmos'+IntToStr(OrbitalObject3DIndex);
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].AtmosphereRadius:=3.55;//3.75;//3.55;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].BlendingMode:=abmOneMinusSrcAlpha;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].HighAtmColor.Color:=clrBlue;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].LowAtmColor.Color:=clrWhite;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Opacity:=2.1;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].PlanetRadius:=3.395;
//         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Slices:=64;
         FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Visible:=false;
      end; //==END== case: o3dotSatellitePlanet, o3dotSatelliteAsteroid ==//
   end; //==END== case TypeToGenerate of ==//
end;

procedure FCMogoO_OrbitalObject_Initialize( const ObjectIndex: integer );
{:Purpose: initialize a full row of objects for non satellite objects.
    Additions:
      -2013Oct20- *add: orbits.
}
   const
      LinePattern=65535;
      LineWidth=1.5;
begin
   {.the object group}
   FC3doglObjectsGroups[ObjectIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
   FC3doglObjectsGroups[ObjectIndex].Name:='FCGLObj_ObjectsGroup'+IntToStr(ObjectIndex);
   FC3doglObjectsGroups[ObjectIndex].CubeSize:=1;
   FC3doglObjectsGroups[ObjectIndex].Up.X:=0;
   FC3doglObjectsGroups[ObjectIndex].Up.Y:=1;
   FC3doglObjectsGroups[ObjectIndex].Up.Z:=0;
   FC3doglObjectsGroups[ObjectIndex].VisibleAtRunTime:=false;
   FC3doglObjectsGroups[ObjectIndex].Visible:=false;
   FC3doglObjectsGroups[ObjectIndex].ShowAxes:=false;
   {.the planet}
   FC3doglPlanets[ObjectIndex]:=TGLSphere(FC3doglObjectsGroups[ObjectIndex].AddNewChild(TGLSphere));
   FC3doglPlanets[ObjectIndex].Name:='FCGLObj_Planet'+IntToStr(ObjectIndex);
   FC3doglPlanets[ObjectIndex].Radius:=1;
   FC3doglPlanets[ObjectIndex].Slices:=64;
   FC3doglPlanets[ObjectIndex].Stacks:=64;
   FC3doglPlanets[ObjectIndex].Visible:=false;
   FC3doglPlanets[ObjectIndex].ShowAxes:=false;
   FC3doglPlanets[ObjectIndex].Material.BackProperties.Ambient.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
   FC3doglPlanets[ObjectIndex].Material.BackProperties.Diffuse.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
   FC3doglPlanets[ObjectIndex].Material.BackProperties.Emission.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
   FC3doglPlanets[ObjectIndex].Material.BackProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
   FC3doglPlanets[ObjectIndex].Material.BackProperties.Specular.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
   FC3doglPlanets[ObjectIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
   FC3doglPlanets[ObjectIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
   FC3doglPlanets[ObjectIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
   FC3doglPlanets[ObjectIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
   FC3doglPlanets[ObjectIndex].Material.FrontProperties.Emission:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
   FC3doglPlanets[ObjectIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
   FC3doglPlanets[ObjectIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
   FC3doglPlanets[ObjectIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
   FC3doglPlanets[ObjectIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
   FC3doglPlanets[ObjectIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
   FC3doglPlanets[ObjectIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
   FC3doglPlanets[ObjectIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
   FC3doglPlanets[ObjectIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
   FC3doglPlanets[ObjectIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
   FC3doglPlanets[ObjectIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
   FC3doglPlanets[ObjectIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
   FC3doglPlanets[ObjectIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
   FC3doglPlanets[ObjectIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
   FC3doglPlanets[ObjectIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
   FC3doglPlanets[ObjectIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
   FC3doglPlanets[ObjectIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
   {.the asteroid}
   FC3doglAsteroids[ObjectIndex]:=TDGLib3dsStaMesh(FC3doglObjectsGroups[ObjectIndex].AddNewChild(TDGLib3dsStaMesh));
   FC3doglAsteroids[ObjectIndex].Name:='FCGLSObObjAster'+IntToStr(ObjectIndex);
   FC3doglAsteroids[ObjectIndex].UseGLSceneBuildList:=False;
   FC3doglAsteroids[ObjectIndex].PitchAngle:=90;
   FC3doglAsteroids[ObjectIndex].UseShininessPowerHack:=0;
   FC3doglAsteroids[ObjectIndex].UseInvertWidingHack:=False;
   FC3doglAsteroids[ObjectIndex].UseNormalsHack:=True;
   FC3doglAsteroids[ObjectIndex].Scale.SetVector(0.27,0.27,0.27);
   {.the atmosphere}
   FC3doglAtmospheres[ObjectIndex]:=TGLAtmosphere(FC3doglObjectsGroups[ObjectIndex].AddNewChild(TGLAtmosphere));
   FC3doglAtmospheres[ObjectIndex].Name:='FCGLSObObjAtmos'+IntToStr(ObjectIndex);
   FC3doglAtmospheres[ObjectIndex].AtmosphereRadius:=3.55;//3.75;//3.55;
   FC3doglAtmospheres[ObjectIndex].BlendingMode:=abmOneMinusSrcAlpha;
   FC3doglAtmospheres[ObjectIndex].HighAtmColor.Color:=clrBlue;
   FC3doglAtmospheres[ObjectIndex].LowAtmColor.Color:=clrWhite;
   FC3doglAtmospheres[ObjectIndex].Opacity:=2.1;
   FC3doglAtmospheres[ObjectIndex].PlanetRadius:=3.395;
   FC3doglAtmospheres[ObjectIndex].Slices:=64;
   FC3doglAtmospheres[ObjectIndex].Visible:=false;
   {.initialize root orbit}
   FC3doglMainViewListMainOrbits[ObjectIndex]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
   FC3doglMainViewListMainOrbits[ObjectIndex].Name:='FCGLSObObjPlantOrb'+IntToStr(ObjectIndex);
   FC3doglMainViewListMainOrbits[ObjectIndex].AntiAliased:=true;
   FC3doglMainViewListMainOrbits[ObjectIndex].Division:=16;
   FC3doglMainViewListMainOrbits[ObjectIndex].LineColor.Alpha:=1;
   FC3doglMainViewListMainOrbits[ObjectIndex].LineColor.Blue:=0.953;
   FC3doglMainViewListMainOrbits[ObjectIndex].LineColor.Green:=0.576;
   FC3doglMainViewListMainOrbits[ObjectIndex].LineColor.Red:=0.478;
   FC3doglMainViewListMainOrbits[ObjectIndex].LinePattern:=LinePattern;
   FC3doglMainViewListMainOrbits[ObjectIndex].LineWidth:=LineWidth;
   FC3doglMainViewListMainOrbits[ObjectIndex].NodeColor.Color:=clrBlack;
   FC3doglMainViewListMainOrbits[ObjectIndex].NodesAspect:=lnaInvisible;
   FC3doglMainViewListMainOrbits[ObjectIndex].NodeSize:=0.005;
   FC3doglMainViewListMainOrbits[ObjectIndex].SplineMode:=lsmCubicSpline;
   {.initialize gravity well orbit}
   FC3doglMainViewListGravityWells[ObjectIndex]:=TGLLines(FC3doglObjectsGroups[ObjectIndex].AddNewChild(TGLLines));
   FC3doglMainViewListGravityWells[ObjectIndex].Name:='FCGLSObObjPlantGravOrb'+IntToStr(ObjectIndex);
   FC3doglMainViewListGravityWells[ObjectIndex].AntiAliased:=true;
   FC3doglMainViewListGravityWells[ObjectIndex].Division:=8;
   FC3doglMainViewListGravityWells[ObjectIndex].LineColor.Color:=clrYellowGreen;
   FC3doglMainViewListGravityWells[ObjectIndex].LinePattern:=LinePattern;
   FC3doglMainViewListGravityWells[ObjectIndex].LineWidth:=LineWidth;
   FC3doglMainViewListGravityWells[ObjectIndex].NodeColor.Color:=clrBlack;
   FC3doglMainViewListGravityWells[ObjectIndex].NodesAspect:=lnaInvisible;
   FC3doglMainViewListGravityWells[ObjectIndex].NodeSize:=0.005;
   FC3doglMainViewListGravityWells[ObjectIndex].SplineMode:=lsmCubicSpline;
end;

procedure FCMogO_Star_Set;
{:Purpose: set the central star.
    Additions:
      -2013Sep14- *code: move the routine in it own procedure and unit.
                  *fix: bad texture allocations for G stars.
}
   var
      fCalc
      ,StarSize: extended;

      StarClassString: string;
begin
   fCalc:=0;
   StarSize:=0;

   StarClassString:='';

   fCalc:=1390000 * FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_diameter;
   StarSize:=FCFcF_Scale_Conversion( cKmTo3dViewUnits, fCalc ) * 10;
   FCWinMain.FCGLSStarMain.Scale.X:=StarSize;
   FCWinMain.FCGLSStarMain.Scale.Y:=StarSize;
   FCWinMain.FCGLSStarMain.Scale.Z:=StarSize;
   FCWinMain.FCGLSStarMain.Position.X:=0;
   FCWinMain.FCGLSStarMain.Position.Y:=0;
   FCWinMain.FCGLSStarMain.Position.Z:=0;
   {.set starlight}
   FCWinMain.FCGLSSM_Light.Position.X:=0;
   FCWinMain.FCGLSSM_Light.Position.Y:=0;
   FCWinMain.FCGLSSM_Light.Position.Z:=0;
   {.set starlight diffuse color and star texture name}
   case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_class of
      cB5..cB9:
      begin
         StarClassString:='cB';//old file index 005
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;

      cA0..cA4:
      begin
         StarClassString:='cAless5';//old file index 003
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;

      cA5..cA9:
      begin
         StarClassString:='cAsupeg5';//old file index 004
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;

      cK0..cK4:
      begin
         StarClassString:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;

      cK5..cK8:
      begin
         StarClassString:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      cK9:
      begin
         StarClassString:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;

      cM0..cM4:
      begin
         StarClassString:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      cM5:
      begin
         StarClassString:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;

      gF0..gF4:
      begin
         StarClassString:='gFless5';//old file index 018
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;

      gF5..gF9:
      begin
         StarClassString:='gFsupeg5';//old file index 019
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;

      gG0..gG4:
      begin
         StarClassString:='gGless5';//old file index 022
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;

      gG5..gG8:
      begin
         StarClassString:='gGeg5-8';//old file index 023
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;

      gG9:
      begin
         StarClassString:='gGeg9';//old file index 024
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;

      gK0..gK4:
      begin
         StarClassString:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;

      gK5..gK8:
      begin
         StarClassString:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      gK9:
      begin
         StarClassString:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;

      gM0..gM4:
      begin
         StarClassString:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      gM5:
      begin
         StarClassString:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;

      O5..O9:
      begin
         StarClassString:='O';//old file index 028
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;

      B0..B4:
      begin
         StarClassString:='Bless5';//old file index 006
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;

      B5..B9:
      begin
         StarClassString:='Bsupeg5';//old file index 007
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;

      A0..A4:
      begin
         StarClassString:='Aless5';//old file index 001
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.966;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;

      A5..A9:
      begin
         StarClassString:='Asupeg5';//old file index 002
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;

      F0..F4:
      begin
         StarClassString:='Fless5';//old file index 020
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;

      F5..F9:
      begin
         StarClassString:='Fsupeg5';//old file index 021
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;

      G0..G4:
      begin
         StarClassString:='Gless5';//old file index 025
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;

      G5..G8:
      begin
         StarClassString:='Geg5-8';//old file index 026
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;

      G9:
      begin
         StarClassString:='Geg9';//old file index 027
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;

      K0..K4:
      begin
         StarClassString:='Kless5';//old file index 011
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;

      K5..K8:
      begin
         StarClassString:='Keg5-8';//old file index 012
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      K9:
      begin
         StarClassString:='Keg9';//old file index 013
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;

      M0..M4:
      begin
         StarClassString:='Mless5';//old file index 016
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;

      M5..M9:
      begin
         StarClassString:='Msupeg5';//old file index 017
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;

      WD0..WD9:
      begin
         StarClassString:='WDeg0-9';//old file index 029
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;

      PSR:
      begin
         StarClassString:='PSR';//old file index 030
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.584;
      end;

      BH:
      begin
         StarClassString:='BH';//no old file (previous iteration of FAR Colony had no tex
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.325;
      end;
   end;
   FCWinMain.FCGLSSM_Light.Specular.Blue:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Green:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Red:=FCWinMain.FCGLSSM_Light.Diffuse.Red;
   {.set star's picture}
   FCWinMain.FCGLSStarMain.Material.Texture.Image.LoadFromFile(FCVdiPathResourceDir+'pics-ogl-stars\star_'+StarClassString+'.png');
end;

procedure FCMogO_SurfaceMapTexture_Assign(const MTAoobjIdx, MTAsatIdx, MTAsatObjIdx: integer);
{:Purpose: assign the correct surface map texture on a designed orbital object.
    Additions:
      -2013Jun20- *add/mod: apply the new types of planets.
                  *rem: standard pictures for icy/telluric planets are removed. There are all custom now
      -2013Jun19- *add/mod: update the hydrosphere part with the last changes.
      -2010Jan07- *add: implement planet w/ personalized textures.
                  *add: the rest of telluric/icy planets w/ standard textures.
                  *add: implement calculations for mean temperature and and hydrosphere type for satellites.
      -2010Jan06- *add: implement calculations for mean temperature and and hydrosphere type.
}
var
   MTAdmpObjTp: TFCEduOrbitalObjectTypes;
   MTAdmpHydroTp: TFCEduHydrospheres;
   MTAdmpLibName
   ,MTAdmpOobjToken
   ,MTAdmpTexPath: string;
   BaseTemperatureMean: extended;
begin
   MTAdmpLibName:='';
   if MTAsatIdx=0
   then
   begin
      MTAdmpObjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_type;
      MTAdmpHydroTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_hydrosphere;
   end
   else if MTAsatIdx>0
   then
   begin
      MTAdmpObjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_satellitesList[MTAsatIdx].OO_type;
      MTAdmpHydroTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_satellitesList[MTAsatIdx].OO_hydrosphere;
   end;
   BaseTemperatureMean:=FCFuF_OrbitalPeriods_GetBaseTemperature(
      FC3doglCurrentStarSystem
      ,FC3doglCurrentStar
      ,MTAoobjIdx
      ,MTAsatIdx
      );
   {.for gaseous planets => standard textures}
   if ( MTAdmpObjTp >= ootPlanet_Gaseous_Uranus )
      and ( MTAdmpObjTp<ootSatellite_Asteroid_Metallic )
   then
   begin
      case MTAdmpObjTp of
         ootPlanet_Gaseous_Uranus:
         begin
            if BaseTemperatureMean<=80
            then  MTAdmpLibName:='UranusCold'
            else if BaseTemperatureMean>80
            then  MTAdmpLibName:='UranusHot';
         end;
         ootPlanet_Gaseous_Neptune:
         begin
            if BaseTemperatureMean<=80
            then  MTAdmpLibName:='NeptuneCold'
            else if BaseTemperatureMean>80
            then  MTAdmpLibName:='NeptuneHot';
         end;
         ootPlanet_Gaseous_Saturn:
         begin
            if BaseTemperatureMean<=145
            then  MTAdmpLibName:='SaturnCold'
            else if BaseTemperatureMean>145
            then  MTAdmpLibName:='SaturnHot';
         end;
         ootPlanet_Jovian:
         begin
            if BaseTemperatureMean<=175
            then  MTAdmpLibName:='JovianCold'
            else if BaseTemperatureMean>175
            then  MTAdmpLibName:='JovianHot';
         end;
         ootPlanet_Supergiant:
         begin
            if BaseTemperatureMean<=175
            then  MTAdmpLibName:='SuperGiantCold'
            else if BaseTemperatureMean>175
            then  MTAdmpLibName:='SuperGiantHot';
         end;
      end; //==END== case MTAdmpObjTp ==//
   end //==END== if (MTAdmpObjTp>Plan_Icy_CallistoH3H4Atm0 and <Sat_Aster_Metall) ==//
   {.for planet w/ personalized textures}
   else if ( ( MTAdmpObjTp>ootAsteroid_Icy ) and ( MTAdmpObjTp<ootPlanet_Gaseous_Uranus ) )
      or ( MTAdmpObjTp>ootSatellite_Asteroid_Icy ) then
   begin
      if MTAsatIdx=0
      then MTAdmpOobjToken:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_dbTokenId
      else if MTAsatIdx>0
      then MTAdmpOobjToken:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[MTAoobjIdx].OO_satellitesList[MTAsatIdx].OO_dbTokenId;
   end;
   {.assign standard texture}
   if MTAdmpLibName<>''
   then
   begin
      if MTAsatIdx=0
      then
      begin
         if FC3doglPlanets[MTAoobjIdx].Material.MaterialLibrary=nil
         then FC3doglPlanets[MTAoobjIdx].Material.MaterialLibrary:=FC3doglMaterialLibraryStandardPlanetTextures;
         FC3doglPlanets[MTAoobjIdx].Material.LibMaterialName:=MTAdmpLibName;
      end
      else if MTAsatIdx>0
      then
      begin
         if FC3doglSatellitesPlanet[MTAsatObjIdx].Material.MaterialLibrary=nil
         then FC3doglSatellitesPlanet[MTAsatObjIdx].Material.MaterialLibrary:=FC3doglMaterialLibraryStandardPlanetTextures;
         FC3doglSatellitesPlanet[MTAsatObjIdx].Material.LibMaterialName:=MTAdmpLibName;
      end;
   end
   {.assign personalized texture}
   else if MTAdmpLibName=''
   then
   begin
      if FileExists(FCVdiPathResourceDir+'pics-ogl-oobj-pers\'+MTAdmpOobjToken+'.jpg')
      then MTAdmpTexPath:=FCVdiPathResourceDir+'pics-ogl-oobj-pers\'+MTAdmpOobjToken+'.jpg'
      else MTAdmpTexPath:=FCVdiPathResourceDir+'pics-ogl-oobj-pers\_error_map.jpg';
      if MTAsatIdx=0
      then FC3doglPlanets[MTAoobjIdx].Material.Texture.Image.LoadFromFile(MTAdmpTexPath)
      else if MTAsatIdx>0
      then FC3doglSatellitesPlanet[MTAsatObjIdx].Material.Texture.Image.LoadFromFile(MTAdmpTexPath);
   end;
end;

//procedure FCMogoO_TemporarySat_Free;
{:Purpose: free the temporary satellite data structure.
    Additions:
}
//begin
//   if FC3ogooTemporaryAsteroid<>nil
//   then FC3ogooTemporaryAsteroid.Free;
//end;

end.
