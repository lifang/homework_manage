#encoding: utf-8
module MicropostsHelper
  require 'net/http'
  def jpush_parameter messages,receivervalue
    message = "\"#{message}\""
    sendno = 1001
    receivertype = 3
    mastersecret = "902d3da3dc9366734a84ee21"
    input ="#{sendno}" + "#{receivertype}" + receivervalue + mastersecret
    code = Digest::MD5.hexdigest(input)
    msg_content =  "{\"n_title\":\"1111222\",\"n_content\":#{messages},\"n_extras\":{\"class_id\":\"2\"} }"
    msg_content = {"n_content" => "#{messages}","n_title"=> "2iidid","extras"=>{"class_id"=> "2"}}.to_json()
#    msg_content = {"n_content" => "#{messages}"}.to_json()  #,"title"=>"iiiii","extras"=>{"class_id"=>"2"} }.to_json()
    p msg_content
#    msg_content = {"n_title":"hello","n_content":"hello zhe tian","n_extras":{"n_url":"","n_type":"1"}}

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
