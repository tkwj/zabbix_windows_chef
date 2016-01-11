# Author:: H. "Waldo" Grunenwald
# Cookbook Name:: zabbix_windows
# Recipe:: windows_agent
#
# Copyright 2012, Ernst Publishing
# License: Apache 2.0

# Install the Zabbix Windows Agent
# see the perl default recipe for pieces

installdir	= node.zabbix_windows.agent.install_dir
includedir	= node.zabbix_windows.agent.include_dir
extractdir	= installdir + "\\#{node['zabbix_windows']['agent']['version']}-files"
platformdir = extractdir + "\\bin\\win#{node['zabbix_windows']['agent']['windows_bitness']}"

installer	= "zabbix_agentd#{node['zabbix_windows']['agent']['windows_bitness']}.exe"
getter		= "zabbix_get#{node['zabbix_windows']['agent']['windows_bitness']}.exe"
sender		= "zabbix_sender#{node['zabbix_windows']['agent']['windows_bitness']}.exe"

zabbix_agent_url = node['zabbix_windows']['agent']['base_url'].gsub! 'VERSION', node['zabbix_windows']['agent']['version']

#directory node['zabbix_windows']['agent']['include_dir'] do
#	action :create
#	recursive true
#	inherits true
#end

directory node['zabbix_windows']['log_dir'] do
	action :create
	recursive true
	inherits true
end

template "#{installdir}\\agent_include" do
	source "agent_include.erb"
	action :create_if_missing
	inherits true
	notifies :restart, "service[Zabbix Agent]"
end

template "#{installdir}\\zabbix_agentd.conf" do
	source "zabbix_agentd.conf.erb"
	action :create_if_missing
	inherits true
	notifies :restart, "service[Zabbix Agent]"
end

if node['zabbix_windows']['agent']['version'] != node['zabbix_windows']['agent']['version_installed']

	# Check Windows Service
	require 'win32ole'
	zabbixservice = 'Zabbix Agent'
	wmi = WIN32OLE.connect("winmgmts://")
	services = wmi.ExecQuery("Select * from Win32_Service where Name = '#{zabbixservice}'")
	if services.count >= 1
		#service exists
		service "Zabbix Agent" do
			action [:stop]
		end

		execute "Remove Zabbix" do
			command "sc delete \"#{zabbixservice}\""
		end

		execute 'remove_old_files' do
			command "del /S #{installdir}\\zabbix*.exe"
		end

	end
		#INSTALL AWAY!

		include_recipe 'windows'
		# Download and unzip zabbix agent zip file
		windows_zipfile "#{extractdir}" do
			source zabbix_agent_url
			action :unzip
			overwrite true
		end

		#move platform-specific EXEs and then remove zip extract folder
		batch 'copy_and_remove' do
			code <<-EOH
			xcopy #{platformdir}\\* #{installdir} /e /y
			for /f "delims=" %%i in ('dir /b #{installdir}\\*.exe') do ren #{installdir}\\"%%~i" "%%~ni64%%~xi
			rd /s /q #{extractdir}
			EOH
		end

	# Back to Chef-land
	execute "Install Zabbix" do
		command "#{installdir}\\#{installer} --config #{installdir}\\zabbix_agentd.conf --install"
		#not_if { File.exists?("#{node['perl']['install_dir']}\\perl\\bin\\perl.exe") }
	end

	ruby_block 'set-installed-version' do
	  block do
	    node.set['zabbix_windows']['agent']['version_installed'] = node['zabbix_windows']['agent']['version']
	  end
	end

end

# Define zabbix_agentd service
#service "zabbix_agentd" do
service "Zabbix Agent" do
	supports :status => true, :start => true, :stop => true, :restart => true
	action [ :enable ]
	action [ :start ]
end