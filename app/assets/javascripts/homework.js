//获取url中对应的参数
function getQueryString(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null) return unescape(r[2]);
    return null;
}


function setChosen(obj){
    $(obj).parents(".tab_switch").find("span.tooltip_html").remove();
    $(obj).after("<span class='tooltip_html'>当前</span>");
    $(".hidden_selected_tag_id").val($(obj).attr("data-value"));
}

//显示发布任务栏
function show_publish_task_panel(question_package_id)
{
    $("#question_package_id_value").val(question_package_id);
    var page_value = getQueryString("page");
    if(page_value!= ""){
        $("#hidden_page_value").val(page_value);
    }
    show_windows("publish_task_panel");
}

//发布任务时验证时间
function check_time(obj)
{
    end_time = $.trim($("#end_time").val());
    if(end_time != "" && end_time!="截止时间")
    {
        $("#fugai").show();
        $("#fugai1").find("h2").text("题包发布中，请耐心等待...");
        $("#fugai1").show();
        $(obj).parents("#publish_task_panel").find("form").submit();
    }
    else{
        tishi("时间不能为空！");
    }
}
