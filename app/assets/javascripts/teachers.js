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