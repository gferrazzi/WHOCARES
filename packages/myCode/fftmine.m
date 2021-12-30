function image = fftmine(kspace, dims, bfftshift)
%%**********************************************************************
%
%   image = fftnsh(kspace, dims, bfftshift)
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
image = kspace;
if(bfftshift)
    for lL = 1:lDims
        image = fftshift(fft(fftshift(image,dims(lL)),[],dims(lL)),dims(lL));
    end
else
    for lL = 1:lDims
        image = (fft(fftshift(image,dims(lL)),[],dims(lL)));
    end
end

end
