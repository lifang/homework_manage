function show_list_class(){
    if($("#schoolclasses_count").attr("schoolclasses")<=1){
        var message = "暂无班级可切换";
        tishi(message);
    }else{
        height_tab();
        $(".list_classes").show();
    }
}
function created_new_class(){
    height_tab();
    $(".school_class_list").hide();
    $(".created_new_class").show();
}
function create_school_class(school_class_id){
    var teaching_material_id = $("select[name='teaching_material_id']").val();
    var class_name = $("input[name='class_name']").val();
    var period_of_validity = $("input[name='period_of_validity']").val();
    var message;
    if (class_name==""){
        message = "请输入班级名称"
        tishi(message);
        return false;
    }
    if (period_of_validity==""){
        message = "请选择结束时间";
        tishi(message);
    }else{
        $.ajax({
            url : "/school_classes/" + school_class_id + "/teachers/create_class",
            type:'post',
            dataType : 'script',
            data : {
                teaching_material_id : teaching_material_id,
                class_name : class_name,
                period_of_validity : period_of_validity
            }
        });
    }
}

function check_nonempty(){
    var email_reg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;
    if($.trim($("input[name='name']").val()).length == 0){
        tishi('提示:\n\n名称不能为空');
        return false;
    }else if(!email_reg.test($.trim($("input[name='email']").val()))){
        tishi("邮箱格式不正确,请重新输入！");
        return false;
    }
}
function cancle_main(){
    window.location.href="/welcome/logout";
}
function create_new_tag(){
    $(".tag_list").hide();
    $(".create_new_tag").show();
}
function update_password(school_class_id){
    var password_now = $("input[name='password_now']").val();
    var password_update = $("input[name='password_update']").val();
    var password_update_agin = $("input[name='password_update_agin']").val();
    if(password_update.length<6 || password_update_agin.length<6 ||
        password_update.length>20 || password_update_agin.length>20){
        tishi("请输入密码长度在6到20位之间");
        return false;
    }
    $.ajax({
        url : "/school_classes/" + school_class_id + "/teachers/update_password",
        type:'post',
        dataType : 'json',
        data : {
            password_now : password_now,
            password_update : password_update,
            password_update_agin : password_update_agin
        },
        success: function(data){
            if(data.status==true){
                message = data.notice;
                tishi(message);
                $(".update_password").css("display","none");
                setTimeout('',2000)
                location.reload();
            }else{
                message = data.notice;
                tishi(message);
            }
        }
    })
}
//function save_updated_avatars(){
//    $("#submit_file").click();
//}
function upload_avatar(obj,school_class_id){
    png_reg = /\.png$|\.PNG/;
    jpg_reg = /\.jpg$|\.JPG/;
    var pic = $(obj).val();
    var input_s = $('#file_uploads');
    //    var ie = +[1,];
    var isIE = document.all && window.external
    if(isIE){
    }
    else{
        var file_size = input_s[0].files[0].size;
        if(file_size>1048576){
            tishi("图片不可大于1M");
            return false;
        }
    }


    if(png_reg.test(pic) == false && jpg_reg.test(pic) == false)
    {
        tishi("头像格式不正确，请重新选择JPG或PNG格式的图片！");
        $(obj).val("");
    }
    else{
        $("#fugai").show();
        $("#fugai1").show();
        $(obj).parents("form").submit();
    }
}
function cancel_upload(){
    $("#changes_avatar").hide(100);
    
}


function shwo_tags(){   //点击班级分组跳出弹出层
    //    height_tab()
    $(".mask").show()
    $(".tag_list").show();
}

