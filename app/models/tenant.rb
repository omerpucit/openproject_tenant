class Tenant < ApplicationRecord
  include SubdomainValidation
  self.table_name = 'public.tenants'
  validates :name, presence: true
  validates :sub_domain, presence: true, uniqueness: { case_sensitive: false }
  validates :sub_domain, subdomain: true, uniqueness: { case_sensitive: false }

  after_create :prepare_tenant
  after_destroy :drop_tenant

  attr_accessor :username, :email, :password

  validates :username, :email, :password, presence: true, on: :create
  validates :username, format: { with: /\A[a-z0-9_\-@.+ ]*\z/i }
  validates :username, length: { maximum: 256 }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :password, length: 6..20, on: :create

  def switch
    ::Apartment::Tenant.switch(id) do
      yield if block_given?
    end
  end

  def current_admin?
    sub_domain == 'admin'
  end

  def can_destroy?
    !current_admin?
  end

  def first_email
    switch do
      User.first.mail rescue ''
    end
  end

  def first_username
    switch do
      User.first.login rescue ''
    end
  end

  private

  def prepare_tenant
    if email.blank? || password.blank? || username.blank?
      errors.add(:base, "Email/Password can't be blank")
      throw(:abort)
    end
    ::Apartment::Tenant.create(id.to_s) do
      user = new_admin
      user.save!(validate: false)
    end
    # begin
    #
    # rescue StandardError => e
    #   errors.add(:base, e.message)
    #   throw(:abort)
    # end
    # Apartment::Tenant.create(id.to_s) do
    #   # create_default_user
    # end
  end

  def drop_tenant
    Apartment::Tenant.drop(id) rescue nil
  end

  def new_admin
    User.new.tap do |user|
      user.admin = true
      user.login = username
      user.password = password
      first, last = ::Setting.seed_admin_user_name.split(' ', 2)
      user.firstname = first
      user.lastname = last
      user.mail = email
      user.language = I18n.locale.to_s
      user.status = ::User.statuses[:active]
      user.force_password_change = force_password_change?
      user.notification_settings.build(assignee: true, responsible: true, mentioned: true, watched: true)
    end
  end

  def force_password_change?
    return false if Rails.env.development?

    ::Setting.seed_admin_user_password_reset?
  end

end
