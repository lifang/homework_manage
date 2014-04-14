set :user, "deploy"                            #cap deploy的操作用户
set :deploy_to, "/opt/projects/homework_manage"     #服务器上项目位置
set :current_path, "#{deploy_to}/current"
set :shared_path, "#{deploy_to}/shared"
role :web, "58.240.210.42"                          # Your HTTP server, Apache/etc
role :app, "58.240.210.42"                          # This may be the same as your `Web` server
role :db,  "58.240.210.42", :primary => true # This is where Rails migrations will run
set :rails_env, 'production'