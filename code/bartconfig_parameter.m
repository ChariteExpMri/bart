
% my templatepaths
function o=bartconfig_parameter

o.templates=...
{
'F:\bart_templates\bart_template_mouse_ABA'
'F:\bart_templates\bart_template_Rat_Waxholmv4_clipped'
'%----our windows-Server----'
'D:\bart_templates\bart_template_mouse_ABA'
'D:\bart_templates\bart_template_Rat_Waxholmv4_clipped'
'----my older----'
'F:\tools\bart_template'
'D:\MATLAB\bart_templates'
};



o.deepslice_default=...
    {
    'none'
    which('deepslice_defaults_home.m')
    which('deepslice_defaults_win10server.m');
    };

  
  