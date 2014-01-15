class User < ActiveRecord::Base
  has_many :students
  has_many :teachers
end
