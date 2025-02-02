from Bio import SeqIO
import sys
with open (sys.argv[2]+'filter_contig/circular_long.txt','w') as f:
    for contig in  SeqIO.parse(open(sys.argv[1]), 'fasta'):
        length = len(contig.seq)
        if length > 1500:
            if contig.seq[0:10] == contig.seq[length-10:]:
                f.write(contig.id+"\t"+str(length)+"\t"+"L_circular\n")
            else:
                f.write(contig.id+"\t"+str(length)+"\t"+"L_notcircular\n")
        else:
            if length > 500: 
                if contig.seq[0:10] == contig.seq[length-10:]:
                    f.write(contig.id+"\t"+str(length)+"\t"+"S_circular\n")
