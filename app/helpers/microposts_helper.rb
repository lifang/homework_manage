#encoding: utf-8
module MicropostsHelper
  require 'net/http'
  def jpush_parameter messages,receivervalue
    sendno = '1001'
    receivertype = '3'
    mastersecret = "902d3da3dc9366734a84ee21"
    input = sendno+ receivertype + receivervalue + mastersecret
    code = Digest::MD5.hexdigest(input)
    map = Hash.new
    map.store("sendno", sendno)
    map.store("app_key", "26e6b3d44da78ea902c7fac9")
    map.store("receiver_type", receivertype)
    map.store("receiver_value",receivervalue)
    map.store("verification_code", code)
    map.store("txt", messages)
    map.store("platform", "android")
    data =  (Net::HTTP.post_form(URI.parse("http://api.jpush.cn:8800/sendmsg/v2/notification"), map)).body
    p data
  end
end
