{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: OpenGL Framework - main view unit

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
   ,foAsteroidBelt
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
///   cleanup the 3d view by resetting all the data structures
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMovM_3DView_Cleanup;

///<summary>
///   initialize the 3d view data structures
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks>call it only once for all the lifetime of FARC when its launched! Include a call to FCMovM_3DView_Cleanup</remarks>
procedure FCMovM_3DView_Initialize;

///<summary>
///   reset the 3d view data structures for a new setup
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMovM_3DView_Reset;

///<summary>
///setup 3d main view: star itself and it's eventual planets and satellites
///</summary>
///   <param name="StarSys">star system index #</param>
///   <param name="Star">star index #</param>
procedure FCMovM_3DView_Update(
   const StarSys
         ,Star: string
   );

///<summary>
///target a specified object in 3d view and initialize user's interface if needed
///</summary>
///   <param name="FocusedObject">type of object to focus</param>
///   <param name="mustUpdatePopupMenu">[=true] the popup menu is updated</param>
procedure FCMovM_CameraMain_Target(
   const FocusedObject: TFCEovmFocusedObjects;
   const mustUpdatePopupMenu: boolean
   );


///<summary>
///   switch toward the current orbital object (loaded into FC3doglSelectedPlanetAsteroid previously)
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMovM_OObj_SwitchTo;

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
///   switch toward the targeted satellite
///</summary>
///   <param name="SatelliteDBIndex">can be 0: FC3doglSelectedSatellite isn't altered then</param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMovM_Sat_SwitchTo( const SatelliteDBIndex: integer );

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
   ,farc_ui_missionsetup
   ,farc_ui_surfpanel
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

function FCFovM_Focused3dObject_GetType(): TFCEovmFocusedObjects;
{:Purpose: return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit.
    Additions:
      -2013Sep22- *add: asteroid belt.
      -2013Sep14- *mod: the result of the function is now a more readable and understandable result.
}
begin
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FCWinMain.FCGLSStarMain
   then Result:=foStar
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid]
   then Result:=foAsteroidBelt
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid]
   then Result:=foOrbitalObject
   else if ( FC3doglMainViewTotalSatellites>0 )
      and ( FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite] )
   then Result:=foSatellite
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit]
   then Result:=foSpaceUnit;
end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMovM_3DView_Cleanup;
{:Purpose: cleanup the 3d view by resetting all the data structures.
    Additions:
}
begin
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
   FC3doglSatellitesPlanet:=nil;
   SetLength(FC3doglSatellitesPlanet,1);
   FC3doglObjectsGroups:=nil;
   SetLength(FC3doglObjectsGroups,1);
   FC3doglPlanets:=nil;
   SetLength(FC3doglPlanets,1);
   FC3doglAsteroids:=nil;
   SetLength(FC3doglAsteroids,1);
   FC3doglMainViewMax3DSatellitesInDataS:=0;
end;

procedure FCMovM_3DView_Initialize;
{:Purpose: initialize the 3d view data structures.
    Additions:
}
   const
      MaxOrbitalObjects = 15;
      MaxSetLength = MaxOrbitalObjects + 1;

   var
      Count: integer;
begin
   FCMovM_3DView_Cleanup;
   SetLength( FC3doglObjectsGroups, MaxSetLength );
   SetLength( FC3doglPlanets, MaxSetLength );
   SetLength( FC3doglAsteroids, MaxSetLength );
   SetLength( FC3doglAtmospheres, MaxSetLength );
   SetLength( FC3doglMainViewListGravityWells, MaxSetLength );
   SetLength( FC3doglMainViewListMainOrbits, MaxSetLength );
   Count:=1;
   while Count <= MaxOrbitalObjects do
   begin
      FCMogoO_OrbitalObject_Initialize( Count );
      inc( Count );
   end;
   FCMovM_3DView_Reset;
end;

procedure FCMovM_3DView_Reset;
{:Purpose: reset the 3d view data structures for a new setup.
    Additions:
      -2013Nov13- *add: complete satellite cleanup.
      -2013Nov03- *add: start satellite cleanup.
}
   var
      Count: integer;
