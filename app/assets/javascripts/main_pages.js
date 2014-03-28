$(function(){
    $(document).on('click',".form_cancel",function(){
        $(".tab_mess").hide();
    })
})
function check_send_microposts(value){
    var content =$.trim($(value).find("textarea").val());
    if(content == ""){
        tishi("内容不能为空");
        return false;
    }
    else if(content.length>=60){
        tishi("长度不能超过60");
        return false;
    }
    else
    {
        $(value).find("button").click(function(){
            return false;
        });
    }
}

function main_reply(value,index){
    var page = $(".pagination em").html();
    if($(".pagination em").length==0){
        page = 1;
    }
    var textarea=$.trim($(value).parent().parent().find("textarea").val());
    if(textarea==""){
        tishi("不能为空！");
        return false;
    }
    if(textarea.length>60){
        tishi("字数不能大于60！");
        return false;
    }
    else
    {
        $(value).attr("disabled","disabled");
        var input=$(value).parent().parent().find("input");
        var micropost_id= $(input[0]).val();
        var micropost_user_id= $(input[1]).val();
        var micropost_user_type= $(input[2]).val();
        var teacher_id= $(input[3]).val();
        var class_index =index;
        $.ajax({
            async:true,
            type : 'get',
            url:'/microposts/'+micropost_id+'/create_reply',
            dataType:"script",
            data  :"textarea=" + textarea + "&micropost_id=" + micropost_id+"&class_index="+class_index+"&page="+page
            + "&micropost_user_id=" + micropost_user_id+ "&micropost_user_type=" + micropost_user_type+ "&teacher_id=" + teacher_id+"&conditions="+$("#condtions").val(),
            success:function(data){
                $(".tab_mess").hide();
                $(value).removeAttr("disabled");
                tishi("回复成功！");
            }
        });
    }

}

function show_reply_again(value,name,event){
    var input=$(value).parent().find("input");
    var answer=$(value).parents(".answer_area").find(".ask_area");
    var target_input =$(answer[1]).find("input");
    $(target_input[0]).val($(input[0]).val());
    $(target_input[1]).val($(input[1]).val());
    $(target_input[2]).val($(input[2]).val());
    var index = get_index2(value);
    var id = "target"+index;
    $(answer[1]).show();
    $(answer[1]).find("textarea").attr("placeholder","给"+name+"回复：");
    height_adjusting();
    $(answer[1]).find("textarea").attr("id",id);
    //location.href="#"+id;
    $(".tab_mess").find(".h1_content").html("回复")
    var html='<div class="ask_area" >\n\
               <input type="hidden" value="'+$(input[0]).val()+'" />\n\
                <input type="hidden" value="'+ $(input[1]).val() +'" />\n\
                <input type="hidden" value="'+ $(input[2]).val() +'" />\n\
                <input type="hidden" value="'+ $(input[3]).val() +'" />\n\
                <div class="textarea_box"><textarea cols="" rows=""></textarea></div>\n\
                <div class="tab_mess_btn">  \n\
<button onclick="main_reply(this,'+ index +')">提交</button>\n\
<button type="button" onclick="cancle_this_window(this)">取消</button></div>'
    $(".create_main_microposts").html(html);
    $(".tab_mess").css({
            "top":($(value).offset().top+20)+"px",
            "left":($(value).offset().left+0)+"px"
        })
    $(".tab_mess").show(100);
    
  
}


