require 'test_helper'

class QuestionAdmin::ExamManagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
