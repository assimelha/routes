defmodule TestSupport.Routes.TestRouter do
  use Phoenix.Router
  use Routes

  get("/", Routes.TestController, :index)
  get("/users", Routes.TestController, :list)
  get("/users/:id", Routes.TestController, :show)
  post("/users", Routes.TestController, :create)
  put("/users/:id", Routes.TestController, :update)
  delete("/users/:id", Routes.TestController, :delete)
end
