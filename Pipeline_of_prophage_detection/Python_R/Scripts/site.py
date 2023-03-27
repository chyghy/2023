import pandas as pd 
import sys

work_dir = sys.argv[1]
df1=work_dir+'vsout/trim_vsout.txt'
df2=work_dir+'checkV/trimV.txt'

file1=pd.read_csv(df1,sep='\t',header=None,index_col=0)
file2=pd.read_csv(df2,sep='\t',header=None,index_col=0)
insert_index = [i for i in file1.index if i not in file2.index]
out_file = pd.concat([file2,file1.loc[[i not in insert_index for i in file1.index],:]])
out_file.columns=['trim_bp_start','trim_bp_end']
out_file.index.name='seqname'
out_file.to_csv(work_dir+'coverage/trim_all_u.txt',sep='\t')
