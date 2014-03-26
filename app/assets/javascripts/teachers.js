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
    $(".tab_user").hide(100);
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
                window.location.href="/school_classes/" + school_class_id + "/teachers/teacher_setting";

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


function shwo_tags(){
    //    height_tab()
    $(".mask").show()
    $(".tag_list").show();
}
function show_switch_class(){
    //    height_tab()
    $(".mask").show()
    $("#school_class_list").show();
}

function delete_student_tag(obj,school_class_id,student_id){
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
            for(var i=0;i<data.tag.length;i++){
                if(data.tag[i].id!= data.schoolclassstudentralastion.tag_id){
                    var name = data.tag[i].name
                    var id = data.tag[i].id
                    html +="<li><form action='"+ path +"' method='post' >\n\
                               <input type='submit' value='"+ name +"' class='tab_head'>\n\
                               <input type='text' name='tag_id' value="+ id +" style='display:none' >\n\
                                <input type='text' name='student_id' value="+ student_id +" style='display:none'>\n\
                                </form>  </li> ";
                }
            }
            var html_ul = "<a href='javascript:void(0);' class='close'>close</a>\n\
<div class='tab_body clearAfter'><div class='tab_warning'>根据本班学员的个人情况进行分组</div><div class='tab_switch'>\n\
<ul>"+ html +"</ul></div></div>"
            $(".regrouping").html(html_ul);
            $(".regrouping").show()
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
    $(obj).parent().parent().find(".submit_sava").click();
    var questions_item = $(obj).parent().parent().parent()
    var form_class = questions_item.attr("stypes")
    var question_package_id = questions_item.find("input[name='question_package_id']").val()
    if (form_class=="save_select"){
        questions_item.find("form").attr("action","/question_packages/"+ question_package_id +"/questions/update_select")
        $(obj).parent().find(".delete").attr("href","/question_packages/"+ question_package_id +"/questions/delete_branch_question?id=162")
        $(obj).parent().find(".delete").show()
        $(obj).parent().find(".save").hide()
    }else if (form_class=="save_lianxian"){
        questions_item.find("form").attr("action","/question_packages/"+ question_package_id +"/questions/update_lianxian")
        $(obj).parent().find(".delete").show()
        $(obj).parent().find(".save").hide()
    }else{
        questions_item.find("form").attr("action","/question_packages/"+ question_package_id +"/questions/save_select")
        $(obj).parent().find(".delete").hide()
        $(obj).parent().find(".save").show()
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
            $(obj).parents().find(".q_topic").attr("class","q_topic q_compile")
            if(data_arr[0]=="voice"){
                alert($("#input_select_upload").parents(".q_topic").find("input[name='select_content']").attr("name"))
                $("#input_select_upload").parents(".q_topic").find("input[name='select_content']").attr("disabled","true")
                var html_title = "<input type='text' name='select_content' style='display:block;' disabled='true'>"
                $("#input_select_upload").parents(".q_topic").find(".q_title").find(".qt_text").html(html_title)
                q_left.html("<img src='/assets/voiceing.jpg'>")
            }else if(data_arr[0]=="photo"){
                alert(data_arr[0])
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
function upload_avatar(){

}