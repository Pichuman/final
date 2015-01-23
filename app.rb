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
    @uname=uname
    redirect "/profile"
  else
    redirect "/loginfail"
  end
end


=begin
post "/upload" do
  @accounts = DB[:account]
  #Upload to local directory
  #File.open('public/uploads/' + params['image'][:filename], "w") do |f|
   # f.write(params['image'][:tempfile].read)
  #end
  #image=params['image'][:tempfile].read
  f = File.new("public/images/Dog001.bmp","rb")
  image = f.read
  f.close
  blob = SQLite3::Blob.new image
  @accounts.insert(:image => blob)
  redirect "/profile"
end

=end

post "/upload" do
  db = SQLite3::Database.open 'database.db'
  #Upload to local directory
  File.open('public/uploads/' + params['image'][:filename], "w") do |f|
   f.write(params['image'][:tempfile].read)
  end
  name=params['uname']
  pic=params['image'][:filename]
  a = File.new("public/uploads/" + pic,"rb")
  image = a.read
  a.close
  blob = SQLite3::Blob.new image
  db.execute("UPDATE account SET image=(?) WHERE uname=(?)", blob, name)
end