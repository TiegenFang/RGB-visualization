clear all; clc; close all;
   
% input_folder - 输入图像的文件夹路径
% output_folder - 处理后图像保存的文件夹路径

%比色数据导入
r_b = xlsread('H:\传承资料\2-SST实验数据2.0\1-光学可视化处理\RGB数值-空间相机-长光所镜片.xlsx','Sheet1');
r_g = xlsread('H:\传承资料\2-SST实验数据2.0\1-光学可视化处理\RGB数值-空间相机-长光所镜片.xlsx','Sheet2');
g_b = xlsread('H:\传承资料\2-SST实验数据2.0\1-光学可视化处理\RGB数值-空间相机-长光所镜片.xlsx','Sheet3');

input_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化';  % 输入文件夹路径
output_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化\新'; % 输出文件夹路径
Tpre = 300; %输入预热温度，单位摄氏度 
% 获取文件夹中所有 BMP 图片，并按文件名中 R 后面的拍照序号排序。
% 文件名格式示例：Light_512x2048_R4_G1_E4440_RGB.bmp
% R 后面的数字表示拍照顺序；E 后面的数字为 0 时表示数据破坏，跳过。
image_files_raw = dir(fullfile(input_folder, '*.bmp'));
r_order = nan(1, numel(image_files_raw));
exposure_time = nan(1, numel(image_files_raw));
keep_image = false(1, numel(image_files_raw));

for file_idx = 1:numel(image_files_raw)
    file_token = regexp(image_files_raw(file_idx).name, 'R(\d+)_G\d+_E(\d+)_RGB\.bmp$', 'tokens', 'once');
    if isempty(file_token)
        warning('Skip unmatched file name: %s', image_files_raw(file_idx).name);
        continue;
    end

    r_order(file_idx) = str2double(file_token{1});
    exposure_time(file_idx) = str2double(file_token{2});
    keep_image(file_idx) = exposure_time(file_idx) > 0;
end

skipped_broken = sum(exposure_time == 0);
image_files = image_files_raw(keep_image);
r_order = r_order(keep_image);
[r_order, sort_idx] = sort(r_order);
image_files = image_files(sort_idx);

fprintf('Loaded %d valid BMP files by R order; skipped %d E=0 broken files.\n', ...
    numel(image_files), skipped_broken);

% 如果输出文件夹不存在，创建该文件夹
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

N = length(image_files)
% % 初始化一个结构体或 cell 数组来保存每次的矩阵
% all_T_new = cell(1, N);  % 使用 cell 数组来存储每次的 T_new

T_ig = zeros(1, N);  % 创建一个 1 行 N 列的零矩阵

% 遍历每个图像文件
    for i = 1:length(image_files)
        fprintf('Processing output %03d, R%d, %s\n', i, r_order(i), image_files(i).name);
        % 构造文件路径
        image_path = fullfile(input_folder, image_files(i).name);
        
        % 读取图像
        input_image = imread(image_path);
        
        % 调用 mask 和 temp 函数处理图像
        processed_image = mask(input_image);  % mask掉催化剂部分
%         [processed_image, all_T_new] = temp(processed_image, r_b,r_g,g_b,i,Tpre,all_T_new);  % 计算燃烧区域温度
        frame_order = r_order(i) + 1;  % R0 对应第 1 帧，用于按真实拍照顺序计算时间
        [processed_image,T_ig] = temp(processed_image, r_b,r_g,g_b,i,Tpre,output_folder,T_ig,frame_order);  % 计算燃烧区域温度
        
        % 保存图像为文件
        output_filename = sprintf('%03d.tiff', i);  % 按序号保存图像
        output_path = fullfile(output_folder, output_filename);
        
        % 保存图像为 .tiff格式（可以修改为其他格式）
%         saveas(gcf, output_path);
        exportgraphics(processed_image, output_path, 'Resolution', 300);

        % 关闭当前图形窗口
        close(gcf);
    end
    
    
% %% 将所有的结果保存到同一个 mat 文件中  
% % 文件名
% filename = sprintf('T_new_%d.mat', k);
% % 创建完整的文件路径
% output_path = fullfile(output_folder, filename);
% % 将数据保存到指定路径
% save(output_path, 'all_T_new');

%% 将图片存储为视频
input_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化\新';  % 输入文件夹路径
output_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化\新'; % 输出文件夹路径

% 设置视频帧率（每秒显示多少帧）
frame_rate = 5;  % 5 帧每秒

% 获取文件夹中所有图片文件，按序号排序（假设文件名是数字形式）
image_files = dir(fullfile(input_folder, '*.tiff'));  % 可根据需要修改为其他格式
image_files = natsortfiles({image_files.name});  % 按文件名自然排序

% 创建视频输出路径
video_filename = 'output_video.mp4';  % 可以根据需要修改文件名
video_path = fullfile(output_folder, video_filename);  % 完整视频文件路径

% 创建视频写入对象
video_writer = VideoWriter(video_path, 'MPEG-4');  % 使用 MPEG-4 格式
video_writer.FrameRate = frame_rate;  % 设置帧率
open(video_writer);

% 遍历每张图片并写入视频
for i = 1:length(image_files)
    % 读取当前图片
    image_path = fullfile(input_folder, image_files{i});
    img = imread(image_path);

    % 将当前图像写入视频
    writeVideo(video_writer, img);
end

% 关闭视频文件
close(video_writer);

disp(['视频已保存为: ', video_path]);


