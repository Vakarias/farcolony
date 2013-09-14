{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: OpenGL Framework - main view unit

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
unit farc_ogl_viewmain;

interface

uses
   Math
   ,SysUtils

   ,DecimalRounding_JH1

   ,GLAtmosphere
   ,GLColor
   ,GLObjects
   ,GLScene
//   ,GLVectorFileObjects
//   ,glfile3ds
//   ,GLFile3DSSceneObjects

   ,oxLib3dsMeshLoader;

type TFCEovmFocusedObjects=(
   foStar
   ,foOrbitalObject
   ,foSatellite
   ,foSpaceUnit
   );

type TFCEovmOrbital3dObjectTypes=(
   o3dotPlanet
   ,o3dotAsteroid
   ,o3dotSatellitePlanet
   ,o3dotSatelliteAsteroid
   );



type TFCEovmSpaceUnitOrigin=(
   scfDocked
   ,scfInOrbit
   ,scfInSpace
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit
///</summary>
function FCFovM_Focused3dObject_GetType(): integer;

//===========================END FUNCTIONS SECTION==========================================


///<summary>
///target a specified object in 3d view and initialize user's interface if needed
///</summary>
///   <param name="CMTidxOfObj">selected object index -10: space unit -1: central star >=0: orbital object 100: sat</param>
procedure FCMovM_CameraMain_Target(
   const CMTidxOfObj: integer;
   const CMTisUpdPMenu: boolean
   );

///<summary>
///   target a specified space unit, this one must but owned by the player
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMoglMV_Camera_TargetSpaceUnit( const DBSpaceUnit: integer);

///<summary>
///setup 3d main view: star itself and it's eventual planets and satellites
///</summary>
///   <param name="StarSys">star system index #</param>
///   <param name="Star">star index #</param>
///   <param name="LSVUresetSelect">switch for reset FCV3dMViewObjSlctdInScene</param>
procedure FCMovM_3DView_Update(
   const StarSys
         ,Star: string;
   const LSVUoobjReset,
         LSVUspUnReset: Boolean
   );



///<summary>
///   generate a 3d objects row of selected index
///</summary>
///   <param name="OOGobjClass">class of object to generate</param>
///   <param name="OGobjIdx">index of object row</param>
procedure FCMoglVM_OObj_Gen(
   const OOGobjClass: TFCEovmOrbital3dObjectTypes;
   const OOGobjIdx: integer
   );

///<summary>
///   change space unit scale according to it's distance, it's a fast&dirty fix
///</summary>
///    <param name="OOSUCSobjIdx">object index</param>
procedure FCMoglVM_OObjSpUn_ChgeScale(const OOSUCSobjIdx: integer);

///<summary>
///   display space units in orbit of a selected orbital object.
///</summary>
///    <param name="OOSUIOUoobjIdx">orbital object DB index id</param>
///    <param name="OOSUIOUsatIdx">satellite DB index id, if>0 then it gene</param>
///    <param name="OOSUIOUmustGen">true: generate the space unit 3d object</param>
procedure FCMoglVM_OObjSpUn_inOrbit(
   const OOSUIOUoobjIdx,
         OOSUIOUsatIdx,
         OOSUIOUsatObjIdx: integer;
   const OOSUIOUmustGen: boolean
   );

///<summary>
///   generate a space unit.
///</summary>
///   <param name="SUGstatus">space unit status</param>
///   <param name="SUGfac">faction 's index #</param>
///   <param name="SUGspUnOwnIdx">space unit owned index</param>
procedure FCMoglVM_SpUn_Gen(
   const SUGstatus: TFCEovmSpaceUnitOrigin;
   const SUGfac
         ,SUGspUnOwnIdx: integer
   );

///<summary>
///   restore the initial size of the targeted space unit
///</summary>
procedure FCMoglVMain_SpUnits_SetInitSize(const SUSIZresetSize: boolean);

///<summary>
///   resize the targeted space unit correctly, depending on distance
///</summary>
procedure FCMoglVM_SpUn_SetZoomScale;

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_main
   ,farc_ogl_genorbits
   ,farc_ogl_ui
   ,farc_data_spu
   ,farc_spu_functions
   ,farc_ui_actionpanel
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================

var
   {.dump asteroid}
   FC3oglvmAsteroidTemp: TDGLib3dsStaMesh;









{:DEV NOTES: OGL CLEAR SCENE - FCMoglVM_Scene_Cleanup;

   - freeze realtime + ogl timers
   - unload all ui + store their state

   - put at zero S_orbitalObjects[.].OO_isNotSat_1st3dObjectSatelliteIndex




.}

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFoglVMain_Aster_Set(
   const ASoobjIdx, ASsatIdx: integer;
   const ASisSat: boolean
   ): string;
{:Purpose: return .3ds path relative to aster type and load the AsterDmp with right
material.
    Additions:
}
var
   ASresDmp: string;
   ASobjTp: TFCEduOrbitalObjectTypes;
begin
   {.test if AsterDmp is created}
   if FC3oglvmAsteroidTemp=nil then
   begin
      FC3oglvmAsteroidTemp:=TDGLib3dsStaMesh(FCWinMain.FCGLSStarMain.AddNewChild(TDGLib3dsStaMesh));
      FC3oglvmAsteroidTemp.Name:='FCGLSasterDmp';
      FC3oglvmAsteroidTemp.UseGLSceneBuildList:=False;
      FC3oglvmAsteroidTemp.UseShininessPowerHack:=0;
   end;
   {.get the object type}
   if ASisSat
   then ASobjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASoobjIdx].OO_satellitesList[ASsatIdx].OO_type
   else if not ASisSat
   then ASobjTp:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[ASoobjIdx].OO_type;
   {.determine the type of asteroid to load}
   case ASobjTp of
      ootAsteroid_Metallic, ootSatellite_Asteroid_Metallic:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVdiPathResourceDir+'obj-3ds-aster\aster_metall.3ds';
         with FC3oglvmAsteroidTemp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.9;
            Diffuse.Green:=0.9;
            Diffuse.Red:=0.9;
            Emission.Color:=clrGray80;
            Shininess:=90;
         end;
      end;
      ootAsteroid_Silicate, ootSatellite_Asteroid_Silicate:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVdiPathResourceDir+'obj-3ds-aster\aster_sili.3ds';
         with FC3oglvmAsteroidTemp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.5;
            Diffuse.Green:=0.5;
            Diffuse.Red:=0.5;
            Emission.Color:=clrGray90;
            Shininess:=70;
         end;
      end;
      ootAsteroid_Carbonaceous, ootSatellite_Asteroid_Carbonaceous:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVdiPathResourceDir+'obj-3ds-aster\aster_carbo.3ds';
         with FC3oglvmAsteroidTemp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.8;
            Diffuse.Green:=0.8;
            Diffuse.Red:=0.8;
            Emission.Color:=clrBlack;
            Shininess:=50;
         end;
      end;
      ootAsteroid_Icy, ootSatellite_Asteroid_Icy:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVdiPathResourceDir+'obj-3ds-aster\aster_icy.3ds';
         with FC3oglvmAsteroidTemp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.4;
            Ambient.Green:=0.4;
            Ambient.Red:=0.4;
            Diffuse.Blue:=0.8;
            Diffuse.Green:=0.8;
            Diffuse.Red:=0.8;
            Emission.Color:=clrGray10;
            Shininess:=80;
         end;
      end;
   end; //==END== case ASobjTp ==//
   Result:=ASresDmp;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMoglVMain_Atmosph_SetCol(
   const ASCoobjIdx
         ,ASCsatIdx
         ,ASCsatObjIdx: integer
   );
{:Purpose: set the atmosphere color following main gases which compose it..
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

procedure FCMovM_CameraMain_Target(
   const CMTidxOfObj: integer;
   const CMTisUpdPMenu: boolean
   );
{:Purpose: target a specified object in 3d view and initialize user's interface if needed.
    Additions:
      -2010Feb17- *add: set space unit size if targeted.
                  *add: restore space unit size, if it was previously targeted.
      -2009Dec20- *add: satellite data display link.
      -2009Dec16- *mod: change camera bias for satellite focus.
      -2009Dec15- *add: store the player's location.
                  *add: satellite focus.
      -2009Dec08- *change camera near plane following the target type.
      -2009Sep27- *add focused popup menu update.
      -2009Sep23- *display focused object name for space units.
      -2009Sep22- *tweaks in zoom for central star focus.
                  *display focused object name.
      -2009Sep20- *camera change for location and zoom during a space unit targeting.
      -2009Sep17- *add space unit targeting.
      -2009Sep06- *gone back to previous FARC camera settings for orbital object focus.
                  *use cubesize for objgroup.
      -2009Aug30- *other object targeting.
      -2009Aug27- *star targeting completion.
}
var
   CMTdmpCoef: extended;
   CMTdmpSatIdx
   ,CMTdmpSatPlanIdx: integer;
begin
   {.space unit selected}
   if CMTidxOfObj=-1
   then
   begin
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];
      FC3doglSpaceUnitSize:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
      FCMoglVM_OObjSpUn_ChgeScale(FC3doglSelectedSpaceUnit);
      CMTdmpCoef:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*8;
      FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.X+FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X+(0.05*CMTdmpCoef);
      FCWinMain.FCGLSCamMainViewGhost.Position.Y
         :=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y+(0.04*CMTdmpCoef);
      FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.Z+FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z+(0.05*CMTdmpCoef);
      {.configuration}
      FCWinMain.FCGLSCamMainView.NearPlaneBias
         :=0.01+(sqrt(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU)/100);//30);

      FCMoglVM_SpUn_SetZoomScale;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];
      {.update focused object name}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
     {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiAP_Update_SpaceUnit;
   end
   {.central star selected}
   else if CMTidxOfObj=0
   then
   begin
      if FC3doglSpaceUnitSize<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FCWinMain.FCGLSStarMain;
      FCWinMain.FCGLSCamMainViewGhost.Position.X:=FCWinMain.FCGLSStarMain.Scale.X*2;
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FCWinMain.FCGLSStarMain.Scale.Y*1.5;
      FCWinMain.FCGLSCamMainViewGhost.Position.Z:=0;
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FCWinMain.FCGLSStarMain;
      {.update focused object name}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiAP_Update_OrbitalObject;
   end
   {.orbital object selected}
   else if (CMTidxOfObj>0)
      and (CMTidxOfObj<100)
   then
   begin
      if FC3doglSpaceUnitSize<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglObjectsGroups[CMTidxOfObj];
      {.X location}
      if FC3doglObjectsGroups[CMTidxOfObj].Position.X>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3doglObjectsGroups[CMTidxOfObj].Position.X)-(FC3doglObjectsGroups[CMTidxOfObj].CubeSize*2.3)
      else if FC3doglObjectsGroups[CMTidxOfObj].Position.X<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3doglObjectsGroups[CMTidxOfObj].Position.X)+(FC3doglObjectsGroups[CMTidxOfObj].CubeSize*2.3);
      {.Y location}
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
      {.Z location}
      if FC3doglObjectsGroups[CMTidxOfObj].Position.Z>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3doglObjectsGroups[CMTidxOfObj].Position.Z)-(FC3doglObjectsGroups[CMTidxOfObj].CubeSize*2.3)
      else if FC3doglObjectsGroups[CMTidxOfObj].Position.Z<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3doglObjectsGroups[CMTidxOfObj].Position.Z)+(FC3doglObjectsGroups[CMTidxOfObj].CubeSize*2.3);
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglObjectsGroups[CMTidxOfObj];
      {.update focused object data}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiAP_Update_OrbitalObject;
      {.store the player's location}
      FCVdgPlayer.P_viewOrbitalObject:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId;
   end
   {.satellite selected}
   else if CMTidxOfObj=100
   then
   begin
      if FC3doglSpaceUnitSize<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite];
      {.X location}
      if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X)-(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3)
      else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X)+(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3);
      {.Y location}
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
      {.Z location}
      if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z)-(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3)
      else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z)+(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3);
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=0.55;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite];
      {.update focused object data}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiAP_Update_OrbitalObject;
      {.store the player's location}
      CMTdmpSatIdx:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
      CMTdmpSatPlanIdx:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
      FCVdgPlayer.P_viewSatellite
         :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[CMTdmpSatPlanIdx].OO_satellitesList[CMTdmpSatIdx].OO_dbTokenId;
   end;
end;

function FCFoglVMain_CloudsCov_Conv2AtmOp(const CCC2AOcover: extended): extended;
{:Purpose: calculate atmosphere opacity following clouds covers given.à
   Additions:
      -2010Mar21- *add: reinstate round of the result with a new method.
}
var CCC2AOdmp: extended;
begin
   if CCC2AOcover=0
   then Result:=0
   else if CCC2AOcover=-1
   then Result:=0.7
   else
   begin
      try
         CCC2AOdmp:=CCC2AOcover/(10+(sqrt(CCC2AOcover)/8))   ;
      finally
         Result:=DecimalRound(CCC2AOdmp, 1, 0.01);
      end;
   end;
end;

procedure FCMoglVMain_MapTex_Assign(const MTAoobjIdx, MTAsatIdx, MTAsatObjIdx: integer);
{:Purpose: assign the correct surface/atmosphere texture map on a designed orbital object.
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
         if FC3doglSatellites[MTAsatObjIdx].Material.MaterialLibrary=nil
         then FC3doglSatellites[MTAsatObjIdx].Material.MaterialLibrary:=FC3doglMaterialLibraryStandardPlanetTextures;
         FC3doglSatellites[MTAsatObjIdx].Material.LibMaterialName:=MTAdmpLibName;
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
      then FC3doglSatellites[MTAsatObjIdx].Material.Texture.Image.LoadFromFile(MTAdmpTexPath);
   end;
end;

procedure FCMoglMV_Camera_TargetSpaceUnit( const DBSpaceUnit: integer);
{:Purpose: target a specified space unit, this one must but owned by the player.
    Additions:
}
begin
   if FCDdgEntities[0].E_spaceUnits[DBSpaceUnit].SU_linked3dObject>0 then
   begin
      FC3doglSelectedSpaceUnit:=FCDdgEntities[0].E_spaceUnits[DBSpaceUnit].SU_linked3dObject;
      FCMovM_CameraMain_Target(-1, true)
      {:DEV NOTES: put the spu part of cammain target here + root test if DBSpaceUnit=0 then use FC3doglSelectedSpaceUnit.}
   end;
end;

function FCFovM_Focused3dObject_GetType(): integer;
{:Purpose: return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit.
    Additions:
}
{:DEV NOTES: put the result in an ENUM!.}
begin
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FCWinMain.FCGLSStarMain
   then Result:=0
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then Result:=1
   else if ( FC3doglMainViewTotalSatellites>0 )
      and ( FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite] )
   then Result:=2
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit]
   then Result:=3;
