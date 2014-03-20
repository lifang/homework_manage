// JavaScript Document

//问答切换显示X
function dia(e){
    $(e).hover(
        function(){
            $(this).find("a.x").css("display","block");
        },
        function(){
            $(this).find("a.x").css("display","none");
        }
        );
}
$(function(){
    dia(".askAnswer_area_con");
})


//统计-正确率-题型
$(function(){
    $(".item_content li a").click(function(e){
        $(".s_tab").css('display','block');
        $(".s_tab").css({
            'top':(e.pageY)+'px',
            'left':(e.pageX)+'px'
        });
    });

    $(".close").click(function(){
        $(this).parents(".s_tab").css("display","none");
    })
})

//  问答留言   鼠标点击别处隐藏tab
$(function(){
    $(document).on('click',".askAnswer_area_func a.comment_icon",function(e){
        $(".tab_mess").css('display','block');
        //alert($(".tab_mess").height()+e.pageY >= $(window).height())
        if( $(".tab_mess").height()+e.pageY >= $(window).height() ){
            $(".tab_mess").css({
                'top':(e.pageY-$(".tab_mess").height()-50)+'px',
                'left':(e.pageX-180)+'px'
            });
        }else{
            $(".tab_mess").css({
                'top':(e.pageY+30)+'px',
                'left':(e.pageX-180)+'px'
            });
        }
        return false;
    });
    $(document).bind('click', function (e) {
        if ( $(e.target).closest(".tab_mess").length>0 ) {
            if($(e.target).closest(".form_cancel").length>0){
                $(".tab_mess").css('display','none');
                return false;
            }else{
                $(".tab_mess").css('display','block');
            }
        }else{
            $(".tab_mess").css('display','none');
        }
    });
})



//ask_btn 发布问答
$(function(){
    $("a.ask_btn").click(function(e){
        var html = '<form action="/microposts" method="post" onsubmit="return check_send_microposts(this)" accept-charset="UTF-8">\n\
                <div class="textarea_box">\n\
<textarea name="microposts[content]" cols="" rows="" placeholder="字数限制60字"></textarea></div>\n\
                <div class="tab_mess_btn">\n\
<button type="submit" class="">提交</button>\n\
<button type="button" class="form_cancel">取消</button></div></form>'
        $(".create_main_microposts").html(html)
        $(".tab_mess").find(".h1_content").html("提问")
        $(".tab_mess").css('display','block');
        $(".tab_mess").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-180)+'px'
        });
        return false;
    });
})

//作业题面 标签   鼠标点击别处隐藏tab
$(function(){
    $(".qt_icon a.tag").click(function(e){
        $(".tag_tab").css('display','block');
        $(".tag_tab").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-192)+'px'
        });
        return false;
    });
    $(document).bind('click', function (e) {
        if ( $(e.target).closest(".tag_tab").length>0 ) {
            $(".tag_tab").css('display','block');
        }else{
            $(".tag_tab").css('display','none');
        }
    });
})

//侧边留言信息页面高度 点击滑出
$(function(){
    var ch = document.documentElement.clientHeight;
    $(".right_side_mess").css("height",$(document).height()-40);

    $(".email").click(function(){
        $(".right_side_mess").slideDown("slow");
    })
    $(document).bind('click', function (e) {
        if ( $(e.target).closest(".right_side_mess").length>0 || $(e.target).closest(".email").length>0 ) {
            $(".right_side_mess").slideDown("slow");
        }else{
            $(".right_side_mess").slideUp("slow");
        }
    });
})


//页面弹出层高度
//作业题面 标签
$(function(){
    $(".qt_icon a.tag").click(function(e){
        $(".tag_tab").css('display','block');
        $(".tag_tab").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-192)+'px'
        });
        return false;
    });

    $(document).bind('click', function (e) {

        if ( $(e.target).closest(".tag_tab").length>0 ) {
            $(".tag_tab").css('display','block');
        }else{
            $(".tag_tab").css('display','none');
        }

    });


})

