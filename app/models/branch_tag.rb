class BranchTag < ActiveRecord::Base
  attr_accessible :name, :teacher_id
  has_many :btags_bque_relations
  has_many :branch_questions, :through => :btags_bque_relations
end
