node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping remote_syslog2::configure application #{application} as it is not a Rails app")
    next
  end

  if node[:remote_syslog2][application]

    config = node[:remote_syslog2][application]

    template node['remote_syslog2']['config_file'] do
      source 'remote_syslog2.yml.erb'
      mode 0664

      variables({
        hostname: node[:opsworks][:instance][:hostname],
        application: application,
        rails_env: node[:deploy][application][:rails_env],
        destination: {
          host: config[:destination][:host],
          port: config[:destination][:port]
        }
      })

      mode '0644'
      notifies :restart, 'service[remote_syslog2]', :delayed
    end
  end
end
