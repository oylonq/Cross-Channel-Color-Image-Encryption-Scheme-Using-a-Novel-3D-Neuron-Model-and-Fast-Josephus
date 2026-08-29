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
% 获取解密图像
[DI1] = decryption(CI1, In_Key1);

PI2 = imread("../Images/misc/4.2.06.tiff");
% 调整尺寸至 256x256
PI2 = imresize(PI2, [256, 256]);
[In_Key2] = generate_key(PI2, Ex_key, scale_factor);
[CI2] = encryption(PI2, In_Key2);
[DI2] = decryption(CI2, In_Key2);


PI3 = imread("../Images/misc/4.2.07.tiff");
% 调整尺寸至 256x256
PI3 = imresize(PI3, [256, 256]);
[In_Key3] = generate_key(PI3, Ex_key, scale_factor);
[CI3] = encryption(PI3, In_Key3);
[DI3] = decryption(CI3, In_Key3);

PI4 = imread("../Images/misc/house.tiff");
% 调整尺寸至 256x256
PI4 = imresize(PI4, [256, 256]);
[In_Key4] = generate_key(PI4, Ex_key, scale_factor);
[CI4] = encryption(PI4, In_Key4);
[DI4] = decryption(CI4, In_Key4);


figure(1);
subplot(3,4,1);
imshow(PI1);
xlabel('(a)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,2);
imshow(PI2);
xlabel('(b)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,3);
imshow(PI3);
xlabel('(c)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,4);
imshow(PI4);
xlabel('(d)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,5);
imshow(CI1);
xlabel('(e)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,6);
imshow(CI2);
xlabel('(f)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,7);
imshow(CI3);
xlabel('(g)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,8);
imshow(CI4);
xlabel('(h)', 'FontSize', 12, 'FontWeight', 'bold');


subplot(3,4,9);
imshow(DI1);
xlabel('(i)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,10);
imshow(DI2);
xlabel('(j)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,11);
imshow(DI3);
xlabel('(k)', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,4,12);
imshow(DI4);
xlabel('(l)', 'FontSize', 12, 'FontWeight', 'bold');
