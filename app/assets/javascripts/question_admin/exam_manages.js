//div_select div模拟select
$(function(){
    $(".tag_select").click(function() {
        $(this).parent(".div_select").find("ul").toggle();
    });
    $(document).on("click",".div_select ul li",function(){
        var text = $(this).html();
        var $val = $(this).attr("cell_id");
        $(this).parents(".div_select").find(".tag_select span").html(text);
        $(this).parents(".div_select").find("input.tag_input").val($val);
        $(this).parents(".div_select").find("ul").hide();
    })

    $(document).bind('click', function(e) {
        var $clicked = $(e.target);
        if (! $clicked.parents().hasClass("div_select"))
            $(".div_select ul").hide();
    });
    $(document).on("click","#select_chapter li", function(){
        var text = $(this).html();
        var $val = $(this).attr("cell_id");
        //        var unit_episode = $("#select_unit").parents(".div_select").find("input[name='unit_episode']").val();
        $("#select_unit").parents(".div_select").find("input[name='chapter']").val("");
        $(this).parents(".div_select").find("input[name='chapter']").val($val);
        var question_types = $("#select_question").parents(".div_select").find("input[name='question_types']").val();
        $.ajax({
            url : "/question_admin/exam_manages/set_cell",
            type : "post",
            dataType : "script",
            data : {
                cell_id : $val,
                //                unit_episode : unit_episode,
                question_types : question_types
            }
        })
    })
    $(document).on("click","#select_episode li", function(){
        var text = $(this).html();
        var $val = $(this).attr("episode_id");
        var chapter_id = $("#select_chapter").parents(".div_select").find("input[name='chapter']").val();
        var question_types = $("#select_question").parents(".div_select").find("input[name='question_types']").val();
        $(this).parents(".div_select").find("input[name='unit_episode']").val($val);
        $.ajax({
            url : "/question_admin/exam_manages/set_episode",
            type : "post",
            dataType : "script",
            data : {
                episode_id : $val,
                cell_id : chapter_id,
                question_types : question_types
            }
        })
    })
    $(document).on("click","#select_question li", function(){
        var text = $(this).html();
        var $val = $(this).attr("question_types");
        var chapter_id = $("#select_chapter").parents(".div_select").find("input[name='chapter']").val();
        var episode_id = $("#select_episode").parents(".div_select").find("input[name='unit_episode']").val();
        $(this).parents(".div_select").find("input[name='question_types']").val($val);
        $.ajax({
            url : "/question_admin/exam_manages/set_question_type",
            type : "post",
            dataType : "script",
            data : {
                episode_id : episode_id,
                cell_id : chapter_id,
                question_types : $val
            }
        })
    })
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
