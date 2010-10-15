package :redis do
  description 'Redis Database'
  version '2.0.2'
  source "http://redis.googlecode.com/files/redis-#{version}.tar.gz" do
    pre :install, "mkdir -p /usr/local/bin"
    pre :install, "mkdir -p /usr/local/var/run"
    pre :install, "mkdir -p /usr/local/var/log"
    pre :install, "mkdir -p /usr/local/var/db/redis"
    pre :install, "mkdir -p /usr/local/etc"
    
    custom_install ["make install"]
  end
  
  verify do
    has_directory '/usr/local/etc'
    has_directory '/usr/local/var/log'
    has_directory '/usr/local/var/run'
    has_directory '/usr/local/var/db/redis'
    has_executable '/usr/local/bin/redis-server'
    has_executable '/usr/local/bin/redis-cli'
    has_executable '/usr/local/bin/redis-benchmark'
    has_executable '/usr/local/bin/redis-check-dump'
    has_executable '/usr/local/bin/redis-check-aof'
  end
  
  requires :build_essential
end

package :redis_conf do
  descript "Custom Redis Config file"
  
  transfer 'config/stack/files/redis.conf', '/tmp/redis.conf' do
    post :install, "mv -f /tmp/redis.conf /usr/local/etc/redis.conf"
  end
  
  verify do
    has_file "/usr/local/etc/redis.conf"
  end
end

package :redis_init do
  descript "Custom Redis init file"
  
  transfer 'config/stack/files/redis-init.sh', '/tmp/redis' do
    post :install, "mv -f /tmp/redis /etc/init.d/redis"
    post :install, "chmod +x /etc/init.d/redis"
    post :install, "/usr/sbin/update-rc.d -f redis defaults"
    post :install, "/etc/init.d/redis start"
  end
  
  verify do
    has_executable "/etc/init.d/redis"
  end
end
