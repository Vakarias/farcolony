{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: contains all opengl initializations for all windows

============================================================================================
********************************************************************************************
Copyright (c) 2009-2011, Jean-Francois Baconnet

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

unit farc_ogl_init;

interface

uses
   BaseClasses,
   GLColor,
   GLGraphics,
   GLMaterial,
   GLRenderContextInfo,
   GLScene,
   GLState,
   GLTexture,
   GLTextureFormat;

///<summary>initialize data of all OpenGL components in FARC</summary>
procedure FCMoglInit_Initialize;

///<summary>
///   switch HR/SR standard textures sets
///</summary>
procedure FCMoglInit_StdText_Set(const STSisHR, STSforceLoad: boolean);

///<summary>
///   return the standard library index given library name
///</summary>
///    <param name="STNGname">standard library name</param>
function FCFoglInit_StdTexIdx_Get(const STIGname: string): integer;

implementation

uses
   farc_data_files
   ,farc_data_init
   ,farc_main
   ,farc_ogl_ui
   ,farc_ui_win;

//=============================================END OF INIT==================================

function FCFoglInit_StdTexName_Get(const STNGidx: integer): string;
{:Purpose: return the standard texture library name given library index #.
    Additions:
}
var
   STNGdmpRes: string;
begin
   STNGdmpRes:='';
   case STNGidx of
      0: STNGdmpRes:='MercuryH0';
      1: STNGdmpRes:='MercuryH3';
      2: STNGdmpRes:='MercuryH4';
      3: STNGdmpRes:='Pluto';
      4: STNGdmpRes:='Europa';
      5: STNGdmpRes:='CallistoH3';
      6: STNGdmpRes:='CallistoH4';
      7: STNGdmpRes:='UranusCold';
      8: STNGdmpRes:='UranusHot';
      9: STNGdmpRes:='NeptuneCold';
      10: STNGdmpRes:='NeptuneHot';
      11: STNGdmpRes:='SaturnCold';
      12: STNGdmpRes:='SaturnHot';
      13: STNGdmpRes:='JovianCold';
      14: STNGdmpRes:='JovianHot';
      15: STNGdmpRes:='SuperGiantCold';
      16: STNGdmpRes:='SuperGiantHot';
      17: STNGdmpRes:='SatLunarCold';
      18: STNGdmpRes:='SatLunar';
      19: STNGdmpRes:='SatIo';
      20: STNGdmpRes:='SatPluto';
      21: STNGdmpRes:='SatEuropa';
      22: STNGdmpRes:='SatCallistoH3';
      23: STNGdmpRes:='SatCallistoH4';
   end; //==END== case STNGidx ==//
   Result:= STNGdmpRes;
end;

procedure FCMoglInit_Initialize;
{:Purpose: initialize data of all OpenGL components in FARC.
    Additions:
      -2011Apr09- *add: hud space unit capability - docking.
      -2010Jul18- *add: hud tags.
      -2010Jan11- *mod: extract some code part to functions.
      -2010Jan05- *add: FC3DmatLibSplanT completion.
      -2010Jan04- *add: create and initialize the FC3DmatLibSplanT.
      -2009Dec08- *change near basic plane bias.
      -2009Aug27- *add smooth navigator from main view.
      -2009Aug26- *add camera ghost from main view.
      -2009Aug25- *correction of main view camera control settings.
      -2009Aug24- *main view central star finished.
                  *main view starlight added.
}
var
   OGLIIcnt: integer;
   OGLIIname: string;
begin
   {.main view root object}
   FCWinMain.FCGLSRootMain.ObjectsSorting:=osRenderBlendedLast;
   FCWinMain.FCGLSRootMain.VisibilityCulling:=vcNone;
   {.main view camera}
   FCWinMain.FCGLSCamMainView.CameraStyle:=csInfinitePerspective;
   FCWinMain.FCGLSCamMainView.DepthOfView:=16000;
   FCWinMain.FCGLSCamMainView.FocalLength:=90;
   FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
   {.main view camera ghost}
   FCWinMain.FCGLSCamMainViewGhost.CameraStyle:=csPerspective;
   FCWinMain.FCGLSCamMainViewGhost.DepthOfView:=100;
   FCWinMain.FCGLSCamMainViewGhost.FocalLength:=50;
   FCWinMain.FCGLSCamMainViewGhost.NearPlaneBias:=1;
   {.main view central star}
   FCWinMain.FCGLSStarMain.Height:=1;
   FCWinMain.FCGLSStarMain.Material.BackProperties.Ambient.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.BackProperties.Diffuse.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.BackProperties.Emission.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.BackProperties.PolygonMode:=pmFill;
   FCWinMain.FCGLSStarMain.Material.BackProperties.Shininess:=0;
   FCWinMain.FCGLSStarMain.Material.BackProperties.Specular.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.Ambient.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.Diffuse.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.Emission.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.PolygonMode:=pmFill;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.Shininess:=0;
   FCWinMain.FCGLSStarMain.Material.FrontProperties.Specular.Color:=clrTransparent;
   FCWinMain.FCGLSStarMain.Material.BlendingMode:=bmAlphaTest50;
   FCWinMain.FCGLSStarMain.Material.FaceCulling:=fcNoCull;
   FCWinMain.FCGLSStarMain.Material.Texture.FilteringQuality:=tfIsotropic;
   FCWinMain.FCGLSStarMain.Material.Texture.ImageAlpha:=tiaTopLeftPointColorTransparent;
   FCWinMain.FCGLSStarMain.Material.Texture.ImageBrightness:=1;
   FCWinMain.FCGLSStarMain.Material.Texture.MagFilter:=maLinear;
   FCWinMain.FCGLSStarMain.Material.Texture.MappingMode:=tmmUser;
   FCWinMain.FCGLSStarMain.Material.Texture.MinFilter:=miLinear;
   FCWinMain.FCGLSStarMain.Material.Texture.NormalMapScale:=0.125;
   FCWinMain.FCGLSStarMain.Material.Texture.TextureFormat:=tfDefault;
   FCWinMain.FCGLSStarMain.Material.Texture.TextureMode:=tmReplace;
   FCWinMain.FCGLSStarMain.Material.Texture.TextureWrap:=twNone;
   FCWinMain.FCGLSStarMain.Material.Texture.Disabled:=false;
   FCWinMain.FCGLSStarMain.MirrorU:=false;
   FCWinMain.FCGLSStarMain.MirrorV:=false;
   FCWinMain.FCGLSStarMain.ObjectsSorting:=osInherited;
   FCWinMain.FCGLSStarMain.Scale.X:=1;
   FCWinMain.FCGLSStarMain.Scale.Y:=1;
   FCWinMain.FCGLSStarMain.Scale.Z:=1;
   FCWinMain.FCGLSStarMain.VisibilityCulling:=vcInherited;
   FCWinMain.FCGLSStarMain.Width:=1;
   {.main view starlight}
   FCWinMain.FCGLSSM_Light.Ambient.Color:=clrBlack;
   FCWinMain.FCGLSSM_Light.ConstAttenuation:=1;
   FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
   FCWinMain.FCGLSSM_Light.LightStyle:=lsSpot;
   FCWinMain.FCGLSSM_Light.Shining:=true;
   FCWinMain.FCGLSSM_Light.Specular.Color:=clrBlack;
   FCWinMain.FCGLSSM_Light.SpotCutOff:=180;
   {.main view smooth navigator}
   FCWinMain.FCGLSsmthNavMainV.MovingObject := FCWinMain.FCGLSCamMainViewGhost;
   {.main view user's interface}
   FCMoglUI_Main3DViewUI_Update(oglupdtpLocOnly,ogluiutAll);
   {.material library for standard planetary textures}
   FC3DmatLibSplanT:=TGLMaterialLibrary.Create(FCWinMain);
   FC3DmatLibSplanT.Name:='FCGLSmlibSPT';
   OGLIIcnt:=0;
   while OGLIIcnt<=23 do
   begin
      FC3DmatLibSplanT.Materials.Add;
      OGLIIname:=FCFoglInit_StdTexName_Get(OGLIIcnt);
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Name:=OGLIIname;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Ambient.Color:=clrGray20;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Diffuse.Color:=clrGray80;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Emission.Color:=clrBlack;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.PolygonMode:=pmFill;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Shininess:=0;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Specular.Color:=clrBlack;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BlendingMode:=bmOpaque;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FaceCulling:=fcBufferDefault;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FrontProperties.Ambient:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Ambient;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FrontProperties.Diffuse:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Diffuse;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FrontProperties.Emission:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Emission;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.PolygonMode:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.PolygonMode;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FrontProperties.Shininess:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Shininess;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.FrontProperties.Specular:=FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.BackProperties.Specular;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.MaterialOptions:=[];
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.BorderColor.Color:=clrTransparent;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.Compression:=tcNone;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.DepthTextureMode:=dtmLuminance;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.Disabled:=false;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.EnvColor.Color:=clrTransparent;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.FilteringQuality:=tfIsotropic;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.ImageAlpha:=tiaDefault;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.ImageGamma:=1;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.MagFilter:=maLinear;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.MappingMode:=tmmUser;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.MinFilter:=miNearestMipmapLinear;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.NormalMapScale:=0.45;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureCompareFunc:=cfEqual;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureCompareMode:=tcmNone;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureFormat:=tfDefault;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureMode:=tmModulate;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureWrap:=twBoth;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureWrapS:=twRepeat;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureWrapT:=twRepeat;
      FC3DmatLibSplanT.Materials.Items[OGLIIcnt].Material.Texture.TextureWrapR:=twRepeat;
      inc(OGLIIcnt);
   end; //==END== while OGLIIcnt<=23 ==//
   FCMoglInit_StdText_Set(FCV3DstdTresHR, true);
   {.tags}
   {:DEV NOTES: update also FCMoglUI_Elem_SelHelp.}
   {:DEV NOTES: orbital object data: 1-100, star data: 101-200, space unit data: 201-300, CPS data: 301-400.}
   {.orbital object albedo}
   FCWinMain.FCGLSHUDobobjAlbeLAB.Tag:=1;
   FCWinMain.FCGLSHUDobobjAlbe.Tag:=1;
   {.orbital object distance}
   FCWinMain.FCGLSHUDobobjDistLAB.Tag:=2;
   FCWinMain.FCGLSHUDobobjDist.Tag:=2;
   {.orbital object eccentricity}
   FCWinMain.FCGLSHUDobobjEccLAB.Tag:=3;
   FCWinMain.FCGLSHUDobobjDist.Tag:=3;
   {.star temperature}
   FCWinMain.FCGLSHUDstarTempLAB.Tag:=101;
   FCWinMain.FCGLSHUDstarTemp.Tag:=101;
   {.space unit hud capabilities}
   FCWinMain.FCGLSHUDspunDockd.Material.Texture.Image.LoadFromFile(FCVpathRsrc+'pics-ui-spu\spucapab_docking.jpg');
end;

procedure FCMoglInit_StdText_Set(const STSisHR, STSforceLoad: boolean);
{:Purpose: switch HR/SR standard textures sets.
    Additions:
}
var
   STSisLoad: boolean;
   STScnt: integer;
   STSmatStr
   ,STSmatRes: string;
begin
   STSisLoad:=false;
   if (STSisHR)
      and (not FCV3DstdTresHR)
   then
   begin
      FCV3DstdTresHR:=true;
      FCMuiWin_UI_Upd(mwupMenuStex);
      FCMdF_ConfigFile_Write(false);
      STSisLoad:=true;
   end
   else if (not STSisHR)
      and (FCV3DstdTresHR)
   then
   begin
      FCV3DstdTresHR:=false;
      FCMuiWin_UI_Upd(mwupMenuStex);
      FCMdF_ConfigFile_Write(false);
      STSisLoad:=true;
   end;
   {.reload the choosen textures set if needed}
   if ((STSisLoad) or ((not STSisLoad) and (STSforceLoad)))
      and (FC3DmatLibSplanT<>nil)
   then
   begin
      if FCV3DstdTresHR
      then STSmatRes:='2048'
      else if not FCV3DstdTresHR
      then STSmatRes:='1024';
      STScnt:=0;
      while STScnt<=23 do
      begin
         STSmatStr:=FCFoglInit_StdTexName_Get(STScnt);
         FC3DmatLibSplanT.Materials.Items[STScnt].Material.Texture.Image.LoadFromFile
            (FCVpathRsrc+'pics-ogl-oobj-std\'+STSmatRes+'_'+STSmatStr+'.jpg');
         inc(STScnt)
      end;
   end; //==END== if STSisLoad ==//
end;

function FCFoglInit_StdTexIdx_Get(const STIGname: string): integer;
{:Purpose: return the standard library index given library name.
    Additions:
}
var
   STIGdmpRes: integer;
begin
   STIGdmpRes:=-1;
   if STIGname='MercuryH0'
   then STIGdmpRes:=0
   else if STIGname='MercuryH3'
   then STIGdmpRes:=1
   else if STIGname='MercuryH4'
   then STIGdmpRes:=2
   else if STIGname='Pluto'
   then STIGdmpRes:=3
   else if STIGname='Europa'
   then STIGdmpRes:=4
   else if STIGname='CallistoH3'
   then STIGdmpRes:=5
   else if STIGname='CallistoH4'
   then STIGdmpRes:=6
   else if STIGname='UranusCold'
   then STIGdmpRes:=7
   else if STIGname='UranusHot'
   then STIGdmpRes:=8
   else if STIGname='NeptuneCold'
   then STIGdmpRes:=9
   else if STIGname='NeptuneHot'
   then STIGdmpRes:=10
   else if STIGname='SaturnCold'
   then STIGdmpRes:=11
   else if STIGname='SaturnHot'
   then STIGdmpRes:=12
   else if STIGname='JovianCold'
   then STIGdmpRes:=13
   else if STIGname='JovianHot'
   then STIGdmpRes:=14
   else if STIGname='SuperGiantCold'
   then STIGdmpRes:=15
   else if STIGname='SuperGiantHot'
   then STIGdmpRes:=16
   else if STIGname='SatLunarCold'
   then STIGdmpRes:=17
   else if STIGname='SatLunar'
   then STIGdmpRes:=18
   else if STIGname='SatIo'
   then STIGdmpRes:=19
   else if STIGname='SatPluto'
   then STIGdmpRes:=20
   else if STIGname='SatEuropa'
   then STIGdmpRes:=21
   else if STIGname='SatCallistoH3'
   then STIGdmpRes:=22
   else if STIGname='SatCallistoH4'
   then STIGdmpRes:=23;
   Result:= STIGdmpRes;
end;

end.
