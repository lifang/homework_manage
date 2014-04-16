//显示设置教材窗口
function show_material_pannel(teacher_id)
{
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

function search_admin(obj)
{
    var key_word = $(obj).parents(".search").find(".key_word").val();
    // tishi(key_word);
    window.location.href="/admin/question_admins?key_word="+key_word;
}

function show_add_question_admin_pannel()
{
    $.ajax({
        type: "get",
        dataType: "script",
        url: "/admin/question_admins/load_add_question_admin_panel",
        success: function(data){
               
        }
    });
}


function show_password_pannel(teacher_id)
{
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


function show_disable_pannel(teacher_id, status)
{
    $.ajax({
        type: "get",
        dataType: "script",
        url: "/admin/question_admins/load_disable_teacher",
        data: {
            teacher_id : teacher_id,
            status : status
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
        tishi("课程为空！");
    }    
}

function check_teaching_materials(obj)
{
    $(obj).attr("disabled", "true");
    var course_select = $(obj).parents("form").find(".course_select").val();
    var material_select = $(obj).parents("form").find(".material_select").val();
    // alert(course_select);
    // alert(material_select);
    if(course_select == 0)
    {
        tishi("请选择科目!");
        $(obj).removeAttr("disabled");
    }
    else
    {
        if(material_select == 0)
        {
            tishi("请选择教材!");
            $(obj).removeAttr("disabled");
        }
        else
        {
            $(obj).parents("form").submit();
        } 
    } 
}

function check_password(obj)
{
    $(obj).attr("disabled", "true");
    var password = $(obj).parents("form").find(".password").val(); 
    var confirm_password = $(obj).parents("form").find(".confirm_password").val(); 
    if(password == "")
    {
        tishi("密码不能为空!");
        $(obj).removeAttr("disabled");
    }
    else
    {
        if(confirm_password == "")
        {
            tishi("确认密码不能为空!");
            $(obj).removeAttr("disabled");
        }
        else
        {
            if(password != confirm_password)
            {
                tishi("两次密码不一致!");   
                $(obj).removeAttr("disabled");
            }
            else
            {
                if(password.length >= 6)
                {
                    $(obj).parents("form").submit();    
                }    
                else
                {
                    tishi("密码长度至少六位!");
                    $(obj).removeAttr("disabled");   
                } 
            }    
        }
    }
}

function check_admin_info(obj)
{
    $(obj).attr("disabled", "true");
    var name = $(obj).parents("form").find(".name").val();
    var course_select = $(obj).parents("form").find(".course_select").val(); 
    var material_select = $(obj).parents("form").find(".material_select").val(); 
    var email = $(obj).parents("form").find(".email").val(); 
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.\-]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}(\.[a-zA-Z]{2,2}){0,1}$/;
    if(name == "" || course_select == "" || material_select == "" || email == "")
    {
        tishi("管理员名称、科目、教材、邮箱不能为空！");
        $(obj).removeAttr("disabled");
    }
    else
    {
        if(!email_reg.test(email))
        {
            tishi("邮箱格式不正确！");
            $(obj).removeAttr("disabled");
        }
        else
        {
            // popup("#waiting_warning");
            $(obj).parents("form").submit();
        }
    }    

}