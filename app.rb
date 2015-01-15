require 'sinatra'
require 'sequel'

DB = Sequel.connect('sqlite://database.db')

get "/create" do
  DB.create_table :account do
    primary_key :id
    string :uname
    string :password
    BLOB :image
  end
  redirect "/"
end
get "/drop" do
  DB.drop_table("account")
  redirect "/create"
end
get "/" do
  @accounts = DB[:account]
  @accounts.all.each do |x|
    puts x[:id]
    puts x[:uname]
    puts x[:password]
  end
  erb :home
end
get "/profile" do
  erb :profile
end
get "/baduser" do
  @accounts = DB[:account]
  @accounts.all.each do |x|
    puts x[:id]
    puts x[:uname]
    puts x[:password]
  end
  erb :invaliduser
end
get "/usertaken" do
  erb :usertaken
end
get "/loginfail" do
  erb :loginfail
end
post "/register" do
  @accounts = DB[:account]
  uname=params['uname']
  password=params['password']
  user = @accounts[:uname => uname]
  if user == nil
    @accounts.insert(:uname => uname, :password => password)
  else
    redirect "/usertaken"
  end
  redirect "/"
end
post "/login" do
  @accounts = DB[:account]
  uname=params['uname'].chomp
  password=params['password'].chomp

  user = @accounts[:uname => uname]
  if user == nil
    redirect "/baduser"
  elsif user[:password] == password
    redirect "/profile"
  else
    redirect "/loginfail"
  end
end
post "/upload" do
  @account = DB[:account]
  #Upload to local directory
  File.open('public/uploads/' + params['image'][:filename], "w") do |f|
    f.write(params['image'][:tempfile].read)
  end
  @image=params[:filename]
  #@accounts.insert(:image => image)
  redirect "/profile"
end