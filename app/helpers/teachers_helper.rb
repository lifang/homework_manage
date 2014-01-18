module TeachersHelper
  def current_teacher
    sql="select t.id,t.user_id,t.password,t.email,t.status,t.types,u.name,u.avatar_url from teachers t left join users u on t.user_id=u.id where t.id=?"
    params_arr =[sql,session[:user_id] ]
    teacher =Teacher.find_by_sql(params_arr)[0]
    
    teacher
  end
end
