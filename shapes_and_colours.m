function [sorted_shapes, fig] = shapes_and_colours(image)
%%
RGB = imread(image);
imshow(RGB);
%%
I = im2gray(RGB);
bw = imbinarize(I);
imshow(bw);
%%
minSize = 30;
bw = bwareaopen(bw,minSize);
imshow(bw);
%%
se = strel("disk",2);
bw = imclose(bw,se);
imshow(bw);
%%
bw = imcomplement(bw);
bw = imfill(bw,"holes");
imshow(bw);
%%
[B,L] = bwboundaries(bw,"noholes");

imshow(label2rgb(L,@jet,[.5 .5 .5]))
%%
%%%%%

centroid_value = [];
sorted_shapes = [];
whatShape = 2;

hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2),boundary(:,1),"w",LineWidth=2)
end
title("Objects with Boundaries in White")

% determine roundness
stats = regionprops(L,"Circularity","Centroid");

threshold = 0.90;
square_threshold = 0.75;
%
for k = 1:length(B)

  % Obtain (X,Y) boundary coordinates corresponding to label "k"
  boundary = B{k};
  
  % Obtain the circularity corresponding to label "k"
  circ_value = stats(k).Circularity;
  
  % Display the results
  circ_string = sprintf("%2.2f",circ_value);

  % Mark objects above the threshold with a black circle
  if circ_value > threshold
    centroid_value = stats(k).Centroid;
    whatShape = 0;
    sorted_shapes = [sorted_shapes; centroid_value(1), centroid_value(2), whatShape, 0];
  end

  % between a certain threshold for square
  if circ_value > square_threshold && circ_value <= threshold
    centroid_value = stats(k).Centroid;
    whatShape = 1;
    sorted_shapes = [sorted_shapes; centroid_value(1), centroid_value(2), whatShape, 0];
  end
 

  text(boundary(1,2)-35,boundary(1,1)+13,circ_string,Color="y",...
       FontSize=14,FontWeight="bold")
  
end
title("Centroids of Circular Objects and Circularity Values")


[R, G, B] = imsplit(RGB);
threshold = 60;
margin = 30;


%check square
for i = 1:size(sorted_shapes,1)

    y = round(sorted_shapes(i,2));
    x = round(sorted_shapes(i,1));
    
    R_value = R(y, x);
    G_value = G(y, x);
    B_value = B(y, x);
    
    redMask = (R_value > threshold) & (R_value > G_value + margin) & (R_value > B_value + margin);
    blueMask = (B_value > threshold) & (B_value > R_value + margin) & (B_value > G_value + margin);
    greenMask = (G_value > threshold) & (G_value > B_value + margin) & (G_value > R_value + margin);

if sorted_shapes(i,3) == 0
    shape_desc = "circle";
elseif sorted_shapes(i,3) == 1
    shape_desc = "square";
end
    
    if redMask
        fprintf('The %s at (%d, %d) is red.\n', shape_desc, x, y);
        plot(sorted_shapes(i,1),sorted_shapes(i,2),"ko");
        text(sorted_shapes(i,1) - 10, sorted_shapes(i,2) + 20, sprintf('RED %s', shape_desc),  'Color', 'r', 'FontSize', 12);
        sorted_shapes(i,4) = 1;
    elseif blueMask
        fprintf('The %s at (%d, %d) is blue.\n', shape_desc, x, y);
        plot(sorted_shapes(i,1),sorted_shapes(i,2),"ko");
        text(sorted_shapes(i,1) - 10,  sorted_shapes(i,2) + 20, sprintf('BLUE %s', shape_desc), 'Color', 'b', 'FontSize', 12);
        sorted_shapes(i,4) = 2;
    elseif greenMask
        fprintf('The %s at (%d, %d) is green.\n', shape_desc, x, y);
        plot(sorted_shapes(i,1),sorted_shapes(i,2),"ko");
        text(sorted_shapes(i,1) - 10,  sorted_shapes(i,2) + 20, sprintf('GREEN %s', shape_desc), 'Color', 'g', 'FontSize', 12);
        sorted_shapes(i,4) = 3;
    end
end
fig = gcf;
end



%% call in mainfunc
% [sorted_shapes, fig] = shapes_and_colours("finn.png");
% frame = getframe(fig);
% figImage = frame.cdata;
% 
% montage({A, figImage});