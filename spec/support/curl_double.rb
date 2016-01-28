class CurlDouble
  class Response
    attr_accessor :body

    def initialize(body)
      @body = body
    end
  end

  attr_accessor :stubbed_get_body, :stubbed_post_body

  def initialize(get="", post="")
    @stubbed_get_body = get
    @stubbed_post_body = post
  end

  def get(url, params={}, &block)
    Response.new(stubbed_get_body)
  end

  def post(url, params={}, &block)
    Response.new(stubbed_post_body)
  end
end
