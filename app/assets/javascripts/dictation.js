/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function addTM(obj){
    //隐藏第二步
    $(obj).parents("#second_step").css("display","none");
    $(".mask").css("display","none");
    //显示第三步
    popup("#add_teaching_material");
}

function saveTM(obj){
    var course_id = $("#third_step").find("#class_course_id").val();
    var teaching_material_name = $("#add_teaching_material").find(".tm_name").val();
    $.ajax({
        url:"/dictations/create_teaching_material",
        type:"post",
        dataType : "html",
        data:{
            course_id : course_id,
            teaching_material_name: teaching_material_name
        },
        success: function(data){
            if(data!= -1){
                //隐藏这一步
                $(obj).parents("#add_teaching_material").css("display","none");
                $(".mask").css("display","none");
                //显示选择教材那一步
                $("#second_step").html(data);
                popup("#second_step");
            }else{
                tishi("出错了");
            }
        }
    })
}