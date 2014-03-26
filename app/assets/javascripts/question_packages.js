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
function add_l_r_question(types, school_class_id )
{

    var question_package_id = $("#question_package_id").val();
    var cell_id = $("#cell_id").val();
    var episode_id = $("#episode_id").val();
    var url = "/school_classes/"+school_class_id+"/question_packages/new_reading_or_listening";
    $.ajax({
        type: "get",
        dataType: "script",
        url: url,
        data: {
            types : types,
            question_package_id : question_package_id,
            episode_id : episode_id,
            cell_id : cell_id
        },
        success: function(data){
        }
    });
}


//选择上传音频文件
function select_audio(obj)
{   
    $(obj).next().find("[class='file']").click();
}

//显示该单元该课下的题目
function show_ques(types, school_class_id)
{
    var question_package_id = $("#question_package_id").val();
    var cell_id = $("#cell_id").val();
    var episode_id = $("#episode_id").val();
    var url = "/school_classes/"+school_class_id+"/question_packages/show_questions";
    $.ajax({
        type: "get",
        dataType: "script",
        url: url,
        data: {
            types : types,
            question_package_id : question_package_id,
            episode_id : episode_id,
            cell_id : cell_id
        },
        success: function(data){
        }
    }); 
}

//播放音频文件
function playAudio(obj){
    var oAudio =  $(obj).find("audio")[0];
    if (oAudio.paused) {
        oAudio.play();
    }
    else {
        oAudio.pause();
    }
}

//听力和朗读上传音频文件
function check_audio(obj, types, school_class_id)
{
    var question_id = $(obj).parent().find("[class='question_id']").val();
    var branch_id = $.trim($(obj).parent().find("[class='branch_id']").val());
    var types = $(obj).parent().find("[class='types']").val();
    var q_index = $(obj).parent().find("[class='q_index']").val();
    var b_index = $(obj).parent().find("[class='b_index']").val();
    var content = $.trim($(obj).parent().find("[class='content']").val());  
  
 
    if(types == 0) //听写
    {


        if(content != "")
        {
            $(obj).parent().submit();
        }
        else
        {
            tishi("小题内容不能为空！");
            $(obj).val();
        }
    }
    else if(types == 1)  // 朗读
    {
        if(content != "")
        {
            if(branch_id != "")
            {   
                $(obj).parent().submit();
            } 
        }
        else
        {
            tishi("小题内容不能为空！");
            $(obj).val();
        }    

    } 

}

//听力和朗读的onblur事件
function ob_listeng_or_reading(obj, school_class_id)
{
    var question_package_id = $("#question_package_id").val();
    var cell_id = $("#cell_id").val();
    var episode_id = $("#episode_id").val();
    var question_id = $(obj).parent().find("[class='question_id']").val();
    var branch_id = $.trim($(obj).parent().prev().find("[class='branch_id']").val());
    var q_index = $(obj).parent().parent().parent().parent().parent().parent().parent().parent().index();
    var b_index = $(obj).parent().parent().parent().parent().parent().index();
    var types = $(obj).parent().find("[class='types']").val();
    var content = $.trim($(obj).val());
    if(content != "")
    {

        $(obj).prev().text(content);
        $(obj).hide();
        $(obj).prev().show();
        $(obj).parent().prev().find("form").find("[class='q_index']").val(q_index);
        $(obj).parent().prev().find("form").find("[class='b_index']").val(b_index);
        $(obj).parent().prev().find("form").find("[class='content']").val(content);

        if(types == 0)  //听写
        {
            if(branch_id != "")
            {
                var url =  "/school_classes/"+school_class_id+"/question_packages/save_listening";
                $.ajax({
                    type: "post",
                    dataType: "script",
                    url: url,
                    data: {
                        branch_id : branch_id,
                        types : types,
                        content : content,
                        question_id : question_id,
                        question_package_id : question_package_id,
                        episode_id : episode_id,
                        cell_id : cell_id
                    },
                    success: function(data){
                    }
                }); 
            }
        }
        else if(types == 1) // 朗读
        {
            var url =  "/school_classes/"+school_class_id+"/question_packages/save_reading";
            $.ajax({
                type: "post",
                dataType: "script",
                url: url,
                data: {
                    branch_id : branch_id, 
                    q_index : q_index,
                    b_index : b_index,
                    types : types,
                    content : content,
                    question_id : question_id,
                    question_package_id : question_package_id,
                    episode_id : episode_id,
                    cell_id : cell_id
                },
                success: function(data){
                }
            });
        }
    }
    else
    {
        tishi("小题内容不能为空！");
    }

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
    <a style='cursor: pointer;display: none;' onclick='add_wanxin_tags(this, <%= @school_class.id  %>)' class='tag tooltip_html wangping_tag'>标签</a> \n\
  </div> \n\
  <div class='tag_ul'><ul></ul></div></div> \n\
";
    $(".gapFilling_box").append(html);
    add_style_to_wanxin();
    ondblclick(".qt_text p",".qt_text input");

}
function show_this(obj,question_packages,school_class_id){
    var question_id = $(obj).find(".question_id").val();
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
            data:"question_id="+question_id+"&index="+gloab_index
        });
        for(var i=0;i<pp.length;i++){
            if(pp[i]!=$(obj).parent()){
                $(pp[i]).find(".ab_list_box").hide();
                $(pp[i]).removeClass("ab_list_open");
            }
            
        }
    }
}
function show_the_paixu(obj,question_packages,school_class_id){
    var question_id = $(obj).find(".question_id").val();
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
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_packages+"/show_the_paixu",
            data:"question_id="+question_id+"&index="+gloab_index
        });
        for(var i=0;i<pp.length;i++){
            if(pp[i]!=$(obj).parent()){
                $(pp[i]).find(".ab_list_box").hide();
                $(pp[i]).removeClass("ab_list_open");
            }

        }
    }
}

