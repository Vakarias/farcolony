{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FARC Universe Generator (FUG) window

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

unit farc_win_fug;

interface

uses
   Controls
   ,Forms
   ,Messages
   ,SysUtils
   ,Windows, StdCtrls, Classes, AdvMemo, AdvPageControl, ComCtrls, ExtCtrls,

   AdvGlowButton
   ,AdvGroupBox, AdvCombo, htmlbtns;

type
   TFCWinFUG = class(TForm)
    WF_XMLOutput: TAdvMemo;
    WF_ConfigurationMultiTab: TAdvPageControl;
    CMT_TabStellarStarSystem: TAdvTabSheet;
      TSSS_StellarStarSysGroup: TAdvGroupBox;
         SSSG_StellarSysToken: TLabeledEdit;
         SSSG_LocationX: TLabeledEdit;
         SSSG_LocationY: TLabeledEdit;
         SSSG_LocationZ: TLabeledEdit;
    CMT_TabMainStar: TAdvGroupBox;
      TMS_StarToken: TLabeledEdit;
      TMS_StarDiam: TLabeledEdit;
      TMS_StarMass: TLabeledEdit;
      TMS_StarLum: TLabeledEdit;
      TMS_StarClass: TAdvComboBox;
      TMS_StarClassLabel: TLabel;
      TMS_SystemType: TAdvComboBox;
      TMS_SystemTypeLabel: TLabel;
      TMS_OrbitGeneration: THTMLRadioGroup;
      TMS_OrbitGenerationNumberOrbits: TLabeledEdit;
      TMS_StarTemp: TLabeledEdit;
    CMT_TabCompanion1Star: TAdvGroupBox;
      TC1S_EnableGroupCompanion1: TCheckBox;
      TC1S_StarToken: TLabeledEdit;
      TC1S_StarDiam: TLabeledEdit;
      TC1S_StarMass: TLabeledEdit;
      TC1S_StarLum: TLabeledEdit;
      TC1S_StarClass: TAdvComboBox;
      TC1S_SystemType: TAdvComboBox;
      TC1S_OrbitGeneration: THTMLRadioGroup;
      TC1S_OrbitGenerationNumberOrbits: TLabeledEdit;
      TC1S_StarTemp: TLabeledEdit;
    CMT_TabCompanion2Star: TAdvGroupBox;
      TC2S_EnableGroupCompanion2: TCheckBox;
      TC2S_StarToken: TLabeledEdit;
      TC2S_StarDiam: TLabeledEdit;
      TC2S_StarMass: TLabeledEdit;
      TC2S_StarLum: TLabeledEdit;
      TC2S_StarClass: TAdvComboBox;
      TC2S_SystemType: TAdvComboBox;
      TC2S_OrbitGeneration: THTMLRadioGroup;
      TC2S_OrbitGenerationNumberOrbits: TLabeledEdit;
      TC2S_StarTemp: TLabeledEdit;
    WF_ConfigurationMainTitle: TLabel;



    WF_GenerateButton: TAdvGlowButton;






    Label5: TLabel;
    Label6: TLabel;



    Label7: TLabel;
    Label8: TLabel;

    AdvGlowButton1: TAdvGlowButton;
    procedure WF_GenerateButtonClick(Sender: TObject);
    procedure TMS_OrbitGenerationClick(Sender: TObject);
    procedure TC1S_EnableGroupCompanion1Click(Sender: TObject);
    procedure TC2S_EnableGroupCompanion2Click(Sender: TObject);
    procedure TMS_SystemTypeChange(Sender: TObject);
    procedure TC1S_SystemTypeChange(Sender: TObject);
    procedure TC2S_SystemTypeChange(Sender: TObject);
    procedure AdvGlowButton1Click(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
   end;

var
   FCWinFUG: TFCWinFUG;

implementation

uses
   farc_common_func//to remove when FCFcFunc_Star_GetClass is moved
   ,farc_data_univ
   ,farc_fug_com
   ,farc_fug_data
   ,farc_fug_orbits
   ,farc_fug_stars;

//=======================================END OF INIT========================================

{$R *.dfm}

procedure TFCWinFUG.WF_GenerateButtonClick(Sender: TObject);
var
   Count
   ,Count1
   ,Max1: integer;

   DumpString: string;
begin
   if (SSSG_StellarSysToken.Text<>'stelsys')
      and (SSSG_LocationX.Text<>'')
      and (SSSG_LocationY.Text<>'')
      and (SSSG_LocationZ.Text<>'')
      and (TMS_StarToken.Text<>'') then
   begin
      {.FUG start process}
      FCDduStarSystem[0].SS_token:=SSSG_StellarSysToken.Text;
      FCDduStarSystem[0].SS_locationX:=StrToFloat(SSSG_LocationX.Text);
      FCDduStarSystem[0].SS_locationY:=StrToFloat(SSSG_LocationY.Text);
      FCDduStarSystem[0].SS_locationZ:=StrToFloat(SSSG_LocationZ.Text);
      FCRfdStarOrbits[1]:=-1;
      FCRfdStarOrbits[2]:=-1;
      FCRfdStarOrbits[3]:=-1;
      FCRfdSystemType[1]:=0;
      FCRfdSystemType[2]:=0;
      FCRfdSystemType[3]:=0;
      {.stars}
      FCMfS_Data_Load(1);
      FCDduStarSystem[0].SS_stars[1].S_token:=TMS_StarToken.Text;
      FCDduStarSystem[0].SS_stars[1].S_class:=TFCEduStarClasses(TMS_StarClass.ItemIndex);
      if TMS_StarTemp.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=FCFfS_Temperature_Calc(1)
      else if TMS_StarTemp.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=StrToInt(TMS_StarTemp.Text);
      if TMS_StarMass.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=FCFfS_Mass_Calc(1)
      else if TMS_StarMass.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=StrToInt(TMS_StarMass.Text);
      if TMS_StarDiam.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=FCFfS_Diameter_Calc(1)
      else if TMS_StarDiam.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=StrToFloat(TMS_StarDiam.Text);
      if TMS_StarLum.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=FCFfS_Luminosity_Calc(1)
      else if TMS_StarLum.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=StrToFloat(TMS_StarLum.Text);
      FCRfdSystemType[1]:=TMS_SystemType.ItemIndex+1;
      FCRfdStarOrbits[1]:=TMS_OrbitGeneration.ItemIndex-1;
      if FCRfdStarOrbits[1]=1
      then FCRfdStarOrbits[1]:=StrToInt(TMS_OrbitGenerationNumberOrbits.Text);
      if (CMT_TabCompanion1Star.Visible)
         and (TC1S_StarToken.Text<>'star')
      then
      begin
         FCDduStarSystem[0].SS_stars[2].S_token:=TC1S_StarToken.Text;
         FCDduStarSystem[0].SS_stars[2].S_class:=TFCEduStarClasses(TC1S_StarClass.ItemIndex);
         if TC1S_StarTemp.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=FCFfS_Temperature_Calc(2)
         else if TC1S_StarTemp.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=StrToInt(TC1S_StarTemp.Text);
         if TC1S_StarMass.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=FCFfS_Mass_Calc(2)
         else if TC1S_StarMass.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=StrToInt(TC1S_StarMass.Text);
         if TC1S_StarDiam.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=FCFfS_Diameter_Calc(2)
         else if TC1S_StarDiam.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=StrToFloat(TC1S_StarDiam.Text);
         if TC1S_StarLum.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=FCFfS_Luminosity_Calc(2)
         else if TC1S_StarLum.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=StrToFloat(TC1S_StarLum.Text);
         FCMfS_CompStar_Calc(2);
         FCRfdSystemType[2]:=TC1S_SystemType.ItemIndex+1;
         FCRfdStarOrbits[2]:=TC1S_OrbitGeneration.ItemIndex-1;
         if FCRfdStarOrbits[2]=1
         then FCRfdStarOrbits[2]:=StrToInt(TC1S_OrbitGenerationNumberOrbits.Text);
         if (CMT_TabCompanion2Star.Visible)
            and (TC2S_StarToken.Text<>'star')
         then
         begin
            FCDduStarSystem[0].SS_stars[3].S_token:=TC2S_StarToken.Text;
            FCDduStarSystem[0].SS_stars[3].S_class:=TFCEduStarClasses(TC2S_StarClass.ItemIndex);
            if TC2S_StarTemp.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=FCFfS_Temperature_Calc(3)
            else if TC2S_StarTemp.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=StrToInt(TC2S_StarTemp.Text);
            if TC2S_StarMass.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=FCFfS_Mass_Calc(3)
            else if TC2S_StarMass.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=StrToInt(TC2S_StarMass.Text);
            if TC2S_StarDiam.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=FCFfS_Diameter_Calc(3)
            else if TC2S_StarDiam.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=StrToFloat(TC2S_StarDiam.Text);
            if TC2S_StarLum.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=FCFfS_Luminosity_Calc(3)
            else if TC2S_StarLum.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=StrToFloat(TC2S_StarLum.Text);
            FCMfS_CompStar_Calc(3);
            FCRfdSystemType[3]:=TC2S_SystemType.ItemIndex+1;
            FCRfdStarOrbits[3]:=TC1S_OrbitGeneration.ItemIndex-1;
            if FCRfdStarOrbits[3]=1
            then FCRfdStarOrbits[3]:=StrToInt(TC1S_OrbitGenerationNumberOrbits.Text);

         end;
      end;
      {.generate the orbital objects}
      if ( FCRfdSystemType[1]<4 )
         and ( FCRfdStarOrbits[1]>-1 )
      then FCMfO_Generate(1);
      if (FCDduStarSystem[0].SS_stars[2].S_token<>'')
         and (FCRfdSystemType[2]<4)
         and ( FCRfdStarOrbits[2]>-1 )
      then FCMfO_Generate(2);
      if (FCDduStarSystem[0].SS_stars[3].S_token<>'')
         and (FCRfdSystemType[3]<4)
         and ( FCRfdStarOrbits[3]>-1 )
      then FCMfO_Generate(3);
      {.generate ouput}
      WF_XMLOutput.Lines.Clear;
      WF_XMLOutput.Lines.Add('===============================================');
      WF_XMLOutput.Lines.Add('===============================================');
      {.for stellar system}
      WF_XMLOutput.Lines.Add('<!-- -->');
      WF_XMLOutput.Lines.Add(
         '<starsys sstoken="'+FCDduStarSystem[0].SS_token+'" steslocx="'
         +SSSG_LocationX.Text+'" steslocy="'+SSSG_LocationY.Text+'" steslocz="'+SSSG_LocationZ.Text+'">'
         );
      {.for stars}
      Count:=1;
      while Count<=3 do
      begin
         if FCDduStarSystem[0].SS_stars[Count].S_token=''
         then break
         else begin
            DumpString:=FCFcFunc_Star_GetClass(cdfRaw, 0, Count);
            WF_XMLOutput.Lines.Add('   <star startoken="'+FCDduStarSystem[0].SS_stars[Count].S_token+'" starclass="'+DumpString+'">');
            WF_XMLOutput.Lines.Add(
               '      <starphysdata startemp="'+IntToStr(FCDduStarSystem[0].SS_stars[Count].S_temperature)
               +'" starmass="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_mass)
               +'" stardiam="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_diameter)
               +'" starlum="'+FloatToStrF(FCDduStarSystem[0].SS_stars[Count].S_luminosity, ffFixed, 15, 5)+'"'
               +'/>'
               );
            if Count=2 then
            begin
               WF_XMLOutput.Lines.Add(
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
                  +'"/>'
                  );
            end
            else if Count=3 then
            begin
               case FCDduStarSystem[0].SS_stars[Count].S_isCompStar2OrbitType of
                  cotAroundMain_Companion1: DumpString:='cotAroundMain_Companion1';
                  cotAroundCompanion1: DumpString:='cotAroundCompanion1';
                  cotAroundMain_Companion1GravityCenter: DumpString:='cotAroundMain_Companion1GravityCenter';
               end;
               WF_XMLOutput.Lines.Add(
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
                  +'" comporb="'+DumpString+'"'
                  +'/>'
                  );
            end;
            {.orbital objects}
            Max1:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects ) - 1;
            Count1:=1;
            while Count1<=Max1 do
            begin
               WF_XMLOutput.Lines.Add( '      <orbobj ootoken="'+FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_dbTokenId+'" ftSeed="">' );
               case FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_orbitalZone of
                  hzInner: DumpString:='hzInner';

                  hzIntermediary: DumpString:='hzIntermediary';

                  hzOuter: DumpString:='hzOuter';
               end;
               WF_XMLOutput.Lines.Add(
                  '         <orbobjorbdata oodist="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_distanceFromStar )
                     +'" ooecc="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_eccentricity )
                     +'" ooorbzne="'+DumpString
                     +'" oorevol="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriod )
                     +'" oorevevinit="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriodInit )
                     +'"/>'
                  );
               inc( Count1 );
            end;
            WF_XMLOutput.Lines.Add('   </star>');
         end; //==END== else of FCDduStarSystem[0].SS_stars[Count].S_token='' ==//
         inc(Count);
      end; //==END== while Count<=3 ==//
      {.end root}
      WF_XMLOutput.Lines.Add('</starsys>');
   end //==END== if (SSSG_StellarSysToken.Text<>'stelsys') and (SSSG_LocationX.Text<>'') and (SSSG_LocationY.Text<>'') and (SSSG_LocationZ.Text<>'') and (TMS_StarToken.Text<>'') ==//
   else
   begin
      WF_XMLOutput.Lines.Add('===============================================');
      WF_XMLOutput.Lines.Add('!ERROR: DATA INIT!');
      WF_XMLOutput.Lines.Add('===============================================');
   end;
end;

procedure TFCWinFUG.AdvGlowButton1Click(Sender: TObject);
begin
   FCMfC_Initialize( false );
end;

procedure TFCWinFUG.TC1S_EnableGroupCompanion1Click(Sender: TObject);
begin
   if TC1S_EnableGroupCompanion1.Checked
   then
   begin
      CMT_TabCompanion1Star.Visible:=true;
      TC2S_EnableGroupCompanion2.Enabled:=true;
   end
   else if not TC1S_EnableGroupCompanion1.Checked
   then
   begin
      CMT_TabCompanion1Star.Visible:=false;
      TC2S_EnableGroupCompanion2.Checked:=false;
      TC2S_EnableGroupCompanion2.Enabled:=false;
      CMT_TabCompanion2Star.Visible:=false;
   end;
end;

procedure TFCWinFUG.TC1S_SystemTypeChange(Sender: TObject);
begin
   if TC1S_SystemType.ItemIndex=3
   then TC1S_OrbitGeneration.ItemIndex:=0;
end;

procedure TFCWinFUG.TC2S_EnableGroupCompanion2Click(Sender: TObject);
begin
   if TC2S_EnableGroupCompanion2.Checked
   then CMT_TabCompanion2Star.Visible:=true
   else if not TC2S_EnableGroupCompanion2.Checked
   then CMT_TabCompanion2Star.Visible:=false;
end;

procedure TFCWinFUG.TC2S_SystemTypeChange(Sender: TObject);
begin
   if TC2S_SystemType.ItemIndex=3
   then TC2S_OrbitGeneration.ItemIndex:=0;
end;

procedure TFCWinFUG.TMS_OrbitGenerationClick(Sender: TObject);
begin
   if TMS_OrbitGeneration.ItemIndex<2
   then TMS_OrbitGenerationNumberOrbits.Enabled:=false
   else TMS_OrbitGenerationNumberOrbits.Enabled:=true;
end;

procedure TFCWinFUG.TMS_SystemTypeChange(Sender: TObject);
begin
   if TMS_SystemType.ItemIndex=3
   then TMS_OrbitGeneration.ItemIndex:=0;
end;

end.
