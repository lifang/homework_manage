//阻止冒泡
function stopPropagation(e) {
    e = e || window.event;
    if(e.stopPropagation) { //W3C阻止冒泡方法
        e.stopPropagation();
    } else {
        e.cancelBubble = true; //IE阻止冒泡方法
    }
}
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
        url : '/school_manage/teacher_manages',
        dataType : 'script',
        type : 'post',
        data : {
            teacher_name : teacher_name,
            teacher_email : teacher_email
        }
    })
}
//重设教师密码
function reset_teacher_password(obj,teacher_id){
    $("#reset_teacher_password").find("input[name='teacher_id']").val(teacher_id);
    $("#reset_teacher_password").show();
    $(".mask").show();
}

//重设教师密码
function update_teacher_password(obj){
    var password_new = $(obj).parents("#reset_teacher_password").find("input[name='password_new']").val();
    var password_again = $(obj).parents("#reset_teacher_password").find("input[name='password_again']").val();
    var teacher_id = $(obj).parents("#reset_teacher_password").find("input[name='teacher_id']").val();
    if(password_new == password_again){
        $.ajax({
            url : "/school_manage/teacher_manages/update_password",
            type : "post",
            dataType : "json",
            data : {
                password_new : password_new,
                teacher_id : teacher_id
            },
            success : function(data){
                if(data.status==1){
                    tishi("修改成功！");
                    $("#reset_teacher_password").hide();
                    $(".mask").hide();
                }else{
                    tishi("修改失败！")
                }
            }
        })

    }else{
        tishi("两次密码输入不一致！");
    }
}

// 显示班级过户
function show_class_transfer(obj){
    $("#class_transfer").show();

}

// 是否禁用教师
function is_disable(obj,teacher_id){
    var content_tishi = "";
    if($(obj).attr("class").indexOf("blockUp_a_ed")>=0){
        content_tishi = "确认启用？"
    }else{
        content_tishi = "确认停用？";
    }
    if(confirm(content_tishi)){
        $.ajax({
            url : "/school_manage/teacher_manages/is_disable",
            dataType : "json",
            type : "post",
            data : {
                teacher_id : teacher_id
            },
            success : function(data){
                if(data.status==1){
                    $(obj).attr("class","blockUp_a_ed tooltip_html");
                    tishi(data.notice);
                }else if (data.status==2){
                    $(obj).attr("class","blockUp_a tooltip_html");
                    tishi(data.notice);
                }else{
                    tishi(data.notice);
                }
            }
        })
    }
}
//搜索老师
function sercher_teacher(obj){
    var teacher_name = $(obj).parents(".search").find("input[name='teacher_name']").val();
    window.location.href="/school_manage/teacher_manages?teacher_name="+teacher_name
}