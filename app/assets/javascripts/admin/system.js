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