begin
   Count:=1;
   while Count <= FC3doglMainViewTotalOrbitalObjects do
   begin
      FC3doglObjectsGroups[Count].Visible:=false;
      FC3doglPlanets[Count].Visible:=false;
      FC3doglAsteroids[Count].Visible:=false;
      FC3doglAtmospheres[Count].Visible:=false;
      FC3doglMainViewListMainOrbits[Count].Nodes.Clear;
      FC3doglMainViewListGravityWells[Count].Nodes.Clear;
      inc( Count );
   end;
   FC3doglMainViewTotalOrbitalObjects:=0;
   FC3doglMainViewTotalSpaceUnits:=0;
   Count:=1;
   while Count <= FC3doglMainViewTotalSatellites do
   begin
      FC3doglSatellitesObjectsGroups[Count].Visible:=false;
      FC3doglSatellitesPlanet[Count].Visible:=false;
      FC3doglSatellitesAsteroids[Count].Visible:=false;
      FC3doglSatellitesAtmospheres[Count].Visible:=false;
      FC3doglMainViewListSatelliteOrbits[Count].Nodes.Clear;
      FC3doglMainViewListSatellitesGravityWells[Count].Nodes.Clear;
      inc( Count );
   end;
   FC3doglMainViewTotalSatellites:=0;
   FC3doglSelectedPlanetAsteroid:=0;
   FC3doglSelectedSatellite:=0;
   FC3doglSelectedSpaceUnit:=0;
end;

