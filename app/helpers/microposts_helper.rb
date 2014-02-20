#encoding: utf-8
module MicropostsHelper
  require 'net/http'
  def jpush_parameter messages,receivervalue,extras_hash=nil
    input ="#{Micropost::JPUSH[:SENDNO]}" + "#{Micropost::JPUSH[:RECEIVERTYPE]}" + receivervalue + Micropost::JPUSH[:MASTERSECRET]
    code = Digest::MD5.hexdigest(input)
    msg_content =  "{\"n_title\":\"1111222\",\"n_content\":#{messages},\"n_extras\":{\"class_id\":\"2\"} }"
    content = {"n_content" => "#{messages}","n_title"=> "2iidid"}
    content["extras"] = extras_params_hash if !extras_hash.nil? && extras_hash.class == Hash
    msg_content = content.to_json()
    map = Hash.new
    map.store("sendno", Micropost::JPUSH[:SENDNO])
    map.store("app_key", Micropost::JPUSH[:APP_KEY])
    map.store("receiver_type", Micropost::JPUSH[:RECEIVERTYPE])
    map.store("receiver_value",receivervalue)
    map.store("verification_code", code)
    map.store("msg_type",Micropost::JPUSH[:MSG_TYPE])
    map.store("msg_content",msg_content)
    map.store("platform", Micropost::JPUSH[:PLATFORM])
    data =  (Net::HTTP.post_form(URI.parse(Micropost::JPUSH[:URI]), map)).body
    p data
  end
end
