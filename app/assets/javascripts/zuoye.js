/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
var branchQuestion = "<tr class=\"done_tr\">\n\
                           <td>\n\
                                <div class=\"td_text\">\n\
                                  <a href=\"javascript:void(0)\" class=\"remove\" onclick = \"removeBranchQues(this)\">删除</a>\n\
                                  <p class=\"td_text_p tooltip_title\" title=\"双击句子可以进行编辑和修改\" ondblclick=\"ModifyQuestion(this)\"></p>\n\
                                  <input name=\"branch[content]\" type=\"text\" class=\"td_text_input\" onblur=\"hideInput(this)\"/>\n\
                                </div>\n\
                              </td>\n\
                              <td width=\"100\" class=\"td_func_bg\">\n\
                                 <form action=\"\" method=\"post\" data-remote=\"true\" data-type=\"script\">\n\
                                    <a class=\"up_voice_a\">\n\
                                      <span>上传音频</span>\n\
                                         <input name=\"branch_url\" type=\"file\" onchange=\"showPath(this)\"/>\n\
                                    </a>\n\
                                    <input name=\"branch[content]\" type=\"text\" class=\"td_text_input\"/>\n\
                                  <input type=\"hidden\" name=\"tr_index\" class=\"tr_index\"/>\n\
                                </form>\n\
                              </td>\n\
                     </tr>";

var page = 1;
var i = 10;

$(function(){
    $(".book_box_page").on('click', ".addPage", function(){
        var ul_parent = $(this).prev();
        var all_li =  ul_parent.find("li.question_li");
        var index = all_li.length;
        var top_li_href = ul_parent.find("li.question_li").first().find("a").attr("href");
        var question_pack_id = top_li_href.split("/")[4];
        if(all_li.last().find("a").attr("href") == "#"){
            if(confirm("当前题目还未保存，新增将丢失当前内容")){
                all_li.removeClass("hover");
                ul_parent.find("ul").append("<li  class=\"question_li hover\" onclick=\"liHover(this)\"><a href=\"#\">" + (index +1) +".</a></li>");
                afterClickAddpage();
                $.ajax({
                    url: "/question_packages/" + question_pack_id + "/render_new_question",
                    type: "GET",
                    dataType: "html",
                    success:function(data){
                        $(".book_box .steps").html(data);
                        height_adjusting();
                    },
                    error:function(data){
                        tishi(data)
                    }
                })
            }
        }
        else{
            var count_line = 0;
            var count_finish_line = 0;
            $("div.book_box_table").find("table").find("tbody").find("tr").each(function(){
                count_line += 1;
//                alert("line:"+count_line);
                if($(this).attr("class"))
                {
                    if($(this).find("td").eq(1).find("form").length>0)
                    {
                        if($(this).find("td").eq(1).find("form").find("a").find("audio").length>0)
                        {
                            count_finish_line += 1;
                        }
                        else
                        {}
                    }
                    else{}
                }
                else{}

            });
//            alert(count_line);
//            alert(count_finish_line);
            if(count_line != 1)
            {
                var question_type = $("#question_types").val();
                if((question_type!=1 && count_finish_line == (count_line-1)) || question_type==1)
                {
                    all_li.removeClass("hover");
                    ul_parent.find("ul").append("<li  class=\"question_li hover\" onclick=\"liHover(this)\"><a href=\"#\">" + (index +1) +".</a></li>");
                    afterClickAddpage();
                    $.ajax({
                        url: "/question_packages/" + question_pack_id + "/render_new_question",
                        type: "GET",
                        dataType: "html",
                        success:function(data){
                            $(".book_box .steps").html(data);
                            height_adjusting();
                        },
                        error:function(data){
                            tishi(data)
                        }
                    })
                }
                else{
                      tishi("有"+ (count_line-count_finish_line-1) +"题未编辑完成或未上传音频,请完成编辑！");
                }
            }
            else
            {
                if(count_finish_line == 0)
                {
                    tishi("每题至少有一个小题！");
                }
            }
        }
    });
});

