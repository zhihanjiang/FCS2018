clear all;
load('AGP');
load('NPS');
sm = length(find(NPS>=300));%һ��10����30��300����ɸѡ����
mid = find(NPS>=300);
idx = kmeans(AGP,5,'rep',10);
lables = idx';
L = zeros(77,68);
L(mid)=lables;
save('L',L)
imagesc(L)
grid on