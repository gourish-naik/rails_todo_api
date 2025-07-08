class Api::TodosController < ApplicationController
  before_action :set_todo, only: %i[ show update destroy ]

  # GET /todos

################------ API DOC's ------ #########################
# | Purpose                | Request URL                        |
# | ---------------------- | ---------------------------------- |
# |     Get requests       |          endpoint                  |
# | All todos              | `/todos` or `/todos?completed=all` |
# | Only completed         | `/todos?completed=true`            |
# | Only incomplete        | `/todos?completed=false`           |
# | With pagination page 2 | `/todos?completed=false&page=2`    |
# | Sorting order          |  `/todos?order=desc`               |
# | Sorting with filter    |  `/todos?completed=true&order=asc` |
# | get specfic todo       |  `/todos/:id`                      |
# |    -------------------------------------------------------  |
# |     patch requests       |          endpoint                |
# | modify specfic todo    |  patch `/todos/:id` {content json} |

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

    items_per_page =  params[:count].to_i > 6 && params[:count].to_i < 25 ? params[:count].to_i : 12

    @todos = todos.order(updated_at: order_direction).page(params[:page]).per(items_per_page)
    render json:{
      todos: @todos.as_json(only: [:id,:todo_name,:completed,:description,:updated_at]),
      current_page: @todos.current_page,
      current_count: @todos.count,
      total_pages: @todos.total_pages,
      total_count: @todos.total_count,
      per_page_limit: items_per_page,
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

  # PATCH/PUT /todos/:id
  def update
    if @todo.update(todo_params)
      render json: @todo.as_json(only: [:id,:todo_name,:description,:completed,:updated_at])
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
      params.require(:todo).permit(:todo_name, :completed, :description)
    end
end
