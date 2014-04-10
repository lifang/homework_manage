//
function show_quota_consumptions_panel(teacher_id)
{
	$.ajax({
        type: "get",
        dataType: "script",
        url: "/school_manage/quota_consumptions/load_quota_consumptions_panel",
        data: {
            teacher_id : teacher_id
        },
        success: function(data){
               
        }
    });
}

//减少
function reduce_a(obj){
    var number = $(obj).parents("li").find("input.number").val();
    var number_reg = /^[1-9][0-9]*$/
    if(!number_reg.test(number))
    {
        if(number == "")
        {
            tishi("配额不能为空!");
        }
        else
        {
            tishi("配额必须为正整数!");    
        }  
    }
    else
    {
        if(number > 1)
        {
            number = parseInt(number)-1;
            $(obj).parents("li").find("input.number").val(number);        
        }
        else
        {
            tishi("配额不能小于1!");  
        }
        
    }   
    
}
//增加
function add_a(obj){
    var number = $(obj).parents("li").find("input.number").val();
    var number_reg = /^[1-9][0-9]*$/
    if(!number_reg.test(number))
    {
        if(number == "")
        {
            tishi("配额不能为空!");
        }
        else
        {
            tishi("配额必须为正整数!");    
        }  
    }
    else
    {
            number = parseInt(number)+1;
            $(obj).parents("li").find("input.number").val(number);
    }
}


function check_apply_quota_consumptions(obj)
{
    $(obj).attr("disabled", "true");
    var number = $(obj).parents("form").find("input.number").val();
    var number_reg = /^[0-9][0-9]*$/
    var teacher_id = $(obj).parents("form").find("input.teacher_id").val();
    if(!number_reg.test(number))
    {
        if(number == "")
        {
            tishi("配额不能为空!");
            $(obj).removeAttr("disabled");
        }
        else
        {
            tishi("配额必须为正整数!");  
            $(obj).removeAttr("disabled");  
        }  
    }
    else
    {
        if(teacher_id != "")
        {
            $(obj).parents("form").submit();   
        }
        else
        {   
            tishi("数据错误，请刷新页面后再操作!");    
            $(obj).removeAttr("disabled");
        }    
    }
}