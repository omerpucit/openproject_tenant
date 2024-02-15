# Prevent load-order problems in case openproject-plugins is listed after a plugin in the Gemfile
# or not at all
require 'open_project/plugins'
require 'apartment/elevators/first_subdomain'

module OpenProject::Tenant
  class Engine < ::Rails::Engine
    engine_name :openproject_tenant

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-tenant',
             :author_url => 'https://openproject.org',
             :requires_openproject => '>= 6.0.0',
             settings: {
               default: { 'cost_currency' => 'EUR', 'costs_currency_format' => '%n %u' },
               partial: 'settings/costs',
               menu_item: :costs_setting
             } do
      # Menu extensions
      menu :admin_menu,
           :tenants_admin_tenants,
           { controller: '/tenants/admin/tenants', action: :index },
           if: ->(*) {
             User.current.admin? && ::Apartment::Tenant.current_tenant && ::Apartment::Tenant.current_tenant.current_admin?
           },
           #parent: :admin_costs,
           caption: :label_tenant_plural,
           icon: 'custom-fields'
    end

    initializer "#{engine_name}.middleware" do |app|
      Apartment.configure do |config|
        config.excluded_models = %w{ Tenant }
        config.tenant_names = lambda { Tenant.pluck :id }
        config.use_schemas = true
        config.use_sql = true
      end
      app.config.middleware.use Apartment::Elevators::Subdomain
        #Rails.application.config.middleware.use Apartment::Elevators::Subdomain
    end

    initializer "open_project.apartment.override_warning_bar_helper" do
      config = OpenProject::Configuration
      Rails.application.config.session_store :cookie_store, key: config['session_cookie_name'], tld_length: 1
      ActiveSupport.on_load(:after_initialize) do
        ::WarningBarHelper.prepend OpenProject::Tenant::GemOverrides
      end
    end

  end
end
