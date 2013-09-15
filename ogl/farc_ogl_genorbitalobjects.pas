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
   ,GLObjects

   ,oxLib3dsMeshLoader;

type TFCEogooOrbital3dObjectTypes=(
   o3dotPlanet
   ,o3dotAsteroid
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
///   set the atmosphere color following main gases which compose it
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMogoO_Atmosphere_SetColors(
   const ASCoobjIdx
         ,ASCsatIdx
         ,ASCsatObjIdx: integer
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

procedure FCMogoO_TemporarySat_Free;

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

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ
   ,farc_main;

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

procedure FCMogoO_Atmosphere_SetColors(
   const ASCoobjIdx
         ,ASCsatIdx
         ,ASCsatObjIdx: integer
   );
{:Purpose: set the atmosphere color following main gases which compose it.
    Additions:
      -2010Jan31- *mod: change in ASAsizeCoef.
      -2010Jan05- *add: set also atmosphere scale.
                  *mod: refactor the method considering the new function.
}
const
   ASAsizeCoef=2;//1.948;//.892
var
   ASChighColRed
   ,ASChighColGreen
   ,ASChighColBlue
   ,ASClowColRed
   ,ASClowColGreen
   ,ASClowColBlue: extended;

   ASCh2
   ,ASChe
   ,ASCn2
   ,ASCo2
   ,ASCh2s
   ,ASCco2
   ,ASCso2
   : TFCEduAtmosphericGasStatus;
begin
   if ASCsatIdx=0
   then
   begin
      ASCh2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceH2;
      ASChe:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceHe;
      ASCn2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceN2;
      ASCo2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceO2;
      ASCh2s:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceH2S;
      ASCco2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceCO2;
      ASCso2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_atmosphere.AC_gasPresenceSO2;
   end
   else if ASCsatIdx>0
   then
   begin
      ASCh2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceH2;
      ASChe:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceHe;
      ASCn2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceN2;
      ASCo2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceO2;
      ASCh2s:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceH2S;
      ASCco2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceCO2;
      ASCso2:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASCoobjIdx].OO_satellitesList[ASCsatIdx].OO_atmosphere.AC_gasPresenceSO2;
   end;
   {.N2 atmosphere - titan like}
   if (ASCn2=agsPrimary)
      and (ASCco2<agsPrimary)
      and (ASCo2<agsPrimary)
   then
   begin
      ASChighColRed:=0.223529;
      ASChighColGreen:=0.286274;
      ASChighColBlue:=0.415686;
      ASClowColRed:=0.615686;
      ASClowColGreen:=0.447058;
      ASClowColBlue:=0.247058;
   end
   {.N2/CO2 atmosphere - mars like}
   else if (ASCn2=agsPrimary)
      and (ASCco2=agsPrimary)
      and (ASCo2<agsPrimary)
   then
   begin
      ASChighColRed:=0.372549;
      ASChighColGreen:=0.364705;
      ASChighColBlue:=0.317647;
      ASClowColRed:=0.760784;
      ASClowColGreen:=0.745098;
      ASClowColBlue:=0.709803;
   end
   {.N2/O2 atmosphere - earth like}
   else if (ASCn2=agsPrimary)
      and (ASCco2<agsPrimary)
      and (ASCo2=agsPrimary)
   then
   begin
      ASChighColRed:=0.247058;
      ASChighColGreen:=0.392156;
      ASChighColBlue:=0.6;
      ASClowColRed:=0.196078;
      ASClowColGreen:=0.6;
      ASClowColBlue:=0.8;
   end
   {.H2/He atmosphere - saturn like}
   else if (ASCh2=agsPrimary)
      and (ASChe=agsPrimary)
   then
   begin
      ASChighColRed:=0.403921;
      ASChighColGreen:=0.454901;
      ASChighColBlue:=0.478431;
      ASClowColRed:=0.709803;
      ASClowColGreen:=0.639215;
      ASClowColBlue:=0.458823;
   end
   {.H2S/SO2 atmosphere - io like}
   else if (ASCh2s=agsPrimary)
      and (ASCso2=agsPrimary)
   then
   begin
      ASChighColRed:=0.556862;
      ASChighColGreen:=0.549019;
      ASChighColBlue:=0.325490;
      ASClowColRed:=0.866666;
      ASClowColGreen:=0.866666;
      ASClowColBlue:=0.866666;
   end;
   {.set the colors}
   if ASCsatIdx=0
   then
   begin
      FC3doglAtmospheres[ASCoobjIdx].HighAtmColor.Red:=ASChighColRed;
      FC3doglAtmospheres[ASCoobjIdx].HighAtmColor.Green:=ASChighColGreen;
      FC3doglAtmospheres[ASCoobjIdx].HighAtmColor.Blue:=ASChighColBlue;
      FC3doglAtmospheres[ASCoobjIdx].LowAtmColor.Red:=ASClowColRed;
      FC3doglAtmospheres[ASCoobjIdx].LowAtmColor.Green:=ASClowColGreen;
      FC3doglAtmospheres[ASCoobjIdx].LowAtmColor.Blue:=ASClowColBlue;
      FC3doglAtmospheres[ASCoobjIdx].SetOptimalAtmosphere2
         (
            FC3doglPlanets[ASCoobjIdx].Scale.X
            -(
               (sqrt(FC3doglPlanets[ASCoobjIdx].Scale.X)/ASAsizeCoef)
               -(sqrt(FC3doglPlanets[ASCoobjIdx].Scale.X)/2)
            )
         );
   end
   else if ASCsatIdx>0
   then
   begin
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].HighAtmColor.Red:=ASChighColRed;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].HighAtmColor.Green:=ASChighColGreen;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].HighAtmColor.Blue:=ASChighColBlue;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].LowAtmColor.Red:=ASClowColRed;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].LowAtmColor.Green:=ASClowColGreen;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].LowAtmColor.Blue:=ASClowColBlue;
      FC3doglSatellitesAtmospheres[ASCsatObjIdx].SetOptimalAtmosphere2
         (
            FC3doglSatellites[ASCsatObjIdx].Scale.X
            -(
               (sqrt(FC3doglSatellites[ASCsatObjIdx].Scale.X)/ASAsizeCoef)
               -(sqrt(FC3doglSatellites[ASCsatObjIdx].Scale.X)/2)
            )
         );
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
      -2010Dec07- *add: intialize the material of planets, if needed.
      -2009Dec14- *add: complete satellite generation.
      -2009Dec12- *mod: delete the method's boolean and replace it by a switch.
                  *add: generate satellite.
      -2009Dec07- *update atmosphere initialization.
}
begin
   if (TypeToGenerate=o3dotPlanet)
      or (TypeToGenerate=o3dotAsteroid)
   then
   begin
      {.the object group}
      FC3doglObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3doglObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSObObjGroup'+IntToStr(OrbitalObject3DIndex);
      FC3doglObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
      FC3doglObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
      FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
      FC3doglObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
      FC3doglObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
      FC3doglObjectsGroups[OrbitalObject3DIndex].Visible:=false;
      FC3doglObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
      {.the planet}
      FC3doglPlanets[OrbitalObject3DIndex]:=TGLSphere(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
      FC3doglPlanets[OrbitalObject3DIndex].Name:='FCGLSObObjPlnt'+IntToStr(OrbitalObject3DIndex);
      FC3doglPlanets[OrbitalObject3DIndex].Radius:=1;
      FC3doglPlanets[OrbitalObject3DIndex].Slices:=64;
      FC3doglPlanets[OrbitalObject3DIndex].Stacks:=64;
      FC3doglPlanets[OrbitalObject3DIndex].Visible:=false;
      FC3doglPlanets[OrbitalObject3DIndex].ShowAxes:=false;
      if TypeToGenerate=o3dotPlanet
      then
      begin
         FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Ambient.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Diffuse.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Emission.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Shininess
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
         FC3doglPlanets[OrbitalObject3DIndex].Material.BackProperties.Specular.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3doglPlanets[OrbitalObject3DIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Emission
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3doglPlanets[OrbitalObject3DIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
         FC3doglPlanets[OrbitalObject3DIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.BorderColor.Color:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.DepthTextureMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareFunc:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
         FC3doglPlanets[OrbitalObject3DIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapS:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapT:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapR:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootNorm ==//
      else if TypeToGenerate=o3dotAsteroid
      then
      begin
         {.the asteroid}
         FC3doglAsteroids[OrbitalObject3DIndex]:=TDGLib3dsStaMesh(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TDGLib3dsStaMesh));
         FC3doglAsteroids[OrbitalObject3DIndex].Name:='FCGLSObObjAster'+IntToStr(OrbitalObject3DIndex);
         FC3doglAsteroids[OrbitalObject3DIndex].UseGLSceneBuildList:=False;
         FC3doglAsteroids[OrbitalObject3DIndex].PitchAngle:=90;
         FC3doglAsteroids[OrbitalObject3DIndex].UseShininessPowerHack:=0;
         FC3doglAsteroids[OrbitalObject3DIndex].UseInvertWidingHack:=False;
         FC3doglAsteroids[OrbitalObject3DIndex].UseNormalsHack:=True;
         FC3doglAsteroids[OrbitalObject3DIndex].Scale.SetVector(0.27,0.27,0.27);
         FC3doglAsteroids[OrbitalObject3DIndex].Load3DSFileFrom( FCFogoO_Asteroid_Set( OrbitalObject3DIndex, 0 ) );
         FC3doglAsteroids[OrbitalObject3DIndex].Material.FrontProperties:=FC3ogooTemporaryAsteroid.Material.FrontProperties;
      end;
      {.the atmosphere}
      FC3doglAtmospheres[OrbitalObject3DIndex]:=TGLAtmosphere(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLAtmosphere));
      FC3doglAtmospheres[OrbitalObject3DIndex].Name:='FCGLSObObjAtmos'+IntToStr(OrbitalObject3DIndex);
      FC3doglAtmospheres[OrbitalObject3DIndex].AtmosphereRadius:=3.55;//3.75;//3.55;
      FC3doglAtmospheres[OrbitalObject3DIndex].BlendingMode:=abmOneMinusSrcAlpha;
      FC3doglAtmospheres[OrbitalObject3DIndex].HighAtmColor.Color:=clrBlue;
      FC3doglAtmospheres[OrbitalObject3DIndex].LowAtmColor.Color:=clrWhite;
      FC3doglAtmospheres[OrbitalObject3DIndex].Opacity:=2.1;
      FC3doglAtmospheres[OrbitalObject3DIndex].PlanetRadius:=3.395;
      FC3doglAtmospheres[OrbitalObject3DIndex].Slices:=64;
      FC3doglAtmospheres[OrbitalObject3DIndex].Visible:=false;
   end
   {.satellites}
   else if (TypeToGenerate=o3dotSatellitePlanet)
      or (TypeToGenerate=o3dotSatelliteAsteroid)
   then
   begin
      {.the object group}
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Name:='FCGLSsatGrp'+IntToStr(OrbitalObject3DIndex);
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].CubeSize:=1;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.X:=0;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Y:=1;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Up.Z:=0;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].VisibleAtRunTime:=false;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].Visible:=false;
      FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].ShowAxes:=false;
      {.the planet}
      FC3doglSatellites[OrbitalObject3DIndex]:=TGLSphere(FC3doglSatellitesObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLSphere));
      FC3doglSatellites[OrbitalObject3DIndex].Name:='FCGLSsatPlnt'+IntToStr(OrbitalObject3DIndex);
      FC3doglSatellites[OrbitalObject3DIndex].Radius:=1;
      FC3doglSatellites[OrbitalObject3DIndex].Slices:=64;
      FC3doglSatellites[OrbitalObject3DIndex].Stacks:=64;
      FC3doglSatellites[OrbitalObject3DIndex].Visible:=false;
      FC3doglSatellites[OrbitalObject3DIndex].ShowAxes:=false;
      if TypeToGenerate=o3dotSatellitePlanet
      then
      begin
         FC3doglSatellites[OrbitalObject3DIndex].Material.BackProperties.Ambient.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3doglSatellites[OrbitalObject3DIndex].Material.BackProperties.Diffuse.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3doglSatellites[OrbitalObject3DIndex].Material.BackProperties.Emission.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//         FC3DobjSat[OOGobjIdx].Material.PolygonMode:=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.BackProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
         FC3doglSatellites[OrbitalObject3DIndex].Material.BackProperties.Specular.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3doglSatellites[OrbitalObject3DIndex].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FrontProperties.Emission:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//         FC3DobjSat[OOGobjIdx].Material.PolygonMode:=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FrontProperties.Shininess:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3doglSatellites[OrbitalObject3DIndex].Material.FrontProperties.Specular:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
         FC3doglSatellites[OrbitalObject3DIndex].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//         FC3DobjSat[OOGobjIdx].Material.Texture.BorderColor.Color:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//         FC3DobjSat[OOGobjIdx].Material.Texture.DepthTextureMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.FilteringQuality:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareFunc:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
         FC3doglSatellites[OrbitalObject3DIndex].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapS:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapT:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapR:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootSatNorm ==//
      else if TypeToGenerate=o3dotSatelliteAsteroid then
      begin
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
         FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Load3DSFileFrom( FCFogoO_Asteroid_Set( OrbitalObjectIndex, SatelliteIndex ) );
         FC3doglSatellitesAsteroids[OrbitalObject3DIndex].Material.FrontProperties:=FC3ogooTemporaryAsteroid.Material.FrontProperties;
//         FC3doglSatellitesAsteroids[OrbitalObject3DIndex].TurnAngle:=S_orbitalObjects[OrbitalObjCount].OO_isNotSat_axialTilt;
      end;
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
      FC3doglSatellitesAtmospheres[OrbitalObject3DIndex].Visible:=false;
   end; //==END== else if (OOGobjClass=oglvmootSatNorm) or (=oglvmootSatAster) ==//
end;

procedure FCMogoO_TemporarySat_Free;
{:Purpose: free the temporary satellite data structure.
    Additions:
}
begin
   if FC3ogooTemporaryAsteroid<>nil
   then FC3ogooTemporaryAsteroid.Free;
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

end.
