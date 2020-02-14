function t=statxture(f,scale)
%f��uint8���Ͷ�ά����
%scale�Ǿ���Ԫ�����ű�����Ĭ��1
%t��6��Ԫ�أ�ƽ���Ҷȡ�ƽ���Աȶȡ�ƽ���ȡ����׾ء�һ���ԡ���
if nargin==1
    scale(1:6)=1;
else
    scale=scale(:)';
end
p=imhist(f);
p=p./numel(f);
L=length(p);
[v,mu]=statmoments(p,3);
t(1)=mu(1);
t(2)=mu(2).^0.5;
varn=mu(2)/(L-1)^2;
t(3)=1-1/(1+varn);
t(4)=mu(3)/(L-1)^2;
t(5)=sum(p.^2);
t(6)=-sum(p.*(log2(p+eps)));
t=t.*scale;