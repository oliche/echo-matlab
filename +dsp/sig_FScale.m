function F=sig_FScale(nech,si)
dF=(1/nech);
F=dF*[0 1:((nech)/2) -fliplr((1:nech/2-.25))].'/si;
