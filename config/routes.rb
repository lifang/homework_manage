HomeworkManage::Application.routes.draw do

  resources :microposts do
    get :create_reply
    member do
      get :reply_page_change,:delete_micropost,:delete_micropost_reply,:delete_micropost,:add_reply_page,:particate_reply_show
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.


  namespace :api do
    resources :students do
      collection do
        get 'add_concern','unfollow','switching_classes', 'delete_posts',
          'get_my_classes', 'into_daily_tasks', :get_microposts, :get_class_info,
          :get_answer_history, :my_microposts, :get_reply_microposts, :get_messages
        post :login, :record_person_info, :record_answer_info, :upload_avatar,:modify_person_info, :reply_message,
          :finish_question_packge, :delete_reply_microposts, :news_release, :validate_verification_code,
          :read_message, :delete_message
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
    resources :main_pages
    
    resources :results
    resources :homeworks do
      collection do
        post :delete_question_package, :publish_question_package
      end
    end
    resources :messages do
      collection do
        get :check_micropost
      end
    end

    resources :teachers do
      member do
      end

      collection do
        get :teacher_setting, :destroy_classes,:chang_class
        post :create_class, :save_updated_teacher
      end
    end

    resources :question_packages do
      resources :questions do
         resources :branch_questions
      end
    end
  end


  resources :question_packages do
    member do
      get :render_new_question
    end
    resources :questions do
      member do
        post :share, :reference
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