end;

procedure FCMovM_3DView_Update(
   const StarSys
         ,Star: string;
   const LSVUoobjReset,
         LSVUspUnReset: Boolean
   );
{:Purpose: setup local star view: star itself and it's eventual planets & satellites.
    Additions:
      -2013Sep14- *add/mod: start of the overhaul/cleaning/refactoring.
      -2010Sep15- *add: entities code.
      -2010Jun15- *mod: use the new function for space location.
      -2010Apr25- *add: generate docked space units.
      -2010Apr05- *add: initialize star's specular colors for a better looking.
      -2010Mar07- *mod: change the display for space units which aren't in orbit.
      -2010Jan07- *add: sky/surface texture mapping for planets (satellites).
      -2010Jan05- *add: sky/surface texture mapping for planets.
                  *mod: small tweaks in atmosphere display.
      -2009Dec28- *add: set atmosphere color following main gases composition.
                  *mod: change the calculation of atmosphere size.
      -2009Dec18- *add: complete satellites display.
      -2009Dec12- *add: begin satellites display.
      -2009Dec09- *complete atmosphere display.
                  *change relative star display size for be more realistic after the
                  distance changes.
      -2009Dec07- *add atmosphere display.
      -2009Nov15- *re-enable and optimize space units generations that are in free space.
      -2009Nov05- *separate reset of FCV3dMVorbObjSlctd and FCV3dMVspUnitSlctd.
      -2009Sep23- *add space unit faction and proper id# directly in object itself.
      -2009Sep20- *load space unit location x/z in FCRplayer.Play_suOwned.
                  *display space unit in orbit for asteroids.
      -2009Sep19- *add space units in orbit.
      -2009Sep17- *add space units initialization.
      -2009Sep15- *set orbit build for asteroid.
      -2009Sep14- *add gravity well orbit.
      -2009Sep09- *add orbit object initialization.
      -2009Sep07- *test code for spacecraft display
      -2009Sep06- *fix objgroup size.
      -2009Sep03- *relocate correctly designed objects.
      -2009Sep01- *fix a bug in object count.
                  *set final size of 3d object lists at the end of process.
      -2009Aug31- *include new 3d object creation method.
                  *orbital object generation - planets.
      -2009Aug29- *orbital object generation - asteroids.
      -2009Aug26- *addition of FCV3dMViewObjSlctdInScene switch to reset this variable.
                  *post setup addition.
                  *star settings completion.
}
const
   LSVUblocCnt=128;