function afterClickAddpage(){
    var parent = $('div.book_box_page');
    var box_height = $(".book_box_page_box").height();
    var ul_show = parent.find('.book_box_page_box ul');
    var new_all_li = ul_show.find('li');
    var len = new_all_li.length;
    var page_count = Math.ceil(len/i);
    page = page_count;
    ul_show.animate({
        marginTop:''+box_height*(1- page_count)
    },'slow');
                
}

function GoForthStep(question_pack_id, school_class_id){
    var first_selected = $(".first_step").find(".addwork_btn a.selected");
    var question_type = first_selected.find("span").hasClass("write_a") ? 0 : 1;  //大题题型， 0是听力， 1是朗读
    var second_selected = $(".second_step").find(".addwork_btn a.selected");
    var new_or_refer = second_selected.find("span").hasClass("build_a") ? 0 : 1;  //大题的小题来源， 0是新建， 1是引用

    var cell_id = $(".third_step").find("select.cell_ids option:selected").val();
    var episode_id = $(".third_step").find("select#cell_"+ cell_id + " option:selected").val();
    if(cell_id == "请选择单元"){
        tishi("请选择单元！")
        return false;
    }

    if(episode_id=="请选择课"){
        tishi("请选择课！")
        return false;
    }
    $(".third_step .remark_btn").find("button").attr("disabled", "disabled");
    $.ajax({
        url: "/question_packages",
        type: "POST",
        dataType: "html",
        data: {
            question_type: question_type,
            new_or_refer: new_or_refer,
            cell_id: cell_id,
            episode_id: episode_id,
            question_pack_id: question_pack_id ? question_pack_id : ""
        },
        success:function(data){
            if(data!="-1" && data!="-2"){
                $(".book_box .steps").html(data);
                if (question_type == 0) {
                	$("#new_xj_red").show();
                	$("#new_xj_write").hide();
                } else {
                	$("#new_xj_red").hide();
                	$("#new_xj_write").show();
                }
                $(".book_box_table table > tbody > tr:odd").addClass("tbg");
                height_adjusting();
                var question_id = $("#hidden_question_id").val();
                var question_pack_id = $("#hidden_question_pack_id").val();
                $(".remark").parents("form").attr("action", "/school_classes/" + school_class_id +"/question_packages/" + question_pack_id );
                $(".remark").parents("form").append("<input name=\"_method\" type=\"hidden\" value=\"put\">")
                $(".remark").show("<input name=\"_method\" type=\"hidden\" value=\"put\">");
                $(".book_box_page li.hover").find("a").attr("href", "/school_classes/" + school_class_id +"/question_packages/" + question_pack_id + "/questions/" + question_id + "/edit");
                $(".book_box_page li.hover").find("a").attr("data-remote", true);
                $(".book_box_page li.hover").find("a").attr("data-type", "script");
            }else if(data=="-1"){
                tishi("保存失败");
            }else if(data=="-2"){
                tishi("该单元下没有题目可以引用");
            }
        },
        error:function(data){
            tishi(data)
        }
    })

}

function checkText(obj, path){
    var blanket_reg = new RegExp(/[\s]+/g);
    var value = $.trim($(obj).val()).replace(blanket_reg," ");

    if(value==""){
        //        tishi("内容不能为空");
        $(obj).val("");
    }
//    else if(value.match(/[^A-Za-z'0-9!,?:."' ]/g)!=null)
//    {
//        tishi("输入有错，有效范围:英文字母、逗号、叹号、单引号、双引号、问号、冒号及数字");
//        $(obj).val("");
//    }
    else{
        if($("#question_types").length > 0 )
        {
            var question_types = $("#question_types").val();
            $(obj).val(value);
            $(obj).parents("tr").before(branchQuestion);
            $(obj).parents("tr").prev().find("input.td_text_input").attr("onblur", "hideInput(this," + question_types +")")
            $(".book_box_table table > tbody > tr:odd").addClass("tbg");
            var done_tr = $(".book_box_table table tr.done_tr");
            var new_done_tr = done_tr.last();
            new_done_tr.find("p.td_text_p").text(value);
            new_done_tr.find("input.td_text_input").val(value);
            new_done_tr.find("form").attr("action", path);
            var index = done_tr.index(new_done_tr);
            new_done_tr.find(".tr_index").val(index);
            if(question_types == 1)
            {
                $(obj).parent().parent().prev().find("form").submit();
            }
            $(obj).val("");

        }
        else{
    //没有题型则清空输入
    }
    }
}

