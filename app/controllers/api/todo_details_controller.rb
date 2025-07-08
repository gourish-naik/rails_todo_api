class Api::TodoDetailsController < ApplicationController
  before_action :set_todo

  # GET /todo/:id

# | Method | Endpoint    | Action                 |
# | ------ | ----------- | ---------------------- |
# | GET    | `/todo/:id` | Show todo details      |
# | PATCH  | `/todo/:id` | Mark todo as completed |
# | DELETE | `/todo/:id` | Delete if completed    |

  def show
    render json: {
      id: @todo.id,
      title: @todo.todo_name,
      description: @todo.description,
      completed: @todo.completed,
      completed_at: @todo.completed? ? @todo.updated_at : nil
    }
  end

  # PATCH /todo/:id
  def update
    status = params[:completed]
    puts params.inspect

    if @todo.update(todo_params)
      render json: {
        message: "Marked as completed",
        completed_at: @todo.updated_at
      }, status: :ok
    else
      render json: { error: "Could not update todo" }, status: :unprocessable_entity
    end
  end

  # DELETE /todo/:id
  def destroy
    if @todo.completed?
      @todo.destroy
      render json: { message: "Todo deleted" }, status: :ok
    else
      render json: { error: "Cannot delete an incomplete todo" }, status: :unprocessable_entity
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Todo not found" }, status: :not_found
  end

  def todo_params
    params.require(:todo_detail).permit(:description)
  end
end