function create_class_valid(obj){   //创建班级分组验证
    var tag_name = $(obj).parents("form").find("input[name='name_tag']").first().val();
    if(tag_name==undefined || tag_name==""){
        tishi("组名不能为空!");
    }else{
        $(obj).removeAttr("onclick");
        $(obj).parents("form").submit();
    }
}
function show_switch_class(){   //切换班级
    //    height_tab()
    $(".mask").show();
    $(".tab").hide();
    $("#school_class_list").show();
}
function close_student_ungrouped_mess(school_class_id, obj){    //关闭页面上学员未分组的提示
    $.ajax({
        type: "get",
        url: "/school_classes/"+school_class_id+"/students/close_student_ungrouped_mess",
        dataType: "json",
        success: function(data){
            if(data.status==1){
                $(obj).parent().remove();
            }else{
                tishi("操作失败!");
            }
        },
        error: function(data){
            tishi("操作失败!");
        }
    })
}
function delete_student_tag(obj,school_class_id,student_id){
    var page_value = getQueryString("page");
    var html = ""
    var path = "/school_classes/"+ school_class_id +"/tags/choice_tags"
    $.ajax({
        url : "/school_classes/" + school_class_id + "/tags/delete_student_tag",
        type:'post',
        dataType : 'json',
        data : {
            student_id : student_id
        },
        success:function(data){
            var flag = false;
            for(var i=0;i<data.tag.length;i++){
                if(data.tag[i].id!= data.schoolclassstudentralastion.tag_id){
                    flag = true;
                    var name = data.tag[i].name
                    var id = data.tag[i].id
                    html +="<li><form action='"+ path +"' method='post' >\n\
                               <input type='submit' value='"+ name +"' class='tab_head' style='color: #F3F8F7;'>\n\
                               <input type='text' name='tag_id' value="+ id +" style='display:none' >\n\
                                <input type='text' name='student_id' value="+ student_id +" style='display:none'>\n\
                                <input type='text' name='page' value='"+ page_value +"' style='display:none'/>\n\
                                </form>  </li> ";
                }
            }
            if(flag){
                var html_ul = "<a href='javascript:void(0);' class='close'>close</a>\n\
<div class='tab_body clearAfter'><div class='tab_warning'>根据本班学员的个人情况进行分组</div><div class='tab_switch'>\n\
<ul style='border:0'>"+ html +"</ul></div></div>"
                $(".regrouping").html(html_ul);
                $(".regrouping").show();
            }else{
                tishi("当前班级没有更多的组！")
            }
        }
    })
}

//弹出框高度
function height_tab(){
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var z_layer_height = $(".tab").height();
    $(".tab").css('top',10);
    var doc_width = $(document).width();
    var layer_width = $(".tab").width();
    $(".tab").css('left',(doc_width-layer_width)/2);
}


function onclick_submit(obj){
    var questions_item = $(obj).parents(".questions_item")
    var question_type = questions_item.attr("question_type")
    if(question_type=="select"){
        var select_resourse = questions_item.find("input[name='select_resourse']");
        var select_content = questions_item.find("input[name='select_content']").val();
        var title_length = select_resourse.val() + select_content
        var check_select = questions_item.find("input[name='check_select[]']:checked").length;
        var select_value1 = questions_item.find("input[name='select_value1']").val();
        var select_value2 = questions_item.find("input[name='select_value2']").val();
        var select_value3 = questions_item.find("input[name='select_value3']").val();
        var select_value4 = questions_item.find("input[name='select_value4']").val();
        var select_arr = [select_value1,select_value2,select_value3,select_value4]
        var flag = false;
        for(var i=0;i<select_arr.length;i++){
            for(var j=i+1;j<select_arr.length;j++){
                if(select_arr[i]==select_arr[j]){
                    flag=true;
                }
            }
        }
        if (select_value4==""|| select_value3=="" || select_value2=="" || select_value1==""){
            tishi("选项不能为空！");
            return false;
        }else if(check_select<=0){
            tishi("请选择至少一个正确答案！");
            return false;
        }else if(flag){
            tishi("不可出现重复选项！");
            return false;
        }else if(select_resourse.length<=0 && select_content==""){
            tishi("题目不能为空！")
            return false;
        }
        else if(title_length.length>250){
            tishi("题目长度超过250！");
        }
    }else if (question_type=="lianxian"){
        var left_lianxian = questions_item.find("input[name='left_lianxian']").val()
        var right_lianxian = questions_item.find("input[name='right_lianxian']").val()
        if(left_lianxian==""|| right_lianxian==""){
            tishi("连线内容不能为空！");
            return false;
        }
    }
    $(obj).parent().parent().find(".submit_sava").click();
    var form_class = questions_item.attr("stypes")
    var question_package_id = questions_item.find("input[name='question_package_id']").val()
    if (form_class=="save_select"){
        questions_item.find("form").attr("action","/question_packages/"+ question_package_id +"/questions/update_select")
        $(obj).parent().find(".delete").show();
        $(obj).parent().find(".tag").show();
        $(obj).parent().find(".save").hide();
    }else if (form_class=="save_lianxian"){
        questions_item.find("form").attr("action","/question_packages/"+ question_package_id +"/questions/update_lianxian")
        $(obj).parent().find(".delete").show()
        $(obj).parent().find(".tag").show();
        $(obj).parent().find(".save").hide()
    }else{

}
}


