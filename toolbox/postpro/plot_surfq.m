function h = plot_surfq(fileIn, modIn, aoa, aos, param)
%PLOT_SURFQ Plots the surface mesh with color proportional to the chosen parameter
%
% Inputs:
%    file_name  : Name of the file containing the results (fiName_eqmodel)
%    folderpath : Folder containig the file.
%    aoa        : Angle of attack [rad]
%    aos        : Angle of sideslip [rad]
%    param      : Surface parameter to plot (cp, ctau, cd, cl)
%
% Outputs:
%   h           :
%
% Author: David Mostaza-Prieto
% The University of Manchester
% December 2012
%
%------------- BEGIN CODE --------------

% Load model mesh
[~,modName,~] = fileparts(modIn);
load(modIn);
x = meshdata.XData;
y = meshdata.YData;
z = meshdata.ZData;

% Load results for indicated aoa, aos
s = load(fileIn);
if isfield(s, 'aedb')
    % Locate correct individual adbsat output file
    [pathstr, name, ~] = fileparts(fileIn);
    try
        s = load(fullfile(pathstr,name,[modName,'_a',mat2str(aoa*180/pi),'s',mat2str(aos*180/pi),'.mat']));
    catch
    end
end


L_wb = dcmbody2wind(aoa, aos); % Body to Wind
L_gb = [1 0 0; 0 -1 0; 0 0 -1]; % Body to Geometric
L_gw = L_gb*L_wb'; % Wind to Geometric
%L_fb = [-1 0 0; 0 1 0; 0 0 -1]; % Body to Flight

axlength = 0.7*s.Lref;

x1 = [0;0;0];
y1 = x1;
z1 = x1;

figure
hold on
%Wind
W = quiver3(x1,y1,z1,L_gw(:,1),L_gw(:,2),L_gw(:,3),axlength, 'b');
quiver3(0,0,0,L_gw(1,1),L_gw(1,2),L_gw(1,3),axlength, 'b', 'LineWidth',2)
% Body
B = quiver3(x1,y1,z1,L_gb(:,1),L_gb(:,2),L_gb(:,3),axlength,'r');
quiver3(0,0,0,L_gb(1,1),L_gb(1,2),L_gb(1,3),axlength, 'r', 'LineWidth',2)
% Geometric
G = quiver3(x1,y1,z1,[1;0;0],[0;1;0],[0;0;1],axlength,'g');
axis equal
grid on

h = patch(x, y, z, s.(param));
colorbar
legend([W,B,G],'Wind','Body','Geometric','Location','NorthWest')
% set(h,'EdgeAlpha',0)
string1 = strcat(s.(param),' surface distribution');
string2 = strcat('AoA: ',mat2str(aoa*180/pi),' deg,  AoS: ', mat2str(aos*180/pi), ' deg');
xlabel('x'); ylabel('y'); zlabel('z')
title(char(string1,string2))

axis equal

%------------- END OF CODE --------------