procedure FCMovM_3DView_Update(
   const StarSys
         ,Star: string
   );
{:Purpose: setup local star view: star itself and it's eventual planets & satellites.
    Additions:
      -2013Sep22- *add: begin implementation of asteroid belt.
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
   OrbitDistanceInUnits: extended;

   OrbitalObjIndex,
   MVUentCnt,
   LSVUspUnCnt,
   LSVUspUnFacTtl,
   Satellite3DCount,
   TotalSatInDataStructure,
   SatelliteIndex: integer;

   CurrentLocation: TFCRoglfPosition;
begin
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
   {.set the update message}
   FCWinMain.WM_MainViewGroup.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'FCWM_3dMainGrp.Upd' );
   {.set star}
   FCMogO_Star_Set;
   {.set orbital objects}
   FC3doglMainViewTotalOrbitalObjects:=Length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects )-1;
   if FC3doglMainViewTotalOrbitalObjects > 0 then
   begin
      OrbitalObjIndex:=1;
      Satellite3DCount:=0;
      {.orbital objects + satellites creation loop}
      while OrbitalObjIndex <= FC3doglMainViewTotalOrbitalObjects do
      begin
         case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_type of
            ootAsteroidsBelt:
            begin
               {.initialize 3d structure}
               FCMogoO_OrbitalObject_Generate( o3dotAsterBelt, OrbitalObjIndex);
               OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_isNotSat_distanceFromStar);
               FCMogO_Orbit_Generation(
                  otAsteroidBelt
                  ,OrbitalObjIndex
                  ,0
                  ,0
                  ,OrbitDistanceInUnits
                  );
               {.asteroids in the belt}
               TotalSatInDataStructure:=Length( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList ) - 1;
               SatelliteIndex:=1;
               while SatelliteIndex <= TotalSatInDataStructure do
               begin
                  inc( Satellite3DCount );
                  {.initialize 3d structure}
                  FCMogoO_OrbitalObject_Generate( o3dotAsteroidInABelt, Satellite3DCount, OrbitalObjIndex , SatelliteIndex );
                  {.displaying}
                  FC3doglSatellitesObjectsGroups[Satellite3DCount].Visible:=true;
                  FC3doglSatellitesPlanet[Satellite3DCount].Visible:=false;
                  FC3doglSatellitesAsteroids[Satellite3DCount].Visible:=true;
                  {.set orbits}
                  OrbitDistanceInUnits:=FCFcF_Scale_Conversion(
                     cAU_to3dViewUnits
                     ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar
                     );
                  FCMogO_Orbit_Generation(
                     otAsteroidInABelt
                     ,OrbitalObjIndex
                     ,SatelliteIndex
                     ,Satellite3DCount
                     ,OrbitDistanceInUnits
                     );
                  {.space units in orbit of current object}
                  FCMoglVM_OObjSpUn_inOrbit(OrbitalObjIndex, SatelliteIndex, Satellite3DCount,true);
                  {.set tag values}
                  {satellite index #}
                  FC3doglSatellitesObjectsGroups[Satellite3DCount].Tag:=SatelliteIndex;
                  {central orbital object linked}
                  FC3doglSatellitesObjectsGroups[Satellite3DCount].TagFloat:=OrbitalObjIndex;
                  {.put index of the first sat object}
                  if SatelliteIndex=1
                  then FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_isNotSat_1st3dObjectSatelliteIndex:=Satellite3DCount;
                  inc(SatelliteIndex);
               end; //==END== while SatelliteIndex<=TotalSatInDataStructure ==//
               FC3doglMainViewTotalSatellites:=Satellite3DCount;
            end;

            ootAsteroid_Metallic..ootAsteroid_Icy:
            begin
               {.initialize 3d structure}
               FCMogoO_OrbitalObject_Generate(o3dotAsteroid, OrbitalObjIndex);
               {.displaying}
               FC3doglObjectsGroups[OrbitalObjIndex].Visible:=true;
               FC3doglPlanets[OrbitalObjIndex].Visible:=false;
               FC3doglAsteroids[OrbitalObjIndex].Visible:=true;
               {.set orbits}
               OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_isNotSat_distanceFromStar);
               FCMogO_Orbit_Generation(otPlanetAster, OrbitalObjIndex, 0, 0, OrbitDistanceInUnits);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(OrbitalObjIndex, 0, 0, true);
            end;

            ootPlanet_Telluric..ootPlanet_Supergiant:
            begin
               {.initialize 3d structure}
               FCMogoO_OrbitalObject_Generate(o3dotPlanet, OrbitalObjIndex);
               {.set atmosphere}
               if (
                  ( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_type in [ootPlanet_Telluric..ootPlanet_Icy] )
                     and ( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_atmosphericPressure > 0 )
                     and ( not FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_atmosphere.AC_traceAtmosphere )
                  )
                  or (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_type in [ootPlanet_Gaseous_Uranus..ootPlanet_Supergiant])
               then FCMogoO_Atmosphere_Setup(OrbitalObjIndex, 0, 0);
               {.texturing}
               FCMogO_SurfaceMapTexture_Assign(OrbitalObjIndex, 0, 0);
               {.satellites}
               TotalSatInDataStructure:=Length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList)-1;
               SatelliteIndex:=1;
               while SatelliteIndex<=TotalSatInDataStructure do
               begin
                  inc(Satellite3DCount);
                  {.for a satellite asteroid}
                  if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_type<ootSatellite_Planet_Telluric then
                  begin
                     {.initialize 3d structure}
                     FCMogoO_OrbitalObject_Generate( o3dotSatelliteAsteroid, Satellite3DCount, OrbitalObjIndex , SatelliteIndex );
                     {.displaying}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Visible:=true;
                     FC3doglSatellitesPlanet[Satellite3DCount].Visible:=false;
                     FC3doglSatellitesAsteroids[Satellite3DCount].Visible:=true;
                  end //==END== if ...OOS_type<oobtpSat_Tellu_Lunar ==//
                  {.for a satellite planetoid}
                  else if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_type>ootSatellite_Asteroid_Icy then
                  begin
                     {.initialize 3d structure}
                     FCMogoO_OrbitalObject_Generate(o3dotSatellitePlanet, Satellite3DCount, OrbitalObjIndex, SatelliteIndex);
                     {.set atmosphere}
                     if ( FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_atmosphericPressure > 0 )
                        and ( not FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_atmosphere.AC_traceAtmosphere )
                     then FCMogoO_Atmosphere_Setup(OrbitalObjIndex, SatelliteIndex, Satellite3DCount);
                     {.texturing}
                     FCMogO_SurfaceMapTexture_Assign(OrbitalObjIndex, SatelliteIndex, Satellite3DCount);
                     {.displaying}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Visible:=true;
                     FC3doglSatellitesPlanet[Satellite3DCount].Visible:=true;
                  end; //==END== if OOS_type>oobtpSat_Aster_Icy ==//
                  OrbitDistanceInUnits:=FCFcF_Scale_Conversion(
                     cKmTo3dViewUnits
                     ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_satellitesList[SatelliteIndex].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000
                     );
                  {.set orbits}
                  FCMogO_Orbit_Generation(
                     otSatellite
                     ,OrbitalObjIndex
                     ,SatelliteIndex
                     ,Satellite3DCount
                     ,OrbitDistanceInUnits
                     );
                  {.space units in orbit of current object}
                  FCMoglVM_OObjSpUn_inOrbit(OrbitalObjIndex, SatelliteIndex, Satellite3DCount,true);
                  {.set tag values}
                        {satellite index #}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].Tag:=SatelliteIndex;
                        {central orbital object linked}
                     FC3doglSatellitesObjectsGroups[Satellite3DCount].TagFloat:=OrbitalObjIndex;
                  {.put index of the first sat object}
                  if SatelliteIndex=1
                  then FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_isNotSat_1st3dObjectSatelliteIndex:=Satellite3DCount;
                  inc(SatelliteIndex);
               end; //==END== while TDMVUsatIdx<=TDMVUsatTtlInDS ==//
               FC3doglMainViewTotalSatellites:=Satellite3DCount;
               {.set distance and location}
               OrbitDistanceInUnits:=FCFcF_Scale_Conversion(cAU_to3dViewUnits,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjIndex].OO_isNotSat_distanceFromStar);
               {.displaying}
               FC3doglObjectsGroups[OrbitalObjIndex].Visible:=true;
               FC3doglPlanets[OrbitalObjIndex].Visible:=true;
               {.set orbits}
               FCMogO_Orbit_Generation(otPlanetAster, OrbitalObjIndex, 0, 0, OrbitDistanceInUnits);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(OrbitalObjIndex, 0, 0, true);
            end;
         end; //==END== case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObjCount].OO_type ==//
         inc(OrbitalObjIndex);
      end; //==END== while LSVUorbObjCnt<=LSVUorbObjInTtl ==//
   end; //==END==if Length(FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB].SDB_obobj)>1==//
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
//   FCMogoO_TemporarySat_Free;
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

