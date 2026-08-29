clc;clear;

% 设置外部密钥和影响因子
Ex_key = [1,-1,0.1,1.5,-1.5,0.2];
scale_factor = 0.2;

% 读取需要加密的图片
PI1 = imread("../Images/misc/4.2.03.tiff");
% 调整尺寸至 256x256
PI1 = imresize(PI1, [256, 256]);

% 生成内部密钥
[In_Key1] = generate_key(PI1, Ex_key, scale_factor);
% 获取加密图像
[CI1] = encryption(PI1, In_Key1);
imshow(CI1);
% 获取解密图像
[DI1] = decryption(CI1, In_Key1);