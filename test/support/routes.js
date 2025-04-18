const Routes = (function() {
  const routes = [{"name":"index","path":"/","controller":"Routes.TestController","params":[],"action":"index","method":"GET"},{"name":"users.list","path":"/users","controller":"Routes.TestController","params":[],"action":"list","method":"GET"},{"name":"users.show","path":"/users/:id","controller":"Routes.TestController","params":["id"],"action":"show","method":"GET"},{"name":"users.create","path":"/users","controller":"Routes.TestController","params":[],"action":"create","method":"POST"},{"name":"users.update","path":"/users/:id","controller":"Routes.TestController","params":["id"],"action":"update","method":"PUT"},{"name":"users.delete","path":"/users/:id","controller":"Routes.TestController","params":["id"],"action":"delete","method":"DELETE"}];

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
} else {
  window.Routes = Routes;
}

export default Routes;
