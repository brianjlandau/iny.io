set :application, "iny.io"
set :deploy_to, "/var/www/#{application}"

set :user, "deploy"

set :repository,  "git://github.com/brianjlandau/iny.io.git"
set :scm, :git
set :branch, "origin/master"
set :ssh_options, {:forward_agent => true}
set :use_sudo, false

set(:latest_release) { fetch(:current_path) }
set(:release_path) { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision) { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

default_run_options[:shell] = 'bash'

role :web, "173.255.226.28"                          # Your HTTP server, Apache/etc
role :app, "173.255.226.28"                          # This may be the same as your `Web` server

namespace :deploy do
  desc "Deploy"
  task :default do
    update
    restart
  end
  
  task :cold do
    update
    restart
  end
  
  desc "Setup a GitHub-style deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "git clone #{repository} #{current_path}"
    run "chmod -R g+w #{current_path}"
  end
  
  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  end
  
  task :update do
    transaction do
      update_code
    end
  end
  
  desc "Restart"
  task :restart, :except => { :no_release => true } do
    run 'if ps -efa | grep -v grep | grep "io iny.io" > /dev/null; then killall -9 io; fi'
    run "cd #{current_path}; io iny.io -d >/dev/null 2>&1 &"
  end
  
  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end
