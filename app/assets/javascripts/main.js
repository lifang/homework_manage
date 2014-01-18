// JavaScript Document
//tab
function tabFunc(t){
	var win_width = $(window).width();
	var win_height = $(window).height();
	
	var layer_height = $(t).height();
	var layer_width = $(t).width();
	//alert($(".tab").width());
	
	$(t).css('top',(win_height-layer_height)/2);
	$(t).css('left',(win_width-layer_width)/2);
	
	$(".close").click(function(){
		$(this).parents(t).css("display","none");	
	});
}
$(function(){
	tabFunc(".tab");
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
			$(".login_box").animate({ 
				opacity: 0,
			  }, 200 );
			$(".login_bg").animate({ 
				height: "60px",
			  }, 200 , function(){
				 $(".register_box").css("display","block");
				});
		}
	});
	$(".goLogin_a").on("click",function(){
		if( !$(this).is(":animated")){
			$(".register_box").css("display","none");
			$(".login_bg").animate({ 
				height: "437px",
			  }, 200 , function(){
				 $(".login_box").animate({ 
				opacity: 1,
			  }, 200 );
			});
		}
	})
})

//left菜单
$(function(){
	$(".firstNav").click(function(){
		$(this).find(".menu").toggle(300);
	});
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
	//$(".book_box_con").css("width",$(".book_box").width()-$(".book_box_page").width());	
	$(".book_box_page ul").css("height",$(".book_box_con").height()+40);
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