function showPath(obj){
    var tr_index = $(obj).parent().parent().find("[class='tr_index']").val();
    if(tr_index=="")
    {
        var done_tr = $(".book_box_table table tr.done_tr");
        var new_done_tr = $(obj).parent().parent().parent().parent();
        var index = done_tr.index(new_done_tr);
        $(obj).parent().parent().find("[class='tr_index']").val(index);
    }
    var fil_name =  $(obj).val();
    var img_extension = fil_name.substring(fil_name.lastIndexOf('.') + 1).toLowerCase();
    if(img_extension == "mp3" || img_extension == "amr" || img_extension == "wav"){
    }else{
        tishi("音频格式不对! 仅支持mp3、amr、wav格式");
        return false;
    }
    var $a = $(obj).parent("a");
    var content = $(obj).parents("td").prev().find("input.td_text_input").val();
    if($.trim(content)==""){
        tishi("小题内容不能为空!")
    }else{
        $("#fugai").show();
        $("#fugai1").show();
        $(obj).parents("form").submit();
    }
}

function removeBranchQues(obj){
    if(confirm("确定删除？")){
        var url = $(obj).parents("tr.done_tr").find("td.td_func_bg form").attr("action");
        var question_type = $("#question_types").val();
        if($(obj).parents("tr.done_tr").find("td.td_func_bg a").hasClass("up_voice_a") && question_type == 0){
            $(obj).parents("tr.done_tr").remove();
        }else{
            if(question_type == 1){
                var branch_id = $(obj).parents("tr.done_tr").find("form input[name=branch_id]").val();
                url = url + "/" + branch_id;
            }
            $.ajax({
                url:url,
                type: "delete",
                dataType: "text",
                success: function(data){
                    if(data == 0){
                        $(obj).parents("tr.done_tr").remove();
                    }
                }
            });
        }
    }
}

function liHover(obj){
    var top_li_href = $(obj).parents("ul").find("li.question_li").first().find("a").attr("href");
    if(typeof(top_li_href)!="undefined"){
        var question_pack_id = top_li_href.split("/")[4];
        var all_li =  $(obj).parents("ul").find("li.question_li");
        all_li.removeClass("hover");
        $(obj).addClass("hover");
        if($(obj).find("a").attr("href") == "#" && ($(".first_step").css("display") == "none" || typeof($(".first_step").css("display"))=="undefined")){
            $.ajax({
                url: "/question_packages/" + question_pack_id + "/render_new_question",
                type: "GET",
                dataType: "html",
                success:function(data){
                    $(".book_box .steps").html(data);
                    height_adjusting();
                },
                error:function(data){
                    tishi(data);
                }
            })
        }
    }
}

function ModifyQuestion(obj){
    $(obj).css("display","none");
    $(obj).parent().find(".td_text_input").css("display","inline-block").focus();
    $(obj).parent().find(".td_text_input").val($(obj).html());
}

