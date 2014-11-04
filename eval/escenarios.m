%% COMPLEJIDAD DE ESCENARIOS DE NEGOCIACI�N
% La medida de complejidad de una escenario de negociaci�n depende de dos
% factores: la complejidad de la funci�n de utilidad individual, y la
% complejidad de las utilidades conjuntas.

%%% Funci�n de Utilidad Bell
% function [f] = *fbell*(np, ni, r, h, norm) genera dos handles a funciones de
% utilidad bell de NP picos, NI issues, radios comprendidos entre 1 y R, y
% alturas de campana comprendidas entre 0.1 y H. La utilidad m�xima se
% normaliza a 1 mediante simmulated annealing si NORM==true.
d = [0 0;100 100];
[xa.x xa.y]=meshgrid(linspace(0, 100, 100));
%%
figure;
[fB] = fbell(100, 2, 5, 1, false);
subplot(2,1,1); surf(xa.x, xa.y, fB(xa, d));
[fB] = fbell(400, 2, 5, 1, false);
subplot(2,1,2); surf(xa.x, xa.y, fB(xa, d));
%%
figure;
[fB] = fbell(100, 2, 20, 1, false);
subplot(2,1,1); surf(xa.x, xa.y, fB(xa, d));
[fB] = fbell(400, 2, 20, 1, false);
subplot(2,1,2); surf(xa.x, xa.y, fB(xa, d));
%%

%%% Complejidad de la funci�n de utilidad individual
% La complejidad se mide utilizando la Distancia de Correlaci�n (DC).
% Para calcular DC se prefijan una serie de distancias. Para cada distancia
% se genera una secuencia de pares de puntos separados a dicha distancia.
% Se calcula a continuaci�n el coeficiente de correlaci�n, de manera que
% coeficientes bajos indican rugosidad alta. Una vez se han calculado los
% coeficientes para todas las distancias se busca aquella distancia para la
% que el coeficiente se hace aproximadamente 0.5. 
%
% function [dc fnl pv] = *rugfactor*(f, ni, d, vd, ns) calcula la distancia
% de correlaci�n DC, los coeficientes de correlaci�n FNL y los p-valores PV
% de cada coeficiente (por debajo de 0.05 se pueden considerar v�lidos), de
% la funci�n F, de NI issues, dominio D, distancias VD, tomando NS puntos
% aleatorios en cada secuencia.
%
% Para fB = fbell(400, 2, 20, 1) calculamos DC como:
[dc fnl pv vd] = rugfactor(fB, 2, [0 0; 100 100], linspace(0.1, 20, 50), 1000);
sprintf('DC = %f', dc)
figure; plot(vd, fnl);

%%%
% El procedimiento *rgfmat.m* analiza DC para diferentes funciones de
% utilidad variando el n�mero de picos y la anchura de los mismos:
%
% npeaks =  2:8:512; radio = 2:4:64;
%
% El siguiente gr�fico muestra el resultado, del que se deduce que la
% complejidad depende fundamentalmente de la anchura de los picos. 
% Los datos se guardan en distcorr.mat.
open distcorr.fig;

%%

