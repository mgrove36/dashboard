require 'dashing'

configure do
  set :auth_token, 'auth_token'
  set :default_dashboard, 'home'
  # enable :sessions

  # See http://www.sinatrarb.com/intro.html > Available Template Languages on
  # how to add additional template languages.
  set :template_languages, %i[html erb]
  set :show_exceptions, false

  helpers do
    def protected!
      # if session.include?('auth_token') && authenticated?(session['auth_token'])
      #   return
      # end
      # unless authenticated?(params['token'])
      #   response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      #   throw(:halt, [401, "Not authorized\n"])
      # end
      # session['auth_token'] = params['token']
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
