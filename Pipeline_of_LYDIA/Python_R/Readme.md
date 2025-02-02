## The dictory Scripts contains the R & Python scripts needed for the analysis process
### circular.py
This is used for selecting contigs which are circular or longer than 1.5kb.
### seq.py
This is used to obtain complete lysogen contig sequences because the output file final-viral-combined.fa only contains prophage sequnces.
### site.py
This is used to get a table that describes the position of prophages in contig predicted by virsorter and checkV. And if the results of there two tools overlap, the result of checkV will prevail.
### interaction.py
This is used to determine whether each 1kb bin belongs to bacteria or prophage.
### ratio.r
This is used to calculate the differential coverage between regions of prophage and  surrounding regions(+/-10kb).
### plot.r
This is used to plot the reads coverage of prophage and host.
### partial_bed.r
This is used to selecting the upstream and downstream 10kb region around the prophage to calculate the relative activity of the prophage.


