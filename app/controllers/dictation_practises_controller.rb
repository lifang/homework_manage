class DictationPractisesController < ApplicationController
	#
	def index
	end

	def new_task
		@date = params[:date]
	end
end
