KindEditor.plugin('commit', function(K) {
    var editor = this, name = 'commit';
    editor.clickToolbar(name, function() {
        var div = $(".assignment_body").children(".assignment_body_list");
        var question_id = $(div[gloab_index]).find(".question_id").val();
        var school_class_id = $("#school_class_id").val();
        //选项的个数，-1是因为每次多一个
        var length = $(div[gloab_index]).find(".gapFilling_questions").length-1;
        var temp = editor.text();
        var sign_length = temp.match(/\[\[sign\]\]/g).length;
        //alert(length+"-->"+sign_length);
        if(length != sign_length){
           tishi("选项标记与选项个数不匹配！");
           return false;
        }
        var text = editor.html();
        $.ajax({
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