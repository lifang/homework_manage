// JavaScript Document

$(function(){
	$(".assignment_task").click(function(){
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

			var questions_id = "";
			$(select_item).each(function(i){
				questions_id += $(this).find("input").val();
				questions_id += "|"
			})	
			var school_class_id = $(".school_class_id").val();
			var question_package_id = $(".question_package_id").val();
			// alert(questions_id);
			var act = "";
			if(obj_class_name == "goto")
				act = "add"
			else
				act = "delete"

			$.ajax({
			        type: "post",
			        url: "/school_classes/"+ school_class_id +"/dictation_practises/manage_questions",
			        dataType: "script",
			        data: {
			        	question_package_id : question_package_id,
			            questions_id : questions_id,
			            act : act
			        },
			        success: function(data){
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
	$(questions_id_objs).each(function(){
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
	var question_id = $(".ylxg_box_tit").find("h2.hover").attr("id");
	$.ajax({
	        type: "GET",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/new_branch",
	        dataType: "script",
	        data: {
	        	question_id : question_id
	        },
	        success: function(data){
	        },
	        error: function(){
	        }
	})
}

function show_branchs(obj, que_id)
{
	$(obj).parents(".ylxg_box_tit").find("h2").removeClass("hover");
	$(obj).addClass("hover");
	var school_class_id = $(".school_class_id").val();
	$.ajax({
	        type: "GET",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/show_branch_questions",
	        dataType: "script",
	        data: {
	        	question_id : que_id
	        },
	        success: function(data){
	        },
	        error: function(){
	        }
	})	
}

function check_material()
{
	var material_name = $("#material_form").find(".material_name").val();
	if(material_name.length > 0)
	{
		$("#material_form").submit();
	}
	else
	{
		tishi("教材名称不能为空！");
	}
}

function add_material()
{
	var school_class_id = $("#school_class_id").val();
	$.ajax({
	        type: "GET",
	        url: "/school_classes/"+ school_class_id +"/dictation_practises/new_material",
	        dataType: "script",
	        success: function(data){
	        },
	        error: function(){
	        }
	})	
}