{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: OpenGL Framework - orbits generation unit

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
unit farc_ogl_genorbits;

interface

uses
   Math
   ,SysUtils

   ,GLColor
   ,GLObjects

   ,oxLib3dsMeshLoader;

type TFCEogoOrbitTypes=(
   otAsteroidBelt
   ,otAsteroidInABelt
   ,otPlanetAster
   ,otSatellite
   ,otSpaceUnit
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   generate an orbit display at 1/4 and centered around central scene object for planet
///   orbit or full and centered around spacecraft for vessel beacon
///</summary>
procedure FCMogO_Orbit_Generation(
   const OrbitType: TFCEogoOrbitTypes;
   const OrbitalObject3DIndex,
         SatelliteIndex,
         Satellite3DIndex: integer;
   const DistanceIn3DUnits: extended
   );

implementation

uses
   farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ
   ,farc_main
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================

//var

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMogO_Orbit_Generation(
   const OrbitType: TFCEogoOrbitTypes;
   const OrbitalObject3DIndex,
         SatelliteIndex,
         Satellite3DIndex: integer;
   const DistanceIn3DUnits: extended
   );
{:Purpose: generate an orbit display at 1/4 and centered around central scene object for
            planet orbit or full and centered around spacecraft for vessel beacon.
            Thanks to Ivan S. for the base code.
    Additions:
      -2013Sep22- *add: begin asteroid belt.
                  *code: some code cleanup.
      -2013Sep14- *code: moved the procedure in its proper unit + multiple code refactoring.
      -2009Dec16- *add: satellite orbits.
      -2009Dec09- *some changes since distance change.
      -2009Sep14- *add gravity well orbit.
}
const
   LinePattern=65535;
   LineWidth=1.5;
   OrbitSegments=40;
   OrbitWidth=90/100;
   OrbitHeight=90/100;
var
   OBcount: integer;

   RotationAngleCos
   ,RotationAngleSin
   ,OBtheta
   ,OBxx
   ,OByy
   ,OBxRotated
   ,OByRotated
   ,OBrotAngle: extended;
begin
   OBcount:=0;

   RotationAngleCos:=0;
   RotationAngleSin:=0;
   OBtheta:=0;
   OBxx:=0;
   OByy:=0;
   OBxRotated:=0;
   OByRotated:=0;
   OBrotAngle:=0;

   case OrbitType of
      otAsteroidBelt:
      begin
//         {.initialize root orbit}
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Name:='FCGLSObObjPlantOrb'+IntToStr(OrbitalObject3DIndex);
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].AntiAliased:=true;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Division:=16;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Alpha:=1;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Blue:=0.953;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Green:=0.576;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Red:=0.478;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LinePattern:=LinePattern;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineWidth:=LineWidth;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeSize:=0.005;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.Clear;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X:=DistanceIn3DUnits*1;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Y:=1;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Z:=FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Visible:=true;
         {.nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].StructureChanged;
            inc(OBcount);
         end;
      end;

      otAsteroidInABelt:
      begin
         {.initialize root orbit}
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Name:='FCGLSsatOrb'+IntToStr(Satellite3DIndex);
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].AntiAliased:=true;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Division:=16;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineColor.Alpha:=1;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineColor.Color:=clrCornflowerBlue;//clrMidnightBlue;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodeSize:=0.005;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Nodes.Clear;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.X:=DistanceIn3DUnits*(1.11105+(power(DistanceIn3DUnits,0.333)*0.000004));
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.Y:=1;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.Z:=FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_angle1stDay;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Visible:=true;
         {.nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].StructureChanged;
            inc(OBcount);
         end;
         {.initialize gravity well orbit}
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex]:=TGLLines(FC3doglSatellitesObjectsGroups[Satellite3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Name:='FCGLSsatGravOrb'+IntToStr(Satellite3DIndex);
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].AntiAliased:=true;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Division:=8;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LineColor.Color:=clrGoldenrod;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodeSize:=0.005;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Nodes.Clear;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X:=(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
         if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_type in [ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Icy]
         then FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X*6.42;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.Y:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.Z:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Visible:=true;
         {.gravity well nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].StructureChanged;
            inc(OBcount);
         end;
      end;

      otPlanetAster:
      begin
//         {.initialize root orbit}
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Name:='FCGLSObObjPlantOrb'+IntToStr(OrbitalObject3DIndex);
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].AntiAliased:=true;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Division:=16;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Alpha:=1;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Blue:=0.953;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Green:=0.576;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Red:=0.478;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LinePattern:=LinePattern;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineWidth:=LineWidth;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeSize:=0.005;
//         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.Clear;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X:=DistanceIn3DUnits*(1.11105+(power(DistanceIn3DUnits,0.333)*0.000004));
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Y:=1;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Z:=FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Visible:=true;
         {.nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=90*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].StructureChanged;
            inc(OBcount);
         end;
//         {.initialize gravity well orbit}
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Name:='FCGLSObObjPlantGravOrb'+IntToStr(OrbitalObject3DIndex);
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].AntiAliased:=true;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Division:=8;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineColor.Color:=clrYellowGreen;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LinePattern:=LinePattern;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineWidth:=LineWidth;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodeSize:=0.005;
//         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Nodes.Clear;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X:=(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
         if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_type in [ootAsteroid_Metallic..ootAsteroid_Icy]
         then FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X*6.42;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.Y:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.Z:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Visible:=true;
         {.gravity well nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListGravityWells[OrbitalObject3DIndex].StructureChanged;
            inc(OBcount);
         end;
      end; //==END== case OrbitType of: otPlanet ==//

      otSatellite:
      begin
         {.initialize root orbit}
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Name:='FCGLSsatOrb'+IntToStr(Satellite3DIndex);
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].AntiAliased:=true;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Division:=16;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineColor.Alpha:=1;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineColor.Color:=clrCornflowerBlue;//clrMidnightBlue;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].NodeSize:=0.005;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Nodes.Clear;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.X:=DistanceIn3DUnits*(1.11105+(power(DistanceIn3DUnits,0.333)/250000));
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.Y:=1;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.Z:=FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_angle1stDay;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Visible:=true;
         {.nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatelliteOrbits[Satellite3DIndex].StructureChanged;
            inc(OBcount);
         end;
         {.initialize gravity well orbit}
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex]:=TGLLines(FC3doglSatellitesObjectsGroups[Satellite3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Name:='FCGLSsatGravOrb'+IntToStr(Satellite3DIndex);
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].AntiAliased:=true;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Division:=8;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LineColor.Color:=clrGoldenrod;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].NodeSize:=0.005;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Nodes.Clear;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X:=(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
         if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_type in [ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Icy]
         then FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X*6.42;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.Y:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.Z:=FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[SatelliteIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Visible:=true;
         {.gravity well nodes generation}
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=OrbitWidth*cos(OBtheta);
            OByy:=OrbitHeight*sin(OBtheta);
            OBxRotated:=(OBxx*RotationAngleCos)-(OByy*RotationAngleSin);
            OByRotated:=(OBxx*RotationAngleSin)+(OByy*RotationAngleCos);
            FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatellitesGravityWells[Satellite3DIndex].StructureChanged;
            inc(OBcount);
         end;
      end; //==END== case OrbitType of: otSatellite ==//

      otSpaceUnit:
      begin
      end; //==END== case OrbitType of: otSpaceUnit ==//
   end; //==END== case OrbitType of ==//
end;

end.
