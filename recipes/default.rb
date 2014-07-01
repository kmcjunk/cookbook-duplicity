#
# Cookbook Name:: duplicity
# Recipe:: default
#
# Copyright (C) 2014 Rackspace, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'python'

python_pip 'pyrax'
python_pip 'lockfile'
package 'librsync-dev'

remote_file 'duplicity' do
  owner 'root'
  group 'root'
  mode '0644'
  path "#{Chef::Config[:file_cache_path]}/duplicity-#{node[:duplicity][:version]}.tar.gz"
  source node[:duplicity][:url]
  checksum node[:duplicity][:checksum]
  notifies :run, 'bash[install duplicity]', :immediately
end

bash "install duplicity" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    TMPDIR=$( mktemp -d )
    echo "Created tmpdir ${TMPDIR}"
    pushd /tmp/${TMPDIR}
    echo "Extracting duplicity"
    /bin/tar xzf #{Chef::Config[:file_cache_path]}/duplicity-#{node[:duplicity][:version]}.tar.gz
    cd duplicity-#{node[:duplicity][:version]}
    echo "Running duplicity install"
    /usr/bin/python setup.py install
    popd
    echo "Removing duplicity tmpdir"
    rm -rf ${TMPDIR}
  EOH
  action :nothing
end