%%% Complejidad del escenario
% La complejidad del escenario en su conjunto depende de la distancia de
% correlaci�n DC de cada funci�n, ya que condiciona el n�mero de m�ximos
% locales. Es decir, DC mide la tendencia a quedar atrapado en un m�ximo
% local, pero no queda caracteriza en qu� proporci�n dichos m�ximos se
% acercan a 1 (utilidad m�xima). Por otro lado, es importante analizar la
% correlaci�n entre las funciones de utilidad de los agentes. Sin embargo,
% la correlaci�n por s�  misma tampoco es una indicaci�n de en qu� medida
% se pueden llegar a soluciones �ptimas. 
%
% Se puede dar el siguiente caso por
% ejemplo: rugosidad baja (DC alto y por tanto complejidad baja),
% correlaci�n alta de funciones de utilidad (complejidad baja a priori). El
% problema es que estos valores se pueden dar tanto para funciones de
% utilidad con muchos puntos cercanos a 1, como con muchos puntos cercanos
% a 0.
%
% La correlaci�n directa (no el coeficiente de correlaci�n), o el
% coeficiente de correlaci�n ponderado pueden ser la soluci�n. 
%
% function [x y c r xp yp] = *evfut*(f, ni, d, nst, option, modo, vrf, nsrf)
% permite evaluar un set de funciones y obtener los coeficientes de
% correlaci�n.
[fB] = fbell(400, 2, 10, 1, true);
[fS] = fbell(400, 2, 10, 1, true);
%%
plotSurfs(fB,fS,0.75,0.05)
%%
[x y c] = evfut({fB, fS}, 2, d, 100000, 2, 'rect_random');
[dcB] = rugfactor(fB, 2, [0 0; 100 100], linspace(0.1, 20, 50), 1000);
[dcS] = rugfactor(fS, 2, [0 0; 100 100], linspace(0.1, 20, 50), 1000);
sprintf('dcB = %f   dcS = %f  Corrcoef: %f  p-value: %f', dcB, dcS, c(1,2,1), c(1,2,2))
%%
% *Interpretation of the size of a correlation*
% 	
% -0.3 to -0.1 	0.1 to 0.3 Small 	
% -0.5 to -0.3  0.3 to 0.5 Medium 	
% -1.0 to -0.5 	0.5 to 1.0 Large
% 
% Several authors have offered guidelines for the interpretation of a
% correlation coefficient. I is observed, however, that all
% such criteria are in some ways arbitrary and should not be observed too
% strictly. This is because the interpretation of a correlation coefficient
% depends on the context and purposes. A correlation of 0.9 may be very low
% if one is verifying a physical law using high-quality instruments, but
% may be regarded as very high in the social sciences where there may be a
% greater contribution from complicating factors.
%
% Along this vein, it is important to remember that "large" and "small"
% should not be taken as synonyms for "good" and "bad" in terms of
% determining that a correlation is of a certain size. For example, a
% correlation of 1.0 or -1.0 indicates that the two variables analyzed are
% equivalent modulo scaling. Scientifically, this more frequently indicates
% a trivial result than a profound one. For example, consider discovering a
% correlation of 1.0 between how many feet tall a group of people are and
% the number of inches from the bottom of their feet to the top of their
% heads.
%%
% *Non-parametric correlation coefficients*
%
% Pearson's correlation coefficient is a parametric statistic and when
% distributions are not normal it may be less useful than non-parametric
% correlation methods, such as Chi-square, Point biserial correlation,
% Spearman's ?, Kendall's ?, and Goodman and Kruskal's lambda. They are a
% little less powerful than parametric methods if the assumptions underlying
% the latter are met, but are less likely to give distorted results when the
% assumptions fail.
%%
% *Other measures of dependence among random variables*
% 
% The information given by a correlation coefficient is not enough to
% define the dependence structure between random variables. The correlation
% coefficient completely defines the dependence structure only in very
% particular cases, for example when the cumulative distribution functions
% are the multivariate normal distributions. (See diagram above.) In the
% case of elliptic distributions it characterizes the (hyper-)ellipses of
% equal density, however, it does not completely characterize the
% dependence structure (for example, the a multivariate t-distribution's
% degrees of freedom determine the level of tail dependence).
% 
% To get a measure for more general dependencies in the data (also
% nonlinear) it is better to use the correlation ratio which is able to
% detect almost any functional dependency, or the entropy-based mutual
% information/total correlation which is capable of detecting even more
% general dependencies. The latter are sometimes referred to as
% multi-moment correlation measures, in comparison to those that consider
% only 2nd moment (pairwise or quadratic) dependence.
% 
% The polychoric correlation is another correlation applied to ordinal data
% that aims to estimate the correlation between theorised latent variables.
% 
% One way to capture a more complete view of dependence structure is to
% consider a copula between them.
%%
% *Correlation and linearity*
% Four sets of data with the same correlation of 0.816
% 
% While Pearson correlation indicates the strength of a linear relationship
% between two variables, its value alone may not be sufficient to evaluate
% this relationship, especially in the case where the assumption of
% normality is incorrect.
% 
% The image  in Wikipedia (correlation) shows scatterplots of Anscombe's
% quartet, a set of four different pairs of variables created by Francis
% Anscombe.[6] The four y variables have the same mean (7.5), standard
% deviation (4.12), correlation (0.816) and regression line (y = 3 + 0.5x).
% However, as can be seen on the plots, the distribution of the variables
% is very different. The first one (top left) seems to be distributed
% normally, and corresponds to what one would expect when considering two
% variables correlated and following the assumption of normality. The
% second one (top right) is not distributed normally; while an obvious
% relationship between the two variables can be observed, it is not linear,
% and the Pearson correlation coefficient is not relevant. In the third
% case (bottom left), the linear relationship is perfect, except for one
% outlier which exerts enough influence to lower the correlation
% coefficient from 1 to 0.81. Finally, the fourth example (bottom right)
% shows another example when one outlier is enough to produce a high
% correlation coefficient, even though the relationship between the two
% variables is not linear.
% 
% These examples indicate that the correlation coefficient, as a summary
% statistic, cannot replace the individual examination of the data.
%%
% *Calculating a weighted correlation*
% Suppose observations to be correlated have differing degrees of
% importance that can be expressed with a weight vector w. To calculate the
% correlation between vectors x and y with the weight vector w (all of
% length n), see Wikipedia: <http://en.wikipedia.org/wiki/Correlation>
%%
% *Conclusiones*
% No existe hasta lo que conocemos una medida de correlaci�n que se ajuste
% a nuestras necesidades. El coeficiente de Pearson es v�lido bajo la
% suposici�n de distribuciones marginales normales, que no es nuestro caso.
% Por otro lado las distribuciones no param�tricas se basan en rankings que
% desvirt�an los valores absolutos de utilidad. Finalmente otras
% alternativas como los ratios de correlaci�n o c�pulas tienen los mismos
% problemas. 
% Otra alternativa es  estudiar el problema de la M�trica Probabil�stica (Probabilistic
% Metric). Da una idea de c�mo de distantes son dos valores procedentes de dos
% variables aleatorias (pueden ser continuas). Tras analizarlo, llegamos a
% la conclusi�n de que al ser una medida de distancia, se omite el valor
% absoluto de utilidad, y �ste es fundamental es la evaluaci�n que queremos
% hacer. Planteamos por tanto otras alternativas.
%%
%%% Posibles soluciones
% 1) Teniendo en cuenta que la m�trica que vamos a utilizar para considerar la
% utilidad conjunta es el producto de utilidades o la suma de utilidades,
% parece l�gico utilizar un estad�stico de esta medida. Probamos con un
% coeficiente de correlaci�n sin restar la media, con la media y con la
% mediana.
[fB] = fbell(400, 2, 5, 1, true);
[fS] = fbell(400, 2, 5, 1, true);
[x fval] = evfut({fB, fS}, 2, [0 0;100 100], 100000, 1, 'rect_random');
%%
plotSurfs(fB{1},fS{1},1.05,0.65);
fval = fval';
%%
umb = 0.77;
selb = fval(1,:)>umb; sels = fval(2,:)>umb;
y = fval(:, selb & sels); %Prefiltrado de utilidades por umbral de reserva.
lb = sum(selb); ls = sum(sels);%Longitudes de muestras para B y S filtradas
lt = length(y); 
mapB = lt/lb; mapS = lt/ls;  %Marginal agreement probabilities
% Determinan la probabilidad de que los bids de un agente sean aceptados
% por el otro.
nashcoeff = sum(prod(y))/(sqrt(sum(y(1,:).^2))*sqrt(sum(y(2,:).^2)));
nashmean = mean(prod(y));
nashmedian = median(prod(y));
nor = norm(y(1,:)-y(2,:));%Consideramos vectores y hallamos la distancia eucl�dea.
sprintf('MeanProd: %0.2f  MedianProd: %0.2f mapB: %0.1f%% mapS: %0.1f%%', nashmean, nashmedian, mapB*100, mapS*100)
sprintf('MeanSum: %0.2f  MedianSum: %0.2f', mean(sum(y)), median(sum(y)))
% El nashcoeff no es una medida v�lida. Se puede comprobar que favorece
% valores absolutos de utilidad bajos (denominador). El problema de la
% media es no ser un estad�stico robusto cuando las distribuciones
% marginales no son normales (como es nuestro caso). La mediana es robusta
% pero es 0, y por lo tanto, no da informaci�n acerca de la verdadera
% dificultad del escenario. Por eso  realizamos un prefiltrado
% de soluciones en funci�n de la distancia de correlaci�n local y de los
% umbrales aplicados. Esto tiene sentido ya que los dos agentes en ning�n
% caso negocian con muestras por debajo de su umbral. Luego lo que hay que
% hacer es suponer que la probabilidad aleatoria de llegar a un acuerdo
% determina la complejidad del escenario de forma objetiva. La dificultad
% local de encontrar bids por encima del umbral es funci�n de la distancia
% de correlaci�n. 
%
% Esto guarda relaci�n con el problema de la m�trica probabil�stica. Se
% puede modelar cuentas iteraciones de negociaci�n se necesitan para
% aleatoriamente llegar a una soluci�n. Si un agente tiene un map 10%
% por ejemplo, podemos utilizar la funci�n de distribuci�n geom�trica para
% modelar la probabilidad de un n�mero de aciertos o fallos antes de un
% fallo o acierto respectivamente (la generalizaci�n es la distribuci�n
% binomial negativa). La funci�n densidad nos dar�a la probabilidad de un n�mero de
% iteraciones de negociaci�n fallidas antes de un acierto. Lo que queremos
% hallar en realidad es la probabilidad de que se necesiten un n�mero mayor
% o menor predeterminado de iteraciones. El siguiente ejemplo calcula la
% probabilidad de que se necesiten niters o menos iteraciones para llegar a un acuerdo
% para unos mapB y mapS.

