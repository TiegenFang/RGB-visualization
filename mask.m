function processed_image = mask(input_image)
    % threshold_image - 将图像中灰度值高于阈值的部分保留 RGB 信息，其他区域设置为 0
    %
    % 输入:
    % input_image - 输入的彩色图像
    % threshold   - 灰度值的阈值
    %
    % 输出:
    % processed_image - 处理后的图像

    % 设置灰度值的阈值
    threshold = 25;
    
    % 将图像转换为灰度图
    gray_image = rgb2gray(input_image);
    
    % 创建一个与输入图像相同大小的全零矩阵
    processed_image = input_image;

    % 找出灰度值大于阈值的像素位置
    mask = gray_image > threshold;
    
    % 将灰度值低于阈值的区域对应的 RGB 值设置为 0
    processed_image(repmat(~mask, [1, 1, 3])) = 0;
    
%     % 使用掩模直接修改每个通道
%     for c = 1:3
%         channel = processed_image(:,:,c);  % 提取当前通道
%         channel(~mask) = 0;  % 将掩模外的区域置为 0
%         processed_image(:,:,c) = channel;  % 将修改后的通道放回原图
%     end
    
    % 显示处理后的图像
    imshow(processed_image);
    
end