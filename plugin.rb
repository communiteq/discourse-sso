
module DiscourseSSO
  module ControllerExtensions
    def self.included(klass)
      klass.append_before_filter :sso_login
    end

    private

    def sso_login

      if request["sso"].present?

        # if we don't have a secret, create one
        secret = SiteSetting.sso_shared_secret
        unless secret.present?
          secret = SecureRandom.hex(32)
          SiteSetting.send('sso_shared_secret=', secret)
        end

        # get the payload and split it
        sso = Base64.decode64 request["sso"]
        userid, ts, ip, signature = sso.split(':')

        # calculate the check digest and quit if it doesn't match
        check = Digest::SHA2.hexdigest("#{userid}:#{ts}:#{ip}:#{secret}")
        return if (check != signature)

        # quit if the timestamp is too far off
        tdiff = ts.to_i - Time.now.to_i
        return if tdiff.abs > 180

        # find out what kind of user data we have (email, id or username) and load
        if userid.include? '@'
          user = User.where(email: userid.downcase).first
        elsif userid.to_i.to_s == userid
          user = User.where(id: userid.to_i).first
        else
          user = User.where(username_lower: userid.downcase).first
        end

        # got it? log on and refresh
        if user.present?
          log_on_user(user)
          redirect_to url_for
        else
          reset_session
          cookies[:_t] = nil
        end

      end
    end

  end
end

ActiveSupport.on_load(:action_controller) do
  include DiscourseSSO::ControllerExtensions
end
