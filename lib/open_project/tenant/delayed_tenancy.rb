module OpenProject
  module Tenant
    module DelayedTenancy
      def self.included(klass)
        klass.send(:alias_method, :enqueue, :enqueue_with_tenant)
        klass.send(:alias_method, :enqueue_at, :enqueue_at_with_tenant)
      end

      def self.extended(klass)
        meta = class << klass; self; end
        meta.send(:alias_method, :enqueue, :enqueue_with_tenant)
        meta.send(:alias_method, :enqueue_at, :enqueue_at_with_tenant)
        klass.send(:extended, InstanceMethods)
        # meta.instance_eval do
        #  def invoke_job
        #    p 'invoke goes from here'
        #    p 'invoke goes from here'
        #    p 'invoke goes from here'
        #    p 'invoke goes from here'
        #    p 'invoke goes from here'
        #  end
        # end
      end

      def enqueue_with_tenant(job)
        enqueue_at(job, nil)
      end

      def enqueue_at_with_tenant(job, timestamp)
        options = { queue: job.queue_name }
        options[:tenant_name] = job.tenant_name if job.tenant_name.present? && job.tenant_name != 'public'
        options[:run_at] = Time.at(timestamp) if timestamp
        options[:priority] = job.priority if job.respond_to?(:priority)
        wrapper = ::ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper.new(job.serialize)
        delayed_job = Delayed::Job.enqueue(wrapper, options)
        job.provider_job_id = delayed_job.id if job.respond_to?(:provider_job_id=)
        delayed_job
      end
    end
  end
end