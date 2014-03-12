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
function show_tag_task(tag_id, pub_id)
{

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
                tishi("查询日期不能大于今日日期！");
            }
            else if(current_date < today_date)
            {
                current_date = new Date(current_date);
                var date = current_date.setDate(current_date.getDate()+1);
                today_date = new Date(today_date);
                if(date <= today_date)
                {
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
                    tishi("查询日期不能大于今日日期！");
                }
            }
        }
    }
    else if(option == "prev")
    {
        current_date = new Date(current_date);
        var date = new Date(current_date.setDate(current_date.getDate()-1))
        date = date.format("yyyy-MM-dd");
//        alert(date);
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