function create_wanxin(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/create_wanxin",
        data:"episode_id="+episode_id,
        success:function(){
         
        }
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
        data: {
            cell_id : cell_id,
            episode_id : episode_id,
            question_package_id : question_package_id
        }
    })
}

//搜索标签
function search_b_tags(obj, school_class_id){
    var tag_name = $.trim($(obj).val());
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/question_packages/search_b_tags",
        dataType: "json",
        data: {
            tag_name : tag_name
        },
        success: function(data){
            $(obj).parents("div.tag_tab").find("ul").empty();
            if(data.b_tags.length > 0){
                $.each(data.b_tags, function(index, val){
                    $(obj).parents("div.tag_tab").find("ul").append("<li><input type='checkbox' value='"+val.id+"' \n\
                    /><p>"+val.name+"</p></li>");
                });
                $('input[type=checkbox], input[type=radio]').iCheck({
                    checkboxClass: 'icheckbox_square-aero',
                    radioClass: 'iradio_square-aero',
                    increaseArea: '20%' // optional
                });
                var lis = $("#tags_table").find("li");
                $.each(lis, function(){
                    var current_input = $(this).find("input").first();
                    var tag_id = current_input.val();
                    var tag_name = $(this).find("p").first().text();
                    $(current_input).on("ifChecked", function(){
                        add_tags_to_time_limit($(this), tag_id, tag_name);
                    })
                });
                $(obj).parents("div.tag_tab").find("a").first().text("");
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
            data: {
                tag_name : tag_name
            },
            success: function(data){
                if(data.status==0){
                    tishi("保存失败!");
                }else if(data.status==2){
                    tishi("保存失败,已有同名的标签!");
                }else{
                    tishi("新建成功!");
                    $(obj).parents("div.tag_tab").find("ul").html("<li><input type='checkbox' value='"+data.tag_id+"' \n\
 onclick='add_tags_to_time_limit(this,\""+data.tag_id+"\",\""+data.tag_name+"\")'/><p>"+data.tag_name+"</p></li>");
                    $('input[type=checkbox], input[type=radio]').iCheck({
                        checkboxClass: 'icheckbox_square-aero',
                        radioClass: 'iradio_square-aero',
                        increaseArea: '20%' // optional
                    });
                    var lis = $("#tags_table").find("li");
                    $.each(lis, function(){
                        var current_input = $(this).find("input").first();
                        var tag_id = current_input.val();
                        var tag_name = $(this).find("p").first().text();
                        $(current_input).on("ifChecked", function(){
                            add_tags_to_time_limit($(this), tag_id, tag_name);
                        })
                    });
                    $(obj).text("");
                }
            },
            erroe: function(data){
                tishi("数据错误!");
            }
        })
    }
}

//点击跳出标签层
function add_b_tags(type, obj){
    var width = $("#tags_table").width();
    var height = $(obj).height();
    $("#tags_table").css("display", "block");
    $("#tags_table").css({
        'left':($(obj).offset().left-width)+'px',
        'top':($(obj).offset().top+height)+'px'
    });
    if(type=="time_limit"){
        var time_limit_div = $(obj).parents(".questions_item").attr("id");
        var index = time_limit_div.split("_")[3];       //获取当前添加标签图标对应的题目的索引
        $("#tags_table").find("input[type='hidden']").first().val(index);
        var lis = $("#tags_table").find("li");
        $.each(lis, function(){
            var current_input = $(this).find("input").first();
            var tag_id = current_input.val();
            var tag_name = $(this).find("p").first().text();
            $(current_input).on("ifChecked", function(){
                add_tags_to_time_limit($(this), tag_id, tag_name);
            })           
        })
    }else if(type=="select"){

    }
    return false;
}

