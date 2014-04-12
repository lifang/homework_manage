function address_search_episodes(obj,school_class_id){
    $("#cell_id").val($(obj).val());
    $.ajax({
        type: "get",
        dataType: "script",
        url: "/school_classes/"+school_class_id+"/question_packages/setting_episodes",
        data: {
            cell_id : $(obj).val()
        },
        success: function(data){
               
        }
    });
    
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
        $(obj).parents(".select_box").find("#select1").attr("disabled","disabled");
        $(".assignment_body").show();
        $(".questionTypes").show();
        $(".complete_btn_box").show();
    }
}

function tiku_change_episode(obj){
    episode_id = $("#episode_id").val();
    if( episode_id !=""){
        $(obj).val(episode_id)
        return false;
    }
    $("#episode_id").val($(obj).val());
    if($(".assignment_body").css("display") == "none"){
        $(".assignment_body").show();
        $(".questionTypes").show();
    }

}


//添加听力或朗读题  types 0：听写  1：朗读
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
    $(obj).parent().next().next().find("[class='tmp_voice']").first().click();
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

//检查音频文件后缀名
function check_audio(obj)
{
    var file_name = $(obj).val();
    var branch_id = $(obj).parents("form").first().find("input.branch_id").val();
    var b_index = $(obj).parents("div.questions_item").first().index();
    var question_package_id = $("#question_package_id").val();
    var types = $(obj).parent().find("input.types").val();
    var input_s = $(obj);
    var isIE = document.all && window.external
    var file_name = $(obj).val();
    if(isIE){
    }
    else{
        if(file_name.size != "")
        {    
            var file_size = input_s[0].files[0].size;
            if(file_size>1048576){
                $(obj).val("");
                tishi("文件不能大于1M!");
                return false;
            }
        }    
    }

    if(file_name.match(/\..*$/) == ".mp3" || file_name.match(/\..*$/) == ".MP3")
    {
        $(obj).parent().find(".branch_id").first().val(branch_id);
        $(obj).parent().find(".b_index").first().val(b_index);
        $(obj).parent().find(".question_package_id").first().val(question_package_id);
        $(obj).parent().submit();
    }
    else
    {
        tishi("只能上传mp3格式文件！");
        $(obj).val("");

    }

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

//保存听力和朗读
function save_listening_reading(obj, types, school_class_id)
{
    $(obj).removeAttr("onclick");
    var content = $.trim($(obj).parent().parent().find("ul.branch_question").find("li:eq(0)").find("[class='content']").val());
    var types = $.trim($(obj).parent().parent().find("ul.branch_question").find("li:eq(0)").find("[class='types']").val());
    var file = $.trim($(obj).parent().parent().find("ul.branch_question").find("li:eq(0)").find("[class='file']").val());  
 
    if(types == 0) //听写
    {
        if(content != "")
        {
            if(file == "")
            {
                tishi("听写题资源不能为空！");
                $(obj).attr("onclick", "save_listening_reading(this,"+types+","+ school_class_id +")");
            }
            else
            {
                $(obj).parent().parent().find("ul.branch_question").find("li:eq(0)").find("form").submit();
            }     
        }
        else
        {
            tishi("小题内容不能为空！");
            $(obj).val();
            $(obj).attr("onclick", "save_listening_reading(this,"+types+","+ school_class_id +")");
        }
    }
    else if(types == 1)  // 朗读
    {
        if(content != "")
        {
            $(obj).parent().parent().find("ul.branch_question").find("li:eq(0)").find("form").submit();
        }
        else
        {
            tishi("小题内容不能为空！");
            $(obj).val();
            $(obj).attr("onclick", "save_listening_reading(this,"+types+","+ school_class_id +")");
        }    

    } 

}

//修改听力或朗读题内容
function change_text(obj)
{
    var branch_id = $.trim($(obj).parents(".questions_item").find("input.branch_id").first().val());
    var types = $(obj).parents(".branch_question").first().find("input.types").first().val();
    var school_class_id = $("#school_class_id").val();
    if(branch_id != "")
    {
        var save_btn = $(obj).parents(".questions_item").find("div.qt_icon").find("a.save");
        var delete_btn = $(obj).parents(".questions_item").find("div.qt_icon").find("a.delete");
        if(save_btn.length > 0)
        {}
        else
        {
            $(obj).parents(".questions_item").find("div.qt_icon").find("a.delete").first().hide();
            var update_btn = '<a href="javascript:void(0)" class="save tooltip_html" onclick="update_listening_reading(this,'+ types +','+ school_class_id +');">更新</a>'
            $(obj).parents(".questions_item").find("div.qt_icon").first().prepend
            (update_btn);
        }    
    }   
}

function listening_reading_onblur(obj)
{
    var b_index = $(obj).parents(".questions_item").index();
    var content = $(obj).val();
    // alert("b_index = "+ b_index +",content ="+ content +"");
    $(".questions_item").find("input.content").val(content);
    $(".questions_item").find("input.b_index").val(b_index);
}

//更新听力和朗读事件
function update_listening_reading(obj, types, school_class_id)
{
    var question_package_id = $("#question_package_id").val();
    var question_id = $(obj).parent().prev().find("form").find("[class='question_id']").val();
    var branch_id = $.trim($(obj).parent().prev().find("[class='branch_id']").val());
    var b_index = $(obj).parent().parent().parent().parent().parent().index();
    var content = $.trim($(obj).parent().prev().find("li.qt_text").find("input.content").first().val());

    if(content != "")
    {
        if(types == 0)  //听写
        {
            if(branch_id != "")
            {
                var url =  "/school_classes/"+school_class_id+"/question_packages/update_listening";
                $.ajax({
                    type: "post",
                    dataType: "json",
                    url: url,
                    data: {
                        branch_id : branch_id,
                        types : types,
                        content : content,
                        b_index : b_index,
                        question_id : question_id
                    // question_package_id : question_package_id,
                    // episode_id : episode_id,
                    // cell_id : cell_id
                    },
                    success: function(data){
                        if(data.status == true)
                        {
                            var div_qt_icon = $(obj).parents("div.qt_icon").first();
                            $(obj).remove();
                            $(div_qt_icon).find("a.delete").show();
                            tishi("小题修改成功！");
                        }
                        else
                        {
                            tishi("小题修改失败！");  
                        }    
                    },
                    error: function(data){ 
                    }
                }); 
            }
        }
        else if(types == 1) // 朗读
        {
            if(branch_id != "")
            {
                var url =  "/school_classes/"+school_class_id+"/question_packages/save_reading";
                $.ajax({
                    type: "post",
                    dataType: "script",
                    url: url,
                    data: {
                        branch_id : branch_id,
                        b_index : b_index,
                        types : types,
                        content : content,
                        question_id : question_id
                    // question_package_id : question_package_id,
                    // episode_id : episode_id,
                    // cell_id : cell_id
                    },
                    success: function(data){
                        var div_qt_icon = $(obj).parents("div.qt_icon").first();
                        $(obj).remove();
                        $(div_qt_icon).find("a.delete").show();
                    }
                });
            }
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
        var flag = false;
        if($(obj).parents(".assignment_body_list").find(".gapFilling_box")){
            if($.trim($(obj).parents(".assignment_body_list").find(".gapFilling_box").html())==""){
                flag=true;
            }
        }
        if(flag){
            $.ajax({
                dataType:"script" ,
                url:"/school_classes/"+school_class_id+"/question_packages/"+question_packages+"/show_ab_list_box",
                data:"question_id="+question_id+"&index="+gloab_index
            });
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
        var flag = false;
        if($.trim($(obj).parents(".assignment_body_list").find(".ab_list_box").html())==""){
            flag =true
        }
        if(flag){
            $.ajax({
                dataType:"script" ,
                url:"/school_classes/"+school_class_id+"/question_packages/"+question_packages+"/show_the_paixu",
                data:"question_id="+question_id+"&index="+gloab_index
            });
        }
    }
}



function create_wanxin(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    var cell_id = $("#cell_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/create_wanxin",
        data:"episode_id="+episode_id+"&cell_id="+cell_id,
        success:function(){
            var obj = $(".assignment_body_list").last().find(".ab_list_title");
            $(obj).click();
        }
    });
}
function create_paixu(school_class_id,question_id){
    var episode_id = $("#episode_id").val();
    var cell_id = $("#cell_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/create_paixu",
        data:"episode_id="+episode_id+"&cell_id="+cell_id,
        success:function(){
            var obj = $(".assignment_body_list").last().find(".ab_list_title");
            $(obj).click();
        }
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
    if(school_class_id == 0){
        timeLimitGetPartial(school_class_id)
    }else{
        var time_limit_que_id = $("#time_limit_assignment_body_list").find("input[name='question_id']").first().val();
        if(time_limit_que_id==undefined || time_limit_que_id=="" || time_limit_que_id=="0"){
            timeLimitGetPartial(school_class_id)

        }else{
            tishi("每个大题下面最多只能有一个十速挑战!");
            var assignment_body_list_divs = $("#question_list").find("div.ab_list_open");
            if(assignment_body_list_divs.length>0){
                $.each(assignment_body_list_divs,function(){
                    $(this).find("div.ab_list_box").hide();
                    $(this).removeAttr("class");
                    $(this).attr("class","assignment_body_list");
                })
            };
            $("#time_limit_assignment_body_list").removeAttr("class");
            $("#time_limit_assignment_body_list").attr("class","assignment_body_list ab_list_open");
            $("#time_limit_assignment_body_list").find("div.ab_list_box").show();
        }
    }
}

function timeLimitGetPartial(school_class_id){
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
    var tag_bq_type = $(obj).parents(".tag_tab").find("input[name='tag_bq_type']").first().val();
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/question_packages/search_b_tags",
        dataType: "json",
        data: {
            tag_name : tag_name
        },
        success: function(data){
            $(obj).parents("div.tag_tab").find("ul").empty();   //清空并取消监听
            if(data.b_tags.length > 0){
                $.each(data.b_tags, function(index, val){
                    $(obj).parents("div.tag_tab").find("ul").append("<li><input type='checkbox' value='"+val.id+"' \n\
                    /><p>"+val.name+"</p></li>");
                });
                $('input[type=checkbox], input[type=radio]').iCheck({   //添加监听
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
                        if(tag_bq_type!="" && tag_bq_type=="time_limit"){
                            add_tags_to_time_limit($(this), tag_id, tag_name);
                        }
                        else if(tag_bq_type!="" && tag_bq_type=="listening_and_reading_tags"){
                            var q_index = $(this).parents(".tag_tab").find("input[name='q_index']").first().val();
                            var b_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                            add_tags_to_listening_reading(q_index, b_index, tag_id, tag_name)
                        }    
                        else if(tag_bq_type!="" && tag_bq_type=="listening_befor_save"){    
                            var question_id = $(this).parents(".tag_tab").find("input[name='q_index']").first().val();
                            var b_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                            add_tags_to_listening_bef_save(question_id, b_index, tag_id, tag_name);   
                        } else if(tag_bq_type!="" && tag_bq_type=="wanxin"){
                            var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                            var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                            add_content_to_wanxin($(this), q_index, branch_question_id);
                        }
                        else if(tag_bq_type!="" && tag_bq_type=="paixu"){
                            var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                            var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                            add_content_to_paixu($(this), q_index, branch_question_id);
                        }else if(tag_bq_type!="" && tag_bq_type=="lianxian" || tag_bq_type=="select"&& tag_bq_type!=""){
                            var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                            var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                            add_tag_to_select($(this), q_index, branch_question_id,tag_bq_type);
                        }
                    })
                });
                if(data.show_create_tag==0){
                    $(obj).parents("div.tag_tab").find("a").first().text("");
                }else{
                    $(obj).parents("div.tag_tab").find("a").first().text("新建\""+tag_name+"\"");
                }
            }else{
                $(obj).parents("div.tag_tab").find("ul").html("<span>无</span>");
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
function add_new_b_tag(obj, school_class_id){
    var tag_name = $(obj).text().split("\"")[1];        //获取标签名称
    var tag_bq_type = $(obj).parents(".tag_tab").find("input[name='tag_bq_type']").first().val();
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
                    $(obj).parents("div.tag_tab").find("ul").find("span").remove();
                    //将新建的标签添加到标签跳出层
                    $(obj).parents("div.tag_tab").find("ul").append("<li><input type='checkbox' value='"+data.tag_id+"' \n\
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
                            if(tag_bq_type!="" && tag_bq_type=="time_limit"){
                                add_tags_to_time_limit($(this), tag_id, tag_name);
                            }
                            else if(tag_bq_type!="" && tag_bq_type=="listening_and_reading_tags"){
                                var q_index = $(this).parents(".tag_tab").find("input[name='q_index']").first().val();
                                var b_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                                add_tags_to_listening_reading(q_index, b_index, tag_id, tag_name)   
                            }else if(tag_bq_type!="" && tag_bq_type=="listening_befor_save"){    
                                var question_id = $(this).parents(".tag_tab").find("input[name='q_index']").first().val();
                                var b_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                                add_tags_to_listening_bef_save(question_id, b_index, tag_id, tag_name);   
                            }    
                            else if(tag_bq_type!="" && tag_bq_type=="wanxin"){
                                var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                                var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                                add_content_to_wanxin($(this), q_index, branch_question_id);
                            }
                            else if(tag_bq_type!="" && tag_bq_type=="paixu"){
                                var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                                var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                                add_content_to_paixu($(this), q_index, branch_question_id);
                            }else if(tag_bq_type!="" && tag_bq_type=="lianxian" || tag_bq_type=="select"&& tag_bq_type!=""){
                                var q_index = $(this).parents(".tag_tab").find("input[name='b_index']").first().val();
                                var branch_question_id = $(this).parents(".tag_tab").find("input[name='branch_question_id']").first().val();
                                add_tag_to_select($(this), q_index, branch_question_id,tag_bq_type);
                            }
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
    var school_class_id = $("#school_class_id").val();
    $("#tags_table").find("input[type='text']").first().val("");
    $("#tags_table").find("a").last().text("");
    var width = $("#tags_table").width();
    var height = $(obj).height();
    $("#tags_table").css({
        'left':($(obj).offset().left-width)+'px',
        'top':($(obj).offset().top+height)+'px'
    });
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/question_packages/search_b_tags",
        dataType: "json",
        data: {
            tag_name : ""
        },
        success: function(data){
            $("#tags_table").find("ul").first().empty();
            if(data.b_tags.length > 0){
                $.each(data.b_tags, function(index, val){
                    $("#tags_table").find("ul").first().append("<li><input type='checkbox' value='"+val.id+"' \n\
                    /><p>"+val.name+"</p></li>");
                });
            };
            //先取消监听
            var checks = $("#tags_table").find("input[type='checkbox']");
            $.each(checks,function(){
                var tag_name = $(this).parents("li").find("p").first().text();
                var tag_id = $(this).val();
                $("#tags_table").find("ul").append("<li><input type='checkbox' value='"+tag_id+"'/><p>"+tag_name+"</p></li>");
                $(this).parents("li").remove();
            });
            //再添加监听
            $('input[type=checkbox], input[type=radio]').iCheck({
                checkboxClass: 'icheckbox_square-aero',
                radioClass: 'iradio_square-aero',
                increaseArea: '20%' // optional
            });

            $("#tags_table").css("display", "block");

            $("#tags_table").find("input[name='tag_bq_id']").first().val("");   //将小题的索引添加到标签层
            $("#tags_table").find("input[name='tag_bq_type']").first().val(type);   //将大题的类型添加到标签层(如十速挑战)
            if(type=="time_limit"){
                var time_limit_div = $(obj).parents(".questions_item").attr("id");
                var index = time_limit_div.split("_")[3];       //获取当前添加标签图标对应的题目的索引
                $("#tags_table").find("input[name='tag_bq_id']").first().val(index);   //将小题的索引添加到标签层
                var lis = $("#tags_table").find("li");
                $.each(lis, function(){
                    var current_input = $(this).find("input").first();
                    var tag_id = current_input.val();
                    var tag_name = $(this).find("p").first().text();
                    $(current_input).on("ifChecked", function(){
                        add_tags_to_time_limit($(this), tag_id, tag_name);
                    })
                })
            }else if(type=="listening_and_reading_tags"){
                var question_id = $(obj).parents("div.assignment_body_list").find("input.question_id").first().val();
                var b_index = $(obj).parents(".questions_item").index();
                $("#tags_table").find("input[name='q_index']").first().val(question_id);
                $("#tags_table").find("input[name='b_index']").first().val(b_index);
                var lis = $("#tags_table").find("li");
                $.each(lis, function(){
                    var current_input = $(this).find("input").first();
                    var tag_id = current_input.val();
                    var tag_name = $(this).find("p").first().text();
                    $(current_input).on("ifChecked", function(){
                        add_tags_to_listening_reading(question_id, b_index, tag_id, tag_name);
                    })
                })
            }
            else if(type=="listening_befor_save"){
                var question_id = $(obj).parents("div.assignment_body_list").find("input.question_id").first().val();
                var b_index = $(obj).parents(".batchUpload_item_con").parents("li").index();
                $("#tags_table").find("input[name='q_index']").first().val(question_id);
                $("#tags_table").find("input[name='b_index']").first().val(b_index);
                var lis = $("#tags_table").find("li");
                $.each(lis, function(){
                    var current_input = $(this).find("input").first();
                    var tag_id = current_input.val();
                    var tag_name = $(this).find("p").first().text();
                    $(current_input).on("ifChecked", function(){
                        add_tags_to_listening_bef_save(question_id, b_index, tag_id, tag_name);
                    })
                })
            }
        }
    });
    
    return false;
}

//听写题导入部分保存前添加标签
function add_tags_to_listening_bef_save(question_id, b_index, tag_id, tag_name)
{   
    var has_tags = $("#question_"+ question_id +"").find("div.batchUpload_item_con:eq("+ b_index +")").find("div.tag_ul ul").find("input[type='hidden']");   //验证是否已添加该标签
    var flag = true;
    $.each(has_tags, function(name,val){
        if($(this).val()==tag_id){
            flag = false;
        }
    });
    if(flag)
    {
        var index_val = $("#question_"+ question_id +"").find("div.batchUpload_item_con:eq("+ b_index +")").find("input.index_val").val();
        var tag_arr = $("#question_"+ question_id +"").find("div.batchUpload_item_con:eq("+ b_index +")").find("input[name='["+ index_val +"][tags]']");
        var tag_li ="<li><p>"+tag_name+"</p><a href='javascript:void(0)' class='x' onclick='delete_listening_save_bef_tags(this,"+tag_id+")'>X</a><input name='[lisenting]["+ index_val +"][tags][]' value='"+ tag_id +"' type='hidden'></li>";
        $("#question_"+ question_id +"").find("div.batchUpload_item_con:eq("+ b_index +")").find("ul").append(tag_li);      
    }
    else
    {
        tishi("该标签已存在！");
    }
}

//添加标签到听写或朗读题小题下
function add_tags_to_listening_reading(question_id, b_index, tag_id, tag_name)
{
    var tags_id = $.trim($("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val());
    var branch_id = $.trim($("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.branch_id").val());
    var question_pack_id = $("#question_pack_id").val();
    var school_class_id = $("#school_class_id").val();
    var url = "/school_classes/" + school_class_id + "/question_packages/save_branch_tag";
    var tag_li = "<li><p>"+tag_name+"</p><a href='javascript:void(0)'' class='x' onclick='delete_reading_listening_tags(this,"+tag_id+")'>X</a></li>";
    if(branch_id == "")
    {
        $("#tags_table").hide();
        tishi("未保存小题，还不能添加标签!");
    // if(tags_id == "")
    // {
    //     $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("div.tag_ul").find("ul").append(tag_li);
    //     $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tag_id);
    // }
    // else
    // {
    //     var tags_id_arr = tags_id.split(/\|/);
    //     var index = $.inArray(tag_id,tags_id_arr);
    //     if(index== -1)
    //     {
    //         tags_id += "|";
    //         tags_id += tag_id;
    //         $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("div.tag_ul").find("ul").append(tag_li);
    //         $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tags_id);
    //     }
    //     else
    //     {
    //         tishi("已添加该标签!");
    //     }
    // }
    }
    else
    {
        if(tags_id == "")
        {
            
            $.ajax({
                type: "get",
                dataType: "json",
                url: url,
                data: {
                    branch_question_id : branch_id,
                    branch_tag_id : tag_id
                },
                success: function(data){
                    if(data.status == 1){
                        var old = $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")");
                        old.find(".tag_ul ul").append(tag_li);
                        $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tag_id);
                    }else if(data.status == 2){
                        tishi("已添加该标签!");
                    }else if(data.status == 3){
                        tishi("添加失败，无此标签！");
                    }
                }
            });
        }
        else
        {
            var tags_id_arr = tags_id.split(/\|/);
            var index = $.inArray(tag_id,tags_id_arr);
            if(index== -1)
            {
                
                $.ajax({
                    type: "get",
                    dataType: "json",
                    url: url,
                    data: {
                        branch_question_id : branch_id,
                        branch_tag_id : tag_id
                    },
                    success: function(data){
                        if(data.status == 1){
                            tags_id +=  "|"
                            tags_id += tag_id
                            var old = $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")");
                            old.find(".tag_ul ul").append(tag_li);
                            $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tags_id);
                        }else if(data.status == 2){
                            tishi("已添加该标签!");
                        }else if(data.status == 3){
                            tishi("添加失败，无此标签！");
                        }
                    }
                });
            }
            else
            {
                tishi("已添加该标签!");
            }
        }       
    }
}

//听写题导入题目删除标签
function delete_listening_save_bef_tags(obj,tag_id)
{
    if(confirm("确认删除此标签!") == true)
    {
        $(obj).parent().remove();
    }
}
 
//删除导入的听写题所有小题
function delete_import_resources(obj) 
{
    if(confirm("确认删除导入小题吗？")==true)
    {
        var school_class_id = $("#school_class_id").val();
        var audios = $(obj).parents(".batchUpload_box").find("input[class='audio']");
        // alert(audios);
        var resources = ""
        $.each(audios, function(name,val){
            resources += $(this).val();
            resources += ";||;";
        });
        var url = "/school_classes/" + school_class_id + "/question_packages/delete_resources";
        $.ajax({
            type: "post",
            dataType: "json",
            url: url,
            data: {
                resources : resources
            },
            success: function(data){
                if(data["status"] == true)
                {
                    $(obj).parents(".batchUpload_box").empty();
                    tishi(data["notice"]);
                }
                    
            }
        });
    }   
}

//删除导入的听力的小题
function delete_before_save_branch(obj)
{
    if(confirm("确认删除小题吗？")==true)
    {
        var school_class_id = $("#school_class_id").val();
        var audios = $(obj).parents(".batchUpload_box").find("input[class='audio']");
        // alert(audios);
        var resources = ""
        $.each(audios, function(name,val){
            resources += $(this).val();
            resources += ";||;";
        });
    
        var url = "/school_classes/" + school_class_id + "/question_packages/delete_resources";
        $.ajax({
            type: "post",
            dataType: "json",
            url: url,
            data: {
                resources : resources
            },
            success: function(data){
                if(data["status"] == true)
                {
                    $(obj).parents(".batchUpload_item_con").remove();
                    tishi(data["notice"]);
                }
                    
            }
        });
    }    
}

//听力和朗读题保存后删除标签
function delete_reading_listening_branch(obj)
{
    var school_class_id = $("#school_class_id").val();
    var branch_id = $(obj).parents("div.questions_item").find("input.branch_id").first().val();
   
    if(confirm("确认删除小题吗？")==true)
    {
        $.ajax({
            type: "POST",
            url: "/school_classes/"+school_class_id+"/question_packages/delete_branch",
            dataType: "json",
            data: {
                branch_question_id : branch_id
            },
            success: function(data){
                if(data.status==1){
                    tishi("删除成功!");
                    $(obj).parents("div.questions_item").remove();
                }else{
                    tishi("删除失败!");
                }
            },
            error: function(data){
                tishi("数据错误!");
            }
        })
    }

}
//删除听写或朗读的标签
function delete_reading_listening_tags(obj, tag_id)
{   
    if(confirm("确定删除此标签?") == true)
    {
        var question_id = $(obj).parents("div.assignment_body_list").find("input.question_id").first().val();
        var b_index = $(obj).parent().parent().parent().parent().index();
        var branch_id = $.trim($("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.branch_id").val());
        var tags_id = $.trim($("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val());
        var school_class_id = $("#school_class_id").val();
        var question_pack_id = $("#question_package_id").val();
        if(branch_id == "")
        {
            var tags_id_arr = tags_id.split(/\|/);
            tags_id_arr.splice($.inArray(tag_id,tags_id_arr),tags_id_arr.length);
            tags_id = "";
            $.each(tags_id_arr,function(n,value) 
            {
                tags_id += value;
            });
            $(obj).parent().remove();
            $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tags_id);
        }
        else
        {
            $.ajax({
                dataType:'json',
                url:"/school_classes/"+school_class_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
                data:+""+b_index+"&tag_id="+tag_id+"&branch_question_id="+branch_id+"&type="+"reading_or_listening",
                success:function(data){
                    if(data.status == 1){
                        var tags_id_arr = tags_id.split(/\|/);
                        tags_id_arr.splice($.inArray(tag_id,tags_id_arr),tags_id_arr.length);
                        tags_id = "";
                        $.each(tags_id_arr,function(n,value) 
                        {
                            tags_id += value;
                        });
                        $(obj).parent().remove();
                        $("#question_"+ question_id +"").find("div.questions_item:eq("+ b_index +")").find("input.tags_id").val(tags_id);
                    }else{
                        tishi("删除失败！");
                    }
                }
            });
        }
    }
    else
    {
        
}   
}

//添加标签到十速挑战的题目下面
function add_tags_to_time_limit(obj, tag_id, tag_name){
    var index = $("#tags_table").find("input[name='tag_bq_id']").first().val();
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
                $("#time_limit_item_"+index+" .tag_ul ul").append("<li><p>"+tag_name+"</p><a href='javascript:void(0)' class='x' onclick='remove_tags_from_time_limit(this)'>x</a>\n\
      <input type='hidden' name='[time_limit]["+index+"][tags][]' value='"+tag_id+"'/></li>");
            }else{
                tishi("已添加该标签!");
            }
        }
    }
}


