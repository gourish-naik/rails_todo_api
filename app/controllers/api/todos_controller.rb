class Api::TodosController < ApplicationController
  before_action :set_todo, only: %i[ show update_completed destroy ]

  # GET /todos

################------ API DOC's ------ #########################
# | Purpose                | Request URL                        |
# | ---------------------- | ---------------------------------- |
# | All todos              | `/todos` or `/todos?completed=all` |
# | Only completed         | `/todos?completed=true`            |
# | Only incomplete        | `/todos?completed=false`           |
# | With pagination page 2 | `/todos?completed=false&page=2`    |
# | Sorting order          |  `/todos?order=desc`               |
# | Sorting with filter    |  `/todos?completed=true&order=asc` |

#################################################################


  def index
    # handle filters
    case params[:completed]
    when 'true'
      todos = Todo.where(completed: true)
    when 'false'
      todos = Todo.where(completed: false)
    else
      todos = Todo.all
    end

    order_direction = params[:order].to_s.downcase == 'desc' ? :desc : :asc

    @todos = todos.order(updated_at: order_direction).page(params[:page]).per(10)
    render json:{
      todos: @todos.as_json(only: [:id,:todo_name,:completed,:updated_at]),
      current_page: @todos.current_page,
      total_pages: @todos.total_pages,
      total_count: @todos.total_count,
      sorting_order: order_direction
    }
  end

  # GET /todos/1
  def show
    render json: @todo
  end

  # POST /todos
  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      render json: @todo, status: :created
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todos/1
  def update_completed
    if @todo.update(completed: params[:completed])
      render json: @todo
    else
      render json: @todo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todos/1
  def destroy
    if @todo.completed?
      @todo.destroy!
      render json: Todo.all
    else
      render json: {error: "Todo not completed yet!"}, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:todo_name, :completed)
    end
end