% La probabilidad de que en una iteraci�n negociadora se alcance un acuerdo
% es (se entiende por  iteraci�n que un agente env�a un bid y otro agente env�a otro):
ap = 1-(1-mapB)*(1-mapS); % (1 - Probabilidad de que no se alcance 
                                                               % acuerdo
                                                               % con ninguna de las dos bids)
niters = 50;
geocdf(niters-1, ap)*100
% Sin embargo, es m�s elegante fijar una probabilidad (p.ej el 95%), de
% manera que lo que buscamos es calcular el n�mero de iteraciones de
% negociaci�n necesarias para alcanzar un acuerdo con una probabilidad del
% 95%.
geoinv(0.95, ap)
% 
% Estamos asumiendo que los agentes muestrean el espacio de manera
% uniforme. Sin embargo, en la realidad los agentes buscar�n m�ximos
% locales. De esta manera el n�mero de iteraciones ser� mayor a medida que
% subamos el umbral y a medida que los agentes sean m�s estrictos con el
% proceso de maximizaci�n local para emitir bids. No en vano, si se buscan
% m�ximos locales con gran precisi�n, el espacio intersecci�n se hace m�s
% peque�o. Se puede generar una tabla que muestre la evoluci�n del n�mero
% de iteraciones necesarias en funci�n los umbrales elegidos:
%%
npi = 0;
radi = 0;
umb = 0.1:0.2:0.9;
le = length(umb);
npeaks = 100:100:400;
nrads = 5:5:20;
for np = npeaks
    npi = npi+1;
    radi = 0;
    for rad = nrads
        radi = radi+1;
        [fB] = fbell(np, 2, rad, 1, true);
        [fS] = fbell(np, 2, rad, 1, true);
        [x fval] = evfut({fB, fS}, 2, [0 0;100 100], 100000, 1, 'rect_random');
        fval = fval';
        for i=1:le
            selb{i} = fval(1,:)>umb(i);
            exper(radi, npi).stats.yb{i} = fval(:, selb{i});
            sels{i} = fval(2,:)>umb(i);
            exper(radi, npi).stats.ys{i} = fval(:, sels{i});
        end
        for i=1:le
            for j=1:le
                y = fval(:, selb{i} & sels{j}); %Prefiltrado de utilidades por umbral de reserva.
                exper(radi, npi).stats.y{i,j} = y;
                exper(radi, npi).stats.py{i,j} = prod(y);
                lb = sum(selb{i}); ls = sum(sels{j});%Longitudes de muestras para B y S filtradas
                lt = length(y); 
                mapB = lt/lb; mapS = lt/ls;  %Marginal agreement probabilities
                exper(radi, npi).stats.mean(i,j) = mean(prod(y));
                exper(radi, npi).stats.median(i,j) = median(prod(y));
                exper(radi, npi).stats.norm(i,j) = norm(y(1,:)-y(2,:));%Consideramos vectores y hallamos la distancia eucl�dea.
                exper(radi, npi).stats.agprob(i,j) = 1-(1-mapB)*(1-mapS); %probabilidad de agreement 'p'. Para hallar el intervalo de confianza: [p c] = binofit(agprob*nsamples, nsamples)
                exper(radi, npi).stats.nit(i,j) = geoinv(0.95, exper(radi, npi).stats.agprob(i,j))+1; %sumo 1 porque me interesa el n�mero de rounds, no el n�mero de fallos
                [exper(radi, npi).stats.nitmean(i,j) exper(radi, npi).stats.nitvar(i,j)] =  geostat(exper(radi, npi).stats.agprob(i,j));
                exper(radi, npi).stats.nitmean(i,j) = exper(radi, npi).stats.nitmean(i,j) + 1;
            end
        end
        exper(radi, npi).title = ['Peaks = ' num2str(np) ' Rad = ' num2str(rad)];
        exper(radi, npi).rad = rad;
        exper(radi, npi).np = np;
        exper(radi, npi).umb = umb;
    end
