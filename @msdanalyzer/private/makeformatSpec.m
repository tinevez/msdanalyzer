function [numSpec,bkspSpec] = makeformatSpec(n_digits)
%MAKEFORMATSPEC Create reusable formatSpec that prints and deletes x/x.

assert(n_digits > 0)
assert(n_digits == round(n_digits))

dSpec = sprintf('%%%dd', n_digits);       % '%3d'
numSpec = [dSpec '/' dSpec];              % '%3d/%3d'
bkspSpec = repmat('\b', 1, 2*n_digits + 1);  % '\b\b\b\b\b\b\b'
end
