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

