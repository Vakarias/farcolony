{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: 3d OpenGL - data unit

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
unit farc_data_3dopengl;

interface

uses
   GLAtmosphere
   ,GLMaterial
   ,GLObjects

   ,oxLib3dsMeshLoader;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

var
   //==========3d objects and components====================================================
   ///<summary>
   ///   material library for standard planetary textures
   ///</summary>
   FC3doglMaterialLibraryStandardPlanetTextures: TGLMaterialLibrary;

   ///<summary>
   ///   objects list for asteroids
   ///</summary>
   FC3doglAsteroids: array of TDGLib3dsStaMesh;

   ///<summary>
   ///   objects list for atmospheres
   ///</summary>
   FC3doglAtmospheres: array of TGLAtmosphere;

   ///<summary>
   ///   objects list for object groups
   ///</summary>
   FC3doglObjectsGroups: array of TGLDummyCube;

   ///<summary>
   ///   objects list for planets
   ///</summary>
   FC3doglPlanets: array of TGLSphere;

   ///<summary>
   ///   objects list for satellites
   ///</summary>
   FC3doglSatellites: array of TGLSphere;

   ///<summary>
   ///   objects list for satellites asteroids
   ///</summary>
   FC3doglSatellitesAsteroids: array of TDGLib3dsStaMesh;

   ///<summary>
   ///   objects list for satellites atmospheres
   ///</summary>
   FC3doglSatellitesAtmospheres: array of TGLAtmosphere;

   ///<summary>
   ///   objects list for satellites object groups
   ///</summary>
   FC3doglSatellitesObjectsGroups: array of TGLDummyCube;

   ///<summary>
   ///   objects list for space units, tag= faction id#, tagfloat= owned index
   ///</summary>
   FC3doglSpaceUnits: array of TDGLib3dsStaMesh;

   //==========3d data======================================================================
   ///<summary>
   ///   current star index of the 3d view
   ///</summary>
   FC3doglCurrentStar: integer;

   ///<summary>
   ///   current stellar system index of the 3d view
   ///</summary>
   FC3doglCurrentStarSystem: integer;

   ///<summary>
   ///   HR standard map (2048*1024) switch, false= 1024*512
   ///</summary>
   FC3doglHRstandardTextures: boolean;

   ///<summary>
   ///   3d object index of the selected main orbital object
   ///</summary>
   FC3doglSelectedPlanetAsteroid: integer;

   ///<summary>
   ///   3d object index of the selected satellite
   ///</summary>
   FC3doglSelectedSatellite: integer;

   ///<summary>
   ///   3d object index of the selected space unit
   ///</summary>
   FC3doglSelectedSpaceUnit: integer;

   ///<summary>
   ///   store data for initial size of the targeted space unit
   ///</summary>
   FC3doglSpaceUnitSize: extended;

   ///<summary>
   ///   total orbital objects created in the current 3d view w/o count central star and the satellites
   ///</summary>
   FC3doglTotalOrbitalObjects: integer;

   ///<summary>
   ///   total satellites created in the current 3d view
   ///</summary>
   FC3doglTotalSatellites: integer;

   ///<summary>
   ///   total space units created in the current 3d view
   ///</summary>
   FC3doglTotalSpaceUnits: integer;

   //==========main view data======================================================================
   ///<summary>
   ///   objects list for gravity wells
   ///</summary>
   FC3doglMainViewListGravityWells: array of TGLLines;

   ///<summary>
   ///   objects list for orbits
   ///</summary>
   FC3oglMainViewListMainOrbits: array of TGLLines;

   ///<summary>
   ///   objects list for satellites gravity wells
   ///</summary>
   FC3oglMainViewListSatellitesGravityWells: array of TGLLines;

   ///<summary>
   ///   objects list for satellites orbits
   ///</summary>
   FC3oglMainViewListSatelliteOrbits: array of TGLLines;


//==END PUBLIC VAR==========================================================================

const

   ///<summary>
   ///   used to reduce distance between orbital objects in the view but without affect the effects or secondary assets
   ///</summary>
   FC3doglCoefViewReduction=5.5;

//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