// 个人信息 鼠标点击别处隐藏tab
$(function(){
    $(".userName").click(function(e){
        $(".tab_user").css('display','block');
        $(".tab_user").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-470)+'px'
        });
        return false;
    });
    $(document).bind('click', function (e) {
        if ( $(e.target).closest(".tab_user").length>0 ) {
            $(".tab_user").css('display','block');
        }else{
            $(".tab_user").css('display','none');
        }
    });
})


//tab
function tabFunc(c,t){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();

    var layer_height = $(t).height();
    var layer_width = $(t).width();

    $(".mask").css("height",doc_height);

    $(c).click(function(){
        $(t).css('display','block');
        $(t).css('top',(win_height-layer_height)/2);
        $(t).css('left',(win_width-layer_width)/2);
        $(".mask").css("display","block");
        return false;
    })

    $(".close").click(function(){
        $(this).parents(t).css("display","none");
        $(".mask").css("display","none");
    });
}
$(function(){
    //    tabFunc(".td_seeQuestion",".tab");
    //    tabFunc(".switchoverClass a",".tab");
    //    tabFunc("a.student_btn_a",".tab");
    //    tabFunc("a.time_icon",".tab");
    //    tabFunc("a.clock_icon",".tab");
    })

//页面弹出层高度
$(function(){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();
    var layer_height = $(".tab500").height();
    var layer_width = $(".tab500").width();
    $(".mask").css("height",doc_height);
    $(".tab500").css('top',(win_height-layer_height)/6);
    $(".tab500").css('left',(win_width-layer_width)/2);
    $(document).on('click',".close",function(){
        $(this).parents(".tab").css("display","none");
        $(".mask").css("display","none");
    })
})

//popup
function popup(t){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();

    var layer_height = $(t).height();
    var layer_width = $(t).width();

    var top = 0;
    var left = 0;
    $(".mask").css("height",doc_height);
    $(t).css('top',top);
    $(t).css('left',left);
    $(".mask").css("display","block");
    $(t).css('display','block');

    $(".close").click(function(){
        $(this).parents(t).css("display","none");
        $(".mask").css("display","none");
    });
}

//登录默认值
function focusBlur(e){
    $(e).focus(function(){
        var thisVal = $(this).val();
        if(thisVal == this.defaultValue){
            $(this).val('');
        }
    })
    $(e).blur(function(){
        var thisVal = $(this).val();
        if(thisVal == ''){
            $(this).val(this.defaultValue);
        }
    })
}

$(function(){
    focusBlur('.tab_switch li input');//
    focusBlur('.setTime_tab li input');//设置参考时间
    focusBlur('.setShare_tab li input');//设置分享作业名称
    focusBlur('.qt_input input');//创建作业题目输入文字
})

//班级分组 单击修改
$(function(){
    $("li.p_input p").click(function(){
        $(this).css("display","none");
        $(this).parent().find("input").css("display","inline-block");
        $(this).parent().find("input").focus();
        $(this).parent().find("input").val($(this).html());
    });
    $("li.p_input input").blur(function(){
        $(this).css("display","none");
        $(this).parent().find("p").css("display","inline-block");
        $(this).parent().find("p").html($(this).val());
        $(this).attr("value",$(this).val());
    //alert($(this).val());
    });
})

//题面 双击修改
function ondblclick(a,b){
    $(a).dblclick(function(){
        $(this).css("display","none");
        $(this).parent().find("input").css("display","inline-block");
        $(this).parent().find("input").focus();
        $(this).parent().find("input").val($(this).html());
    });
    $(b).blur(function(){
        $(this).css("display","none");
        $(this).parent().find("p").css("display","inline-block");
        $(this).parent().find("p").html($(this).val());
        $(this).attr("value",$(this).val());
    //alert($(this).val());
    });
}
$(function(){
    ondblclick(".qt_text p",".qt_text input");
})

