%% load data
clc; clear; close all;
% load('SMS_IN'); load('SMS_OUT'); load('SMS');
% load('CALL_IN'); 
% load('CALL_OUT'); 
% load('CALL');
% load('INTERNET');
% load('S');
load('PS');
load('DS');

sm = length(find(PS>=3600));
[i,j] = find(PS>=3600);
M = 1;
coord = [i';j'];
grids = zeros(sm,24*7);

for N =1:sm
    x = coord(M,N);
    y = coord(M+1,N);
    c = squeeze(DS(x,y,:));
    c = c';
    sum1 = [];
    for n = 1:2:1439
        sum1 = [sum1 c(1,n)+c(1,n+1)];
    end
    sum2 = sum1(:,4*24+1:4*24+24*7*3);
    sum2 = mean(reshape(sum2',24*7,3),2);
    m = sum2';
    grids(N,:)=m;
end
Grids = grids(:,1:24*7);
imagesc(Grids)

% Ng = 10000; Nt = 6*24*62; Nh = Nt/6;%Ng��ʾ100*100�����ӣ�Nh��ʾ�����¹��ж���Сʱ
% Nm = sum(S);%�Ծ���S��ÿ����͡�Nm��ʾ��182����վ��SΪ������


%% select Milano metropolitan areas
mid = find(PS>=3600);%�ҵ�����S�з�0Ԫ�ص�λ�ã�midΪ������
% M = INTERNET(mid,:);


%%
% clc;close all;
% m1 = M(999,:); m2 = M(1000,:); m3 = M(1001,:);
% mfigure();
% subplot(3,1,1);     plot(m1);
% subplot(3,1,2);     plot(m2);
% subplot(3,1,3);     plot(m3);


%% aggregate by hour and extract 8 good weeks
% H = squeeze(sum(reshape(M,Nm,6,Nh),2));%sum(A,2)������ÿ�еĺ͡�6������
% H = H(:,24*3+1:24*3+24*7*8);%HΪNm*��24*8�ܣ�


%% training data: first 4 weeks, as a typical week
% W = H(:,1:24*7*4);         % WΪNm*��24*7*4 ��
% W = mean(reshape(W,Nm,24*7,4),3);%WΪNm*��24*7����ÿһ�����ӵ���ֵ����4�ܶ�Ӧʱ��ľ�ֵ
% imagesc(W);


%% random grid traffic pattern
clc;close all;
g = Grids(randi(sm),:);%randi��Nm����ʾ1��Nm�е�����һ����
clc; close all; figure('Position',[500,500,400,200]);%ͼ�񴰿ڵ�λ�ü����С��500,500��ʾ��ʼ���꣬400��ʾ��200��ʾ��
plot(g,'g','LineWidth',2);
xlim([1,168]); axis tight;
ax = gca; ax.XTick = 1:24:168; 
ax.XTickLabel = {'MON','TUE','WED','THU','FRI','SAT','SUN'};
grid on; set(gca,'FontSize', 15);


%% prepare distance matrix
Ng = 154*136;
[X,Y] = ind2sub([154,136],1:Ng);%��100*100�ľ����е�ÿ��Ԫ�ص�����ת��Ϊ���꣬I��ʾ�У�J��ʾ��.I��J��Ϊ������
GEODIST = squareform(pdist([Y',X']));
GEODIST = GEODIST(mid,mid);%GEODISTΪNm*Nm�ľ������
imagesc(GEODIST);


%% prepare similarity matrix
SIMDIST = (1 + corr(Grids'))/2;
SIMDIST(GEODIST==0) = 0;        %SIMDISTΪNm*Nm�����ϵ�������ҶԽ���Ԫ��Ϊ0�� remove self-loop
imagesc(SIMDIST); colorbar();


%% GCLP algorithm
clc;tic;
Nl = 10; Nc = 4;
DTHRES = sqrt(2*Nc*Nc);           % 1km range
C = randperm(sm);               % CΪ1��Nm��Nm��������֣�Ϊ��������random initialization of labels
for lc = 1:Nl
    C0 = C;%������
    L = randperm(sm);%LΪ1��Nm�������Nm���������磺1,4,3,7,9��Nm.....2.LΪ������
    for i = 1:sm
        n = L(i);
        [a,~,c] = unique(C);%aΪC�в��ظ���Ԫ�أ���С�������У���c��ʾC��Ԫ����c�е�λ��
        dmax = accumarray(c,GEODIST(n,:),[],@max);%dmax��cһ������������GEODIST(n,:)Ϊ��������ÿһ��Ԫ�ذ�c��Ԫ�ص�ֵ������λ�á�
        aff = accumarray(c,SIMDIST(n,:));
        gain = aff.*log(DTHRES./dmax);
        [v,k] = max(gain);%����������[v,k]��vΪ��������ÿһ��Ԫ�ش���gain��ÿ��Ԫ�ص����ֵ��kΪ��������ÿһ��Ԫ�ش���ÿ�����Ԫ�����ڵ�������
%         [v,k] = max(aff);
        C(n) = a(k);
    end
    disp([num2str(lc),': ',num2str(length(aff))]);%num2str(lc)��1c�е�����ת��Ϊ�ַ�����ת�������fprintf����disp�������������
    if C0 == C 
        break
    end
end
toc;
save('C','C');


%% display clusters
load('C');
F = zeros(154,136);
F(mid) = C;%��C�е�Ԫ��һ�η���midֵ��λ�ô������磺mid=45��48��50��C =[1,3,2],�Ͱ�C�е�1����G�е�45λ��3�ŵ�48λ��2�ŵ�50λ
%F = rot90(F);%��G������ʱ����ת90��
clc; close all; figure('Position',[500,500,500,500]);
imagesc(F);
axis off;


%% test grid and cluster traffic
% clc; close all;
% mfigure();
% % grid 5738: san siro
% h = H(mid==5738,:);
% subplot(2,1,1);
% plot(h);
% ax = gca; ax.XTick = 1:24*7:24*7*8; ax.XTickLabel = 1:7*8;
% xlabel('day'); ylabel('traffic');
% grid on; axis tight; set(gca,'FontSize', 17);
% % 1962: san siro
% h = sum(H(C==1962,:));
% subplot(2,1,2);
% plot(h);
% ax = gca; ax.XTick = 1:24*7:24*7*8; ax.XTickLabel = 1:7*8;
% xlabel('week'); ylabel('traffic'); 
% grid on; axis tight; set(gca,'FontSize', 20);
% ylim([0,3e4]);
% 
% 
% %% 2105: duomo
% clc; close all;
% h = sum(H(C==2105,1:24*7*4));
% h = reshape(h,24,7*4);
% figure('Position',[100,500,600,400]);
% imagesc(h); colorbar();
% ax = gca; ax.XTick = 1:7:7*4; ax.XTickLabel = 1:4;
% % ax = gca; ax.YTick = 1:2:24;
% xlabel('week'); ylabel('hour'); set(gca,'FontSize', 22);