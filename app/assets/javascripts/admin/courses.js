function select_course(obj){
    var course_id = $(obj).find("option:selected").val();
    window.location.href="/admin/courses?course_id="+course_id;
}

