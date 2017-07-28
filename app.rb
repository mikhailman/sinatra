require 'sinatra'
require 'sinatra/activerecord'
# require './config/environments' #database configuration
require './models/user' # Model class
require 'net/http'
VK_SECRET_KEY = '2dkR4pzH4jQzD9amHZmN'
enable :session

get '/' do
	erb :index
end

post '/submit' do
	@model = User.new(name: params['user']['name'], password: params['user']['password'])
	if @model.save
		redirect '/models'
	else
		"Sorry, there was an error!"
	end
end

get '/login' do
	code = params[:code]
	uri = URI("https://oauth.vk.com/access_token?client_id=6111872&client_secret=#{VK_SECRET_KEY}&redirect_uri=http://localhost:4567/login&code=#{code}")
	vk_token = Net::HTTP.get(uri)
 	access_token = JSON.parse(vk_token)['access_token']
	expires_in = JSON.parse(vk_token)['expires_in']
 	user_id = JSON.parse(vk_token)['user_id']

	session[:name] = user_id.to_s
	uri = URI("https://api.vk.com/method/users.get?user_ids=#{session[:name]}&fields=bdate&v=5.67")
	user_name_vk = Net::HTTP.get(uri)
	json_name = JSON.parse(user_name_vk)['response'][0]['first_name']
	return "Привет #{json_name}"

end

get '/hello' do
	#uri = URI("https://api.vk.com/method/users.get?user_ids=#{session[:name]}&fields=bdate&v=5.67")
	#vk_token = Net::HTTP.get(uri)
	"привет #{session[:name]} <br> <a href='/models'>афафа</a>"
	#https://api.vk.com/method/users.get?user_ids=210700286&fields=bdate&v=5.67
	#@models = User.all
	#erb :models
end

get '/models' do
	@models = User.all
	erb :models
end
