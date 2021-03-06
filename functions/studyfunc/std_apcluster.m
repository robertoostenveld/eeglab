% std_apcluster() - Affinity propagation cluster for eeglab STUDY
%                   Wrapper for function provided by (Frey/Dueck, Science 2007)
%
% Usage:
%   >>  [IDX,C,sumd] = std_apcluster(clustdata);
%
% Inputs:
% clustdata -Preclustering matrix
%
% Optional inputs:
%
%   'maxits'     -maximum number of iterations (default: 1000)
%   'convits'    -if the estimated exemplars stay fixed for convits
%                 iterations, APCLUSTER terminates early (default: 100)
%   'dampfact'   -update equation damping level in [0.5, 1).  Higher
%                 values correspond to heavy damping, which may be needed
%                 if oscillations occur. (default: 0.9)
%   'dist'      - Same as in pdist:
%       'euclidean'   - Euclidean distance (default)
%       'seuclidean'  - Standardized Euclidean distance. Each coordinate
%                       difference between rows in X is scaled by dividing
%                       by the corresponding element of the standard
%                       deviation S=NANSTD(X). To specify another value for
%                       S, use D=PDIST(X,'seuclidean',S).
%       'cityblock'   - City Block distance
%       'minkowski'   - Minkowski distance. The default exponent is 2. To
%                       specify a different exponent, use
%                       D = PDIST(X,'minkowski',P), where the exponent P is
%                       a scalar positive value.
%       'chebychev'   - Chebychev distance (maximum coordinate difference)
%       'mahalanobis' - Mahalanobis distance, using the sample covariance
%                       of X as computed by NANCOV. To compute the distance
%                       with a different covariance, use
%                       D =  PDIST(X,'mahalanobis',C), where the matrix C
%                       is symmetric and positive definite.
%       'cosine'      - One minus the cosine of the included angle
%                       between observations (treated as vectors)
%       'correlation' - One minus the sample linear correlation between
%                       observations (treated as sequences of values).
%       'spearman'    - One minus the sample Spearman's rank correlation
%                       between observations (treated as sequences of values).
%       'hamming'     - Hamming distance, percentage of coordinates
%                       that differ
%       'jaccard'     - One minus the Jaccard coefficient, the
%                       percentage of nonzero coordinates that differ
%
% Outputs:
%
% See also:
%   std_plotinfocluster
%
% Author: Ramon Martinez-Cancino, SCCN, 2014
%
% Copyright (C) 2014  Ramon Martinez-Cancino,INC, SCCN
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [idx,c,sumd] = std_apcluster(clustdata,varargin)

%  Input stuffs
try
    options = varargin;
    if ~isempty( varargin ),
        for i = 1:2:numel(options)
            opts.(options{i}) = options{i+1};
        end
    else opts= [];
    end
catch
    disp('std_infocluster() error: calling convention {''key'', value, ... } error'); return;
end

try opts.maxits;           catch, opts.maxits       = 200;          end; % Maximun number of iterations
try opts.convits;          catch, opts.convits      = 100;          end; %
try opts.dampfact;         catch, opts.dampfact     = 0.9;          end; %
try opts.dist;             catch, opts.dist         = 'euclidean';  end; % Distance metric

% Getting distance matrix
S = squareform(pdist(clustdata, opts.dist));

% Spell
[idxtmp,netsim,~,expref] = apcluster(S,mean(S(:)),'maxits', opts.maxits, 'convits', opts.convits, 'dampfact',opts.dampfact);

% --- Adjusting output formats --
% Getting centroids
rmpindx = 1:length(idxtmp);
c_indx  = find(rmpindx(:) == idxtmp(:));
c  = clustdata(c_indx,:);

% Reindexing indxtmp
centroids_realindx = unique(idxtmp);
idx = zeros(size(idxtmp));

dist_tmp = [];
for i = 1 : length(centroids_realindx)
    hit_tmp = find(idxtmp == centroids_realindx(i));
    idx(hit_tmp)  = i;
    
    for j = 1:length(hit_tmp)
        dist_tmp(j) = pdist([c(i,:)' clustdata(hit_tmp(j),:)']', opts.dist);
    end
    sumd(i) = sum(dist_tmp);
    dist_tmp = [];
end
