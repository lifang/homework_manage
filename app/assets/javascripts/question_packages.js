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
    var editor = KindEditor.instances;
    //var text = editor[parent_index].text()+"["+index+"]"
    //editor[parent_index].text(text);
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
    add_style_to_wanxin();

}
function show_this(obj,question_id,school_class_id){

    if($(obj).parent().find(".ab_list_box").is(":hidden")){
        
        $.ajax({
            dataType:"script" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/show_ab_list_box"
        });
        var pp = $(obj).parent().parent().children("div");
        var ab = $(obj).parent().parent().children("div").find(".ab_list_title");
        for(var i=0;i<ab.length;i++){
            if(ab[i] == obj){
                gloab_index =i;
            }
        }
        for(var i=0;i<pp.length;i++){
            if(pp[i]!=$(obj).parent()){
                $(pp[i]).find(".ab_list_box").hide();
                $(pp[i]).removeClass("ab_list_open");
            }
            
        }
    //
    //        $(obj).parent().children(".ab_list_box").show();
    //        $(obj).addClass("ab_list_open");
    }else{
//        $(obj).parent().find(".ab_list_box").hide();
//        $(obj).removeClass("ab_list_open");
}
}

function create_wanxin(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/create_wanxin",
        data:"episode_id="+episode_id
    });
}
function show_wanxin(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/show_wanxin",
        data:"episode_id="+episode_id
    });
}

function save_wanxin_branch(obj,school_class,question_pack){
    var question_id = $($(obj).parents(".ab_list_open")[0]).find(".questions_id").val();
    var params = $($(obj).parents(".gapFilling_questions")[0]).find("form").serialize();
    var branch_question = $($(obj).parents(".gapFilling_questions")[0]).find(".branch_question_form");
    var texts = branch_question.find("input[type=text]");
    for(var i=0;i<texts.length;i++){
        if($.trim($(texts[i]).val())==""){
            alert("存在选项为空！");
            return false;
        }
    }
    var radios = branch_question.find("input[type=radio]:checked").length;
    if(radios == 0){
        alert("请给出正确答案！");
        return false;
    }
    var branch_question_id = $($(obj).parents(".gapFilling_questions")[0]).find(".branch_question_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class+"/question_packages/"+question_pack+"/save_wanxin_branch_question",
        data:"question_id="+question_id+"&branch_question_id="+branch_question_id+"&"+params
    });
}