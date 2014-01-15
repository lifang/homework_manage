// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function check_value()
{
    email = $("#email").val();
    password = $("#password").val();
//    alert(email);
//    alert(password);
    if(email == "邮箱" && password == "密码")
        alert("邮箱或密码不能为空！");
    else
        $("#login_submit_button").click();
    end
}