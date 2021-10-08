N = 128;% Number of subcarriers
M = 16  ;% number of secondary users
K = 10;% number of primary users
E_g = 0.1;% Average value of inteference channel gain (g)
E_f = 1;% Average value of channel  gain (f)
pow_in_DB_for_SU = 20;
pow_in_DB_for_PU = 12;
substation_power_per_SU = 10^ (pow_in_DB_for_SU/20) ;% power limit on each subcarrier derived from the secondary base station power budget
power_inteference_per_PU = 10^ (pow_in_DB_for_PU/20);% power limit on each subcarrier derived from the PU interference threshold
N_o = 1; %Normalized AWGN noise
d = 0.1 ;% Average PU interference gain on SU on a single channel
U = 160;%Transmit power per Primary User;
J = d*10^ (U/20) ; %PU interference on a secondary user
num_subcarrier_per_SU = N /M ;

frames = 10;
percentage_users_allocated_ =0;
SU_network_throughput_=0;
SU_network_throughput_columnly_ = 0;
fairness_index_ = 0 ;
SU_network_throughput_columnly_arr =[];
SU_network_throughput_arr = [] ;
fairness_index_arr = [] ;
percentage_users_allocate_d_arr = [];

M_count = 1 ;

for M = 4:4:4
    if M ~=12
        num_subcarrier_per_SU = N /M ;
        index = 1;
        for n = 1:0.1:5
            U = 12;
            J = d*10^ (U/20) ;
            for iter =1:frames

                [users_subcarriers users_subcarriers_powers_i h_array_2D f_array_2D] = phase_one(n,N,M,E_g,E_f,power_inteference_per_PU);
                [users_subcarriers_powers_y final_power_allocations SU_network_throughput fairness_index SU_network_throughput_columnly ] = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU,N_o,J,N, M,num_subcarrier_per_SU);
                sum_powers = sum(users_subcarriers_powers_i,2);
                num_SU_allocated = size(sum_powers);

                percentage_users_allocated_ =percentage_users_allocated_+ (num_SU_allocated(1)/M) *100;
                SU_network_throughput_ = SU_network_throughput_ + SU_network_throughput;
                SU_network_throughput_columnly_ = SU_network_throughput_columnly_ +SU_network_throughput_columnly;
                fairness_index_ = fairness_index_ + fairness_index ;

                if iter==frames

                    SU_network_throughput_arr(index) = SU_network_throughput_/frames;
                    SU_network_throughput_columnly_arr(index) = SU_network_throughput_columnly_/frames;
                    fairness_index_arr(index) = fairness_index_/frames ;
                    percentage_users_allocate_d_arr(index) = percentage_users_allocated_/frames;
                    index = index +1 ;
                    %reset
                    SU_network_throughput_=0;
                    SU_network_throughput_columnly_ = 0;
                    fairness_index_ = 0 ;

                end
            end

%     11111111111111111111111111111111111111
%             n
%     users_subcarriers
%     final_power_allocations
%     111111111111111111111111111111111111111

        end
        nn = 1:0.1:5;
        figure(4)
%         SU_network_throughput_columnly_arrv=size(SU_network_throughput_columnly_arr)
%         nnnn = size(nn)
        plot(nn, SU_network_throughput_columnly_arr)
        title('Relationship between n and Throughput');
        ylabel('Throughput (bit/sec/Hz)');
        xlabel('fairness constraint n')
        legend('M=4', 'M=8','M=16');
        grid on;
        grid minor;
        hold on

        figure(5)
        plot(nn, fairness_index_arr)
        title('Relationship between n and  Fairness index');
        ylabel('Fairness Index');
        xlabel('fairness constraint n')
        legend('M=4', 'M=8','M=16');
        grid on;
        grid minor;
        hold on

    end


end
hold off