function hideInput(obj, ques_type){
    var old_content = $(obj).parents("td").next().find("input.td_text_input").val();
    var blanket_reg = new RegExp(/[\s]+/g);
    var content = $.trim($(obj).val()).replace(blanket_reg," ");
    if($.trim(content)==""){
        tishi("内容不能为空!");
        $(obj).val(old_content);
        $(obj).hide();
        $(obj).parent().find("p").css("display","inline-block");
    }
    else if(content == old_content){
        $(obj).hide();
        $(obj).val(content);
        $(obj).parent().find("p").css("display","inline-block");
    }
//    else if(content.match(/[^A-Za-z'0-9!,?:."' ]/g)!=null){
//        tishi("输入有错，有效范围:英文字母、逗号、叹号、单引号、双引号、问号、冒号及数字");
//        $(obj).val(old_content);
//        $(obj).hide();
//        $(obj).parent().find("p").css("display","inline-block");
//    }
    else{
        $(obj).val(content);
        $(obj).css("display","none");
        $(obj).parent().find("p").css("display","inline-block");
        $(obj).parent().find("p").html(content);
        $(obj).parents("td").next().find("input.td_text_input").val(content);
        if($(obj).parents("td").next().find("a").hasClass("voice_icon")){
            $(obj).parents("td").next().find("form").submit();
        }else{
            if(ques_type == 1){
              var url = $(obj).parents("td").next().find("form").attr("action");
              var branch_id = $(obj).parents("td").next().find("form").find("input[name='branch_id']").val();
              $.ajax({
                  url: url + "/" + branch_id,
                  type: "PUT",
                  dataType: "script",
                  data: {"branch[content]" : content},
                  success:function(data){
                      //tishi(data.message == 1 ? "保存成功" : "保存失败")
                  },
                  error:function(data){
                     tishi("请求出错了");
                  }
              })
            }
        }
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


//题号向上滚动
function questionUp(obj){
    var $parent = $(obj).parents('div.book_box_page');
    var $ul_show = $parent.find('.book_box_page_box ul');
    var box_height = $(".book_box_page_box").height();
    var len = $ul_show.find('li').length;
    var page_count = Math.ceil(len/i);

    if(!$ul_show.is(':animated')){
        if(page > 1 & page <= page_count){
            $ul_show.animate({
                marginTop:'+='+box_height
            },'slow');
            page--;
        }
        if(page == 1){
            $(".bbp_up").removeAttr( "onclick" );
            if(typeof($(".bbp_down").attr("onclick"))=="undefined"){
                $(".bbp_down").attr("onclick", "questionDown(this)")
            }
        }
    }
}

//题号向下滚动
function questionDown(obj){
    var $parent = $(obj).parents('div.book_box_page');
    var $ul_show = $parent.find('.book_box_page_box ul');
    var box_height = $(".book_box_page_box").height();
    var len = $ul_show.find('li').length;
    var page_count = Math.ceil(len/i);

    if(!$ul_show.is(':animated')){
        if(page >= 1 & page < page_count){
            $ul_show.animate({
                marginTop:'-='+box_height
            },'slow');
            page++;
        }
        if(page == page_count){
            $(".bbp_down").removeAttr( "onclick" );
            if(typeof($(".bbp_up").attr("onclick"))=="undefined"){
                $(".bbp_up").attr("onclick", "questionUp(this)")
            }
        }
    }
}

//显示对应单元的课
function loadEpisode(obj){
    var cell_id = $(obj).find("option:selected").val();
    if(cell_id != "请选择单元"){
        $(".third_step").find("select.episode_ids").hide();
        $("#cell_" + cell_id).show();
    }
}

//显示第一步
function showFirstStep(){
    $(".first_step").show();
    $(".second_step").hide();
    $(".third_step").hide();
}

//显示第二步
function showSecondStep(){
    $(".second_step").show();
    $(".third_step").hide();
    $(".first_step").hide();
}

//显示第三步
function showThirdStep(){
    $(".third_step").show();
    $(".second_step").hide();
    $(".first_step").hide();
}

//第二步，第三步hover效果
function addClassHover(obj){
  $(obj).addClass("hover");
}

function removeClassHover(obj){
  $(obj).removeClass("hover")
}
//第二步，第三步hover效果