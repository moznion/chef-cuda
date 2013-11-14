CUDA_VERSION = '5.5'

default['cuda']['packages'] = ['cuda']
default['cuda']['version']  = CUDA_VERSION

case platform_family
when "rhel"
  default['cuda']['pkg_manager_src'] = 'http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-' << CUDA_VERSION << '-0.x86_64.rpm'
  default['cuda']['pkg_manager']     = "#{Chef::Config[:file_cache_path]}/cuda.rpm"
  default['cuda']['profile']         = '/etc/bashrc'
end
