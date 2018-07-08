% adaptive histogram equalization

%%
% histogram matching
clear all;
a=imread('cameraman.tif');
b=imread('tire.tif');
[rows1,columns1]=size(a);
[rows2,columns2]=size(b);

L=256;
pixel_val=0:255;
nk1=zeros(1,L);
nk2=zeros(1,L);

a=double(a);
b=double(b);

for i=1:rows1
    for j=1:columns1
        val=a(i,j);
%         val+1 as values from 0 to 255
        nk1(val+1)= nk1(val+1)+1;
    end
end

for i=1:rows2
    for j=1:columns2
        val=b(i,j);
%         val+1 as values from 0 to 255
        nk2(val+1)= nk2(val+1)+1;
    end
end    

prk1=zeros(1,L);
prk2=zeros(1,L);
% probability distribution
prk1=double(nk1)/(rows1*columns1);
sum1=0;
prk2=double(nk2)/(rows2*columns2);
sum2=0;

for i=1:size(nk1,2)
    sum1=sum1+prk1(i);
    sum2=sum2+prk2(i);
%     cumulative probability distribution
    s1(i)=sum1;
    s2(i)=sum2;
end
for i=1:L
    diff=s1(i)-s2;
    [~,ind]=min(abs(diff));
    map(i)= ind-1;
end


final_image=map(double(a)+1);
%  just used for plotting
nk_out=zeros(1,L);
for i=1:rows1
    for j=1:columns1
        val=final_image(i,j);
%         val+1 as values from 0 to 255
        nk_out(val+1)= nk_out(val+1)+1;
    end
end    
prk_out=double(nk_out)/(rows1*columns1);

% for transformation 
psk_out=zeros(1,L);
s1=0;
for i=1:L
    s1=s1+prk_out(i);
    psk_out(i)=s1;
end    


output=imhistmatch(uint8(a),uint8(b),256);
% output probability distribution
final_out=zeros(1,L);
for i=1:rows1
    for j=1:columns1
        val=output(i,j);
%         val+1 as values from 0 to 255
        final_out(val+1)= final_out(val+1)+1;
    end
end    
prk_final=double(final_out)/(rows1*columns1);


% plots


% plot for transformation
figure;
stairs(pixel_val,psk_out);
axis([0,255,0,1]);


figure;
subplot(1,4,1);
imshow(uint8(a));
title('Original Image');
subplot(1,4,2);
imshow(uint8(b));
title('Specified Histogram');
subplot(1,4,3);
imshow(uint8(final_image));
title('Histogram Matching');
subplot(1,4,4);
imshow(output);
title('Inbuilt Histogram Matching');


figure;
maxim1=max(prk1);
maxim2=max(prk2);
maxim_out=max(prk_out);
m=maxim1;maxim2;maxim_out;
maxim=max(m);
subplot(1,4,1);
% actual distribution
bar(pixel_val,prk1,'BarWidth',1);
title('Original Histogram');
xlabel('Intensity Value');
ylabel('Probability Destribution');
axis([0,260,0,maxim+0.01]);
subplot(1,4,2);
% specified distribution 
bar(pixel_val,prk2,'BarWidth',1);
title('Specified Histogram');
xlabel('Intensity Value');
ylabel('Probability Destribution');
axis([0,260,0,maxim+0.01]);
subplot(1,4,3);
% transformed
bar(pixel_val,prk_out,'BarWidth',1);
title('Histogram Matching');
xlabel('Intensity Value');
ylabel('Probability Destribution');
axis([0,260,0,maxim+0.01]);
subplot(1,4,4);
% transformed using matlab inbuilt
bar(pixel_val,prk_final,'BarWidth',1);
title('Inbuilt Histogram Matching');
xlabel('Intensity Value');
ylabel('Probability Destribution');
axis([0,260,0,maxim+0.01]);
subplot(1,4,4);
%histnatching
% change the loss function accordingly
% diff=sum(sum(abs(uint8(final_image)-output),1),2);
diff=final_image-double(output);
mse=sum(sum((diff.*diff)/(rows1*columns1),1),2);
