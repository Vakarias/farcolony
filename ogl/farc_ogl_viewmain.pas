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
function FCFovM_Focused3dObject_GetType(): TFCEovmFocusedObjects;

//===========================END FUNCTIONS SECTION==========================================


///<summary>
///target a specified object in 3d view and initialize user's interface if needed
///</summary>
///   <param name="CMTidxOfObj">selected object index -10: space unit -1: central star >=0: orbital object 100: sat</param>
procedure FCMovM_CameraMain_Target(
   const CMTidxOfObj: TFCEovmFocusedObjects;
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
   ,farc_ogl_functions
   ,farc_ogl_genorbitalobjects
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

//var

{:DEV NOTES: OGL CLEAR SCENE - FCMoglVM_Scene_Cleanup;

   - freeze realtime + ogl timers
   - unload all ui + store their state

   - put at zero S_orbitalObjects[.].OO_isNotSat_1st3dObjectSatelliteIndex




.}

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

//===========================END FUNCTIONS SECTION==========================================

procedure FCMovM_CameraMain_Target(
   const CMTidxOfObj: TFCEovmFocusedObjects;
   const CMTisUpdPMenu: boolean
   );
{:Purpose: target a specified object in 3d view and initialize user's interface if needed.
    Additions:
      -2013Sep14- *mod: the parameter for the object type is now a more readable and understandable value.
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

   test:extended;
begin
   case CMTidxOfObj of
      foStar:
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
      end;

      foOrbitalObject:
      begin
         if FC3doglSpaceUnitSize<>0
         then FCMoglVMain_SpUnits_SetInitSize(true);
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid];
         {.X location}
         if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X>0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X)-(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize*2.3)
         else if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X<0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X)+(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize*2.3);
         {.Y location}
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
         {.Z location}
         if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z>0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z)-(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize*2.3)
         else if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z<0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z)+(FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize*2.3);
         {.camera near plane bias}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid];
         {.update focused object data}
         FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
         {.update the corresponding popup menu}
         if CMTisUpdPMenu
         then FCMuiAP_Update_OrbitalObject;
         {.store the player's location}
         FCVdgPlayer.P_viewOrbitalObject:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId;
      end;

      foSatellite:
      begin
         if FC3doglSpaceUnitSize<>0
         then FCMoglVMain_SpUnits_SetInitSize(true);
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite];
         {.X location}
         if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X>0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X)-(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3)
         else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X<0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X)+(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3);
         {.Y location}
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
         {.Z location}
         if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z>0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z)-(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3)
         else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z<0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z)+(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize*2.3);
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
         FCVdgPlayer.P_viewSatellite:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[CMTdmpSatPlanIdx].OO_satellitesList[CMTdmpSatIdx].OO_dbTokenId;
      end;

      foSpaceUnit:
      begin
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];
         FC3doglSpaceUnitSize:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
         FCMoglVM_OObjSpUn_ChgeScale(FC3doglSelectedSpaceUnit);
         CMTdmpCoef:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*20;
         FCWinMain.FCGLSCamMainViewGhost.Position.X:=-(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.X+FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X+(0.05*CMTdmpCoef));
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y+(0.04*CMTdmpCoef);
         FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.Z+FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z+(0.05*CMTdmpCoef));
         {.configuration}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=0.01+(sqrt(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU)/100);//30);
         FCMoglVM_SpUn_SetZoomScale;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];

         test:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo(FCWinMain.FCGLSStarMain)/1711;
//         if test <=0.49
//         then test:= (0.49 - test ) * 10
//         else test:=(1-(test / 2 ));
         if test < 0.48
         then test:=test*((1/test)*1.17)
         else test:=power(test,0.111)+0.076128;
         FCWinMain.Caption:=floattostr(test);

         FCWinMain.FCGLSCamMainViewGhost.AdjustDistanceToTarget(Power(1.5, ( 2700 / test )  / -120));
         {.update focused object name}
         FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
        {.update the corresponding popup menu}
         if CMTisUpdPMenu
         then FCMuiAP_Update_SpaceUnit;
      end;
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
      FCMovM_CameraMain_Target(foSpaceUnit, true)
      {:DEV NOTES: put the spu part of cammain target here + root test if DBSpaceUnit=0 then use FC3doglSelectedSpaceUnit.}
   end;
end;

