function [dc fnl pv vd] = rugfactor(f, ni, d, vd, ns)
%% RUGFACTOR calcula el factor de complejidad local de una regi�n
%% hiper-rectangular o hiperesf�rica. 
% La funci�n retorna la distancia de correlaci�n DC para un umbral 0.5 de corrcoef, los coeficientes de
% correlaci�n y los p-valores (por debajo de 0.05 se pueden considerar
% valores de correlaci�n v�lidos). A mayor DC menor complejidad local.
%
%   F funci�n de utilidad.
%
%   NI n�mero de issues.
%
%   D dominio de los atributos. Puede ser un vector simple que define un
%   rango, o una restricci�n. En el primer caso el factor de rugosidad se
%   calcula sobre un hiper-rect�ngulo. En el segundo caso se calcula sobre
%   una hiperesfera.
%
%   VD vector de distancias en orden creciente.
%
%   NS n�mero de muestras a tomar por medida de distancia.
%
%%
nd = length(vd);
nst = ns;
for i=1:nd
    ns = nst;
%     if isstruct(d) %la regi�n es una hiperesfera
%         pa = unifrnd(-d.rd(d.ind), d.rd(d.ind), ni, ns); 
%         pa(:, logical(sqrt(sum(pa.^2))>d.rd(d.ind))) = [];
%         ns = size(pa, 2);
%         pa = pa' + repmat(d.centro(d.ind,:), ns, 1) ;  
%     else %la regi�n es un hiper-rect�ngulo
        pa = unifrnd(d(1,1), d(2,1), ns, ni);
%     end
    %c�lculo de puntos apareados
    v = unifrnd(-1,1,ni,ns);
    v = v./repmat(sqrt(sum(v.^2)), ni,1); %vectores unitarios aleatorios
    pb = pa + vd(i).*v';
    sel = ( pb < repmat(d(1,:),ns,1) | pb >repmat(d(2,:),ns,1));
    sel = sel(:,1)|sel(:,2);
    pb(sel,:) = []; pa(sel,:) = [];
    [c(:,:,i) p(:,:,i)]= corrcoef(f(pa,d)', f(pb,d)');
    fnl(i) = c(1,2,i);
    pv(i) = p(1,2,i);
end
sel = find(pv<0.05); %nos quedamos s�lo con las DC significativas
fnl = fnl(sel);
pv = pv(sel);
vd = vd(sel);
if(isempty(find(fnl<=0.5, 1)))
    dc = Inf; %no hay correlaciones menores o iguales que 0.5. Significa que la
                            %DC es mayor que la mayor de las distancias en
                            %VD.
else
%     pfit = polyfit(fnl, vd, 5); %regresi�n mediante polinomio de orden 5
%     dc = polyval(pfit, 0.5);
    dc = vd(find(fnl>=0.5,1,'last'));
    if isempty(dc)
        dc=-Inf; %la DC es menor que la menor de las distancias en VD 
    end
end
