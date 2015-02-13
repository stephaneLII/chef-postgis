#
# Cookbook Name:: _postgresql
# Recipe:: _postgresql
#
# Copyright (C) 2015 Stephane LII
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node.set['postgresql']['password']['postgres'] = 'toto'
node.set['postgresql']['config']['listen_addresses'] = '*'
node.set['postgresql']['pg_hba'] = [
   {
      type: 'local',
      db: 'all',
      user: 'postgres',
      addr: nil,
      method: 'ident'
   },
   {
      type: 'local',
      db: 'all',
      user: 'all',
      addr: nil,
      method: 'ident'
   },
   {
      type: 'host',
      db: 'all',
      user: 'all',
      addr: '127.0.0.1/32',
      method: 'md5'
   },
   {
      type: 'host',
      db: 'all',
      user: 'all',
      addr: '::1/128',
      method: 'md5'
   },
   {
      type: 'host',
      db: 'tefenua',
      user: 'tefenua',
      addr: '192.168.0.0/8',
      method: 'md5'
   },
   {
      type: 'host',
      db: 'postgres',
      user: 'postgres',
      addr: '192.168.0.0/8',
      method: 'md5'
   }
]
# install the database software
include_recipe 'postgresql::server'

# create the database
include_recipe 'database::postgresql'

postgresql_connection_info = {
   host: '127.0.0.1',
   port: 5432,
   username: 'postgres',
   password: 'toto'
}

postgresql_database 'tefenua' do
   connection postgresql_connection_info
   action :create
end

postgresql_database_user 'tefenua' do
   connection postgresql_connection_info
   password 'toto'
   action :create
end

postgresql_database_user 'tefenua' do
   connection postgresql_connection_info
   password 'toto'
   database_name 'tefenua'
   action :grant
end

