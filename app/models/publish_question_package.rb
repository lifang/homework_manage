#encoding: utf-8
class PublishQuestionPackage < ActiveRecord::Base
  attr_protected :authentications
  STATUS = {:RELEASE => 1,:UNPUBLISHED => 0,:EXPIRED => 2}
  STATUS_NAME = {0 => '未发布',1 => '发布',2 => '过期'}
end
