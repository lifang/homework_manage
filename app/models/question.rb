#encoding: utf-8
class Question < ActiveRecord::Base
  attr_protected :authentications
  TYPES = {:READ=> 0,:DICTATION => 1}
  TYPES_NAME = {0 => '朗读',1 => '听写'}
end
