class Teacher < ActiveRecord::Base
  has_many :school_classes, :dependent => :destroy
end
