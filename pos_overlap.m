%only for RGB image homography
 clc;
clear all;
% close all

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


ref_overlap = ref_img1 + ref_img21;%%%2�����غ�����1���������ص�����
ref_overlap = uint8(ref_overlap);
figure,imshow(ref_overlap);


