%to be able to do nargout on anonymous function :(
function [f, g, h] = objective(input, fun)
  [f,g,h] = fun(input);
  h = 0.5 * (h + h');
end