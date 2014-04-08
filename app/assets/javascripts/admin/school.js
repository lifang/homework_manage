// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function show_new_chool(){
    $("#system_new_school").show();
}

// 新建 学校
function system_new_school(obj){
    var system_new_school = $(obj).parents("#system_new_school");
    var school_name = system_new_school.find("input[name='school_name']").val();
    alert(school_name)
    var school_students_count = system_new_school.find("input[name='school_students_count']").val();
    var email = system_new_school.find("input[name='email']").val();
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
}

//调整配额
function adjust_quotas(obj){
    var students_count = $(obj).parents("#adjust_quotas").find("input[name='students_count']").val();
    var school_id = $(obj).parents("#adjust_quotas").find("input[name='school_id']").val()
    $.ajax({
        url : "/admin/schools/adjust_quotas",
        type : "post",
        dataType : "script",
        data : {
            students_count : students_count,
            school_id : school_id
        }
    })
}

function reset_password(obj,school_id){
    $("#update_school_password").find("input[name='school_id']").val(school_id);
    $("#update_school_password").show();
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