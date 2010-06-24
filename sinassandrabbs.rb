# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'uuidtools'
require 'cassandra'
include Cassandra::Constants

get '/' do
  ca = Cassandra.new('BBS')
  @data = ca.get(:View,'room02').map do |k,v|
    ca.get(:Entry,v)
  end
  erb :index
end

get '/add' do
  erb :add
end

post '/post' do
  data = {}
  data['id'] = UUIDTools::UUID.random_create().to_s
  data['subject'] = params['subject']
  data['content'] = params['content']
  data['createdAt'] = Time.now.to_i.to_s
  ca = Cassandra.new('BBS')
  ca.insert(:Entry,data['id'],data)
  ca.insert(:View,'room02',{data['createdAt']=>data['id']})
  redirect '/'
end

get '/view/:id' do
  ca = Cassandra.new('Keyspace1')
  @data = ca.get(:Standard1,params['id'])
  erb :view
end

__END__

@@ index
<table border='1'>
<tr><th>title</th><th>content</th><th>created</th></tr>
<% @data.each do |row| %>
<tr>
<td><a href="/view/<%= row['id'] %>"><%= row['subject'] %></a></td>
<td><%= row['content'] %></td>
<td><%= Time.at(row['createdAt'].to_i).strftime "%Y/%m/%d %H:%M:%S" %></td>
</tr>
<% end %>
</table>
<a href='/add'>投稿</a>

@@ add
<form action='/post' method='post'>
件名：<input type='text' name='subject'/><br/>
本文：<textarea name='content'></textarea>
<input type='submit' value='投稿'/>
</form>

@@ view
<table border='1'><tr><th>id</th><td><%= @data['id'] %></td></tr>
<tr><th>title</th><td><%= @data['subject'] %></td></tr>
<tr><th>content</th><td><%= @data['content'] %></td></tr>
<tr><th>createdAt</th><td><%= Time.at(@data['createdAt'].to_i).strftime "%Y/%m/%d %H:%M:%S" %></td></tr>
</table>
<a href='/'>一覧</a>
