function [processed_image,T_ig] = temp(input_image, r_b,r_g,g_b,k,Tpre,output_folder,T_ig)

% 调用函数提取图像的矩形区域
cropped_img = imcrop(input_image,[674.5 180.5 341 67]);

% 显示原图和裁剪后的图像
% subplot(1, 2, 1);
% imshow(input_image);
% title('原始图像');
% 
% subplot(1, 2, 2);
% imshow(cropped_img);
% title('裁剪后的矩形区域');

img = im2double(cropped_img);
R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
G_B = G./B;
T = [300:10:1500];

% Calibrate the theoretical G/B curve to experimental G/B points, then use
% only the monotonic high-temperature branch for inversion.
T_fit_min = 650;
if exist('G_B_exp.txt', 'file')
    g_b_exp_data = readmatrix('G_B_exp.txt');
    exp_T = g_b_exp_data(:, 1);
    exp_g_b = g_b_exp_data(:, 2);
    theory_g_b_at_exp = interp1(T, g_b, exp_T, 'linear', 'extrap');
    valid_exp = isfinite(exp_T) & isfinite(exp_g_b) & isfinite(theory_g_b_at_exp);
    if sum(valid_exp) >= 2
        g_b_cal_coeff = polyfit(theory_g_b_at_exp(valid_exp), exp_g_b(valid_exp), 1);
        g_b_cal = polyval(g_b_cal_coeff, g_b);
    else
        g_b_cal = g_b;
    end
else
    g_b_cal = g_b;
end

fit_idx = T >= T_fit_min;
T_fit = T(fit_idx);
g_b_fit = g_b_cal(fit_idx);
[g_b_fit, sort_idx] = sort(g_b_fit);
T_fit = T_fit(sort_idx);
[g_b_fit, unique_idx] = unique(g_b_fit, 'stable');
T_fit = T_fit(unique_idx);

G_B(isinf(G_B) | isnan(G_B)) = 0; % 将矩阵中的Inf 和 nan 替换为 0

% 创建一个新的矩阵 T_new 来存储因变量
T_new = zeros(size(G_B));

% 对于每个 G_B 中的元素，根据规则计算 T_new 中的对应值
for i = 1:size(G_B, 1)
    for j = 1:size(G_B, 2)
        G_B_val = G_B(i, j);  % 获取矩阵中的值
        % 当 R, G, B 三个矩阵的对应值均大于 250 时
        if R(i,j) > 0.9 && G(i,j) > 0.9 && B(i,j) > 0.9
            % 则 T_new 对应的值为高温拟合段下界
            T_new(i,j) = T_fit(1);        
        elseif G_B_val == 0
            % 如果矩阵中的值为 0，则 T_new 对应的值对应预热温度
            T_new(i, j) = 273+Tpre;
        elseif G_B_val == 1
            % 如果值为 1，则限制在高温拟合段内
            T_new(i, j) = interp1(g_b_fit, T_fit, G_B_val, 'linear', 'extrap');
        elseif G_B_val < min(g_b_fit)
            % Below the fitted high-temperature branch, keep the preheat temperature.
            T_new(i, j) = 273+Tpre;
        elseif G_B_val > max(g_b_fit)
            % 如果矩阵中的值大于拟合段最大值，则取拟合段温度上界
            T_new(i, j) = T_fit(end);
        else
            % 如果矩阵中的值在拟合段范围内，使用插值方法计算 T 值
            T_new(i, j) = interp1(g_b_fit, T_fit, G_B_val, 'linear', 'extrap');
        end
    end
end

% % 将 T_new 存储到 cell 数组中
% all_T_new{k} = T_new;
filename = sprintf('T_new_%03d.mat', k);
% 创建完整的文件路径
output_path = fullfile(output_folder, filename);
% 保存矩阵 T_new 到指定路径
save(output_path, 'T_new');  % 保存矩阵 T_new 到 .mat 文件
% G/B;
filename1 = sprintf('G_B_%03d.mat', k);
% 创建完整的文件路径
output_path1 = fullfile(output_folder, filename1);
% 保存矩阵 G_B 到指定路径
save(output_path1, 'G_B');  % 保存矩阵 T_new 到 .mat 文件

