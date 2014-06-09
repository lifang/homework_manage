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