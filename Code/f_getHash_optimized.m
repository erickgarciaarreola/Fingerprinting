
%
%
%
function y = f_getHash_optimized(data,fan_out)
    hash_array=zeros(1,2);
    idx =1;
    for k=1:1:length(data)-fan_out %each constelation point is an anchor
        for j=1:1:fan_out  %creating as many addresses
            %fist column
            f1=data(k,2); %anchor
            f2=data(k+j,2); %target zone
            delta_t=data(k+j,1)-data(k,1); %t2-t1
            address = sprintf('%d%d%d', f1, f2, delta_t);
            address_32 = str2double(address);
            %second column
            abs_offset_t=data(k,1); %time
            %saving data in array
            hash_array(idx,1) = address_32;
            hash_array(idx,2) = abs_offset_t;
            idx = idx+1;
        end
    end
    y = sortrows(hash_array); %return sorted structure

end