//添加标签到十速挑战的题目下面
function add_tags_to_time_limit(obj, tag_id, tag_name){
    var index = $("#tags_table").find("input[type='hidden']").first().val();
    if($(obj).attr("checked")=="checked"){
        if(index==""){
            tishi("数据错误!");
        }else{
            var has_tags = $("#time_limit_item_"+index+" .tag_ul ul").find("input[type='hidden']");   //验证是否已添加该标签
            var flag = true;
            $.each(has_tags, function(name,val){
                if($(this).val()==tag_id){
                    flag = false;
                }
            });
            if(flag){
                $("#time_limit_item_"+index+" .tag_ul ul").append("<li><p>"+tag_name+"</p><a href='jsvsacript:void(0)' class='x' onclick='remove_tags_from_time_limit(this)'>x</a>\n\
      <input type='hidden' name='[time_limit]["+index+"][tags][]' value='"+tag_id+"'/></li>");
            }
        }
    }
}
  
function save_wanxin_branch(obj,school_class,question_pack){
    var question_id = $($(obj).parents(".ab_list_open")[0]).find(".question_id").val();
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
        data:"question_id="+question_id+"&branch_question_id="+branch_question_id+"&gloab_index="+gloab_index+"&"+params    
    });
}

function save_paixu_branch(obj,school_class,question_pack){
    var question_id = $($(obj).parents(".ab_list_open")[0]).find(".question_id").val();
    var params = $($(obj).parents(".questions_item")[0]).find("form").serialize();
    var branch_question = $($(obj).parents(".questions_item")[0]).find(".branch_question_form");
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
                $(obj).parents(".questions_item").find(".wangping_save").hide();
                $(obj).parents(".questions_item").find(".wangping_delete").show();

                var html = "\n\
<div class='questions_item'> \n\
    <input type='hidden' class='branch_question_id' value='' /> \n\
    <div class='q_topic'> \n\
      <form class='branch_question_form'>\n\
        <div class='sortQuestions qt_input'>\n\
          <div class='qt_text'><p style='min-height: 36px;display: block;'></p><input name='content' type='text' value=' '/></div>\n\
        </div>\n\
      </form>\n\
    </div>\n\
    <div class='qt_icon'>\n\
      <a style='cursor: pointer;' onclick='save_paixu_branch(this,"+school_class+","+question_pack+")' class='save tooltip_html wangping_save'>保存</a>\n\
      <a style='cursor: pointer;display: none;' class='delete tooltip_html wangping_delete'>删除</a>\n\
      <a style='cursor: pointer;display: none;' onclick='add_paixu_tags(this, <%= @school_class.id  %>)' class='tag tooltip_html wangping_tag'>标签</a>\n\
    </div>\n\
    <div class='tag_ul'>\n\
      <ul>\n\
        <li><p>不定冠词</p><a href='#' class='x'>X</a></li>\n\
      </ul>\n\
    </div>\n\
  </div>"
                $($(obj).parents(".ab_article")[0]).append(html);
                alert('保存成功！');

            }else if(data==3){
                $(obj).parents(".questions_item").find(".wangping_save").hide();
                $(obj).parents(".questions_item").find(".wangping_delete").show();
                $(obj).parents(".questions_item").find(".wangping_tag").show();
                alert('保存成功！');
            }else if(data==2){
                alert('保存失败！');
            }

        }
    });
    
}


function delete_wanxin_option(obj,school_class,question_package){
    var branch_question_id = $(obj).parent().parent().find(".branch_question_id").val();
    var question_id = $($(obj).parents(".assignment_body_list")[0]).find(".question_id").val();
    if(confirm("是否确定删除？")){
        $.ajax({
            dataType:"script" ,
            url:"/school_classes/"+school_class+"/question_packages/"+question_package+"/delete_wanxin_branch_question",
            data:"branch_question_id="+branch_question_id+"&question_id="+question_id+"&index="+gloab_index
        });
    }
}
function delete_paixu_option(obj,school_class,question_package){
    var branch_question_id = $(obj).parent().parent().find(".branch_question_id").val();
    var question_id = $($(obj).parents(".assignment_body_list")[0]).find(".question_id").val();
    if(confirm("是否确定删除？")){
        $.ajax({
            dataType:"script" ,
            url:"/school_classes/"+school_class+"/question_packages/"+question_package+"/delete_paixu_branch_question",
            data:"branch_question_id="+branch_question_id+"&question_id="+question_id+"&index="+gloab_index
        });
    }
}

