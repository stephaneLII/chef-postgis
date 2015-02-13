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

remote_file '/tmp/postgis-2.1.3.tar.gz' do
   mode '0644'
   source 'http://10.0.0.78/soft/postgis-2.1.3.tar.gz'
end

bash 'install-postgis' do
  user 'root'
  cwd "/tmp"
  code <<-EOH
    tar -xvzf /tmp/postgis-2.1.3.tar.gz
    cd postgis-2.1.3
    ./configure
    make
    make install
  EOH
end
# create the database
include_recipe 'database::postgresql'

postgresql_connection_info = {
   host: '127.0.0.1',
   port: 5432,
   username: 'postgres',
   password: 'toto'
}


# INSTALL POSTGIS ON DATABASE
postgresql_database "enable-postgis_extension" do
  connection postgresql_connection_info
  database_name 'tefenua'
  sql "CREATE EXTENSION postgis ; CREATE EXTENSION postgis_topology"
  action :query
end