function FCFovM_Focused3dObject_GetType(): TFCEovmFocusedObjects;
{:Purpose: return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit.
    Additions:
      -2013Sep14- *mod: the result of the function is now a more readable and understandable result.
}
begin
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FCWinMain.FCGLSStarMain
   then Result:=foStar
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then Result:=foOrbitalObject
   else if ( FC3doglMainViewTotalSatellites>0 )
      and ( FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite] )
   then Result:=foSatellite
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit]
   then Result:=foSpaceUnit;
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
   LSVUangleRad
	,OrbitDistanceInUnits
   ,LSVUsatDistUnit: extended;

   OrbitalObjCount,
   MVUentCnt,
   LSVUorbObjTtlInDS,
   LSVUspUnCnt,
   LSVUspUnFacTtl,
   Satellite3DCount,
   TotalSatInDataStructure,
   SatelliteIndex: integer;

   CurrentLocation: TFCRoglfPosition;
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
   FCMogO_Star_Set;
   {.set orbital objects}
   LSVUorbObjTtlInDS:=Length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects)-1;
   if LSVUorbObjTtlInDS>0
   then
   begin
      OrbitalObjCount:=1;
      Satellite3DCount:=0;
      {.orbital objects + satellites creation loop}
      while OrbitalObjCount<=LSVUorbObjTtlInDS do
      begin
         {.set the 3d object arrays, if needed}
         if OrbitalObjCount >= Length(FC3doglObjectsGroups)
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
         LSVUangleRad:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_angle1stDay*FCCdiDegrees_To_Radian;   //ok to fill the call w/ param and remove this
         {.asteroid}
         if (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type>=ootAsteroid_Metallic)
            and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type<=ootAsteroid_Icy)
         then
         begin
            {.initialize 3d structure}
            FCMogoO_OrbitalObject_Generate(o3dotAsteroid, OrbitalObjCount);
//               FC3doglAsteroids[TDMVUorbObjCnt].Load3DSFileFrom(FCFoglVMain_Aster_Set(TDMVUorbObjCnt, 0, false));
//               {.set material}
//               FC3doglAsteroids[TDMVUorbObjCnt].Material.FrontProperties:=FC3oglvmAsteroidTemp.Material.FrontProperties;
            {.set common data}
//            FC3doglAsteroids[OrbitalObjCount].TurnAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_axialTilt;
            FC3doglAsteroids[OrbitalObjCount].scale.X
               :=FCFcF_Scale_Conversion(cAsteroidDiameterKmTo3dViewUnits, FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_diameter);
            FC3doglAsteroids[OrbitalObjCount].scale.Y:=FC3doglAsteroids[OrbitalObjCount].scale.X;
            FC3doglAsteroids[OrbitalObjCount].scale.Z:=FC3doglAsteroids[OrbitalObjCount].scale.X;
            {.set distance and location}
            {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_OrbitalObject_CalculatePosition.}
            OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_distanceFromStar);//dev:USE /5.5 - WARNING: adjust all dist proportionally ; //ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.X:=cos(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Y:=0;//ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Z:=sin(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
            {.set group scale}
            FC3doglObjectsGroups[OrbitalObjCount].CubeSize:=FC3doglAsteroids[OrbitalObjCount].scale.X*50;
            {.displaying}
            FC3doglObjectsGroups[OrbitalObjCount].Visible:=true;
            FC3doglPlanets[OrbitalObjCount].Visible:=false;
            FC3doglAsteroids[OrbitalObjCount].Visible:=true;
            {.set orbits}
            FCMogO_Orbit_Generation(otPlanet, OrbitalObjCount, 0, 0, OrbitDistanceInUnits);
            {.space units in orbit of current object}
            FCMoglVM_OObjSpUn_inOrbit(OrbitalObjCount, 0, 0, true);
         end //==END== if (OO_type>=oobtpAster_Metall) and (OO_type<=oobtpAster_Icy) ==//
         {.planet}
         else if (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type>=ootPlanet_Telluric)
                 and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type<=ootPlanet_Supergiant)
         then
         begin
            {.initialize 3d structure}
            FCMogoO_OrbitalObject_Generate(o3dotPlanet, OrbitalObjCount);
            {.inclination}