$(function(){
    //点击跳出设定时间弹出层
    $("#question_list").on("click", ".clock_icon", function(){        
        var que_id = $(this).parents(".ab_list_title").find("input[name='question_id']").first().val();
        var win_width = $(window).width();
        var win_height = $(window).height();
        var layer_height = $("#set_time_div").height();
        var layer_width = $("#set_time_div").width();
        $("#set_time_div").css('display','block');
        $("#set_time_div").css('top',(win_height-layer_height)/2);
        $("#set_time_div").css('left',(win_width-layer_width)/2);
        var doc_height = $(document).height();
        $(".mask").css("height",doc_height);
        $(".mask").css("display","block");
        $("#set_time_div").find("button").first().removeAttr("onclick");
        $("#set_time_div").find("button").first().attr("onclick", "new_question_set_time_valid('"+que_id+"',this)");
        return false;
    });

    //点击分享
    $("#question_list").on("click", ".share_icon", function(){
        //var type = $(this).parents(".ab_list_title").find("input[name='question_type']").first().val();
        var que_id = $(this).parents(".ab_list_title").find("input[name='question_id']").first().val();
        var que_name = $(this).parents(".ab_list_title").find("h1").first().text();
        var school_class_id = $("#school_class_id").val();
        var this_icon = $(this);
        var que_name_1 = que_name.split("(")[0];
        var que_name_2 = que_name.split("(")[1];
        if(que_name_2==undefined || que_name_2==""){
            var doc_height = $(document).height();
            $(".mask").css("height",doc_height);
            $("#set_name_div").show();
            $(".mask").show();
            $("#set_name_div").find("button").removeAttr("onclick");
            $("#set_name_div").find("button").attr("onclick", "set_question_name_valid('"+que_id+"','"+school_class_id+"')");
        }else{
            $.ajax({
                type: "get",
                url: "/school_classes/"+school_class_id+"/question_packages/share_question",
                dataType: "json",
                data: {
                    que_id : que_id,
                    que_name : que_name_2.split(")")[0]
                },
                success: function(data){
                    if(data.status == 0){
                        tishi("分享成功!");
                        this_icon.addClass("share_icon_ed");
                        this_icon.removeClass("share_icon");
                        this_icon.parents(".ab_list_title").find("h1").first().text(que_name_1+"("+que_name_2);
                    }else if(data.status == 1){
                        tishi("此题已经分享过");
                    }else if(data.status == 2){
                        tishi("该大题下未保存任何小题,请先创建小题！");
                    }
                },
                error: function(data){
                    tishi("数据错误!");
                }
            })
        }
        return false;
    });

    //如果已分享，则阻止该分享按钮冒泡
    $("#question_list").on("click", ".share_icon_ed", function(){
        return false;
    })
    //点击删除该大题
    $("#question_list").on("click", ".delete_icon", function(){
        var que_id = $(this).parents(".ab_list_title").find("input[name='question_id']").first().val();
        var school_class_id = $("#school_class_id").val();
        var flag = confirm("确定删除该大题?");
        var del_a = $(this);
        if(flag){
            $.ajax({
                type: "get",
                url: "/school_classes/"+school_class_id+"/question_packages/delete_question",
                dataType: "json",
                data: {
                    question_id : que_id
                },
                success: function(data){
                    if(data.status==1){
                        tishi("删除成功!");
                        if(school_class_id == 0){
                            del_a.parents(".assignment_body_list").remove();
                        }else{
                            del_a.parents(".assignment_body_list").remove();
                            this_index = $(".assignment_body_list").index($(this).parent());
                            if(gloab_index>this_index)
                            {
                                gloab_index--
                            }
                        }
                
                    }else{
                        tishi("删除失败!");
                    }
                },
                error: function(data){
                    tishi("数据错误!");
                }
            })
        };
        return false;
    })
})

