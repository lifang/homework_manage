KindEditor.plugin('commit', function(K) {
    var editor = this, name = 'commit';
    
    editor.clickToolbar(name, function() {
//       var editors =  KindEditor.instances;
//        var index = -1;
//        for(var i=0 ; i<editors.length; i++){
//            if(editors[i]==editor){
//                index = i;
//            }
//        }
        var div = $(".assignment_body").children(".assignment_body_list");
        var question_id = $(div[gloab_index]).find(".question_id").val();
        var school_class_id = $("#school_class_id").val();
        var length = $(div[gloab_index]).find(".gapFilling_questions").length;
        var temp = editor.text();
        var sign_length = temp.match(/\[\[sign\]\]/g).length;
        alert(length+"-->"+sign_length);
        if(length != sign_length){
           alert("选项标记与选项个数不匹配！");
           return false;
        }
        var text = editor.html();
        $.ajax({
            dataType:"text" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+question_id+"/save_wanxin_content",
            data:"content="+text,
            success:function(data){
                if(data==1)
                    alert("保存成功！");
                else
                    alert("保存失败！");
            }
        });
    });
});