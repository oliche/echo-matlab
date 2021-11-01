function [MaxiTps,MaxiVal] = sig_Pick(X)
%  [MaxiTps,MaxiVal] = sig_Pick(X)

%X=[1 2 -1 1 3 .9 1;1 2 -1 1 3 1 1;0 1 2 -1 1 3 .8 ;4 4 1 1 3 .8 1;4 2 1 1 3 .8 1;;4 2 1 1 3 .8 6;;4 2 1 1 3 7 7]';
[~,ind]=max(X);
[nech,ntr]=size(X);
%Gestion des maximum en debut ou fin de trace (si la 2eme valeur est egal à
% a la premiere valeur et que c'est un max on met le max en 2eme
% echantillon
Sel1=ind==1 & X(1,:)~=X(2,:);
ind(ind==1 & X(1,:)==X(2,:))=2; 
Sel2=ind==nech;


MaxiTps=zeros(1,ntr)*NaN;
MaxiVal=zeros(1,ntr)*NaN;
MaxiTps(Sel1)=0;
MaxiVal(Sel1)=X(1,Sel1);
MaxiTps(Sel2)=nech-1;
MaxiVal(Sel2)=X(end,Sel2);

IND=[ind-1;ind;ind+1];
IND=IND+size(X,1)*repmat(0:(size(X,2)-1),3,1);

SelCompute=~Sel1 & ~Sel2;
X=X(IND(:,SelCompute));


%Polynomial interpolation pol = a,b,c avec ax2+bx+c=0
%inv([1 -1 1;0  0 1;1  1 1])=[0.5 -1. 0.5;-0.5 0  0.5;0 1 0].......
%G*(pol)=X donc pol=InvG*X
% Le maximum est atteint lorsque la dérivée du polynome est nulle donc 
InvG=[0.5 -1. 0.5;-0.5 0  0.5;0 1 0];
pol=InvG*X;

tempTps = -pol(2,:)./(pol(1,:)+double(pol(1,:)==0))/2;
tempVal = (pol(3,:)+tempTps.*pol(2,:)+tempTps.^2.*pol(1,:));

MaxiTps(SelCompute) =tempTps + ind(SelCompute)-1;        
MaxiVal(SelCompute) =tempVal;        