//设定时间验证
function new_question_set_time_valid(question_id, obj){
    var hour = $.trim($("#new_question_hour").val());
    var minute = $.trim($("#new_question_minute").val());
    var second = $.trim($("#new_question_second").val());
    var tes = new RegExp(/^[0-9]*[1-9][0-9]*$/);
    var flag = true;
    if((hour=="" || hour == "时") && (minute=="" || minute == "分") && (second=="" || second == "秒")){
        tishi("请至少输入一个时间!");
        flag = false;
    }else if((hour != "时" && tes.test(hour)==false) || (minute != "分" && tes.test(minute)==false) || (second != "秒" && tes.test(second)==false)){
        tishi("请输入正确的时间,时间必须为正整数!");
        flag = false;
    };
    if(flag){
        add_time_to_question(hour, minute, second, question_id);
        $(obj).parents(".tab500").hide();
        $(".mask").hide();
    }
}

//设置名称验证
function set_question_name_valid(question_id, school_class_id){
    var name = $.trim($("#new_question_name").val());
    if(name=="" || name=="名称"){
        tishi("请输入名称!");
    }else{
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/question_packages/share_question",
            dataType: "json",
            data: {
                que_id : question_id,
                que_name : name
            },
            success: function(data){
                if(data.status==0){
                    tishi("分享成功!");
                    $("#set_name_div").hide();
                    $(".mask").hide();
                    var q_ids = $("#question_list").find("input[name='question_id']");
                    $.each(q_ids, function(){
                        if($(this).val()==question_id){
                            var txt = $(this).parents(".ab_list_title").find("h1").first().text();
                            $(this).parents(".ab_list_title").find("h1").first().text(txt+"("+name+")");
                            var share_icon = $(this).parents(".ab_list_title").find(".share_icon");
                            share_icon.addClass("share_icon_ed");
                            share_icon.removeClass("share_icon");
                        }
                    });
                }else if(data.status == 1){
                    tishi("此题已经分享过");
                }else if(data.status == 2){
                    tishi("该大题下未保存任何小题,请先创建小题！");
                }
            },
            error: function(data){
                tishi("数据错误!");
            }
        })
    }
}
//将时间添加到question里面
function add_time_to_question(hour, minute, second, question_id){
    var school_class_id = $("#school_class_id").val();
    if(question_id==undefined || question_id=="0"){
        tishi("数据错误!");
        return false;
    }else{
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/question_packages/set_question_time",
            dataType: "json",
            data: {
                hour :　hour,
                minute : minute,
                second : second,
                question_id : question_id
            },
            success: function(data){
                if(data.status==1){
                    tishi("设置成功!");
                    if(data.type=="time_limit"){
                        $("#create_time_limit_hour").val(data.time_int[0]);
                        $("#create_time_limit_minute").val(data.time_int[1]);
                        $("#create_time_limit_second").val(data.time_int[2]);
                    }
                    var str = "参考时间：";
                    if(data.time_int[0] > 0){
                        str += data.time_int[0] + "时";
                    };
                    if(data.time_int[1] > 0){
                        str += data.time_int[1] + "分";
                    };
                    if(data.time_int[2] > 0){
                        str += data.time_int[2] + "秒";
                    };
                    var q_ids = $("#question_list").find("input[name='question_id']");
                    $.each(q_ids, function(){
                        if($(this).val()==question_id){
                            $(this).parents(".ab_list_title").find("span[name='cankaoshijian']").first().text(str);
                        }
                    });
                }else{
                    tishi("设置失败!");
                }
            },
            error: function(data){
                tishi("数据错误!");
            }
        })
    }
}

