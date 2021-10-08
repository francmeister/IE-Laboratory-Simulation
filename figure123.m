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
for M = 4:4:16
    if M ~=12
        num_subcarrier_per_SU = N /M ;
        for U = 1:30
            J = d*10^ (U/20) ;
            for iter =1:frames

                n = 1.2 ;
                [users_subcarriers users_subcarriers_powers_i h_array_2D f_array_2D] = phase_one(n,N,M,E_g,E_f,power_inteference_per_PU);
                [users_subcarriers_powers_y final_power_allocations SU_network_throughput fairness_index SU_network_throughput_columnly ] = phase_two(users_subcarriers_powers_i,f_array_2D,substation_power_per_SU,N_o,J,N, M,num_subcarrier_per_SU);
                sum_powers = sum(users_subcarriers_powers_i,2);
                num_SU_allocated = size(sum_powers);

                percentage_users_allocated_ =percentage_users_allocated_+ (num_SU_allocated(1)/M) *100;
                SU_network_throughput_ = SU_network_throughput_ + SU_network_throughput;
                SU_network_throughput_columnly_ = SU_network_throughput_columnly_ +SU_network_throughput_columnly;
                fairness_index_ = fairness_index_ + fairness_index ;

                if iter==frames

                    SU_network_throughput_arr(U) = SU_network_throughput_/frames;
                    SU_network_throughput_columnly_arr(U) = SU_network_throughput_columnly_/frames;
                    fairness_index_arr(U) = fairness_index_/frames ;
                    percentage_users_allocate_d_arr(U) = percentage_users_allocated_/frames;

                    %             final_power_allocations = final_power_allocations;
                    %             sumf= sum(final_power_allocations,2);
                    %             users_subcarriers;
                    %             final_power_allocations_ = size(final_power_allocations);

                    %reset
                    percentage_users_allocated_ =0;
                    SU_network_throughput_=0;
                    SU_network_throughput_columnly_ = 0;
                    fairness_index_ = 0 ;

                end
            end

        end
        UU = 1:30;
        figure(1)
        plot(UU, SU_network_throughput_columnly_arr)
        title('Relationship between PU SNR and Throughput');
        ylabel('Throughput (bit/sec/Hz)');
        xlabel('PU SNR (dB)')
        legend('M=4', 'M=8','M=16');
        grid on;
        grid minor;
        hold on

        figure(2)
        plot(UU, fairness_index_arr)
        title('Relationship between PU SNR and  Fairness index');
        ylabel('Fairness Index');
        xlabel('PU SNR (dB)')
        legend('M=4', 'M=8','M=16');
        grid on;
        grid minor;
        hold on

        figure(3)
        plot(SU_network_throughput_columnly_arr,fairness_index_arr)
        title('Relationship between Fairness Index and Throughput');
        xlabel('Throughput (bit/sec/Hz)');
        ylabel('Fairness Index');
        legend('M=4', 'M=8','M=16');
        grid on;
        grid minor;
        hold on
        SU_network_throughput_columnly_arr = [];
        fairness_index_arr=[];


        percent_per_M_SU (M_count) = mean(percentage_users_allocate_d_arr);
        M_count = M_count + 1;
        percentage_users_allocate_d_arr = [];

    end


end
hold off

percent_per_M_SU

hold off
