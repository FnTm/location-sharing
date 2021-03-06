class API::V1::SessionsController < Devise::SessionsController
  include ApplicationHelper
  include Devise::Controllers::Helpers

  respond_to :json

  prepend_before_filter :require_no_authentication, :only => [:create]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :authenticate_user_from_token!, :except => :create


  def create
    return failure unless params[:user]
    resource = User.find_for_database_authentication(:email => params[:user][:email])
    return failure unless resource
    return render json: { :user => {:id => resource.id, :email => resource.email}, errors: ["api.v1.user.unconfirmed_user"]}, :status => "403" unless resource.confirmed?

    if resource.valid_password?(params[:user][:password])
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      render :json=> {:success => true, :authentication_token => resource.authentication_token, :id => resource.id}
      return
    end
    failure
  end

  def destroy
    resource = current_user
    resource.reset_authentication_token!
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render :status => 200, :json => {:success => true}
  end

  def failure
    return render json: { success: false, errors: ['api.v1.sessions.invalid_login'] }, :status => :unauthorized
  end

end
