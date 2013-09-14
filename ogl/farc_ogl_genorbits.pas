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
   ,GLObjects;

type TFCEogoOrbitTypes=(
   otPlanet
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
         Satellite3DIndex,
         OBsatCnt: integer;
   const OBdistInUnit: extended
   );

implementation

uses
   farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ
   ,farc_main;

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
         Satellite3DIndex,
         OBsatCnt: integer;
   const OBdistInUnit: extended
   );
{:Purpose: generate an orbit display at 1/4 and centered around central scene object for
            planet orbit or full and centered around spacecraft for vessel beacon.
            Thanks to Ivan S. for the base code.
    Additions:
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
   ,Xcenter
   ,Ycenter
   ,OBtheta
   ,OBxx
   ,OBxxCen
   ,OByy
   ,OByyCen
   ,OBxRotated
   ,OByRotated
   ,OBrotAngle: extended;
begin
   case OrbitType of
      otPlanet:
      begin
         {.initialize root orbit}
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Name:='FCGLSObObjPlantOrb'+IntToStr(OrbitalObject3DIndex);
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].AntiAliased:=true;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Division:=16;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Alpha:=1;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Blue:=0.953;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Green:=0.576;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Red:=0.478;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].NodeSize:=0.005;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.Clear;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)*0.000004)));
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Y:=FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Z:=FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Visible:=true;
         {.nodes generation}
         Xcenter:=0;
         Ycenter:=0;
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=90*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=Xcenter+OrbitWidth*cos(OBtheta);
            OByy:=Ycenter+OrbitHeight*sin(OBtheta);
            OBxxCen:=OBxx-Xcenter;
            OByyCen:=OByy-Ycenter;
            OBxRotated:=Xcenter+(OBxxCen)*RotationAngleCos-(OByyCen)*RotationAngleSin;
            OByRotated:=Ycenter+(OBxxCen)*RotationAngleSin+(OByyCen)*RotationAngleCos;
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.AddNode(OBxRotated, 0, OByRotated);
            FC3doglMainViewListMainOrbits[OrbitalObject3DIndex].StructureChanged;
            inc(OBcount);
         end;
         {.initialize gravity well orbit}
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Name:='FCGLSObObjPlantGravOrb'+IntToStr(OrbitalObject3DIndex);
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].AntiAliased:=true;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Division:=8;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineColor.Color:=clrYellowGreen;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LinePattern:=LinePattern;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineWidth:=LineWidth;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].NodeSize:=0.005;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Nodes.Clear;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X:=
            (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
         if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_type
            in [ootAsteroid_Metallic..ootAsteroid_Icy]
         then FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X*6.42;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.Y:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.Z:=FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Scale.X;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Visible:=true;
         {.gravity well nodes generation}
         Xcenter:=0;
         Ycenter:=0;
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=Xcenter+OrbitWidth*cos(OBtheta);
            OByy:=Ycenter+OrbitHeight*sin(OBtheta);
            OBxxCen:=OBxx-Xcenter;
            OByyCen:=OByy-Ycenter;
            OBxRotated:=Xcenter+(OBxxCen)*RotationAngleCos-(OByyCen)*RotationAngleSin;
            OByRotated:=Ycenter+(OBxxCen)*RotationAngleSin+(OByyCen)*RotationAngleCos;
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
         FC3doglMainViewListSatelliteOrbits[OBsatCnt]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Name:='FCGLSsatOrb'+IntToStr(OBsatCnt);
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].AntiAliased:=true;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Division:=16;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].LineColor.Alpha:=1;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].LineColor.Color:=clrCornflowerBlue;//clrMidnightBlue;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].LinePattern:=LinePattern;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].LineWidth:=LineWidth;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].NodeSize:=0.005;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Nodes.Clear;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)/250000)));
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Scale.Y:=FC3doglMainViewListSatelliteOrbits[OBsatCnt].Scale.X;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Scale.Z:=FC3doglMainViewListSatelliteOrbits[OBsatCnt].Scale.X;
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].TurnAngle
            :=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_angle1stDay;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatelliteOrbits[OBsatCnt].Visible:=true;
         {.nodes generation}
         Xcenter:=0;
         Ycenter:=0;
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=90*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=Xcenter+OrbitWidth*cos(OBtheta);
            OByy:=Ycenter+OrbitHeight*sin(OBtheta);
            OBxxCen:=OBxx-Xcenter;
            OByyCen:=OByy-Ycenter;
            OBxRotated:=Xcenter+(OBxxCen)*RotationAngleCos-(OByyCen)*RotationAngleSin;
            OByRotated:=Ycenter+(OBxxCen)*RotationAngleSin+(OByyCen)*RotationAngleCos;
            FC3doglMainViewListSatelliteOrbits[OBsatCnt].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatelliteOrbits[OBsatCnt].StructureChanged;
            inc(OBcount);
         end;
         {.initialize gravity well orbit}
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt]:=TGLLines(FC3doglSatellitesObjectsGroups[OBsatCnt].AddNewChild(TGLLines));
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Name:='FCGLSsatGravOrb'+IntToStr(OBsatCnt);
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].AntiAliased:=true;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Division:=8;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].LineColor.Color:=clrGoldenrod;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].LinePattern:=LinePattern;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].LineWidth:=LineWidth;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].NodeColor.Color:=clrBlack;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].NodesAspect:=lnaInvisible;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].NodeSize:=0.005;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].SplineMode:=lsmCubicSpline;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Nodes.Clear;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X:=
            (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
         if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_type
            in [ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Icy]
         then FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X:=FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X*6.42;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.Y:=FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.Z:=FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X;
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].TurnAngle
            :=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_angle1stDay-0.25;
         RotationAngleCos:=cos(OBrotAngle);
         RotationAngleSin:=sin(OBrotAngle);
         FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Visible:=true;
         {.gravity well nodes generation}
         Xcenter:=0;
         Ycenter:=0;
         OBcount:=0;
         OBrotAngle:=DegToRad(0);
         while OBcount<=OrbitSegments do
         begin
            OBtheta:=360*(OBcount/OrbitSegments)*FCCdiDegrees_To_Radian;
            OBxx:=Xcenter+OrbitWidth*cos(OBtheta);
            OByy:=Ycenter+OrbitHeight*sin(OBtheta);
            OBxxCen:=OBxx-Xcenter;
            OByyCen:=OByy-Ycenter;
            OBxRotated:=Xcenter+(OBxxCen)*RotationAngleCos-(OByyCen)*RotationAngleSin;
            OByRotated:=Ycenter+(OBxxCen)*RotationAngleSin+(OByyCen)*RotationAngleCos;
            FC3doglMainViewListSatellitesGravityWells[OBsatCnt].Nodes.AddNode(
               OBxRotated
               ,0
               ,OByRotated
               );
            FC3doglMainViewListSatellitesGravityWells[OBsatCnt].StructureChanged;
            inc(OBcount);
         end;
      end; //==END== case OrbitType of: otSatellite ==//

      otSpaceUnit:
      begin
      end; //==END== case OrbitType of: otSpaceUnit ==//
   end; //==END== case OrbitType of ==//
end;

end.
