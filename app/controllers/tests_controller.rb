class TestsController < Simpler::Controller

  def index
    # render 'tests/list.html'
    # render 'tests/index.text'
    # render 'tests/index.html'
    # render 'tests/index'
    # render template: "tests/index.text"
    # render template: "tests/index.text", status: 234
    # render plain: "plain text"
    # render html: %Q[<h1>html <span style="color: red;">answer</span></h1>]
    @time = Time.now
  end

  def create; end

  def show
    @id = params[:id]
  end

end
