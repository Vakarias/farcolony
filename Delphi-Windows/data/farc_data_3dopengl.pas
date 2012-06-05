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
   //==========3d related===================================================================
   {.material library for standard planetary textures}
   FC3DmatLibSplanT: TGLMaterialLibrary;
   {.objects list for asteroids}
   FC3DobjAster: array of TDGLib3dsStaMesh;
   {.dump asteroid}
   FC3DobjAsterDmp: TDGLib3dsStaMesh;
   {.objects list for atmospheres}
   FC3DobjAtmosph: array of TGLAtmosphere;
   {.objects list for object groups}
   FC3DobjGrp: array of TGLDummyCube;
   {.objects list for gravity well}
   FC3DobjPlanGrav: array of TGLLines;
   {.objects list for orbits}
   FC3DobjPlanOrbit: array of TGLLines;
   {.objects list for planets}
   FC3DobjPlan: array of TGLSphere;
   {.objects list for satellite / asteroids}
   FC3DobjSatAster: array of TDGLib3dsStaMesh;
   {.objects list for satellite atmospheres}
   FC3DobjSatAtmosph: array of TGLAtmosphere;
   {.objects list for object satellite groups}
   FC3DobjSatGrp: array of TGLDummyCube;
   {.objects list for satellite gravity well}
   FC3DobjSatGrav: array of TGLLines;
   {.objects list for satellite orbits}
   FC3DobjSatOrbit: array of TGLLines;
   {.objects list for satellites}
   FC3DobjSat: array of TGLSphere;
   {.objects list for space units, tag= faction id#, tagfloat= owned index}
   FC3DobjSpUnit: array of TDGLib3dsStaMesh;//TGLFile3DSFreeForm;
   {.index which target selected object}
   FCV3DselOobj: integer;
   {.index which target selected satellite}
   FCV3DselSat: integer;
   {.index of targeted space unit}
   FCV3DselSpU: integer;
   {.selected stellar system for 3d view, related to FCRplayer}
   FCV3DselSsys: integer;
   {.selected star for 3d view, related to FCRplayer}
   FCV3DselStar: integer;
   {.total orbital object created in current 3d main view w/o count central star}
   FCV3DttlOobj: integer;
   {.total satellites the linked orbital object have}
   FCV3DttlSat: integer;
   {.total space units created in current 3d main view}
   FCV3DttlSpU: integer;
   {.HR standard map (2048*1024) switch, false= 1024*512}
   FCV3DstdTresHR: boolean;
   {.store data for intial size of a targeted space unit}
   FCV3DspUnSiz: extended;
//==END PUBLIC VAR==========================================================================

//const
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
