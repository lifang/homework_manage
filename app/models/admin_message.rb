#encoding: utf-8
class AdminMessage < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:NOMAL => 0, :READED => 1} #0未阅读  1已阅读
  STATUS_NAME = {0 => "未读", 1 => "已读"} #0未阅读  1已阅读
end