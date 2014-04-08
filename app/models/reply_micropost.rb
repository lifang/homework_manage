#encoding: utf-8
require 'will_paginate/array'
class ReplyMicropost < ActiveRecord::Base
  attr_protected :authentications
  belongs_to :micropost, :counter_cache => true
  PER_PAGE = 10

  #获取子消息（分页）
  def self.get_microposts micropost_id, page
    base_sql = "select r.id, r.content, r.sender_id, r.sender_types, r.reciver_id, DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i:%S') as new_created_at, s.name sender_name,
              s.avatar_url sender_avatar_url, u.name reciver_name, u.avatar_url reciver_avatar_url
              from microposts m left join reply_microposts r on m.id = r.micropost_id left join
              users s on r.sender_id = s.id left join users u on r.reciver_id = u.id
              where r.id is not null and m.id = #{micropost_id}  order by r.created_at desc"
    page_count = 0
    microposts = Micropost.find_by_sql(base_sql).paginate(:page => page, :per_page => PER_PAGE)
    return_info = {:page => page, :pages_count => microposts.total_pages, :reply_microposts => microposts}
  end
end
