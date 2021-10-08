function output_matrix = trim_matrix(input_matrix)
size_input_matrix = size(input_matrix);
num_of_rows = 0;
for i = 1:size_input_matrix(1)
    if(input_matrix(i,1) == 0)
        break;
    else
        num_of_rows = num_of_rows + 1;
    end
end
output_matrix = input_matrix(1:num_of_rows,:);
end