function show_branch_question(obj,question_package_id,question_id,types){

    $.ajax({
        url : "/question_packages/"+ question_package_id +"/questions/show_branch_question",
        type: 'get',
        dataType : 'json',
        data : {
            question_id : question_id,
            types : types
        },
        success :function(data){
            
        }
    })

}

//选择上传音频或者视屏
function select_upload_choice(obj){
    $("input[name='select_file']").removeAttr("id")
    $(obj).parent().find("input[name='select_file']").attr("id","input_select_upload")
    if($(obj).attr("input_t")=="voice"){
        $(obj).parent().find("#input_select_upload").attr("input_t","voice")
    }else if ($(obj).attr("input_t")=="photo"){
        $(obj).parent().find("#input_select_upload").attr("input_t","photo")
    }
    $(obj).parent().find("#input_select_upload").click()
//    $("#input_select_upload").click();
}

//上传资源
function select_upload(obj){
    var type = $(obj).attr("input_t");
    var fil_name =  $(obj).val();
    var img_extension = fil_name.substring(fil_name.lastIndexOf('.') + 1).toLowerCase();
    if(type=="voice"){
        if(img_extension == "mp3" || img_extension == "amr" || img_extension == "wav"){
        }else{
            tishi("音频格式不对! 仅支持mp3、amr、wav格式");
            return false;
        }
    }else if (type=="photo"){
        if(img_extension == "jpg" || img_extension == "png"){
        }else{
            tishi("图片格式不对! 仅支持jpg,png格式");
            return false;
        }
    }
    var question_package_id = $(obj).parents(".questions_item").find("#question_package_id").val();
    var question_id = $(obj).parents(".questions_item").find("input[name='question_id']").val();
    $.ajaxFileUpload(
    {
        type:'post',
        url:'/question_packages/'+ question_package_id +'/questions/select_upload',            //需要链接到服务器地址
        secureuri:false,
        fileElementId:'input_select_upload',                  //文件选择框的id属性
        dataType: 'text',
        data :{
            type : type
        },                                               //服务器返回的格式，可以是json
        success: function (data, status)            //相当于java中try语句块的用法
        {
            var data_arr = data.split(";||;")
            tishi("上传成功！");
            var html="<input type='text' value='"+ data_arr[1] +"' name='select_resourse' style='display:none;'>"
            var q_left = $("#input_select_upload").parents(".q_left")
            //            $(obj).parents().find(".q_topic").attr("class","q_topic q_compile")
            if(data_arr[0]=="voice"){
                $("#input_select_upload").parents(".q_topic").find("input[name='select_content']").attr("disabled","true")
                //                var html_title = "<input type='text' name='select_content' style='display:block;' disabled='true'>"
                var html_title = "<p></p><input type='text' name='select_content' style='display:none;background: #F0F0F0;' disabled='true'>"
                $("#input_select_upload").parents(".q_topic").find(".q_title").find(".qt_text").html(html_title)
                var  html_audiao = "<a href='javascript:void(0)' onclick='playAudio(this)' id='audio_only'> \n\
                                        <img src='/assets/voiceing.jpg'>\n\
                                        </img></a>"
                q_left.html(html_audiao)
                var audio = document.createElement("audio");
                audio.preload = true;
                audio.controls = true;
                audio.style.display='none'
                var source= document.createElement("source");
                source.type= "audio/ogg";
                source.src = data_arr[1]
                audio.appendChild(source);
                $("#audio_only").append(audio)
            }else if(data_arr[0]=="photo"){
                q_left.html("<img src='"+ data_arr[1] +"' style='width:86px;height:86px;'>")
            }
            q_left.append(html)
            $("#input_select_upload").removeAttr("id")
        },
        error: function (data, status, e)            //相当于java中catch语句块的用法
        {
            $('#result').html('添加失败');
        }
    });
}

