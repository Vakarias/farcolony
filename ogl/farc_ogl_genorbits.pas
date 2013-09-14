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
   OBsegments=40;
   OBwdth=90/100;
   OBheight=90/100;
var
   OBcount: integer;

   OBrotAngleCos
   ,OBrotAngleSin
   ,OBxCenter
   ,OByCenter
   ,OBtheta
   ,OBxx
   ,OBxxCen
   ,OByy
   ,OByyCen
   ,OBxRotated
   ,OByRotated
   ,OBrotAngle: extended;
begin
   if OrbitType=otPlanet then
   begin
      {.initialize root orbit}
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Name:='FCGLSObObjPlantOrb'+IntToStr(OrbitalObject3DIndex);
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].AntiAliased:=true;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Division:=16;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Alpha:=1;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Blue:=0.953;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Green:=0.576;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LineColor.Red:=0.478;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LinePattern:=65535;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].LineWidth:=1.5;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].NodeColor.Color:=clrBlack;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].NodesAspect:=lnaInvisible;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].NodeSize:=0.005;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].SplineMode:=lsmCubicSpline;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.Clear;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)*0.000004)));
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Y:=FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.Z:=FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Scale.X;
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].TurnAngle:=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_angle1stDay;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Visible:=true;
      {.nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=90*(OBcount/OBsegments)*FCCdiDegrees_To_Radian;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].Nodes.AddNode(OBxRotated, 0, OByRotated);
         FC3oglMainViewListMainOrbits[OrbitalObject3DIndex].StructureChanged;
         inc(OBcount);
      end;
      {.initialize gravity well orbit}
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Name:='FCGLSObObjPlantGravOrb'+IntToStr(OrbitalObject3DIndex);
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].AntiAliased:=true;
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Division:=8;
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineColor.Color:=clrYellowGreen;
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LinePattern:=65535;
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].LineWidth:=1.5;
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
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Visible:=true;
      {.gravity well nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=360*(OBcount/OBsegments)*FCCdiDegrees_To_Radian;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3doglMainViewListGravityWells[OrbitalObject3DIndex].StructureChanged;
         inc(OBcount);
      end;
   end //==END== if OBorbitType=oglvmotpPlanet ==//
   else if OrbitType=otSatellite
   then
   begin
      {.initialize root orbit}
      FC3oglMainViewListSatelliteOrbits[OBsatCnt]:=TGLLines(FC3doglObjectsGroups[OrbitalObject3DIndex].AddNewChild(TGLLines));
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Name:='FCGLSsatOrb'+IntToStr(OBsatCnt);
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].AntiAliased:=true;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Division:=16;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].LineColor.Alpha:=1;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].LineColor.Color:=clrCornflowerBlue;//clrMidnightBlue;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].LinePattern:=65535;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].LineWidth:=1.5;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].NodeColor.Color:=clrBlack;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].NodesAspect:=lnaInvisible;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].NodeSize:=0.005;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].SplineMode:=lsmCubicSpline;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Nodes.Clear;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)/250000)));
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Scale.Y:=FC3oglMainViewListSatelliteOrbits[OBsatCnt].Scale.X;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Scale.Z:=FC3oglMainViewListSatelliteOrbits[OBsatCnt].Scale.X;
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].TurnAngle
         :=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_angle1stDay;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3oglMainViewListSatelliteOrbits[OBsatCnt].Visible:=true;
      {.nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=90*(OBcount/OBsegments)*FCCdiDegrees_To_Radian;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3oglMainViewListSatelliteOrbits[OBsatCnt].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3oglMainViewListSatelliteOrbits[OBsatCnt].StructureChanged;
         inc(OBcount);
      end;
      {.initialize gravity well orbit}
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt]:=TGLLines(FC3doglSatellitesObjectsGroups[OBsatCnt].AddNewChild(TGLLines));
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Name:='FCGLSsatGravOrb'+IntToStr(OBsatCnt);
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].AntiAliased:=true;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Division:=8;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].LineColor.Color:=clrGoldenrod;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].LinePattern:=65535;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].LineWidth:=1.5;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].NodeColor.Color:=clrBlack;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].NodesAspect:=lnaInvisible;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].NodeSize:=0.005;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].SplineMode:=lsmCubicSpline;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Nodes.Clear;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X:=
         (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_gravitationalSphereRadius/(CFC3dUnInKm))*2;
      if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_type
         in [ootSatellite_Asteroid_Metallic..ootSatellite_Asteroid_Icy]
      then FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X:=FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X*6.42;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.Y:=FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.Z:=FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Scale.X;
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].TurnAngle
         :=-FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OrbitalObject3DIndex].OO_satellitesList[Satellite3DIndex].OO_angle1stDay-0.25;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Visible:=true;
      {.gravity well nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=360*(OBcount/OBsegments)*FCCdiDegrees_To_Radian;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3oglMainViewListSatellitesGravityWells[OBsatCnt].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3oglMainViewListSatellitesGravityWells[OBsatCnt].StructureChanged;
         inc(OBcount);
      end;
   end; //==END== if OBorbitType=oglvmotpSat ==//
end;

end.
