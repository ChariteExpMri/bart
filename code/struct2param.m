% ==============================================
%%   struct2param (p,z)
%  fill (potenitally empty) n-by-4 zell info-arry with settings from parameter struct 
% p:  nx4 cell array (parameter, input, descr fcn)
% z: struct with corresponding fieldnames 
%--> can be  used to re-use in paramgui
% 
% 
% p =
% 
%   8×4 cell array
% 
%     {'files'     }    {0×0 char}    {'select tiff files'     }    {'mf'    }
%     {'fileswcard'}    {'_x10'  }    {'alternative select w…'}    {1×2 cell}
%     {'transpose' }    {[     1]}    {'transpose image {0,1}' }    {'b'     }
%     {'verbose'   }    {[     1]}    {'passes extra info  {…'}    {'b'     }
%     {'outdir'    }    {'up1'   }    {'out-put directory: {…'}    {1×2 cell}
%     {'verb'      }    {[     1]}    {'verbose,passes extra…'}    {'b'     }
%     {'thumbnail' }    {[     1]}    {'save thumbnail image…'}    {'b'     }
%     {'isparallel'}    {[     0]}    {'use parallel computi…'}    {'b'     }
% 
% z = 
% 
%   struct with fields:
% 
%          files: {'horst'  'adam'}
%     fileswcard: 'qq'
%      transpose: 0
%        verbose: 1
%         outdir: 'same'
%           verb: 1
%      thumbnail: 1
%     isparallel: 0
%===================================================================================================
% OUTPUT
% p2 =
% 
%   8×4 cell array
% 
%     {'files'     }    {1×2 cell}    {'select tiff files'   }    {'mf'    }
%     {'fileswcard'}    {'qq'    }    {'alternative select…'}    {1×2 cell}
%     {'transpose' }    {[     0]}    {'transpose image {0…'}    {'b'     }
%     {'verbose'   }    {[     1]}    {'passes extra info …'}    {'b'     }
%     {'outdir'    }    {'same'  }    {'out-put directory:…'}    {1×2 cell}
%     {'verb'      }    {[     1]}    {'verbose,passes ext…'}    {'b'     }
%     {'thumbnail' }    {[     1]}    {'save thumbnail ima…'}    {'b'     }
%     {'isparallel'}    {[     0]}    {'use parallel compu…'}    {'b'     }
% ===============================================

function p2=struct2param(p,z)
 

fn=fieldnames(z);

p2=p;
for i=1:length(fn)
  is=find(strcmp(p(:,1),fn{i}));     
   in=getfield(z,fn{i});
  p2{is,2}=in;
end



