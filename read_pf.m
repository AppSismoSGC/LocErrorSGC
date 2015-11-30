function [S,vcnt] = read_pf(pffile)


% FGETS approach
fid = fopen(pffile,'r');
tline = fgets(fid);
tlcnt = 0;
while ischar(tline)
    if (tline(1)~='#')
       C = strsplit(tline);
       for i = 1:length(C)
          tlcnt = tlcnt + 1;       
          S(tlcnt) = C(i);
       end
    end
    tline = fgets(fid);
end
fclose(fid);

vcnt = tlcnt;



