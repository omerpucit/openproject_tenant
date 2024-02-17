module OpenProject
  module Tenant
    module ActiveRecord
      class Railtie < ::Rails::Railtie
        config.after_initialize do
          Delayed::Job.include(::OpenProject::Tenant::DelayedPerformTenancy)
          # Bulk cron/jobs overriding goes from here...
          %w[Attachments::CleanupUncontaineredJob Cron::ClearOldSessionsJob
            Cron::ClearUploadedFilesJob Exports::CleanupOutdatedJob
            Ldap::SynchronizationJob Notifications::ScheduleDateAlertsNotificationsJob
            Notifications::ScheduleReminderMailsJob OAuth::CleanupJob
            PaperTrailAudits::CleanupJob].each do |klass|
            klass.constantize.prepend(::OpenProject::Tenant::OverrideBulkJobs)
          end
        end
      end
    end
  end
end
