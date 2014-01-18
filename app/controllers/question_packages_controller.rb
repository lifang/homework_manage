class QuestionPackagesController < ApplicationController

  def new

  end
  
  def create
    question_type, new_or_refer, cell_id, episode_id = params[:question_type], params[:new_or_refer], params[:cell_id], params[:episode_id]
    school_class_id = current_user.last_visit_class_id if current_user
    status = 0
    QuestionPackage.transaction do
      @question_pack = QuestionPackage.create(:school_class_id => school_class_id)
      if @question_pack.save
        @question = @question_pack.questions.create({:cell_id => cell_id, :episode_id => episode_id, :types => question_type.to_i})
      else
        status =  1
      end
    
      if status ==0
        render :partial => new_or_refer == "0" ? "questions/new_branch" : "questions/new_reference"
      end
    end
  end

  def update

  end
  
end