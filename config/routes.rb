Rails.application.routes.draw do
  namespace :admin do
    namespace :settings do
      resources :tenants, controller: '/tenants/admin/tenants'
    end
  end

  # Create a route that is handled completely in the frontend
  # with a helper controller that just renders a plain page for the frontend
  # to hook into with its own route
  get '/multi_tenant', to: 'angular#empty_layout'
end
