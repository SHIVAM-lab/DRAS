function [W]= lsm(A,t1,t,runtime,wattage,prices,RRTP)

T = t/60;
t1=t1./T;
t1(1)=t1(1)*T;
m=1:24*(T^-1);
NoM = 24/t*60;
n = size(A,1);
%Checking and improving consistency for the matrices input
for i=1:size(A,3)
    [A(:,:,i),CR(i)] = consistency(A(:,:,i));
end

%Initializing NoM number of unit matrices
for j = 1:NoM
       I(:,:,j)=eye(n);
end


%Copying upper diagonal elements of A into temp
ind=1;
k=1;
p=size(A);
for i=1:n
   for j=1:n
       if i~=j && i<j
           index1(1,ind) = i;
           index2(1,ind) = j;
           ind=ind+1;
           for r=1:p(3)
              temp(k,r) = A(i,j,r);
           end
           k=k+1;
       end
    end
end

%%%%Applying Pchip%%%%
q=size(temp);
for i=1:q(1)
    one(i) = pchip(t1,temp(i,:));
end

%%%%Storing the coefficient matrices in b %%%%%
for k=1:length(one)
       for i=1:size((one(k).coefs),1)
          b(i,1:4,k) = one(k).coefs(i,1:4);
       end
end


%%%% Substituting timestep values in the coefficient matrix%%%%%
for i=1:length(one)
     a(1,1:NoM,i)=pchip(t1,temp(i,:),m);
end
 


%Copying upper diagonal elements in the unit matrix
k=1;
for i=1:n
   for j=1:n
       if i~=j && i<j
           I(i,j,1:NoM) = a(1,1:NoM,k);
           if k<3
               k=k+1;
           end
       end
    end
end

%Copying lower diagonal elements in the unit matrix
k=1;
for i=1:n
   for j=1:n
       if i~=j && i>j
           I(i,j,1:NoM) = 1./(a(1,1:NoM,k));
             if k<3
               k=k+1;
             end
       end
    end
end


for i=1:length(t1)
I(:,:,t1(i))= A(:,:,i);
end


%%%%%Improving consistency for all the newly created matrices%%%%%
for i=1:size(I,3)
    [W(:,:,i),CR(i)] = consistency(I(:,:,i));
end

%%%%Finding Moving average priorities%%%%%
priority = eigenvectors(W);
final = permute(priority, [3 2 1]);
for j=1:n
  for i=1:length(final)-(runtime(j)-1)
    avg(j,i)=(1/runtime(j))*sum(final(i:i+(runtime(j)-1),j));
  end
end

%%%%%Interpolating DAY_AHEAD hourly prices for every timestep(15 mins)%%%%
k = 1/T;
for i=1:length(prices)
    if i==1
        for j=1:i+(k-1)
            DAprices(j)=prices(i);
        end
    else
        for j=j+1:i*k
            DAprices(j)=prices(i);
            if j==length(prices)*k
                break;
            end
        end
    end
end

%%%%%Interpolating REAL TIME hourly prices for every timestep(15 mins)%%%%
k = 1/T;
for i=1:length(RRTP)
    if i==1
        for j=1:i+(k-1)
            actualprices(j)=RRTP(i);
        end
    else
        for j=j+1:i*k
            actualprices(j)=RRTP(i);
            if j==length(RRTP)*k
                break;
            end
        end
    end
end

%%%%%Plot for Real time hourly Prices%%%%
figure; plot((0:length(DAprices)-1)*T,DAprices);
axis tight; 
str=sprintf('Day ahead prices for every 15 mins') ;
title(str,'FontSize', 12),
xlabel('Hour of the day (hr)', 'FontSize', 12),ylabel('Prices in cents', 'FontSize', 12)

%%%%%%%Normalization%%%%%%%%%
A=min(DAprices);B=max(DAprices);
NDAprices=(DAprices-A)/(B-A);
InvNDAprices=1-NDAprices;
for i=1:size(avg,1)
   Y(i)=min(avg(i,:)); Z(i)=max(avg(i,:));
   Navg(i,:)=(avg(i,:)-Y(i))./(Z(i)-Y(i));
end

%%%%%Plot for Inverted Real time hourly Prices%%%%
figure; plot((0:length(InvNDAprices)-1)*T,InvNDAprices);
axis tight; 
str=sprintf('Inverted prices after normalization') ;
title(str,'FontSize', 12),
xlabel('Hour of the day (hr)', 'FontSize', 12),ylabel('Inverted Prices after normalization', 'FontSize', 12)

%%%%%Finding Load rankings after combining normalized moving average priorities and inverted prices%%%%%%
 for i = 1:n
    for j=1:length(Navg)
       LoadRankings(i,j) = (Navg(i,j) + InvNDAprices(1,j));
    end
 end
figure; plot((0:length(LoadRankings)-1)*T,LoadRankings(:,:));
axis tight; 
str=sprintf('Load priorities and prices combined') ;
title(str,'FontSize', 12),
xlabel('Hour of the day (hr)', 'FontSize', 12),ylabel('Load rankings after normalization', 'FontSize', 12) 
for z=1:n
    leg{z}=strcat('Load',num2str(z));
end
legend(leg);

for i=1:n
     Loadpeak(i,:)=find(LoadRankings(i,:)==max(LoadRankings(i,:)))*T;
     Loadpeak(i,:)=Loadpeak(i,:)-T;
     cost(i) = wattage(i)*(runtime(i)*T)* (actualprices(1,Loadpeak(i,:)/T));
     fprintf('\nLoad %d is scheduled to run at hour %1.2f, for a runtime of %1.2f hours at a cost of %1.2f cents \n',i,Loadpeak(i,1),runtime(i)*T,cost(i))
     dayaheadcost = wattage(i)*(runtime(i)*T)* (DAprices(1,Loadpeak(i,:)/T));
     fprintf('Day-ahead cost (Expected earlier) = %1.2f\n',dayaheadcost)
end

P = linspace(t/60,24,NoM);
figure; plot(P,final);
axis tight; title('Load Priorities throughout the day', 'FontSize', 12),
xlabel('Hour of the day (hr)', 'FontSize', 12),ylabel('AHP priority ranking', 'FontSize', 12),
for i=1:n
    leg{i}=strcat('Load', num2str(i));
end
legend(leg);


PWC = permute(a, [3 2 1]);
figure; plot(P,PWC); axis tight;
title('Pairwise comparison matrices elements as a function of time', 'FontSize', 12),
xlabel('Time(hours)', 'FontSize', 12), ylabel('Magnitude', 'FontSize', 12), 
for i=1:length(index1)
    leg{i}=strcat('a', num2str(index1(i)),num2str(index2(i)));
end
legend(leg);

figure; plot((1:length(avg))*T,Navg);
axis tight;title('Normalized moving average priorities of loads', 'FontSize', 12),
xlabel('Hour of the day (hr)', 'FontSize', 12),ylabel('AHP priority ranking', 'FontSize', 12),
for i=1:n
    leg{i}=strcat('Load', num2str(i));
end
legend(leg);

end