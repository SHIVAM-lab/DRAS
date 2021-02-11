function [A,CR] = consistency(A)
eigenvalue = eig(A);
maxeigen = max(eigenvalue);
n = length(A);
eigenvector = eigenvectors(A);

if n==3
    RI = 0.52;
elseif n==4
    RI = 0.89;
elseif n==5
    RI = 1.11;
elseif n==6
    RI = 1.25;
elseif n==7
    RI = 1.35;
elseif n==8
    RI = 1.4;
elseif n==9
    RI = 1.45;
elseif n==10
    RI = 1.49;
elseif n==11
    RI = 1.51;
elseif n==12
    RI = 1.54;
elseif n==13
    RI = 1.56;
elseif n==14
    RI = 1.57;
else
    RI = 1.58;
end
CI = abs((maxeigen-n))/(n-1);
CR = CI/RI;

for m=1:1000
    if (n==3 && CR>0.05)
    for i=1:n
        for j=1:n
            Y(i,j) = A(i,j)*eigenvector(j)/eigenvector(i);
        end
    end
Y = round(Y*1e4) / 1e4;

l=find(Y(:)==max(Y(:)));
[r,c]=ind2sub(size(Y),l);

for i=1:length(r)
    
A(r(i),c(i))=eigenvector(r(i))/eigenvector(c(i));
    
end

eigenvector = eigenvectors(A);

eigenvalue = eig(A);
maxeigen = max(eigenvalue);
RI = 0.52;
CI = abs((maxeigen-n))/(n-1);
CR = CI/RI;
    end
end


for m =1:1000
    if (n==4 && CR>0.08)
    for i=1:n
        for j=1:n
            Y(i,j) = A(i,j)*eigenvector(j)/eigenvector(i);
        end
    end
Y = round(Y*1e4) / 1e4;

l=find(Y(:)==max(Y(:)));
[r,c]=ind2sub(size(Y),l);

for i=1:length(r)
    
A(r(i),c(i))=eigenvector(r(i))/eigenvector(c(i));
    
end
eigenvalue = eig(A);
maxeigen = max(eigenvalue);
n = length(A);
eigenvector = eigenvectors(A);
RI = 0.89;
CI = abs((maxeigen-n))/(n-1);
CR = CI/RI;
end
end


for m=1:1000
    if (n>=5 && CR>0.1)
    for i=1:n
        for j=1:n
            Y(i,j) = A(i,j)*eigenvector(j)/eigenvector(i);
        end
    end
Y = round(Y*1e4) / 1e4;

l=find(Y(:)==max(Y(:)));
[r,c]=ind2sub(size(Y),l);

for i=1:length(r)
    
A(r(i),c(i))=eigenvector(r(i))/eigenvector(c(i));
    
end
eigenvalue = eig(A);
maxeigen = max(eigenvalue);
n = length(A);
eigenvector = eigenvectors(A);
if n==5
    RI = 1.11;
elseif n==6
    RI = 1.25;
elseif n==7
    RI = 1.35;
elseif n==8
    RI = 1.4;
elseif n==9
    RI = 1.45;
elseif n==10
    RI = 1.49;
elseif n==11
    RI = 1.51;
elseif n==12
    RI = 1.54;
elseif n==13
    RI = 1.56;
elseif n==14
    RI = 1.57;
else
    RI = 1.58;    
end
CI = abs((maxeigen-n))/(n-1);
CR = CI/RI;
end
end
end
