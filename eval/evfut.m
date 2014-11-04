function [X Y C R XP YP] = evfut(f, ni, d, nst, option, modo, vrf, nsrf)
%% EVFUT eval�a una o m�s funciones de utilidad a efectos de
% del espacio de utilidad, pareto-optimalidad, correlaci�n y
% rugosidad.
%
% F cell array de handles a funciones. 
%
% NI n�mero de issues.
%
% D vector de dominios o
% restriccion RES. La restricci�n tiene que tener definido el centro, el
% radio y el �ndice.
%
% NST n�mero de muestras total.
%
% VRF vector de factor de rugosidad
%
% NSRF n�mero de muestras por distancia en VRF
%
% MODO En 'rect_random'  y 'rect_grid' se analiza el dominio de la funci�n determinado por D en forma
% de hiper-rect�ngulo. 'rect_grid' s�lo opera con dominios id�nticos para todas las variables. 
% D ser� un vector de dominio. En modo
% 'res_random' y 'res_grid' se analiza el dominio de la funci�n determinado 
% por D en forma de restricci�n. En definitiva, se analiza la funci�n para el dominio
% restringido por la restricci�n D. La diferencia entre _random y
% _grid reside en la forma de generar los puntos a pasar a la funci�n.
%
% OPTION
%   1- Calcular s�lo utilidades
%   2- Calcular utilidades+correlacion
%   3- Calcular utilidades+correlaci�n+rugosidad
%   4- Calcular utilidades+correlaci�n+rugosidad+frontera pareto

%  
% X valores de muestra, Y valores de
% salida de la funciones. XP e YP
% representan los puntos pareto �ptimos.
%
% C es la matriz (:,:,4) de coeficientes de correlaci�n, p-values, rlo y
% rlup.
%
% R Vector de rugosidades de las funciones.
%%
disp('Calculando muestras...')
nf = length(f); %N�mero de funciones
t = fix(nst.^(1/ni)); %N�mero total de samples
if strcmp(modo, 'rect_grid') %s�lo operativo en el caso de variables con dominio id�ntico
    [Xm{1:ni}]  = ndgrid(linspace(d(1,1), d(2,1), t));
    nst = t^ni;
    for i=1:ni    
        X(:,i) = reshape(Xm{i}, nst, 1);
    end
elseif strcmp(modo, 'rect_random')
    X = unifrnd(repmat(d(1,:), nst, 1), repmat(d(2,:), nst, 1));
elseif strcmp(modo, 'res_grid')
    X = genpeuclid(d.centro(d.ind, :), [0 d.rd(d.ind)], nst, [], 'grid');
    nst = size(X, 1);
else %res_random
    X = genpeuclid(d.centro(d.ind, :), [0 d.rd(d.ind)], nst, [], 'random');
    nst = size(X, 1);
end
for k=1:nf
    Y(:, k) = f{k}(X, d);
end

if option>=2
    disp('Calculando coeficiente de correlacion...')
    [c p rlo rlu]= corrcoef(Y);
    C(:,:,1) = c;
    C(:,:,2) = p;
    C(:,:,3) = rlo;
    C(:,:,4) = rlu;
end

if option>=3
    disp('Calculando factores de rugosidad...')
    for k=1:nf
        R(k,:) = rugfactor(f{k}, ni, d, vrf, nsrf);
    end
    R = R';
end
if option>=4
    %   C�lculo de puntos pareto �ptimos
    disp('Calculando puntos pareto...')
    listpareto(1) = 1;
    for i=1:nst %Bucle del punto a analizar
        for j=1:i %Bucle de recorrido de puntos de la lista pareto
             if listpareto(j) == 1 %S�lo se toman puntos de la lista pareto
                 for k=1:nf
                     g(k) = f{k}(X(i,:),d)>=f{k}(X(j,:),d);
                     l(k) = f{k}(X(i,:),d)<=f{k}(X(j,:),d);
                 end
                 if all(g)
                     listpareto (j) = 0; %El punto de referencia ya no es pareto optimo
                     listpareto (i) = 1; %El punto analizado es pareto optimo 
                 elseif all(l)
                     listpareto (i) = 0; %El punto analizado no es pareto optimo, no es 
                     break; % necesario seguir comparando
                 else %El punto analizado es peor s�lo en alguno o algunos de los criterios pero mejor en otro u otros.
                     listpareto (i) = 1;    %El punto de referencia no se debe eliminar, y el actual es tambi�n pareto optimo 
                 end  
             end
        end     
    end

    XP = X(logical(listpareto), :); %Se almacena en XP la lista de puntos pareto optimos

    for k=1:nf
        YP(:, k) = f{k}(XP,d);
    end
end



