$(function(){
    $("#teacher_question_manage_tab").on("click", " .tag_select", function() {
        $(this).parent(".div_select").find("ul").toggle();
    });
    $("#teacher_question_manage_tab").on("click", " .div_select ul li", function() {
        var text = $(this).html();
        $(this).parents(".div_select").find(".tag_select span").html(text);

        $(this).parents(".div_select").find("ul").hide();
    });
    $(".select_box_s").on("click", " .tag_select", function() {
        $(this).parent(".div_select").find("ul").toggle();
    });
    $(".select_box_s").on("click", " .div_select ul li", function() {
        var text = $(this).html();
        $(this).parents(".div_select").find(".tag_select span").html(text);

        $(this).parents(".div_select").find("ul").hide();
    });
    $(document).bind('click', function(e){
        var $clicked = $(e.target);
        if (! $clicked.parents().hasClass("div_select"))
            $(".div_select ul").hide();
    });

    $("#teacher_question_manage_pag_div").on("click", ".pageTurn a", function(){    //题库管理，异步分页
        var href = $(this).attr("href");
        $.ajax({
            type: "get",
            url: href,
            dataType: "script",
            error: function(){
                tishi("数据错误!");
            }
        })
        return false;
    })
})

function teacher_question_manages_select_course(obj, school_class_id){  //选择科目
    var course_id = $(obj).find("input[type='hidden']").first().val();
    $("#teacher_question_manages_course_id").val(course_id);
    if(course_id=="0"){
        $("#teacher_select_2").find("ul").html("<li>教材</li>");
        $("#teacher_select_2").find("span").text("教材");
    }else{
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/teacher_question_manages/select_course",
            data: {
                course_id : course_id
            },
            dataType: "script",
            error: function(){
                tishi("数据错误!");
            }
        })
    }
}

function teacher_question_manages_search_ques(obj, school_class_id, type){  //根据不同类型搜索题目
    if(type=="teaching_material"){  //按教材搜索
        var tm_id = $(obj).find("input[type='hidden']").first().val();
        $("#teacher_question_manages_tm_id").val(tm_id);
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/teacher_question_manages",
            data: {
                search_type : type,
                teaching_material_id : tm_id
            },
            dataType: "script",
            error: function(){
                tishi("数据错误!");
            }
        })
    }else if(type=="cell"){     //按章搜索
        var cell_id = $(obj).find("input[type='hidden']").first().val();
        $("#teacher_question_manages_cell_id").val(cell_id);
        var tm_id = $("#teacher_question_manages_tm_id").val();
        if(tm_id!="0"){
            $.ajax({
                type: "get",
                url: "/school_classes/"+school_class_id+"/teacher_question_manages",
                data: {
                    search_type : type,
                    teaching_material_id : tm_id,
                    cell_id : cell_id
                },
                dataType: "script",
                error: function(){
                    tishi("数据错误!");
                }
            })
        }
    }else if(type=="episode"){  //按节搜索
        var tm_id = $("#teacher_question_manages_tm_id").val();
        var cell_id = $("#teacher_question_manages_cell_id").val();
        var episode_id = $(obj).find("input[type='hidden']").first().val();
        $("#teacher_question_manages_episode_id").val(episode_id);
        if(tm_id=="0" || cell_id=="0"){
            tishi("数据错误!");
        }else{
            $.ajax({
                type: "get",
                url: "/school_classes/"+school_class_id+"/teacher_question_manages",
                data: {
                    search_type : type,
                    teaching_material_id : tm_id,
                    cell_id : cell_id,
                    episode_id : episode_id
                },
                dataType: "script",
                error: function(){
                    tishi("数据错误!");
                }
            })
        }
    }else if(type=="type"){
        var type_id = $(obj).find("input[type='hidden']").first().val();
        var tm_id = $("#teacher_question_manages_tm_id").val();
        var cell_id = $("#teacher_question_manages_cell_id").val();
        var episode_id = $("#teacher_question_manages_episode_id").val();
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/teacher_question_manages",
            data: {
                search_type : type,
                teaching_material_id : tm_id,
                cell_id : cell_id,
                episode_id : episode_id,
                type_id : type_id
            },
            dataType: "script",
            error: function(){
                tishi("数据错误!");
            }
        })
    }
}

function share_que(que_id, school_class_id){
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop; //滚动条高度
    var doc_height = $(document).height();
    var win_width = $(window).width();
    var layer_width = $("#set_time_div").width();
    $("#tqm_set_que_name_div").css('top',100);
    $("#tqm_set_que_name_div").css('left',(win_width-layer_width)/2);
    $("#tqm_set_que_name_div").css('display','block');
    $(".mask").css("height",doc_height);
    $(".mask").css("display","block");
    $("#tqm_set_que_name_div").find("button").first().removeAttr("onclick");
    $("#tqm_set_que_name_div").find("button").first().attr("onclick", "tqm_set_que_name_valid('"+que_id+"',this,'"+school_class_id+"')")
}

function tqm_set_que_name_valid(que_id, obj, school_class_id){
    var que_name = $.trim($("#tqm_set_question_name").val());
    if(que_name=="" || que_name=="名称"){
        tishi("名称不能为空!");
    }else{
        $.ajax({
            type: "get",
            url: "/school_classes/"+school_class_id+"/teacher_question_manages/share_question",
            data: {q_id : que_id, name : que_name},
            dataType: "json",
            success: function(data){
                if(data.status==1){
                    tishi("已经分享!");
                }else if(data.status==2){
                    tishi("该大题下无小题!");
                }else{
                    tishi("分享成功!");
                    var q_ids = $("#teacher_question_manage_tab").find("input[name='q_id']");
                    $.each(q_ids, function(){

                        if($(this).val()==que_id){
                            var td = $(this).parents("tr").find("td")[3];
                            $(td).text(que_name);
                            var a = $(this).parents("tr").find("a.share");
                            a.removeAttr("class");
                            a.removeAttr("title");
                            a.removeAttr("onclick");
                            a.attr("class", "share_ed tooltip_html");
                            a.attr("title", "已分享");
                        }
                    })
                };
                $(".mask").hide();
                $("#tqm_set_que_name_div").hide();
            },
            error: function(){
                tishi("数据错误!");
            }
        })
    }
}
