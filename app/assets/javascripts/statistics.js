// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

Date.prototype.format = function(format){
    var o = {
        "M+" : this.getMonth()+1, //month
        "d+" : this.getDate(), //day
        "h+" : this.getHours(), //hour
        "m+" : this.getMinutes(), //minute
        "s+" : this.getSeconds(), //second
        "q+" : Math.floor((this.getMonth()+3)/3), //quarter
        "S" : this.getMilliseconds() //millisecond
    }

    if(/(y+)/.test(format)) {
        format = format.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length));
    }

    for(var k in o) {
        if(new RegExp("("+ k +")").test(format)) {
            format = format.replace(RegExp.$1, RegExp.$1.length==1 ? o[k] : ("00"+ o[k]).substr((""+ o[k]).length));
        }
    }
    return format;
}

//点击某个标签时
function show_tag(obj,school_class_id, date, tag_id, pub_id)
{
    $.ajax({
        url: "/school_classes/"+ school_class_id +"/statistics/show_tag_task",
        type: "POST",
        dataType: "script",
        data:{
            date:date,
            school_class_id:school_class_id,
            tag_id:tag_id,
            pub_id:pub_id
        },
        success:function(data){
            $(".sh_choose a").removeAttr("class");
            $(obj).attr("class", "hover");
        },
        error:function(data){
        }
    })
}

//左右切换日期
function checkout_date(obj, school_class_id)
{
    var option = $(obj).text();
    var today_date = $("#today_date").val();
    var current_date = $("#current_date").val();
//    alert(option);
    if(option == "next")
    {
        if(current_date.length != 0)
        {
            if(current_date == today_date)
            {
                msg("查询日期不能大于今日日期！");
            }
            else if(current_date < today_date)
            {
                current_date = new Date(current_date);
                var date = current_date.setDate(current_date.getDate()+1);
                today_date = new Date(today_date);
                if(date <= today_date)
                {
                    $(".datetimepicker").remove();
                    date = new Date(date);
                    date = date.format("yyyy-MM-dd");
                    $.ajax({
                        url: "/school_classes/"+ school_class_id +"/statistics/checkout_by_date",
                        type: "POST",
                        dataType: "script",
                        data:{
                            date:date,
                            school_class_id:school_class_id
                        },
                        success:function(data){
                        },
                        error:function(data){
                        }
                    })
                }
                else
                {
                    msg("查询日期不能大于今日日期！");
                }
            }
        }
    }
    else if(option == "prev")
    {
        $(".datetimepicker").remove();
        current_date = new Date(current_date);
        var date = new Date(current_date.setDate(current_date.getDate()-1));
        date = date.format("yyyy-MM-dd");
        $.ajax({
            url: "/school_classes/"+ school_class_id +"/statistics/checkout_by_date",
            type: "POST",
            dataType: "script",
            data:{
                date:date,
                school_class_id:school_class_id
            },
            success:function(data){
            },
            error:function(data){
            }
        })
    }
}

//按日期查询统计信息
function show_date_status(obj, school_class_id)
{
    var date = $(obj).val();
    var today_date = $("#today_date").val();
    if(date > today_date)
    {
        msg("查询日期不能大于今日日期！");
    }
    else
    {
//        $(".datetimepicker").remove();
        $.ajax({
            url: "/school_classes/"+ school_class_id +"/statistics/checkout_by_date",
            type: "POST",
            dataType: "script",
            data:{
                date:date,
                school_class_id:school_class_id
            },
            success:function(data){
            },
            error:function(data){

            }
        })
    }
}

//显示题型统计信息
function shou_question_status(obj,pub_id, school_class_id)
{
    $.ajax({
        url: "/school_classes/"+ school_class_id +"/statistics/show_question_statistics",
        type: "POST",
        dataType: "script",
        data:{
            pub_id:pub_id,
            school_class_id:school_class_id
        },
        success:function(data){
            $(".sc_nav a").removeAttr("class");
            $(obj).attr("class", "hover");
        },
        error:function(data){
        }
    })
}

//显示错题的原题
function shou_incorrect_que(question_types, stu_ans_record_id, school_class_id)
{
    $.ajax({
        url: "/school_classes/"+ school_class_id +"/statistics/show_incorrect_questions",
        type: "POST",
        dataType: "script",
        data:{
            question_types:question_types,
            student_answer_record_id:stu_ans_record_id
        },
        success:function(data){
        },
        error:function(data){
        }
    })
}

//显示原题
function show_que(que_id, school_class_id)
{
    $.ajax({
        url: "/school_classes/"+ school_class_id +"/statistics/show_questions",
        type: "POST",
        dataType: "script",
        data:{
            question_id:que_id
        },
        success:function(data){
        },
        error:function(data){
        }
    })
}

//显示该题所有标签
function show_tags(que_id, school_class_id)
{
    $.ajax({
        url: "/school_classes/"+ school_class_id +"/statistics/show_all_tags",
        type: "POST",
        dataType: "script",
        data:{
            question_id:que_id
        },
        success:function(data){
        },
        error:function(data){
        }
    })
}