procedure FCMovM_CameraMain_Target(
   const FocusedObject: TFCEovmFocusedObjects;
   const mustUpdatePopupMenu: boolean
   );
{:Purpose: target a specified object in 3d view and initialize user's interface if needed.
    Additions:
      -2013Sep23- *code audit:
                  (x)var formatting + refactoring     (_)if..then reformatting   (x)function/procedure refactoring
                  (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                  (_)float local variables=> extended (_)case..of reformatting   (_)local methods: put inline; + reformat _X
                  (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                  (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                  (x)any function/procedure variable pre-initialization. Init array w/ [0] array EACH PARAMETERS not direct
                  (-)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                  (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                  (x)conditional <>= and operators with spaces
                  (_)if the procedure reset the same record's data or external data put:
                     ///   <remarks>the procedure/function reset the /data/</remarks>
      -2013Sep22- *add: begin the asteroid belt.
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
      fCalc: extended;

      Satellite
      ,SatelliteRoot: integer;
begin
   fCalc:=0;
   Satellite:=0;
   SatelliteRoot:=0;

   case FocusedObject of
      foStar:
      begin
         if FC3doglSpaceUnitSize <> 0
         then FCMoglVMain_SpUnits_SetInitSize( true );
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FCWinMain.FCGLSStarMain;
         FCWinMain.FCGLSCamMainViewGhost.Position.X:=FCWinMain.FCGLSStarMain.Scale.X * 2;
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FCWinMain.FCGLSStarMain.Scale.Y * 1.5;
         FCWinMain.FCGLSCamMainViewGhost.Position.Z:=0;
         {.camera near plane bias}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FCWinMain.FCGLSStarMain;
         {.update focused object name}
         FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuFocusedObject );
         {.update the corresponding popup menu}
         if ( mustUpdatePopupMenu )
            and ( FCVdiActionPanelSatMode = 0 )
         then FCMuiAP_Update_OrbitalObject
         else if mustUpdatePopupMenu
         then FCMuiAP_Update_Satellites( FCVdiActionPanelSatMode );
      end;

      foAsteroidBelt:
      begin
         if FC3doglSpaceUnitSize <> 0
         then FCMoglVMain_SpUnits_SetInitSize( true );
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid];
         {.X location}
         FCWinMain.FCGLSCamMainViewGhost.Position.X:=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid].Scale.X ;
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid].Scale.X;
         FCWinMain.FCGLSCamMainViewGhost.Position.Z:=0;
         {.camera near plane bias}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglMainViewListMainOrbits[FC3doglSelectedPlanetAsteroid];
         {.update focused object data}
         FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuFocusedObject );
         {.update the corresponding popup menu}
