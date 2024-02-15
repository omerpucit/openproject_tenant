class Tenants::Admin::TenantsController < ApplicationController
  layout 'admin'

  model_object ::Tenant
  before_action :require_admin, :require_admin_sub_domain
  before_action :find_model_object,
                only: %i[show destroy edit confirm_destroy update]

  menu_item :tenants_admin_tenants

  helper :sort
  include SortHelper

  def index
    sort_init 'name', 'asc'
    sort_columns = { 'name' => "#{Tenant.table_name}.name",
                     'sub_domain' => "#{Tenant.table_name}.sub_domain"
                   }
    sort_update sort_columns

    @tenants = Tenant.order(sort_clause)

    if params[:clear_filter]
      @fixed_date = Date.today
      @include_deleted = nil
    else
      @fixed_date = begin
        Date.parse(params[:fixed_date])
      rescue StandardError
        Date.today
      end
      @include_deleted = params[:include_deleted]
    end

    render action: 'index', layout: !request.xhr?
  end

  def new
    @tenant = Tenant.new

    render action: 'edit', layout: !request.xhr?
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      flash[:notice] = 'Created new tenant'
      redirect_to action: 'index'
    else
      flash[:error] = 'Cannot create new tenant'
      render action: 'edit', layout: !request.xhr?
    end
  end

  def destroy
    if @tenant.can_destroy?
      @tenant.destroy
    else
      flash[:error] = 'Cannot delete admin tenant'
    end
    redirect_back_or_default(action: 'index')
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name, :sub_domain, :email, :password, :username)
  end

  def require_admin_sub_domain
    is_allowed = ::Apartment::Tenant.current_tenant && ::Apartment::Tenant.current_tenant.current_admin?
    unless is_allowed
      return deny_access
    end
  end

end