var
   j: integer;
   i: integer;
   LSVUangleRad
	,OrbitDistanceInUnits
   ,LSVUsatDistUnit
   ,LSVUstarSize: extended;

   TDMVUorbObjCnt,
   MVUentCnt,
   LSVUorbObjTtlInDS,
   LSVUspUnCnt,
   LSVUspUnInTtl,
   LSVUspUnFacTtl,
   LSVUdmpCount,
   LSVUspUntOwnIdx,
   TDMVUsatCnt,
//   TDMVUsatInTtl,
   TDMVUsatTtlInDS,
   TDMVUsatIdx: integer;
   LSVUstarClssStr,
   LSVUasterFileName: string;
   LSVUtest: TGLBaseSceneObject;
begin
   {.scene and data cleanup in pre-process}
   FC3doglMainViewTotalOrbitalObjects:=0;
   FC3doglMainViewTotalSpaceUnits:=0;
   FC3doglMainViewTotalSatellites:=0;
   if LSVUoobjReset
   then
   begin
      FC3doglSelectedPlanetAsteroid:=0;
      FC3doglSelectedSatellite:=0;
   end;
   if LSVUspUnReset
   then FC3doglSelectedSpaceUnit:=0;
   FCWinMain.FCGLSmainView.Hide;
   FCWinMain.FCGLScadencer.Enabled:=false;
   FC3doglCurrentStarSystem:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,StarSys
      ,0
      ,0
      ,0
      );
   FC3doglCurrentStar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,Star
      ,FC3doglCurrentStarSystem
      ,0
      ,0
      );
   FC3doglAtmospheres:=nil;
   SetLength(FC3doglAtmospheres,1);
   FC3doglMainViewListMainOrbits:=nil;
   SetLength(FC3doglMainViewListMainOrbits,1);
   FC3doglMainViewListGravityWells:=nil;
   SetLength(FC3doglMainViewListGravityWells,1);
   FC3doglSpaceUnits:=nil;
   SetLength(FC3doglSpaceUnits,1);
   FC3doglSatellitesAsteroids:=nil;
   SetLength(FC3doglSatellitesAsteroids,1);
   FC3doglSatellitesAtmospheres:=nil;
   SetLength(FC3doglSatellitesAtmospheres,1);
   FC3doglSatellitesObjectsGroups:=nil;
   SetLength(FC3doglSatellitesObjectsGroups,1);
   FC3doglMainViewListSatellitesGravityWells:=nil;
   SetLength(FC3doglMainViewListSatellitesGravityWells,1);
   FC3doglMainViewListSatelliteOrbits:=nil;
   SetLength(FC3doglMainViewListSatelliteOrbits,1);
   FC3doglSatellites:=nil;
   SetLength(FC3doglSatellites,1);
   FC3doglObjectsGroups:=nil;
   SetLength(FC3doglObjectsGroups,1);
   FC3doglPlanets:=nil;
   SetLength(FC3doglPlanets,1);
   FC3doglAsteroids:=nil;
   SetLength(FC3doglAsteroids,1);
   {.set the update message}
   FCWinMain.WM_MainViewGroup.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.Upd');
   {.set star}
   LSVUstarSize:=FCFcF_Scale_Conversion(
      cKmTo3dViewUnits
      ,(1390000*FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_diameter)
      )*10;
   FCWinMain.FCGLSStarMain.Scale.X:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Scale.Y:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Scale.Z:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Position.X:=0;
   FCWinMain.FCGLSStarMain.Position.Y:=0;
   FCWinMain.FCGLSStarMain.Position.Z:=0;
   {.set starlight}
   FCWinMain.FCGLSSM_Light.Position.X:=0;
   FCWinMain.FCGLSSM_Light.Position.Y:=0;
   FCWinMain.FCGLSSM_Light.Position.Z:=0;
   {.set starlight diffuse color and star texture name}
   case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_class of
      cB5, cB6, cB7, cB8, cB9:
      begin
         LSVUstarClssStr:='cB';//old file index 005
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;
      cA0, cA1, cA2, cA3, cA4:
      begin
         LSVUstarClssStr:='cAless5';//old file index 003
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;
      cA5, cA6, cA7, cA8, cA9:
      begin
         LSVUstarClssStr:='cAsupeg5';//old file index 004
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      cK0, cK1, cK2, cK3, cK4:
      begin
         LSVUstarClssStr:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      cK5, cK6, cK7, cK8:
      begin
         LSVUstarClssStr:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      cK9:
      begin
         LSVUstarClssStr:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      cM0, cM1, cM2, cM3, cM4:
      begin
         LSVUstarClssStr:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      cM5:
      begin
         LSVUstarClssStr:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      gF0, gF1, gF2, gF3, gF4:
      begin
         LSVUstarClssStr:='gFless5';//old file index 018
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;
      gF5, gF6, gF7, gF8, gF9:
      begin
         LSVUstarClssStr:='gFsupeg5';//old file index 019
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;
      gG0, gG1, gG2, gG3, gG4:
      begin
         LSVUstarClssStr:='gGless5';//old file index 022
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;
      gG5, gG6, gG7, gG8:
      begin
         LSVUstarClssStr:='gGeg5-8';//old file index 023
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      gG9:
      begin
         LSVUstarClssStr:='gGeg9';//old file index 024
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      gK0, gK1, gK2, gK3, gK4:
      begin
         LSVUstarClssStr:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      gK5, gK6, gK7, gK8:
      begin
         LSVUstarClssStr:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      gK9:
      begin
         LSVUstarClssStr:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      gM0, gM1, gM2, gM3, gM4:
      begin
         LSVUstarClssStr:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      gM5:
      begin
         LSVUstarClssStr:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      O5, O6, O7, O8, O9:
      begin
         LSVUstarClssStr:='O';//old file index 028
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;
      B0, B1, B2, B3, B4:
      begin
         LSVUstarClssStr:='Bless5';//old file index 006
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;
      B5, B6, B7, B8, B9:
      begin
         LSVUstarClssStr:='Bsupeg5';//old file index 007
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;
      A0, A1, A2, A3, A4:
      begin
         LSVUstarClssStr:='Aless5';//old file index 001
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.966;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;
      A5, A6, A7, A8, A9:
      begin
         LSVUstarClssStr:='Asupeg5';//old file index 002
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      F0, F1, F2, F3, F4:
      begin
         LSVUstarClssStr:='Fless5';//old file index 020
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;
      F5, F6, F7, F8, F9:
      begin
         LSVUstarClssStr:='Fsupeg5';//old file index 021
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;
      G0, G1, G2, G3, G4:
      begin
         LSVUstarClssStr:='Gless5';//old file index 025
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;
      G5, G6, G7, G8:
      begin
         LSVUstarClssStr:='Feg5-8';//old file index 026
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      G9:
      begin
         LSVUstarClssStr:='Feg9';//old file index 027
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      K0, K1, K2, K3, K4:
      begin
         LSVUstarClssStr:='Kless5';//old file index 011
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      K5, K6, K7, K8:
      begin
         LSVUstarClssStr:='Keg5-8';//old file index 012
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      K9:
      begin
         LSVUstarClssStr:='Keg9';//old file index 013
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      M0, M1, M2, M3, M4:
      begin
         LSVUstarClssStr:='Mless5';//old file index 016
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      M5, M6, M7, M8, M9:
      begin
         LSVUstarClssStr:='Msupeg5';//old file index 017
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      WD0..WD9:
      begin
         LSVUstarClssStr:='WDeg0-9';//old file index 029
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      PSR:
      begin
         LSVUstarClssStr:='PSR';//old file index 030
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.584;
      end;
      BH:
      begin
         LSVUstarClssStr:='BH';//no old file (previous iteration of FAR Colony had no tex
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.325;
      end;
   end;
   FCWinMain.FCGLSSM_Light.Specular.Blue:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Green:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Red:=FCWinMain.FCGLSSM_Light.Diffuse.Red;
   {.set star's picture}
   FCWinMain.FCGLSStarMain.Material.Texture.Image.LoadFromFile(FCVdiPathResourceDir+'pics-ogl-stars\star_'+LSVUstarClssStr+'.png');
   {.set orbital objects}
   LSVUorbObjTtlInDS:=Length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects)-1;
   if LSVUorbObjTtlInDS>0
   then
   begin
      with FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar] do
      begin
         TDMVUorbObjCnt:=1;
         TDMVUsatCnt:=0;
         {.orbital objects + satellites creation loop}
         while TDMVUorbObjCnt<=LSVUorbObjTtlInDS do
         begin
            {.set the 3d object arrays, if needed}
            if TDMVUorbObjCnt >= Length(FC3doglObjectsGroups)
            then
            begin
               SetLength(FC3doglObjectsGroups, Length(FC3doglObjectsGroups)+LSVUblocCnt);
               SetLength(FC3doglPlanets, Length(FC3doglPlanets)+LSVUblocCnt);
               SetLength(FC3doglAtmospheres, length(FC3doglAtmospheres)+LSVUblocCnt);
               SetLength(FC3doglAsteroids, Length(FC3doglAsteroids)+LSVUblocCnt);
               SetLength(FC3doglMainViewListGravityWells, Length(FC3doglMainViewListGravityWells)+LSVUblocCnt);
               SetLength(FC3doglMainViewListMainOrbits, Length(FC3doglMainViewListMainOrbits)+LSVUblocCnt);
            end;
            {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_OrbitalObject_CalculatePosition.}
            LSVUangleRad:=S_orbitalObjects[TDMVUorbObjCnt].OO_angle1stDay*FCCdiDegrees_To_Radian;   //ok to fill the call w/ param and remove this
            {.asteroid}
            if (S_orbitalObjects[TDMVUorbObjCnt].OO_type>=ootAsteroid_Metallic)
               and (S_orbitalObjects[TDMVUorbObjCnt].OO_type<=ootAsteroid_Icy)
            then
            begin
               {.initialize 3d structure}
               FCMoglVM_OObj_Gen(o3dotAsteroid, TDMVUorbObjCnt);
               FC3doglAsteroids[TDMVUorbObjCnt].Load3DSFileFrom(FCFoglVMain_Aster_Set(TDMVUorbObjCnt, 0, false));
               {.set material}
               FC3doglAsteroids[TDMVUorbObjCnt].Material.FrontProperties:=FC3oglvmAsteroidTemp.Material.FrontProperties;
               {.set common data}
               FC3doglAsteroids[TDMVUorbObjCnt].TurnAngle:=S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_axialTilt;
               FC3doglAsteroids[TDMVUorbObjCnt].scale.X
                  :=FCFcF_Scale_Conversion(cAsteroidDiameterKmTo3dViewUnits, S_orbitalObjects[TDMVUorbObjCnt].OO_diameter);
               FC3doglAsteroids[TDMVUorbObjCnt].scale.Y:=FC3doglAsteroids[TDMVUorbObjCnt].scale.X;
               FC3doglAsteroids[TDMVUorbObjCnt].scale.Z:=FC3doglAsteroids[TDMVUorbObjCnt].scale.X;
               {.set distance and location}
               {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_OrbitalObject_CalculatePosition.}
               OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_distanceFromStar);//dev:USE /5.5 - WARNING: adjust all dist proportionally ; //ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.X:=cos(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Y:=0;//ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Z:=sin(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
               {.set group scale}
               FC3doglObjectsGroups[TDMVUorbObjCnt].CubeSize:=FC3doglAsteroids[TDMVUorbObjCnt].scale.X*50;
               {.displaying}
               FC3doglObjectsGroups[TDMVUorbObjCnt].Visible:=true;
               FC3doglPlanets[TDMVUorbObjCnt].Visible:=false;
               FC3doglAsteroids[TDMVUorbObjCnt].Visible:=true;
               {.set orbits}
               FCMogO_Orbit_Generation(otPlanet, TDMVUorbObjCnt, 0, 0, OrbitDistanceInUnits);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, 0, 0, true);
            end //==END== if (OO_type>=oobtpAster_Metall) and (OO_type<=oobtpAster_Icy) ==//
            {.planet}
            else if (S_orbitalObjects[TDMVUorbObjCnt].OO_type>=ootPlanet_Telluric)
                    and (S_orbitalObjects[TDMVUorbObjCnt].OO_type<=ootPlanet_Supergiant)
            then
            begin
               {.initialize 3d structure}
               FCMoglVM_OObj_Gen(o3dotPlanet, TDMVUorbObjCnt);
               {.inclination}
               FC3doglPlanets[TDMVUorbObjCnt].RollAngle:=S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_axialTilt;
               {.set scale}
               FC3doglPlanets[TDMVUorbObjCnt].scale.X
                  :=FCFcF_Scale_Conversion(cKmTo3dViewUnits,S_orbitalObjects[TDMVUorbObjCnt].OO_diameter);
               FC3doglPlanets[TDMVUorbObjCnt].scale.Y:=FC3doglPlanets[TDMVUorbObjCnt].scale.X;
               FC3doglPlanets[TDMVUorbObjCnt].scale.Z:=FC3doglPlanets[TDMVUorbObjCnt].scale.X;
               {.set distance and location}
               {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_OrbitalObject_CalculatePosition.}
               OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_distanceFromStar);//dev:USE /5.5 - WARNING: adjust all dist proportionally ; //ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.X:=cos(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Y:=0;//ok to fill the call w/ param and remove this
               FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Z:=sin(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
               {.set group scale}
               FC3doglObjectsGroups[TDMVUorbObjCnt].CubeSize:=FC3doglPlanets[TDMVUorbObjCnt].scale.X*2;
               {.set atmosphere}
               if ( ( (S_orbitalObjects[TDMVUorbObjCnt].OO_type = ootPlanet_Telluric) or (S_orbitalObjects[TDMVUorbObjCnt].OO_type = ootPlanet_Icy) ) and (S_orbitalObjects[TDMVUorbObjCnt].OO_atmosphericPressure>0) )
                  or (S_orbitalObjects[TDMVUorbObjCnt].OO_type in [ootPlanet_Gaseous_Uranus..ootPlanet_Supergiant]) then
               begin
                  FCMoglVMain_Atmosph_SetCol(TDMVUorbObjCnt, 0, 0);
                  FC3doglAtmospheres[TDMVUorbObjCnt].Sun:=FCWinMain.FCGLSSM_Light;
                  if S_orbitalObjects[TDMVUorbObjCnt].OO_type<ootPlanet_Gaseous_Uranus
                  then FC3doglAtmospheres[TDMVUorbObjCnt].Opacity
                     :=FCFoglVMain_CloudsCov_Conv2AtmOp(S_orbitalObjects[TDMVUorbObjCnt].OO_cloudsCover)
                  else FC3doglAtmospheres[TDMVUorbObjCnt].Opacity:=FCFoglVMain_CloudsCov_Conv2AtmOp(-1);
                  FC3doglAtmospheres[TDMVUorbObjCnt].Visible:=true;
               end;
               {.texturing}
               FCMoglVMain_MapTex_Assign(TDMVUorbObjCnt, 0, 0);
               {.satellites}
               TDMVUsatTtlInDS:=Length(S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList)-1;
               if TDMVUsatTtlInDS>0
               then
               begin
                  TDMVUsatIdx:=1;
                  while TDMVUsatIdx<=TDMVUsatTtlInDS do
                  begin
                     inc(TDMVUsatCnt);
                     {.set the 3d object arrays, if needed}
                     if TDMVUsatCnt >= Length(FC3doglSatellitesObjectsGroups) then
                     begin
                        SetLength(FC3doglSatellitesObjectsGroups, Length(FC3doglSatellitesObjectsGroups)+LSVUblocCnt);
                        SetLength(FC3doglSatellites, Length(FC3doglSatellites)+LSVUblocCnt);
                        SetLength(FC3doglSatellitesAtmospheres, length(FC3doglSatellitesAtmospheres)+LSVUblocCnt);
                        SetLength(FC3doglSatellitesAsteroids, Length(FC3doglSatellitesAsteroids)+LSVUblocCnt);
                        SetLength(FC3doglMainViewListSatellitesGravityWells, Length(FC3doglMainViewListSatellitesGravityWells)+LSVUblocCnt);
                        SetLength(FC3doglMainViewListSatelliteOrbits, Length(FC3doglMainViewListSatelliteOrbits)+LSVUblocCnt);
                     end;
                     {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition}
                     LSVUangleRad:=S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_angle1stDay*FCCdiDegrees_To_Radian; //ok to fill the call w/ param and remove this
                     {.for a satellite asteroid}
                     if S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_type<ootSatellite_Planet_Telluric
                     then
                     begin
                        {.initialize 3d structure}
                        FCMoglVM_OObj_Gen(o3dotSatelliteAsteroid, TDMVUsatCnt);
                        {.initialize 3d structure}
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].Load3DSFileFrom
                           (FCFoglVMain_Aster_Set(TDMVUorbObjCnt, TDMVUsatIdx, true));
                        {.set material}
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].Material.FrontProperties:=FC3oglvmAsteroidTemp.Material.FrontProperties;
                        {.set axial tilt}
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].TurnAngle:=S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_axialTilt;
                        {.set scale}
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.X
                           :=FCFcF_Scale_Conversion
                              (
                                 cAsteroidDiameterKmTo3dViewUnits
                                 , S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx]
                                    .OO_diameter
                              );
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.Y:=FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.X;
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.Z:=FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.X;
                        {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition.}
                        {.set distance and location}
                        LSVUsatDistUnit:=FCFcF_Scale_Conversion   //ok to fill the call w/ param and remove this
                           (                                                        //ok to fill the call w/ param and remove this
                              cKmTo3dViewUnits                                              //ok to fill the call w/ param and remove this
                              ,S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx]   //ok to fill the call w/ param and remove this
                                 .OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000                             //ok to fill the call w/ param and remove this
                           );                                                               //ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.X              //ok to fill the call w/ param and remove this
                           :=FC3doglObjectsGroups[TDMVUorbObjCnt].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);//ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.Y:=0;//ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.Z//ok to fill the call w/ param and remove this
                           :=FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);//ok to fill the call w/ param and remove this
                        {.set group scale}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].CubeSize:=FC3doglSatellitesAsteroids[TDMVUsatCnt].scale.X*50;
                        {.displaying}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Visible:=true;
                        FC3doglSatellites[TDMVUsatCnt].Visible:=false;
                        FC3doglSatellitesAsteroids[TDMVUsatCnt].Visible:=true;
                     end //==END== if ...OOS_type<oobtpSat_Tellu_Lunar ==//
                     {.for a satellite planetoid}
                     else if S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_type>ootSatellite_Asteroid_Icy then
                     begin
                        {.initialize 3d structure}
                        FCMoglVM_OObj_Gen(o3dotSatellitePlanet, TDMVUsatCnt);
                        {.axial tilt}
                        FC3doglSatellites[TDMVUsatCnt].RollAngle
                           :=S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_axialTilt;
                        {.set scale}
                        FC3doglSatellites[TDMVUsatCnt].scale.X
                           :=FCFcF_Scale_Conversion
                              (
                                 cKmTo3dViewUnits
                                 ,S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_diameter
                              );
                        FC3doglSatellites[TDMVUsatCnt].scale.Y:=FC3doglSatellites[TDMVUsatCnt].scale.X;
                        FC3doglSatellites[TDMVUsatCnt].scale.Z:=FC3doglSatellites[TDMVUsatCnt].scale.X;
                        {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition.}
                        {.set distance and location}
                        LSVUsatDistUnit:=FCFcF_Scale_Conversion     //ok to fill the call w/ param and remove this
                           (                            //ok to fill the call w/ param and remove this
                              cKmTo3dViewUnits       //ok to fill the call w/ param and remove this
                              ,S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx] //ok to fill the call w/ param and remove this
                                 .OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000       //ok to fill the call w/ param and remove this
                           );     //ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.X     //ok to fill the call w/ param and remove this
                           :=FC3doglObjectsGroups[TDMVUorbObjCnt].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);  //ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.Y:=0; //ok to fill the call w/ param and remove this
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Position.Z    //ok to fill the call w/ param and remove this
                           :=FC3doglObjectsGroups[TDMVUorbObjCnt].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);  //ok to fill the call w/ param and remove this
                        {.set group scale}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].CubeSize:=FC3doglSatellites[TDMVUsatCnt].scale.X*2;
                        {.set atmosphere}
                        if S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_atmosphericPressure > 0 then
                        begin
                           FCMoglVMain_Atmosph_SetCol(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt);
                           FC3doglSatellitesAtmospheres[TDMVUsatCnt].Sun:=FCWinMain.FCGLSSM_Light;
                           FC3doglSatellitesAtmospheres[TDMVUsatCnt].Opacity
                              :=FCFoglVMain_CloudsCov_Conv2AtmOp(S_orbitalObjects[TDMVUorbObjCnt].OO_satellitesList[TDMVUsatIdx].OO_cloudsCover);
                           FC3doglSatellitesAtmospheres[TDMVUsatCnt].Visible:=true;
                        end;
                        {.texturing}
                        FCMoglVMain_MapTex_Assign(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt);
                        {.displaying}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Visible:=true;
                        FC3doglSatellites[TDMVUsatCnt].Visible:=true;
                     end; //==END== if OOS_type>oobtpSat_Aster_Icy ==//
                     {.set orbits}
                     FCMogO_Orbit_Generation(
                        otSatellite
                        ,TDMVUorbObjCnt
                        ,TDMVUsatIdx
                        ,TDMVUsatCnt
                        ,LSVUsatDistUnit
                        );
                     {.space units in orbit of current object}
                     FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt,true);
                     {.set tag values}
                           {satellite index #}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].Tag:=TDMVUsatIdx;
                           {central orbital object linked}
                        FC3doglSatellitesObjectsGroups[TDMVUsatCnt].TagFloat:=TDMVUorbObjCnt;
                     {.put index of the first sat object}
                     if TDMVUsatIdx=1
                     then S_orbitalObjects[TDMVUorbObjCnt].OO_isNotSat_1st3dObjectSatelliteIndex:=TDMVUsatCnt;
                     inc(TDMVUsatIdx);
                  end; //==END== while TDMVUsatIdx<=TDMVUsatTtlInDS ==//
                  FC3doglMainViewTotalSatellites:=TDMVUsatCnt;
               end;//==END== if Length(SDB_obobj[LSVUorbObjCnt].OO_satList>1) ==//
               {.displaying}
               FC3doglObjectsGroups[TDMVUorbObjCnt].Visible:=true;
               FC3doglPlanets[TDMVUorbObjCnt].Visible:=true;
               {.set orbits}
               FCMogO_Orbit_Generation(otPlanet, TDMVUorbObjCnt, 0, 0, OrbitDistanceInUnits);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, 0, 0, true);
            end; //==END== else if (SDB_obobj[LSVUorbObjCnt].OO_type>=oobtpPlan_Tellu...//
            inc(TDMVUorbObjCnt);
         end; //==END== while LSVUorbObjCnt<=LSVUorbObjInTtl ==//
      end; //==END== with FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB] ==//
      FC3doglMainViewTotalOrbitalObjects:=TDMVUorbObjCnt-1;
   end; //==END==if Length(FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB].SDB_obobj)>1==//
   SetLength(FC3doglObjectsGroups, TDMVUorbObjCnt+1);
   SetLength(FC3doglPlanets, TDMVUorbObjCnt+1);
   SetLength(FC3doglAtmospheres, TDMVUorbObjCnt+1);
   SetLength(FC3doglAsteroids, TDMVUorbObjCnt+1);
   SetLength(FC3doglMainViewListMainOrbits, TDMVUorbObjCnt+1);
   SetLength(FC3doglMainViewListGravityWells, TDMVUorbObjCnt+1);
   {.space units display in free space}
   MVUentCnt:=0;
   while MVUentCnt<=FCCdiFactionsMax do
   begin
      LSVUspUnFacTtl:=Length(FCDdgEntities[MVUentCnt].E_spaceUnits)-1;
      if LSVUspUnFacTtl>0
      then
      begin
         LSVUspUnCnt:=1;
         while LSVUspUnCnt<=LSVUspUnFacTtl do
         begin
            if (FCDdgEntities[MVUentCnt].E_spaceUnits[LSVUspUnCnt].SU_status=susInFreeSpace)
               and (FCDdgEntities[MVUentCnt].E_spaceUnits[LSVUspUnCnt].SU_locationStar=Star)
            then FCMoglVM_SpUn_Gen(
               scfInSpace
               ,MVUentCnt
               ,LSVUspUnCnt
               )
            else if (FCDdgEntities[MVUentCnt].E_spaceUnits[LSVUspUnCnt].SU_status=susDocked)
               and (FCDdgEntities[MVUentCnt].E_spaceUnits[LSVUspUnCnt].SU_locationStar=Star)
            then FCMoglVM_SpUn_Gen(
               scfDocked
               ,MVUentCnt
               ,LSVUspUnCnt
               );
            inc(LSVUspUnCnt);
         end;
      end;
      inc(MVUentCnt);
   end;
   {.free the AsterDmp}
   if FC3oglvmAsteroidTemp<>nil
   then FC3oglvmAsteroidTemp.Free;
   {.space unit selection}
   if FC3doglMainViewTotalSpaceUnits>0
   then FC3doglSelectedSpaceUnit:=1;
   {.relocate correctly non-dynamic objects}
   {.HUDgameTime and all hud children}
   FCWinMain.FCGLSRootMain.Objects.MoveChildLast(1);
   {.camera for main view}
   FCWinMain.FCGLSRootMain.Objects.MoveChildLast(2);
   {.camera controller for main view}
   FCWinMain.FCGLSRootMain.Objects.Children[3].MoveLast;
   {.3d view post setup}
   FCWinMain.FCGLScadencer.Enabled:=true;
   FCWinMain.FCGLSmainView.Show;
   FCMuiW_UI_Initialize(mwupTextWM3dFrame);
   FCMovM_CameraMain_Target(FC3doglSelectedPlanetAsteroid, true);
