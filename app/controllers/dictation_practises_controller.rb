class DictationPractisesController < ApplicationController
	#
	def index
	end

	def new_task
		@date = params[:date]
		school_class_id = params[:school_class_id]
		school_class = SchoolClass.find_by_id school_class_id
		@lessons = []
		if school_class.present?
			@lessons = Question.where("types = ")
		end
	end
end
