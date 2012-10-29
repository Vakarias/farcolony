{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: OpenGL - functions unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2012, Jean-Francois Baconnet

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
unit farc_ogl_functions;

interface

//uses

type TFCEoglfObjectTypes=(
   otOrbitalObject
   ,otSatellite
   ,otSpaceUnit
   );

//==END PUBLIC ENUM=========================================================================

type TFCRoglfPosition=record
   P_x: extended;
   P_y: extended;
   P_z: extended;
end;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   calculate the distance between to objects in the 3d view
///</summary>
///   <param name="Origin">type of origin object</param>
///   <param name="OriginIndex">index of origin object, always in 3d index. 3d index= 3D space unit index, DB orbital object index (=3d index), 3D satellite object index (must be retrieved if required)</param>
///   <param name="Destination">type of destination object</param>
///   <param name="DestinationIndex">index of destination object, always in 3d index. 3d index= 3D space unit index, DB orbital object index (=3d index), 3D satellite object index (must be retrieved if required)</param>
///   <returns>distance in 3d units</returns>
///   <remarks>formatted [x.x9]</remarks>
function FCFoglF_DistanceBetweenTwoObjects_Calculate(
   const Origin: TFCEoglfObjectTypes;
   const OriginIndex: integer;
   const Destination: TFCEoglfObjectTypes;
   const DestinationIndex: integer
   ): extended;

///<summary>
///   calculate the distance between to objects in the 3d view
///</summary>
///   <param name="Origin">type of origin object</param>
///   <param name="OriginIndex">index of origin object, always in 3d index. 3d index= 3D space unit index, DB orbital object index (=3d index), 3D satellite object index (must be retrieved if required)</param>
///   <param name="Destination">type of destination object</param>
///   <param name="DestinationIndex">index of destination object, always in 3d index. 3d index= 3D space unit index, DB orbital object index (=3d index), 3D satellite object index (must be retrieved if required)</param>
///   <returns>distance in astronomical units (AU)</returns>
///   <remarks>formatted [x.x9]</remarks>
function FCFoglF_DistanceBetweenTwoObjects_CalculateInAU(
   const Origin: TFCEoglfObjectTypes;
   const OriginIndex: integer;
   const Destination: TFCEoglfObjectTypes;
   const DestinationIndex: integer
   ): extended;

///<summary>
///   calculate the position, in the 3d view, of an orbital object according to a given angle
///</summary>
///   <param name="DistanceFromStar">distance of the orbital object from its star, in AU</param>
///   <param name="Angle">orbital object's current seasonal angle</param>
///   <returns>orbital object's X, Y and Z in TFCRoglfPosition.</returns>
///   <remarks>100% compatible with asteroids too</remarks>
function FCFoglF_OrbitalObject_CalculatePosition(
   const DistanceFromStar
         ,Angle: extended
   ): TFCRoglfPosition;

///<summary>
///   calculate the position, in the 3d view, of a satellite according to a given angle
///</summary>
///   <param name="DistanceFromPlanet">distance of the satellite from its star, in thousands of kilometers</param>
///   <param name="Angle">satellite's current seasonal angle</param>
///   <param name="PlanetPosition">central planet 3d position, if this data is unknown, use the other one</param>
///   <returns>satellite's X, Y and Z in TFCRoglfPosition.</returns>
///   <remarks>100% compatible with satellites asteroids too</remarks>
function FCFoglF_Satellite_CalculatePosition(
   const DistanceFromPlanet
         ,Angle: extended;
         PlanetPosition: TFCRoglfPosition
   ): TFCRoglfPosition;

///<summary>
///   return the satellite object index of the choosen satellite in the current view. Satellite_SearchObject
///</summary>
function FCFoglF_Satellite_SearchObject(const SOSidxDBoob, SOSidxDBsat: integer): integer;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_univ;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFoglF_DistanceBetweenTwoObjects_Calculate(
   const Origin: TFCEoglfObjectTypes;
   const OriginIndex: integer;
   const Destination: TFCEoglfObjectTypes;
   const DestinationIndex: integer
   ): extended;
{:Purpose: calculate the distance between to objects in the 3d view.
    Additions:
}
   var
      DestinationGravitationalSphere
      ,DestinationX
      ,DestinationZ
      ,OriginGravitationalSphere
      ,OriginX
      ,OriginZ
      ,ProcessData: extended;

      DestinationDBPlanetIndex
      ,DestinationDBSatelliteIndex
      ,OriginDBPlanetIndex
      ,OriginDBSatelliteIndex: integer;
begin
   DestinationGravitationalSphere:=0;
   DestinationX:=0;
   DestinationZ:=0;
   OriginGravitationalSphere:=0;
   OriginX:=0;
   OriginZ:=0;
   ProcessData:=0;
   DestinationDBPlanetIndex:=0;
   DestinationDBSatelliteIndex:=0;
   OriginDBPlanetIndex:=0;
   OriginDBSatelliteIndex:=0;
   Result:=0;
   case Origin of
      otOrbitalObject:
      begin
         OriginX:=FC3doglObjectsGroups[OriginIndex].Position.X;
         OriginZ:=FC3doglObjectsGroups[OriginIndex].Position.Z;
         OriginGravitationalSphere:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OriginIndex].OO_gravitationalSphereRadius
            );
      end;

      otSatellite:
      begin
         OriginX:=FC3doglSatellitesObjectsGroups[OriginIndex].Position.X;
         OriginZ:=FC3doglSatellitesObjectsGroups[OriginIndex].Position.Z;
         OriginDBPlanetIndex:=round( FC3doglSatellitesObjectsGroups[OriginIndex].TagFloat );
         OriginDBSatelliteIndex:=FC3doglSatellitesObjectsGroups[OriginIndex].Tag;
         OriginGravitationalSphere:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[OriginDBPlanetIndex].OO_satellitesList[OriginDBSatelliteIndex].OO_gravitationalSphereRadius
            );
      end;

      otSpaceUnit:
      begin
         OriginX:=FC3doglSpaceUnits[OriginIndex].Position.X;
         OriginZ:=FC3doglSpaceUnits[OriginIndex].Position.Z;
      end;
   end; //==END== case Origin of ==//
   case Destination of
      otOrbitalObject:
      begin
         DestinationX:=FC3doglObjectsGroups[DestinationIndex].Position.X;
         DestinationZ:=FC3doglObjectsGroups[DestinationIndex].Position.Z;
         DestinationGravitationalSphere:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[DestinationIndex].OO_gravitationalSphereRadius
            );
      end;

      otSatellite:
      begin
         DestinationX:=FC3doglSatellitesObjectsGroups[DestinationIndex].Position.X;
         DestinationZ:=FC3doglSatellitesObjectsGroups[DestinationIndex].Position.Z;
         DestinationDBPlanetIndex:=round( FC3doglSatellitesObjectsGroups[DestinationIndex].TagFloat );
         DestinationDBSatelliteIndex:=FC3doglSatellitesObjectsGroups[DestinationIndex].Tag;
         DestinationGravitationalSphere:=FCFcFunc_ScaleConverter(
            cf3dctKmTo3dViewUnit
            ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[DestinationDBPlanetIndex].OO_satellitesList[DestinationDBSatelliteIndex].OO_gravitationalSphereRadius
            );
      end;

      otSpaceUnit:
      begin
         DestinationX:=FC3doglSpaceUnits[DestinationIndex].Position.X;
         DestinationZ:=FC3doglSpaceUnits[DestinationIndex].Position.Z;
      end;
   end;
   ProcessData:=sqrt( sqr( OriginX-DestinationX )+sqr( OriginZ-DestinationZ ) )-( OriginGravitationalSphere+DestinationGravitationalSphere );
   Result:=FCFcFunc_Rnd( rtt3dposition, ProcessData );