//选择tag
function add_selects_tags(obj){
    common_tags(obj);
    var branch_question_id = $(obj).parents(".questions_item").attr("branch_question_index");
    var question_item = $(obj).parents(".questions_item")[0]
    var q_index = $($(obj).parents(".ab_article")[0]).find(".questions_item").index($(question_item));
    var question_name = $(obj).parents(".questions_item").attr("question_type")
    $("#tags_table").find("input[name='q_index']").first().val(gloab_index);
    $("#tags_table").find("input[name='b_index']").first().val(q_index);
    $("#tags_table").find("input[name='tag_bq_type']").first().val(question_name);
    $("#tags_table").find("input[name='branch_question_id']").first().val(branch_question_id);
    var lis = $("#tags_table").find("li");
    var types = $(obj).parents(".questions_item").attr("question_type")
    $.each(lis, function(){
        var current_input = $(this).find("input").first();
        // current_input.attr("onclick","add_content_to_paixu(this,"+q_index+","+ branch_question_id+")")
        $(current_input).on("ifChecked", function(){
            add_tag_to_select($(this),q_index,branch_question_id,types)
        //            add_content_to_paixu($(this), q_index, branch_question_id);
        })
    })
}

function add_tag_to_select(obj,q_index,branch_question_id,types){
    if($(obj).attr("checked")=="checked"){
        var shcool_id = $("#school_class_id").val();
        var question_pack_id = $("#question_package_id").val();
        var value = $(obj).val();
        $.ajax({
            url:"/school_classes/"+shcool_id+"/question_packages/save_branch_tag",
            dataType:"json",
            data:"branch_question_id="+branch_question_id+"&branch_tag_id="+value,
            success:function(data){
                if(data.status == 1){
                    var old = $($( $(".assignment_body_list")[gloab_index] ).find(".questions_item")[q_index]);
                    if(types=="select"){
                        old.find(".tag_ul ul").
                        append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\"select\")' class='x'>X</a></li>");
                    }else if(types=="lianxian"){
                        old.find(".tag_ul ul").
                        append("<li><p>"+data.tag_name+"</p><a onclick='delete_tags(this,"+shcool_id+","+question_pack_id+","+data.tag_id+","+branch_question_id+",\"lianxian\")' class='x'>X</a></li>");
                    }
                    html="<class='aaa'>"
                }else if(data.status == 2){
                    alert("添加失败，重复标签！");
                }else if(data.status == 3){
                    alert("添加失败，无此标签！");
                }
            }
        })
    }

}


//点击新建
function new_select_question(obj){
    $("div.ab_list_box").hide();
    var episode_id = $("#episode_id").val();
    var question_package_id = $("#question_package_id").val()
    var type = 3
    var cell_id = $("#cell_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/question_packages/"+question_package_id+"/questions/show_select",
        data:{
            episode_id : episode_id,
            question_package_id : question_package_id,
            type : type,
            cell_id : cell_id
        },
        success:function(){
        }
    });
}

function new_lianxian_question(obj){
    $("div.ab_list_box").hide();
    var episode_id = $("#episode_id").val();
    var question_package_id = $("#question_package_id").val()
    var type = 4
    var cell_id = $("#cell_id").val();
    $.ajax({
        dataType:"script" ,
        url:"/question_packages/"+question_package_id+"/questions/new_lianxian",
        data:{
            episode_id : episode_id,
            question_package_id : question_package_id,
            type : type,
            cell_id : cell_id
        },
        success:function(){
        }
    });
}
// 如果变量大于0 说明分组有变化，则需要跳转，否则不跳转
function whether_skip(){
    if(no_tag>0){
        window.location.reload()
    }
}
