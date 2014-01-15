module ApplicationHelper
  def authenticate_user_from_token
    authentication_token = params[:authentication_token].presence
    user = authentication_token && User.find_by_authentication_token(authentication_token)
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token])
      self.resource = user
    end
    render :status => 401, :json => {errors: [t('api.v1.token.invalid_token')]} if self.resource.nil?
  end
end