function save_wanxin_branch(obj,school_class,question_pack){
    var question_id = $($(obj).parents(".ab_list_open")[0]).find(".question_id").val();
    var params = $($(obj).parents(".gapFilling_questions")[0]).find("form").serialize();
    var branch_question = $($(obj).parents(".gapFilling_questions")[0]).find(".branch_question_form");
    var texts = branch_question.find("input[type=text]");
    var arr =[]
    for(var i=0;i<texts.length;i++){
        if ($.inArray($.trim($(texts[i]).val()), arr)>=0) {
            tishi("完形填空选项内容不能重复");
            return false;
        } else {
            arr[arr.length] = $.trim($(texts[i]).val());
        }
        if(!get_str_len($.trim($(texts[i]).val()))){
            tishi("完形填空选项字符长度不能大于250！");
            return false;
        }
        if($.trim($(texts[i]).val())==""){
            tishi("完形填空选项不能为空！");
            return false;
        }
    }
    var radios = branch_question.find("input[type=radio]:checked").length;
    if(radios == 0){
        tishi("请给出正确答案！");
        return false;
    }
    $(obj).removeAttr("onclick");
    var branch_question_id = $($(obj).parents(".gapFilling_questions")[0]).find(".branch_question_id").val();
    $.ajax({
        type:'post',
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
        tishi("内容不能为空！");
        return false;
    }
    if(!get_str_len($.trim(content).length) ){
        tishi("内容长度不能大于250！");
        return false;
    }
    var branch_question_id = $($(obj).parents(".questions_item")[0]).find(".branch_question_id").val();
    $(obj).removeAttr("onclick");
    $.ajax({
        type:'post',
        dataType:"script" ,
        url:"/school_classes/"+school_class+"/question_packages/"+question_pack+"/save_paixu_branch_question",
        data:"question_id="+question_id+"&branch_question_id="+branch_question_id+"&gloab_index="+gloab_index+"&"+params,
        success:function(data){

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
    $("#tags_table").find("input[name='q_index']").first().val(gloab_index);
    $("#tags_table").find("input[name='b_index']").first().val(q_index);
    $("#tags_table").find("input[name='tag_bq_type']").first().val("paixu");
    $("#tags_table").find("input[name='branch_question_id']").first().val(branch_question_id);
    $.each(lis, function(){
        var current_input = $(this).find("input").first();
        // current_input.attr("onclick","add_content_to_paixu(this,"+q_index+","+ branch_question_id+")")
        $(current_input).on("ifChecked", function(){
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
            url:"/school_classes/"+shcool_id+"/question_packages/save_branch_tag",
            dataType:"json",
            data:"branch_question_id="+branch_question_id+"&branch_tag_id="+value,
            success:function(data){
                if(data.status == 1){
                    var old = $($( $(".assignment_body_list")[gloab_index] ).find(".questions_item")[q_index]);
                    old.find(".tag_ul ul").
                    append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\"paixu\")' class='x'>X</a></li>");
                }else if(data.status == 2){
                    tishi("已添加该标签！");
                }else if(data.status == 3){
                    tishi("已添加该标签！");
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
                    append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\"wanxin\")' class='x'>X</a></li>");
                }else if(data.status == 2){
                    tishi("已添加该标签！");
                }else if(data.status == 3){
                    tishi("已添加该标签！");
                }
            }
        })
    }
}


function delete_tags(obj,shcool_id,question_pack_id,tag_id,branch_question_id,type){

    if(confirm("确定删除此标签?")){
        if(type == 'paixu'){
            var question_item = $(obj).parents(".questions_item")[0]
            var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".questions_item").index($(question_item));
            var type = 'paixu'
            $.ajax({
                dataType:'script',
                url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
                data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type
            });
    
        }else if(type=='wanxin'){
            var question_item = $(obj).parents(".gapFilling_questions")[0]
            var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".gapFilling_questions").index($(question_item));
            var type = 'wanxin'
            $.ajax({
                dataType:'script',
                url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
                data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type
            });
        }else if(type=='select'){
            var question_item = $(obj).parents(".gapFilling_questions")[0]
            var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".gapFilling_questions").index($(question_item));
            $.ajax({
                dataType:'json',
                url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
                data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type,
                success:function(data){
                    if(data.status == 1){
                        $(obj).parent().remove()
                    }else{
                        tishi("删除失败！")
                    }
                }
            });
        }else if(type="lianxian"){
            var question_item = $(obj).parents(".gapFilling_questions")[0]
            var q_index =   $($(obj).parents(".ab_list_box")[0]).find(".gapFilling_questions").index($(question_item));
            $.ajax({
                dataType:'json',
                url:"/school_classes/"+shcool_id+"/question_packages/"+question_pack_id+"/delete_branch_tag",
                data:"gloab_index="+gloab_index+"&q_index="+q_index+"&tag_id="+tag_id+"&branch_question_id="+branch_question_id+"&type="+type,
                success:function(data){
                    if(data.status == 1){
                        $(obj).parent().remove()
                    }else{
                        tishi("删除失败！")
                    }
                }
            });
        }
    }
}

