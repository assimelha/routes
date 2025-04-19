defmodule Routes.Generator do
  @moduledoc """
  Generates JavaScript code with TypeScript definitions for route handling.
  """

  @doc """
  Generates JavaScript code from transformed routes.
  """
  def generate_javascript(routes) do
    routes_json = Jason.encode!(routes)

    """
    const Routes = (function() {
      const routes = #{routes_json};

      function replaceParams(path, params = {}) {
        let result = path;
        const routeParams = {...params};
        delete routeParams._query;

        // Keep track of used route parameters
        const usedParams = new Set();

        Object.keys(routeParams).forEach(key => {
          if (result.includes(`:${key}`)) {
            result = result.replace(`:${key}`, String(routeParams[key]));
            usedParams.add(key);
          }
        });

        const queryParams = {...params};
        const explicitQueryParams = queryParams._query || {};
        delete queryParams._query;

        // Remove used route parameters from query params
        usedParams.forEach(key => delete queryParams[key]);

        const allQueryParams = {...queryParams, ...explicitQueryParams};
        const queryString = Object.keys(allQueryParams).length
          ? '?' + new URLSearchParams(Object.fromEntries(
              Object.entries(allQueryParams).filter(([_, v]) => v != null)
            )).toString()
          : '';

        return result + queryString;
      }

      function route(name, params = {}) {
        const route = routes.find(r => r.name === name);
        if (!route) throw new Error(`Route '${name}' not found`);

        return replaceParams(route.path, params);
      }

      function path(name, params = {}) {
        return route(name, params);
      }

      function method(name) {
        const route = routes.find(r => r.name === name);
        if (!route) throw new Error(`Route '${name}' not found`);
        return route.method;
      }

      function hasRoute(name) {
        return routes.some(r => r.name === name);
      }

      return {
        routes,
        route,
        path,
        method,
        hasRoute,
        replaceParams
      };
    })();

    if (typeof module !== 'undefined' && module.exports) {
      module.exports = Routes;
    } else if (typeof window !== 'undefined' && window) {
      window.Routes = Routes;
    }

    export default Routes;
    """
  end

  @doc """
  Generates TypeScript declaration file.
  """
  def generate_typescript_declarations(routes) do
    route_defs = generate_route_type_definitions(routes)
    route_names = generate_route_names(routes)
    route_methods = routes |> Enum.map(& &1.method) |> Enum.uniq() |> Enum.join(" | ")
    route_path_config = generate_route_path_config(routes)

    """
    interface Route {
      readonly name: string;
      readonly action: string;
      readonly path: string;
      readonly method: string;
      readonly controller: string;
      readonly params: readonly string[];
    }

    type HTTPMethod = #{route_methods};

    type QueryParam = string | number | boolean | null | undefined;
    type QueryParams = Record<string, QueryParam | QueryParam[]>;

    type RouteParams = {
      #{route_defs}
    }

    type RouteName = #{route_names};

    type RouteParamsWithQuery<T extends Record<string, any>> = T & {
      _query?: QueryParams;
    }

    type RoutePathConfig = {
      #{route_path_config}
    }

    type RoutePath = keyof RoutePathConfig;

    type PathParamsWithQuery<T extends RoutePath> = RoutePathConfig[T] & {
      _query?: QueryParams;
    }

    declare const Routes: {
      readonly routes: readonly Route[];

      route<T extends RouteName>(
        name: T,
        params?: RouteParamsWithQuery<RouteParams[T]>
      ): string;

      path<T extends RouteName>(
        name: T,
        params?: RouteParamsWithQuery<RouteParams[T]>
      ): string;

      replaceParams<T extends RoutePath>(
        path: T,
        params?: PathParamsWithQuery<T>
      ): string;

      method(name: RouteName): HTTPMethod;

      hasRoute(name: string): name is RouteName;
    };

    export as namespace Routes;
    export { RoutePath, PathParamsWithQuery };
    export = Routes;
    """
  end

  @doc """
  Writes JavaScript file.
  """
  def write_javascript(routes, base_path) do
    js_content = generate_javascript(routes)

    js_path = Path.join(base_path, "routes.js")

    File.write!(js_path, js_content)
  end

  @doc """
  Writes both JavaScript and TypeScript declaration files.
  """
  def write_javascript_with_types(routes, base_path) do
    js_content = generate_javascript(routes)
    dts_content = generate_typescript_declarations(routes)

    js_path = Path.join(base_path, "routes.js")
    dts_path = Path.join(base_path, "routes.d.ts")

    File.write!(js_path, js_content)
    File.write!(dts_path, dts_content)
  end

  # Add new helper function for generating RoutePathConfig
  defp generate_route_path_config(routes) do
    routes
    |> Enum.group_by(& &1.path)
    |> Enum.map(fn {path, path_routes} ->
      # Use the first route's params since all routes with the same path should have the same params
      route = List.first(path_routes)

      params =
        if Enum.empty?(route.params) do
          "Record<string, never>"
        else
          route.params
          |> Enum.map(&"#{&1}: string | number")
          |> Enum.join("; ")
          |> then(&"{#{&1}}")
        end

      "\"#{path}\": #{params}"
    end)
    |> Enum.join(";\n      ")
  end

  defp wrap_in_quotes(string) do
    string
    |> String.split(" | ")
    |> Enum.map(&"\"#{&1}\"")
    |> Enum.join(" | ")
  end

  defp generate_route_type_definitions(routes) do
    routes
    |> Enum.map(fn route ->
      params =
        if Enum.empty?(route.params) do
          "Record<string, never>"
        else
          route.params
          |> Enum.map(&"#{&1}: string | number")
          |> Enum.join("; ")
          |> then(&"{#{&1}}")
        end

      "\"#{route.name}\": #{params}"
    end)
    |> Enum.join(";\n  ")
  end

  defp generate_route_names(routes) do
    routes
    |> Enum.map(& &1.name)
    |> Enum.join(" | ")
    |> wrap_in_quotes()
  end
end
