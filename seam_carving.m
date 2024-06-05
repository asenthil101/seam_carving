close all;
%Display
%Image 1
img1 = imread("https://a-z-animals.com/media/2022/04/shutterstock_1666284073.jpg");
img1 = imresize(img1, 0.25);
s_img1 = seam_carve(img1, 50, 'Width');
figure;subplot(1,2,1);imshow(img1);
subplot(1,2,2);imshow(s_img1);
%Image 2
img2 = imread("https://upload.wikimedia.org/wikipedia/commons/e/e2/BroadwayTowerSeamCarvingA.png");
s_img2 = seam_carve(img2, 35, 'Width');
figure;subplot(1,2,1);imshow(img2);
subplot(1,2,2);imshow(s_img2);
%Image 3
img3 = imread("https://www.travelandleisure.com/thmb/ildFh_HcRHGYli6qL01ytKrVXkI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/grand-teton-rocky-mountains-USMNTNS0720-52499caea565471a8571acdfc3dfd9fe.jpg");
img3 = imresize(img3, 0.33);
s_img3 = seam_carve(img3, 50, 'Height');
figure;subplot(1,2,1);imshow(img3);
subplot(1,2,2);imshow(s_img3);
%Image 4
%My own image
img4 = imread("https://github.com/asenthil101/images/blob/main/BBAAFFCE-FFA6-448C-93B4-B043220D9D11_1_105_c.jpeg?raw=true");
s_img4 = seam_carve(img4, 50, 'Height');
figure;subplot(1,2,1);imshow(img4);
subplot(1,2,2);imshow(s_img4);
%Image 5
%Example of a bad seam carving image
img5 = imread("https://images.unsplash.com/photo-1501386761578-eac5c94b800a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y3Jvd2QlMjBvZiUyMHBlb3BsZXxlbnwwfHwwfHw%3D&w=1000&q=80")
img5 = imresize(img5, 0.5);
s_img5 = seam_carve(img5, 400, 'Width');
figure;subplot(1,2,1);imshow(img5);
subplot(1,2,2);imshow(s_img5);

%FUNCTIONS
%Seam Carve
%Direction is the dimension in which the image compresses
function result = seam_carve(im, pixels, direction)
    e_im = energy_function(im);
    new_im = im;
    if strcmp(direction, 'Height')
       for i = 1:pixels
           new_im = seam_remove(new_im, e_im, 'Horizontal');
       end
    elseif strcmp(direction, 'Width')
        for i = 1:pixels
            new_im = seam_remove(new_im, e_im, 'Vertical');
        end
    end
    result = new_im;
end

%Create Energy Image
function result = energy_function(im)
    gray_im = double(rgb2gray(im));
    
    gradient_x=gray_im(:,2:end)-gray_im(:,1:end-1);
    gradient_y=gray_im(2:end,:)-gray_im(1:end-1,:);
    
    e_im = sqrt(gradient_x(1:end-1,:).^2+gradient_y(:,1:end-1).^2);
    e_im(end+1,end+1)=0;
    result = e_im;
end

%Find Seam and Remove
function result = seam_remove(im, e_im, seam_direction)

    if strcmp(seam_direction, 'Horizontal')
        hseam = horizontal_seam(e_im);
        for i = 1:length(hseam)
            im(hseam(i):end-1,i,:) = im(hseam(i)+1:end,i,:);
        end
        result = im(1:end-1,:,:);
        
    elseif strcmp(seam_direction, 'Vertical')
        vseam = vertical_seam(e_im);
        for i = 1:length(vseam)
            im(i,vseam(i):end-1,:) = im(i,vseam(i)+1:end,:);
        end
        result = im(:,1:end-1,:);
    end
end

%Find Horizontal Seam
function result  = horizontal_seam(e_im)
    A = zeros(size(e_im));
    
    A(:,1)=e_im(:,1);
    A(1,2:end)=inf;
    A(end,2:end)=inf;
    for j=2:size(A,2)
        a = movmin(A(:,j-1),3);
        for k=2:size(A,1)-1
            A(k,j)=e_im(k,j) + a(k);
        end
    end
    
    seam=zeros(size(A,2),1);
    
    [val, index]=min(A(:,end));
    seam(end)=index;
    for i=size(A,2)-1:-1:1
        [val, index2]=min(A(index-1:index+1,i));
        index=index+index2-2;
        seam(i)=index;
    end
    result = seam;
end

%Find Vertical Seam
function result = vertical_seam(e_im)
    A = zeros(size(e_im));
    
    A(1,:)=e_im(1,:);
    A(2:end,1)=inf;
    A(2:end,end)=inf;
    for j=2:size(A,1)
        a = movmin(A(j-1,:),3);
        for k=2:size(A,2)-1
            A(j,k)= e_im(j,k) + a(k);
        end
    end
    
    seam = zeros(size(A,1),1);
    [val, index] = min(A(end,:));
    seam(end) = index;
    for i = size(A,1)-1:-1:1
        [val, index2]=min(A(i,index-1:index+1));
        index = index + index2 - 2;
        seam(i)= index;
    end
    result = seam;
end