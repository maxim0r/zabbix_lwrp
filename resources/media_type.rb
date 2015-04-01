#
# Cookbook Name:: zabbix_lwrp
# Resource:: media_type
#
# Author:: LLC Express 42 (cookbooks@express42.com)
#
# Copyright (C) 2015 LLC Express 42
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
#

attr_accessor :exists

actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :type, kind_of: Symbol

attribute :server, kind_of: String
attribute :helo,   kind_of: String
attribute :email,  kind_of: String

# script
attribute :path, kind_of: String

# sms
attribute :modem, kind_of: String

# jabber
attribute :username, kind_of: String
attribute :password, kind_of: String