//         FCMuiAP_Panel_Reset;
         if ( mustUpdatePopupMenu )
            and ( FCVdiActionPanelSatMode = 0 )
         then FCMuiAP_Update_OrbitalObject
         else if mustUpdatePopupMenu
         then FCMuiAP_Update_Satellites( FCVdiActionPanelSatMode );
         {.store the player's location}
         FCVdgPlayer.P_viewOrbitalObject:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId;
      end;

      foOrbitalObject:
      begin
         if FC3doglSpaceUnitSize <> 0
         then FCMoglVMain_SpUnits_SetInitSize( true );
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid];
         {.location}
         fCalc:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].CubeSize * 2.3;
         if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X > 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=( FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X ) - fCalc
         else if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X < 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=( FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.X ) + fCalc;
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
         if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z > 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=( FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z ) - fCalc
         else if FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z < 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=( FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid].Position.Z ) + fCalc;
         {.camera near plane bias}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglObjectsGroups[FC3doglSelectedPlanetAsteroid];
         {.update focused object data}
         FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuFocusedObject );
         {.update the corresponding popup menu}
         if ( mustUpdatePopupMenu )
            and ( FCVdiActionPanelSatMode = 0 )
         then FCMuiAP_Update_OrbitalObject
         else if mustUpdatePopupMenu
         then FCMuiAP_Update_Satellites( FCVdiActionPanelSatMode );
         {.store the player's location}
         FCVdgPlayer.P_viewOrbitalObject:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId;
      end;

      foSatellite:
      begin
         if FC3doglSpaceUnitSize <> 0
         then FCMoglVMain_SpUnits_SetInitSize( true );
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite];
         {.location}
         fCalc:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].CubeSize * 2.3;
         if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X > 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X ) - fCalc
         else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X < 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.X:=( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.X ) + fCalc;
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
         if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z > 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z ) - fCalc
         else if FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z < 0
         then FCWinMain.FCGLSCamMainViewGhost.Position.Z:=(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Position.Z ) + fCalc;
         {.camera near plane bias}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=0.55;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite];
         {.update focused object data}
         FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuFocusedObject );
         {.update the corresponding popup menu}
         if ( mustUpdatePopupMenu )
            and ( FCVdiActionPanelSatMode = 0 )
         then FCMuiAP_Update_OrbitalObject
         else if mustUpdatePopupMenu
         then FCMuiAP_Update_Satellites( FCVdiActionPanelSatMode );
         {.store the player's location}
         Satellite:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
         SatelliteRoot:=round( FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat );
         FCVdgPlayer.P_viewSatellite:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[SatelliteRoot].OO_satellitesList[Satellite].OO_dbTokenId;
      end;

      foSpaceUnit:
      begin
         {.camera ghost settings}
         FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];
         FC3doglSpaceUnitSize:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X;
         FCMoglVM_OObjSpUn_ChgeScale(FC3doglSelectedSpaceUnit);
         fCalc:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo( FCWinMain.FCGLSStarMain ) / CFC3dUnInAU * 20;
         FCWinMain.FCGLSCamMainViewGhost.Position.X:=-( FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.X + FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.X + ( 0.05 * fCalc ) );
         FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Y + ( 0.04 * fCalc );
         FCWinMain.FCGLSCamMainViewGhost.Position.Z:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Position.Z + FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Scale.Z + ( 0.05 * fCalc );
         {.configuration}
         FCWinMain.FCGLSCamMainView.NearPlaneBias:=0.01 + ( sqrt( FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo( FCWinMain.FCGLSStarMain ) / CFC3dUnInAU ) / 100 );
         FCMoglVM_SpUn_SetZoomScale;
         {.smooth navigator target change}
         FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit];
         fCalc:=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].DistanceTo( FCWinMain.FCGLSStarMain ) / 1711;
         if fCalc < 0.48
         then fCalc:=fCalc * ( ( 1 / fCalc ) * 1.17 )
         else fCalc:=power( fCalc, 0.111 ) + 0.076128;
         FCWinMain.FCGLSCamMainViewGhost.AdjustDistanceToTarget( Power( 1.5, ( 2700 / fCalc )  / -120 ) );
         {.update focused object name}
         FCMoglUI_CoreUI_Update( ptuTextsOnly, ttuFocusedObject );
        {.update the corresponding popup menu}
         if mustUpdatePopupMenu
         then FCMuiAP_Update_SpaceUnit;
      end;
   end;