end;

procedure FCMoglVM_OObj_Gen(
   const OOGobjClass: TFCEovmOrbital3dObjectTypes;
   const OOGobjIdx: integer
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
   if (OOGobjClass=o3dotPlanet)
      or (OOGobjClass=o3dotAsteroid)
   then
   begin
      {.the object group}
      FC3doglObjectsGroups[OOGobjIdx]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3doglObjectsGroups[OOGobjIdx].Name:='FCGLSObObjGroup'+IntToStr(OOGobjIdx);
      FC3doglObjectsGroups[OOGobjIdx].CubeSize:=1;
      FC3doglObjectsGroups[OOGobjIdx].Up.X:=0;
      FC3doglObjectsGroups[OOGobjIdx].Up.Y:=1;
      FC3doglObjectsGroups[OOGobjIdx].Up.Z:=0;
      FC3doglObjectsGroups[OOGobjIdx].VisibleAtRunTime:=false;
      FC3doglObjectsGroups[OOGobjIdx].Visible:=false;
      FC3doglObjectsGroups[OOGobjIdx].ShowAxes:=false;
      {.the planet}
      FC3doglPlanets[OOGobjIdx]:=TGLSphere(FC3doglObjectsGroups[OOGobjIdx].AddNewChild(TGLSphere));
      FC3doglPlanets[OOGobjIdx].Name:='FCGLSObObjPlnt'+IntToStr(OOGobjIdx);
      FC3doglPlanets[OOGobjIdx].Radius:=1;
      FC3doglPlanets[OOGobjIdx].Slices:=64;
      FC3doglPlanets[OOGobjIdx].Stacks:=64;
      FC3doglPlanets[OOGobjIdx].Visible:=false;
      FC3doglPlanets[OOGobjIdx].ShowAxes:=false;
      if OOGobjClass=o3dotPlanet
      then
      begin
         FC3doglPlanets[OOGobjIdx].Material.BackProperties.Ambient.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3doglPlanets[OOGobjIdx].Material.BackProperties.Diffuse.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3doglPlanets[OOGobjIdx].Material.BackProperties.Emission.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglPlanets[OOGobjIdx].Material.BackProperties.Shininess
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
         FC3doglPlanets[OOGobjIdx].Material.BackProperties.Specular.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3doglPlanets[OOGobjIdx].Material.BlendingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
         FC3doglPlanets[OOGobjIdx].Material.FaceCulling:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
         FC3doglPlanets[OOGobjIdx].Material.FrontProperties.Ambient:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3doglPlanets[OOGobjIdx].Material.FrontProperties.Diffuse:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3doglPlanets[OOGobjIdx].Material.FrontProperties.Emission
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglPlanets[OOGobjIdx].Material.FrontProperties.Shininess
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3doglPlanets[OOGobjIdx].Material.FrontProperties.Specular
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
         FC3doglPlanets[OOGobjIdx].Material.MaterialOptions:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.BorderColor.Color
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3doglPlanets[OOGobjIdx].Material.Texture.Compression:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.DepthTextureMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3doglPlanets[OOGobjIdx].Material.Texture.Disabled:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
         FC3doglPlanets[OOGobjIdx].Material.Texture.EnvColor.Color:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3doglPlanets[OOGobjIdx].Material.Texture.FilteringQuality
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3doglPlanets[OOGobjIdx].Material.Texture.ImageAlpha:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3doglPlanets[OOGobjIdx].Material.Texture.ImageGamma:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
         FC3doglPlanets[OOGobjIdx].Material.Texture.MagFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
         FC3doglPlanets[OOGobjIdx].Material.Texture.MappingMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
         FC3doglPlanets[OOGobjIdx].Material.Texture.MinFilter:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
         FC3doglPlanets[OOGobjIdx].Material.Texture.NormalMapScale:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareFunc
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3doglPlanets[OOGobjIdx].Material.Texture.TextureFormat:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
         FC3doglPlanets[OOGobjIdx].Material.Texture.TextureMode:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
         FC3doglPlanets[OOGobjIdx].Material.Texture.TextureWrap:=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapS:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapT:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
//         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapR:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootNorm ==//
      else if OOGobjClass=o3dotAsteroid
      then
      begin
         {.the asteroid}
         FC3doglAsteroids[OOGobjIdx]:=TDGLib3dsStaMesh(FC3doglObjectsGroups[OOGobjIdx].AddNewChild(TDGLib3dsStaMesh));
         FC3doglAsteroids[OOGobjIdx].Name:='FCGLSObObjAster'+IntToStr(OOGobjIdx);
         FC3doglAsteroids[OOGobjIdx].UseGLSceneBuildList:=False;
         FC3doglAsteroids[OOGobjIdx].PitchAngle:=90;
         FC3doglAsteroids[OOGobjIdx].UseShininessPowerHack:=0;
         FC3doglAsteroids[OOGobjIdx].UseInvertWidingHack:=False;
         FC3doglAsteroids[OOGobjIdx].UseNormalsHack:=True;
         FC3doglAsteroids[OOGobjIdx].Scale.SetVector(0.27,0.27,0.27);
      end;
      {.the atmosphere}
      FC3doglAtmospheres[OOGobjIdx]:=TGLAtmosphere(FC3doglObjectsGroups[OOGobjIdx].AddNewChild(TGLAtmosphere));
      FC3doglAtmospheres[OOGobjIdx].Name:='FCGLSObObjAtmos'+IntToStr(OOGobjIdx);
      FC3doglAtmospheres[OOGobjIdx].AtmosphereRadius:=3.55;//3.75;//3.55;
      FC3doglAtmospheres[OOGobjIdx].BlendingMode:=abmOneMinusSrcAlpha;
      FC3doglAtmospheres[OOGobjIdx].HighAtmColor.Color:=clrBlue;
      FC3doglAtmospheres[OOGobjIdx].LowAtmColor.Color:=clrWhite;
      FC3doglAtmospheres[OOGobjIdx].Opacity:=2.1;
      FC3doglAtmospheres[OOGobjIdx].PlanetRadius:=3.395;
      FC3doglAtmospheres[OOGobjIdx].Slices:=64;
      FC3doglAtmospheres[OOGobjIdx].Visible:=false;
   end
   {.satellites}
   else if (OOGobjClass=o3dotSatellitePlanet)
      or (OOGobjClass=o3dotSatelliteAsteroid)
   then
   begin
      {.the object group}
      FC3doglSatellitesObjectsGroups[OOGobjIdx]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3doglSatellitesObjectsGroups[OOGobjIdx].Name:='FCGLSsatGrp'+IntToStr(OOGobjIdx);
      FC3doglSatellitesObjectsGroups[OOGobjIdx].CubeSize:=1;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].Up.X:=0;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].Up.Y:=1;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].Up.Z:=0;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].VisibleAtRunTime:=false;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].Visible:=false;
      FC3doglSatellitesObjectsGroups[OOGobjIdx].ShowAxes:=false;
      {.the planet}
      FC3doglSatellites[OOGobjIdx]:=TGLSphere(FC3doglSatellitesObjectsGroups[OOGobjIdx].AddNewChild(TGLSphere));
      FC3doglSatellites[OOGobjIdx].Name:='FCGLSsatPlnt'+IntToStr(OOGobjIdx);
      FC3doglSatellites[OOGobjIdx].Radius:=1;
      FC3doglSatellites[OOGobjIdx].Slices:=64;
      FC3doglSatellites[OOGobjIdx].Stacks:=64;
      FC3doglSatellites[OOGobjIdx].Visible:=false;
      FC3doglSatellites[OOGobjIdx].ShowAxes:=false;
      if OOGobjClass=o3dotSatellitePlanet
      then
      begin
         FC3doglSatellites[OOGobjIdx].Material.BackProperties.Ambient.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3doglSatellites[OOGobjIdx].Material.BackProperties.Diffuse.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3doglSatellites[OOGobjIdx].Material.BackProperties.Emission.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Emission.Color;
