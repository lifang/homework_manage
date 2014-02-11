function show_list_class(){
    if($("#schoolclasses_count").attr("schoolclasses")<=1){
        var message = "暂无班级可切换";
        tishi(message);
    }else{
        $(".list_classes").show();
    }
}
function created_new_class(){
    $(".created_new_class").show();
}
function create_school_class(school_class_id){
    var teaching_material_id = $("select[name='teaching_material_id']").val();
    var class_name = $("input[name='class_name']").val();
    var period_of_validity = $("input[name='period_of_validity']").val();
    var message;
    alert(school_class_id)
    if (class_name==""){
        message = "请输入班级名称"
        tishi(message);
        return false;
    }
    if (period_of_validity==""){
        message = "请选择结束时间";
        tishi(message);
    }else{
        $.ajax({
            url : "/school_classes/" + school_class_id + "/teachers/create_class",
            type:'post',
            dataType : 'json',
            data : {
                teaching_material_id : teaching_material_id,
                class_name : class_name,
                period_of_validity : period_of_validity
            },
            success: function(data){
                if(data.status==true){
                    message = data.notice;
                    $(".created_new_class").css("display","none");
                    tishi(message);
                    setTimeout('',2000);
                    window.location.href="/school_classes/" + school_class_id + "/teachers/teacher_setting";
                //                    $(".create_success").show();
                }else{
                    message = data.notice;
                    tishi(message);
                }
            },
            error:function(){
                alert()
            }
        });
    }
}

function check_nonempty(){
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    if($.trim($("input[name='name']").val()).length == 0){
        tishi('提示:\n\n名称不能为空');
        return false;
    }else if(!email_reg.test($.trim($("input[name='email']").val()))){
        tishi("邮箱格式不正确,请重新输入！");
        return false;
    }
}
function show_update_password(){
    $(".update_password").show();
}
function update_password(school_class_id){
    var password_now = $("input[name='password_now']").val();
    var password_update = $("input[name='password_update']").val();
    var password_update_agin = $("input[name='password_update_agin']").val();

    if($.trim(password_update).length<6 || $.trim(password_update_agin).length<6){
        tishi("密码长度不能小于6位数");
        return false;
    }
    $.ajax({
        url : "/school_classes/" + school_class_id + "/teachers/update_password",
        type:'post',
        dataType : 'json',
        data : {
            password_now : password_now,
            password_update : password_update,
            password_update_agin : password_update_agin
        },
        success: function(data){
            if(data.status==true){
                message = data.notice;
                tishi(message);
                $(".update_password").css("display","none");
                setTimeout('',2000)
                window.location.href="/school_classes/" + school_class_id + "/teachers/teacher_setting";

            }else{
                message = data.notice;
                tishi(message);
            }
        }
    })
}