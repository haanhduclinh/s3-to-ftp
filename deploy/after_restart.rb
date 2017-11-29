# encoding: utf-8
# frozen_string_literal: true

Chef::Log.info("Running deploy/after_restart.rb")

node[:deploy].each do |_application, deploy|
  template "#{node.default[:monit][:conf_dir]}/slack_observer.monitrc" do
    cookbook "dl_app"
    source "slack_observer.monitrc.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      deploy_user: deploy[:user],
      deploy_dir: deploy[:deploy_to],
      env: deploy[:env],
      slack_token: deploy[:environment][:SLACK_TOKEN],
      slack_chanel_id: deploy[:environment][:SLACK_CHANEL_ID],
      bucket_name: deploy[:environment][:BUCKET_NAME],
      maper: deploy[:environment][:MAPER],
      name: deploy[:environment][:NAME],
      slack_observer: deploy[:environment][:SLACK_OBSERVER],
      host: deploy[:environment][:HOST],
      username: deploy[:environment][:USERNAME],
      password: deploy[:environment][:PASSWORD],
      port: deploy[:environment][:PORT],
      secret_access_key: deploy[:environment][:SECRET_ACCESS_KEY],
      region: deploy[:environment][:REGION],
      endpoint: deploy[:environment][:ENDPOINT],
    )
  end

  execute "monit_restart" do
    command "/etc/init.d/monit restart"
    ignore_failure true
    user "root"
  end

  execute "kill_current_process" do
    command "/usr/bin/pkill -f slack_observer"
    ignore_failure true
    user "root"
  end
end