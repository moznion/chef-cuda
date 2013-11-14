case node['platform_family']
when 'rhel'
  p node['cuda']['pkg_manager_src']
  remote_file node['cuda']['pkg_manager'] do
    action :create_if_missing
    source node['cuda']['pkg_manager_src']
  end

  rpm_package node['cuda']['pkg_manager'] do
    action :install
    source node['cuda']['pkg_manager']
  end

  packages = %w/gcc-c++ kernel-devel/
  packages.each do |pkg|
    yum_package pkg do
      action :install
      flush_cache [:before]
    end
  end

  packages = %w/nvidia-settings nvidia-kmod xorg-x11-drv-nouveau/
  packages.each do |pkg|
    yum_package pkg do
      action :remove
      flush_cache [:before]
    end
  end

  packages.each do |pkg|
    yum_package pkg do
      action :install
      flush_cache [:before]
    end
  end
end

node['cuda']['packages'].each do |pkg|
  package pkg do
    action  :install
    options options
  end
end

cuda_home = 'export CUDA_HOME=/usr/local/cuda-5.5'
execute 'Set CUDA_HOME' do
  command %/echo "#{cuda_home}" >> #{node['cuda']['profile']}/
  not_if { File.open(node['cuda']['profile']).read.match(cuda_home) }
end

ld_library_path = 'export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH'
execute 'Set LD_LIBRARY_PATH' do
  command %/echo "#{ld_library_path}" >> #{node['cuda']['profile']}/
  not_if { File.open(node['cuda']['profile']).read.match(ld_library_path) }
end

path = 'export PATH=\$CUDA_HOME/bin:\$PATH'
execute 'Set PATH' do
  command %/echo "#{path}" >> #{node['cuda']['profile']}/
  not_if { File.open(node['cuda']['profile']).read.match(path) }
end

samples_dir     = "/usr/local/cuda/samples"
samples_bin_dir = samples_dir << '/bin/x86_64/linux/release'
samples_path    = "export PATH=#{samples_bin_dir}:\$PATH"
execute 'Install CUDA SDK Samples' do
  command %!cd #{samples_dir} && make && echo "#{samples_path}" >> #{node['cuda']['profile']}!
  not_if { File.exist?(samples_bin_dir) }
end
