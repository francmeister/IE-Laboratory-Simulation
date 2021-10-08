
function [users_subcarriers users_subcarriers_powers_i h_array_2D f_array_2D] = phase_one(n, N,M,E_g,E_f,power_inteference_per_PU)
% Calculate the average number of subcarriers to allocate to each SU
N_ave = N/M;
users_subcarriers = zeros(M,15); % An array to keep track of which subcariers are allocated to which SUs
users_subcarriers_powers_i = zeros(M,15); % An array to keep track of powers allocated to SUs subcarriers
% Generate an array of random inteference channel gains (g) each mapped to its own subcarrier

h_array = normrnd(E_g,0.1,[1,N]); % Normal distribution with mean E_g and standard deviation 0.1
h_array = abs(h_array);
f_array = normrnd(E_f,0.1,[1,N]); % For each subchannel generate the respective f gains
% h_array = raylpdf([1:0.1:N], E_g);
% f_array = raylpdf([1:0.1:N], E_f);
f_array_2D = zeros(M,15);
h_array_2D = zeros(M,15);
power_per_subcarrier_i = power_inteference_per_PU/N;

% Sort the subcarriers in ascending order of channel gains. This is to ensure that those subcarriers with lowest
% channel inteference gain (g) are assigned first.
h_array = sort(h_array);
beta = 1;
% n = 1;
% n = 1.2 ;
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
%     n = n+0.1;
%     n = 1.2 ;

end
users_subcarriers = trim_matrix(users_subcarriers);
users_subcarriers_powers_i = trim_matrix(users_subcarriers_powers_i);
h_array_2D = trim_matrix(h_array_2D);
f_array_2D = trim_matrix(f_array_2D);
end

function power_value = calculate_SU_power_allocation(beta,power_per_subcarrier_i,h_array)
power_value = power_per_subcarrier_i/h_array(beta);
end
