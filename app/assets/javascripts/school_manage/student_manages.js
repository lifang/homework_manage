function set_stu_status(student_id, type){   //点击设置停用或启用学生弹出层
    var head_con = ""
    var con = "";
    if(type=="open"){
        head_con = "启用学生"
        con = "你确定启用该学生吗?";
    }else if(type=="close"){
        head_con = "停用学生"
        con = "你确定停用该学生吗?";
    };
    $("#set_stu_active_status_div").find("div.tab_head").first().text(head_con);
    $("#set_stu_active_status_div").find("div.tab_warning").first().text(con);
    var button = $("#set_stu_active_status_div").find("button[type='button']").first();
    if(button != undefined){
        button.removeAttr("onclick");
        button.attr("onclick", "set_stu_status_commit('"+student_id+"', '"+type+"')");
    };
    popup("#set_stu_active_status_div");
}

function set_stu_status_commit(student_id, type){    //设置停用或启用学生确定
    $("#set_stu_active_status_div").hide();
    $(".mask").hide();
    $("#waiting_warning").find("p").first().text("正在处理...");
    popup("#waiting_warning");
    $.ajax({
        type: "post",
        url: "/school_manage/student_manages/set_stu_status",
        dataType: "json",
        data: {
            stu_id : student_id
        },
        success: function(data){
            $(".mask").hide();
            $("#waiting_warning").hide();
            if(data.status==1){
                tishi("操作成功!");
                var stu_inputs = $("#student_list_table").find("input[name='stu_id']");
                if(type=="close"){
                    $.each(stu_inputs, function(){
                        if($(this).val()==student_id){
                            var a = $(this).parent().find("a").first();
                            a.removeAttr("class");
                            a.removeAttr("onclick");
                            a.attr("class", "blockUp_a_ed tooltip_html");
                            a.attr("onclick", "set_stu_status('"+student_id+"', 'open')");
                            a.text("启用");
                        }
                    })
                }else{
                    $.each(stu_inputs, function(){
                        if($(this).val()==student_id){
                            var a = $(this).parent().find("a").first();
                            a.removeAttr("class");
                            a.removeAttr("onclick");
                            a.attr("class", "blockUp_a tooltip_html");
                            a.attr("onclick", "set_stu_status('"+student_id+"', 'close')");
                            a.text("停用");
                        }
                    })
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

function search_student(){  //搜索学生
    var name = $.trim($("#student_name").val());
    window.location.href="/school_manage/student_manages?student_name="+name;
}


function import_stu_xls(){
    popup("#import_student_div");
}

function import_stu_xls_valid(obj){ //导入学生表格验证
    var file_name = $("#stu_list_form").val();
    var point_type = file_name.substring(file_name.lastIndexOf(".")).toLowerCase();
    var type = point_type.substring(1, point_type.length);
    if(type != "xls" && type != "xlsx"){
        tishi("请上传正确的表格文件,文件格式必须为'xls'或者'xlsx'!");
        $("#stu_list_form").val("");
    }else{
        $("#import_student_div").hide();
        $(".mask").hide();
        $("#waiting_warning").find("p").first().text("文件上传中，请稍后...");
        popup("#waiting_warning");
        $(obj).parents("form").submit();
    }
}

// 激活学生
function is_activating(obj,student_id){
    if ($(obj).text()!='待激活'){
        return false;
    }
    var flag = confirm("确定激活该学生?");
    if(flag){
        $.ajax({
            type :"get",
            dataType : "json",
            url : "/school_manage/student_manages/activating_student",
            data : {
                student_id : student_id
            },
            success : function(data){
                tishi(data.notice);
                if(data.status==1){
                    $(obj).removeClass("student_text_a");
                    $(obj).html("已激活");
                }
            }
        })
    }
}