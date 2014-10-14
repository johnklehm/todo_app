TodoApp::App.controllers :todo_item do
	# FIXME white list params?
	# separate api app?

	get :index, :provides => :json, :map => "/api/v1/todo_item" do
		TodoItem
			.where(:account_id => current_account[:id])
			.reverse_order(:created_at)
			.to_json
	end

	post :index, :provides => :json, :map => "/api/v1/todo_item" do
		begin
			logger.info "post params: #{params.inspect}"
			logger.info "post params[:attributes]: #{params[:attributes]}"

			@todoitem = TodoItem.new(params[:attributes])
			logger.info "TodoItem.new #{@todoitem}"

			@todoitem.set(account_id: current_account[:id])
			logger.info @todoitem.inspect

			# @#$#$ save for not throwing by default...@#$% me for using a validator on a field a hook was populating..
			@todoitem.save(:raise_on_failure => true)

			logger.info "todoitem.inspect: #{@todoitem.inspect}"
			@todoitem.to_json

		rescue
			logger.error $!.error
			halt 409
		end
	end

	delete :index, :with => :id, :provides => :json, :map => "/api/v1/todo_item" do
		item = TodoItem
			.where(:account_id => current_account[:id])
			.with_pk(:id)
		if item.present? and item.destroy then
			status 200
			body ''
		else
			halt 404
		end
	end

	get :todo_item, :provides => :json, :map => "/api/v1/todo_item/:id" do
		todoId = params[:id]
		if !todoId.present? then
			halt 404
		end

		item = TodoItem
			.where(:account_id => current_account[:id])
			.with_pk(todoId)
		if item.present? then
			item.to_json
		else
			halt 404
		end
	end

	put :todo_item, :provides => :json, :map => "/api/v1/todo_item/:id" do
		todoId = params[:id]
		newVals = params[:attributes]

		item = TodoItem
			.where(:account_id => current_account[:id])
			.with_pk(todoId)

		if item.present? && item.update(newVals) then	
			item.to_json
		else
			logger.warn "update failed for todo_item #{item.inspect}, newVals #{newVals.inspect}"
			halt 404
		end
	end

	put :todo_item_many, :provides => :json, :map => "/api/v1/todo_items" do

		shadyTodos = {}
		params[:attributes].each { |index, val| 
			logger.info "each param: #{val.inspect}"

			objId = val[:id].to_i
			logger.info "objId: #{objId.inspect}"
			
			shadyTodos[objId] = val
		}

		goodTodos = Array.new

		# only look up ids we own
		TodoItem
			.where(:account_id => current_account[:id])
			.where(:id => shadyTodos.map { |key, val| 
				logger.info "shadyTodos map: key:#{key.inspect}, val:#{val.inspect}"
				key
			})
			.each do | mine |
				logger.info "shadyTodo each: #{mine.inspect}"

				# field restricted errors without filter even though I have an explicit list in update_only?
				newVals = shadyTodos[mine[:id]].delete_if do |key, value|
						key.to_s.match(/^(account_id|id)$/)
				end
				logger.info "shadyTodo each filter: #{newVals.inspect}"

				#why I can't limit to just those fields ?! 
				#upd = mine.update_only(newVals, :data_col, :data_row, :data_sizex, :data_sizey)

				# FIXME convert to batch updates
				if mine.update(newVals)
					goodTodos.push(mine)
				else
					logger.warn "update failed for todo_item #{mine.inspect} updateVals: #{newVals.inspect}"
				end
			end

		goodTodos.to_json
	end
end