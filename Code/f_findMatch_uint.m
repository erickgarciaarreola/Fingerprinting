%
%
%
%
function match_data = f_findMatch_uint(reference_files,hash_s)
    num_references = size(reference_files,2);
    match_data = struct();
    hash_s = [hash_s; 0 0]; %growing this one just to be able to loop j+1
    modul = 10;
    start=1;
    stop=num_references;
    for i=start:1:stop 
        limit_l = find(reference_files(i).hash_s >= hash_s(1,1));                
         if(isempty(limit_l))
             match_data.histo(i).h_t = 0;
             match_data.n_offsets_t(i)=0;
            continue;  %no hash exist in this reference need to move to next loop
        else
            limit_l = limit_l(1);  
        end
        
        limit_h = find(reference_files(i).hash_s >= hash_s(end-1,1));  %minus one becase the appen of 0 0 for j +1 
        if(isempty(limit_h))
            limit_h = length(reference_files(i).hash_s);
        else
            limit_h = limit_h(1);   
        end

        hash_cut = reference_files(i).hash_s(limit_l:limit_h,:);
        %reference_files(i).hash_cut = reference_files(i).hash_s(limit_l:limit_h,:);
        cont = 0;
        matched_offsets_p=(zeros(60e3,2));
        temp = (hash_cut);  %this is to save in access time, is faster not to access full struct.
        e = 0;
        %Sliming this out
        temp_32 = uint32(temp(:,1));
        hash_s_32 = uint32(hash_s(:,1));
        temp_2 = temp(:,2);
        hash_s_2 = hash_s(:,2);
        %
        
        %Short search!!
        %limit = 1;
        for j=1:1:(size(hash_s_32,1)-1)
            if(cont==1)
                cont=0;
                continue; %skip this loop, since matches were already appended in previous one. 
            end

            matched_hashes_32 = find(temp_32 == hash_s_32(j));
            %temp_32_s = temp_32(limit:end);
            %matched_hashes_32_s = find(temp_32_s == hash_s_32(j));
            %matched_hashes_32_s = matched_hashes_32_s + limit -1 ;
            
            %After finding the matching addresse's  indexes we apend its
            %offsets (for each individial song)side to side so we can substrac them and get the diference.  
            if(~isempty(matched_hashes_32)) %Not appending if not necesary
                %limit = matched_hashes_32_s(end);
                sh = size(matched_hashes_32,1);
                s = e + 1;
                e = s + sh-1;
                if hash_s_32(j) == hash_s_32(j+1)  %this means this a repeted address!! good, no need to find again, skeep next loop
                    matched_offsets_p(s:e,:) = [ones(sh,1)*hash_s_2(j),temp_2(matched_hashes_32)];
                    s = e + 1;
                    e = s + sh-1;
                    matched_offsets_p(s:e,:) = [ones(sh,1)*hash_s_2(j+1),temp_2(matched_hashes_32)];
                    cont = 1;
                else
                    matched_offsets_p(s:e,:) = [ones(sh,1)*hash_s_2(j),temp_2(matched_hashes_32)];

                end 
            end
        end
        if(e > 60e3)
            disp('this is cliping');
            disp(e);
        end
        %match_data.mo(i).matched_offsets_p = matched_offsets_p(1:e,:); %resizsing array
        %match_data.histo(i).h_t = histcounts(match_data.mo(i).matched_offsets_p(:,2) - match_data.mo(i).matched_offsets_p(:,1),'BinMethod','integers');  % substracting times to get offsets
        %[match_data.n_offsets_t(i,1),match_data.n_offsets_t(i,2) ] = max(match_data.histo(i).h_t); %saving max form histogram and inxe which is the offset value which gave more matches

        match_data.mo.matched_offsets_p = matched_offsets_p(1:e,:); %resizsing array
        match_data.histo.h_t = histcounts(match_data.mo.matched_offsets_p(:,2) - match_data.mo.matched_offsets_p(:,1),'BinMethod','integers');  % substracting times to get offsets
        [match_data.n_offsets_t(i,1),match_data.n_offsets_t(i,2) ] = max(match_data.histo.h_t); %saving max form histogram and inxe which is the offset value which gave more matches

        %Improve search
        if(mod(i,modul) == 0)
            if(max(match_data.n_offsets_t(:,1)) > 5*mean(match_data.n_offsets_t(:,1)))
                break  %no need to keep searching, most likely this is already found given history of matches.
            end     
        end

    end
    [match_data.match_t,match_data.match_index_t] = max(match_data.n_offsets_t(:,1));
end
