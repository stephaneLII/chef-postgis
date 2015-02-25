#
# Cookbook Name:: chef-postgis
# Recipe:: default
#
# Copyright (C) 2015 stephaneLII
#
# All rights reserved - Do Not Redistribute
#


case node["platform"]
   when "debian"
      %w( postgresql-server-dev-all libxml2 libxml2-dev libgeos-3.3.3 libgeos-dev proj-bin libproj-dev gdal-bin libgdal-dev ).each do |pkg|
         package pkg do
            action :install
         end
   end
   when "ubuntu"
   %w( postgresql-server-dev-9.3 libxml2 libxml2-dev libgeos-3.4.2 libgeos-dev proj-bin libproj-dev gdal-bin libgdal-dev ).each do |pkg|
         package pkg do
            action :install
         end
   end
end

directory node['chef-postgis']['directory']['src'] do
   owner 'root'
   group 'root'
   mode '0755'
   action :create
   recursive true
end

remote_file node['chef-postgis']['directory']['src'] + '/' + node['chef-postgis']['bin'] do
   mode '0644'
   source node['chef-postgis']['src_link']
   not_if { ::File.exist?(node['chef-postgis']['directory']['src'] + '/' + node['chef-postgis']['bin']) }
end


if !(File.exist?(node['chef-postgis']['postgis_bin_installed']))
   untar_cmd = "tar -xvzf #{node['chef-postgis']['directory']['src']}" + '/' + node['chef-postgis']['bin']

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

   # INSTALL FLAG
   #
   file node['chef-postgis']['postgis_bin_installed'] do
      mode '0644'
      action :create_if_missing
   end
end

# load database Functions
#
include_recipe 'database::postgresql'

postgresql_connection_info = {
   host: '127.0.0.1',
   port: 5432,
   username: 'postgres',
   password: node['postgresql']['database_root_password']
}

node['chef-postgis']['databases'].each do |database|

   if !(File.exist?( node['chef-postgis']['base_postgis_created'] + '_' + database ))
      # INSTALL POSTGIS ON DATABASE
      #
      postgresql_database "enable-postgis_extension" do
         connection postgresql_connection_info
         database_name database
         sql "CREATE EXTENSION postgis ; CREATE EXTENSION postgis_topology"
         action :query
      end

      # INSTALL FLAG
      #
      file node['chef-postgis']['base_postgis_created'] + '_' + database do
	mode '0644'
	action :create_if_missing
      end

   end
end

