// JavaScript Document

$(function(){
	$(".assignment_btn_a").click(function(){
		submit_date();
	})
})


function submit_date()
{
	var year = parseInt($(".nian").find("span").text());
	var month = parseInt($(".yue").find("span").text());
	var day = 0;
	var day_tag = $(".dayBox").find("span.selected");
	if(day_tag.length > 0)
	{
		day = $(".dayBox").find("span.selected").first().text();
	}
	if(day != 0)
	{
		var school_class_id = $(".school_class_id").val();
		if(month < 10 )
		{
			month = "0" + month;
		}
		if(day < 10)
		{
			day = "0" + day;
		}
		var date = year + "-" + month + "-" + day;
        window.location.href = "/school_classes/"+ school_class_id +"/dictation_practises/new_task?date="+date;
	}
	else
	{
		alert("请先选择日期！");
	}
}

function click_list(obj)
{
	//$(obj).parents("ul").find("li").removeClass("hover");
	if(!$(obj).hasClass("hover"))
	{
		$(obj).addClass("hover");
	}
	else
	{
		$(obj).removeClass("hover");
	}
}

function move_item(obj)
{
	var obj_class_name = $(obj).attr("class");
	if(obj_class_name == "goto" || obj_class_name == "goback")
	{
		if(obj_class_name == "goto")
		{
			var remove_panel = "left";
			var add_panel = "right";
		}
		else if(obj_class_name == "goback")
		{
			var remove_panel = "right";
			var add_panel = "left";	
		} 	
		var select_item = $(".assignment_body").find("."+ remove_panel +" ul").find("li.hover");
		if(select_item.length > 0)
		{
			$(select_item).each(function(i){
				// var item_text = $(this).text();
				var item_text = $(this);
				$(this).remove();
				$(item_text).removeClass("hover");
				// var add_item = "<li>" + item_text + "</li>"; 
				$(".assignment_body").find("."+ add_panel +" ul").append(item_text);
			})
		}
		else
		{	
			tishi("请先选择项目!");
		}
	}
}

function preview_questions()
{
	var school_class_id = $(".school_class_id").val();
	var questions_id = $(".left ul li").find("input").val();
	alert(questions_id);
	 $.ajax({
            type: "post",
            url: "/school_classes/"+ school_class_id +"/dictation_practises/preview_questions",
            dataType: "script",
            data: {
                type : 1,
                name : name
            },
            success: function(data){
            },
            error: function(){
            }
        })
	// popup("#preview_question_panel");
}