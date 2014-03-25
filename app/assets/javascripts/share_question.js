//引用的时候，判断是否选择 单元id，课程id
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
                data:{
                    cell_id : cell_id,
                    episode_id : episode_id
                },
                success:function(data){
                    if(data.status!="-1" && data.status!="-2"){
                        $(".reference_replace_part").html(data);
                    }else if(data.status=="-1"){
                        tishi(data.msg);
                    }else if(data.status=="-2"){
                        tishi(data.msg);
                    }
                },
                error:function(data){
                    tishi(data)
                }
            })
        }
    });

})