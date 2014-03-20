function address_search_episodes(obj,school_class_id){
    cell_id = $("#cell_id").val();
    if( cell_id !=""){
        return false;
    }
    if(confirm("确认选择后就不能更改了？")){
        $("#cell_id").val($(obj).val());
        $.ajax({
            type: "get",
            dataType: "script",
            url: "/school_classes/"+school_class_id+"/question_packages/setting_episodes",
            data: {
                cell_id : $(obj).val()
            },
            success: function(data){
                 $(obj).attr("disabled","disabled");
            }
        });
    }
}

function no_change(obj){
    episode_id = $("#episode_id").val();
    if( episode_id !=""){
        $(obj).val(episode_id)
        return false;
    }
    if(confirm("确认选择后就不能更改了？")){
      $("#episode_id").val($(obj).val());
      $(obj).attr("disabled","disabled");
      $(".assignment_body").show();
    }
}

//选择T或者F时改变样式
function change_true_or_false(obj){
    $(obj).parents("ul").find("a").removeAttr("class");
    $(obj).attr("class", "true");

}