ActionController::Routing::Routes.draw do |map|

  map.with_options :controller => 'first_run' do |f|
    f.first_app_config 'firstrun/first_app_config', :action => 'new_app_config', :method => 'get'
    f.first_department 'firstrun/first_department', :action => 'new_department', :method => 'get'
    f.first_user 'firstrun/first_user', :action => 'new_user', :method => 'get'
    f.create_first_app_config 'firstrun/create_first_app_config', :action => 'create_app_config', :method => 'post'
    f.create_first_department 'firstrun/create_first_department', :action => 'create_department', :method => 'post'
    f.create_first_user 'firstrun/create_first_user', :action => 'create_user', :method => 'post'
  end

  map.login "/login", :controller => 'user_sessions', :action => 'new'
  map.logout "/logout", :controller => 'user_sessions', :action => 'destroy'

  map.resources :app_configs, :only => [:edit, :update]

  map.edit_app_config "/app_config", :controller => 'app_configs', :action => 'edit', :method => 'get'

  map.resources :punch_clocks
  map.resources :restrictions
  map.email_reminders "/email_reminders", :controller => 'payforms', :action => 'email_reminders'
  map.reminders_advanced_options "/reminders_advanced_options", :controller => 'payforms', :action => 'reminders_advanced_options'
  map.warnings_advanced_options  "/warnings_advanced_options", :controller => 'payforms', :action => 'warnings_advanced_options'

  #TODO: get rid of sessions controller and move logout action to user_session controller and name it cas_logout
  map.cas_logout "/cas_logout", :controller => 'sessions', :action => 'logout'

  # routes for managing superusers
  map.superusers "/superusers", :controller => 'superusers'
  map.add_superusers "/superusers/add", :controller => 'superusers', :action => 'add'
  map.remove_superusers "/superusers/remove", :controller => 'superusers', :action => 'remove'

  map.resources :user_sessions

  map.resources :password_resets

  map.resources :user_configs, :only => [:edit, :update]



  map.resources :sub_requests
  map.resources :notices, :collection => {:archive => :get}

  map.resources :payform_item_sets
  map.resources :payform_sets
  map.resources :department_configs, :only => [:edit, :update]

  map.resources :payforms,
                :collection => { :prune => :delete, :go => :get, :search => :post},
                :member => {:submit => :get, :approve => :get, :print => :get},
                :shallow => true do |payform|
    payform.resources :payform_items, :member => {:delete => :get}
  end

  map.resources :payform_items

  map.resources :time_slots, :member => {:rerender => :get} #TODO: What should this be nested under, if anything?

  map.resources :shifts, :new => {:unscheduled => :get, :power_sign_up => :get, :ajax_create => :post}, :collection => {:show_active => :get, :show_unscheduled => :get}, :shallow => true do |shifts|
    shifts.resource :report do |report|
      report.resources :report_items
    end
    #NOTE: "sub_requests" is a clearer model name, we use subs for routing
    shifts.resources :sub_requests, :member => {:take => :post, :get_take_info => :get},
                                    :as => "subs"
  end

  map.resources :users, :collection => {:update_superusers => :post}, :member => {:toggle => [:get, :post]} do |user|
    user.resources :punch_clocks
  end

  map.resources :reports, :member => {:popup => :get} do |report|
    report.resources :report_items
  end

  map.resources :data_types do |data_type|
    data_type.resources :data_fields
    data_type.resources :data_objects, :only => [:new, :create]
  end

  map.resources :data_objects do |data_object|
    data_object.resources :data_entries
  end

  map.resources :departments, :shallow => true do |departments|
    departments.resources :users, :collection => {:mass_add => :get, :mass_create => :post, :restore => :post, :autocomplete => :get, :search => :post, :import => :get, :save_import => :post}
    departments.resources :loc_groups
    departments.resources :locations
    departments.resources :roles
    departments.resources :categories
  end

  map.resources :user_profile_fields
#  map.connect "user_profile/:user_login", :controller => 'user_profiles', :action => "show"
  map.resources :user_profiles do |profile|
    profile.resources :user_profile_entries
  end

  map.resources :punch_clock_sets

  # permission is always created indirectly so there is only index method that lists them
  map.resources :permissions, :only => :index

  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  map.access_denied '/access_denied', :controller => 'application', :action => 'access_denied'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "dashboard"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

