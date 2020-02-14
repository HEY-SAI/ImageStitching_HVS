%only for RGB image homography
 clc;
clear all;
close all

f = 'xiao';
ext = 'jpg';
img1 = imread([f '1.' ext]);
img2 = imread([f '2.' ext]);

H = [     0.9494    0.0043         0
         -0.0379    0.9681         0
         263.5857   -6.3415    1.0000];%%�������

 
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

% for i = 1:M3
%     for j = 1:N3
%         if img22 > 0
%             ref_img21(up+i-1,left+j-1) = 1;
%         end
% 
%     end
% end


ref_overlap = ref_img1 + ref_img21;%%%�ο�ͼ��2�����غ�����1���������ص�����
ref_overlap = uint8(ref_overlap);%%%%%%%%%%%�ο�ͼ��%%%%%%%%%%%%%%%%
figure,imshow(ref_overlap),title('�غ���������ο�');





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

edge_add = add+edge1;
figure,imshow(edge_add),title('����ָ�');%%0����ƽ������1�����������0.5Ϊ����ǿ�߽������1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�
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

%%��edge_addͼ�У�ƽ�������ȥk1���ļ���ֵ�������������k2������ֵ
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
                                
            otherwise
                masking_img1(i,j) = 0;
        end
            
    end
 
end

masking_img1 = Normalize(masking_img1);
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

figure,
imshow(masking),title('�ڱ�����');




%%%%%%%%%%%%%%%%%%������ӳ��ͼ%%%%%%%%%%%%%%%%


%%%%%%%%%%%������ӳ��ͼ���%%%%
average = mean(gray1(:));

nonlinear = log(double_gray1+1)+log(average);%%log��average���ǹ�ʽS = K*LnL + K0�е�K0����ͼ���ƽ�������й�
Nor_nonlinear = uint8(Normalize(nonlinear));%%������ӳ��ͼ
%nonlinear = Normalize(nonlinear);

Nor_nonlinear_map = zeros(m,n);

Nor_nonlinear_map(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1) = Nor_nonlinear;
Nor_nonlinear_map = uint8(Nor_nonlinear_map);
figure,
imshow(Nor_nonlinear_map),title('�Ҷȶ�����һ��');



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
figure,
imshow(saliency),title('ȫͼ������');


%%%%%%%%%%%%%%%%%���·��Ȩֵͼ%%%%%%%%%%%%%%%%

cost_map = 0.75*(255-saliency) + 0.15*masking + 0.1*Nor_nonlinear_map;

cost_map = uint8(cost_map);
figure,
imshow(cost_map),title('Ȩֵͼ');


%%%%%%%%%%%%%%%%%��Ե��Ϣ�ο�%%%%%%%%%%%%%%%%

ref_edge1 = zeros(m,n);
ref_edge2 = zeros(m,n);


ref_edge1(Yoffset+1:Yoffset+M1,Xoffset+1:Xoffset+N1,:) = edge1;
ref_edge2(up:up+M3-1,left:left+N3-1,:) = edge2;

%%���غϱ߽���٣���������С��Χ������
ref_edge = ref_edge1 + ref_edge2;

ref_edge = uint8(ref_edge);%%2�����غϵı߽磬���Դ����� 1��ʾ���غϵı߽�
figure,
imshow(ref_edge*100),title('��Ե��Ϣ�ο�');

figure,
subplot(121);imshow(cost_map);title('Ȩֵͼ');
subplot(122);imshow(ref_edge*100);title('��Ե��Ϣ�ο�');

%%edge_add��0����ƽ������1�����������0.5Ϊ����ǿ�߽������1.5Ϊ�������е�ǿ�߽�,2Ϊ���߽