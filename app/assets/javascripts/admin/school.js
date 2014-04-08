// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function show_new_chool(){
    $("#system_new_school").show();
    $(".mask").show();
}

//减少
function reduce_a(obj){
    var val_student_count = $(obj).parents("li").find("input[name='students_count']").val()
    var number = parseInt(val_student_count)-1
    $(obj).parents("li").find("input[name='students_count']").val(number)
}
//增加
function add_a(obj){
    var val_student_count = $(obj).parents("li").find("input[name='students_count']").val()
    var number = parseInt(val_student_count)+1
    $(obj).parents("li").find("input[name='students_count']").val(number)
}
// 新建 学校
function system_new_school(obj){
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    var system_new_school = $(obj).parents("#system_new_school");
    var school_name = system_new_school.find("input[name='school_name']").val();
    var school_students_count = system_new_school.find("input[name='school_students_count']").val();
    var email = system_new_school.find("input[name='email']").val();
    if (school_name==""){
        tishi("学校名称不能为空！");
        return false;
    }else if(school_students_count==""){
        tishi("学校配额不能为空！");
        return false;
    }else if(!email_reg.test(email)){
        tishi("邮箱格式不正确,请重新输入！");
        return false;
    }
    $.ajax({
        url:"/admin/schools",
        type:"post",
        dataType : "script",
        data:{
            school_name : school_name,
            school_students_count : school_students_count,
            email : email
        },
        success: function(data){
        }
    })
}

// 显示调整配额
function add_students_count(obj,school_id,students_count){
    var school_tr = $(obj).parents(".school_tr")
    var school_name = school_tr.find(".school_name").text();
    $("#adjust_quotas").find(".tab_warning").html(school_name + "调整配额");
    $("#adjust_quotas").find("input[name='students_count']").val(students_count);
    $("#adjust_quotas").find("input[name='school_id']").val(school_id);
    $("#adjust_quotas").show();
    $(".mask").show();
}

//调整配额
function adjust_quotas(obj){
    var students_count = $(obj).parents("#adjust_quotas").find("input[name='students_count']").val();
    var school_id = $(obj).parents("#adjust_quotas").find("input[name='school_id']").val()
    if(students_count<1){
        tishi("配额必须大于0！");
        return false;
    }
    $.ajax({
        url : "/admin/schools/adjust_quotas",
        type : "post",
        dataType : "json",
        data : {
            students_count : students_count,
            school_id : school_id
        },
        success : function(data){
            tishi(data.notice)
            $("#adjust_quotas").hide();
            $(".mask").hide();
            if(data.status==1){
                tr_school_id=
                $("tr[tr_school_id='"+ school_id +"']").find(".school_student_count").html(data.count_show);
            }
        }
    })
}

function reset_password(obj,school_id){
    $("#update_school_password").find("input[name='school_id']").val(school_id);
    $("#update_school_password").show();
    $(".mask").show();
}

function update_school_password(obj){
    var password_new = $(obj).parents("#update_school_password").find("input[name='password_new']").val();
    var password_again = $(obj).parents("#update_school_password").find("input[name='password_again']").val();
    var school_id = $(obj).parents("#update_school_password").find("input[name='school_id']").val();
    if(password_new == password_again){
        $.ajax({
            url : "/admin/schools/update_school_password",
            type : "get",
            dataType : "json",
            data : {
                password_new : password_new,
                school_id : school_id
            },
            success : function(data){
                if(data.status==1){
                    alert("修改成功！");
                    $("#update_school_password").hide();
                }else{
                    alert("修改失败！")
                }
            }
        })
    }else{
        alert("两次密码输入不一致！");
    }
}

//查询学校列表
function search_schools(obj){
    var schools_name = $(obj).parents(".search").find("input[name='schools_name']").val();
    $.ajax({
        url : "/admin/schools/search_schools",
        dataType : "script",
        type : "post",
        data : {
            schools_name : schools_name
        }
    })
    
}

// 停用或者启用
function is_enable(obj,school_id){
    $.ajax({
        url : "/admin/schools/is_enable",
        dataType : "json",
        type : "post",
        data : {
            school_id : school_id
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