// JavaScript Document

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
	})

	$(".close").click(function(){
		$(this).parents(t).css("display","none");
		$(".mask").css("display","none");	
	});
}
$(function(){
	tabFunc(".td_seeQuestion",".tab");
	//tabFunc(".tab_article");
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
  $(".sb_table table > tbody > tr:even").addClass("tbg");

});

