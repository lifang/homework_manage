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
		tishi("请先选择日期！");
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

			var questions_id = [];
			$(select_item).each(function(i){
				questions_id.push($(this).find("input").val())
			})	
			var school_class_id = $(".school_class_id").val();
			var question_package_id = $(".question_package_id").val();
			alert(questions_id);
			var act = "";
			if(obj_class_name == "goto")
				act = "add"
			else
				act = "delete"

			$.ajax({
			        type: "post",
			        url: "/school_classes/"+ school_class_id +"/dictation_practises/manage_questions",
			        dataType: "json",
			        data: {
			        	question_package_id : question_package_id,
			            questions_id : questions_id,
			            act : act
			        },
			        success: function(data){
			        	if(data.status == 0){
							$(select_item).each(function(i){
								// var item_text = $(this).text();
					
					
					        	var item_text = $(this);
								$(this).remove();
								$(item_text).removeClass("hover");
								// var add_item = "<li>" + item_text + "</li>"; 
								$(".assignment_body").find("."+ add_panel +" ul").append(item_text);
							})	
						}
			        },
			        error: function(){
			        }
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
	var questions_id = ""
	var questions_id_objs = $(".right ul").find("li");
	$(questions_id_objs).each(function(i){
		if($(this).find("input").length > 0){
			// alert($(this).find("input").val());
			if(questions_id != "")
			{
				questions_id += "|"	
			}	
			questions_id += $(this).find("input").val();
		}
	})

	$.ajax({
	        type: "post",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/preview_questions",
	        dataType: "script",
	        data: {
	            questions_id : questions_id
	        },
	        success: function(data){
	        },
	        error: function(){
	        }
	})
	
}

//完成编辑题包
function finish_edit_question(obj)
{
	$(".edit").remove();
	$(".question_package").show();
}


function delete_branch(obj)
{
	var school_class_id = $(".school_class_id").val();
	var branch_id = $(obj).attr("id");
	$.ajax({
	        type: "post",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/delete_branch",
	        dataType: "script",
	        data: {
	            branch_id : branch_id
	        },
	        success: function(data){
	        },
	        error: function(){
	        }
	})
}

function add_branch()
{	
	var school_class_id = $(".school_class_id").val();
	$.ajax({
	        type: "GET",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/new_branch",
	        dataType: "script",
	        data: {
	        },
	        success: function(data){
	        },
	        error: function(){
	        }
	})
}