function add_wanxin_tags(obj, index){

    common_tags(obj);
    var branch_question_id = $(obj).parents(".gapFilling_questions").find(".branch_question_id").val();
    var question_item = $(obj).parents(".gapFilling_questions")[0]
    var q_index = $($(obj).parents(".gapFilling_box")[0]).find(".gapFilling_questions").index($(question_item));
    $("#tags_table").find("input[name='q_index']").first().val(gloab_index);
    $("#tags_table").find("input[name='b_index']").first().val(q_index);
    $("#tags_table").find("input[name='tag_bq_type']").first().val("wanxin");
    $("#tags_table").find("input[name='branch_question_id']").first().val(branch_question_id);
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
    //先取消监听
    var checks = $("#tags_table").find("input[type='checkbox']");
    $.each(checks,function(){
        var tag_name = $(this).parents("li").find("p").first().text();
        var tag_id = $(this).val();
        $("#tags_table").find("ul").append("<li><input type='checkbox' value='"+tag_id+"'/><p>"+tag_name+"</p></li>");
        $(this).parents("li").remove();
    });
    //再添加监听
    $('input[type=checkbox], input[type=radio]').iCheck({
        checkboxClass: 'icheckbox_square-aero',
        radioClass: 'iradio_square-aero',
        increaseArea: '20%' // optional
    });
    var divs = $("#tags_table").find("div.icheckbox_square-aero");
    $.each(divs, function(){
        $(this).removeAttr("class");
        $(this).attr("class", "icheckbox_square-aero");
    });
    var width = $("#tags_table").width();
    var height = $(obj).height();
    $("#tags_table").css("display", "block");
    $("#tags_table").css({
        'left':($(obj).offset().left-width)+'px',
        'top':($(obj).offset().top+height)+'px'
    });
}

