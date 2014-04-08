function select_course(obj){
    var course_id = $(obj).find("option:selected").val();
    window.location.href="/admin/courses?course_id="+course_id;
}

function del_course(course_id){
    $(".mask").show();
    $("#del_course_tab").find("input[type='hidden']").first().val(course_id);
    popup("#del_course_tab");
}

function del_course_commit(obj){
    var course_id = $(obj).parents("div.tab").find("input[type='hidden']").first().val();
    if(course_id==undefined || course_id=="0"){
        tishi("数据错误!");
    }else{
        $(obj).removeAttr("onclick");
        $.ajax({
            type: "delete",
            url: "/admin/courses/"+course_id,
            dataType: "json",
            success: function(data){
                if(data.status==1){
                    tishi("删除成功!");
                    window.location.href="/admin/courses"
                }else{
                    tishi("删除失败!");
                }
            },
            error: function(){
                tishi("数据错误!");
            }
        })
    }
}

function del_teac_material(teac_material_id){
    $(".mask").show();
    $("#del_t_material_tab").find("input[type='hidden']").first().val(teac_material_id);
    popup("#del_t_material_tab");
}

function del_t_material_commit(obj){
    var t_material_id = $(obj).parents("div.tab").find("input[type='hidden']").first().val();
    if(t_material_id==undefined || t_material_id=="0"){
        tishi("数据错误!");
    }else{
        $(obj).removeAttr("onclick");
        $.ajax({
            type: "get",
            url: "/admin/courses/del_teaching_material",
            data: {
                teaching_material_id : t_material_id
            },
            dataType: "json",
            success: function(data){
                if(data.status==1){
                    tishi("删除成功!");
                    window.location.reload();
                }else{
                    tishi("删除失败!");
                }
            },
            error: function(){
                tishi("数据错误!");
            }
        })
    }
}

function new_course(obj){
    $(".mask").show();
    popup("#new_course_tab");
}

function new_course_commit(obj){
    var name = $.trim($("#new_course_name").val());
    if(name==""){
        tishi("科目名称不能为空!");
    }else{
        $(obj).removeAttr("onclick");
        $(obj).parents("form").submit();
    }
}