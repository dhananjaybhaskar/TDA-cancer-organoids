%
% Agent-based model of particle movement on implicit surface (torus)
% Author: Dhananjay Bhaskar
% Last Modified: Jan 04, 2020
% Reference: Using Particles to Sample and Control Implicit Surfaces
% Andrew P. Witkin and Paul S. Heckbert, Proc. SIGGRAPH '94
%

% Agent-based model of particle movement on implicit surface (torus)
% Authors: Dhananjay Bhaskar, Tej Stead
% Last Modified: Jul 09, 2020
% Reference: Using Particles to Sample and Control Implicit Surfaces
% Andrew P. Witkin and Paul S. Heckbert, Proc. SIGGRAPH '94
%​
% number of particles
N = 500;
% params
Alpha = 2;
Sigma = 0.5;
phi = 1;
deltaT = 0.1;
totT = 5;

% init positions
X = zeros(N, 3);

% preallocate state variables
P = zeros(N, 3);
q = [2, 5];
Q = [0.0, 0.0];
F = zeros(N, 1);
dFdX = zeros(N, 3);
dFdq = zeros(N, 2);
dXdt = zeros(N, 3);

pt_1_idx = floor(rand()*N) + 1;
pt_2_idx = floor(rand()*N) + 1;

% use rejection sampling for initial position
% https://math.stackexchange.com/questions/2017079/uniform-random-points-on-a-torus
cnt = 0;
r = q(1);
R = q(2);
while cnt < N
    U = rand();
    V = rand();
    Theta = 2*pi*U;
    Phi = 2*pi*V;
    thresh = (R + r*cos(Theta))/(R + r);
    cnt = cnt + 1;
    X(cnt, :) = [(R + r*cos(Theta))*cos(Phi), (R + r*cos(Theta))*sin(Phi), r*sin(Theta)]; 
end

% preload pathfinder (for static surfaces)
if(isfile("torus_mesh.mat"))
    load("torus_mesh.mat");
else
    mesh_theta_num = 80;
    mesh_phi_num = 40;
    theta_grid = linspace(0, 2*pi, mesh_theta_num);
    phi_grid = linspace(0, 2*pi, mesh_phi_num);
    [Phi_mesh, Theta_mesh] = meshgrid(phi_grid, theta_grid); 
    mesh_x = (R+r.*cos(Theta_mesh)).*cos(Phi_mesh);
    mesh_y = (R+r.*cos(Theta_mesh)).*sin(Phi_mesh);
    mesh_z = r.*sin(Theta_mesh);
    mat = adj_mat_torus(mesh_x,mesh_y,mesh_z);
    [dist_mat, next] = FloydWarshall(mat);
    save torus_mesh.mat mesh_theta_num mesh_phi_num mesh_x mesh_y mesh_z mat dist_mat next;
end
% preload visualizer mesh (not computationally intensive)
theta_num = 36;
phi_num = 18;
theta_grid = linspace(0, 2*pi, theta_num);
phi_grid = linspace(0, 2*pi, phi_num);
[Phi_mesh, Theta_mesh] = meshgrid(phi_grid, theta_grid); 
vis_x = (R+r.*cos(Theta_mesh)).*cos(Phi_mesh);
vis_y = (R+r.*cos(Theta_mesh)).*sin(Phi_mesh);
vis_z = r.*sin(Theta_mesh);

% visualize
% visualize_surface(X,0,vis_x,vis_y,vis_z, [-10 10], [-10 10], [-3 3]);
% visualize_random_path(X, 0, pt_1_idx, pt_2_idx,vis_x,vis_y,vis_z,phi_num, next, [-10 10], [-10 10], [-3 3]);
visualize_geodesic_heatmap(X,0,vis_x,vis_y,vis_z,mesh_x,mesh_y,mesh_z,pt_1_idx,[-10 10], [-10 10], [-3 3], dist_mat);
t = 0;
itr = 0;
while t < totT

    % compute updated state vectors
        % compute updated state vectors
    for i = 1 : N

        P(i,:) = [0, 0, 0]; 
        for j = 1 : N
            Fij = Alpha*exp(-1.0*norm((X(i,:)-X(j,:)))/(2*Sigma^2));
            P(i,:) = P(i,:) + (X(i,:) - X(j,:))*Fij;
        end

        F(i) = (X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)^2 - 4*q(2)^2*(X(i,1)^2 + X(i,2)^2);

        dFdX_i_x = 4*(X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)*X(i,1) - 8*q(2)^2*X(i,1);
        dFdX_i_y = 4*(X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)*X(i,2) - 8*q(2)^2*X(i,2);
        dFdX_i_z = 4*(X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)*X(i,3);
        dFdX(i,:) = [dFdX_i_x, dFdX_i_y, dFdX_i_z];

        dFdq_i_a = -4*(X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)*q(1);
        dFdq_i_R = 4*(X(i,1)^2 + X(i,2)^2 + X(i,3)^2 + q(2)^2 - q(1)^2)*q(2) - 8*q(2)*(X(i,1)^2 + X(i,2)^2); 
        dFdq(i,:) = [dFdq_i_a, dFdq_i_R];

        correction = (dot(dFdX(i,:), P(i,:)) + dot(dFdq(i,:), Q) + phi*F(i))/(norm(dFdX(i,:))^2);
        dXdt(i,:) = P(i,:) - correction*dFdX(i,:);

    end
    
    % update position
    for i = 1 : N
        X(i,:) = X(i,:) + deltaT*dXdt(i,:);
    end
    
    t = t + deltaT;
    itr = itr + 1;
%     visualize(X, itr, pt_1_idx, pt_2_idx,x,y,z,phi_num, next, [-10 10], [-10 10], [-3 3]);
    visualize_geodesic_heatmap(X,itr,vis_x,vis_y,vis_z,mesh_x,mesh_y,mesh_z,pt_1_idx,[-10 10], [-10 10], [-3 3], dist_mat);
end


function [adj_mat] = adj_mat_torus(x,y,z)
    sz = size(x);
    height = sz(1);
    width = sz(2);
    adj_mat = inf*ones(height*width, height*width);
    for i = 1:height
        for j = 1:width
            dx = [-1 -1 -1 0 0 0 1 1 1];
            dy = [-1 0 1 -1 0 1 -1 0 1];
%               dx = [-1 0 0 0 1];
%               dy = [0 -1 0 1 0];
            for k = 1:numel(dx)
                new_i = mod(i+dy(k) - 1, height) + 1; 
                new_j = mod(j+dx(k) - 1, width) + 1;
                distance = pdist([x(i,j) y(i,j) z(i,j) ; x(new_i, new_j) y(new_i, new_j) z(new_i, new_j)]);
                adj_mat((i-1)*width + j,(new_i - 1)*width + new_j) = distance;
            end
        end
    end
end