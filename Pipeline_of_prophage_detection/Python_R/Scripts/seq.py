from Bio import SeqIO
import os
import sys
import re
try:
    file1_path = os.path.abspath(sys.argv[1])
    file2_path = os.path.abspath(sys.argv[2])
except:
    print('Please check file path')
file1 = SeqIO.parse(file1_path,'fasta')
contig_id=[]
contig1_seq=[]
contig2_seq=[]
for contig1 in file1:
    file2 = SeqIO.parse(file2_path,'fasta')
    for contig2 in file2:
        if str(contig1.id).split('||')[0] == str(contig2.id).split(' ')[0]:
            contig_id.append(str(contig1.id).split('||')[0])
            contig1_seq.append(contig1.seq)
            contig2_seq.append(contig2.seq)

out_dir=''
for i,j in zip(file1_path,file2_path):
    if i==j:
        out_dir=out_dir+i
    else:
        out_dir=out_dir.rsplit('/',1)[0]
        break
if re.search('(srr\d+)',out_dir,re.I):
    out_name= re.search('(srr\d+)',out_dir,re.I).group(0)
else:
    print('Can not match SRR* chars')
            
with open(out_dir+'/'+out_name+'.txt','w') as f:
    print('The result is saved to '+out_dir+'/'+out_name+'.txt')
    with open(out_dir+'/'+out_name+'_seq.fa','w') as f2:
        print('The sequences saved to '+out_dir+'/'+out_name+'_seq.fa')
        f.write('ID\tContig1\tContig2\tEqual\n')
        for i,j,k in zip(contig_id,contig1_seq,contig2_seq):
            if len(j) == len(k):
                f.write(i+'\t'+str(len(j))+'\t'+str(len(k))+'\tTrue\n')
                f2.write('>'+i+'\n'+str(k)+'\n')
            else:
                f.write(i+'\t'+str(len(j))+'\t'+str(len(k))+'\tFalse\n')
                f2.write('>'+i+'\n'+str(k)+'\n')
