clc;close all;
load('NDS');

i =[50,51,49,49];
j =[57,57,28,27];
M = 1;
Ncoord = [i;j];
Ngrids = zeros(4,24*7);

for N =1:4
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
NGrids = Ngrids';
csvwrite('NGrids.csv',NGrids);



% g = NGrids(3,:);%randi��Nm����ʾ1��Nm�е�����һ����
% clc; close all; 
% figure('Position',[500,500,400,200]);%ͼ�񴰿ڵ�λ�ü����С��500,500��ʾ��ʼ���꣬400��ʾ��200��ʾ��
% plot(g,'g','LineWidth',2);
% xlim([1,168]);
% axis tight;
% ax = gca;
% ax.XTick = 1:24:168; 
% ax.XTickLabel = {'MON','TUE','WED','THU','FRI','SAT','SUN'};
% grid on; 
% set(gca,'FontSize', 15);

