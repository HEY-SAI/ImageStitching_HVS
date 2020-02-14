%only for RGB image homography
 clc;
clear all;
close all

f = 'jian';
ext = 'jpg';
img1 = imread([f '1.' ext]);
img2 = imread([f '2.' ext]);


% H = [    1.0354    0.0241         0
%    -0.0058    1.0538         0
%    40.9300  -55.5326    1.0000];%%%tu1
% H = [    0.9973   -0.0116         0
%     0.0229    0.9754         0
%    50.0256  -24.0130    1.0000];%%%dhԭʼ����
% 
% H = [    0.9973   -0.0116         0
%     0.0229    0.9854         0
%    50.0256  -26.0130    1.0000];%%%dh�Ĳ���
%  H = [ 1.0395   -0.0026         0
%    -0.0340    1.0181         0
%   126.4352  -38.7236    1.0000];%%%hg

%  H = [ 0.9856   -0.0296         0
%     0.0323    0.9988         0
%    12.8007  -36.2664    1.0000];%%%9lou
% 
%  H = [ 1.1760    0.0155         0
%     0.0200    1.1694         0
%    12.7816  -66.2034    1.0000];%%%build
% H = [ 1.0687    0.0112         0
%    -0.0180    1.0826         0
%    90.7917  -27.4238    1.0000];%%%dl
% H = [    0.9932    0.0002         0
%     0.0197    1.0146         0
%    48.1505  -29.0500    1.0000];%%%tj
% H = [   0.9489    0.0039         0
%    -0.0358    0.9666         0
%   263.3049   -5.7935    1.0000];%%%xiao

% H = [ 0.9853         0         0
%     0.0163    0.9880         0
%    70.0556   -8.0000    1.0000];%%%hu

% H = [ 0.9853         0         0
%     0.0163    1.0000         0
%    70.0556   -8.0000    1.0000];%%%hu_yuanshi
% 
H = [    0.9590    0.0137         0
   -0.0318    0.9750         0
  145.9796   -6.8725    1.0000];%% jian 12�޸ķ������
% H = [    0.9590    0.0137         0
%    -0.0318    0.9686         0
%   145.9796   -4.1725    1.0000];%% jian 12ԭʼ�������
% H = [0.9549    0.0105         0
%    -0.0377    0.9623         0
%    73.7390   -1.4277    1.0000];%%scale 12�������

% H = [ 1.0140    0.0074         0
%    -0.0295    1.0255         0
%    49.9593  -84.7181    1.0000];%%%dweiheԭʼ����
% H = [ 1.0140    0.0074         0
%    -0.0295    1.0300         0
%    52.5593  -85.7181    1.0000];%%%dweihe�޸Ĳ���

 
img2_change = rgb2gray(img2) + 10;
     
tform = maketform('affine',H);
img21 = imtransform(img2,tform);    %%���κ�ͼ2

img22 = imtransform(img2_change,tform);%%��֤��Ч������0ֵ

[M1 N1 dim1] = size(img1);
[M2 N2 dim2] = size(img2);
% do the mosaic
pt = zeros(4,3);
pt(1,:) = [1 1 1]*H;
pt(2,:) =[N2 1 1]* H;
pt(3,:) = [N2 M2 1]*H;
pt(4,:) = [1 M2 1]*H;%�ĸ�����λ��,������˳ʱ�롣

k12 = (pt(1,2)-pt(2,2))/(pt(1,1)-pt(2,1));%%�غ�����߽�б��
k23 = (pt(3,2)-pt(2,2))/(pt(3,1)-pt(2,1));
k34 = (pt(4,2)-pt(3,2))/(pt(4,1)-pt(3,1));
k14 = (pt(1,2)-pt(4,2))/(pt(1,1)-pt(4,2));


gray1= rgb2gray(img1);
gray2= rgb2gray(img21);

% figure,
% imshow(gray2);

edge1 = edge(gray1,'canny');%ͼ1canny�㷨��⵽�ı߽�
edge2 = edge(gray2,'canny');%ͼ2����任��canny�㷨��⵽�ı߽�

% figure,
% imshow(edge2);

double_gray1 = double(gray1);
double_gray2 = double(gray2);



x2 = pt(:,1)./pt(:,3);
y2 = pt(:,2)./pt(:,3);


up = round(min(y2));
Yoffset = 0;
if up <= 0
	Yoffset = -up+1;
	up = 1;
end

left = round(min(x2));
Xoffset = 0;
if left<=0
	Xoffset = -left+1;
	left = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%����%%%%%%%%%%%%%%%%%%%%%%%%%%%
img1(:,:,1) = img1(:,:,1) - 1.32;
img1(:,:,2) = img1(:,:,2) + 0.5;
img1(:,:,3) = img1(:,:,3) + 2.2;
img1 = uint8(img1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M3 N3 dim3] = size(img21);
imgout(up:up+M3-1,left:left+N3-1,:) = img21;
imgout(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = img1;

imgout = uint8(imgout);

figure,imshow(imgout), title('ֱ���ں�');

gray_imgout = rgb2gray(imgout);

%%���غ���������

[m,n] = size(gray_imgout);%%���ƴ��ͼ��Ĵ�С

ref_img1 = zeros(m,n);
ref_img21 = zeros(m,n);

up_o = round(min(y2));
left_o = round(min(x2));


ref_img1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1) = 1;%%ͼ1��Ӧ������Ϊ1

