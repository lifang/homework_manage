set :use_sudo, false
set :group_writable, false
set :keep_releases, 2 # Less releases, less space wasted
set :runner, nil # thanks to http://www.rubyrobot.org/article/deploying-rails-20-to-mongrel-with-capistrano-21
set :application, "homework_manage"  #应用名称

default_run_options[:pty] = true #pty: 伪登录设备  
set :scm, :git   # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
# set :deploy_via, :copy
# 如果SCM设为空， 也可通过直接copy本地repo部署
set :repository,  "git@github.com:lifang/homework_manage.git" #项目在github上的地址
#set :ssh_options, { :forward_agent => true }  #deploy时获取github上项目使用你本地的ssh key
#set :git_shallow_clone, 1  #Shallow cloning will do a clone each time, but will only get the top commit, not the entire repository history
set :branch, "master"  #deploy的时候默认checkout master branch

#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
#require "rvm/capistrano"           # Load RVM's capistrano plugin.
#require "bundler/capistrano"       #添加之后部署时会调用bundle install， 如果不需要就可以注释掉
set :rvm_type, :user

set :default_stage, "staging"     #一般不写成production，因为写成production的时候运行touch #{current_path}/tmp/restart.txt没效果
set :stages, %w(staging sandbox production)
set :rvm_ruby_string, '1.9.3-p448@rails3.2.1'  #设置ruby具体版本号 去rvm安装目录/wrappers里面查看具体ruby版本

require 'capistrano/ext/multistage' #多stage部署所需
require 'capistrano_colors'


after("deploy:symlink") do    #after， before 表示在特定操作之后或之前执行其他任务  
 
 
end

namespace :deploy do  
  task :restart do
    #    run "chmod -R 777 /opt/projects/lantan_BAM/" # 每次deploy完给目录下新产生的文件赋权限
 # log link
  run "rm -rf #{current_path}/log"        #移除当前路径下的log文件
  run "ln -s #{shared_path}/log/ #{current_path}/log"  #link日志文件到share下的日志文件

  run "ln -s /opt/projects/homework_manage/public/* #{current_path}/public/" #链接上传的图片
  
    # database.yml for localized database connection
    run "rm #{current_path}/config/database.yml"  #移除当前路径下的数据库配置文件
    run "ln -s #{shared_path}/database.yml #{current_path}/config/database.yml"  #link数据库文件到shared目录下的yml文件

    #nginx -s reload 是重启Nginx
    #touch /tmp/restart.txt 是重启当前的Rails项目
    #Passenger会检查这个文件，如果这个文件时间戳改变了，或者被创建或者移除，Passenger就会reload。
    run "touch #{current_path}/tmp/restart.txt"
  end
end
