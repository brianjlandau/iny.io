package :monit, :provides => :monitoring do
  description 'installs monit - a system monitoring utility which allows an admin to easily monitor files, processes, directories, or devices on your system.'
  version '5.2.1'
  
  source "http://mmonit.com/monit/dist/monit-#{version}.tar.gz" do
    post :install, 'mkdir /etc/monit'
    post :install, 'mkdir /etc/monit.d'
    post :install, 'mkdir /var/lib/monit'
  end
  
  requires :build_essential, :monit_dependencies, :dependencies
  
  verify do
    has_executable "monit"
  end
end

package :monit_conf do
  description "Monit conf file"
  requires :monit
  install_path "/etc/monitrc"
  
  mailserver_username = ask("Enter the monit mailserver username: ")
  mailserver_password = ask("Enter the monit mailserver password: ")
  alert_email = ask("Enter the monit alert email address: ")
  monit_httpd_username = ask("Enter the monit HTTPD username: ")
  monit_httpd_password = ask("Enter the monit HTTPD password: ")
  
  monitrv_template = ERB.new(File.read('config/stack/files/monitrc.erb'))
  
  push_text monitrv_template.result(binding), "/tmp/monitrc" do
    post :install, "mv -f /tmp/monitrc /etc/monitrc"
    post :install, "chown root:root /etc/monitrc"
    post :install, "chmod u=rw,go= /etc/monitrc"
  end
  
  verify do 
    has_file "/etc/monitrc"
  end
end

package :monit_init do
  description "Monit init.d script."
  requires :monit, :monit_conf
  install_path "/etc/init.d/monit"
  
  transfer "config/stack/files/monit_init.sh", "/tmp/monit" do
    post :install, "sudo mv -f /tmp/monit /etc/init.d/monit"
    post :install, "sudo chown root:root /etc/init.d/monit"
    post :install, "sudo chmod +x /etc/init.d/monit"
    post :install, "sudo /usr/sbin/update-rc.d -f monit defaults"
  end
  
  verify do 
    has_file "/etc/init.d/monit"
  end
end


package :monit_dependencies do
  description "Dependencies to build monit from source"
  apt %w(flex byacc bison)
end