img22(find(img22>0)) = 1;

ref_img21(up:up+M3-1,left:left+N3-1,:) = img22;

ref_overlap = ref_img1 + ref_img21;%%%�ο�ͼ��2�����غ�����1���������ص�����
ref_overlap = uint8(ref_overlap);%%%%%%%%%%%�ο�ͼ��%%%%%%%%%%%%%%%%
%figure,imshow(ref_overlap),title('�غ���������ο�');

%%%%%%%%%%�ָ�%%%%%
%�Լ�⵽�ı߽��������
se1 = strel('square',6);
% ����6*6��������
se2 = strel('line',10,45);
% ����ֱ�߳���10���Ƕ�45
se3 = strel('disk',7);
% ����Բ�̰뾶
se4 = strel('ball',15,5);
% ������Բ�壬�뾶15���߶�5

I2 = imdilate(edge1,se1);
I3 = imdilate(edge1,se2);
I4 = imdilate(edge1,se3);
%I5 = imdilate(edge,se4);

%��ʴ
area1 = imerode(I4,se3);
area2 = imerode(area1,se3);
area3 = imerode(area2,se2);

add = (I4+area3)/2;%%0����ƽ������1�����������0.5Ϊ����ǿ�߽������
%figure,imshow(add);

edge_add = add+edge1;%%0����ƽ������1�����������0.5Ϊ����ǿ�߽������1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�

%%figure,imshow(edge_add),title('����ָ�');
%%%���϶�ͼ1����˷ָ�%%%

%%%%%%%%%%%%%%%%%%%%%%%%�ڱ�����%%%%%%%%%%%%%%%%%%%
%%�˲�ǰ������˹�˲�����Ҷ�ͼ��
jicha = rangefilt(gray1);%%�ֲ��������ԽС����Խƽ��
jicha = double(jicha);
%biaozhuncha = stdfilt(gray); %�ֲ���׼��

%��
entropy_map = Normalize(entropyfilt(gray1));
% entropy_map = uint8(entropy_map);
%

%%��edge_addͼ�У�ƽ�������ȥk1���ļ���ֵ�������������k2������ֵ(�����н�k1��k2�ߵ���)
k1 = 1;
k2 = 0.8;
masking_img1 = zeros(M1,N1);
masking_img1 = double(masking_img1);

for i = 1:M1
    for j = 1:N1
        switch(edge_add(i,j))
            case(0)
                masking_img1(i,j) = k1*(255 -jicha(i,j));
            case(1)
                masking_img1(i,j) = k2*entropy_map(i,j);
            case(2)
                masking_img1(i,j) = k2*entropy_map(i,j);
            case(1.5)
                masking_img1(i,j) = -20; %%%%ǿ�߽����С��Ȩֵ               
            otherwise
                masking_img1(i,j) = 0;
        end
            
    end
 
end

masking_img1 = Normalize(masking_img1+30);
masking_img1 = uint8(masking_img1);

for i = 1:M1
    for j =1:N1
        if edge_add(i,j) == 0.5 || edge_add(i,j) == 1.5
            masking_img1(i,j) = 0;
            
        end
    
    end 
end    

masking = zeros(m,n);

masking(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1) = masking_img1;
masking = uint8(masking);%%%%%%%%%%%%%%%%%�ڱ�����%%%%%%%%%%%%%%%%

% figure,
% imshow(masking),title('�ڱ�����');




%%%%%%%%%%%%%%%%%%������ӳ��ͼ%%%%%%%%%%%%%%%%

%%%%%%%%%���Ȳ���ӳ��ͼ%%%%%%%%
 gray_light1= zeros(m,n);
 gray_light2= zeros(m,n);
gray_light1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = gray1;
gray_light2(up:up+M3-1,left:left+N3-1,:) = gray2;

%%��ֵ�˲���ƽ������
gray_light1 = double(filter2(fspecial('average',3),gray_light1));
gray_light2 = double(filter2(fspecial('average',3),gray_light2));
% gray_light1 = medfilt2(double(gray_light1));
% gray_light2 = medfilt2(double(gray_light2));

light_difference = gray_light1 - gray_light2;
light_difference(find(ref_overlap == 1)) = 0;

light_difference = abs(light_difference );
% %%%%�Ķ�
light_difference = Normalize(light_difference + 10);
% %%%

%light_difference = Normalize(light_difference + 1);
light_difference = 255 - light_difference;
%light_difference_overlap = light_difference(find(ref_overlap == 2));
light_difference(find(ref_overlap == 1)) = 0;
light_difference(find(ref_overlap == 0)) = 0;
light_difference = uint8(light_difference);%%%%%light_difference  ֵԽ�󣬲���ԽС

