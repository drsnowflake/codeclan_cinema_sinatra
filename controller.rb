require('sinatra')
require('sinatra/contrib/all')

require_relative('models/film')
also_reload('./models/*')

get '/films' do
  @results = Film.all
  erb(:index)
end

get '/films/:id' do
  @results = Film.find_one(params[:id].to_i)
  erb(:details)
end
