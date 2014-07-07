class DictationPractisesController < ApplicationController
	include DictationPractisesHelper
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
			@questions = Question
							.select("questions.name,  questions.id, u.name username")
							.joins("left join question_packages qp on questions.question_package_id = qp.id ")
							.joins("left join school_classes sc on qp.school_class_id = sc.id ")
							.joins("left join teachers t on sc.teacher_id = t.id ")
							.joins("left join users u on t.user_id = u.id ")
							.where(["questions.question_package_id in (?) and questions.if_from_reference = ?
								and	questions.types = ?", current_class_question_pack_ids,
								 Question::IF_FROM_REFER[:NO],  Question::TYPES[:DICTATION] ])
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
			questions_id << e.scan(/[0-9]+$/).first.to_i
		end
		p questions_id
		@questions = Question.where(["id in (?)", questions_id])
		# @branch_question = BranchQuestion.where(["question_id in (?)", questions_id])
		@branch_questions = []
		if @questions.first.present?
			@branch_questions = @questions.first.branch_questions
		end	
		p @questions.first
		p @branch_questions
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

	def new_question
	end	

	def new_branch
	end

	def save_branchs
	end

	def manage_questions
		question_package_id = params[:question_package_id].to_i
		@questions_ids_collect = params[:questions_id].split("|")
		@act = params[:act]
		questions_id = []
		share_questions_id = []
		school_class_id = params[:school_class_id]
		school_class = SchoolClass.find_by_id school_class_id
		teacher = Teacher.find_by_id school_class.teacher_id
		user = teacher.user
		
		@add_questions = []
		if @act == "add"
			@questions_ids_collect.each do |id_str|
				str = id_str.split("__")
				if str[0] == "share_questions"
					share_questions_id << str[1].to_i
				elsif str[0] == "questions"
					questions_id << str[1].to_i
				end
			end
			share_questions = ShareQuestion.where(["id in (?)", share_questions_id])
			questions = Question.where(["id in (?)", questions_id])
			share_questions.each do |que|
				tmp = Question.create(:name => que.name, :types => que.types, 
					:question_package_id => question_package_id, :cell_id => 1, 
					:episode_id => 1, :if_shared => Question::IF_SHARED[:NO],
					:if_from_reference =>  Question::IF_FROM_REFER[:YES], 
					:status => Question::STATUS[:NORMAL])
				que.share_branch_questions.each do |bq|
					tmp.branch_questions.create(:types => que.types, 
						            :resource_url => bq.resource_url, 
									:translation => bq.translation)
				end	
				@add_questions << {:origin_table => "share_questions", :origin_id => que.id, 
					:new_id => tmp.id, :name => tmp.name, :username => user.name}
			end
			questions.each do |que|
				tmp = Question.create(:name => que.name, :types => que.types, 
					:question_package_id => question_package_id, :cell_id => 1, 
					:episode_id => 1, :if_shared => Question::IF_SHARED[:NO],
					:if_from_reference =>  Question::IF_FROM_REFER[:YES], 
					:status => Question::STATUS[:NORMAL])
				que.branch_questions.each do |bq|
					tmp.branch_questions.create(:types => que.types, 
						            :resource_url => bq.resource_url,
									:translation => bq.translation)
				end	
				@add_questions << {:origin_table => "questions", :origin_id => que.id, 
					:new_id => tmp.id, :name => tmp.name, :username => user.name}
			end
		elsif @act == "delete"
			delete_questions_id = []
			@questions_ids_collect.each do |id_str|	
				if id_str.match("share_questions") != nil
					delete_questions_id << id_str.scan(/[0-9]+$/).first.to_i
					share_questions_id << id_str.scan(/(?<=share_questions__)[0-9]+(?=__[0-9]+)/).first.to_i
				elsif id_str.match("questions") != nil
					delete_questions_id << id_str.scan(/[0-9]+$/).first.to_i
					questions_id << id_str.scan(/(?<=questions__)[0-9]+(?=__[0-9]+)/).first.to_i
				end	
			end
			Question.where(["id in (?)", delete_questions_id]).delete_all
			ques = []
			share_ques = []
			if questions_id.present?
				ques = Question
						.select("u.name username, questions.name, questions.id")
						.joins("left join question_packages qp on questions.question_package_id = qp.id")
						.joins("left join school_classes sc on qp.school_class_id = sc.id")
						.joins("left join teachers t on sc.teacher_id = t.id")
						.joins("left join users u on t.user_id = u.id")
						.where(["questions.id in (?)", questions_id])
			end		
			if share_questions_id.present?	
				share_ques = ShareQuestion
						.select("u.name username, share_questions.name, share_questions.id")
						.joins("left join users u on share_questions.user_id = u.id")
						.where(["share_questions.id in (?)", share_questions_id])
			end			
			ques.each do |que|
				@add_questions << {:origin_table => "questions", :origin_id => que.id, 
									 :name => que.name, :username => que.username} 	
			end	
			share_ques.each do |que|
				@add_questions << {:origin_table => "share_questions", :origin_id => que.id, 
									 :name => que.name, :username => que.username} 	
			end	
		end
	end
end