//点击作业列表展开隐藏
$(function(){
    $(".ab_list_title").click(function(){
        if($(this).parent().find(".ab_list_box").is(":hidden")){
            $(this).parent().find(".ab_list_box").show();
            $(this).parent().addClass("ab_list_open");
        }else{
            $(this).parent().find(".ab_list_box").hide();
            $(this).parent().removeClass("ab_list_open");
        }

    })
})

//鼠标经过题型menu
$(function(){
    $(".qType_menu > ul > li").mouseover(function(){
        $(this).find("i.arrows").css("display","block");
        $(this).find(".second_menu").css("display","block");
    });
    $(".qType_menu").mouseout(function(){
        $(this).find("i.arrows").css("display","none");
        $(this).find(".second_menu").css("display","none");
    });
})

//题面 双击修改
function ondblclick(a,b){
    $(a).dblclick(function(){
        $(this).css("display","none");
        $(this).parent().find("input").css("display","inline-block");
        $(this).parent().find("input").focus();
        $(this).parent().find("input").val($(this).html());
    });
    $(b).blur(function(){
        $(this).css("display","none");
        $(this).parent().find("p").css("display","inline-block");
        $(this).parent().find("p").html($(this).val());
        $(this).attr("value",$(this).val());
    //alert($(this).val());
    });
}
$(function(){
    ondblclick(".qt_text p",".qt_text input");
})


//点击作业列表展开隐藏
$(function(){
    $(".ab_list_title").click(function(){
        if($(this).parent().find(".ab_list_box").is(":hidden")){
            $(this).parent().find(".ab_list_box").show();
            $(this).parent().addClass("ab_list_open");
        }else{
            $(this).parent().find(".ab_list_box").hide();
            $(this).parent().removeClass("ab_list_open");
        }

    })
})


//鼠标经过题型menu
$(function(){
    $(".qType_menu > ul > li").mouseover(function(){
        $(this).find("i.arrows").css("display","block");
        $(this).find(".second_menu").css("display","block");
    });
    $(".qType_menu").mouseout(function(){
        $(this).find("i.arrows").css("display","none");
        $(this).find(".second_menu").css("display","none");
    });
})



