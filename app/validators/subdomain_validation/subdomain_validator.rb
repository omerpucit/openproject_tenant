module SubdomainValidation
  class SubdomainValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.blank?
        record.errors.add(attribute, :blank)
        return
      end

      record.errors.add(attribute, :taken) if reserved_name.include?(value)
      record.errors.add(attribute, :too_short, count: 3) if value.length < 3
      record.errors.add(attribute, :too_long, count: 63) if value.length > 63

      record.errors.add(attribute, I18n.t('subdomain_validation.errors.messages.label')) if value =~ /[^A-Za-z0-9\-]/

      record.errors.add(attribute, I18n.t('subdomain_validation.errors.messages.first_character')) if value =~ /^-/
      record.errors.add(attribute, I18n.t('subdomain_validation.errors.messages.last_character')) if value =~ /-$/
    end

    private

    def reserved_name
      case options[:reserved_name]
      when nil
        if Rails.env.development?
          %w[www http https ftp sftp ssl ns mx pop smtp admin administrator ass fuck staging mail users host spam api]
        else
          %w[www http https ftp sftp ssl ns mx pop smtp admin administrator ass fuck mail users host spam api
           www1 www2 www3 www4 email
          ]
        end
      when false
        []
      else
        options[:reserved_name]
      end
    end
  end
end
