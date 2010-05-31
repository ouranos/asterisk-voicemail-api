module Sinatra
  module Authorization
    # Redefine this method on your helpers block to actually contain
    # your authorization logic.
    def authorize(username, password)
      false
    end

    # From you app, call set :authorization_realm, "my app" to set this
    # or define a #authorization_realm method in your helpers block.
    def authorization_realm
      settings.authorization_realm
    end

    # Call in any event that requires authentication
    def login_required
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request!  unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env["REMOTE_USER"] = auth.username
    end

    # Convenience method to determine if a user is logged in
    def authorized?
      !!request.env["REMOTE_USER"]
    end
    alias_method :logged_in?, :authorized?

    # Name provided by the current user to log in
    def current_user
      request.env["REMOTE_USER"]
    end

    private
      def auth
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
      end

      def unauthorized!(realm=authorization_realm)
        response["WWW-Authenticate"] = %(Basic realm="#{realm}")
        throw :halt, [401, "Authorization Required"]
      end

      def bad_request!
        throw :halt, [400, "Bad Request"]
      end
  end

  helpers Authorization
end
