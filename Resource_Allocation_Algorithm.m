N = 100;% Number of subcarriers
M = 20;% number of secondary users
K = 10;% number of primary users
E_g = 0.1;% Average value of inteference channel gain (g)
E_f = 1;% Average value of channel gain (f)
power_inteference_per_PU = 20;% power limit on each subcarrier derived from the PU interference threshold
substation_power_per_SU = 50;% power limit on each subcarrier derived from the secondary base station power budget
N_o = 1; %Normalized AWGN noise
d = 0.1 % Average PU interference gain on SU on a single channel
U = 100;%Transmit power per Primary User
J = d*U; %PU interference on a secondary user

[users_subcarriers users_subcarriers_powers_i h_array_2D f_array_2D] = phase_one(N,M,E_g,E_f,power_inteference_per_PU)

[users_subcarriers_powers_y final_power_allocations SU_network_throughput] = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU,N_o,J,N)
sum(users_subcarriers_powers_i,2);
sum_powers = sum(output,2);
num_SU_allocated = size(sum_powers)
percentage_users_allocated = (num_SU_allocated(1)/M) *100
function [users_subcarriers users_subcarriers_powers_i h_array_2D f_array_2D] = phase_one(N,M,E_g,E_f,power_inteference_per_PU)
    % Calculate the average number of subcarriers to allocate to each SU
    N_ave = N/M;
    users_subcarriers = zeros(M,15); % An array to keep track of which subcariers are allocated to which SUs
    users_subcarriers_powers_i = zeros(M,15); % An array to keep track of powers allocated to SUs subcarriers
    % Generate an array of random inteference channel gains (g) each mapped to its own subcarrier
    h_array = normrnd(E_g,0.1,[1,N]); % Normal distribution with mean E_g and standard deviation 0.1
    h_array = abs(h_array);
    f_array = normrnd(E_f,0.1,[1,N]); % For each subchannel generate the respective f gains
    f_array_2D = zeros(M,15);
    h_array_2D = zeros(M,15);
    power_per_subcarrier_i = power_inteference_per_PU/N;
    
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
            users_subcarriers_powers_i(m,column_num) = calculate_SU_power_allocation(beta,power_per_subcarrier_i,h_array);
            h_array_2D(m,column_num) = h_array(beta);
            f_array_2D(m,column_num) = f_array(beta);
            beta = beta + 1;
            num_of_allocated_subcarriers = num_of_allocated_subcarriers + 1;
            column_num = column_num + 1;
        end 
        n = n+0.1;
    end    
    users_subcarriers = trim_matrix(users_subcarriers);
    users_subcarriers_powers_i = trim_matrix(users_subcarriers_powers_i);
    h_array_2D = trim_matrix(h_array_2D);
    f_array_2D = trim_matrix(f_array_2D);
end

function power_value = calculate_SU_power_allocation(beta,power_per_subcarrier_i,h_array)
    power_value = power_per_subcarrier_i/h_array(beta);
end

function [users_subcarriers_powers_y final_power_allocations SU_network_throughput] = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU,N_o,J,N)
    users_subcarriers_powers_y = power_allocation(f_array_2D,substation_power_per_SU);
    final_power_allocations = min(users_subcarriers_powers_i,users_subcarriers_powers_y);
    SU_network_throughput = (f_array_2D.*final_power_allocations)/(J+N_o);

    size_SU_network_throughput = size(SU_network_throughput);
    for i = 1:size_SU_network_throughput(1)
        for j = 1:size_SU_network_throughput(2)
            if(SU_network_throughput(i,j) ~= 0)
                SU_network_throughput(i,j) = SU_network_throughput(i,j) + 1;
                SU_network_throughput(i,j) = log2(SU_network_throughput(i,j));
            end
        end
    end
    SU_network_throughput = sum(SU_network_throughput,"all")/N;
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