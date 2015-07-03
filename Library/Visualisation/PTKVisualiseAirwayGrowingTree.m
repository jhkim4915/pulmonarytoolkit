function PTKVisualiseAirwayGrowingTree(airway_tree, reporting)
    % PTKVisualiseAirwayGrowingTree. Draws a simplified visualisation of a tree
    % generated by PTKAirwayGenerator.
    %
    %     Syntax
    %     ------
    %
    %         PTKVisualiseAirwayGrowingTree(parent_branch)
    %
    %             parent_branch     is the root branch in a PTKTreeModel structure 
    %             reporting         is an object which implements
    %                               PTKReportingInterface, for error and progress
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %           
    % 

    reporting.ShowProgress('Drawing computed airway tree');
    % Assumes coordinates are in mm so no voxel size conversion required
    aspect_ratio = [1, 1, 1];

    % Set up appropriate figure properties
    fig = figure;
    set(fig, 'Name', 'Airway Growing Tree');
    
    hold on;
    axis off;
    axis square;
    lighting gouraud;
    axis equal;
    set(gcf, 'Color', 'white');
    set(gca, 'DataAspectRatio', aspect_ratio);
    rotate3d
    cm = colormap(PTKSoftwareInfo.Colormap);
    view(-37.5, 30);
    cl = camlight('headlight');

    next_generation = airway_tree;
    segment_count = 0;
    total_segments = airway_tree.CountBranches;
    
    while ~isempty(next_generation)
        current_generation = next_generation;
        next_generation = [];
        
        reporting.UpdateProgressValue(round(100*segment_count/total_segments));

        for segment = current_generation

            segment_count = segment_count + 1;
            next_generation = [next_generation segment.Children];
        
            start_point = segment.StartPoint;
            end_point = segment.EndPoint;
            generation = segment.GenerationNumber;
            
            colour_value = mod(generation - 1, 5) + 1;
            colour = cm(colour_value, :);
            
            if segment.IsGenerated
                thickness = 1;
            else
                colour = [1 1 0];
                thickness = 2;
            end

            px = [start_point.CoordX; end_point.CoordX];
            py = [start_point.CoordY; end_point.CoordY];
            pz = [start_point.CoordZ; end_point.CoordZ];
            
            
            line('XData', px, 'YData', py, 'ZData', pz, 'Color', colour, 'LineWidth', thickness);
        end
    end
end