end
%%
% Resultados de N�mero de Iteraciones  que garantizan acuerdo al 95% �
% N�mero de iteraciones * (1-mean) (Factor de Complejidad)
subplot(4,4,1);
npeaks = 100:100:400;
nrads = 5:5:20;
sp = 0;
map = colormap(gray);
map = map(size(map,1):-1:1,:); %inversi�n del mapa de colores
colormap(map);
caxis('manual');

for i=1:length(nrads)
    for j=1:length(npeaks)
        sp = sp+1;
        subplot(4,4,sp);
        %surf(umb,umb, log2(exper(i,j).stats.nit));view(2);
        surf(umb,umb, (exper(i,j).stats.nit).*(1-exper(i,j).stats.mean));view(2);
        %surf(umb,umb, exper(i,j).stats.agprob.*exper(i,j).stats.mean);view(2);
        set(gca,'xtick',[],'ytick',[]);
        if j==1
            set(gca,'ytickmode','auto');
        end
        if i==4
            set(gca,'xtickmode','auto');
        end
        caxis([0 5]);%Para iteraciones por debajo de 2^0 se fija color blanco. 
                                % Para iteraciones por encima de 2^9 se
                                % fija color negro.
        grid off;
    end
end

%%
% Mean
subplot(4,4,1);
npeaks = 100:100:400;
nrads = 5:5:20;
sp = 0;
map = colormap(gray);
map = map(size(map,1):-1:1,:); %inversi�n del mapa de colores
colormap(map);
caxis('manual');

