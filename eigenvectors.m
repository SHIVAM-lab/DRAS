function [answer] = eigenvectors(A)
for j=1:size(A,3)
for i=1:10000
    if i==10000
        error('Matrix A has been squared 10000 times, and has not converged')
    end
    if i==1
    A(:,:,j) = A(:,:,j)^2;
    B(:,:,j) = sum(A(:,:,j)'); 
    C(:,:,j) = sum(B(:,:,j));
    E(:,:,i,j) = B(:,:,j)/C(:,:,j);
    iteration(:,:,1,j) = E(:,:,1,j);
    end
    
    if i>1
    A(:,:,j) = A(:,:,j)^2;
    B(:,:,j) = sum(A(:,:,j)'); 
    C(:,:,j) = sum(B(:,:,j));
    E(:,:,i,j) = B(:,:,j)/C(:,:,j);
    iteration(:,:,i,j) = E(:,:,i,j);
    if sum(abs(iteration(:,:,i,j) - iteration(:,:,i-1,j)) )<= (1e-6);
        break;
    end
    end
    answer(:,:,j)=iteration(:,:,i,j);
end
end
end