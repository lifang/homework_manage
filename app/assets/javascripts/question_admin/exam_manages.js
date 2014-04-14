//div_select div模拟select
$(function(){
    $(".tag_select").click(function() {
        $(this).parent(".div_select").find("ul").toggle();
    });
    $(document).on("click",".div_select ul li",function(){
        var text = $(this).html();
        var div_select = $(this).parents(".div_select");
        div_select.find(".tag_select span").html(text);
        div_select.find("input").val($(this).attr("index_id"));
        var cell_id = $("#teacher_question_share").find("input[name='chapter']").val();
        var episode_id = $("#teacher_question_share").find("input[name='unit_episode']").val();
        var question_types = $("#teacher_question_share").find("input[name='question_types']").val();
        window.location.href="/question_admin/exam_manages?cell_id="+cell_id+"&episode_id="+episode_id+"&question_types="+ question_types;
        $.ajax({
            url : "/question_admin/exam_manages",
            type : "get",
            dataType : "html",
            data : {
                cell_id : cell_id,
                episode_id : episode_id,
                question_types : question_types
            }
        })
        $(this).parents(".div_select").find("ul").hide();
    })
    $(document).bind('click', function(e) {
        var $clicked = $(e.target);
        if (! $clicked.parents().hasClass("div_select"))
            $(".div_select ul").hide();
    });

})

function delete_share_question(obj,share_question_id){
    var chapter_id = $("#select_chapter").parents(".div_select").find("input[name='chapter']").val();
    var episode_id = $("#select_episode").parents(".div_select").find("input[name='unit_episode']").val();
    var question_types = $("#select_question").parents(".div_select").find("input[name='question_types']").val();
    var flag = confirm("确定删除该大题?");
    if (flag){
        $.ajax({
            url : "/question_admin/exam_manages/delete_share_question",
            type : "get",
            dataType : "script",
            data : {
                share_question_id : share_question_id,
                episode_id : episode_id,
                cell_id : chapter_id,
                question_types : question_types
            }
        })
    }
}

function back_exam_manages(){
    window.location.reload();
}

function renameSQname(obj, question_id){
    $(obj).hide();
    $(obj).next().show();
    return false;
}

function saveSQname(obj, question_id){
    var name = $(obj).val();
    if($.trim(name) != ""){
        $(obj).hide();
        $.ajax({
            url : "/question_admin/question_manages/set_share_question_name",
            type : "post",
            dataType : "json",
            data : {
                question_id : question_id,
                name : name
            },
            success:function(data){
                if(data.status == 0){
                    $(obj).prev().text(name).show();
                }else{
                    tishi("更新出错")
                }
            }
        });
    }else{
      tishi("请输入名称")
    }
   return false;
}