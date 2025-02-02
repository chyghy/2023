import pandas as pd
import sys
work_dir = sys.argv[1]
file1=work_dir+'coverage/1k_cov.txt'
file2=work_dir+'coverage/trim_all_u.txt'
df1=pd.read_table(file1,sep='\t',header=None,index_col=0)
df2=pd.read_table(file2,sep='\t',header=0,index_col=0)
temp = []
for i in range(df1.shape[0]):
    if df1.index[i] not in df2.index:
        temp.append('NA')
    elif ((df1.iloc[i,0] >= df2.loc[df1.index[i],'trim_bp_start']) | (df2.loc[df1.index[i],'trim_bp_start'] <100)) & (df1.iloc[i,1] <= df2.loc[df1.index[i],'trim_bp_end']):
        temp.append('v')
    else:
        temp.append('h')
df1.loc[:,'4'] = temp
df1.to_csv(work_dir+'coverage/1k_interaction.txt',sep='\t')

