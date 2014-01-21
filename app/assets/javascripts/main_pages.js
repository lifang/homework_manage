function check_send_microposts(value){
    var content =$.trim($(value).find("textarea").val());
    if(content == ""){
        tishi("内容不能为空");
        return false;
    }
}

function main_reply(value){
    var page = $(".pagination em").html();
    var textarea=$.trim($(value).parent().parent().find("textarea").val());
    if(textarea==""){
        tishi("不能为空！");
        return false;
    }
    var input=$(value).parent().parent().find("input");
    var micropost_id= $(input[0]).val();
    var micropost_user_id= $(input[1]).val();
    var micropost_user_type= $(input[2]).val();
    var teacher_id= $(input[3]).val();
    var class_index =get_index(value);
    $.ajax({
        async:true,
        type : 'get',
        url:'/microposts/'+micropost_id+'/create_reply',
        dataType:"script",
        data  :"textarea=" + textarea + "&micropost_id=" + micropost_id+"&class_index="+class_index+"&page="+page
        + "&micropost_user_id=" + micropost_user_id+ "&micropost_user_type=" + micropost_user_type+ "&teacher_id=" + teacher_id+"&conditions="+$("#condtions").val(),
        success:function(data){
            tishi("回复成功！");
        }
    });

}

function show_reply_again(value,name){
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
    location.href="#"+id;
    
}

function send_more_replies(value,micropost_id){
    var current_page = $(value).parent().find(".current_page").val();
    
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
    if(condtion!="all"){
        $("#condtions").val(id);
        $(question_classify[0]).attr("class","");
        $(question_classify[1]).attr("class","hover");
    }else{
        $(question_classify[0]).attr("class","hover");
        $(question_classify[1]).attr("class","");
        $("#condtions").val("");
    }
    value = $("#condtions").val();
    location.href="/school_classes/"+$("#class_id").val()+"/main_pages?condtions=" + value;
    
}

function delete_reply(id){
    var page = $(".pagination em").html();
    if(confirm("确认删除？"))
        $.ajax({
            async:true,
            type : 'get',
            url:"/microposts/"+id+"/delete_micropost_reply",
            dataType:"script",
            data  : "id="+id+"&page="+page+"&conditions="+$("#condtions").val(),
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
//location.href="/microposts/"+id+"/delete_micropost_reply?id="+id+"&page="+page;
}

function  show_reply(value,micropost_id){
    var answer_area = $(value).parent().parent().find(".answer_area");
    var index = get_index(value);
    if(answer_area.css("display")=="none"){
        $(answer_area).show();
         $.ajax({
            async:true,
            type : 'get',
            url:"/microposts/"+micropost_id+"/particate_reply_show",
            dataType:"script",
            data  : "micropost_id="+micropost_id+"&index="+index,
            success:function(data){

            }
        });

    }else{
        $(answer_area).hide();
    }
   

 
}
//调整高度
function height_adjusting(){
    $(".leftSide").css("height",$(".rightSide").height());
    $(".grade_box").css("height",$(".rightSide").height()-40);
    $(".work_book").css("height",$(".rightSide").height());
}