clear all; clc; close all;

%比色数据导入
r_b = xlsread('E:\课题组\17-催化燃烧\4-实验数据\1-光学可视化处理\RGB数值.xlsx','Sheet1');
r_g = xlsread('E:\课题组\17-催化燃烧\4-实验数据\1-光学可视化处理\RGB数值.xlsx','Sheet2');
g_b = xlsread('E:\课题组\17-催化燃烧\4-实验数据\1-光学可视化处理\RGB数值.xlsx','Sheet3');

%导入图片读取rgb值
img = imread('I:\1-科研\1-SST\12.16怀来实验\1s-16db-220-1.5MPa\Pic_20241216190210965-323.tiff');
% img = imread('I:\1-科研\1-SST\12.16怀来实验\1s-16db-260-0.6MPa\Pic_20241216191033989-369.tiff');

% % 设置矩形区域的左上角和右下角坐标
% x1 = 500;  % 矩形左上角的列
% y1 = 2700;   % 矩形左上角的行
% x2 = 4700;  % 矩形右下角的列
% y2 = 1900;  % 矩形右下角的行

% 调用函数提取图像的矩形区域
cropped_img = imcrop(img,[500 1800 4200 900]);

% 显示原图和裁剪后的图像
subplot(1, 2, 1);
imshow(img);
title('原始图像');

subplot(1, 2, 2);
imshow(cropped_img);
title('裁剪后的矩形区域');

% figure;
% imshow(img);

% rectangle('position',[2300,3800,10,10],'EdgeColor','b','LineWidth',1)
% % rect = imrect;
% % positon = wait(rect);
% img = imcrop(img,[2300 3800 10 10]);
% figure;
% imshow(img);

img = im2double(cropped_img);
R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
R_G = R./G;
G_B = G./B;
T = [300:10:1500];
r_g = r_g * 0.7;figure;
plot(r_g,T)
p(1)=spline(r_g,T);

R_G(isinf(R_G) | isnan(R_G)) = 0; % 将矩阵中的Inf 和 nan 替换为 0


% 创建一个新的矩阵 T_new 来存储因变量
T_new = zeros(size(R_G));

% 对于每个 R_G 中的元素，根据规则计算 T_new 中的对应值
for i = 1:size(R_G, 1)
    for j = 1:size(R_G, 2)
        R_G_val = R_G(i, j);  % 获取矩阵中的值
        
        if R_G_val == 0
            % 如果矩阵中的值为 0，则 T_new 对应的值也为 0
            T_new(i, j) = 273;      
        elseif R_G_val == 1
            % 如果值为 1，则取 T的最大值
                 T_new(i, j) = max(T);
        elseif R_G_val < min(r_g)
            % 如果矩阵中的值小于 r_g 中的最小值，则 T_new 对应的值为 r_g 最小值时的 T 值
            T_new(i, j) = T(find(r_g == min(r_g), 1));
        elseif R_G_val > max(r_g)
            % 如果矩阵中的值大于 r_g 中的最大值，则 T_new 对应的值为 r_g 最大值时的 T 值
            T_new(i, j) = T(find(r_g == max(r_g), 1));
        else
            % 如果矩阵中的值在 r_g 的范围内，使用插值方法计算 T 值
            T_new(i, j) = interp1(r_g, T, R_G_val, 'linear', 'extrap');
        end
    end
end

% T=[16,22,30,50]%数值可以输入自己需要的任意值
% T1=ppval(p(1),R_B(1,:));
% T1=ppval(p(1),R_G);
figure;
imagesc(T_new);
colorbar;%添加颜色条

% 保持横纵坐标比例一致
axis equal;

% plot(g_b,T)
% p(2)=spline(g_b,T);
% % T=[16,22,30,50]%数值可以输入自己需要的任意值
% % T1=ppval(p(1),R_B(1,:));
% T2=ppval(p(2),G_B);
% figure;
% imagesc(T2);
% colorbar;%添加颜色条