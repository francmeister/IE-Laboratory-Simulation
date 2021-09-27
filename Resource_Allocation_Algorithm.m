N = 100;% Number of subcarriers
M = 20;% number of secondary users
K = 20;% number of primary users
E_g = 0.1;% Average value of inteference channel gain (g)
E_f = 1;% Average value of channel gain (f)
power_per_subcarrier_i = 20;% power limit on each subcarrier derived from the PU interference threshold
power_per_SU_y = 50;% power limit on each subcarrier derived from the secondary base station power budget

[users_subcarriers users_subcarriers_powers f_array_2D] = subcarrier_allocation(N,M,E_g,E_f,power_per_subcarrier_i)
users_subcarriers_powers_y = power_allocation(f_array_2D,users_subcarriers,users_subcarriers_powers,power_per_SU_y)

function [users_subcarriers users_subcarriers_powers f_array_2D] = subcarrier_allocation(N,M,E_g,E_f,power_per_subcarrier_i)
    % Calculate the average number of subcarriers to allocate to each SU
    N_ave = N/M;
    users_subcarriers = zeros(M,N/2); % An array to keep track of which subcariers are allocated to which SUs
    users_subcarriers_powers = zeros(M,N/2); % An array to keep track of powers allocated to SUs subcarriers
    % Generate an array of random inteference channel gains (g) each mapped to its own subcarrier
    h_array = normrnd(E_g,0.1,[1,N]); % Normal distribution with mean E_g and standard deviation 0.1
    f_array = normrnd(E_f,0.1,[1,N]); % For each subchannel generate the respective f gains
    f_array_2D = zeros(M,N/2);
    
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
            users_subcarriers_powers(m,column_num) = calculate_SU_power_allocation(beta,power_per_subcarrier_i,h_array);
            f_array_2D(m,column_num) = f_array(beta);
            beta = beta + 1;
            num_of_allocated_subcarriers = num_of_allocated_subcarriers + 1;
            column_num = column_num + 1;
        end 
        n = n+0.1;
    end    
    size_users_subcarriers = size(users_subcarriers);
    num_of_rows = 0;
    for i = 1:size_users_subcarriers(1)
        if(users_subcarriers(i,1) == 0)
            break;
        else
            num_of_rows = num_of_rows + 1;
        end
    end
    users_subcarriers = users_subcarriers(1:num_of_rows,:);
    users_subcarriers_powers = users_subcarriers_powers(1:num_of_rows,:);
    f_array_2D = f_array_2D(1:num_of_rows,:);
end

function power_value = calculate_SU_power_allocation(beta,power_per_subcarrier_i,h_array)
    power_value = power_per_subcarrier_i/h_array(beta);
end

function users_subcarriers_powers_y = power_allocation(f_array_2D,users_subcarriers,users_subcarriers_powers,power_per_SU_y)
    size_users_subcarriers = size(users_subcarriers);
    sum_f = sum(f_array_2D,2);
    users_subcarriers_powers_y = zeros(size_users_subcarriers(1),size_users_subcarriers(2));
    for i = 1:size_users_subcarriers(1)
        for j = 1:size_users_subcarriers(2)
            if(users_subcarriers(i,j) ~= 0)
                w = f_array_2D(i,j)/sum_f(i);
                P_y = w*power_per_SU_y;
                users_subcarriers_powers_y(i,j) = P_y;
            end
        end
    end
    
    size_users_subcarriers = size(users_subcarriers);
    num_of_rows = 0;
    for i = 1:size_users_subcarriers(1)
        if(users_subcarriers(i,1) == 0)
            break;
        else
            num_of_rows = num_of_rows + 1;
        end
    end
    users_subcarriers_powers_y = users_subcarriers_powers_y(1:num_of_rows,:);
end