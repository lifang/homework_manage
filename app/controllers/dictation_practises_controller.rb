class DictationPractisesController < ApplicationController
	def index
	end

	def new_task
		@date = params[:date]
		@school_class_id = params[:school_class_id].to_i
		
		school_class_id = params[:school_class_id]
		school_class = SchoolClass.find_by_id school_class_id, @date
		@questions = []
		p school_class
		if school_class.present?
			@question_pack = QuestionPackage.find_question_package school_class.id, @date
			current_class_question_pack = QuestionPackage.where(["school_class_id = ?", school_class.id])
			current_class_question_pack_ids = current_class_question_pack.any? ? current_class_question_pack.map(&:id) : []

			p current_class_question_pack_ids
			#我新建的题目
			@questions = Question.where(["question_package_id in (?) and if_from_reference = ?
								and	types = ?", current_class_question_pack_ids, Question::IF_FROM_REFER[:NO],  Question::TYPES[:DICTATION] ])
			p @questions

			@share_questions = ShareQuestion
						.select("share_questions.id, share_questions.name, u.name username")
						.joins("left join users u on share_questions.user_id = u.id ")
						.where(["teaching_material_id = ? and types = ?", 
						school_class.teaching_material_id.to_i, Question::TYPES[:DICTATION]])

			
			#使用统一教材的班级
			similar_material_class = SchoolClass.where("teaching_material_id = ?",
								 school_class.teaching_material_id.to_i)
			
			p similar_material_class
		end
	end

	def preview_questions
		ques_id = params[:questions_id].split("|")
		questions_id = []
		ques_id.each do |e|
			questions_id << e.to_i	
		end
		questions_id
		@questions = Question.where(["id in (?)", questions_id]).first
		# @branch_question = BranchQuestion.where(["question_id in (?)", questions_id])
		@branch_questions = []
		if @questions
			@branch_questions = @questions.branch_questions
		end	
		p @questions
		p @branch_question
	end

	def delete_branch
		branch_id = params[:branch_id]
		branch = BranchQuestion.find_by_id branch_id.to_i
		@status = false
		if branch && branch.destroy
			@branch_id = branch.id
			@status = true
		end	
		p @status 
	end	

	def new_branch
	end

	def save_branchs
	end

	def manage_questions

		render :json => {:status => 0}
	end	

		
end