//         FC3DobjSat[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglSatellites[OOGobjIdx].Material.BackProperties.Shininess
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Shininess;
         FC3doglSatellites[OOGobjIdx].Material.BackProperties.Specular.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3doglSatellites[OOGobjIdx].Material.BlendingMode
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.BlendingMode;
         FC3doglSatellites[OOGobjIdx].Material.FaceCulling
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FaceCulling;
         FC3doglSatellites[OOGobjIdx].Material.FrontProperties.Ambient
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3doglSatellites[OOGobjIdx].Material.FrontProperties.Diffuse
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3doglSatellites[OOGobjIdx].Material.FrontProperties.Emission
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Emission;
//         FC3DobjSat[OOGobjIdx].Material.PolygonMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3doglSatellites[OOGobjIdx].Material.FrontProperties.Shininess
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3doglSatellites[OOGobjIdx].Material.FrontProperties.Specular
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.FrontProperties.Specular;
         FC3doglSatellites[OOGobjIdx].Material.MaterialOptions
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.MaterialOptions;
//         FC3DobjSat[OOGobjIdx].Material.Texture.BorderColor.Color
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3doglSatellites[OOGobjIdx].Material.Texture.Compression
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Compression;
//         FC3DobjSat[OOGobjIdx].Material.Texture.DepthTextureMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3doglSatellites[OOGobjIdx].Material.Texture.Disabled
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.Disabled;
         FC3doglSatellites[OOGobjIdx].Material.Texture.EnvColor.Color
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3doglSatellites[OOGobjIdx].Material.Texture.FilteringQuality
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3doglSatellites[OOGobjIdx].Material.Texture.ImageAlpha
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3doglSatellites[OOGobjIdx].Material.Texture.ImageGamma
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.ImageGamma;
         FC3doglSatellites[OOGobjIdx].Material.Texture.MagFilter
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MagFilter;
         FC3doglSatellites[OOGobjIdx].Material.Texture.MappingMode
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MappingMode;
         FC3doglSatellites[OOGobjIdx].Material.Texture.MinFilter
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.MinFilter;
         FC3doglSatellites[OOGobjIdx].Material.Texture.NormalMapScale
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.NormalMapScale;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareFunc
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareMode
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3doglSatellites[OOGobjIdx].Material.Texture.TextureFormat
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureFormat;
         FC3doglSatellites[OOGobjIdx].Material.Texture.TextureMode
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureMode;
         FC3doglSatellites[OOGobjIdx].Material.Texture.TextureWrap
            :=FC3doglMaterialLibraryStandardPlanetTextures.Materials.Items[0].Material.Texture.TextureWrap;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapS
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapT
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
//         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapR
//            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootSatNorm ==//
      else if OOGobjClass=o3dotSatelliteAsteroid then
      begin
         {.the asteroid}
         FC3doglSatellitesAsteroids[OOGobjIdx]:=TDGLib3dsStaMesh(FC3doglSatellitesObjectsGroups[OOGobjIdx].AddNewChild(TDGLib3dsStaMesh));
         FC3doglSatellitesAsteroids[OOGobjIdx].Name:='FCGLSsatAster'+IntToStr(OOGobjIdx);
         FC3doglSatellitesAsteroids[OOGobjIdx].UseGLSceneBuildList:=False;
         FC3doglSatellitesAsteroids[OOGobjIdx].PitchAngle:=90;
         FC3doglSatellitesAsteroids[OOGobjIdx].UseShininessPowerHack:=0;
         FC3doglSatellitesAsteroids[OOGobjIdx].UseInvertWidingHack:=False;
         FC3doglSatellitesAsteroids[OOGobjIdx].UseNormalsHack:=True;
         FC3doglSatellitesAsteroids[OOGobjIdx].Scale.SetVector(0.27,0.27,0.27);
      end;
      {.the atmosphere}
      FC3doglSatellitesAtmospheres[OOGobjIdx]:=TGLAtmosphere(FC3doglSatellitesObjectsGroups[OOGobjIdx].AddNewChild(TGLAtmosphere));
      FC3doglSatellitesAtmospheres[OOGobjIdx].Name:='FCGLSsatAtmos'+IntToStr(OOGobjIdx);
      FC3doglSatellitesAtmospheres[OOGobjIdx].AtmosphereRadius:=3.55;//3.75;//3.55;
      FC3doglSatellitesAtmospheres[OOGobjIdx].BlendingMode:=abmOneMinusSrcAlpha;
      FC3doglSatellitesAtmospheres[OOGobjIdx].HighAtmColor.Color:=clrBlue;
      FC3doglSatellitesAtmospheres[OOGobjIdx].LowAtmColor.Color:=clrWhite;
      FC3doglSatellitesAtmospheres[OOGobjIdx].Opacity:=2.1;
      FC3doglSatellitesAtmospheres[OOGobjIdx].PlanetRadius:=3.395;
      FC3doglSatellitesAtmospheres[OOGobjIdx].Slices:=64;
      FC3doglSatellitesAtmospheres[OOGobjIdx].Visible:=false;
   end; //==END== else if (OOGobjClass=oglvmootSatNorm) or (=oglvmootSatAster) ==//
