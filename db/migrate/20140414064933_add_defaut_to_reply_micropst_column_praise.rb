class AddDefautToReplyMicropstColumnPraise < ActiveRecord::Migration
  def change
  	change_column_default :reply_microposts, :praise, 0
  end
end
