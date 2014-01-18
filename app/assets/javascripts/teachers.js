function save_updated_teacher(){
    var tercher_name = $("p[name='name']").html();
    var tercher_email = $("p[name='email']").html();
    $.ajax({
        url : "/teachers/save_updated_teacher",
        type:'get',
        dataType : 'json',
        data : {
            name : tercher_name,
            email : tercher_email
        },
        success: function(data){
            if(data.status==1){
                alert("保存成功");
            }else{
                alert("保存失败");
            }

        },
        error:function(){
            alert()
        }
    });
}
function show_list_class(){
    $(".list_classes").show();
}
function created_new_class(){
    $(".created_new_class").show();
}
function create_school_class(){
    var teaching_material_id = $("select[name='teaching_material_id']").val();
    var class_name = $("input[name='class_name']").val();
    var period_of_validity = $("input[name='period_of_validity']").val()
    $.ajax({
        url : "/teachers/create_class",
        type:'post',
        dataType : 'json',
        data : {
            teaching_material_id : teaching_material_id,
            class_name : class_name,
            period_of_validity : period_of_validity
        },
        success: function(data){
            if(data.status=='success'){
                alert(data.notice);
                $(".created_new_class").hide();
            }else{
                alert(data.notice);
            }
        },
        error:function(){
            alert()
        }
    });

}