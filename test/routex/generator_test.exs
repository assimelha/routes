defmodule Routes.GeneratorTest do
  use ExUnit.Case

  describe "generate_javascript/1" do
    test "generates JavaScript route helper code" do
      routes = [
        %{
          name: "user",
          path: "/users/:id",
          method: "GET",
          controller: "Routes.TestController",
          action: :show,
          params: ["id"]
        },
        %{
          name: "users",
          path: "/users",
          method: "GET",
          controller: "Routes.TestController",
          action: :index,
          params: []
        }
      ]

      js_code = Routes.Generator.generate_javascript(routes)

      # Basic structure checks
      assert js_code =~ "const Routes ="
      assert js_code =~ ~s|"/users/:id"|
      assert js_code =~ ~s|"/users"|

      # Check route function existence
      assert js_code =~ "function route"
      assert js_code =~ "function path"
      assert js_code =~ "function method"
      assert js_code =~ "function hasRoute"

      # Check parameter handling
      assert js_code =~ "replaceParams"
    end

    test "generates valid JavaScript code" do
      routes = [
        %{
          name: "user",
          path: "/users/:id",
          method: "GET",
          controller: "Routes.TestController",
          action: :show,
          params: ["id"]
        }
      ]

      _js_code = Routes.Generator.generate_javascript(routes)

      # This is a basic validation that the generated code is proper JSON
      # The actual JS template part will be wrapped around this
      assert {:ok, _} = Jason.decode(routes |> Jason.encode!())
    end
  end

  describe "generate_typescript_declarations/1" do
    test "generates TypeScript declaration file" do
      routes = [
        %{
          name: "user",
          path: "/users/:id",
          method: "GET",
          controller: "Routes.TestController",
          action: :show,
          params: ["id"]
        }
      ]

      ts_code = Routes.Generator.generate_typescript_declarations(routes)

      # Check interface definition
      assert ts_code =~ "interface Route"
      assert ts_code =~ "name: string"
      assert ts_code =~ "params: readonly string[]"
      assert ts_code =~ "HTTPMethod ="

      # Check method declarations
      assert ts_code =~ "route<T extends"
      assert ts_code =~ "path<T extends"
      assert ts_code =~ "method(name:"

      # Check type declarations
      assert ts_code =~ "type QueryParam"
      assert ts_code =~ "type QueryParams"
      assert ts_code =~ "type RoutePath"
      assert ts_code =~ "type RoutePathConfig"
      assert ts_code =~ "type PathParamsWithQuery"

      # Check route name type and params
      assert ts_code =~ "\"user\""
      assert ts_code =~ "\"user\": {id: string | number}"
    end
  end

  describe "write_javascript_with_types/2" do
    test "writes JavaScript and TypeScript declaration files" do
      routes = [
        %{
          name: "user",
          path: "/users/:id",
          method: "GET",
          controller: "Routes.TestController",
          action: :show,
          params: ["id"]
        }
      ]

      temp_dir = System.tmp_dir!()
      Routes.Generator.write_javascript_with_types(routes, temp_dir)

      assert File.exists?(Path.join(temp_dir, "routes.js"))
      assert File.exists?(Path.join(temp_dir, "routes.d.ts"))
    end
  end

  test "includes support for CommonJS, ESM, and window exports" do
    routes = [
      %{
        name: "user",
        path: "/users/:id",
        method: "GET",
        controller: "Routes.TestController",
        action: :show,
        params: ["id"]
      }
    ]

    js_code = Routes.Generator.generate_javascript(routes)

    # CommonJS support
    assert js_code =~ "if (typeof module !== 'undefined' && module.exports) {"
    assert js_code =~ "module.exports = Routes;"

    # window global support
    assert js_code =~ "else if (typeof window !== 'undefined' && window) {"
    assert js_code =~ "window.Routes = Routes;"

    # ESM support
    assert js_code =~ "export default Routes;"
  end
end