function send_more_replies(value,micropost_id){
    var current_page = $(value).parent().parent().find(".current_page").val();
    var index1=get_index(value);
    //tishi(index1+"--"+box.attr("class"));
    $.ajax({
        async:true,
        type : 'get',
        url:'/microposts/'+micropost_id+'/add_reply_page',
        dataType:"script",
        data  : "micropost_id=" + micropost_id
        + "&index=" + index1+ "&current_page=" + current_page,
        success:function(data){
        }
    });

}
function get_index(value){
    var index1=0;
    var box=$(value).parents(".question_area_box");
    var index1=0;
    var all_box = $("#reply_area").children(".question_area_box");
    for(var i=0;i<all_box.length;i++){
        if(all_box[i]==box[0]){
            index1 = i;

        }
    }
    return index1;
}
function get_index2(value){
    var index1=0;
    var box=$(value).parents(".question_area_box");
    var index1=0;
    var all_box = $("#reply_area").children(".question_area_box");
    for(var i=0;i<all_box.length;i++){
        if(all_box[i]==box[1]){
            index1 = i;

        }
    }
    return index1;
}

function change_conditions(condtion,id){
    var value=0;
    var question_classify =$(".question_classify").children("a");
    if(condtion=="my"){
        $("#condtions").val(id);
        $(question_classify[0]).attr("class","");
        $(question_classify[1]).attr("class","hover");
        $(question_classify[2]).attr("class","");
    }else if(condtion=="all"){
        $(question_classify[0]).attr("class","hover");
        $(question_classify[1]).attr("class","");
        $(question_classify[2]).attr("class","");
        $("#condtions").val("");
    }else{
        $(question_classify[0]).attr("class","");
        $(question_classify[1]).attr("class","");
        $(question_classify[2]).attr("class","hover");
        $("#condtions").val("false");
    }
    value = $("#condtions").val();
    location.href="/school_classes/"+$("#class_id").val()+"/main_pages?condtions=" + value;
    
}

function delete_reply(value,id,m_id){
    var page = $(".pagination em").html();
    var index1=get_index2(value);
    if(confirm("确认删除？"))
        $.ajax({
            async:true,
            type : 'get',
            url:"/microposts/"+id+"/delete_micropost_reply",
            dataType:"script",
            data  : "id="+id+"&page="+page+"&conditions="+$("#condtions").val()+"&index="+index1+"&m_id="+m_id,
            success:function(data){
            }
        });
//location.href="/microposts/"+id+"/delete_micropost_reply?id="+id+"&page="+page;
}
function delete_micropots(id){
    var page = $(".pagination em").html();
    if(confirm("确认删除？"))
        $.ajax({
            async:true,
            type : 'get',
            url:"/microposts/"+id+"/delete_micropost",
            dataType:"script",
            data  : "id="+id+"&page="+page+"&conditions="+$("#condtions").val(),
            success:function(data){

            }
        });
}

function  show_reply(value,micropost_id){
    var answer_area = $(value).parent().parent().find(".answer_area");
    var index = get_index(value);
    var types = $(value).attr('val');
    if(answer_area.css("display")=="none"){
        if (types == '0'){
            $(answer_area).show();
        }
    }else{
        $(answer_area).hide();
    }
    $(".tab_mess").css({
            "top":($(value).offset().top+20)+"px",
            "left":($(value).offset().left+0)+"px"
        })
    $.ajax({
        async:true,
        type : 'get',
        url:"/microposts/"+micropost_id+"/particate_reply_show",
        dataType:"script",
        data  : "micropost_id="+micropost_id+"&index="+index+'&types='+types,
        success:function(data){
        }
    });

    
   

 
}
//调整高度
function height_adjusting(){
    $(".book_box_con").css("min-height",$(".book_box_page").height());
    $(".leftSide").css("height",$(".rightSide").height());
    $(".grade_box").css("height",$(".rightSide").height()-40);
    $(".work_book").css("height",$(".rightSide").height());
}

//删除学生与班级的关系
function delete_student_relation(school_class_id, student_id)
{
    if(confirm("确认删除？"))
        $.ajax({
            async:true,
            type : "POST",
            url:"/school_classes/"+school_class_id+"/main_pages/delete_student",
            dataType:"script",
            data  :{
                school_class_id : school_class_id,
                student_id : student_id
            },
            success:function(data){
            }
        });
}

function cancle_this_window(obj){
    $($(obj).parents(".tab_mess")[0]).hide(10);
}