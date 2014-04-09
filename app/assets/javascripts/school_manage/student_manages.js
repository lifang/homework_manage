function set_stu_active_status(obj, student_id, type){
    $("#waiting_warning").find("p").first().text("正在处理...");
    popup("#waiting_warning");
    $.ajax({
        type: "post",
        url: "/school_manage/student_manages/set_stu_active_status",
        dataType: "json",
        data: {
            stu_id : student_id
        },
        success: function(data){
            $(".mask").hide();
            $("#waiting_warning").hide();
            if(data.status==1){
                tishi("操作成功!");
                $(obj).removeAttr("class");
                $(obj).removeAttr("onclick");
                if(type=="open"){
                    $(obj).attr("class", "blockUp_a tooltip_html");
                    $(obj).attr("onclick", "set_stu_active_status(this, '"+student_id+"', 'close')");
                }else{
                    $(obj).attr("class", "blockUp_a_ed tooltip_html");
                    $(obj).attr("onclick", "set_stu_active_status(this, '"+student_id+"', 'open')");
                }
            }else{
                tishi("操作失败!");
            }
        },
        error: function(){
            $(".mask").hide();
            $("#waiting_warning").hide();
            tishi("数据错误!");
        }
    })
}