%%%%%%%%%%%������ӳ��ͼ���%%%%
average = mean(gray1(:));

nonlinear = log(double_gray1+1)+log(average);%%log��average���ǹ�ʽS = K*LnL + K0�е�K0����ͼ���ƽ�������й�
Nor_nonlinear = uint8(Normalize(nonlinear));%%������ӳ��ͼ
%nonlinear = Normalize(nonlinear);

Nor_nonlinear_map = zeros(m,n);

Nor_nonlinear_map(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1) = Nor_nonlinear;
Nor_nonlinear_map = uint8(Nor_nonlinear_map);
% figure,
% imshow(Nor_nonlinear_map),title('�Ҷȶ�����һ��');



%%%%%%%%������ӳ��ͼ%%%%%%%%%%%

saliency_map1 = SDSP(img1);
saliency_map2 = SDSP(img21);

% saliency_map = uint8(0.5*saliency_map1 + 0.5*saliency_map2);
% figure,
% imshow(saliency_map2),title('������');

ref_saliency1 = zeros(m,n);
ref_saliency2 = zeros(m,n);


ref_saliency1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1) = saliency_map1;
ref_saliency2(up:up+M3-1,left:left+N3-1) = saliency_map2;

saliency = ref_saliency1 + ref_saliency2;

saliency(find(ref_overlap == 0)) = 0;
saliency(find(ref_overlap == 1)) = 100;
saliency(find(ref_overlap == 2)) = 0.5*saliency(find(ref_overlap == 2));
%%��ɫ��ʾԭͼλ�ã���ɫ������
saliency = uint8(saliency); %%%%%%%%%%%%%%%%%�ڱ�����%%%%%%%%%%%%%%%%
% figure,
% imshow(saliency),title('ȫͼ������');