for i=1:length(nrads)
    for j=1:length(npeaks)
        sp = sp+1;
        subplot(4,4,sp);
        surf(umb,umb, exper(i,j).stats.mean);view(2);
        set(gca,'xtick',[],'ytick',[]);
        if j==1
            set(gca,'ytickmode','auto');
        end
        if i==4
            set(gca,'xtickmode','auto');
        end
        caxis([0 1]);
        grid off;
    end
end
%%
% Teniendo en cuenta que a lo largo de las filas (radio de campanas), los
% gr�ficos son similares, y que adem�s el DC cambia en funci�n del radio,
% lo mejor es centrarse en una columna (npeaks) concreta. De todas, la m�s
% interesante es la de 400 picos, en la que gr�ficamente se observa un
% mayor margen de maniobra a la hora de variar los umbrales de reserva de
% los agentes. Nos quedamos finalmente con 400 peaks, rad 5, y 400 peaks,
% rad 20. Para los dos casos, analizamos todas las combinaciones de
% umbrales. Hay que tener en cuenta los casos en los que no hay acuerdo
% posible, es decir, los elementos donde el n�mero de iteraciones 95% es
% NaN. En estos casos no realizamos negociaci�n. Los umbrales utilizados
% ahora tras probar varias alternativas, y para evitar la aparici�n de no
% intersecciones de espacios es: 0.15 0.3 0.45 0.65. Las funciones bell y
% resultados exper est�n almacenados en fBS_400p_5r_20r.mat
%
%%
clear all; 
npi = 0;
radi = 0;
umb = [0.15 0.3 0.45 0.65];
le = length(umb);
npeaks = 400;
nrads = [5 20];
for np = npeaks
    npi = npi+1;
    radi = 0;
    for rad = nrads
        radi = radi+1;
        fB{radi} = fbell(np, 2, rad, 1, true);
        fS{radi} = fbell(np, 2, rad, 1, true);
        [x fval] = evfut({fB{radi}, fS{radi}}, 2, [0 0;100 100], 100000, 1, 'rect_random');
        fval = fval';
        for i=1:le
            selb{i} = fval(1,:)>umb(i);
            exper(radi, npi).stats.yb{i} = fval(:, selb{i});
            sels{i} = fval(2,:)>umb(i);
            exper(radi, npi).stats.ys{i} = fval(:, sels{i});
        end
        for i=1:le
            for j=1:le
                y = fval(:, selb{i} & sels{j}); %Prefiltrado de utilidades por umbral de reserva.
                exper(radi, npi).stats.y{i,j} = y;
                exper(radi, npi).stats.py{i,j} = prod(y);
                lb = sum(selb{i}); ls = sum(sels{j});%Longitudes de muestras para B y S filtradas
                lt = length(y); 
                mapB = lt/lb; mapS = lt/ls;  %Marginal agreement probabilities
                exper(radi, npi).stats.mean(i,j) = mean(prod(y));
                exper(radi, npi).stats.median(i,j) = median(prod(y));
                exper(radi, npi).stats.norm(i,j) = norm(y(1,:)-y(2,:));%Consideramos vectores y hallamos la distancia eucl�dea.
                exper(radi, npi).stats.agprob(i,j) = 1-(1-mapB)*(1-mapS); %probabilidad de agreement 'p'. Para hallar el intervalo de confianza: [p c] = binofit(agprob*nsamples, nsamples)
                exper(radi, npi).stats.nit(i,j) = geoinv(0.95, exper(radi, npi).stats.agprob(i,j))+1; %sumo 1 porque me interesa el n�mero de rounds, no el n�mero de fallos
                [exper(radi, npi).stats.nitmean(i,j) exper(radi, npi).stats.nitvar(i,j)] =  geostat(exper(radi, npi).stats.agprob(i,j));
                exper(radi, npi).stats.nitmean(i,j) = exper(radi, npi).stats.nitmean(i,j) + 1;
            end
        end
        exper(radi, npi).title = ['Peaks = ' num2str(np) ' Rad = ' num2str(rad)];
        exper(radi, npi).rad = rad;
        exper(radi, npi).np = np;
        exper(radi, npi).umb = umb;
    end
end
%%
% Resultados de N�mero de Iteraciones para 400-5 y 400-20
subplot(2,1,1);
umb = [0.15 0.3 0.45 0.65];
npeaks = 400;
nrads = [5 20];
sp = 0;
map = colormap(gray);
map = map(size(map,1):-1:1,:); %inversi�n del mapa de colores
colormap(map);
caxis('manual');

for i=1:length(nrads)
    for j=1:length(npeaks)
        sp = sp+1;
        subplot(2,1,sp);
        surf(umb,umb, log2(exper(i,j).stats.nit));view(2);
        %surf(umb,umb, (exper(i,j).stats.nit).*(1-exper(i,j).stats.mean));view(2);
        %surf(umb,umb, exper(i,j).stats.agprob.*exper(i,j).stats.mean);view(2);
        set(gca,'xtick',[],'ytick',[]);
        if j==1
            set(gca,'ytickmode','auto');
        end
        if i==2
            set(gca,'xtickmode','auto');
        end
        caxis([0 8]);
        grid off;
    end
end


        