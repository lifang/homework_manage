KindEditor.plugin('commit', function(K) {
    var editor = this, name = 'commit';
    editor.clickToolbar(name, function() {
        var div = $(".assignment_body").children(".assignment_body_list");
        var question_id = $("#"+editor.id).parents(".assignment_body_list").find(".question_id").val();
        var school_class_id = $("#school_class_id").val();
        //选项的个数，-1是因为每次多一个
     
        var length =  $("#"+editor.id).parents(".assignment_body_list").find(".gapFilling_questions").length-1;
        var temp = editor.text();
        if($.trim(temp)==""){
            tishi("完形填空内容不能为空！");
            stopPropagation(arguments[1]);
            return false;
        }
        var sign_length=-1;
        if(temp.indexOf("[[sign]]") >= 0){
            sign_length = temp.match(/\[\[sign\]\]/g).length;
        }else{
            sign_length = 0
        }
        //alert(length+"-->"+sign_length);
        if(length != sign_length){
            tishi("选项标记与选项个数不匹配！");
            return false;
        }
        var text = editor.html();
        text = text.replace(/[>&<'";#]/g, function(x) {
            return "(**)" + x.charCodeAt(0) + "(*:*)";
        });
        $.ajax({
            type:'post',
            dataType:"text" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/save_wanxin_content",
            data:"content="+text,
            success:function(data){
                if(data==1)
                    tishi("保存成功！");
                else
                    tishi("保存失败！");
            }
        });
    });
});