function add_paixu_tags(obj){
    common_tags(obj);
    var branch_question_id = $(obj).parents(".questions_item").find(".branch_question_id").val();
    var question_item = $(obj).parents(".questions_item")[0]
    var q_index = $($(obj).parents(".ab_article")[0]).find(".questions_item").index($(question_item));
    var lis = $("#tags_table").find("li");
    $.each(lis, function(){
        var current_input = $(this).find("input").first();
        // current_input.attr("onclick","add_content_to_paixu(this,"+q_index+","+ branch_question_id+")")
        $(current_input).on("ifChecked", function(){
            alert("dddd");
            add_content_to_paixu($(this), q_index, branch_question_id);
        })
    })
}

function add_content_to_paixu(obj,q_index,branch_question_id){
    if($(obj).attr("checked")=="checked"){
        var shcool_id = $("#school_class_id").val();
        var question_pack_id = $("#question_package_id").val();
        var value = $(obj).val();
        $.ajax({
            url:"/school_classes/"+$(".school_class_id").val()+"/question_packages/save_branch_tag",
            dataType:"json",
            data:"branch_question_id="+branch_question_id+"&branch_tag_id="+value,
            success:function(data){
                if(data.status == 1){
                    var old = $($( $(".assignment_body_list")[gloab_index] ).find(".questions_item")[q_index]);
                    old.find(".tag_ul ul").
                    append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\'paixu\')' class='x'>X</a></li>");
                }else if(data.status == 2){
                    alert("添加失败，重复标签！");
                }else if(data.status == 3){
                    alert("添加失败，无此标签！");
                }
            }
        })
    }
}

function add_content_to_wanxin(obj,q_index,branch_question_id){
    if($(obj).attr("checked")=="checked"){
        var shcool_id = $("#school_class_id").val();
        var question_pack_id = $("#question_package_id").val();
        var value = $(obj).val();
        $.ajax({
            url:"/school_classes/"+$(".school_class_id").val()+"/question_packages/save_branch_tag",
            dataType:"json",
            data:"branch_question_id="+branch_question_id+"&branch_tag_id="+value,
            success:function(data){
                if(data.status == 1){
                    var old = $($( $(".assignment_body_list")[gloab_index] ).find(".gapFilling_questions")[q_index]);
                    old.find(".tag_ul ul").
                    append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\'wanxin\')' class='x'>X</a></li>");
                }else if(data.status == 2){
                    alert("添加失败，重复标签！");
                }else if(data.status == 3){
                    alert("添加失败，无此标签！");
                }
            }
        })
    }
}


function delete_tags(obj,shcool_id,question_pack_id,tag_id,branch_question_id,type){
    if(type == 'paixu'){
        var question_item = $(obj).parents(".questions_item")[0]
        var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".questions_item").index($(question_item));
        var type = 'paixu'
        alert(gloab_index+"==>"+q_index);
        $.ajax({
            dataType:'script',
            url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
            data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type
        });
    
    }else if(type=='wanxin'){
        var question_item = $(obj).parents(".gapFilling_questions")[0]
        var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".gapFilling_questions").index($(question_item));
        alert(gloab_index+"==>"+q_index);
        var type = 'wanxin'
        $.ajax({
            dataType:'script',
            url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
            data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type
        });
    }
   
}
function add_wanxin_tags(obj, index){

    common_tags(obj);
    var branch_question_id = $(obj).parents(".gapFilling_questions").find(".branch_question_id").val();
    var question_item = $(obj).parents(".gapFilling_questions")[0]
    var q_index = $($(obj).parents(".gapFilling_box")[0]).find(".gapFilling_questions").index($(question_item));
    var lis = $("#tags_table").find("li");
    $.each(lis, function(){
        var current_input = $(this).find("input").first();
        // current_input.attr("onclick","add_content_to_paixu(this,"+q_index+","+ branch_question_id+")")
        $(current_input).on("ifChecked", function(){
            add_content_to_wanxin($(this), q_index, branch_question_id);
        })
    })
}
 
function common_tags(obj){
    var width = $("#tags_table").width();
    var height = $(obj).height();
    $("#tags_table").css("display", "block");
    $("#tags_table").css({
        'left':($(obj).offset().left-width)+'px',
        'top':($(obj).offset().top+height)+'px'
    });
}