//            FC3doglPlanets[OrbitalObjCount].RollAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_axialTilt;
            {.set scale}
            FC3doglPlanets[OrbitalObjCount].scale.X
               :=FCFcF_Scale_Conversion(cKmTo3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_diameter);
            FC3doglPlanets[OrbitalObjCount].scale.Y:=FC3doglPlanets[OrbitalObjCount].scale.X;
            FC3doglPlanets[OrbitalObjCount].scale.Z:=FC3doglPlanets[OrbitalObjCount].scale.X;
            {.set distance and location}
            {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_OrbitalObject_CalculatePosition.}

//            CurrentLocation:=FCFoglF_OrbitalObject_CalculatePosition(
//                 FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_distanceFromStar
//                 ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_angle1stDay
//
//            )                                                                                                                            ;
//            FC3doglObjectsGroups[OrbitalObjCount].Position.X:=CurrentLocation.P_x;
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Y:=CurrentLocation.P_y;
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Z:=CurrentLocation.P_z;

            OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_distanceFromStar);//dev:USE /5.5 - WARNING: adjust all dist proportionally ; //ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.X:=cos(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Y:=0;//ok to fill the call w/ param and remove this
//            FC3doglObjectsGroups[OrbitalObjCount].Position.Z:=sin(LSVUangleRad)*OrbitDistanceInUnits;//ok to fill the call w/ param and remove this
            {.set group scale}
            FC3doglObjectsGroups[OrbitalObjCount].CubeSize:=FC3doglPlanets[OrbitalObjCount].scale.X*2;
            {.set atmosphere}
            if ( ( (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type = ootPlanet_Telluric) or (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type = ootPlanet_Icy) ) and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_atmosphericPressure>0) )
               or (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type in [ootPlanet_Gaseous_Uranus..ootPlanet_Supergiant]) then
            begin
               FCMogoO_Atmosphere_SetColors(OrbitalObjCount, 0, 0);
               FC3doglAtmospheres[OrbitalObjCount].Sun:=FCWinMain.FCGLSSM_Light;
               if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type<ootPlanet_Gaseous_Uranus
               then FC3doglAtmospheres[OrbitalObjCount].Opacity
                  :=FCFoglVMain_CloudsCov_Conv2AtmOp(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_cloudsCover)
               else FC3doglAtmospheres[OrbitalObjCount].Opacity:=FCFoglVMain_CloudsCov_Conv2AtmOp(-1);
               FC3doglAtmospheres[OrbitalObjCount].Visible:=true;
            end;
            {.texturing}
            FCMoglVMain_MapTex_Assign(OrbitalObjCount, 0, 0);
            {.satellites}
            TotalSatInDataStructure:=Length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList)-1;
            if TotalSatInDataStructure>0
            then
            begin
               SatelliteIndex:=1;
               while SatelliteIndex<=TotalSatInDataStructure do
               begin
                  inc(Satellite3DCount);
                  {.set the 3d object arrays, if needed}
                  if Satellite3DCount >= Length(FC3doglSatellitesObjectsGroups) then
                  begin
                     SetLength(FC3doglSatellitesObjectsGroups, Length(FC3doglSatellitesObjectsGroups)+LSVUblocCnt);
                     SetLength(FC3doglSatellites, Length(FC3doglSatellites)+LSVUblocCnt);
                     SetLength(FC3doglSatellitesAtmospheres, length(FC3doglSatellitesAtmospheres)+LSVUblocCnt);
                     SetLength(FC3doglSatellitesAsteroids, Length(FC3doglSatellitesAsteroids)+LSVUblocCnt);
                     SetLength(FC3doglMainViewListSatellitesGravityWells, Length(FC3doglMainViewListSatellitesGravityWells)+LSVUblocCnt);
                     SetLength(FC3doglMainViewListSatelliteOrbits, Length(FC3doglMainViewListSatelliteOrbits)+LSVUblocCnt);
                  end;
                  {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition}
                  LSVUangleRad:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_angle1stDay*FCCdiDegrees_To_Radian; //ok to fill the call w/ param and remove this
                  {.for a satellite asteroid}
                  if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_type<ootSatellite_Planet_Telluric
                  then
                  begin
                     {.initialize 3d structure}
                     FCMogoO_OrbitalObject_Generate( o3dotSatelliteAsteroid, Satellite3DCount, OrbitalObjCount , SatelliteIndex );
