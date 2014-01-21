// JavaScript Document
//tab
function tabFunc(t){
    var win_width = $(window).width();
    var win_height = $(window).height();

    var layer_height = $(t).height();
    var layer_width = $(t).width();
    //alert($(".tab").width());
    if(!$(t).attr("class")=="tab list_classes"){
        $(t).css('top',(win_height-layer_height)/2);
    }else{
        if(win_height>=layer_height){
            $(t).css('top',(win_height-layer_height)/2);
        }else{
            $(t).css('top',0)
        }
    }
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
                opacity: 0
            }, 200 );
            $(".login_bg").animate({
                height: "60px"
            }, 200 , function(){
                $(".register_box").css("display","block");
            });
        }
    });
    $(".goLogin_a").on("click",function(){
        if( !$(this).is(":animated")){
            $(".register_box").css("display","none");
            $(".login_bg").animate({
                height: "437px"
            }, 200 , function(){
                $(".login_box").animate({
                    opacity: 1
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
        $(this).attr("value",$(this).val())
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

//登陆前验证
function check_value()
{
    email = $("#email").val();
    password = $("#password").val();
    if(email == "邮箱" || password == "密码")
        alert('邮箱或密码不能为空！');
    else
        $("#login_submit_button").click();
}

//检查班级信息
function check_class_info()
{
    teaching_material_id = $.trim($("#teaching_material_id").val());
    class_name = $.trim($("#class_name").val());
    period_of_validity = $.trim($("#period_of_validity").val());

    if(teaching_material_id == 0 || class_name == "" || period_of_validity == "")
        alert('信息填写不完整不能为空！');
    else
        $("#submit_class_info").click();
}

//删除题包
function delete_packages(publish_question_package_id,school_class_id)
{
    if(confirm("确认删除该任务？") == true)
    {
        $.ajax({
            url: "/school_classes/"+ school_class_id +"/homeworks/delete_question_package",
            type: "POST",
            dataType: "script",
            data:{
                publish_question_package_id:publish_question_package_id,
                school_class_id:school_class_id
            },
            success:function(data){
            },
            error:function(data){
            }
        })
    }
}
//显示发布任务栏
function show_publish_task_panel(question_package_id)
{
    $("#question_package_id_value").val(question_package_id);
    $("#publish_task_panel").show();
}

//发布任务时验证时间
function check_time()
{
    end_time = $.trim($("#end_time").val());
    if(end_time != "")
    {
        $("#submit_publish_task").click();
    }
    else
        alert("时间不能为空！");
}

//注册时验证时间
function check_regist_info()
{
    name = $.trim($("#r_name").val());
    email = $.trim($("#r_email").val());
    password = $.trim($("#r_password").val());
    confirm_password = $.trim($("#r_confirm_password").val());
    if(name != "姓名" && email != "邮箱" && password != "密码" && confirm_password != "确认密码")
    {
        if(password == confirm_password)
            $("#register_submit_button").click();
        else
            alert("两次密码不一致！");
    }
    else
        alert("姓名、邮箱、密码、确认密码不能为空！");

}

function show_list_class(){
    if($("#schoolclasses_count").attr("schoolclasses")<=1){
        var message = "暂无班级可切换";
        tishi(message);
    }else{
        $(".list_classes").show();
    }
}
function created_new_class(){
    $(".created_new_class").show();
}
function create_school_class(school_class_id){
    var teaching_material_id = $("select[name='teaching_material_id']").val();
    var class_name = $("input[name='class_name']").val();
    var period_of_validity = $("input[name='period_of_validity']").val();
    var message;
    if (period_of_validity==""){
        message = "请选择结束时间";
        tishi(message);
    }else{
        $.ajax({
            url : "/school_classes/" + school_class_id + "/teachers/create_class",
            type:'post',
            dataType : 'json',
            data : {
                teaching_material_id : teaching_material_id,
                class_name : class_name,
                period_of_validity : period_of_validity
            },
            success: function(data){
                if(data.status==true){
                    message = data.notice;
                    tishi(message);
                    $(".created_new_class").css("display","none");
                    $(".create_success").show();
                }else{
                    message = data.notice;
                    tishi(message);
                }
            },
            error:function(){
                alert()
            }
        });
    }
}

function show_single_record(ids) {
    id_arr = ids.split("_")
    user_id = id_arr[0]
    record_id = null
    if(id_arr != null && id_arr[1] != null) {
        record_id = id_arr[1]
    }
    $.ajax({
        url : "/results/show_single_record",
        type:'post',
        dataType : 'script',
        data: {
            user_id : user_id,
            record_id : record_id
        }
    });
    return false;
}

function tishi(message){
    $(".tab_con .red").html(message);
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var z_layer_height = $(".tab").height();
    $(".tab").css('top',(win_height-z_layer_height)/2 + scolltop);
    var doc_width = $(document).width();
    var layer_width = $(".tab").width();
    $(".tab").css('left',(doc_width-layer_width)/2);
    $(".tab").css('display','block');
    jQuery('.tab').fadeTo("slow",1);
    $(".tab .close").click(function(){
        $(".tab").css('display','none');
    })
    setTimeout(function(){
        jQuery('.tab').fadeTo("slow",0);
    }, 3000);
    setTimeout(function(){
        $(".tab").css('display','none');
    }, 3000);
}

