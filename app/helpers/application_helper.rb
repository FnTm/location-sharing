module ApplicationHelper

  def authenticate_user_from_token!
    authentication_token = params[:authentication_token].presence
    user = authentication_token && User.find_by_authentication_token(authentication_token)
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token])
      if !user.confirmed?
        render :status => 403, :json => {errors: ["api.v1.user.unconfirmed_user"]}
      else
        sign_in user
      end
    else
      sign_out user
    end
    render :status => 401, :json => {errors: ['api.v1.token.invalid_token']} if current_user.nil?
  end
end
