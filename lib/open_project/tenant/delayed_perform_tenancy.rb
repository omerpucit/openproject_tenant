module OpenProject
  module Tenant
    module DelayedPerformTenancy
      def invoke_job
        if tenant_name.present? && tenant_name != 'public' && ( tenant = ::Tenant.find(tenant_name.to_i) )
          tenant.switch do
            super
          end
        else
          super
        end
      end

    end
  end
end
