#
# Cookbook Name:: chef-postgis
# Recipe:: default
#
# Copyright (C) 2015 stephaneLII
#
# All rights reserved - Do Not Redistribute
#


%w( postgresql-server-dev-9.3 libxml2 libxml2-dev libgeos-3.4.2 libgeos-dev proj-bin libproj-dev gdal-bin libgdal-dev ).each do |pkg|
  package pkg do
    action :install
  end
end

directory node['postgis']['directory']['src'] do
   owner 'root'
   group 'root'
   mode '0755'
   action :create
   recursive true
end

remote_file node['postgis']['directory']['src'] + '/' + node['postgis']['bin'] do
   mode '0644'
   source node['postgis']['src_link']
   not_if { ::File.exist?(node['postgis']['directory']['src'] + '/' + node['postgis']['bin']) }
end

if !(File.exist?(node['postgis']['base_postgis_created']))

   untar_cmd = "tar -xvzf #{node['postgis']['directory']['src']}" + '/' + node['postgis']['bin']

   bash 'install-postgis' do
     user 'root'
     cwd "/tmp"
     code <<-EOH
       #{untar_cmd}
       cd postgis-2.1.3
       ./configure
       make
       make install
     EOH
   end

   # load database Functions
   #
   include_recipe 'database::postgresql'

   postgresql_connection_info = {
      host: '127.0.0.1',
      port: 5432,
      username: 'postgres',
      password: node['postgis']['database_root_password']
   }

   # INSTALL POSTGIS ON DATABASE
   #
   postgresql_database "enable-postgis_extension" do
      connection postgresql_connection_info
      database_name node['postgis']['database']
      sql "CREATE EXTENSION postgis ; CREATE EXTENSION postgis_topology"
      action :query
   end

   # INSTALL FLAG
   #
   file node['postgis']['base_postgis_created'] do
	mode '0644'
	action :create_if_missing
   end
end

