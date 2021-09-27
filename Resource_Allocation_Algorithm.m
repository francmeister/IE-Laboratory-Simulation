N = 100;% Number of subcarriers
M = 20;% number of secondary users
K = 20;% number of primary users
E_g = 0.1;% Average value of inteference channel gain (g)
E_f = 1;% Average value of channel gain (f)
power_inteference_per_PU = 20;% power limit on each subcarrier derived from the PU interference threshold
substation_power_per_SU = 50;% power limit on each subcarrier derived from the secondary base station power budget

[users_subcarriers users_subcarriers_powers_i f_array_2D] = phase_one(N,M,E_g,E_f,power_inteference_per_PU)

output = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU)
sum(users_subcarriers_powers_i,2)
sum(output,2)
function [users_subcarriers users_subcarriers_powers_i f_array_2D] = phase_one(N,M,E_g,E_f,power_inteference_per_PU)
    % Calculate the average number of subcarriers to allocate to each SU
    N_ave = N/M;
    users_subcarriers = zeros(M,N/2); % An array to keep track of which subcariers are allocated to which SUs
    users_subcarriers_powers_i = zeros(M,N/2); % An array to keep track of powers allocated to SUs subcarriers
    % Generate an array of random inteference channel gains (g) each mapped to its own subcarrier
    h_array = normrnd(E_g,0.1,[1,N]); % Normal distribution with mean E_g and standard deviation 0.1
    f_array = normrnd(E_f,0.1,[1,N]); % For each subchannel generate the respective f gains
    f_array_2D = zeros(M,N/2);
    h_array_2D = zeros(M,N/2);
    
    % Sort the subcarriers in ascending order of channel gains. This is to ensure that those subcarriers with lowest
    % channel inteference gain (g) are assigned first.
    h_array = sort(h_array);   
    beta = 1;
    n = 1;
    % Run a for loop that assigns subcarriers to secondary users
    for m = 1:M
        column_num = 1;
        num_of_allocated_subcarriers = 0;
        while(num_of_allocated_subcarriers < n*N_ave && beta <= N)
            users_subcarriers(m,column_num) = beta;
            f_array_2D(m,column_num) = f_array(beta);
            h_array_2D(m,column_num) = h_array(beta);
            beta = beta + 1;
            num_of_allocated_subcarriers = num_of_allocated_subcarriers + 1;
            column_num = column_num + 1;
        end 
        n = n+0.1;
    end    
    users_subcarriers = trim_matrix(users_subcarriers);
    f_array_2D = trim_matrix(f_array_2D);
    users_subcarriers_powers_i = power_allocation(h_array_2D,power_inteference_per_PU);
end

function output = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU)
    users_subcarriers_powers_y = power_allocation(f_array_2D,substation_power_per_SU);
    output = users_subcarriers_powers_y;
end 

function users_subcarriers_powers = power_allocation(gain_array,power_per_user)
    size_gain_array = size(gain_array);
    sum_f = sum(gain_array,2);
    users_subcarriers_powers = zeros(size_gain_array(1),size_gain_array(2));
    for i = 1:size_gain_array(1)
        for j = 1:size_gain_array(2)
            if(gain_array(i,j) ~= 0)
                w = gain_array(i,j)/sum_f(i);
                P_y = w*power_per_user;
                users_subcarriers_powers(i,j) = P_y;
            end
        end
    end
    users_subcarriers_powers = trim_matrix(users_subcarriers_powers);
end

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