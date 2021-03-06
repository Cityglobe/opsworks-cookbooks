node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping remote_syslog2::configure application #{application} as it is not a Rails app")
    next
  end

  if node[:remote_syslog2][application]

    Chef::Log.debug("Creating remote_syslog2 config for #{application}")

    config = node[:remote_syslog2][application]

    Chef::Log.debug("Creating remote_syslog2 file at #{node['remote_syslog2']['config_file']}")

    template node['remote_syslog2']['config_file'] do
      source 'remote_syslog2.yml.erb'
      mode 0664

      hostname = "#{node[:opsworks][:stack][:name]}_#{node[:opsworks][:instance][:hostname]}"

      variables({
        hostname: hostname,
        application: application,
        rails_env: node[:deploy][application][:rails_env],
        destination: {
          host: config[:destination][:host],
          port: config[:destination][:port]
        }
      })

      notifies :restart, 'service[remote_syslog2]', :delayed

      Chef::Log.debug("remote_syslog2 configuration written")
    end
  else
    Chef::Log.debug("Skipping remote_syslog2 config creating for #{application}")
  end
end