end;

function FCFoglF_DistanceBetweenTwoObjects_CalculateInAU(
   const Origin: TFCEoglfObjectTypes;
   const OriginIndex: integer;
   const Destination: TFCEoglfObjectTypes;
   const DestinationIndex: integer
   ): extended;
{:Purpose: calculate the distance between to objects in the 3d view.
    Additions:
}
   var
      DataProcess: extended;
begin
   DataProcess:=0;
   Result:=0;
   DataProcess:=FCFoglF_DistanceBetweenTwoObjects_Calculate(
      Origin
      ,OriginIndex
      ,Destination
      ,DestinationIndex
      );
   Result:=FCFcFunc_ScaleConverter( cf3dct3dViewUnitToAU, DataProcess )
end;

function FCFoglF_OrbitalObject_CalculatePosition(
   const DistanceFromStar
         ,Angle: extended
   ): TFCRoglfPosition;
{:Purpose: calculate the position, in the 3d view, of an orbital object according to a given angle.
    Additions:
}
   var
      AngleInRad
      ,DistanceInUnits
      ,ProcessingData: extended;
begin
   AngleInRad:=0;
   DistanceInUnits:=0;
   ProcessingData:=0;
   Result.P_x:=0;
   Result.P_y:=0;
   Result.P_z:=0;
   AngleInRad:=Angle*FCCdiDegrees_To_Radian;
   DistanceInUnits:=FCFcFunc_ScaleConverter( cf3dctAUto3dViewUnit, DistanceFromStar );
   ProcessingData:=cos( AngleInRad )*DistanceInUnits;
   Result.P_x:=FCFcFunc_Rnd( rtt3dposition, ProcessingData );
   Result.P_y:=0;
   ProcessingData:=sin( AngleInRad )*DistanceInUnits;
   Result.P_z:=FCFcFunc_Rnd( rtt3dposition, ProcessingData );
