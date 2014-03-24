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
        $(".questionTypes").show();
        $(".complete_btn_box").show();
    }
}


//添加听力或朗读题
function add_l_r_question(type, school_class_id )
{

    if($("#question_list_"+type+"").length > 0)
    {
        alert($("#question_list_"+type+"").parents().last().index());
    }
    else
    {
        var div_questions_body = "<div class='assignment_body' id='question_list_"+type+"'> </div>";
        $("#question_list").after(div_questions_body);
    }
    var question_package_id = $("#question_package_id").val();
    var cell_id = $("#cell_id").val();
    var episode_id = $("#episode_id").val();
    if(type == 0)
        var url = "/school_classes/"+school_class_id+"/question_packages/new_listening";
    else if(type == 1)
        var url = "/school_classes/"+school_class_id+"/question_packages/new_reading";
    $.ajax({
        type: "get",
        dataType: "script",
        url: url,
        data: {
            type : type,
            question_package_id : question_package_id,
            episode_id : episode_id,
            cell_id : cell_id
        },
        success: function(data){
        }
    });
}


//选择T或者F时改变样式
function change_true_or_false(obj){
    $(obj).parents("ul").find("a").removeAttr("class");
    $(obj).attr("class", "true");
}

function add_wanxin_item(obj,shcool_id,question_package_id){
     
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
   <input type='hidden' class='branch_question_id' /> <span class='gapFilling_numb'>"+index+"</span> \n\
    <div class='gq_article'> \n\
      <form class='branch_question_form'>  \n\
      <div class='gq_article_title'><div class='qt_text'><p></p><input name='title' type='text'></div></div> \n\
      <ul> \n\
        <li><input type='radio' name='radio_"+index+"' value='0'/><div class='qt_text'><p></p><input name='option[]' type='text'></div></li> \n\
        <li><input type='radio' name='radio_"+index+"' value='1'/><div class='qt_text'><p></p><input name='option[]' type='text'></div></li> \n\
        <li><input type='radio' name='radio_"+index+"' value='2'/><div class='qt_text'><p></p><input name='option[]' type='text'></div></li> \n\
        <li><input type='radio' name='radio_"+index+"' value='3'/><div class='qt_text'><p></p><input name='option[]' type='text'></div></li> \n\
      </ul> \n\
      </form>\n\
    </div> \n\
  </div> \n\
  <div class='qt_icon'> \n\
    <a style='cursor: pointer;' onclick='save_wanxin_branch(this,"+shcool_id+","+question_package_id+")' class='save tooltip_html wangping_save'>保存</a> \n\
    <a style='cursor: pointer;display: none;' class='delete tooltip_html wangping_delete' onclick = 'delete_wanxin_option(this,"+shcool_id+","+question_package_id+")'>删除</a> \n\
    <a href='#' class='tag tooltip_html'>标签</a> \n\
  </div> \n\
  <div class='tag_ul'><ul></ul></div></div> \n\
";
    $(".gapFilling_box").append(html);
    add_style_to_wanxin();
    ondblclick(".qt_text p",".qt_text input");

}
function show_this(obj,question_packages,school_class_id){
    var questions_id = $(obj).find(".questions_id").val();
    if($(obj).parent().find(".ab_list_box").is(":hidden")){
    
        var pp = $(obj).parent().parent().children("div");
        var ab = $(obj).parent().parent().children("div").find(".ab_list_title");
        for(var i=0;i<ab.length;i++){
            if(ab[i] == obj){
                gloab_index =i;
            }
        }
        $.ajax({
            dataType:"script" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_packages+"/show_ab_list_box",
            data:"question_id="+questions_id+"&index="+gloab_index
        });
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
function create_paixu(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/create_paixu",
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


//新建十速挑战
function new_time_limit(school_class_id){
    var cell_id = $("#cell_id").val();
    var episode_id = $("#episode_id").val();
    var question_package_id = $("#question_package_id").val();
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/question_packages/new_time_limit",
        dataType: "script",
        data: {cell_id : cell_id, episode_id : episode_id, question_package_id : question_package_id}
    })
}

//搜索标签
  function search_b_tags(obj, school_class_id){
    var tag_name = $.trim($(obj).val());
    $.ajax({
      type: "get",
      url: "/school_classes/"+school_class_id+"/question_packages/search_b_tags",
      dataType: "json",
      data: {tag_name : tag_name},
      success: function(data){
          $(obj).parents("div.tag_tab").find("ul").empty();
          if(data.b_tags.length > 0){
              $.each(data.b_tags, function(index, val){
                  $(obj).parents("div.tag_tab").find("ul").append("<li><input type='checkbox' value='"+val.id+"' \n\
                onclick='add_tags_to_time_limit(this,\""+val.id+"\",\""+val.name+"\")'/><p>"+val.name+"</p></li>");
              })
          }else{
               $(obj).parents("div.tag_tab").find("ul").html("无");
               if(tag_name!=""){
                   $(obj).parents("div.tag_tab").find("a").first().text("新建\""+tag_name+"\"");
               }
          }
      },
      error: function(data){
          tishi("数据错误!");
      }
    })
  }

//新建标签
function add_b_tag(obj, school_class_id){
  var tag_name = $(obj).text().split("\"")[1];
  if(tag_name != undefined && tag_name != ""){
      $.ajax({
          type: "get",
          url: "/school_classes/"+school_class_id+"/question_packages/add_b_tags",
          dataType: "json",
          data: {tag_name : tag_name},
          success: function(data){
              if(data.status==0){
                  tishi("保存失败!");
              }else if(data.status==2){
                  tishi("保存失败,已有同名的标签!");
              }else{
                  tishi("新建成功!");
                   $(obj).parents("div.tag_tab").find("ul").html("<li><input type='checkbox' value='"+data.tag_id+"' \n\
 onclick='add_tags_to_time_limit(this,\""+data.tag_id+"\",\""+data.tag_name+"\")'/><p>"+data.tag_name+"</p></li>");
                  $(obj).text("");
              }
          },
          erroe: function(data){
              tishi("数据错误!");
          }
      })
  }
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
        dataType:"text" ,
        url:"/school_classes/"+school_class+"/question_packages/"+question_pack+"/save_wanxin_branch_question",
        data:"question_id="+question_id+"&branch_question_id="+branch_question_id+"&"+params,
        success:function(data){
            if(data==1){
                $(obj).parents(".gapFilling_questions").find(".wangping_save").hide();
                $(obj).parents(".gapFilling_questions").find(".wangping_delete").show();
                alert('保存成功！');
            }
            
        }
    });
}

