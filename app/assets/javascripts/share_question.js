//引用的时候，判断是否选择 单元id，课程id
$(function(){
    // 题型引用，列出分享的题目
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
// 点击引用，引用某一大题
    $(".ques_pack_reference").on("click", function(){
        var url = $(this).attr("data-href");
        $("#fugai").show();
        $("#fugai1").find("h2").text("正在引用题包，可能需要几分钟的时间，请您耐心等待");
        $("#fugai1").show();
        $.ajax({
            url : url,
            type:'post',
            dataType : 'text',
            success: function(data){
                if(data == -1){
                    tishi("引用失败！");
                }else{
                    tishi("引用成功！")
                    window.location.replace(window.location.href)
                }
                $("#fugai").hide();
                $("#fugai1").find("h2").text("");
                $("#fugai1").hide();
            }
        })
    });

})