//                        {.initialize 3d structure}
//                        FC3doglSatellitesAsteroids[TDMVUsatCnt].Load3DSFileFrom(FCFoglVMain_Aster_Set(TDMVUorbObjCnt, TDMVUsatIdx, true));
                     {.set material}
//                        FC3doglSatellitesAsteroids[Satellite3DCount].Material.FrontProperties:=FC3oglvmAsteroidTemp.Material.FrontProperties;
                     {.set axial tilt}
                     FC3doglSatellitesAsteroids[Satellite3DCount].TurnAngle:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_axialTilt;
                     {.set scale}
                     FC3doglSatellitesAsteroids[Satellite3DCount].scale.X
                        :=FCFcF_Scale_Conversion
                           (
                              cAsteroidDiameterKmTo3dViewUnits
                              , FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex]
                                 .OO_diameter
                           );
                     FC3doglSatellitesAsteroids[Satellite3DCount].scale.Y:=FC3doglSatellitesAsteroids[Satellite3DCount].scale.X;
                     FC3doglSatellitesAsteroids[Satellite3DCount].scale.Z:=FC3doglSatellitesAsteroids[Satellite3DCount].scale.X;
                     {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition.}
                     {.set distance and location}
                     LSVUsatDistUnit:=FCFcF_Scale_Conversion   //ok to fill the call w/ param and remove this
                        (                                                        //ok to fill the call w/ param and remove this
                           cKmTo3dViewUnits                                              //ok to fill the call w/ param and remove this
                           ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex]   //ok to fill the call w/ param and remove this
                              .OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000                             //ok to fill the call w/ param and remove this
                        );                                                               //ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.X              //ok to fill the call w/ param and remove this
                        :=FC3doglObjectsGroups[OrbitalObjCount].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);//ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.Y:=0;//ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.Z//ok to fill the call w/ param and remove this
                        :=FC3doglObjectsGroups[OrbitalObjCount].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);//ok to fill the call w/ param and remove this
                     {.set group scale}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].CubeSize:=FC3doglSatellitesAsteroids[Satellite3DCount].scale.X*50;
                     {.displaying}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Visible:=true;
                     FC3doglSatellites[Satellite3DCount].Visible:=false;
                     FC3doglSatellitesAsteroids[Satellite3DCount].Visible:=true;
                  end //==END== if ...OOS_type<oobtpSat_Tellu_Lunar ==//
                  {.for a satellite planetoid}
                  else if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_type>ootSatellite_Asteroid_Icy then
                  begin
                     {.initialize 3d structure}
                     FCMogoO_OrbitalObject_Generate(o3dotSatellitePlanet, Satellite3DCount, OrbitalObjCount, SatelliteIndex);
                     {.axial tilt}
                     FC3doglSatellites[Satellite3DCount].RollAngle
                        :=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_axialTilt;
                     {.set scale}
                     FC3doglSatellites[Satellite3DCount].scale.X
                        :=FCFcF_Scale_Conversion
                           (
                              cKmTo3dViewUnits
                              ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_diameter
                           );
                     FC3doglSatellites[Satellite3DCount].scale.Y:=FC3doglSatellites[Satellite3DCount].scale.X;
                     FC3doglSatellites[Satellite3DCount].scale.Z:=FC3doglSatellites[Satellite3DCount].scale.X;
                     {:DEV NOTES: WARNING A FUNCTION NOW EXISTS FOR THIS CALCULATION: FCFoglF_Satellite_CalculatePosition.}
                     {.set distance and location}
                     LSVUsatDistUnit:=FCFcF_Scale_Conversion     //ok to fill the call w/ param and remove this
                        (                            //ok to fill the call w/ param and remove this
                           cKmTo3dViewUnits       //ok to fill the call w/ param and remove this
                           ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex] //ok to fill the call w/ param and remove this
                              .OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000       //ok to fill the call w/ param and remove this
                        );     //ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.X     //ok to fill the call w/ param and remove this
                        :=FC3doglObjectsGroups[OrbitalObjCount].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);  //ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.Y:=0; //ok to fill the call w/ param and remove this
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Position.Z    //ok to fill the call w/ param and remove this
                        :=FC3doglObjectsGroups[OrbitalObjCount].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);  //ok to fill the call w/ param and remove this
                     {.set group scale}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].CubeSize:=FC3doglSatellites[Satellite3DCount].scale.X*2;
                     {.set atmosphere}
                     if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_atmosphericPressure > 0 then
                     begin
                        FCMogoO_Atmosphere_SetColors(OrbitalObjCount, SatelliteIndex, Satellite3DCount);
                        FC3doglSatellitesAtmospheres[Satellite3DCount].Sun:=FCWinMain.FCGLSSM_Light;
                        FC3doglSatellitesAtmospheres[Satellite3DCount].Opacity
                           :=FCFoglVMain_CloudsCov_Conv2AtmOp(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_satellitesList[SatelliteIndex].OO_cloudsCover);
                        FC3doglSatellitesAtmospheres[Satellite3DCount].Visible:=true;
                     end;
                     {.texturing}
                     FCMoglVMain_MapTex_Assign(OrbitalObjCount, SatelliteIndex, Satellite3DCount);
                     {.displaying}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Visible:=true;
                     FC3doglSatellites[Satellite3DCount].Visible:=true;
                  end; //==END== if OOS_type>oobtpSat_Aster_Icy ==//
                  {.set orbits}
                  FCMogO_Orbit_Generation(
                     otSatellite
                     ,OrbitalObjCount
                     ,SatelliteIndex
                     ,Satellite3DCount
                     ,LSVUsatDistUnit
                     );
                  {.space units in orbit of current object}
                  FCMoglVM_OObjSpUn_inOrbit(OrbitalObjCount, SatelliteIndex, Satellite3DCount,true);
                  {.set tag values}
                        {satellite index #}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Tag:=SatelliteIndex;
                        {central orbital object linked}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].TagFloat:=OrbitalObjCount;
                  {.put index of the first sat object}
                  if SatelliteIndex=1
                  then FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_isNotSat_1st3dObjectSatelliteIndex:=Satellite3DCount;
                  inc(SatelliteIndex);
               end; //==END== while TDMVUsatIdx<=TDMVUsatTtlInDS ==//
               FC3doglMainViewTotalSatellites:=Satellite3DCount;
            end;//==END== if Length(SDB_obobj[LSVUorbObjCnt].OO_satList>1) ==//
            {.displaying}
            FC3doglObjectsGroups[OrbitalObjCount].Visible:=true;
            FC3doglPlanets[OrbitalObjCount].Visible:=true;
            {.set orbits}
            FCMogO_Orbit_Generation(otPlanet, OrbitalObjCount, 0, 0, OrbitDistanceInUnits);
            {.space units in orbit of current object}
            FCMoglVM_OObjSpUn_inOrbit(OrbitalObjCount, 0, 0, true);
         end; //==END== else if (SDB_obobj[LSVUorbObjCnt].OO_type>=oobtpPlan_Tellu...//
         inc(OrbitalObjCount);
      end; //==END== while LSVUorbObjCnt<=LSVUorbObjInTtl ==//
      FC3doglMainViewTotalOrbitalObjects:=OrbitalObjCount-1;
   end; //==END==if Length(FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB].SDB_obobj)>1==//
   SetLength(FC3doglObjectsGroups, OrbitalObjCount+1);
   SetLength(FC3doglPlanets, OrbitalObjCount+1);
   SetLength(FC3doglAtmospheres, OrbitalObjCount+1);
   SetLength(FC3doglAsteroids, OrbitalObjCount+1);
   SetLength(FC3doglMainViewListMainOrbits, OrbitalObjCount+1);
   SetLength(FC3doglMainViewListGravityWells, OrbitalObjCount+1);
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
   FCMogoO_TemporarySat_Free;
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
   FCMovM_CameraMain_Target(foOrbitalObject, true);
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
//      :=OOSUCSdmpSize*FC3doglSpaceUnits[OOSUCSobjIdx].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*32;//8;
      :=OOSUCSdmpSize*( 5+ power( FC3doglSpaceUnits[OOSUCSobjIdx].DistanceTo(FCWinMain.FCGLSStarMain)/1711,2.5 ) );
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
                  FC3doglSpaceUnits[OOSUIOspUnObjIdx].Pitch(90);
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
//   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X
//      :=FC3doglSpaceUnitSize
//      *
//         (1+
//            (
//               (1/(fcwinmain.FCGLSCamMainViewGhost.DistanceToTarget/fcwinmain.FCGLSCamMainViewGhost.TargetObject.Scale.X))
//               *150//150
//            )
//         )
//         ;
//   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
//   FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
end;

end.