function open_time_set(obj){
    $("#time_limit_set_time").css("top","50px");
    $("#time_limit_set_time").css("display","inherit");
    stopPropagation(arguments[1]);
}

function wp_set_time(obj){
    var flag = true;
    var q_items = $("#time_limit_ab_article").find("div.questions_item");
    var hour = $("#create_time_limit_hour").val();
    var minute = $("#create_time_limit_minute").val();
    var second = $("#create_time_limit_second").val();
    if((hour=="" || hour=="时") && (minute=="" || minute=="分") && (second=="" || second=="秒")){
        flag = false;
        tishi("尚未指定时间");
        return false;
    };
}

function wanxin_save_btn(obj){
    var wanxin_id = $(obj).parents(".assignment_body_list").find(".ab_list_box").find(".wanxin_content").attr("id");
    var editor = KindEditor.instances;
    for(var i=0;i<editor.length;i++){
        if(editor[i].id == wanxin_id)
            editor=editor[i]
    }
    // alert(wanxin_id+"="+editor.id);

    var div = $(".assignment_body").children(".assignment_body_list");
    var question_id = $("#"+editor.id).parents(".assignment_body_list").find(".question_id").val();
    var school_class_id = $("#school_class_id").val();
    //选项的个数，-1是因为每次多一个
    var length = $("#"+editor.id).parents(".assignment_body_list").find(".gapFilling_questions").length-1;
    var temp = editor.text();
    if($.trim(temp)==""){
        tishi("完形填空内容不能为空！");
        stopPropagation(arguments[1]);
        return false;
    }
    var sign_length=-1;
    if(temp.indexOf("[[sign]]") >=0){
        sign_length = temp.match(/\[\[sign\]\]/g).length;
    }else{
        sign_length = 0
    }
    // alert(KindEditor.instances.length+"..."+temp+"-->"+length+"-->"+sign_length);
    if(length != sign_length){
        tishi("选项标记与选项个数不匹配！");
        stopPropagation(arguments[1]);
        return false;
    }
    var text = editor.html();
    text = text.replace(/[>&<'";#]/g, function(x) {
        return "(**)" + x.charCodeAt(0) + "(*:*)";
    });
    $.ajax({
        type:'post',
        dataType:"text" ,
        url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/save_wanxin_content",
        data:"content="+text,
        success:function(data){
            if(data==1)
                tishi("保存成功！");
            else
                tishi("保存失败！");
        }
    });
    stopPropagation(arguments[1]);
}



function full_text(id){
    KindEditor.ready(function(K) {
        window.editor = K.create('#wanxin_'+id, {
            id : "wanxin_"+id,
            width : '420px',
            height : '600px',
            minWidth : '370px',
            items : ['source',
            'fontname', 'fontsize', '|', 'forecolor', 'hilitecolor', 'bold', 'italic', 'underline',
            'removeformat', '|',
            'justifyleft', 'justifycenter', 'justifyright', 'insertorderedlist',
            '|','mark','commit'],
            afterCreate : function() {
                this.sync();
            },
            afterBlur: function(){
                this.sync();
            }//同步KindEditor的值到textarea文本框
        });
    });
}


function upload_lisenting_ques(obj)
{
    var file_name = $(obj).val();
    var question_package_id = $("#question_package_id").val();
    if(file_name.match(/\..*$/) == ".zip")
    {
        $(obj).parents("form").find("input.question_package_id").val(question_package_id);
        $(obj).parents("form").submit();
    }
    else
    {
        tishi("请选择zip压缩包");
    }
}

function submit_import_listening(obj)
{
    $(obj).parent().prev().submit();
}
