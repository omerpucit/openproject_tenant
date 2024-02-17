module OpenProject
  module Tenant
    module Tenancy
      def self.included(klass)
        klass.send(:attr_accessor, :tenant_name)
      end

      def enqueue(options = {})
        tenant_name = if ::Apartment::Tenant.current.present? && ::Apartment::Tenant.current != 'public'
                        ::Apartment::Tenant.current
                      end
        self.tenant_name = tenant_name if tenant_name.present?
        super
      end
    end
  end
end