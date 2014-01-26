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
                    tishi(message);
                    $(".created_new_class").css("display","none");
                    window.location.href="/school_classes/" + school_class_id + "/teachers/teacher_setting"
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
    if($.trim($("input[name='name']").val()).length == 0){
        tishi('提示:\n\n名称不能为空');
        return false;
    } 
}