class API::V1::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper

  respond_to :json

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_scope!, :only => [:update, :destroy]

  before_filter :authenticate_user_from_token!, :except => [:create, :confirm_user, :resend_confirmation_instructions]

  def create
    build_resource(sign_up_params)
    if resource.save
      render :json => {:success => true}
    else
      clean_up_passwords resource
      render :status => 401, :json => {:errors => resource.errors}
    end
  end

  def show
    render :json => current_user.as_json(only: [:id, :name, :email, :latitude, :longitude])
  end

  def update
    resource = current_user
    if resource.update_with_password(account_update_params)
      sign_in resource_name, resource
      render :json => {success: true}
    else
      clean_up_passwords resource
      render :status => 401, :json => {errors: current_user.errors}
    end
  end

  def destroy
    resource = current_user
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource)
    resource.destroy
    render :json => {success: true}
  end

  def update_location
    if current_user.update_without_password(location_update_params)
      render :json => {success: true}
    else
      render :status => 401, :json => {errors: current_user.errors}
    end
  end

  def confirm_user
    user = User.find_by_id params[:id]
    if User.confirm_by_token params[:confirmation_token]
      render :status => 200, :json => {success: true}
    else
      render :status => 401, :json => {errors: user.errors}
    end
  end

  def resend_confirmation_instructions
    user = User.find_by_id params[:id]
    if user and !user.confirmed? and user.resend_confirmation_instructions
      render :status => 200, :json => {success: true}
    else
      render :status => 403, :json => {errors: 'api.v1.user.user_already_confirmed'}
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit( :email, :password, :password_confirmation, :current_password)
  end

  def location_update_params
    params.require(:user).permit( :latitude, :longitude)
  end
end
