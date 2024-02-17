# module Delayed
#   module Backend
#     module ActiveRecord
#       class Job < ::ActiveRecord::Base
#         include ::Delayed::Backend::Base
#         self.table_name = 'public.delayed_jobs'
#         set_callback :save, :before, :update_tenant_name
#
#
#         def update_tenant_name
#           p 'came here or not'
#           p 'update_tenant_name'
#           p 'update_tenant_name'
#           p 'update_tenant_name'
#           p 'update_tenant_name'
#           self.tenant_name = ::Apartment::Tenant.current
#           p 'tenant_name'
#           p tenant_name
#           p 'tenant_name'
#           p 'tenant_name'
#         end
#
#       end
#     end
#   end
# end
