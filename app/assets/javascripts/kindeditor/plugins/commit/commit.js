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
        var div = $(".assignment_body_list").children("div");
        var questions_id = $(div[gloab_index]).find(".questions_id").val();
        var school_class_id = $("#school_class_id").val();
        var text = editor.html();
        $.ajax({
            dataType:"text" ,
            url:"/school_classes/"+school_class_id+"/question_packages/"+questions_id+"/save_wanxin_content",
            data:"content="+text,
            success:function(data){
                if(data==1)
                    alert("保存成功！");
            }
        });
    });
});