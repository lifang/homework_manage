#encoding: utf-8
module MicropostsHelper
  require 'net/http'
  def jpush_parameter messages,receivervalue,extras_hash=nil
    sendno = 1001
    receivertype = 3
    mastersecret = "902d3da3dc9366734a84ee21"
    input ="#{sendno}" + "#{receivertype}" + receivervalue + mastersecret
    code = Digest::MD5.hexdigest(input)
    msg_content =  "{\"n_title\":\"1111222\",\"n_content\":#{messages},\"n_extras\":{\"class_id\":\"2\"} }"
    content = {"n_content" => "#{messages}","n_title"=> "2iidid"}
    content["extras"]=extras_params_hash if !extras_hash.nil? && extras_hash.class == Hash
    msg_content = content.to_json()
    p content
    map = Hash.new
    map.store("sendno", sendno)
    map.store("app_key", "26e6b3d44da78ea902c7fac9")
    map.store("receiver_type", receivertype)
    map.store("receiver_value",receivervalue)
    map.store("verification_code", code)
    map.store("msg_type",1)
    map.store("msg_content",msg_content)
    map.store("platform", "android")
    data =  (Net::HTTP.post_form(URI.parse("http://api.jpush.cn:8800/v2/push"), map)).body
    p data
  end
end
