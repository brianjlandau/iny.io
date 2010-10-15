package :dependencies do
  apt %w(libglib2.0-dev cmake libpcre3 libpcre3-dev libxml2-dev 
    libxml2 libxslt-dev sqlite3 libsqlite3-dev libgcrypt11-dev
    libreadline5-dev zlib1g-dev zlibc libedit-dev gettext logrotate
    libevent-dev libevent-1.4-2 openssl libssl-dev)
  requires :build_essential
end