% %% 计算着火点位置的平均温度
% % 定义圆心坐标 (1193, 357) 和半径 r
% center_x = 365;
% center_y = 1200;
% r = 10;  % 半径，可以根据需要调整
% 
% % 创建网格坐标矩阵
% [x, y] = meshgrid(1:size(T_new, 2), 1:size(T_new, 1));
% 
% % 计算每个点到圆心的距离
% distance = sqrt((x - center_y).^2 + (y - center_x).^2);
% 
% % 创建掩模，选择半径内的点
% mask = distance <= r;
% 
% % 计算掩模区域内的平均值
% T_ig(k) = mean(T_new(mask));
% 
% % % 输出计算结果
% % disp(['T_ig: ', num2str(T_ig)]);

%% 绘制图像
% figure;
% imagesc(T_new);
% colorbar;%添加颜色条
% axis equal;% 保持横纵坐标比例一致

% 获取图像尺寸（像素）
num_rows = size(T_new, 1);  % 图像的行数 (900)
num_cols = size(T_new, 2);  % 图像的列数 (5120)

% 创建热图。直接用毫米坐标绘图，避免再手动把毫米刻度换算成像素刻度。
temperature_min = 273+Tpre;
temperature_max = max(T);
x_range_mm = 20;
y_range_mm = 4.5;
x_mm = linspace(0, x_range_mm, num_cols);
y_mm = linspace(0, y_range_mm, num_rows);

% 只平滑和插值绘图用矩阵，不改变前面保存的原始 T_new 数据。
T_plot = T_new;
smooth_sigma = 1.2;  % Gaussian sigma, in pixels
smooth_radius = ceil(3 * smooth_sigma);
[kernel_x, kernel_y] = meshgrid(-smooth_radius:smooth_radius, -smooth_radius:smooth_radius);
gaussian_kernel = exp(-(kernel_x.^2 + kernel_y.^2) / (2 * smooth_sigma^2));
gaussian_kernel = gaussian_kernel / sum(gaussian_kernel(:));
kernel_weight = conv2(ones(size(T_plot)), gaussian_kernel, 'same');
T_plot = conv2(T_plot, gaussian_kernel, 'same') ./ kernel_weight;
T_plot = min(max(T_plot, temperature_min), temperature_max);

plot_upsample_factor = 3;
x_mm_plot = linspace(x_mm(1), x_mm(end), num_cols * plot_upsample_factor);
y_mm_plot = linspace(y_mm(1), y_mm(end), num_rows * plot_upsample_factor);
T_plot = interp2(x_mm, y_mm, T_plot, x_mm_plot, y_mm_plot', 'linear');
T_plot(isnan(T_plot)) = temperature_min;
T_plot = min(max(T_plot, temperature_min), temperature_max);

figure('Color', 'w');
imagesc(x_mm_plot, y_mm_plot, T_plot);  % 绘制细网格插值后的热图
if exist('turbo', 'file') == 2 || exist('turbo', 'builtin') == 5
    colormap(turbo(256));
else
    colormap(parula(256));
end
% 设置颜色条范围
caxis([temperature_min, temperature_max]);  % 与 T = 300:10:1500 保持一致
cb = colorbar;  % 添加颜色条
cb.Label.String = 'Temperature (K)';

% 设置坐标轴标签
xlabel('X (mm)');
ylabel('Y (mm)');
% 设置图片标题为 'i s'
if k <= 25
    frame_time = (k - 1) / 5;
else
    frame_time = 5 + (k - 26);
end
title(sprintf('%.1f s', frame_time), 'FontSize', 12, 'FontWeight', 'normal');
set(gca, 'FontSize', 11, 'LineWidth', 0.8, 'TickDir', 'out', 'Box', 'on');

% 保证横纵坐标比例一致
axis equal;  % 保持横纵坐标比例一致
axis image;      % 保持图像长宽比
xlim([0, x_range_mm]);
ylim([0, y_range_mm]);

% 返回图像对象作为输出
processed_image = gcf;  % 获取当前图形句柄作为输出
% exportgraphics(processed_image, 'high_quality_image.tiff', 'Resolution', 300);
end
