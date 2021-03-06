require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    #binding.pry
    if !logged_in?
      erb :'users/create_user'
    else
      redirect '/tweets'
    end
  end

  post "/signup" do
    user = User.new(:username => params[:username], :email => params[:email], :password => params[:password])
    if user.save
      session[:user_id]= user.id
      #binding.pry
      redirect "/tweets"
    else
      redirect to '/signup'
    end
  end

  get "/login" do
    if logged_in?
       redirect to '/tweets'
    else
      erb :login
    end
  end

  post "/login" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
  	   session[:user_id] = user.id
  	   redirect '/tweets'
    else
      redirect '/login'
    end
  end

  get "/tweets" do
    if logged_in?
      @user = current_user
      @tweets = Tweet.all
      erb :'/tweets/tweets'
    else
      redirect to '/login'
    end
  end

  get '/tweets/new' do
    if logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect to '/login'
    end
  end

  post '/tweets' do
    if params[:content] != ""
      current_user.tweets.create(content: params[:content])
      redirect to "/tweets"
    else
      redirect to "/tweets/new"
    end
  end

  get '/tweets/:id' do
    if logged_in?
       @tweet=Tweet.find(params[:id])
       erb :'/tweets/show_tweet'
    else
       redirect to '/login'
    end
  end

  get '/tweets/:id/edit' do
     if logged_in?
       @tweet = Tweet.find(params[:id])
       if @tweet.user == current_user
          erb :'/tweets/edit_tweet'
       else
          redirect '/tweets'
       end
     else
       redirect '/login'
     end
  end

  patch '/tweets/:id' do
    @tweet = Tweet.find(params[:id])
    if params[:content] != ""
      @tweet.update(content: params[:content])
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/#{@tweet.id}/edit"
    end
  end

  delete '/tweets/:id/delete' do
     @tweet = Tweet.find(params[:id])
       if logged_in? && current_user == @tweet.user
         @tweet.delete
       end
       redirect to '/tweets'
   end

   get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'/users/`show`'
   end

  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
    end
  end

  helpers do
    def logged_in?
      !!current_user
    end

    def current_user
      @current_user ||= User.find_by(session[:user_id]) if session[:user_id]
    end
  end

end
