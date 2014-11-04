function dp = distPareto(fp, p, type, d)
%DISTPARETO C�lculo de distancias de puntos soluci�n a un frente de Pareto.
%   DISTPARETO calcula la distancia de puntos soluci�n P al Frente de
%   Pareto FP.
%
%   DP = DISTPARETO(FP, P, TYPE, D)
%
%   FP puede representar:
%       (1) La recta expl�cita  R(1)x+R(2)y+R(3)=0, cuando el Frente es una
%       recta.
%       (2) Un set de m puntos mxn, donde n representa el n�mero de agentes.
%       Cada punto es un punto del Frente de Pareto.
%       (3) Un handle a una funci�n expl�cita F(X)=0 que permite definir el frente de
%       pareto.
%
%   P representa la matriz de puntos para los que se quiere calcular la distancia, donde cada fila es un punto. Para el
%   type (3), s�lo se permite un punto.
%
%   D se utiliza s�lo para el  caso (3), como vector de dominios.
%
%
%   TYPE determina el tipo de representaci�n del FP:
%       (1) Recta
%       (2) Set de puntos
%       (3) Handle a funci�n
%
%   DP es un vector de distancias.
%%
    npfp = size(fp,1);
    np = size(p,1);

    if type == 1
        dp = abs(p(:,1).*fp(1)+p(:,2).*fp(2)+fp(3))./sqrt(fp(1).^2+fp(2).^2);
    elseif type == 2
        for i=1:np
            s = (fp-repmat(p(i,:),npfp ,1))';
            dp(i) = min(sqrt(sum(s.^2)));
        end
    else %type == 3
        options = optimset('Algorithm','active-set','Display','off'); % run active-set algorithm
        for i=1:np
            x0 = p;
            [x y exitflag] = fmincon(@(x) sum((x-p).^2), x0, [], [], [], [], d(1,:), d(2,:), @(x) constraint(x, fp),options);
            dp(i) = sqrt(y);
        end
    end
    function [c ceq] = constraint(x, h)
        c = [];
        ceq = h(x);
    end
end


