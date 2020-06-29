clear all;

load('NPS');
load('NDS');
sm = length(find(NPS>=300));%һ��10����30��300����ɸѡ����
[i,j] = find(NPS>=300);
mid = find(NPS>=300);
M = 1;
Ncoord = [i';j'];
Ngrids = zeros(sm,24*7);


for N =1:sm
    x = Ncoord(M,N);
    y = Ncoord(M+1,N);
    c = squeeze(NDS(x,y,:));
    c = c';
    sum1 = [];
    for n = 1:2:1439
        sum1 = [sum1 c(1,n)+c(1,n+1)];
    end
    sum2 = sum1(:,4*24+1:4*24+24*7*3);
    sum2 = mean(reshape(sum2',24*7,3),2);
    m = sum2';
    Ngrids(N,:)=m;
end
AGP = Ngrids(:,1:24*7);%AGP��ʾ���и��Ե����ԣ�all grids profil
save('AGP','AGP');
csvwrite('AGP.csv',AGP);