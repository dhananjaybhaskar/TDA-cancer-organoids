function [] = visualize_surface(X, itr, vis_x, vis_y, vis_z, x_limits, y_limits, z_limits)

    fig = figure('visible', 'off');
    mesh(vis_x, vis_y, vis_z, 'EdgeColor', 'k', 'FaceColor', [0.85, 0.85, 0.85], 'FaceAlpha', 0.2, 'linestyle', '-');
    alpha 0.75;
    daspect([1 1 1])
    xlim(x_limits)
    ylim(y_limits)
    zlim(z_limits)
    hold on;
    scatter3(X(:,1), X(:,2), X(:,3), 30, 'MarkerEdgeColor', [.7 .3 0], 'MarkerFaceColor', [.9 .3 0], 'LineWidth', 1.0);
    zoom(1.32)
    set(gca, 'visible', 'off')
    fname = strcat('sim_', sprintf('%03d',itr), '.png');
    saveas(fig, fname, 'png');
    close
    
end