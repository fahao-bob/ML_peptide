#!/bin/bash

set -e

### Import module 
cat > temp_01.txt << _EOF_
import numpy as np
from ase import Atoms
_EOF_


### Read the name of X.gro
echo -n "import the name of gro> "
read name_gro


####################################
######  ATOM POSITION (PBC)  #######
####################################

cat >> temp_01.txt << _EOF_

p = np.array(
_EOF_


### Delete all blank lines, and output lines(>2)
sed '/^\s*$/d' ${name_gro}.gro > temp_02.txt
end_line=`sed '/^\s*$/d' ${name_gro}.gro | wc -l`
awk -v b=${end_line} '{if(NR>2&&NR<b) print 10*$4,10*$5,10*$6}' temp_02.txt > temp_03.txt
## edit format
a=`wc -l temp_03.txt|awk '{print $1}'`
#sed -i "${a}s/,//g" temp_03.txt
sed -i "1s/^/[/" temp_03.txt
sed -i "${a}s/$/])/" temp_03.txt
awk '{print "               ""["$1","$2","$3"],"}' temp_03.txt > temp_04.txt
sed -i "${a}s/)],/])/g" temp_04.txt


###########################
######  CELL (PBC)  #######
###########################

cat > temp_05.txt << _EOF_

c = np.array(
_EOF_

tail -1 ${name_gro}.gro|awk '{print"             ""[["10*$1",0.,0.],"}' >> temp_05.txt
tail -1 ${name_gro}.gro|awk '{print"             ""[0.,"10*$2",0.],"}' >> temp_05.txt
tail -1 ${name_gro}.gro|awk '{print"             ""[0.,0.,"10*$3"]])"}' >> temp_05.txt



### Read the name of gjf
echo -n "import the name of gjf> "
read name_gjf

### Delete all blank lines, and output lines(>6)
sed '/^\s*$/d' ${name_gjf}.gjf | awk '{if(NR>6) print $1'} > temp_11.txt

### Transpose from column to row
atom_spec=`awk '{ for(i=1;i<=NF;i++){ if(NR==1){ arr[i]=$i; }else{ arr[i]=arr[i]""$i; } } } END{ for(i=1;i<=NF;i++){ print arr[i]; } }' temp_11.txt`


### Read the name of system
echo -n "import the name of system> "
read name_system

cat > temp_12.txt << _EOF_
${name_system} = Atoms('${atom_spec}', positions=p, cell=c, pbc=[1, 1, 1])
${name_system}.write('${name_system}.traj')
_EOF_



cat temp_01.txt temp_04.txt temp_05.txt temp_12.txt > ${name_system}.py
rm -r temp_??.txt












