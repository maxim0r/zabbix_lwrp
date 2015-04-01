#
# Cookbook Name:: zabbix_lwrp
# Recipe:: web
#
# Copyright (C) LLC 2015 Express 42
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include_recipe 'php'
include_recipe 'nginx::official-repo'
include_recipe 'nginx::default'

db_node = node
db_user = 'zabbix'
db_name = 'zabbix'
db_pass = 'zabbix'

# Find zabbix database address and port
if node['recipes'].include?('zabbix_lwrp::database')
  if node['zabbix']['server']['database']['configuration']['listen_addresses'] == '*' || '0.0.0.0'
    db_node_ip = '127.0.0.1'
  else
    db_node_ip = node['zabbix']['server']['database']['configuration']['listen_addresses']
  end
else
  db_node = search(:node, "recipe:zabbix_lwrp::database AND chef_environment:#{node.chef_environment}").first # ~FC003
  db_node_ip = db_node['ipaddress']
end

db_port = db_node['zabbix']['server']['database']['configuration']['port']

# Get user and database information from data bag

if db_node['zabbix']['server']['database']['databag'] && !db_node['zabbix']['server']['database']['databag'].empty?
  db_user_data = data_bag_item(db_node['zabbix']['server']['database']['databag'], 'users')['users']
  db_user = db_user_data.keys.first
  db_pass = db_user_data[db_user]['options']['password']
end

package 'php5-pgsql'

package 'zabbix-frontend-php' do
  response_file 'zabbix-frontend-without-apache.seed'
  action [:install, :reconfig]
end

php_pool 'zabbix-runtime' do
  address node['zabbix']['server']['web']['listen']
  port node['zabbix']['server']['web']['port']
  limits node['zabbix']['server']['web']['limits']
  php_var node['zabbix']['server']['web']['configuration']
  action :add
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'zabbix.conf.php.erb'
  mode '0600'
  owner 'www-data'
  group 'www-data'
  variables(
    db_host: db_node_ip,
    db_name: db_name,
    db_port: db_port,
    user_name: db_user,
    user_password: db_pass,
    server_host: 'localhost',
    server_port: '10051')
end

nginx_site node['zabbix']['server']['web']['server_name'] do
  action :enable
  template 'zabbix-site.conf.erb'
  variables(
    server_name: node['zabbix']['server']['web']['server_name'],
    fastcgi_listen: node['zabbix']['server']['web']['listen'],
    fastcgi_port: node['zabbix']['server']['web']['port']
  )
end
