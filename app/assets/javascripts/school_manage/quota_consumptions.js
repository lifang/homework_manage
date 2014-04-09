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