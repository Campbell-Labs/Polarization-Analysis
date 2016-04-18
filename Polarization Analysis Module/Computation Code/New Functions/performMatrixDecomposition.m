function [M_D, M_delta, M_R, R] = performMatrixDecomposition(MM)
% performMatrixDecomposition

mm = [...
    MM(2,2)  MM(2,3) MM(2,4);
    MM(3,2)  MM(3,3) MM(3,4);
    MM(4,2)  MM(4,3) MM(4,4)];

D = (1/MM(1,1)) .* [MM(1,2); MM(1,3); MM(1,4)];

P = (1/MM(1,1)) .* [MM(2,1); MM(3,1); MM(4,1)];

D_mag_sqr = (1/(MM(1,1)^2)) .* (((MM(1,2))^2) + ((MM(1,3))^2) + ((MM(1,4))^2));

I = eye(3);

m_D = (sqrt(1 - D_mag_sqr) * I) + ((1 - sqrt(1 - D_mag_sqr)) * ((1/D_mag_sqr)*(D*D')));

M_D = (1/MM(1,1)) .* ...
    [ 1 D(1) D(2) D(3);
    D(1) m_D(1,1) m_D(1,2) m_D(1,3);
    D(2) m_D(2,1) m_D(2,2) m_D(2,3);
    D(3) m_D(3,1) m_D(3,2) m_D(3,3);];

M_prime = MM / M_D;

m_prime = [ ...
    M_prime(2,2) M_prime(2,3) M_prime(2,4);
    M_prime(3,2) M_prime(3,3) M_prime(3,4);
    M_prime(4,2) M_prime(4,3) M_prime(4,4);];

P_delta = (P - (mm * D)) / (1- D_mag_sqr);

eigens = eig(m_prime * m_prime');

top = (m_prime * m_prime') + ((sqrt(eigens(1)*eigens(2)) + sqrt(eigens(1)*eigens(3)) + sqrt(eigens(2)*eigens(3))) .* I);
bot = ((sqrt(eigens(1)) + sqrt(eigens(2)) + sqrt(eigens(3))) * (m_prime * m_prime')) + (sqrt(eigens(1)*eigens(2)*eigens(3)) .* I);

m_delta = top \ bot;

if det(m_prime) < 0
    m_delta = -m_delta;
end

M_delta = [...
    1 0 0 0;
    P_delta(1) m_delta(1,1) m_delta(1,2) m_delta(1,3);
    P_delta(2) m_delta(2,1) m_delta(2,2) m_delta(2,3);
    P_delta(3) m_delta(3,1) m_delta(3,2) m_delta(3,3);];

M_R = M_delta \ M_prime;

R = acosd((trace(M_R) / 2) - 1);

end

