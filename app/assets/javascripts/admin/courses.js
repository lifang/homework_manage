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

function new_course(){
    $(".mask").show();
    popup("#new_course_tab");
}

function new_course_commit(obj){
    var name = $.trim($("#new_course_name").val());
    if(name==""){
        tishi("科目名称不能为空!");
        $(obj).removeAttr("onclick");
    }else{
        $.ajax({
            type: "post",
            url: "/admin/courses/new_course_and_teach_material_valid",
            dataType: "json",
            data: {
                type : 1,
                name : name
            },
            success: function(data){
                if(data.status==0){
                    $(obj).attr("onclick", "new_course_commit(this)");
                    tishi("已有同名的科目!");
                }else{
                    $(obj).parents("form").submit();
                }
            },
            error: function(){
                tishi("数据错误!");
            }
        })
        
    }
}

function new_teach_material(obj, course_id){
    if(course_id==undefined || course_id==""){
        tishi("数据错误!");
    }else{
        $("#new_teach_material_tab").find("input[name='new_teach_material_course_id']").val(course_id);
        $(".mask").show();
        popup("#new_teach_material_tab");
    }
}

function new_teach_material_commit(obj){
    var course_id = $("#new_teach_material_tab").find("input[name='new_teach_material_course_id']").first().val();
    if(course_id==undefined || course_id=="" || course_id=="0"){
        tishi("数据错误!");
    }else{
        var t_name = $.trim($("#new_teach_material_name").val());
        var t_xls = $("#new_teach_material_xls").val();
        var xls_format ="xls";
        if(t_name==""){
            tishi("教材名称不能为空!");
        }else if(t_xls==""){
            tishi("请导入章节数据的表格文件!");
        }else{
            var xls_type = t_xls.substring(t_xls.lastIndexOf(".")).toLowerCase();   //.xls
            if(xls_type.substring(1, xls_type.length)!=xls_format){
                tishi("请上传正确的表格文件,文件格式必须为'xls'!");
            }else{
                $(obj).removeAttr("onclick");
                $.ajax({
                    type: "post",
                    url: "/admin/courses/new_course_and_teach_material_valid",
                    dataType: "json",
                    data: {
                        type : 2,
                        name : t_name,
                        course_id : course_id
                    },
                    success: function(data){
                        if(data.status==0){
                            $(obj).attr("onclick", "new_teach_material_commit(this)");
                            tishi("已有同名的教材!");
                        }else{
                            $(obj).parents("form").submit();
                        }
                    },
                    error: function(){
                        tishi("数据错误!");
                    }
                })

            }
        }
    }
}