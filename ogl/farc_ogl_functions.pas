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
///   <param name="PlanetPosition">central planet 3d position, if this data is unknown, use the othe one</param>
///   <returns>satellite's X, Y and Z in TFCRoglfPosition.</returns>
///   <remarks>100% compatible with satellites asteroids too</remarks>
function FCFoglF_Satellite_CalculatePosition(
   const DistanceFromPlanet
         ,Angle: extended;
         PlanetPosition: TFCRoglfPosition
   ): TFCRoglfPosition;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_init;
//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

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

//===========================END FUNCTIONS SECTION==========================================

end.
