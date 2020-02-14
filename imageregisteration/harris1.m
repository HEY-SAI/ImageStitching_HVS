%%%Prewitt Operator Corner Detection.m
%%%ʱ���Ż�--����������ȡ��ķ���
function lc=harris1(Image,hsize)   %C�ǽǵ����count�ǽǵ����������߶������
 if nargin == 0
	Image = imread('feiji1.jpg');
    hsize=5;
 end
[x,y,z]=size(Image);
if z==3
%Image = imread( 'feiji.jpg');                 % ��ȡͼ��
Image = im2uint8(rgb2gray(Image));   
end;

dx = [-1 0 1;-1 0 1;-1 0 1];  %dx������Prewitt���ģ��
Ix2 = filter2(dx,Image).^2;   
Iy2 = filter2(dx',Image).^2;                                         
Ixy = filter2(dx,Image).*filter2(dx',Image);


%���� 5*5 �� 7*7 �� 9*9 �ĸ�˹���ڡ�����Խ��̽�⵽�Ľǵ�Խ�١�
if hsize==5
    h= fspecial('gaussian',5,2);  
elseif hsize==7
    h= fspecial('gaussian',7,2);
elseif hsize==9
    h= fspecial('gaussian',9,2);  
else
    h= fspecial('gaussian',5,2);  
end
A = filter2(h,Ix2);       % �ø�˹���ڲ��Ix2�õ�A 
B = filter2(h,Iy2);                                 
C = filter2(h,Ixy);                                  
nrow = size(Image,1);                            
ncol = size(Image,2); 

det1=zeros(nrow,ncol);
lam1=zeros(nrow,ncol);
Corner = zeros(nrow,ncol); %����Corner���������ѡ�ǵ�λ��,��ֵȫ�㣬ֵΪ1�ĵ��ǽǵ�
                           %�����Ľǵ���137��138����(row_ave,column_ave)�õ�
%����t:��(i,j)������ġ����ƶȡ�������ֻ�����ĵ������������˸��������ֵ֮����
%��-t,+t��֮�䣬��ȷ������Ϊ���Ƶ㣬���Ƶ㲻�ں�ѡ�ǵ�֮��
% -t<Image(i,j)-Image(i��1,j��1)<+t

%�Ҳ�û��ȫ�����ͼ��ÿ���㣬���ǳ�ȥ�˱߽���boundary�����أ�
%��Ϊ���Ǹ���Ȥ�Ľǵ㲢�������ڱ߽���
t =20;
boundary=8;
Image=double(Image);
for i=boundary:nrow-boundary+1 
    for j=boundary:ncol-boundary+1
        nlike=0; %���Ƶ����
        if Image(i-1,j-1)>Image(i,j)-t && Image(i-1,j-1)<Image(i,j)+t 
            nlike=nlike+1;
        end
        if Image(i-1,j)>Image(i,j)-t && Image(i-1,j)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if Image(i-1,j+1)>Image(i,j)-t && Image(i-1,j+1)<Image(i,j)+t  
            nlike=nlike+1;
        end  
        if Image(i,j-1)>Image(i,j)-t && Image(i,j-1)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if Image(i,j+1)>Image(i,j)-t && Image(i,j+1)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if Image(i+1,j-1)>Image(i,j)-t && Image(i+1,j-1)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if Image(i+1,j)>Image(i,j)-t && Image(i+1,j)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if Image(i+1,j+1)>Image(i,j)-t && Image(i+1,j+1)<Image(i,j)+t  
            nlike=nlike+1;
        end
        if nlike>=2 && nlike<=6
            Corner(i,j)=1;%�����Χ��0��1��7��8�������ĵģ�i,j������
                          %��(i,j)�Ͳ��ǽǵ㣬���ԣ�ֱ�Ӻ���
        end;
    end;
end;

CRF = zeros(nrow,ncol);    % CRF��������ǵ���Ӧ����ֵ,��ֵȫ��
CRFmax = 0;                % ͼ���нǵ���Ӧ���������ֵ������ֵ֮�� 
t=0.05;   
% ����CRF
%�����ϳ���CRF(i,j) =det(M)/trace(M)����CRF����ô��ʱӦ�ý������103�е�
%����ϵ��t���ô�һЩ��t=0.1�Բɼ����⼸��ͼ����˵��һ���ȽϺ���ľ���ֵ
for i = boundary:nrow-boundary+1 
for j = boundary:ncol-boundary+1
    if Corner(i,j)==1  %ֻ��ע��ѡ��
        M = [A(i,j) C(i,j);
             C(i,j) B(i,j)];      
         CRF(i,j) = det(M)-t*(trace(M))^2;
         det1(i,j)=det(M);
         lam1(i,j)=trace(M);
        if CRF(i,j) > CRFmax 
            CRFmax = CRF(i,j);
        end;            
    end
end;             
end;  

count = 0;       % ������¼�ǵ�ĸ���
t=0.01;         
% ����ͨ��һ��3*3�Ĵ������жϵ�ǰλ���Ƿ�Ϊ�ǵ�
for i = boundary:nrow-boundary+1 
for j = boundary:ncol-boundary+1
        if Corner(i,j)==1  %ֻ��ע��ѡ��İ�����
            if CRF(i,j) > t*CRFmax && CRF(i,j) >CRF(i-1,j-1) ......
               && CRF(i,j) > CRF(i-1,j) && CRF(i,j) > CRF(i-1,j+1) ......
               && CRF(i,j) > CRF(i,j-1) && CRF(i,j) > CRF(i,j+1) ......
               && CRF(i,j) > CRF(i+1,j-1) && CRF(i,j) > CRF(i+1,j)......
               && CRF(i,j) > CRF(i+1,j+1) 
          % t11=t*CRFmax;
          % t22=CRFmax;
            count=count+1;%����ǽǵ㣬count��1
            else % �����ǰλ�ã�i,j�����ǽǵ㣬����Corner(i,j)��ɾ���Ըú�ѡ�ǵ�ļ�¼
                Corner(i,j) = 0;     
            end;
        end; 
end; 
end; 
[x,y]=find(Corner==1);
lc=[x,y];
%pause; %���Ӳ�����������ͣ��ֱ��������һ�������� �Ӳ�����������ͣx�롣
%disp('�ǵ����');
%disp(count)
%pause;
%imshow(Image);      % display Intensity Image 
% toc(t1)
fid=fopen('harris.txt','w');
fprintf(fid,'harris�ǵ������з��汨��\r\n');
fprintf(fid,'== %s  %s == \r\n',datestr(date,26),datestr(now,13));
fprintf(fid,'--------------------------\r\n');
fprintf(fid,'����ͼ����ݸ�Ϊ��%d\r\n',x);
fprintf(fid,'����ͼ��ĺ��Ϊ��%d\r\n',y);
fprintf(fid,'\r\n');
fprintf(fid,'��˹�˲����ڴ�СΪ��%d*%d\r\n',hsize,hsize);
fprintf(fid,'\r\n');
fprintf(fid,'��Ӧ��������ֵCRFmax = %f\r\n',CRFmax);
fprintf(fid,'\r\n');
fprintf(fid,'�ǵ����Ϊ��%d\r\n',count);
fprintf(fid,'\r\n');
fprintf(fid,'�ǵ������Զ����Ƶ���ʽ�����corner.txt�ļ���\r\n');
C=Corner;
        