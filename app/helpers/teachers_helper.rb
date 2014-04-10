module TeachersHelper
#  def current_teacher
#    sql="select t.id,t.user_id,t.password,t.email,t.status,t.types,t.last_visit_class_id,u.name,u.avatar_url from teachers t left join users u on t.user_id=u.id where t.user_id=?"
#    params_arr =[sql,cookies[:user_id]]
#    @teacher ||=Teacher.find_by_sql(params_arr)[0]
#    @teacher
#  end
end
