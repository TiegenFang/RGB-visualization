clear all; clc; close all;
   
% input_folder - 输入图像的文件夹路径
% output_folder - 处理后图像保存的文件夹路径

input_folder = 'I:\1-科研\1-SST\12.16怀来实验\1s-16db-220-1MPa\时间标';  % 输入文件夹路径
output_folder = 'I:\1-科研\1-SST\12.16怀来实验\1s-16db-220-1MPa\时间标'; % 输出文件夹路径

%%将图片存储为视频
% 设置视频帧率（每秒显示多少帧）
frame_rate = 5;  % 30 帧每秒

% 获取文件夹中所有图片文件，按序号排序（假设文件名是数字形式）
image_files = dir(fullfile(input_folder, '*.jpg'));  % 可根据需要修改为其他格式
image_files = natsortfiles({image_files.name});  % 按文件名自然排序

% 创建视频写入对象
video_writer = VideoWriter(output_folder, 'Uncompressed AVI');  % 可以选择不同的编码格式
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

disp(['视频已保存为: ', output_folder]);