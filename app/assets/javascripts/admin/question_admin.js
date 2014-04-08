//显示设置教材窗口
function show_material_pannel(teacher_id)
{
	teacher_id
	$.ajax({
        type: "get",
        dataType: "script",
        url: "/admin/question_admins/change_teaching_materials",
        data: {
            teacher_id : teacher_id
        },
        success: function(data){
               
        }
    });
}


function show_password_pannel(teacher_id)
{
    teacher_id
    $.ajax({
        type: "get",
        dataType: "script",
        url: "/admin/question_admins/load_password_panel",
        data: {
            teacher_id : teacher_id
        },
        success: function(data){
               
        }
    });
}


function show_disable_pannel(teacher_id)
{
    teacher_id
    $.ajax({
        type: "get",
        dataType: "script",
        url: "/admin/question_admins/load_disable_teacher",
        data: {
            teacher_id : teacher_id
        },
        success: function(data){
               
        }
    });
}

//加载教材
function load_material(obj,div_id)
{
    var course_id = $(obj).val();
    if(course_id != 0)
    {
        $.ajax({
            type: "get",
            dataType: "script",
            url: "/admin/question_admins/load_materials",
            data: {
                course_id : course_id,
                div_id : div_id
            },
            success: function(data){
                   
            }
        });   
    }    
    else
    {
        alert("课程为空！");
    }    
}

function check_teaching_materials(obj)
{
    $(obj).attr("disablesd", "true");
    var course_select = $(obj).parents("form").find(".course_select").val();
    var material_select = $(obj).parents("form").find(".material_select").val();
    // alert(course_select);
    // alert(material_select);
    if(course_select == 0)
    {
        alert("请选择课程!");
        $(obj).removeAttr("disablesd");
    }
    else
    {
        if(material_select == 0)
        {
            alert("请选择教材!");
            $(obj).removeAttr("disablesd");
        }
        else
        {
            $(obj).parents("form").submit();
        } 
    } 
}

function check_password(obj)
{
    $(obj).attr("disablesd", "true");
    var password = $(obj).parents("form").find(".password").val(); 
    var confirm_password = $(obj).parents("form").find(".confirm_password").val(); 
    if(password == "")
    {
        tishi("密码不能为空!");
        $(obj).removeAttr("disablesd");
    }
    else
    {
        if(confirm_password == "")
        {
            tishi("确认密码不能为空!");
            $(obj).removeAttr("disablesd");
        }
        else
        {
            if(password != confirm_password)
            {
                tishi("两次密码不一致!");   
            }
            else
            {
                $(obj).parents("form").submit();
            }    
        }
    }
}