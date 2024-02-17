require 'open_project/tenant/engine'
require 'open_project/tenant/tenancy'
require 'open_project/tenant/delayed_tenancy'
require 'open_project/tenant/delayed_perform_tenancy'
require 'open_project/tenant/override_bulk_jobs'
if defined?(Rails::Railtie)
  # Postpone initialization to railtie for correct order
  require 'open_project/tenant/active_record/railtie'
else
  # Do the same as in the railtie
  ::Delayed::Job.include(OpenProject::Tenant::DelayedPerformTenancy)
end