end;

procedure FCMovM_OObj_SwitchTo;
{:Purpose: switch toward the current orbital object (loaded into FC3doglSelectedPlanetAsteroid previously).
    Additions:
}
begin
   if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type = ootAsteroidsBelt then
   begin
      if FCWinMain.MVG_SurfacePanel.Visible
      then FCWinMain.MVG_SurfacePanel.Hide;
      FCMovM_CameraMain_Target(foAsteroidBelt, true);
   end
   else begin
      FCMovM_CameraMain_Target(foOrbitalObject, true);
      if FCWinMain.FCWM_MissionSettings.Visible
      then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false)
      else if (not FCWinMain.FCWM_MissionSettings.Visible)
         and (FCWinMain.SP_AutoUpdateCheck.Checked)
      then FCMuiSP_SurfaceEcosphere_Set(FC3doglCurrentStarSystem, FC3doglCurrentStar, FC3doglSelectedPlanetAsteroid, 0, false);
   end;
end;

procedure FCMoglVM_OObjSpUn_ChgeScale(const OOSUCSobjIdx: integer);
{:Purpose: change space unit scale according to it's distance, it's a fast&dirty fix.
    Additions:
      -2009Dec10- *bugfix: don't make a cumulative size change anymore.
}
var
   OOSUCSdmpSize: extended;
begin
   if FC3doglSpaceUnits[OOSUCSobjIdx].Hint='' then
   begin
      FC3doglSpaceUnits[OOSUCSobjIdx].Hint:=floattostr(FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X);
      OOSUCSdmpSize:=FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X;
   end
   else OOSUCSdmpSize:=StrToFloat(FC3doglSpaceUnits[OOSUCSobjIdx].Hint);
   FC3doglSpaceUnits[OOSUCSobjIdx].Scale.X:=OOSUCSdmpSize*( 5+ power( FC3doglSpaceUnits[OOSUCSobjIdx].DistanceTo(FCWinMain.FCGLSStarMain)/1711,2.5 ) );
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

procedure FCMovM_Sat_SwitchTo( const SatelliteDBIndex: integer );
{:Purpose: switch toward the targeted satellite.
    Additions:
}
begin
   if SatelliteDBIndex > 0
   then FC3doglSelectedSatellite:=FCFoglF_Satellite_SearchObject( FCVdiActionPanelSatMode, SatelliteDBIndex );
   FCMovM_CameraMain_Target(foSatellite, true);
   if FCWinMain.FCWM_MissionSettings.Visible
   then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false)
   else if (not FCWinMain.FCWM_MissionSettings.Visible)
      and (FCWinMain.SP_AutoUpdateCheck.Checked)
   then FCMuiSP_SurfaceEcosphere_Set(FC3doglCurrentStarSystem, FC3doglCurrentStar, FC3doglSelectedPlanetAsteroid, SatelliteDBIndex, false);
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
