module OpenProject
  module Tenant
    module OverrideBulkJobs
      def perform(*)
        ::Tenant.find_each do |tenant|
          tenant.switch do
            super
          end
        end
      end

    end
  end
end