//tooltip-内容提示
$(function(){
    var x = 0;
    var y = 20;
    $(".tooltip_html").mouseover(function(e){
        this.myTitle=$(this).html();

        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";
        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){

        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})
//tooltip-title提示
$(function(){
    var x = 0;
    var y = 20;
    $(".tooltip_title").mouseover(function(e){
        this.myTitle=this.title;
        this.title="";
        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";

        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){
        this.title = this.myTitle;
        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})


//table偶数行变色
$(function(){
    $(".b_table > table > tbody > tr:even").addClass("tbg");
    $(".student_table table > tbody > tr:even").addClass("tbg");
});







///------------------------------------------------



// JavaScript Document
//tab
//popup
function popup(t){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();

    var layer_height = $(t).height();
    var layer_width = $(t).width();

    var top = 0;
    var left = 0;
    $(".mask").css("height",doc_height);
    $(t).css('top',top);
    $(t).css('left',left);
    $(".mask").css("display","block");
    $(t).css('display','block');

    $(".close").click(function(){
        $(this).parents(t).css("display","none");
        $(".mask").css("display","none");
    });
}

//显示窗口
function show_windows(div_id)
{
    var win_height = $(window).height();
    var win_width = $(window).width();
    var panel_height = $("#"+div_id+"").height();
    var panel_width = $("#"+div_id+"").width();
    var top = (win_height - panel_height)/2
    var left = (win_width - panel_width)/2
    if(top < 0) top = 0;
    $("#"+div_id+"").css("top", top);
    $("#"+div_id+"").css("left", left);
    $("#"+div_id+"").css("display","block");
}

function tabFunc(t){
    var win_width = $(window).width();
    var win_height = $(window).height();

    var layer_height = $(t).height();
    var layer_width = $(t).width();
    //alert($(".tab").width());
    if(!$(t).attr("class")=="tab list_classes"){
        $(t).css('top',(win_height-layer_height)/2);
    }else{
        if(win_height>=layer_height){
            $(t).css('top',(win_height-layer_height)/2);
        }else{
            $(t).css('top',0)
        }
    }
    $(t).css('left',(win_width-layer_width)/2);
    $(".close").click(function(){
        $(this).parents(t).css("display","none");
    });
}
$(function(){
    $(".flash").show();
    setTimeout("$('.flash').hide(1000)",2000);
//    tabFunc(".tab");
//tabFunc(".tab_article");
})

//页面高度
$(function(){
    var ch = document.documentElement.clientHeight;
    $(".area").css("height",ch);
    $(".rightSide").css("min-height",ch);
    $(".leftSide").css("height",$(".rightSide").height());
    $(".grade_box").css("height",$(".rightSide").height()-40);
    $(".work_book").css("height",$(".rightSide").height());
})

//登录默认值
function focusBlur(e){
    $(e).focus(function(){
        var thisVal = $(this).val();
        if(thisVal == this.defaultValue){
            $(this).val('');
        }
    })
    $(e).blur(function(){
        var thisVal = $(this).val();
        if(thisVal == ''){
            $(this).val(this.defaultValue);
        }
    })
}

$(function(){
    focusBlur('.login_box input');//登录input默认值
    focusBlur('.register_box input');//注册input默认值
})

//登录注册页 动画
$(function(){
    $(".goRegister_a").on("click",function(){
        if( !$(this).is(":animated")){
            $(".logoBox").css("display","none");
            $(".downLoad").css("display","none");
            $(".login_bg").animate({
                height: "60px",
            }, 200 , function(){
                $(".register").css("display","block");
            });
        }
    });
    $(".goLogin_a").on("click",function(){
        if( !$(this).is(":animated")){
            $(".register").css("display","none");
            $(".login_bg").animate({
                height: "437px",
            }, 200 , function(){
                $(".logoBox").css("display","block");
                $(".downLoad").css("display","block");
            });
        }
    })
})


//点击作业列表展开隐藏
$(function(){
    $(".ab_list_title").click(function(){
        if($(this).parent().find(".ab_list_box").is(":hidden")){
            $(this).parent().find(".ab_list_box").show();
            $(this).parent().addClass("ab_list_open");
        }else{
            $(this).parent().find(".ab_list_box").hide();
            $(this).parent().removeClass("ab_list_open");
        }

    })
})



//user_info 修改姓名邮箱
$(function(){
    $(".user_info p").click(function(){
        $(this).css("display","none");
        $(this).parent().find("input").css("display","block");
        $(this).parent().find("input").focus();
        $(this).parent().find("input").val($(this).html());
    });
    $(".user_info input").blur(function(){
        $(this).css("display","none");
        $(this).parent().find("p").css("display","block");
        $(this).parent().find("p").html($(this).val());
        $(this).attr("value",$(this).val())
        if($(this).attr("type")=="file"){
            $(this).css("display","block");
        }
    });
})



//tooltip-内容提示
$(function(){
    var x = 0;
    var y = 20;
    $(".tooltip").mouseover(function(e){
        this.myTitle=$(this).html();

        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";

        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){

        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})
//tooltip-title提示
$(function(){
    var x = 0;
    var y = 20;
    $(".tooltip_title").mouseover(function(e){
        this.myTitle=this.title;
        this.title="";
        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";

        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){
        this.title = this.myTitle;
        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})

//切换显示X
function dia(e){
    $(e).hover(
        function(){
            $(this).find("a.x").css("display","block");
        },
        function(){
            $(this).find("a.x").css("display","none");
        }
        );
}
$(function(){
    dia(".question_area_con");
    dia(".grade_con li");
    dia(".mess_box");
})


//table偶数行变色
$(function(){
    $(".assignWork_table table > tbody > tr:odd").addClass("tbg");
    $(".book_box_table table > tbody > tr:odd").addClass("tbg");
});


//创建作业 book_box_con
$(function(){
    $(".book_box_con").css("min-height",$(".book_box_page").height());
    height_adjusting();
})

//双击修改句子
$(function(){
    $(".td_text_p").dblclick(function(){
        $(this).css("display","none");
        $(this).parent().find(".td_text_input").css("display","inline-block").focus();
        $(this).parent().find(".td_text_input").val($(this).html());
    });
    $(".td_text_input").blur(function(){
        $(this).css("display","none");
        $(this).parent().find("p").css("display","inline-block");
        $(this).parent().find("p").html($(this).val());

    });
})

//登陆前验证
function check_value()
{
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    email = $.trim($("#email").val());
    $("#email").val(email);
    password = $("#password").val();
    if(email == "" || password == "")
        tishi('邮箱或密码不能为空！');
    else
    {
        if(!email_reg.test(email))
            tishi('邮箱格式不正确,请重新输入！');
        else
        {
            if(password.length >= 6 && password.length <= 20)
                $("#login_submit_button").click();
            else
                tishi("密码长度在6-20个字符长度之间，请重新输入");
        }
    }
}

//检查班级信息
function check_class_info()
{
    teaching_material_id = $.trim($("#teaching_material_id").val());
    class_name = $.trim($("#class_name").val());
    period_of_validity = $.trim($("#period_of_validity").val());

    if(teaching_material_id == 0 || class_name == "" || period_of_validity == "")
        tishi('信息填写不完整不能为空！');
    else
        $("#submit_class_info").click();
}

//删除题包
function delete_packages(publish_question_package_id,school_class_id)
{
    if(confirm("确认删除该任务？") == true)
    {
        $.ajax({
            url: "/school_classes/"+ school_class_id +"/homeworks/delete_question_package",
            type: "POST",
            dataType: "script",
            data:{
                publish_question_package_id:publish_question_package_id,
                school_class_id:school_class_id
            },
            success:function(data){
            },
            error:function(data){
            }
        })
    }
}
//显示发布任务栏
function show_publish_task_panel(question_package_id)
{
    $("#question_package_id_value").val(question_package_id);
    show_windows("publish_task_panel");
}

//发布任务时验证时间
function check_time(obj)
{
    end_time = $.trim($("#end_time").val());
    if(end_time != "")
    {
        $(obj).attr("disabled","disabled");
        $("#submit_publish_task").click();
    }
    else
        tishi("时间不能为空！");
}

//注册时验证
function check_regist_info()
{
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    name = $.trim($("#r_name").val());
    email = $.trim($("#r_email").val());
    $("#r_email").val(email);
    password = $("#r_password").val();
    confirm_password = $("#r_confirm_password").val();
    if(name == "" || email == "" || password == "" || confirm_password == "")
        tishi("姓名、邮箱、密码、确认密码不能为空！");
    else
    {
        if(!email_reg.test(email))
            tishi("邮箱格式不正确,请重新输入！");
        else
        {
            if(password == confirm_password)
            {
                if(password.length >= 6 && password.length <= 20)
                    $("#register_submit_button").click();
                else
                    tishi("密码、确认密码长度在6-20个字符长度之间，请重新输入");
            }
            else
                tishi("两次密码不一致！");
        }
    }
}

function show_single_record(ids) {
    id_arr = ids.split("_")
    user_id = id_arr[0]
    record_id = null
    if(id_arr != null && id_arr[1] != null) {
        record_id = id_arr[1]
    }
    $.ajax({
        url : "/results/show_single_record",
        type:'post',
        dataType : 'script',
        data: {
            user_id : user_id,
            record_id : record_id
        }
    });
    return false;
}

function tishi(message){
    $("#tab_Prompt").find("p").first().html(message);
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var z_layer_height = $("#tab_Prompt").height();
    $("#tab_Prompt").css('top',(win_height-z_layer_height)/2 + scolltop);
    var doc_width = $(document).width();
    var layer_width = $("#tab_Prompt").width();
    $("#tab_Prompt").css('left',(doc_width-layer_width)/2);
    $("#tab_Prompt").css('display','block');
    jQuery('#tab_Prompt').fadeTo("slow",1);
    $("#tab_Prompt .x").click(function(){
        $("#tab_Prompt").css('display','none');
    })
    setTimeout(function(){
        jQuery('#tab_Prompt').fadeTo("slow",0);
    }, 3000);
    setTimeout(function(){
        $("#tab_Prompt").css('display','none');
    }, 3000);
}

function msg(message){
    $("#tishi_div .tab_con .red").html(message);
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = $(window).height();
    var tishi_div_height = $("#tishi_div").height();
    $("#tishi_div").css('top',(win_height-tishi_div_height)/2);
    var doc_width = $(document).width();
    var tishi_div_width = $("#tishi_div").width();
    $("#tishi_div").css('left',(doc_width-tishi_div_width)/2);
    $("#tishi_div").css('display','block');
    jQuery('#tishi_div').fadeTo("slow",1);
    $("#tishi_div .close").click(function(){
        $("#tishi_div").css('display','none');
    })
    setTimeout(function(){
        jQuery('#tishi_div').fadeTo("slow",0);
    }, 3000);
    setTimeout(function(){
        $("#tishi_div").css('display','none');
    }, 3000);
}

//第一次创建班级提示验证码
function tishi_code(message){
    $("#tab_Prompt").find("p").first().html(message);
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var z_layer_height = $("#tab_Prompt").height();
    $("#tab_Prompt").css('top',(win_height-z_layer_height)/2 + scolltop);
    var doc_width = $(document).width();
    var layer_width = $("#tab_Prompt").width();
    $("#tab_Prompt").css('left',(doc_width-layer_width)/2);
    $("#tab_Prompt").css('display','block');
    jQuery('#tab_Prompt').fadeTo("slow",1);
    $("#tab_Prompt .x").click(function(){
        $("#tab_Prompt").css('display','none');
    })
}

//验证头像文件格式
function validate_pic(obj)
{
    png_reg = /\.png$|\.PNG/;
    jpg_reg = /\.jpg$|\.JPG/;
    var pic = $(obj).val();
    if(png_reg.test(pic) == false && jpg_reg.test(pic) == false)
    {
        tishi("头像格式不正确，请重新选择JPG或PNG格式的图片！");
        $(obj).val("");
    }
}

//刷新消息
function reload_messages(class_id,user_id)
{
    //    alert(class_id);
    $.ajax({
        async:true,
        dataType:'json',
        data:{
            school_class_id : class_id,
            user_id : user_id
        },
        url:"/api/students/get_teacher_messages",
        type:'get',
        success : function(data) {
            if(data.messages.length <= 0)
            {
                $(".nav03 .nms").hide();
            }
            else
            {
                $(".nav03 .nms").show();
            }
        }
    })
}

//查看分享的题目
function share_question_details(obj,q_pack_id,q_id,share_question_id)
{
    $.ajax({
        url:"/share_questions/view",
        type:"POST",
        dataType:"script",
        data:{
            share_question_id : share_question_id,
            question_package_id : q_pack_id,
            question_id : q_id
        },
        success : function(data) {
        }
    })
}

//关闭预览分享题目的窗口
function close_view_share_question()
{
    $("#view_share_question").remove();
    $(".article").show();
}
function height_tab(){
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var z_layer_height = $(".tab").height();
    $(".tab").css('top',(win_height-z_layer_height)/2 + scolltop/2);
    var doc_width = $(document).width();
    var layer_width = $(".tab").width();
    $(".tab").css('left',(doc_width-layer_width)/2);
}

//删除所有未读信息
function del_all_unread_msg(user_id, school_class_id){
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/messages/del_all_unread_msg",
        dataType: "json",
        data: {
            user_id : user_id
        },
        success: function(data){
            window.location.reload();
        },
        erroe: function(data){
            tishi("请求失败!")
        }
    })
}