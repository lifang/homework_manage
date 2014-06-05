// JavaScript Document


	
//格式化日期：yyyy-MM-dd
function formatDate(date) {
	var myyear = date.getFullYear();
	var mymonth = date.getMonth()+1;
	var myweekday = date.getDate();
	if(mymonth < 10){
	mymonth = "0" + mymonth;
	}
	if(myweekday < 10){
	myweekday = "0" + myweekday;
	}
	return (myyear+"-"+mymonth + "-" + myweekday);
} 	 

//获得某月的天数
function getMonthDays(year, myMonth, month_first_date){
	var monthStartDate = new Date(year, myMonth, 1);
	var monthEndDate = new Date(year, myMonth + 1, 1);
	var days = (monthEndDate - month_first_date)/(1000 * 60 * 60 * 24);
	return days;
} 

//生成选择日历
function make_date_control(date)
{	
	var crt_date = new Date(); //date
	var crt_year = crt_date.getYear();	//距1900年相差多少年
	crt_year += (crt_year < 2000) ? 1900 : 0; //当前年
	var crt_month = crt_date.getMonth();  //当前月
	var crt_day = crt_date.getDate();  //当前日
	var	y_m_d = date.split(/\-/);
	var year = parseInt(y_m_d[0]);
	if(parseInt(y_m_d[1]) == 1)
		var month = 0;
	else
		var month = parseInt(y_m_d[1])-1;
	var day = parseInt(y_m_d[2]);
	var month_first_date =  new Date(year, month, 1);
	var fisrtDayOfWeek = month_first_date.getDay(); //当月第一天是那周的第几天
	var days = getMonthDays(year, month, month_first_date);
	var dt = new Date(year, month, day);
	var current_date = new Date(crt_year, crt_month,  crt_day);
	$(".dayBox").find("span").remove();
	//添加第一行空格
	var space = "<span>&nbsp;</span>";
	for(var i=fisrtDayOfWeek; i > 0; i--)
	{
		$(".dayBox").append(space);
	}
	
	//添加其余日期
	var date_span = "";
	var count = 0;
	for(var j = 1; j <= days; j++)
	{
		if(year == crt_year && month == crt_month)
		{
			day = crt_day;
			if(j < day)
			{
				date_span = "<span class='expired'>" + j + "</span>";
			}
			else if(j == day)
			{
				date_span = "<span onmouseover='hover_date(this)' onclick='click_date(this)' class='selected' >" + j + "</span>";
			}
			else
			{
				date_span = "<span onmouseover='hover_date(this)' onclick='click_date(this)' >" + j + "</span>";
			}	
		}
		else if(year == crt_year && month > crt_month)
		{
			date_span = "<span onmouseover='hover_date(this)' onclick='click_date(this)' >" + j + "</span>";
		}
		else if(year == crt_year && month < crt_month)
		{
			date_span = "<span class='expired'>" + j + "</span>";
		}
		else if(year > crt_year)
		{
			date_span = "<span onmouseover='hover_date(this)' onclick='click_date(this)' >" + j + "</span>";
		}
		else
		{
			date_span = "<span class='expired'>" + j + "</span>";
		}
		$(".dayBox").append(date_span);
	}	
}

//添加年的下拉选项
function add_year_options(year)
{
	var opption = "";
	for(var i = 0; i <= 100; i++)
	{
		if(i > 0)
		{
			var yr = year + i;
		}
		else
		{
			var yr = year;
		}
		opption = "<option value='"+ yr +"'>"+ yr +"</option>";
		$(".nian").find("select").append(opption);
		
	}
}

//添加月的下拉选项
function add_month_options()
{
	var opption = "";
	for(var i = 1; i <= 12; i++)
	{
		opption = "<option value='"+ i +"'>"+ i +"</option>";
		$(".yue").find("select").append(opption);
	}
}

function hover_date(obj)
{
	$(".dayBox").find("span").removeClass("hover");
	if(!$(obj).hasClass("expired"))
	{
		if(!$(obj).hasClass("selected"))
		{
			$(obj).addClass("hover");	
		}
	}
}


function click_date(obj)
{
	$(".dayBox").find("span").removeClass("hover");
	$(".dayBox").find("span[class='selected']").removeClass("selected");
	if(!$(obj).hasClass("expired"))
	{
		if(!$(obj).hasClass("selected"))
		{
			$(obj).addClass("selected");			
		}
	}
}

//function

$(function(){
	var crt_date = new Date();
	var y = crt_date.getYear();
	y += (y < 2000) ? 1900 : 0; //当前年
	var m = crt_date.getMonth() + 1;
	var d = crt_date.getDate();
	var	date = "" + y + "-" + m + "-" + d;
	$(".nian").find("span").text(y);
	$(".yue").find("span").text(m);
	add_year_options(y);  //添加年的下拉选项
	add_month_options(); //添加月的下拉选项
	make_date_control(date); //生成日历表
	
	$("a.prev_mon").click(function(){
		var year = $(".nian").find("span").text();
		year = parseInt(year);
		var month = $(".yue").find("span").text();
		month = parseInt(month);
		year_month = reduce_one_month(year, month);
		year = year_month[0];
		month = year_month[1];
		set_year_and_month(year, month); //
		var	date = "" + year + "-" + month + "-";
		make_date_control(date);
	})
	
	$("a.next_mon").click(function(){
		var year = $(".nian").find("span").text();
		year = parseInt(year);
		var month = $(".yue").find("span").text();
		month = parseInt(month);
		year_month = add_one_month(year, month);
		year = year_month[0];
		month = year_month[1];
		set_year_and_month(year, month); //
		var	date = "" + year + "-" + month + "-";
		make_date_control(date);
	})
})

function select_date(obj)
{
	var class_name = $(obj).parents("div").attr("class");
	var value = $(obj).val();
	$("."+ class_name +"").find("span").text(value);
	var year = $(".nian").find("span").text();
	var month = $(".yue").find("span").text();
	var date = ""+ year + "-" + month + "-" ;
	make_date_control(date);
}
 
function remove_hover(obj)
{
	$(obj).find("span").removeClass("hover");
}

//减一个月
function reduce_one_month(year, month)
{
	if(month > 1) 	
	{
		month = month - 1;
	}
	else
	{
		month = 12;
		year = year - 1;
	}
	return [year,month];
}

//加一个月
function add_one_month(year, month)
{
	if(month < 12) 	
	{
		month = month + 1;
	}
	else
	{
		month = 1;
		year = year + 1;
	}
	return [year,month];	
}

//更新年月
function set_year_and_month(year, month)
{
	$(".nian").find("span").text(year);
	$(".yue").find("span").text(month);
}