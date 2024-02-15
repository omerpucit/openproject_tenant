module OpenProject
  module Tenant
    module GemOverrides

      def render_pending_migrations_warning?
        current_user.admin? &&
          OpenProject::Configuration.show_pending_migrations_warning? &&
          OpenProject::Database.migrations_pending?
      end

      def render_host_and_protocol_mismatch?
        current_user.admin? &&
          OpenProject::Configuration.show_setting_mismatch_warning? &&
          (setting_protocol_mismatched? || setting_hostname_mismatched?)
      end

      def render_workflow_missing_warning?
        current_user.admin? &&
          EnterpriseToken.allows_to?(:work_package_sharing) &&
          no_workflow_for_wp_edit_role?
      end

      def setting_protocol_mismatched?
        false
          #request.ssl? != OpenProject::Configuration.https?
      end

      def setting_hostname_mismatched?
        false
          #Setting.host_name.gsub(/:\d+$/, '') != request.host
      end

      def no_workflow_for_wp_edit_role?
        workflow_exists = OpenProject::Cache.read('no_wp_share_editor_workflow')

        if workflow_exists.nil?
          workflow_exists = Workflow.exists?(role_id: Role.where(builtin: Role::BUILTIN_WORK_PACKAGE_EDITOR).select(:id))
          OpenProject::Cache.write('no_wp_share_editor_workflow', workflow_exists) if workflow_exists
        end

        !workflow_exists
      end

      ##
      # By default, never show a warning bar in the
      # test mode due to overshadowing other elements.
      def show_warning_bar?
        OpenProject::Configuration.show_warning_bars?
      end
    end
  end
end
