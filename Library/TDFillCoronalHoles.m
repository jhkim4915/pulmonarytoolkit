function lung_image = TDFillCoronalHoles(lung_image, is_right, reporting)
    % TDFillCoronalHoles. Operates on each coronal slice, applying a closing
    % filter then filling interior holes
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    reporting.ShowProgress('Filling holes');
    
    max_non_coronal_voxel_size = max(lung_image.VoxelSize(2:3));

    opening_size = 16/max_non_coronal_voxel_size;
    closing_size = 16/max_non_coronal_voxel_size;
    
    lung_image.AddBorder(10);
    for coronal_index = 11 : lung_image.ImageSize(1) - 10
        reporting.UpdateProgressValue(round(100*(coronal_index - 11)/(lung_image.ImageSize(1) - 20)));
        coronal_slice = lung_image.GetSlice(coronal_index, TDImageOrientation.Coronal);
        if ~isempty(is_right)
            coronal_slice = OpenOrClose(coronal_slice, is_right, opening_size, closing_size, reporting);
        end
        coronal_slice = imclose(coronal_slice, strel('disk', round(closing_size)));
        coronal_slice = imfill(coronal_slice, 'holes');
        lung_image.ReplaceImageSlice(coronal_slice, coronal_index, TDImageOrientation.Coronal);
    end    
    lung_image.RemoveBorder(10);
end

function mask = OpenOrClose(mask, is_right, opening_size, closing_size, reporting)
    closed_image = imclose(mask, strel('disk', round(closing_size)));
    opened_image = imopen(mask, strel('disk', round(opening_size)));

    threshold = TDImage(~(closed_image & opened_image));
    threshold.AddBorder(1);
    image_size = threshold.ImageSize;


    raw_image = zeros(image_size);
    if (is_right)
        raw_image(2, 2:end-1, 2) = 2;
        raw_image(end-1, 2:end-1, 2) = 1;
    else
        raw_image(2, 2:end-1, 2) = 1;
        raw_image(end-1, 2:end-1, 2) = 2;
    end
    raw_image(2:end-1, end-1, 2) = 2;
    raw_image(2:end-1, 2, 2) = 2;
    right_border_indices = threshold.LocalToGlobalIndices(find(raw_image == 1));
    other_border_indices = threshold.LocalToGlobalIndices(find(raw_image == 2));
    
    start_points = {right_border_indices, other_border_indices};
    regions = TDMultipleRegionGrowing(threshold, start_points, reporting);
    regions.RemoveBorder(1);
    closed_region = (regions.RawImage == 1);
    mask(closed_region) = closed_image(closed_region);
    mask(~closed_region) = opened_image(~closed_region);
end