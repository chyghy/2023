import random
file_path = 'vs2_list.txt'
out_path='./'

wanted_num =5000

seeds = [x for x in range(10)]

with open(file_path) as f:
        name_list = f.readlines()
for seed in seeds:
    random.seed(seed)
    choosed=random.sample(name_list,wanted_num)
    with open (out_path+'downsample_'+str(wanted_num)+'_'+str(seed)+'.txt','w') as f:
        for i in choosed:
            f.write(i)