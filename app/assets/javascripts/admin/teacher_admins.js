
//创建教师
function admin_create_teacher(obj){
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    var teacher_name = $(obj).parents("#teacher_admin_create").find("input[name='teacher_name']").val();
    var teacher_email = $(obj).parents("#teacher_admin_create").find("input[name='teacher_email']").val();
    if(teacher_name==""){
        tishi("教师名称不能为空！");
        return false;
    }else if (teacher_email==""){
        tishi("教师邮箱不能为空！");
        return false;
    }else if(!email_reg.test(teacher_email)){
        tishi("邮箱格式不正确,请重新输入！");
        return false;
    }
    $.ajax({
        url : '/admins/teacher_admins',
        dataType : 'post',
        type : 'script',
        data : {
            teacher_name : teacher_name,
            teacher_email : teacher_email
        }
    })
}