end;

procedure FCMoglVM_OObjSpUn_ChgeScale(const OOSUCSobjIdx: integer);
{:Purpose: change space unit scale according to it's distance, it's a fast&dirty fix.
    Additions:
      -2009Dec10- *bugfix: don't make a cumulative size change anymore.
}
var
   OOSUCSdmpSize: extended;
begin
   if FC3doglSpaceUnits[OOSUCSobjIdx].Hint=''
   then
   begin
      FC3doglSpaceUnits[OOSUCSobjIdx].Hint:=floattostr(FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X);
      OOSUCSdmpSize:=FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X;
   end
   else OOSUCSdmpSize:=StrToFloat(FC3doglSpaceUnits[OOSUCSobjIdx].Hint);
   FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X
      :=OOSUCSdmpSize*FC3doglSpaceUnits[OOSUCSobjIdx].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*64;//8;
   FC3doglSpaceUnits[OOSUCSobjIdx].Scale.Y:=FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X;
   FC3doglSpaceUnits[OOSUCSobjIdx].Scale.Z:=FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X;
end;

procedure FCMoglVM_OObjSpUn_inOrbit(
   const OOSUIOUoobjIdx,
         OOSUIOUsatIdx,
         OOSUIOUsatObjIdx: integer;
   const OOSUIOUmustGen: boolean
   );
{:Purpose: display space units in orbit of a selected orbital object.
    Additions:
      -2010Sep19- *fix: space units in orbits are linked to OO_inOrbitCnt/OOS_inOrbitCnt and not the length-1 which is always equal to 45.
      -2010Sep15- *mod: some refactoring.
                  *add: entities code.
      -2009Dec20- *add: display space units in orbit of satellites too.
      -2009Dec01- *optimization: relative to changes in space unit gen procedure.
}
var
   OOSUIOfac,
   OOSUIOspUinOrb,
   OOSUIOspUnCnt,
   OOSUIOspUntOwnIdx,
   OOSUIOspUnObjIdx: integer;
