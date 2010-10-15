package :io do
  description "Io language"
  
  push_text '', '/tmp/spinkle-hack.txt' do
    pre :install, 'mkdir -p /usr/local/build'
    pre :install, "bash -c 'cd /usr/local/build && git clone git://github.com/stevedekorte/io.git > io.checkout.log 2>&1'"
    pre :install, 'mkdir -p /usr/local/build/io/io-build'
    post :install, "bash -c ' cd /usr/local/build/io/io-build && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local > io-build.log 2>&1'"
    post :install, "bash -c 'cd /usr/local/build/io/io-build && make install > io-install.log 2>&1'"
    post :install, "bash -c 'ldconfig'"
  end
  
  verify do
    has_executable_with_version "/usr/local/bin/io", 'Io Programming Language', '--version'
  end
  
  requires :git, :sgml, :dependencies, :build_essential
end

package :sgml do
  description "SGML library"
  version '1.1.4'
  
  source "http://www.hick.org/code/skape/libsgml/libsgml-#{version}.tar.gz"
end
