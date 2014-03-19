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
        $(".s_tab").css({'top':(e.pageY)+'px', 'left':(e.pageX)+'px'});
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
            $(".tab_mess").css('display','block');
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
                <div class="tab_mess_btn"><button class="">提交</button></div></form>'
        $(".create_main_microposts").html(html)
        $(".tab_mess").css('display','block');
        $(".tab_mess").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-180)+'px'
            });
        return false;
    });
    $(document).bind('click', function (e) {
        if ( $(e.target).closest(".tab_mess").length>0 ) {
            $(".tab_mess").css('display','block');
        }else{
            $(".tab_mess").css('display','none');
        }
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
        $(".tag_tab").css({'top':(e.pageY+30)+'px', 'left':(e.pageX-192)+'px'});
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