begin
   with FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar] do
   begin
      if OOSUIOUsatIdx=0
      then
      begin
         OOSUIOspUinOrb:=S_orbitalObjects[OOSUIOUoobjIdx].OO_inOrbitCurrentNumber;
         if OOSUIOspUinOrb>0
         then
         begin
            OOSUIOspUnCnt:=1;
            while OOSUIOspUnCnt<=OOSUIOspUinOrb do
            begin
               OOSUIOfac:=S_orbitalObjects[OOSUIOUoobjIdx].OO_inOrbitSpaceUnitsList[OOSUIOspUnCnt].SUIO_faction;
               OOSUIOspUntOwnIdx:=S_orbitalObjects[OOSUIOUoobjIdx].OO_inOrbitSpaceUnitsList[OOSUIOspUnCnt].SUIO_ownedSpaceUnitIndex;
               if OOSUIOUmustGen
               then
               begin
                  FCMoglVM_SpUn_Gen(
                     scfInOrbit
                     ,OOSUIOfac
                     ,OOSUIOspUntOwnIdx
                     );
                  OOSUIOspUnObjIdx:=FC3doglMainViewTotalSpaceUnits;
               end
               else if not OOSUIOUmustGen
               then OOSUIOspUnObjIdx:=FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_linked3dObject;
               if FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.X>0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X
                  :=FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.X-(0.9*cos(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListGravityWells[OOSUIOUoobjIdx].Scale.X)
               else if FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.X<0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X
                  :=FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.X+(0.9*cos(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListGravityWells[OOSUIOUoobjIdx].Scale.X);
               if FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.Z>0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z
                  :=FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.Z-(0.9*sin(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListGravityWells[OOSUIOUoobjIdx].Scale.X)
               else if FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.Z<0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z
                  :=FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.Z+(0.9*sin(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListGravityWells[OOSUIOUoobjIdx].Scale.X);
               FC3doglSpaceUnits[OOSUIOspUnObjIdx].PointTo(
                  FC3doglObjectsGroups[OOSUIOUoobjIdx]
                  ,FC3doglObjectsGroups[OOSUIOUoobjIdx].Position.AsVector
                  );
               FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_locationViewX:=FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X;
               FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_locationViewZ:=FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z;
               inc(OOSUIOspUnCnt);
            end; //==END== while OOSUIOUspUnCnt<=OOSUIOUspUinOrb ==//
         end; //==END== if OOSUIOUspUinOrb>0 ==//
      end //==END== if OOSUIOUsatIdx=0 ==//
      else if OOSUIOUsatIdx>0
      then
      begin
         OOSUIOspUinOrb:=S_orbitalObjects[OOSUIOUoobjIdx].OO_satellitesList[OOSUIOUsatIdx].OO_inOrbitCurrentNumber;
         if OOSUIOspUinOrb>0
         then
         begin
            OOSUIOspUnCnt:=1;
            while OOSUIOspUnCnt<=OOSUIOspUinOrb do
            begin
               OOSUIOfac:=S_orbitalObjects[OOSUIOUoobjIdx].OO_satellitesList[OOSUIOUsatIdx].OO_inOrbitSpaceUnitsList[OOSUIOspUnCnt].SUIO_faction;
               OOSUIOspUntOwnIdx:=S_orbitalObjects[OOSUIOUoobjIdx].OO_satellitesList[OOSUIOUsatIdx].OO_inOrbitSpaceUnitsList[OOSUIOspUnCnt].SUIO_ownedSpaceUnitIndex;
               if OOSUIOUmustGen
               then
               begin
                  FCMoglVM_SpUn_Gen(
                     scfInOrbit
                     ,OOSUIOfac
                     ,OOSUIOspUntOwnIdx
                     );
                  OOSUIOspUnObjIdx:=FC3doglMainViewTotalSpaceUnits;
               end
               else if not OOSUIOUmustGen
               then OOSUIOspUnObjIdx:=FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_linked3dObject;
               if FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.X>0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X
                  :=FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.X-(0.9*cos(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListSatellitesGravityWells[OOSUIOUsatObjIdx].Scale.X)
               else if FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.X<0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X
                  :=FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.X+(0.9*cos(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListSatellitesGravityWells[OOSUIOUsatObjIdx].Scale.X);
               if FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.Z>0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z
                  :=FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.Z-(0.9*sin(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListSatellitesGravityWells[OOSUIOUsatObjIdx].Scale.X)
               else if FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.Z<0
               then FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z
                  :=FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.Z+(0.9*sin(8*OOSUIOspUnCnt*FCCdiDegrees_To_Radian)*FC3doglMainViewListSatellitesGravityWells[OOSUIOUsatObjIdx].Scale.X);
               FC3doglSpaceUnits[OOSUIOspUnObjIdx].PointTo(
                  FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx]
                  ,FC3doglSatellitesObjectsGroups[OOSUIOUsatObjIdx].Position.AsVector
                  );
               FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_locationViewX:=FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.X;
               FCDdgEntities[OOSUIOfac].E_spaceUnits[OOSUIOspUntOwnIdx].SU_locationViewZ:=FC3doglSpaceUnits[OOSUIOspUnObjIdx].Position.Z;
               inc(OOSUIOspUnCnt);
            end; //==END== while OOSUIOUspUnCnt<=OOSUIOUspUnFacTtl ==//
         end; //==END== if OOSUIOUspUnFacTtl>0 ==//
      end; //==END== else if OOSUIOUsatIdx>0 ==//
   end; //==END== with FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB] ==//
end;

procedure FCMoglVM_SpUn_Gen(
   const SUGstatus: TFCEovmSpaceUnitOrigin;
   const SUGfac
         ,SUGspUnOwnIdx: integer
   );
{:Purpose: generate a space unit.
    Additions:
      -2012Dec11- *mod: the size of space units has been adjusted.
      -2010Sep14- *add: SUGfac parameter, faction index #.
                  *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2010Apr25- *add: generate docked space units.
      -2009Dec01- *bugfix: crash with space unit not in orbit (in free space for example).
      -2009Nov15- *change switch behavior w/oglvmscfPlayerInOrbit and oglvmscfPlayer.
      -2009Sep19- *add SUGspUnFacIdx, faction owned space unit index.
                  *add location (when not in orbit).
}
var
   SUGdesgn: integer;

begin
   if (SUGstatus=scfDocked)
      or (SUGstatus=scfInOrbit)
      or (SUGstatus=scfInSpace)
   then
   begin
      inc(FC3doglMainViewTotalSpaceUnits);
      SetLength(FC3doglSpaceUnits, FC3doglMainViewTotalSpaceUnits+1);
      SUGdesgn:=FCFspuF_Design_getDB(FCDdgEntities[SUGfac].E_spaceUnits[SUGspUnOwnIdx].SU_designToken);
      {.create the object and set some basic data}
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits]:=TDGLib3dsStaMesh(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TDGLib3dsStaMesh));
//      TGLFile3DSFreeForm(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLFile3DSFreeForm));



      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Load3DSFileFrom(FCVdiPathResourceDir+'obj-3ds-scraft\'+FCDdsuSpaceUnitDesigns[SUGdesgn].SUD_internalStructureClone.IS_token+'.3ds');//Load3DSFileFrom(FCVpathRsrc+'obj-3ds-scraft\'+FCDBscDesigns[SUGdesgn].SCD_intStrClone.SCIS_token+'.3ds');
//      FC3DobjSpUnit[FCV3DttlSpU].UseMeshMaterials:=true;
      {.set the space unit 3d scales}
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Scale.X:=FCFcF_Scale_Conversion(cMetersToSpaceUnitSize, SUGdesgn)*3.5;
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Scale.Y:=FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Scale.X;
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Scale.Z:=FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Scale.X;
      {.in case of the space unit is in free space}
      if SUGstatus=scfInSpace
      then
      begin
         FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Position.X:=FCDdgEntities[SUGfac].E_spaceUnits[SUGspUnOwnIdx].SU_locationViewX;
         FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Position.Z:=FCDdgEntities[SUGfac].E_spaceUnits[SUGspUnOwnIdx].SU_locationViewZ;
      end;
      {.add faction id#}
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Tag:=SUGfac;
      {.add owned space unit index}
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].TagFloat:=SUGspUnOwnIdx;
      FCDdgEntities[SUGfac].E_spaceUnits[SUGspUnOwnIdx].SU_linked3dObject:=FC3doglMainViewTotalSpaceUnits;
      {.finalization}
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].UseMeshMaterials:=true;
      FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Material.Texture.Disabled:=false;
      if (SUGstatus<>scfDocked)
      then FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Visible:=true
      else FC3doglSpaceUnits[FC3doglMainViewTotalSpaceUnits].Visible:=false;
   end;
end;

procedure FCMoglVMain_SpUnits_SetInitSize(const SUSIZresetSize: boolean);
{:Purpose: restore the initial size of the targeted space unit.
    Additions:
}
begin
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X:=FC3doglSpaceUnitSize;
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
   if SUSIZresetSize
   then FC3doglSpaceUnitSize:=0;
end;

procedure FCMoglVM_SpUn_SetZoomScale;
{:Purpose: resize the targeted space unit correctly, depending on distance.
    Additions:
}
begin
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X
      :=FC3doglSpaceUnitSize
      *
         (1+
            (
               (1/(fcwinmain.FCGLSCamMainViewGhost.DistanceToTarget/fcwinmain.FCGLSCamMainViewGhost.TargetObject.Scale.X))
               *150//150
            )
         )
         ;
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
end;

end.
