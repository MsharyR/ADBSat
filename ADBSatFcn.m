function [ pathOut ] = ADBSatFcn( modname, param_eq, aoa_deg, aos_deg, flag_shadow, flag_solar, env, del, verb )
%ADBSATFCN Creates a .mat file(s) in "/inou/results" with the following fields:
%
% Inputs:
%       modname : name of the input model file (.mat) in /inou/models
%       param_eq : GSI & SRP parameter structure inputs (dependent on GSI model)
%           gsi_model   : GSI Model (string)
%           alpha       : Energy accommodation coefficient (Cook/Sentman/Maxwell)
%           alphaN      : Normal thermal accommodation coefficient (CLL)
%           sigmaN      : Normal momentum accommodation coefficent (S&C/Storch)
%           sigmaT      : Tangential momentum accommodation coefficient (S&C/Storch/CLL)
%           sol_cR      : Solar specular reflectivity coefficient
%           sol_cD      : Solar diffuse reflectivity coefficient
%       aoa_deg  : vector of angle of attack [deg]
%       aos_deg  : vector of angle of sideslip [deg]
%       shadow   : flag for shadown analysis
%       solar    : flag for solar coefficient analysis
%       env      : vector of input environmental parameters
%       del      : flag for individual file cleanup (on mergeAEDB)
%       verb     : flag for visual output
%
% Outputs:
%       fileout  : .mat file(s) with the following items in a structure variable
%           aoa      : Angle of attack
%           aos      : Angle of sideslip
%           Aref     : Reference area = Area total/2
%           Lref     : Reference longitude = Xmax-Xmin
%           AreaProj : Projected area
%           aero
%               Cf_w     : Total aerodynamic force coeffients in wind axes [x,y,z] (3x1)
%               Cf_f     : Total aerodynamic force coeffients in flight axes [x,y,z] (3x1)
%               Cm_B     : Total aerodynamic moment coeffients in body axes [x,y,z](3x1)
%           solar
%               C_s      : Total solar force coefficients in
%               C_sB     : Total solar moment coefficients in
%           param_eq : Structure containing input GSI parameters
%
% Author: David Mostaza-Prieto
% The University of Manchester
% November 2012
%
%------------- BEGIN CODE --------------

% Check GSIM Inputs
if strcmpi(param_eq.gsi_model,'CLL')
    if any(~isfield(param_eq,{'alphaN','sigmaT'}))
        error([param_eq.gsi_model,' model requires alphaN and sigmaT inputs'])
    end
elseif any(strcmpi(param_eq.gsi_model,{'schaaf','storchHyp'}))
    if any(~isfield(param_eq,{'sigmaN','sigmaT'}))
        error([param_eq.gsi_model,' model requires sigmaN and sigmaT inputs'])
    end
elseif any(strcmpi(param_eq.gsi_model,{'cook','sentman','maxwell'}))
    if ~isfield(param_eq,'alpha')
        error([param_eq.gsi_model,' model requires alpha input'])
    end
elseif strcmpi(param_eq.gsi_model,'newton')
    % Nothing
else
    error('GSI Model input string not recognised');
end

% Check SRP Model Inputs
if flag_solar == 1 && any(~isfield(param_eq,{'sol_cR','sol_cD'}))
    error('SRP interaction model requires sol_cR and sol_cD inputs')
end

if ~isfield(param_eq,'Tw')
    warning('Wall temperature not defined in input. Default value of 300K used')
    param_eq.Tw = 300; % Surface temperature [K]
end

% Environment Calculations
[param_eq.V, ~, param_eq.s, Rmean, param_eq.Tinf] = environment(env(1),env(2),env(3),env(4),env(5),env(6),env(7),env(8:14));

param_eq.Vw = sqrt(pi.*Rmean.*param_eq.Tw/2); % Velocity of the reflected diffuse molecules

% Calculate Interactions
aoa = aoa_deg*pi/180; % Angle(s) of attack [rad]
aos = aos_deg*pi/180; % Angle(s) of sideslip [rad]
pathOut = calc_coeff(modname, aoa, aos, param_eq, flag_shadow, flag_solar, del, verb);

%------------- END OF CODE --------------