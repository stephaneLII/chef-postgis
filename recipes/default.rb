#
# Cookbook Name:: chef-postgis
# Recipe:: default
#
# Copyright (C) 2015 Stephane LII
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt::default"
include_recipe 'chef-postgis::_postgresql'
include_recipe 'chef-postgis::_postgis'
