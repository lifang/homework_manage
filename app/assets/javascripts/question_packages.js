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

function add_wanxin_item(obj){
    var textarea = $(obj).parent().find("#wanxin_content");
    index = $(".gapFilling_box").find("gapFilling_questions").length+1;
    var editor = KindEditor.instances;
    var text = editor[0].text()+"["+index+"]"
    editor[0].text(text);

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