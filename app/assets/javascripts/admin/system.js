// JavaScript Document

//table偶数行变色
$(function(){
    $(".b_table > table > tbody > tr:even").addClass("tbg");
});

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

//tishi
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
        stopPropagation(arguments[1]);
    })
    setTimeout(function(){
        jQuery('#tab_Prompt').fadeTo("slow",0);
    }, 3000);
    setTimeout(function(){
        $("#tab_Prompt").css('display','none');
    }, 3000);

}

//阻止冒泡
function stopPropagation(e) {
    e = e || window.event;
    if(e.stopPropagation) { //W3C阻止冒泡方法
        e.stopPropagation();
    } else {
        e.cancelBubble = true; //IE阻止冒泡方法
    }
}

//popup
function popup(t){
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop; //滚动条高度
    var win_width = $(window).width();
    var doc_height = $(document).height();
    var layer_width = $(t).width();

    var left = (win_width-layer_width)/2;
    var top = scolltop+100;
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
// 点击关闭按钮关闭弹出层
$(function(){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();

    var layer_height = $(".system").height();
    var layer_width = $(".system").width();

    var left = (win_width-layer_width)/2;
    var top = (win_height-layer_height)/2;
    $(".mask").css("height",doc_height);
    $(".system").css('top',top);
    $(".system").css('left',left);
    $(document).on("click",".system a.close",function(){
        $(this).parents(".system").hide();
        $(".mask").hide();
    })
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


// 个人信息 鼠标点击别处隐藏tab
$(function(){
    $(".userName").click(function(e){
        $(".tab_user").css('display','block');
        $(".tab_user").css({
            'top':(e.pageY+30)+'px',
            'left':(e.pageX-350)+'px'
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

// 检查密码
 function headnav_check_password(obj){
     var form = $(obj).parents("form");
     var new_pwd = form.find(".new_pwd").val();
     var confirm_pwd = form.find(".confirm_pwd").val();
     if(new_pwd.length<6 || new_pwd.length>20 || confirm_pwd.length < 6 || confirm_pwd.length > 20){
        tishi("密码长度在6到20位之间");
        return false;
    }else if(new_pwd != confirm_pwd){
        tishi("两次输入的密码不一致");
        return false;
    }else{
        form.submit();
    }
 }
