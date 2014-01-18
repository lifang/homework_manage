/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
var branchQuestion = "<tr class=\"done_tr\">\n\
              <td>\n\
                <div class=\"td_text\">\n\
                  <a href=\"#\" class=\"remove\">删除</a>\n\
                  <p class=\"td_text_p tooltip_title\" title=\"双击句子可以进行编辑和修改\"></p>\n\
                  <input name=\"branch_content[]\" type=\"text\" class=\"td_text_input\"/>\n\
                </div>\n\
              </td>\n\
              <td width=\"100\" class=\"td_func_bg\">\n\
                <a href=\"#\" class=\"up_voice_a\">\n\
                  <span>上传音频</span>\n\
                  <input name=\"branch_url[]\" type=\"file\" onchange=\"showImg(this)\"/>\n\
                </a><p></p>\n\
              </td>\n\
            </tr>"

$(function(){
    $(".book_box_page").on('click', ".addPage", function(){
        var index = $(this).parents("ul").find("li.question_li").length;
        $(this).parents("ul").find("li.question_li").removeClass("hover");
        $(this).parent("li").before("<li  class=\"question_li hover\"><a href=\"#\">" + (index +1) +".</a></li>");
        if($(".first_step").length == 0){
            $.ajax({
                url: "/question_packages/new",
                type: "GET",
                dataType: "html",
                success:function(data){
                    $(".book_box .steps").html(data);
                },
                error:function(data){
                    alert(data)
                }
            })
        }
    });

    $(".book_box_con").on('click', ".addwork_btn a", function(){
        $(this).addClass("selected");
        $(this).parents(".book_box_con").hide().end();
        $(this).parents(".book_box_con").next().show();

    });

    $(".td_text").on('click', ".remove", function(){
        if(confirm("确定删除？")) $(this).parents("tr.done_tr").remove();
    })

    
    
});

function GoForthStep(){
    var first_selected = $(".first_step").find(".addwork_btn a.selected");
    var question_type = first_selected.find("span").hasClass("write_a") ? 0 : 1;  //大题题型， 0是听力， 1是朗读
    var second_selected = $(".second_step").find(".addwork_btn a.selected");
    var new_or_refer = second_selected.find("span").hasClass("build_a") ? 0 : 1;  //大题的小题来源， 0是新建， 1是引用

    var cell_id = $(".third_step").find("select.cell_ids option:selected").val();
    var episode_id = $(".third_step").find("select.episode_ids option:selected").val();

    $.ajax({
        url: "/question_packages",
        type: "POST",
        dataType: "html",
        data: {
            question_type: question_type,
            new_or_refer: new_or_refer,
            cell_id: cell_id,
            episode_id: episode_id
        },
        success:function(data){
            $(".book_box .steps").html(data);
        },
        error:function(data){
            alert(data)
        }
    })

}
function checkQuestionForm(obj){
var flag = true;
    $(obj).parents("form").find("tr.done_tr input[type=file]").each(function(){
        var resource_path = $(this).val();
        if(resource_path == ""){
            alert("有资源未上传");
            flag = false;
            return false;
        }
    })
    return flag;
}

function checkText(obj){
    var value = $(obj).val();
    if($.trim(value)==""){
        alert("内容不能为空");
    }else{
        $(obj).parents("tr").before(branchQuestion);
        var done_tr = $(".book_box_table table tr.done_tr");
        var new_done_tr = done_tr.last();
        new_done_tr.find("p.td_text_p").text(value);
       new_done_tr.find("input td_text_input").val(value);
        $(obj).val("");
    }
}

function showImg(obj){
    var fil_name =  $(obj).val();
    var $a = $(obj).parent("a");
    $a.next().attr("class", "showPath tooltip_title");
    $a.next().attr("title",fil_name );
    $a.next().text(fil_name);
}
