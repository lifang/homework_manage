//引用的时候，选择 单元id，课程id
$(function(){
    $(".questionTypes .new_reference").on("click", function(){
        var cell_id = $("#cell_id").val();
        var episode_id = $("#episode_id").val();
        var flag = true;
        var url = $(this).attr("data-href");
        if(cell_id == ""){
            tishi("您还未选择单元");
            flag = false;
            return flag;
        }
        if(episode_id == ""){
            tishi("您还未选择课程");
            flag = false;
            return flag;
        }
        if(flag){
            $.ajax({
                url:url,
                type: "GET",
                dataType: "html",
                data:{
                    cell_id : cell_id,
                    episode_id : episode_id
                },
                success:function(data){
                    if(data!="-1" && data!="-2"){
                        $(".reference_replace_part").html(data);
                    }else if(data=="-1"){
                        tishi("保存失败");
                    }else if(data=="-2"){
                        tishi("该单元下没有题目可以引用");
                    }
                },
                error:function(data){
                    tishi(data)
                }
            })
        }
    });

})