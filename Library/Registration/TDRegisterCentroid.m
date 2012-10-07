function [affine_matrix, affine_vector] = TDRegisterCentroid(image_to_transform, reference_image, reporting)
    % TDRegisterCentroid. Computes the transformation matrix to register one
    % image segmentation to another based on a rigid translation of the
    % centroids.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    com_float = GetCentreOfMass(image_to_transform);
    com_ref = GetCentreOfMass(reference_image);
    com_float_to_ref = com_ref - com_float;
    
    affine_vector = [0, 0, 0, -com_float_to_ref];
    affine_matrix = TDImageCoordinateUtilities.CreateRigidAffineMatrix(affine_vector);
end

function com = GetCentreOfMass(mask)
    [c_i, c_j, c_k] = mask.GetCentredGlobalCoordinatesMm;
    [c_i, c_j, c_k] = ndgrid(c_i, c_j, c_k);
    c_i = c_i(mask.RawImage > 0);
    c_j = c_j(mask.RawImage > 0);
    c_k = c_k(mask.RawImage > 0);
    com = [mean(c_i), mean(c_j), mean(c_k)];
end