%%%
masking(find(ref_overlap == 0)) =0;
masking(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0

Nor_nonlinear_map(find(ref_overlap == 0)) =0;
Nor_nonlinear_map(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0

light_difference(find(ref_overlap == 0)) =0;
light_difference(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0


imwrite(Nor_nonlinear_map,[f '_VN.' ext]);
imwrite(light_difference,[f '_LD.' ext]);
imwrite(masking,[f '_VM.' ext]);
imwrite(saliency,[f '_VS.' ext]);

%%%%%%%%%%%%%%%%%���·��Ȩֵͼ%%%%%%%%%%%%%%%%
cost_map = 0.53*(255-saliency) + 0.17*masking + 0.1*Nor_nonlinear_map + 0.2*light_difference;%%����ʽ1��
%cost_map = 0.5*(255-saliency) + 0.2*masking + 0.1*Nor_nonlinear_map + 0.2*light_difference;%%����ʽ2��
%cost_map = 0.55*(255-saliency) + 0.25*masking + 0.1*Nor_nonlinear_map + 0.1*light_difference;%%����ʽ3��
%cost_map = 255-saliency;%% VS
%cost_map = masking;%%VM
%cost_map = Nor_nonlinear_map;%%NL
%cost_map =light_difference;%%LD



cost_map = uint8(cost_map);

cost_map(find(ref_overlap == 0)) =0;
cost_map(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0


imwrite(cost_map,[f '_Weight_map.' ext]);
figure,
imshow(cost_map),title('Ȩֵͼ');



%%%%%%%%%%%%%%%%%��Ե��Ϣ�ο�%%%%%%%%%%%%%%%%

ref_edge1 = zeros(m,n);
ref_edge2 = zeros(m,n);


ref_edge1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = edge1;
ref_edge2(up:up+M3-1,left:left+N3-1,:) = edge2;

%%���غϱ߽���٣���������С��Χ������
% edge_pengzhang = strel('disk',1);
% ref_edge1 = imdilate(ref_edge1,edge_pengzhang);%%%peng zhang
%%%%%%%

ref_edge = ref_edge1 + ref_edge2;

ref_edge = uint8(ref_edge);%%2�����غϵı߽磬���Դ����� 1��ʾ���غϵı߽�

ref_edge(find(ref_overlap == 0)) =0;
ref_edge(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0
% figure,
% imshow(ref_edge*100),title('��Ե��Ϣ�ο�');

% figure,
% subplot(121);imshow(cost_map);title('Ȩֵͼ');
% subplot(122);imshow(ref_edge*100);title('��Ե��Ϣ�ο�');

%%edge_add��0����ƽ������1�����������0.5Ϊ����ǿ�߽������1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�
%%ref_overlap�ο�ͼ��2�����غ�����1���������ص�����
%%cost_mapȨֵͼ��ֵԽ��ȨֵԽ��
%%ref_edge�߽�ο�ͼ��2�����غϵı߽磬���Դ����� 1��ʾ���غϵı߽�



%%����ʼ�㣬��ͼ2��ת����ͼ1�߽�Ľ�������
%%ƴ��ͼ���У�ͼ1 �ı߽磨Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1��

cross_up = min(find(ref_overlap(Yoffset+1,:)==2));%%(Yoffset+1,cross_up)    ��
cross_down = min(find(ref_overlap(Yoffset+M1,:)==2));%%(Yoffset+M1,cross_down)��
cross_left = max(find(ref_overlap(:,Xoffset+1)==2));%%(cross_left,Xoffset+1)    ��
cross_right = max(find(ref_overlap(:,Xoffset+N1)==2));%%(cross_right,Xoffset+N1)��

%%%
if isempty(cross_up) == 0   %%�ϲ��ཻ
    begin = [Yoffset+1,cross_up];
else
    begin = [Yoffset+M1,cross_down];
end

%%%
if isempty(cross_right) == 0   %%�Ҳ��ཻ
    terminal = [cross_right,Xoffset+N1];
else
    terminal = [cross_left,Xoffset+1];
end

%%begin��㣬terminal�յ�
step = terminal - begin;%%�ƶ��Ĳ�����y_step,x_step��

moasic_line = imgout;%%�ڴ�ͼ����ʾ�ں�·����


%%%%%%��ͼ2��ת���ǿ���߽�
I2_img21 = imdilate(edge2,se1);
I3_img21 = imdilate(edge2,se2);
I4_img21 = imdilate(edge2,se3);
%I5 = imdilate(edge,se4);

%��ʴ
area1_img21 = imerode(I4_img21,se3);
area2_img21 = imerode(area1_img21,se3);
area3_img21 = imerode(area2_img21,se2);

add_img21 = (I4_img21+area3_img21)/2;%%0����ƽ������1�����������0.5Ϊ����ǿ�߽������
%figure,imshow(add);

edge_add2 = add_img21+edge2;%%0����ƽ������1�����������0.5Ϊ����ǿ�߽������1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�


edge_strong1 = zeros(m,n);
edge_strong2 = zeros(m,n);


edge_strong1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = edge_add;
edge_strong2(up:up+M3-1,left:left+N3-1,:) = edge_add2;%%%1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�

edge_strong1(find(ref_overlap == 0)) =0;
edge_strong1(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0


edge_strong2(find(ref_overlap == 0)) =0;
edge_strong2(find(ref_overlap == 1)) =0;%%���غ�����Ϊ0

% figure,imshow(edge_strong1),title('1');
% figure,imshow(edge_strong2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����ǵ㼯%%%%%%%%%%%%%%%%%%%%%%

%%%���غ��������꼯��%%%%
[row,col] = find(ref_overlap ~= 2);
misalignment_area = [row,col];

%%%�غ�����߽�����%%%
edge_overlap = edge(ref_overlap);
[row,col] = find(edge_overlap == 1);
boundary_overlap = [row,col];

%%%���غ��������꼯��%%%%
[row1,col1] = find(edge_strong1 == 1.5);
[row2,col2] = find(edge_strong2 == 1.5);
strong_edge1 = [row1,col1];
strong_edge2 = [row2,col2];



strong_edge= union(strong_edge1,strong_edge2,'rows');%%%�غ�������ͼǿ�߽�Ĳ�����ÿ��Ϊ��������
%%%%%%
[row,col] = find(ref_edge == 2);
safe_edge = [row,col];%%%�غϱ߽�����꼯�����������������߽磩


safe_strongedge = intersect(strong_edge,safe_edge,'rows');%%%%��ȫ��ǿ�߽�����
 
[row,col] = find(ref_edge == 1);
mis_edge = [row,col];%%%���غϱ߽�����꼯�����������������߽磩

misalignment_strongedge =  intersect(strong_edge,mis_edge,'rows'); %%%%���غϵ�ǿ�߽�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%�˴�����С��Χ��ǿ�߽�����%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%���������ص��ʼ������%%%%%%
un_candients = union(misalignment_area,misalignment_strongedge,'rows');
un_candients = union(un_candients,boundary_overlap,'rows');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ѡ��ƴ�ӵ�%%%%%%%%%%%
%%%%%%%%Ȩֵͼcost_map
%%%%%%%%���begin
%%%%%%%%�յ�terminal
%%%%%%%%λ����step
%%%%%%%%�����ǵ㼯un_candients
%%%%%%%%��ȫǿ�߽�safe_strongedge
%%%%%%%%��ʾ�ں�·����ͼ��moasic_line

a = ones(3,3);
i1 = begin(1,1);
j1 = begin(1,2);

pos_moasic_points = zeros(m,n);

un_candients = [un_candients;[i1,j1]];
moasic_points = begin;
imax = max(terminal(1,1),up+M3-1);
jmax = max(terminal(1,2),left+N3-1);

while(i1 <=imax && j1 <= jmax) %%%%%������Ҫ���ƣ�����߽�����ֹͣ

%         dis_x = terminal(1:1)-i1;
%         dis_y = terminal(1:2)-j1;
%         window = [cost_map(i1-1,j1-1)/(dis_x),  cost_map(i1-1,j1),  cost_map(i1-1,j1+1);
%                   cost_map(i1,j1-1),    cost_map(i1,j1),    cost_map(i1,j1+1);
%                   cost_map(i1+1,j1-1),  cost_map(i1+1,j1),  cost_map(i1+1,j1+1)];  

        pos_moasic_points(i1,j1) = 1; 
        
        window = [cost_map(i1-1,j1-1),  cost_map(i1-1,j1),  cost_map(i1-1,j1+1);
                  cost_map(i1,j1-1),    cost_map(i1,j1),    cost_map(i1,j1+1);
                  cost_map(i1+1,j1-1),  cost_map(i1+1,j1),  cost_map(i1+1,j1+1)];
        pos_window = [i1-1,j1-1; i1-1,j1; i1-1,j1+1;  i1,j1-1; i1,j1; i1,j1+1; i1+1,j1-1; i1+1,j1; i1+1,j1+1];
        if ismember(terminal,pos_window,'rows')== 1
%             i1 = terminal(1,1);
%             j1 = terminal(1,2);
            moasic_points = [moasic_points; terminal];
             break
        else
        ref_candients = ismember(pos_window,un_candients,'rows');
        
        ref_window = uint8(a-reshape(ref_candients,3,3)');%%%��window�����Ӧ���þ���Ϊ0�������Ǹ�����
        window = double(window.*ref_window);%%�������ڲ����ǵĵ�Ȩֵ��1
        
        window_length = [ norm([i1-1,j1-1]-terminal),  norm([i1-1,j1]-terminal),   norm([i1-1,j1+1]-terminal);
                          norm([i1,j1-1]-terminal),    norm([i1,j1]-terminal),     norm([i1,j1+1]-terminal);
                          norm([i1+1,j1-1]-terminal),  norm([i1+1,j1]-terminal),   norm([i1+1,j1+1]-terminal)];
        ref_length = 1./(window_length); %%��������ĵ���   ����ԶʱӰ���С����ʱӰ��ϴ�   

        window = ref_length + window;%%%cost+��������ĵ���
        [i2,j2] = find(window == max(max(window)), 1, 'last');
        h = i2 - 2;%%hang
        l = j2 - 2;%%lie
        i1 = i1 + h;
        j1 = j1 + l;
        moasic_points = [moasic_points; [i1,j1]];%%%
        %%un_candients = [un_candients;[i1,j1];[i1-1,j1-1];[i1,j1-1];[i1+1,j1]];%%�����ϲ༰���ĵ����Ǻ�ѡ��
        
        un_candients = [un_candients;[i1,j1];[i1-h,j1-l];[i1-h-1,j1-l];[i1-h+1,j1-l];[i1-h,j1-l-1];[i1-h,j1-l+1];];%%����ѡ���ķ���õ�ʮ�ַǺ�ѡ��
        
        moasic_line(i1,j1,:) = 255;
        end
        
end

figure,imshow(moasic_line);
%figure,imshow(pos_moasic_points);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disk1 = strel('disk',2);
disk2 = strel('disk',1);
%%����
pos_moasic_points = imdilate(pos_moasic_points,disk1);
%%��ʴ
pos_moasic_points = imerode(pos_moasic_points,disk1);%%�ں�·����õ�������
%pos_moasic_points = imerode(pos_moasic_points,disk2);
edge_pos_moasic_points = edge(pos_moasic_points,'canny');
edge_pos_moasic_points = [edge_pos_moasic_points(:,end) edge_pos_moasic_points(:,1:end-1)];%%�ں�·��
% imshow(edge_pos_moasic_points)

%%%%
im = pos_moasic_points;
im(1:begin(1,1)-1,:) = 1;%%%Ⱦ��һЩ����
im(:,terminal(1,2)) = 1;
im2=imfill(im,'holes');             %���
%im3=bwperim(im2);                   %������ȡ
im2 = [im2(:,end) im2(:,1:end-1)];

im2(:,terminal(1,2):end) = 1;


figure,imshow(im2); title('�غ����򻮷�')             %��ʾ%%0��ʾͼ1�� 1��ʾͼ2


%%%%%%%%%%%%%%%%%%%%%����im2����ƴ��ͼ%%%%%%%%%%%%%%%%%%%%

ref_img1_moasic = im2(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1);
ref_img2_moasic = im2(up:up+M3-1,left:left+N3-1);
% figure,imshow(ref_img1_moasic);
% figure,imshow(ref_img2_moasic);


%%%
img_moasic1 = zeros(m,n,3);
img_moasic2 = zeros(m,n,3);
img_moasic1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = img1;
img_moasic2(up:up+M3-1,left:left+N3-1,:) = img21;
%%%%%
% im2(:,:,1) = im2;
% im2(:,:,2) = im2;
% im2(:,:,3) = im2;
img_moasic_direct1(:,:,1) = img_moasic1(:,:,1).*~im2;
img_moasic_direct1(:,:,2) = img_moasic1(:,:,2).*~im2;
img_moasic_direct1(:,:,3) = img_moasic1(:,:,3).*~im2;
img_moasic_direct1 = uint8(img_moasic_direct1);
%%%
img_moasic_direct2(:,:,1) = img_moasic2(:,:,1).*im2;
img_moasic_direct2(:,:,2) = img_moasic2(:,:,2).*im2;
img_moasic_direct2(:,:,3) = img_moasic2(:,:,3).*im2;
img_moasic_direct2 = uint8(img_moasic_direct2);


img_moasic_direct = img_moasic_direct1 +img_moasic_direct2;
figure,imshow(img_moasic_direct),title('δ�Ӷ�߶��ں�');


%%%%%��ʾ�ں���%%%%%%
img_moasic_line = img_moasic_direct;
seam_line = edge(im2,'canny');
seam_line(find(ref_overlap == 0)) = 0;
seam_line(find(ref_overlap == 1)) = 0;%%%%seam_line ��ֵͼ��1��ʾƴ����

img_moasic_line_r = img_moasic_line(:,:,1);
img_moasic_line_r(find(seam_line == 1)) = 200;

img_moasic_line_g = img_moasic_line(:,:,2);
img_moasic_line_g(find(seam_line == 1)) = 0;

img_moasic_line_b = img_moasic_line(:,:,3);
img_moasic_line_b(find(seam_line == 1)) = 0;

img_moasic_line(:,:,1) = img_moasic_line_r;
img_moasic_line(:,:,2) = img_moasic_line_g;
img_moasic_line(:,:,3) = img_moasic_line_b;

figure,imshow(img_moasic_line),title('seam line');%%%%%��ʾ�ں�·��
% 

%%%%%%%����Ϊ��߶��ں�%%%%%%%
% im1 = imread('huaji.jpg');  im1 = double(rgb2gray(im1));
% im2 = imread('hand.bmp'); im2 = double(rgb2gray(im2));
% im3 = imread('mask.bmp'); im3 = double(im3);
% C = BlendArbitrary(im1, im2, im3/255, 4);


% C = BlendArbitrary(im1, im2, im2, 4);
% boundary_pengzhang = strel('disk',1);
% edge_overlap_pengzhang = imdilate(edge_overlap,boundary_pengzhang);%%%peng zhang
% 
% ref_overlap_move = ref_overlap;
% ref_overlap_move(edge_overlap_pengzhang == 1) = 1;

extend_moasic1 = img_moasic1(:,:,1);
extend_moasic2 = img_moasic1(:,:,2);
extend_moasic3 = img_moasic1(:,:,3);

extend_moasic1(find(ref_overlap == 2)) = 0;
extend_moasic2(find(ref_overlap == 2)) = 0;
extend_moasic3(find(ref_overlap == 2)) = 0;

extend_moaic(:,:,1) = extend_moasic1;
extend_moaic(:,:,2) = extend_moasic2;
extend_moaic(:,:,3) = extend_moasic3;
img_moasic2 = img_moasic2 + extend_moaic;

img_moasic1(up:up+M3-1,left:left+N3-1,:) = img21;
img_moasic1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = img1;



%%%%%%%%%%%%%%%%%%%%%%ȥ����תͼ��ڱ�%%%
img_moasic1_r = img_moasic1(:,:,1);
img_moasic1_g = img_moasic1(:,:,2);
img_moasic1_b = img_moasic1(:,:,3);


img_moasic2_r = img_moasic2(:,:,1);
img_moasic2_g = img_moasic2(:,:,2);
img_moasic2_b = img_moasic2(:,:,3);

edge_overlap(Yoffset+1,:) = 0;
edge_overlap(:,Xoffset+N1+1) = 0;


img_moasic2_r(find(edge_overlap == 1)) = img_moasic1_r(find(edge_overlap == 1));
img_moasic2_g(find(edge_overlap == 1)) = img_moasic1_g(find(edge_overlap == 1));
img_moasic2_b(find(edge_overlap == 1)) = img_moasic1_b(find(edge_overlap == 1));

img_moasic2(:,:,1) = img_moasic2_r;
img_moasic2(:,:,2) = img_moasic2_g;
img_moasic2(:,:,3) = img_moasic2_b;
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%
x = 64;%%%16xΪ��������ͼ���С
img_moasic_blend1 = zeros(16*x,16*x,3);
img_moasic_blend2 = zeros(16*x,16*x,3);
img_moasic_blend  = zeros(16*x,16*x,3);
c1 = zeros(16*x,16*x);%%%������ƴ�ӷ�ο�
boundary = ones(16*x,16*x);%%%ͼ��߽�Ϊƴ�ӷ�ο�
boundary(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = 0;
%%%
a1 = double((img_moasic1(:,:,1)));
img_moasic_blend1(1:m,1:n,1) = a1;

a2 = double((img_moasic1(:,:,2)));
img_moasic_blend1(1:m,1:n,2) = a2;

a3 = double((img_moasic1(:,:,3)));
img_moasic_blend1(1:m,1:n,3) = a3;

%%%
b1 = double((img_moasic2(:,:,1)));
img_moasic_blend2(1:m,1:n,1) = b1;

b2 = double((img_moasic2(:,:,2)));
img_moasic_blend2(1:m,1:n,2) = b2;

b3 = double((img_moasic2(:,:,3)));
img_moasic_blend2(1:m,1:n,3) = b3;

%%%
c1(1:m,1:n) = double(im2);%%�ںϲο�
img_moasic_blend1 = double(img_moasic_blend1);
img_moasic_blend2 = double(img_moasic_blend2);

C1 = BlendArbitrary(img_moasic_blend2(:,:,1), img_moasic_blend1(:,:,1), c1, 4);
C2 = BlendArbitrary(img_moasic_blend2(:,:,2), img_moasic_blend1(:,:,2), c1, 4);
C3 = BlendArbitrary(img_moasic_blend2(:,:,3), img_moasic_blend1(:,:,3), c1, 4);


img_moasic_blend(:,:,1) = C1;
img_moasic_blend(:,:,2) = C2;
img_moasic_blend(:,:,3) = C3;
img_moasic_blend = img_moasic_blend(1:m,1:n,:);

figure;imshow(uint8(img_moasic_blend));title('���ս��');

%%%
boundary = double(boundary);%%�ںϲο�

D1 = BlendArbitrary(img_moasic_blend2(:,:,1), img_moasic_blend1(:,:,1), boundary, 4);
D2 = BlendArbitrary(img_moasic_blend2(:,:,2), img_moasic_blend1(:,:,2), boundary, 4);
D3 = BlendArbitrary(img_moasic_blend2(:,:,3), img_moasic_blend1(:,:,3), boundary, 4);


img_direct_blend(:,:,1) = D1;
img_direct_blend(:,:,2) = D2;
img_direct_blend(:,:,3) = D3;
img_direct_blend = img_direct_blend(1:m,1:n,:);
img_direct_blend = uint8(img_direct_blend);
figure;imshow(img_direct_blend);title('ֱ��ƽ���ں�');

%%��ʾ%%%
img_direct_blend = uint8(img_direct_blend);
img_moasic_blend = uint8(img_moasic_blend);
subplot(221);imshow(imgout);title('ֱ���ں�');
subplot(222);imshow(img_direct_blend);title('ֱ��ƽ���ں�');
subplot(223);imshow(img_moasic_direct);title('�Ż������');
subplot(224);imshow(img_moasic_blend);title('���ս��');


%%%%%����%%%%
imwrite(imgout,'1.jpg');
imwrite(img_direct_blend,'2.jpg');
imwrite(img_moasic_direct,'3.jpg');
imwrite(img_moasic_blend,'4.jpg');

imwrite(imgout,[f '_mosaic1.' ext]);
imwrite(img_direct_blend,[f '_mosaic2.' ext]);
imwrite(img_moasic_direct,[f '_mosaic3.' ext]);
imwrite(img_moasic_blend,[f '_mosaic4.' ext]);

imwrite(img_moasic_line,[f '_seam line.' ext]);

imwrite(saliency,[f '_saliency.' ext]);
%%%%%%%%%%%%%%%%%%����ͼ������%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%ָ��1��ƴ�ӷ����ܼ����ı߽�%%%%  %%% edge_strong1  %%%1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�

%%%�����Ż������%%%
edge_moasic_direct = edge(rgb2gray(img_moasic_direct),'canny',0.01);%
seam_line_edge = seam_line + edge_moasic_direct;%%%2���������ķ��������
seam_line_edge(find(edge_strong1 == 2)) = 0;%%%%�ҵ��ں�·��ֱ��ƴ��������ܼ����ı߽�㡣2��ʾ�������ķ��������
%figure,imshow(uint8(100*seam_line_edge));

edge_moasic_blend = edge(rgb2gray(img_moasic_blend),'canny',0.01);%
seam_blend_edge = seam_line + edge_moasic_blend;%%%2���������ķ��������
seam_blend_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*seam_blend_edge));

%%%����ͼ�α߽���Ϊ�����%%%
boundary_seam = ones(m,n);%%%ͼ��߽�Ϊƴ�ӷ�ο�
boundary_seam(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = 0;

boundary_seam = edge(boundary_seam,'canny');


edge_imgout = edge(rgb2gray(imgout),'canny',0.01);%
boundary_direct_edge = boundary_seam + edge_imgout;%%%2���������ķ��������
boundary_direct_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*boundary_direct_edge));

edge_direct_blend = edge(rgb2gray(img_direct_blend),'canny',0.01);%
boundary_blend_edge = boundary_seam + edge_direct_blend;%%%2���������ķ��������
boundary_blend_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*boundary_blend_edge));

figure,
subplot(221);imshow(edge_imgout);title('ֱ���ں�');
subplot(222);imshow(edge_direct_blend);title('ֱ��ƽ���ں�');
subplot(223);imshow(edge_moasic_direct);title('�Ż������');
subplot(224);imshow(edge_moasic_blend);title('���ս��');
%%%%ƴ�������ܼ����ı߽����ظ�������ȥ���߽磩
num1=sum(sum(boundary_direct_edge == 2))%%%ֱ��
num2=sum(sum(boundary_blend_edge == 2))%%%ֱ��+�ں�
num3=sum(sum(seam_line_edge == 2))%%%�����
num4=sum(sum(seam_blend_edge == 2))%%%�����+�ں�

%%%%%%%%%ָ��2����⵽�����ظ������������ظ����ı�ֵ%%%
num_dirct = abs(begin(1,1) - terminal(1,1)) + abs(begin(1,2) - terminal(1,2))%%%ֱ���ں����ظ���

num_seam_line = sum(sum(seam_line == 1))

ratio1 = num1/num_dirct
ratio2 = num2/num_dirct

ratio3 = num3/num_seam_line
ratio4 = num4/num_seam_line



%%%%%%%Ĭ��canny

%%%�����Ż������%%%
edge_moasic_direct = edge(rgb2gray(img_moasic_direct),'canny');%
seam_line_edge = seam_line + edge_moasic_direct;%%%2���������ķ��������
seam_line_edge(find(edge_strong1 == 2)) = 0;%%%%�ҵ��ں�·��ֱ��ƴ��������ܼ����ı߽�㡣2��ʾ�������ķ��������
%figure,imshow(uint8(100*seam_line_edge));

edge_moasic_blend = edge(rgb2gray(img_moasic_blend),'canny');%
seam_blend_edge = seam_line + edge_moasic_blend;%%%2���������ķ��������
seam_blend_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*seam_blend_edge));

%%%����ͼ�α߽���Ϊ�����%%%
boundary_seam = ones(m,n);%%%ͼ��߽�Ϊƴ�ӷ�ο�
boundary_seam(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = 0;

boundary_seam = edge(boundary_seam,'canny');


edge_imgout = edge(rgb2gray(imgout),'canny');%
boundary_direct_edge = boundary_seam + edge_imgout;%%%2���������ķ��������
boundary_direct_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*boundary_direct_edge));

edge_direct_blend = edge(rgb2gray(img_direct_blend),'canny');%
boundary_blend_edge = boundary_seam + edge_direct_blend;%%%2���������ķ��������
boundary_blend_edge(find(edge_strong1 == 2)) = 0;%%%��߶��ںϺ��⵽�����ص�
%figure,imshow(uint8(100*boundary_blend_edge));

figure,
subplot(221);imshow(edge_imgout);title('ֱ���ں�');
subplot(222);imshow(edge_direct_blend);title('ֱ��ƽ���ں�');
subplot(223);imshow(edge_moasic_direct);title('�Ż������');
subplot(224);imshow(edge_moasic_blend);title('���ս��');
%%%%ƴ�������ܼ����ı߽����ظ�������ȥ���߽磩
num1=sum(sum(boundary_direct_edge == 2))%%%ֱ��
num2=sum(sum(boundary_blend_edge == 2))%%%ֱ��+�ں�
num3=sum(sum(seam_line_edge == 2))%%%�����
num4=sum(sum(seam_blend_edge == 2))%%%�����+�ں�

%%%%%%%%%ָ��2����⵽�����ظ������������ظ����ı�ֵ%%%
num_dirct = abs(begin(1,1) - terminal(1,1)) + abs(begin(1,2) - terminal(1,2))%%%ֱ���ں����ظ���

num_seam_line = sum(sum(seam_line == 1))

ratio1 = num1/num_dirct
ratio2 = num2/num_dirct

ratio3 = num3/num_seam_line
ratio4 = num4/num_seam_line





% %%%%ָ��3��ƴ�ӷ���ɵ�ǿ�߽��λ
% ref_edge = ref_edge1 + ref_edge2;
% 
% ref_edge = uint8(ref_edge);%%2�����غϵı߽磬���Դ����� 1��ʾ���غϵı߽�
% 
% ref_dis_edge = ref_edge;
% ref_dis_edge(find(ref_dis_edge == 2)) =0;%%%ȥ���غϱ߽����أ�ʣ��ȫ��Ϊ���ѵı߽�
% 
% %%%boundary%%
% dis_edge_boundary = double(ref_dis_edge) + double(boundary_seam);%%%2Ϊ���ѵ����ص�
% dis_edge_boundary(find(edge_strong1 == 2)) = 0;
% dis_edge_boundary(find(edge_strong2 == 2)) = 0;
% figure,imshow(uint8(100*dis_edge_boundary));
% 
% %%%seam line%%
% dis_edge_seam = double(ref_dis_edge) + double(seam_line);%%%2Ϊ���ѵ����ص�
% dis_edge_seam(find(edge_strong1 == 2)) = 0;
% dis_edge_seam(find(edge_strong2 == 2)) = 0;
% figure,imshow(uint8(100*dis_edge_seam));
% 
% %%����%%%
% num_boundary = sum(sum(dis_edge_boundary == 2))%%%ֱ��
% num_seam = sum(sum(dis_edge_seam == 2))%%%ֱ��+�ں