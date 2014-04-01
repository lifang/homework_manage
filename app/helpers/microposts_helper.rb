#encoding: utf-8
module MicropostsHelper
    def get_posts_and_replis  m_id
    @micropost = Micropost.find_by_id(m_id)
    @repiles = (ReplyMicropost::get_microposts @micropost.id,1)[:reply_microposts]
    @repile_page = (ReplyMicropost::get_microposts @micropost.id,1)[:pages_count]
    @page = (ReplyMicropost::get_microposts @micropost.id,1)[:page]
  end
end
