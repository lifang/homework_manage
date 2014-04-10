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
function show_class_transfer(obj,teacher_id){
    $.ajax({
        url : "/school_manage/teacher_manages/list_class_and_teacher",
        type : "post",
        dataType : "script",
        data : {
            teacher_id : teacher_id
        }
    })
    
}
//确定过户
function confirm_transfer(obj){
    var select_school_class_id = $(obj).parents("#class_transfer").find("select[name='select_school_class_id']").val();
    var select_teacher_id = $(obj).parents("#class_transfer").find("select[name='select_teacher_id']").val();
    $.ajax({
        url : "/school_manage/teacher_manages/confirm_transfer",
        type : "post",
        dataType : "json",
        data : {
            select_school_class_id : select_school_class_id,
            select_teacher_id : select_teacher_id
        },
        success : function(data){
            if(data.status==1){
                tishi(data.notice);
                $("#class_transfer").hide();
                $(".mask").hide();
                window.location.reload();
            }else{
                tishi(data.notice)
            }
        }
    })
}
// 提示是否启用或者禁用
function tishi_is_able(obj,teacher_id){
    var content_tishi = "";
    if($(obj).attr("class").indexOf("blockUp_a_ed")>=0){
        content_tishi = "启用"
    }else{
        content_tishi = "停用";
    }
    $("#shifoutingyong").find(".tab_head").text(content_tishi + "教师");
    $("#shifoutingyong").find(".tab_warning").text("确认"+content_tishi + "改教师吗？");
    $("#shifoutingyong").find("button").attr("onclick","is_disable(this,"+teacher_id+")");
    $("#shifoutingyong").show();
}

// 是否禁用教师
function is_disable(obj,teacher_id){
    //    var content_tishi = "";
    //    if($(obj).attr("class").indexOf("blockUp_a_ed")>=0){
    //        content_tishi = "确认启用？"
    //    }else{
    //        content_tishi = "确认停用？";
    //    }
    //    if(confirm(content_tishi)){
    $.ajax({
        url : "/school_manage/teacher_manages/is_disable",
        dataType : "json",
        type : "post",
        data : {
            teacher_id : teacher_id
        },
        success : function(data){
            if(data.status==1){
                $("a[teacher_id="+ teacher_id +"]").attr("class","blockUp_a_ed tooltip_html");
                //                    $(obj).attr("class","blockUp_a_ed tooltip_html");
                tishi(data.notice);
                 $("#shifoutingyong").hide();
            }else if (data.status==2){
                $("a[teacher_id="+ teacher_id +"]").attr("class","blockUp_a tooltip_html");
                //                    $(obj).attr("class","blockUp_a tooltip_html");
                tishi(data.notice);
                 $("#shifoutingyong").hide();
            }else{
                tishi(data.notice);
            }
        }
    })
//    }
}
//搜索老师
function sercher_teacher(obj){
    var teacher_name = $(obj).parents(".search").find("input[name='teacher_name']").val();
    window.location.href="/school_manage/teacher_manages?teacher_name="+teacher_name
}
