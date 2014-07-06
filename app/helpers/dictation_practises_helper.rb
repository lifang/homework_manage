module DictationPractisesHelper
	def render_select_item que
		item = "<li>#{que[:name]}(#{que[:username]})
				<input class='#{que[:origin_table]}__#{que[:origin_id]}' type='hidden'
					 value='#{que[:origin_table]}__#{que[:origin_id]}__#{que[:new_id]}'></li>"
		item
	end	
end
