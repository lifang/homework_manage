KindEditor.plugin('commit', function(K) {
    var editor = this, name = 'commit';
    var editors =  KindEditor.instances;
    var index = -1;
    for(var i=0 ; i<editors.length; i++){
        if(editors[i]==editor){
            index = i;
        }
    }
     alert(index);
    var div = $(".assignment_body_list").children("div");
    var questions_id = $(div[index]).find(".questions_id").val();
     alert(questions_id);
    editor.clickToolbar(name, function() {
            var text = editor.html();

           alert(questions_id);
    });
});