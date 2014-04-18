//div_select div模拟select
$(function(){
    $(".tag_select").click(function() {
        $(this).parent(".div_select").find("ul").toggle();
    });

    $(".main").on("click", ".delete_icon", function(){
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

    $(document).on("click",".div_select ul li",function(){
        var text = $(this).html();
        var div_select = $(this).parents(".div_select");
        div_select.find(".tag_select span").html(text);
        div_select.find("input").val($(this).attr("index_id"));
        var cell_id = $("#teacher_question_share").find("input[name='chapter']").val();
        var episode_id = $("#teacher_question_share").find("input[name='unit_episode']").val();
        if($(this).parents("ul").attr("id")=="select_chapter"){
            episode_id = '';
        }
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


    $("#question_list, .main").on("click", ".amendName", function(){
        var scolltop = document.body.scrollTop|document.documentElement.scrollTop; //滚动条高度
        var doc_height = $(document).height();
        $("#set_name_div").css('top',100);
        $(".mask").css("height",doc_height);
        $("#set_name_div").show();
        $(".mask").show();
        $("#set_name_div").find("button").removeAttr("onclick");
        var que_id = $(this).attr("data-id");
        $("#set_name_div").find("button").attr("onclick", "check_question_name_valid("+que_id+")");
        
        return false;
    });

})

function check_question_name_valid(question_id){
    var name = $.trim($("#new_question_name").val());
    if(name=="" || name=="名称"){
        tishi("请输入名称!");
    }else{
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
                    tishi("设置成功!");
                    $("a[data-id="+ question_id +"]").prev().text(name);
                    $("#set_name_div").hide();
                    $(".mask").hide();
                }else{
                    tishi("设置失败")
                }
            }
        });
        
    }
}

function delete_share_question(obj,share_question_id){
    var chapter_id = $("#select_chapter").parents(".div_select").find("input[name='chapter']").val();
    var episode_id = $("#select_episode").parents(".div_select").find("input[name='unit_episode']").val();
    var question_types = $("#select_question").parents(".div_select").find("input[name='question_types']").val();
    var flag = confirm("确定删除该大题?");
    var page_value = getQueryString("page");
    if(page_value!= "" && page_value!="null" && page_value!=null ){
        var page = page_value;
    }else{
        var page = 1;
    }
    if (flag){
        $.ajax({
            url : "/question_admin/exam_manages/delete_share_question",
            type : "get",
            dataType : "script",
            data : {
                share_question_id : share_question_id,
                episode_id : episode_id,
                cell_id : chapter_id,
                question_types : question_types,
                page : page
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