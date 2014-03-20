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
    var parent_ab_list_box = $(obj).parents(".ab_list_box")[0];
    var parent_index = -1;
    var ab_l =$(".ab_list_box");
    for(var i=0 ;i<ab_l.length;i++ ){
        if(ab_l[i]==parent_ab_list_box){
            parent_index = i;
        }
    }
    var textarea = $(obj).parent().find(".wanxin_content");
    var index = $(obj).parents(".questions_item").find(".gapFilling_box").find(".gapFilling_questions").length+1;
    alert(parent_index+"-->"+index);
    var editor = KindEditor.instances;
    var text = editor[parent_index].text()+"["+index+"]"
    editor[parent_index].text(text);
    var html = "<div class='gapFilling_questions'> \n\
  <div class='gapFilling_questions_body'> \n\
    <span class='gapFilling_numb'>"+index+"</span> \n\
    <div class='gq_article'> \n\
      <div class='gq_article_title'><div class='qt_text'><p></p><input name='' type='text'></div></div> \n\
      <ul> \n\
        <li><input type='radio' name='radio_<%=index%>'/><div class='qt_text'><p></p><input name='' type='text'></div></li> \n\
        <li><input type='radio' name='radio_<%=index%>'/><div class='qt_text'><p></p><input name='' type='text'></div></li> \n\
        <li><input type='radio' name='radio_<%=index%>'/><div class='qt_text'><p></p><input name='' type='text'></div></li> \n\
        <li><input type='radio' name='radio_<%=index%>'/><div class='qt_text'><p></p><input name='' type='text'></div></li> \n\
      </ul> \n\
    </div> \n\
  </div> \n\
  <div class='qt_icon'> \n\
    <a href='#' class='save tooltip_html'>保存</a> \n\
    <a href='#' class='tag tooltip_html'>标签</a> \n\
  </div> \n\
  <div class='tag_ul'><ul></ul></div></div> \n\
";
    $(".gapFilling_box").append(html);

}
function show_this(obj,question_id,school_class_id){
   
    if($(obj).parent().find(".ab_list_box").is(":hidden")){
        var pp = $(obj).parent().parent().find("div");
        for(var i=0;i<pp.length;i++){
            $(pp[i]).find(".ab_list_box").hide();
            $(pp[i]).removeClass("ab_list_open");
        }
        $.ajax({
            dataType:"script" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/show_ab_list_box"
        });
        $(obj).parent().find(".ab_list_box").show();
        $(obj).parent().addClass("ab_list_open");
    }else{
        $(obj).parent().find(".ab_list_box").hide();
        $(obj).parent().removeClass("ab_list_open");
    }
}
