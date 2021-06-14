function A = generateSPDmatrix(n)
    A = rand(n);
    A = 0.5 * (A + A');
    A = A + (n * eye(n));
end