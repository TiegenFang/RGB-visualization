clear; clc; close all;

% Batch normalize raw optical images by exposure time and crop the ROI for
% presentation. This script does not change the temperature-processing
% workflow in main.m/temp.m.

input_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化';
output_folder = 'D:\1work\离子液体\项目工作\2.SST\T9\现场数据\绿色离子液体项目在轨试验数据整理（公开）\可视化第一组\光学可视化\曝光归一化裁剪';

crop_rect = [674.5 180.5 341 67];
output_extension = '.tiff';
normalization_percentile = 99.5;
target_normalized_percentile = 0.85;
max_normalization_gain = 20;
min_reference_value = 1e-6;

image_files_raw = dir(fullfile(input_folder, '*.bmp'));
r_order = nan(1, numel(image_files_raw));
exposure_time = nan(1, numel(image_files_raw));
keep_image = false(1, numel(image_files_raw));

for file_idx = 1:numel(image_files_raw)
    file_token = regexp(image_files_raw(file_idx).name, ...
        'R(\d+)_G\d+_E(\d+)_RGB\.bmp$', 'tokens', 'once');

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
exposure_time = exposure_time(keep_image);

[r_order, sort_idx] = sort(r_order);
image_files = image_files(sort_idx);
exposure_time = exposure_time(sort_idx);

if isempty(image_files)
    error('No valid BMP files were found in: %s', input_folder);
end

target_exposure = median(exposure_time);

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

fprintf('Loaded %d valid BMP files by R order; skipped %d E=0 broken files.\n', ...
    numel(image_files), skipped_broken);
fprintf('Target exposure for normalization: %.0f\n', target_exposure);

for i = 1:numel(image_files)
    image_path = fullfile(input_folder, image_files(i).name);
    raw_img = imread(image_path);
    cropped_raw = imcrop(im2double(raw_img), crop_rect);

    exposure_gain = target_exposure / exposure_time(i);
    roi_reference = prctile(cropped_raw(:), normalization_percentile);
    percentile_gain = target_normalized_percentile / max(roi_reference, min_reference_value);
    normalization_gain = min([exposure_gain, percentile_gain, max_normalization_gain]);
    cropped_img = min(max(cropped_raw * normalization_gain, 0), 1);

    output_filename = sprintf('%03d_R%d_E%d%s', ...
        i, r_order(i), exposure_time(i), output_extension);
    output_path = fullfile(output_folder, output_filename);
    imwrite(cropped_img, output_path);

    fprintf('Saved %03d, R%d, E%d, gain %.2f -> %s\n', ...
        i, r_order(i), exposure_time(i), normalization_gain, output_filename);
end

disp(['曝光归一化裁剪图片已保存到: ', output_folder]);
