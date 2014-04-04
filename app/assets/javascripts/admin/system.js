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