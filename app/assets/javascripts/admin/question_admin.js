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