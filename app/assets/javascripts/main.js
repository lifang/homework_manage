// JavaScript Document
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
