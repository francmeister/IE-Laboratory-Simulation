function [users_subcarriers_powers_y final_power_allocations SU_network_throughput fairness_index ...
    SU_network_throughput_columnly ] = phase_two(users_subcarriers_powers_i,f_array_2D,...
    substation_power_per_SU,N_o,J,N,M, num_subcarrier_per_SU)

users_subcarriers_powers_y = power_allocation(f_array_2D,substation_power_per_SU);
final_power_allocations = min(users_subcarriers_powers_i,users_subcarriers_powers_y);
SU_network_throughput = (f_array_2D.*final_power_allocations)/(J+N_o);

size_SU_network_throughput = size(SU_network_throughput);
actual_allocated_subcar = 0;
subcarriers_per_SU = [];
for i = 1:size_SU_network_throughput(1)
    for j = 1:size_SU_network_throughput(2)
        if(SU_network_throughput(i,j) ~= 0)
            SU_network_throughput(i,j) = SU_network_throughput(i,j) + 1;
            SU_network_throughput(i,j) = log2(SU_network_throughput(i,j));
            actual_allocated_subcar = actual_allocated_subcar +  1;
        end
    end
    subcarriers_per_SU (i) = actual_allocated_subcar;
    actual_allocated_subcar = 0;
end

SU_network_throughput_in_col_form  = sum(SU_network_throughput,2);
M_covered_SU = length(subcarriers_per_SU);
SU_network_throughput_columnly = [];
for i=1:M_covered_SU
    SU_network_throughput_columnly(i) = SU_network_throughput_in_col_form(i)/subcarriers_per_SU(i) ;
    SU_network_throughput_in_col_form(i) = SU_network_throughput_in_col_form(i)/subcarriers_per_SU(i) ;
end

fairness_index_numarator = sum(SU_network_throughput_in_col_form, "all");
fairness_index_numarator = fairness_index_numarator^2 ;
fairness_index_denominator = SU_network_throughput_in_col_form .^2 ;
fairness_index_denominator = sum(fairness_index_denominator, "all");
fairness_index = fairness_index_numarator/( M_covered_SU * fairness_index_denominator );

SU_network_throughput = sum(SU_network_throughput,"all")/N;
SU_network_throughput_columnly = sum(SU_network_throughput_columnly,"all");
end