end;

function FCFoglF_Satellite_CalculatePosition(
   const DistanceFromPlanet
         ,Angle: extended;
         PlanetPosition: TFCRoglfPosition
   ): TFCRoglfPosition;
{:Purpose: calculate the position, in the 3d view, of a satellite according to a given angle.
    Additions:
}
   var
      AngleInRad
      ,DistanceInUnits
      ,ProcessingData: extended;
begin
   AngleInRad:=0;
   DistanceInUnits:=0;
   ProcessingData:=0;
   Result.P_x:=0;
   Result.P_y:=0;
   Result.P_z:=0;
   AngleInRad:=Angle*FCCdiDegrees_To_Radian;
   DistanceInUnits:=FCFcFunc_ScaleConverter( cf3dctKmTo3dViewUnit, DistanceFromPlanet*1000 );
   ProcessingData:=PlanetPosition.P_x+( cos( AngleInRad )*DistanceInUnits );
   Result.P_x:=FCFcFunc_Rnd( rtt3dposition, ProcessingData );
   Result.P_y:=0;
   ProcessingData:=PlanetPosition.P_z+( sin( AngleInRad )*DistanceInUnits );
   Result.P_z:=FCFcFunc_Rnd( rtt3dposition, ProcessingData );
end;

function FCFoglF_Satellite_SearchObject(const SOSidxDBoob, SOSidxDBsat: integer): integer;
{:Purpose: return the satellite object index of the choosen satellite in the current view.
    Additions:
}
var
   SOSdmpObjIdx
   ,SOSdmpSatObjIdx
   ,SOScnt
   ,SOSttl: integer;
begin
   SOSdmpObjIdx:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[SOSidxDBoob].OO_isNotSat_1st3dObjectSatelliteIndex;
   SOSdmpSatObjIdx:=0;
   SOScnt:=1;
   SOSttl:=length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[SOSidxDBoob].OO_satellitesList)-1;
   Result:=0;
   while SOScnt<=SOSttl do
   begin
      SOSdmpSatObjIdx:=SOSdmpObjIdx+SOScnt-1;
      if FC3doglSatellitesObjectsGroups[SOSdmpSatObjIdx].Tag=SOSidxDBsat
      then
      begin
         Result:=SOSdmpSatObjIdx;
         Break;
      end;
      inc(SOScnt);
   end;
end;

//===========================END FUNCTIONS SECTION==========================================

end.
