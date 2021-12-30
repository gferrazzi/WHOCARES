function kspace = ifftmine(image, dims, bfftshift)
%%**********************************************************************
%
%   kspace = ifftnsh(image, dims, bfftshift)
%
%   
%
%   INPUT:                                                          [unit]
%   -----------------------------------------------------------------------
%   kspace:     kspace data (for example)
%   dims:       dimensions along which the FFT will be performed
%               e.g. [1 2 5]
%   bfftshift   boolean value; set to 1 if fftshift should be used.
%
%   OUTPUT:
%   -----------------------------------------------------------------------
%   image       fourier transform of kspace along the dimensions specified by 
%               dims.
%           
%%**********************************************************************

lDims = length(dims);
kspace = image;
if(bfftshift)
    for lL = 1:lDims
        kspace = fftshift(ifft(fftshift(kspace,dims(lL)),[],dims(lL)),dims(lL));
    end
else
    for lL = 1:lDims
        kspace = (ifft(fftshift(kspace,dims(lL)),[],dims(lL)));
    end
end

end
