class API::V1::RegistrationsController < Devise::RegistrationsController
  include ApplicationHelper

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_before_filter :authenticate_scope!, :only => [:update, :destroy]

  before_filter :authenticate_user_from_token!, :except => [:create]

  def create
    build_resource(sign_up_params)
    if resource.save
      return render :json => {:success => true}
    else
      clean_up_passwords resource
      return render :status => 401, :json => {:errors => resource.errors}
    end
  end

  def show
    @user = User.find_by_id params["id"]
    respond_with @user
  end

  def update
    if resource.update_with_password(account_update_params)
      sign_in resource_name, resource
      return render :json => {success: true}
    else
      clean_up_passwords resource
      return render :status => 401, :json => {errors: resource.errors}
    end
  end

  def destroy
    resource.destroy
    return render :json => {success: true}
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit( :email, :password, :password_confirmation, :current_password)
  end
end
