HomeworkManage::Application.routes.draw do


  resources :microposts do
    get :create_reply
    member do
      get :reply_page_change,:delete_micropost,:delete_micropost_reply,:delete_micropost,:add_reply_page,:particate_reply_show
    end
  end
 
  post "/share_questions/view"
  # The priority is based upon order of creation:
  # first created -> highest priority.


  namespace :api do
    match 'current_version' => 'students#current_version'
    resources :students do
      collection do
        get 'add_concern','unfollow', 'delete_posts',
          'get_my_classes', 'into_daily_tasks', :get_microposts, :get_class_info,
          :get_answer_history, :my_microposts, :get_reply_microposts, :get_messages,
          :get_classmates_info, :get_more_tasks, :get_newer_task,:get_teacher_messages,
          :new_homework, :delete_message,:get_sys_message, :get_follow_microposts,
          :get_knowledges_card,:delete_knowledges_card,:card_is_full,:get_question_package_details,
          :get_my_archivements,:card_tags_list,:create_card_tag,:search_tag_card, :get_rankings,
          :knoledge_tag_relation
        post :login, :record_person_info, :record_answer_info, :upload_avatar,:modify_person_info,
          :finish_question_packge, :delete_reply_microposts, :news_release, :validate_verification_code,
          :delete_sys_message,:read_message,:search_tasks, :reply_message
      end
      member do
        
      end
    end
  end


  resources :welcome do
    collection do
      get :first,:teacher_exit
      post :create_first_class, :login, :regist
    end
  end

  resources :school_classes do
    resources :main_pages do
      collection do
        post :delete_student
        get :add_follow_microposts
      end
    end
    resources :statistics do
      collection do
        get :correct_rate
        post :checkout_by_date, :show_tag_task, :show_question_statistics,
          :show_incorrect_questions,:show_questions, :show_all_tags
      end
    end
    resources :results
    resources :homeworks do
      collection do
        post :delete_question_package, :publish_question_package
      end
    end
    resources :messages do
      collection do
        get :check_micropost, :new_message_remind,  :del_all_unread_msg
      end
    end

    resources :teachers do
      member do
      end

      collection do
        get :teacher_setting, :destroy_classes,:chang_class
        post :create_class, :save_updated_teacher,:update_password,:upload_avatar,:update_avatar
      end
    end
    resources :students do
      member do
      end
      collection do
        get :index,:delete_student,:tag_student_list,:add_student_tag,:edit_class
        post :update_class
      end
    end

    resources :tags do
      member do
      end
      collection do
        get 
        post :delete_student_tag,:choice_tags
      end
    end

    resources :question_packages do
      collection do
        get :setting_episodes, :new_time_limit,:show_wanxin, :check_time_limit,
          :new_reading_or_listening, :share_time_limit, :delete_time_limit,
          :search_b_tags, :add_b_tags,:save_branch_tag
        post :create_time_limit, :save_listening, :save_reading
      end
      member do
        get :new_index,:show_wanxin,:create_wanxin,:create_paixu,
          :show_ab_list_box,:save_wanxin_content,:save_wanxin_branch_question,
          :save_paixu_branch_question,:delete_wanxin_branch_question,:show_the_paixu,
          :delete_paixu_branch_question,:delete_branch_tag
      end
      resources :questions do
         member do
          post :share, :reference
         end
        resources :branch_questions do
          collection do
            get 
          end
        end
      end
    end
    resources :share_questions do
      collection do
        get :list_questions_by_type
      end
    end
  end

  resources :question_packages do
    member do
      get :render_new_question
    end
    resources :questions do
#      member do
#        post :share, :reference
#      end
      collection do
        get :show_branch_question
        get :show_select,:question_selects_all,:new_lianxian,:delete_branch_question
        post :save_select,:save_lianxian,:update_select,:update_lianxian,:select_upload
      end
      resources :branch_questions
    end
  end

  resources :results do
    collection do
      post :show_single_record
    end
  end



  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
