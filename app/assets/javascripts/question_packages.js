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

function show_this(){
    $(".ab_list_title").click(function(){
        if($(this).parent().find(".ab_list_box").is(":hidden")){
            $(this).parent().find(".ab_list_box").show();
            $(this).parent().addClass("ab_list_open");
        }else{
            $(this).parent().find(".ab_list_box").hide();
            $(this).parent().removeClass("ab_list_open");
        }

    })
}