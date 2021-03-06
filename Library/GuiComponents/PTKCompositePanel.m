classdef PTKCompositePanel < PTKVirtualPanel
    % PTKCompositePanel.  Part of the gui for the Pulmonary Toolkit.
    %
    %     This class is used internally within the Pulmonary Toolkit to help
    %     build the user interface.
    %
    %     PTKAllPatientsPanel represents the panel in the Patient Browser
    %     showing all datasets grouped by patient.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        LeftMargin = 0;
        RightMargin = 0;
        TopMargin = 0
        BottomMargin = 0
        VerticalSpacing = 0
    end
    
    properties (Access = private)
        Panels
        CachedPanelHeight
        CachedPanelWidth
    end
    
    methods
        function obj = PTKCompositePanel(parent, reporting)
            obj = obj@PTKVirtualPanel(parent, reporting);
            obj.Panels = [];
        end
        
        function Resize(obj, new_position)
            Resize@PTKVirtualPanel(obj, new_position);
            
            panel_width = new_position(3);
            y_coord_from_top = 1 + obj.TopMargin;
            parent_panel_height = new_position(4) + new_position(2);
            
            panel_width_excluding_margins = panel_width - obj.LeftMargin - obj.RightMargin;
            total_height = obj.GetRequestedHeight(panel_width);

            visible_y_min_from_base = - new_position(2);
            visible_y_max_from_base = visible_y_min_from_base + parent_panel_height;
            
            for panel_index = 1 : numel(obj.Panels)
                panel = obj.Panels(panel_index);
                panel_height = panel.GetRequestedHeight(panel_width_excluding_margins);
                panel.CachedMinY = y_coord_from_top;
                panel.CachedMaxY = y_coord_from_top + panel_height;

                panel_max_y_from_base = total_height - y_coord_from_top;
                panel_min_y_from_base = total_height - (y_coord_from_top + panel_height);

                panel_y_coord = panel_min_y_from_base + new_position(2);
                
                panel_size = [1 + obj.LeftMargin, panel_y_coord, panel_width_excluding_margins, panel_height];
                panel.Resize(panel_size);

                % Determine if current panel is visible
                panel_is_visible = (panel_min_y_from_base < visible_y_max_from_base) && (panel_max_y_from_base > visible_y_min_from_base);

                if panel_is_visible
                    panel.Enable(obj.Reporting);
                else
                    panel.Disable;
                end

                y_coord_from_top = y_coord_from_top + panel_height + obj.VerticalSpacing;
            end
        end
        
        function height = GetRequestedHeight(obj, width)

            if isempty(obj.CachedPanelHeight) || (width ~= obj.CachedPanelWidth)
                width_excluding_margins = width - obj.LeftMargin - obj.RightMargin;
                height = obj.TopMargin;
                for panel = obj.Panels
                    height = height + panel.GetRequestedHeight(width_excluding_margins) + obj.VerticalSpacing;
                end
                height = height - obj.VerticalSpacing + obj.BottomMargin;
                obj.CachedPanelHeight = height;
                obj.CachedPanelWidth = width;
            end
            height = obj.CachedPanelHeight;
        end
    end
    
    methods (Access = protected)
        
        function AddPanel(obj, panel)
            obj.Panels = [obj.Panels, panel];
            obj.AddChild(panel, obj.Reporting);
            obj.CachedPanelWidth = [];
            obj.CachedPanelHeight = [];
        end
        
        function RemoveAllPanels(obj)
            for panel = obj.Panels
                delete(panel);
            end
            
            obj.Children = [];
            obj.Panels = [];
            obj.CachedPanelWidth = [];
            obj.CachedPanelHeight = [];
        end

    end
end