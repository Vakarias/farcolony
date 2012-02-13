{=====(C) Copyright Aug.2009-2010 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: root project unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2010, Jean-Francois Baconnet

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

program farcolony;

uses
  FastMM4,
  FastSys,
  FastMove,
  FasterTList,
  Forms,
  ImagingComponents,
  VCLFixPack,
  farc_main in 'farc_main.pas' {FCWinMain},
  farc_data_init in 'data\farc_data_init.pas',
  farc_common_func in 'common\farc_common_func.pas',
  farc_ui_win in 'ui\farc_ui_win.pas',
  farc_data_files in 'data\farc_data_files.pas',
  farc_data_textfiles in 'data\farc_data_textfiles.pas',
  farc_win_newgset in 'ui\farc_win_newgset.pas' {FCWinNewGSetup},
  farc_game_newg in 'game\farc_game_newg.pas',
  farc_ogl_viewmain in 'gfx\farc_ogl_viewmain.pas',
  farc_ogl_init in 'gfx\farc_ogl_init.pas',
  farc_ogl_ui in 'gfx\farc_ogl_ui.pas',
  farc_ui_keys in 'ui\farc_ui_keys.pas',
  farc_game_gameflow in 'game\farc_game_gameflow.pas',
  farc_game_missioncore in 'game\farc_game_missioncore.pas',
  farc_game_mitransit in 'game\farc_game_mitransit.pas',
  farc_spu_functions in 'spu\farc_spu_functions.pas',
  farc_win_about in 'ui\farc_win_about.pas' {FCWinAbout},
  farc_game_contg in 'game\farc_game_contg.pas',
  farc_univ_func in 'univ\farc_univ_func.pas',
  farc_win_fug in 'ui\farc_win_fug.pas' {FCWinFUG},
  farc_game_csm in 'game\farc_game_csm.pas',
  farc_game_colony in 'game\farc_game_colony.pas',
  farc_game_csmevents in 'game\farc_game_csmevents.pas',
  farc_game_cps in 'game\farc_game_cps.pas',
  farc_game_miland in 'game\farc_game_miland.pas',
  farc_game_micolonize in 'game\farc_game_micolonize.pas',
  farc_game_spm in 'game\farc_game_spm.pas',
  farc_win_debug in 'ui\farc_win_debug.pas' {FCWinDebug},
  farc_game_infra in 'game\farc_game_infra.pas',
  farc_fug_com in 'univ\farc_fug_com.pas',
  farc_data_univ in 'data\farc_data_univ.pas',
  farc_data_game in 'data\farc_data_game.pas',
  farc_data_infrprod in 'data\farc_data_infrprod.pas',
  farc_fug_stars in 'univ\farc_fug_stars.pas',
  farc_game_pgs in 'game\farc_game_pgs.pas',
  farc_game_core in 'game\farc_game_core.pas',
  farc_game_spmdata in 'game\farc_game_spmdata.pas',
  farc_ui_umi in 'ui\farc_ui_umi.pas',
  farc_ui_msges in 'ui\farc_ui_msges.pas',
  farc_game_spmmemes in 'game\farc_game_spmmemes.pas',
  farc_game_spmpolicies in 'game\farc_game_spmpolicies.pas',
  farc_fug_orbits in 'univ\farc_fug_orbits.pas',
  farc_gfx_core in 'gfx\farc_gfx_core.pas',
  farc_ui_surfpanel in 'ui\farc_ui_surfpanel.pas',
  farc_game_prod in 'game\farc_game_prod.pas',
  farc_game_prodmodes in 'game\farc_game_prodmodes.pas',
  farc_data_research in 'data\farc_data_research.pas',
  farc_game_infracustomfx in 'game\farc_game_infracustomfx.pas',
  farc_game_infraconsys in 'game\farc_game_infraconsys.pas',
  farc_ui_coldatapanel in 'ui\farc_ui_coldatapanel.pas',
  farc_ui_infrapanel in 'ui\farc_ui_infrapanel.pas',
  farc_ui_html in 'ui\farc_ui_html.pas',
  farc_fug_habidx in 'univ\farc_fug_habidx.pas',
  farc_game_prodSeg1 in 'game\farc_game_prodSeg1.pas',
  farc_game_energymodes in 'game\farc_game_energymodes.pas',
  farc_game_prodSeg2 in 'game\farc_game_prodSeg2.pas',
  farc_game_spmcfx in 'game\farc_game_spmcfx.pas',
  farc_game_prodSeg5 in 'game\farc_game_prodSeg5.pas',
  farc_game_infrafunctions in 'game\farc_game_infrafunctions.pas',
  farc_game_infrastaff in 'game\farc_game_infrastaff.pas',
  farc_data_filesavegame in 'data\farc_data_filesavegame.pas',
  farc_game_prodrsrcspots in 'game\farc_game_prodrsrcspots.pas',
  farc_ui_coredatadisplay in 'ui\farc_ui_coredatadisplay.pas',
  farc_game_cpsobjectives in 'game\farc_game_cpsobjectives.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FAR Colony';
  Application.CreateForm(TFCWinMain, FCWinMain);
  Application.CreateForm(TFCWinNewGSetup, FCWinNewGSetup);
  Application.CreateForm(TFCWinAbout, FCWinAbout);
  Application.CreateForm(TFCWinFUG, FCWinFUG);
  Application.Run;
end.