function save_paixu_branch(obj,school_class,question_pack){
    var question_id = $($(obj).parents(".ab_list_open")[0]).find(".questions_id").val();
    var params = $($(obj).parents(".questions_item")[0]).find("form").serialize();
    var branch_question = $($(obj).parents(".gapFilling_questions")[0]).find(".branch_question_form");
    var content = branch_question.find("input[type=text]").val();
    if($.trim(content) == ""){
        alert("内容不能为空！");
        return false;
    }
    var branch_question_id = $($(obj).parents(".questions_item")[0]).find(".branch_question_id").val();
    $.ajax({
        dataType:"text" ,
        url:"/school_classes/"+school_class+"/question_packages/"+question_pack+"/save_paixu_branch_question",
        data:"question_id="+question_id+"&branch_question_id="+branch_question_id+"&"+params,
        success:function(data){
            if(data==1){
                $(obj).parents(".gapFilling_questions").find(".wangping_save").hide();
                $(obj).parents(".gapFilling_questions").find(".wangping_delete").show();
                alert('保存成功！');
            }

        }
    });
    
}


function delete_wanxin_option(obj,school_class,question_package){
    var branch_question_id = $(obj).parent().parent().find(".branch_question_id").val();
    var question_id = $($(obj).parents(".assignment_body_list")[0]).find(".questions_id").val();
    if(confirm("是否确定删除？")){
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class+"/question_packages/"+question_package+"/delete_wanxin_branch_question",
        data:"branch_question_id="+branch_question_id+"&question_id="+question_id+"&index="+gloab_index,
        success:function(data){

        }
    });
    }
}
